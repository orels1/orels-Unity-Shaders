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

        private HashSet<string> _paramsOnlyBlock = new HashSet<string>
        {
            "%ShaderName",
            "%CustomEditor"
        };

        private List<ShaderBlock> _builtInBlocks;

        private string[] _dataStructs = {
            "@/Structs/VertexData",
            "@/Structs/FragmentData",
            "@/Structs/SurfaceData",
            "@/Structs/MeshData"
        };
        
        private List<ShaderBlock> BuiltInBlocks
        {
            get
            {
                if (_builtInBlocks != null) return _builtInBlocks;
                var blocks = new List<ShaderBlock>();
                foreach (var block in _dataStructs)
                {
                    var parser = new Parser();
                    var sourceStrings = Utils.GetORLSource(block);
                    var blockSource = parser.Parse(sourceStrings);
                    blocks.AddRange(blockSource);
                }
                _builtInBlocks = blocks;
                return _builtInBlocks;
            }
        }
        
        private List<ShaderBlock> _builtInFunctions;
        
        private string[] _functions = {
            "@/Functions/VertexBase",
        };

        private Regex _callSignRegex = new Regex(@"(?:^void\s*)(?<fnName>[\w]+)\((?<params>[\w\,\s]+)\)");
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

        private string[] _libraries = {
            "@/Libraries/Utilities"
        };

        private string _samplingLib = "@/Libraries/SamplingLibrary";
        
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
                    var sourceStrings = Utils.GetORLSource(_samplingLib);
                    var blockSource = parser.Parse(sourceStrings);
                    blocks.AddRange(blockSource);
                }

                _builtInLibraries = blocks;
                return _builtInLibraries;
            }
        }

        private string _defaultLightignModel = "@/LightingModels/PBR";
        
        // Matches %BlockName without nuking %FunctionName()
        private Regex _replacerRegex = new Regex(@"(?<!\/\/\s*)(%[a-zA-Z]+[\w\d]+)(?:$|[""\;\s])");

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
            List<ShaderBlock> blocks;
            string shaderName;
            try
            {
                blocks = parser.Parse(textContent);
                shaderName = blocks[blocks.FindIndex(b => b.Name == "%ShaderName")].Params[0];
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
            catch (Exception)
            {
                ctx.LogImportError($"Failed to parse source shader file {ctx.assetPath}");
                throw;
            }

            // Find and load the lighting model
            var lightingModelIndex = blocks.FindIndex(b => b.Name == "%LightingModel");
            // If we don't have a lighting model, use the default (PBR)
            var lightingModelName = lightingModelIndex == -1 ? _defaultLightignModel : blocks[lightingModelIndex].Params[0].Replace("\"", "");
            var lightingModelPath = Utils.ResolveORLAsset(lightingModelName);
            var lmParser = new Parser();
            var lightingModel = lmParser.Parse(Utils.GetORLSource(lightingModelName));
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
                // We recursively collect everything that the lighting model depends on into a flattened list
                Utils.RecursivelyCollectDependencies(new [] {stripped}.ToList(), ref deepDeps, workingFolder);
                deepDeps.ForEach(dep => ctx.DependsOnSourceAsset(Utils.ResolveORLAsset(dep)));
                var deepBlocks = new List<ShaderBlock>();
                foreach (var deepDep in deepDeps)
                {
                    // since we already have the deps flattened, we can safely strip all the dependencies here
                    deepBlocks.AddRange(blockParser.Parse(Utils.GetORLSource(deepDep)).Where(b => b.Name != "%Includes"));
                }
                updatedBlocks.AddRange(deepBlocks);
            }
            blocks = updatedBlocks;

            // Find and load the template file
            var templateBlockIndex = blocks.FindIndex(b => b.Name == "%Template");
            // if no template is found - use the Lighting Model supplied one
            var templateName = templateBlockIndex == -1 ? lightingModel.Find(b => b.Name == "%Template").Params[0].Replace("\"", "") : blocks[templateBlockIndex].Params[0].Replace("\"", "");
            var templatePath = Utils.ResolveORLAsset(templateName);
            var template = Utils.GetORLTemplate(templateName);
            if (!string.IsNullOrEmpty(templatePath))
            {
                ctx.DependsOnSourceAsset(templatePath);
            }
            
            // Collecting and registering all the dependency objects
            var depList = new List<string>();
            depList.AddRange(_dataStructs);
            depList.AddRange(_functions);
            depList.AddRange(_libraries);
            depList.Add(_samplingLib);
            RegisterDependencies(depList, ctx);
            
            // Adding all the dependencies to the list of blocks
            blocks.AddRange(BuiltInBlocks);
            blocks.AddRange(BuiltInFunctions);
            blocks.AddRange(BuiltInLibraries);

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
            foreach (var s in dependencyPaths)
            {
                var path = Utils.ResolveORLAsset(s);
                if (!string.IsNullOrEmpty(path))
                {
                    ctx.DependsOnSourceAsset(path);
                    continue;
                }
                ctx.LogImportWarning("Failed to resolve dependency: " + s);
            }
        }
        
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
        private Regex _varRegex = new Regex(@"(?:uniform)?(?:\s*)(?:half|float|int|real|fixed){1}(?:\d)?\s+(?<identifier>\w+)");

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
                    Debug.LogWarning("Found duplicate item, skipping: " + identifier);
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
    }
}