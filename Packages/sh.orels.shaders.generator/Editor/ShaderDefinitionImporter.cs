using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEditor.Experimental.AssetImporters;
using UnityEngine;

namespace ORL.ShaderGenerator
{
    [ScriptedImporter(1, "orlshader")]
    public class ShaderDefinitionImporter : ScriptedImporter
    {
        public bool debugBuild;
        
        private readonly HashSet<string> _paramsOnlyBlock = new HashSet<string>
        {
            "%ShaderName",
            "%CustomEditor"
        };

        private List<ShaderBlock> _builtInBlocks;

        private readonly string[] _dataStructs = {
            "@/Structs/VertexData",
            "@/Structs/FragmentData"
        };
        
        private List<ShaderBlock> BuiltInBlocks
        {
            get
            {
                if (_builtInBlocks != null) return _builtInBlocks;
                var blocks = new List<ShaderBlock>();
                foreach (var block in _dataStructs)
                {
                    try
                    {
                        var parser = new Parser();
                        var sourceStrings = Utils.GetORLSource(block);
                        var blockSource = parser.Parse(sourceStrings);
                        blocks.AddRange(blockSource);
                    }
                    catch (Exception ex)
                    {
                        Debug.LogError(ex.ToString());
                        throw;
                    }
                }
                _builtInBlocks = blocks;
                return _builtInBlocks;
            }
        }
        
        private List<ShaderBlock> _builtInFunctions;
        
        private readonly string[] _functions = {
        };

        private List<ShaderBlock> BuiltInFunctions
        {
            get
            {
                if (_builtInFunctions != null) return _builtInFunctions;
                var blocks = new List<ShaderBlock>();
                foreach (var function in _functions)
                {
                    var parser = new Parser();
                    var sourceStrings = Utils.GetORLSource(function);
                    var blockSource = parser.Parse(sourceStrings);
                    blocks.AddRange(blockSource);
                }

                _builtInFunctions = blocks;
                return _builtInFunctions;
            }
        }

        private readonly string[] _libraries = {
            "@/Libraries/Utilities"
        };

        private const string SamplingLib = "@/Libraries/SamplingLibrary";

        private List<ShaderBlock> _builtInLibraries;
        
        private List<ShaderBlock> BuiltInLibraries
        {
            get
            {
                if (_builtInLibraries != null) return _builtInLibraries;
                var blocks = new List<ShaderBlock>();
                foreach (var library in _libraries)
                {
                    var parser = new Parser();
                    var sourceStrings = Utils.GetORLSource(library);
                    var blockSource = parser.Parse(sourceStrings);
                    blocks.AddRange(blockSource);
                }

                // Add sampling lib directly as well, we want it everywhere
                {
                    var parser = new Parser();
                    var sourceStrings = Utils.GetORLSource(SamplingLib);
                    var blockSource = parser.Parse(sourceStrings);
                    blocks.AddRange(blockSource);
                }

                _builtInLibraries = blocks;
                return _builtInLibraries;
            }
        }

        private const string DefaultLightingModel = "@/LightingModels/PBR";

        // Matches %BlockName without nuking %FunctionName()
        private readonly Regex _replacerRegex = new Regex(@"(?<!\/\/\s*)(%[a-zA-Z]+[\w\d]+)(?:$|[""\;\s])");
        
        // Matches %TemplateFeature(<FeatureName>)
        private readonly Regex _templateFeatureRegex = new Regex(@"%TemplateFeature\((?<identifier>""\w+"")\)");

        /// <summary>
        /// Here's the import flow:
        /// - First we parse the original shader definition
        /// - If it has an `Includes` block, we deep-resolve all the includes and inject their blocks into the combined list
        ///     - "self" gets replaced with the blocks from the original shader definition
        /// - Then we pick a lighting model. If none is included in the shader definition - we pick PBR
        /// - We then deep-resolve all the blocks from the lighting model and inject them into the combined list
        ///     - "target" from the LightingModel file gets replaced by already parsed blocks
        /// - We then look for the template. If the shader does not define one - we pick it from the Lighting model blocks
        /// - When that is done - we inject all the always included blocks, like Utilities, Sampling Library and Structs
        /// - Once all the blocks are gathered - we deduplicate them and put all the same named blocks into combined lists
        /// - We then start building the shader source from the template file
        /// - We parse the template line by line and replace the %SomeKeyword with the actual block source (if there is one)
        ///     - If there is no block with that name - we just remove the line
        /// - There are some unique types of blocks
        ///     - Single param blocks inject the contents of their "params" string instead of their body, this is just a convenience thing for the shader devs
        ///     - Function blocks get injected into the shader source at a special %Functions keyword
        ///         - Their call signatures are injected into their named keyword though (e.g. %VertexBase, etc)
        /// - All of the above maintains the correct indentation levels of the original source and preserves comments
        /// - Once the source is built - we stringify it all and create a shader asset
        /// - The ORLAssetPostProcessor then detects the result and adds it to the shader dropdown
        /// </summary>
        /// <param name="ctx"></param>
        public override void OnImportAsset(AssetImportContext ctx)
        {
            var textContent = File.ReadAllLines(ctx.assetPath);
            var workingFolder = ctx.assetPath.Substring(0, ctx.assetPath.LastIndexOf("/", StringComparison.InvariantCulture));

            var parser = new Parser();
            List<ShaderBlock> blocks = new List<ShaderBlock>();

            // We built-in imports first, otherwise the order of imports will be incorrect
            // Collecting and registering all the dependency objects
            var depList = new List<string>();
            depList.AddRange(_dataStructs);
            depList.AddRange(_functions);
            depList.AddRange(_libraries);
            depList.Add(SamplingLib);
            RegisterDependencies(depList, ctx);

            // Adding all the dependencies to the list of blocks
            blocks.AddRange(BuiltInBlocks);
            blocks.AddRange(BuiltInFunctions);
            blocks.AddRange(BuiltInLibraries);

            string shaderName;
            try
            {
                blocks.AddRange(parser.Parse(textContent));
                var shaderNameBlockIndex = blocks.FindIndex(b => b.Name == "%ShaderName");
                if (shaderNameBlockIndex == -1)
                {
                    throw new MissingBlockException("%ShaderName", "");
                }
                shaderName = blocks[shaderNameBlockIndex].Params[0];
                if (string.IsNullOrWhiteSpace(shaderName?.Replace("\"", "")))
                {
                    throw new MissingParameterException("name", "%ShaderName", "");
                }
                var includesIndex = blocks.FindIndex(b => b.Name == "%Includes");
                // Shaders can have direct includes (not via LightingModel or anything else
                // Here we deep-resolve them and inject them back into the blocks in the respective order
                if (includesIndex != -1)
                {
                    var resolvedBlocks = new List<ShaderBlock>();
                    foreach (var include in blocks[includesIndex].Contents)
                    {
                        var stripped = include.Replace("\"", "").Replace(",", "");
                        // We inject the already parsed blocks in place of "self"
                        if (stripped == "self")
                        {
                            resolvedBlocks.AddRange(blocks.Where(b => b.Name != "%Includes"));
                            continue;
                        }
                        
                        var blockParser = new Parser();
                        var deepDeps = new List<string>();
                        // We recursively collect everything that the lighting model depends on into a flattened list
                        Utils.RecursivelyCollectDependencies(new [] {stripped}.ToList(), ref deepDeps, workingFolder);
                        deepDeps.ForEach(dep => ctx.DependsOnSourceAsset(Utils.ResolveORLAsset(dep, dep.StartsWith("@/"), workingFolder)));
                        var deepBlocks = new List<ShaderBlock>();
                        foreach (var deepDep in deepDeps)
                        {
                            // since we already have the deps flattened, we can safely strip all the dependencies here
                            deepBlocks.AddRange(blockParser.Parse(Utils.GetAssetSource(deepDep, workingFolder)).Where(b => b.Name != "%Includes"));
                        }
                        resolvedBlocks.AddRange(deepBlocks);
                    }

                    blocks = resolvedBlocks;
                }
            }
            catch (Exception ex)
            {
                ctx.LogImportError(ex.ToString());
                ctx.LogImportError($"Failed to process the shader definition file {ctx.assetPath}");
                throw;
            }

            // Find and load the lighting model
            List<ShaderBlock> lightingModel;
            try
            {
                var lightingModelIndex = blocks.FindIndex(b => b.Name == "%LightingModel");
                // If we don't have a lighting model, use the default (PBR)
                var lightingModelName = lightingModelIndex == -1
                    ? DefaultLightingModel
                    : blocks[lightingModelIndex].Params[0].Replace("\"", "");
                var lightingModelPath =
                    Utils.ResolveORLAsset(lightingModelName, lightingModelName.StartsWith("@/"), workingFolder);
                var lmParser = new Parser();
                lightingModel = lmParser.Parse(Utils.GetAssetSource(lightingModelName, workingFolder));
                if (!string.IsNullOrEmpty(lightingModelPath))
                {
                    ctx.DependsOnSourceAsset(lightingModelPath);
                }

                // Lighting model defines some basic functions and dictates where the source shader gets plugged in
                var updatedBlocks = new List<ShaderBlock>();
                foreach (var lmInclude in lightingModel.Find(b => b.Name == "%Includes").Contents)
                {
                    var stripped = lmInclude.Replace("\"", "").Replace(",", "");
                    if (stripped == "target")
                    {
                        updatedBlocks.AddRange(blocks);
                        continue;
                    }

                    var blockParser = new Parser();
                    var deepDeps = new List<string>();
                    var lmWorkingFolder = lightingModelPath.Substring(0,
                        lightingModelPath.LastIndexOf("/", StringComparison.InvariantCulture));
                    // We recursively collect everything that the lighting model depends on into a flattened list
                    Utils.RecursivelyCollectDependencies(new[] {stripped}.ToList(), ref deepDeps, lmWorkingFolder);
                    deepDeps.ForEach(dep =>
                        ctx.DependsOnSourceAsset(Utils.ResolveORLAsset(dep, dep.StartsWith("@/"), lmWorkingFolder)));
                    var deepBlocks = new List<ShaderBlock>();
                    foreach (var deepDep in deepDeps)
                    {
                        // since we already have the deps flattened, we can safely strip all the dependencies here
                        deepBlocks.AddRange(blockParser.Parse(Utils.GetAssetSource(deepDep, lmWorkingFolder))
                            .Where(b => b.Name != "%Includes"));
                    }

                    updatedBlocks.AddRange(deepBlocks);
                }

                blocks = updatedBlocks;
            }
            catch (Exception ex)
            {
                ctx.LogImportError(ex.ToString());
                ctx.LogImportError($"Failed to load Lighting Model in {ctx.assetPath}", this);
                throw;
            }

            // Find and load the template file
            string[] template;
            try
            {
                var templateBlockIndex = blocks.FindIndex(b => b.Name == "%Template");
                // if no template is found - use the Lighting Model supplied one
                string templateName;
                if (templateBlockIndex > -1)
                {
                    templateName = blocks[templateBlockIndex].Params[0].Replace("\"", "");
                }
                else
                {
                    templateBlockIndex = lightingModel.FindIndex(b => b.Name == "%Template");
                    if (templateBlockIndex == -1)
                    {
                        throw new MissingBlockException("%Template",
                            "The lighting model is missing the %Template block");
                    }

                    templateName = lightingModel[templateBlockIndex].Params[0]?.Replace("\"", "");
                    ;
                    if (string.IsNullOrWhiteSpace(templateName))
                    {
                        throw new MissingParameterException("name", "%Template", "");
                    }
                }

                var templatePath = Utils.ResolveORLAsset(templateName);
                template = Utils.GetORLTemplate(templateName);
                if (!string.IsNullOrEmpty(templatePath))
                {
                    ctx.DependsOnSourceAsset(templatePath);
                }
            }
            catch (Exception ex)
            {
                ctx.LogImportError(ex.ToString());
                ctx.LogImportError($"Failed to load Template in {ctx.assetPath}", this);
                throw;
            }
            
            // Find and toggle template features
            try
            {
                var templateFeatures = new List<string>();
                var templateFeaturesIndex = blocks.FindIndex(b => b.Name == "%TemplateFeatures");
                if (templateFeaturesIndex > -1)
                {
                    templateFeatures = blocks[templateFeaturesIndex].Params.Select(p => p.Replace("\"", "")).ToList();
                }

                // run through the template and mutate it based on the features
                var newTemplate = new StringBuilder();
                var enteredFeature = false;
                string currentFeatureName = null;
                var skippingFeature = false;
                var nestLevel = 0;
                for (var index = 0; index < template.Length; index++)
                {
                    var trimmedLine = template[index].Trim();
                    if (trimmedLine.StartsWith("//", StringComparison.InvariantCulture))
                    {
                        newTemplate.AppendLine(template[index]);
                        continue;
                    }

                    if (enteredFeature)
                    {
                        if (trimmedLine.StartsWith("{")) nestLevel++;
                        if (trimmedLine.StartsWith("}")) nestLevel--;
                    }

                    if (enteredFeature && nestLevel == 0)
                    {
                        enteredFeature = false;
                        skippingFeature = false;
                        // feature exited, skip this line for the closing `}`
                        continue;
                    }
                    
                    var match = _templateFeatureRegex.Match(trimmedLine);
                    // add all normal lines
                    if (!match.Success)
                    {
                        if (!skippingFeature)
                        {
                            newTemplate.AppendLine(template[index]);
                        }
                        continue;
                    }

                    // if encountered nested feature - abort
                    if (enteredFeature)
                    {
                        ctx.LogImportError($"Found nested Template Features in {ctx.assetPath}. {match.Groups["identifier"].Value} was inside {currentFeatureName}", this);
                        throw new Exception("Nested Template Features are not supported");
                    }
                    
                    currentFeatureName = match.Groups["identifier"].Value.Replace("\"", string.Empty);
                    
                    // if this isn't a feature we want - skip it altogether
                    if (!templateFeatures.Contains(currentFeatureName))
                    {
                        skippingFeature = true;
                        enteredFeature = true;
                        // we skip 1 line for the opening `{`
                        nestLevel++;
                        index++;
                        continue;
                    }
                    
                    enteredFeature = true;
                    // we skip 1 line for the opening `{`
                    nestLevel++;
                    index++;
                }
                template = newTemplate.ToString().Split(new[] { Environment.NewLine, "\n"}, StringSplitOptions.None);
            }
            catch (Exception ex)
            {
                ctx.LogImportError(ex.ToString());
                ctx.LogImportError($"Failed to toggle Template Features in {ctx.assetPath}", this);
                throw;
            }

            // Collapse non-function blocks together and de-dupe things where makes sense
            blocks = OptimizeBlocks(blocks);
            
            // Override shader name to be the one from the source shader
            blocks[blocks.FindIndex(b => b.Name == "%ShaderName")].Params[0] = shaderName;
            
            // save function blocks to a separate list as they need special handling
            var functionBlocks = blocks.Where(b => b.IsFunction).Reverse().ToList();

            var finalShader = new StringBuilder();
            foreach (var line in template)
            {
                var newLine = new StringBuilder(line);
                var hadMatch = false;
                while (_replacerRegex.IsMatch(newLine.ToString()))
                {
                    hadMatch = true;
                    var match = _replacerRegex.Match(newLine.ToString());
                    var matchVal = match.Groups[1].Value;
                    var matchLen = matchVal.Length;

                    // Functions are a special case, they insert their code into the %Functions block
                    // And then insert a call to the function in the respective stage
                    switch (matchVal)
                    {
                        // Here we save all the function source code into the shader %Functions space
                        case "%Functions":
                        {
                            InsertContentsAtPosition(ref newLine, functionBlocks, match.Index, matchLen);
                            continue;
                        }
                        // Here we insert function calls into the pre-pass fragment stage
                        case "%PrePassColorFunctions":
                        {
                            var fragmentFns = functionBlocks.FindAll(b => b.Name == "%PrePassColor");
                            fragmentFns.Reverse();
                            fragmentFns.Sort((a,b) => a.Order.CompareTo(b.Order));
                            // the calls are inserted in reverse order to maintain offsets, so we reverse them back
                            fragmentFns.Reverse();
                            InsertFnCallAtPosition(ref newLine, fragmentFns, match.Index, matchLen);
                            continue;
                        }
                        // Here we insert function calls into the fragment stage
                        case "%FragmentFunctions":
                        {
                            var fragmentFns = functionBlocks.FindAll(b => b.Name == "%Fragment");
                            fragmentFns.Reverse();
                            fragmentFns.Sort((a,b) => a.Order.CompareTo(b.Order));
                            // the calls are inserted in reverse order to maintain offsets, so we reverse them back
                            fragmentFns.Reverse();
                            InsertFnCallAtPosition(ref newLine, fragmentFns, match.Index, matchLen);
                            continue;
                        }
                        // Here we insert function calls into the vertex stage
                        case "%VertexFunctions":
                        {
                            var vertexFns = functionBlocks.FindAll(b => b.Name == "%Vertex");
                            vertexFns.Reverse();
                            vertexFns.Sort((a,b) => a.Order.CompareTo(b.Order));
                            vertexFns.Reverse();
                            InsertFnCallAtPosition(ref newLine, vertexFns, match.Index, matchLen);
                            continue;
                        }
                        // Here we insert function calls into the vertex stage
                        case "%ColorFunctions":
                        {
                            var colorFns = functionBlocks.FindAll(b => b.Name == "%Color");
                            colorFns.Reverse();
                            colorFns.Sort((a,b) => a.Order.CompareTo(b.Order));
                            colorFns.Reverse();
                            InsertFnCallAtPosition(ref newLine, colorFns, match.Index, matchLen);
                            continue;
                        }
                        // Here we insert function calls into the fragment stage of shadowcaster
                        case "%ShadowFunctions":
                        {
                            var shadowFns = functionBlocks.FindAll(b => b.Name == "%Shadow");
                            shadowFns.Reverse();
                            shadowFns.Sort((a,b) => a.Order.CompareTo(b.Order));
                            shadowFns.Reverse();
                            InsertFnCallAtPosition(ref newLine, shadowFns, match.Index, matchLen);
                            continue;
                        }
                    }

                    // For non-function blocks - we simply replace the block name with the block contents
                    var foundBlockIndex = blocks.FindIndex(b => b.Name == matchVal);
                    if (foundBlockIndex != -1)
                    {
                        var block = blocks[foundBlockIndex];
                        
                        // These are special single-line blocks that only insert their params value
                        if (_paramsOnlyBlock.Contains(block.Name))
                        {
                            newLine.Remove(match.Index, matchLen);
                            // To appease unity gods - we define CustomEditor "" as the template, so then if nothing is passed
                            // It doesnt outright fail
                            // We should probably just insert a fallback block instead and remove this weird condition
                            if (block.Name == "%CustomEditor")
                            {
                                newLine.Insert(match.Index, block.Params[0].Replace("\"", ""));
                            }
                            else
                            {
                                newLine.Insert(match.Index, string.Join("", block.Params));
                            }
                            continue;
                        }

                        // This is a case for special functions that are unique per shader
                        // like Vert/Fragment base
                        if (block.IsFunction)
                        {
                            newLine.Remove(match.Index, matchLen);
                            newLine.Insert(match.Index, block.CallSign);
                            continue;
                        }

                        // Simply insert the block lines if no special cases are met
                        newLine.Remove(match.Index, matchLen);
                        newLine.Insert(match.Index, IndentContents(block.Contents, match.Index));
                        continue;
                    }
                    
                    // if nothing matched - clear out the current template hook and move on
                    {
                        newLine.Remove(match.Index, matchLen);
                    }
                }

                var stringLine = newLine.ToString();
                // if there was no match - just add the line as-is
                // otherwise only add if the result wasn't whitespace
                if (!string.IsNullOrWhiteSpace(stringLine) || !hadMatch)
                {
                    finalShader.AppendLine(stringLine);
                }
            }
            
            var shaderString = finalShader.ToString();
            var shader = ShaderUtil.CreateShaderAsset(ctx, shaderString, true);

            if (ShaderUtil.ShaderHasError(shader))
            {
                var errors = ShaderUtil.GetShaderMessages(shader);
                foreach (var error in errors)
                {
                    ctx.LogImportError(error.message + $"on line {error.line} in {ctx.assetPath}");
                }
            }
            else
            {
                ShaderUtil.ClearShaderMessages(shader);
            }

            var textAsset = new TextAsset(shaderString)
            {
                name = "Shader Source",
                hideFlags = HideFlags.HideInHierarchy
            };

            ctx.AddObjectToAsset("Shader", shader);
            ctx.SetMainObject(shader);
            ctx.AddObjectToAsset("Shader Source", textAsset);
        }

        private void RegisterDependencies(List<string> dependencyPaths, AssetImportContext ctx)
        {
            var workingFolder = ctx.assetPath.Substring(0, ctx.assetPath.LastIndexOf("/", StringComparison.InvariantCulture));
            foreach (var s in dependencyPaths)
            {
                string path;
                if (s.StartsWith("@/")) {
                    path = Utils.ResolveORLAsset(s);
                } else {
                    path = Utils.ResolveORLAsset(s, false, workingFolder);
                }
                if (!string.IsNullOrEmpty(path))
                {
                    ctx.DependsOnSourceAsset(path);
                    continue;
                }
                ctx.LogImportWarning("Failed to resolve dependency: " + s);
            }
        }
        
        /// <summary>
        /// Collapses all the same blocks together and deduplicates entries of blocks like Properties or Variables.
        /// Special blocks, like functions, are left untouched
        /// </summary>
        /// <param name="sourceBlocks"></param>
        /// <returns></returns>
        private List<ShaderBlock> OptimizeBlocks(List<ShaderBlock> sourceBlocks)
        {
            var keySet = new Dictionary<string, int>();
            var collapsedBlocks = new List<ShaderBlock>();
            // First pass - collapse blocks with the same name
            foreach (var block in sourceBlocks)
            {
                // We do not merge function blocks because they have unique call signs
                if (block.IsFunction)
                {
                    collapsedBlocks.Add(block);
                    continue;
                }

                if (!keySet.ContainsKey(block.Name))
                {
                    keySet.Add(block.Name, collapsedBlocks.Count);
                    collapsedBlocks.Add(block);
                    continue;
                }
            
                var index = keySet[block.Name];
                collapsedBlocks[index].Contents.Add("");
                collapsedBlocks[index].Contents.AddRange(block.Contents);
            }
            // Second pass - deduplicate things where it makes sense
            for (var i = 0; i < collapsedBlocks.Count; i++)
            {
                var block = collapsedBlocks[i];
                switch (block.Name)
                {
                    case "%Properties":
                        collapsedBlocks[i].Contents = DeDuplicateByRegex(block.Contents, _propertyRegex);
                        continue;
                    case "%Variables":
                        collapsedBlocks[i].Contents = DeDuplicateByRegex(block.Contents, _varRegex);
                        continue;
                    case "%Textures":
                        collapsedBlocks[i].Contents = DeDuplicateByRegex(block.Contents, _texSamplerCombinedRegex);
                        continue;
                }
            }

            return collapsedBlocks;
        }

        // Matches _VarNames
        private Regex _propertyRegex = new Regex(@"(?:\[.*\])*\s*(?<identifier>[\w]+)(?:\s?\(\"".*\""\,[\w\s\(\,\.\-\)]+\)\s*=)");
        // Matches floatX halfX and intX variables
        private Regex _varRegex = new Regex(@"(?:uniform)?(?:\s*)(?:half|float|int|real|fixed|bool|float2x2|float3x3|float4x4|half2x2|half3x3|half4x4|fixed2x2|fixed3x3|fixed4x4|real2x2|real3x3|real4x4){1}(?:\d)?\s+(?<identifier>\w+)");
        // Matches either TEXTUREXXX() or SAMPLER()
        private Regex _texSamplerCombinedRegex =
            new Regex(@"(?:SAMPLER)(?:_CMP)?\(([\w]+)\)|(?:RW_)?(?:TEXTURE[23DCUBE]+[_A-Z]*)\(([\w]+)\)");
        // Matches TEXTUREXXX()
        private Regex _texRegex = new Regex(@"(?:RW_)?(?:TEXTURE[23DCUBE]+[_A-Z]*)\((?<identifier>[\w]+)\)");
        // Matches SAMPLER()
        private Regex _samplerRegex = new Regex(@"(?:SAMPLER)(?:_CMP)?\((?<identifier>[\w]+)\)");
        
        private List<string> DeDuplicateByRegex(List<String> source, Regex matcher)
        {
            var keySet = new HashSet<string>();
            var deduped = new List<string>();
            foreach (var item in source)
            {
                if (string.IsNullOrWhiteSpace(item)) continue;
                if (!matcher.IsMatch(item))
                {
                    // #ifdefs are not invalid, so we just paste them as-is silently
                    if (item.Trim().StartsWith("#"))
                    {
                        deduped.Add(item);
                        continue;
                    }
                    // comments are also not invalid, but we skip them
                    if (item.Trim().StartsWith("//"))
                    {
                        continue;
                    }
                    Debug.LogWarning($"Could not find a item in {item}, adding as-is");
                    deduped.Add(item);
                    continue;
                }
                var identifier = matcher.Match(item).Groups.Cast<Group>().Skip(1).ToList().Find(m => !string.IsNullOrEmpty(m.Value)).Value;
                if (keySet.Contains(identifier))
                {
                    if (debugBuild)
                    {
                        Debug.LogWarning("Found duplicate item, skipping: " + identifier);
                    }
                    continue;
                }
                keySet.Add(identifier);
                deduped.Add(item);
            }

            return deduped;
        }
        
        private void InsertContentsAtPosition(ref StringBuilder line, List<ShaderBlock> blocks, int position, int cleanLen)
        {
            line.Remove(position, cleanLen);
            var i = 0;
            foreach (var block in blocks)
            {
                if (i > 0)
                {
                    line.Insert(position, new string(' ', position));
                    line.Insert(position, "\n\n");
                }
                line.Insert(position, IndentContents(block.Contents, position));
                i++;
            }
        }
        
        private void InsertFnCallAtPosition(ref StringBuilder line, List<ShaderBlock> blocks, int position, int cleanLen)
        {
            line.Remove(position, cleanLen);
            var i = 0;
            foreach (var block in blocks)
            {
                if (i > 0)
                {
                    line.Insert(position, new string(' ', position));
                    line.Insert(position, "\n\n");
                }
                line.Insert(position, block.CallSign);
                i++;
            }
        }
        

        private string IndentContents(List<string> contents, int indentLevel)
        {
            var sb = new StringBuilder();
            var i = 0;
            foreach (var contentLine in contents)
            {
                if (i == 0)
                {
                    sb.Append(contentLine + (contents.Count == 1 ? "" : "\n"));
                    i++;
                    continue;
                }

                if (i == contents.Count - 1)
                {
                    sb.Append(new string(' ', indentLevel) + contentLine);
                }
                else
                {
                    sb.Append(new string(' ', indentLevel) + contentLine + '\n');
                }
                i++;
            }

            return sb.ToString();
        }

        /// <summary>
        /// Saves the generated shader source to the path provided
        /// </summary>
        /// <param name="assetPath">Path to the source shader</param>
        /// <param name="outputPath">Save path</param>
        /// <param name="stripSamplingMacros">Strips the sampling macros from the final shader</param>
        public static void GenerateShader(string assetPath, string outputPath, bool stripSamplingMacros = false) {
            var importer = GetAtPath(assetPath) as ShaderDefinitionImporter;
            if (importer == null)
            {
                Debug.LogWarning($"Shader at {assetPath} is not an ORL shader");
                return;
            }

            var textSource = importer.GenerateShader(stripSamplingMacros);
            if (textSource == null)
            {
                return;
            }
            
            File.WriteAllText(outputPath, textSource);
            AssetDatabase.Refresh();
        }
        
        /// <summary>
        /// Gets the generated shader code from the asset
        /// </summary>
        /// <param name="assetPath">Path to .orlshader file</param>
        /// <param name="stripSamplingMacros">Strips the sampling macros from the final shader</param>
        /// <returns></returns>
        public static string GenerateShader(string assetPath, bool stripSamplingMacros = false)
        {
            var importer = GetAtPath(assetPath) as ShaderDefinitionImporter;
            if (importer == null)
            {
                Debug.LogWarning($"Shader at {assetPath} is not an ORL shader");
                return null;
            }

            return importer.GenerateShader(stripSamplingMacros);
        }

        /// <summary>
        /// Gets the generated shader code from the asset
        /// </summary>
        /// <param name="stripSamplingMacros">Strips the sampling macros from the final shader</param>
        /// <returns></returns>
        public string GenerateShader(bool stripSamplingMacros = false)
        {
            var textSource = "";
            var assets = AssetDatabase.LoadAllAssetsAtPath(assetPath);
            foreach (var asset in assets)
            {
                if (asset is TextAsset textAsset)
                {
                    var text = textAsset.text;
                    textSource = text;
                }
            }
            
            if (string.IsNullOrWhiteSpace(textSource))
            {
                Debug.LogWarning($"Shader source for {assetPath} is empty! Generation likely failed");
                return null;
            }
            
            if (stripSamplingMacros)
            {
                var source = textSource.Split(new[] {Environment.NewLine, "\n"}, StringSplitOptions.None);
                var processedSource = new StringBuilder();

                var skippingSampling = false;
                foreach (var line in source)
                {
                    if (line.Contains("// Sampling Library Module Start"))
                    {
                        skippingSampling = true;
                        continue;
                    }

                    if (line.Contains("// Sampling Library Module End"))
                    {
                        skippingSampling = false;
                        continue;
                    }
                    if (skippingSampling) continue;
                    
                    var texMatch = _texRegex.Match(line);
                    if (texMatch.Success)
                    {
                        var newLine = line.Replace(texMatch.Value, $"Texture2D<float4> {texMatch.Groups["identifier"].Value}");
                        processedSource.AppendLine(newLine);
                        continue;
                    }
                    
                    var samplerMatch = _samplerRegex.Match(line);
                    if (samplerMatch.Success)
                    {
                        var newLine = line.Replace(samplerMatch.Value, $"SamplerState {samplerMatch.Groups["identifier"].Value}");
                        processedSource.AppendLine(newLine);
                        continue;
                    }

                    if (line.Contains("SAMPLE_TEXTURE2D"))
                    {
                        var newLine = line.Replace("SAMPLE_TEXTURE2D", "UNITY_SAMPLE_TEX2D_SAMPLER").Replace("sampler_", "_");
                        processedSource.AppendLine(newLine);
                        continue;
                    }
                    
                    if (line.Contains("SAMPLE_TEXTURE2D_LOD"))
                    {
                        var newLine = line.Replace("SAMPLE_TEXTURE2D_LOD", "UNITY_SAMPLE_TEX2D_LOD_SAMPLER").Replace("sampler_", "_");
                        processedSource.AppendLine(newLine);
                        continue;
                    }
                    
                    if (line.Contains("SAMPLE_TEXTURECUBE"))
                    {
                        var newLine = line.Replace("SAMPLE_TEXTURECUBE", "UNITY_SAMPLE_TEXCUBE_SAMPLER").Replace("sampler_", "_");
                        processedSource.AppendLine(newLine);
                        continue;
                    }
                    
                    if (line.Contains("SAMPLE_TEXTURECUBE_LOD"))
                    {
                        var newLine = line.Replace("SAMPLE_TEXTURECUBE_LOD", "UNITY_SAMPLE_TEXCUBE_SAMPLER_LOD").Replace("sampler_", "_");
                        processedSource.AppendLine(newLine);
                        continue;
                    }
                    
                    processedSource.AppendLine(line);
                }

                textSource = processedSource.ToString();
            }

            return textSource;
        }
    }
}