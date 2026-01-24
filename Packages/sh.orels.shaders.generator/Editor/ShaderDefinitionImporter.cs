using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using NUnit.Framework;
using UnityEditor;
#if UNITY_2022_3_OR_NEWER
using UnityEditor.AssetImporters;
#else
using UnityEditor.Experimental.AssetImporters;
#endif
using UnityEngine;
using UnityShaderParser.Common;
using UnityShaderParser.HLSL;
using UnityShaderParser.ShaderLab;
using Debug = UnityEngine.Debug;
using BlockType = ORL.ShaderGenerator.ShaderBlock.BlockType;
using ORL.ShaderGenerator.Settings;

namespace ORL.ShaderGenerator
{
    [ScriptedImporter(1, "orlshader")]
    public class ShaderDefinitionImporter : ScriptedImporter
    {
        #region Serialized Fields

        public bool debugBuild;

        private bool DebugBuild => debugBuild || GeneratorProjectSettings.GetSettings().forceDebugBuilds;

        // Cached version of the debug flag to avoid constant asset pinging
        private bool _isDebugBuild;
        
        // cached version of the current importer
        private AssetImportContext _ctx;

        public int samplerCount;
        public int textureCount;
        public int featureCount;

        public Dictionary<FunctionDefinitionNode, string> FunctionErrors =
            new Dictionary<FunctionDefinitionNode, string>();

        public List<ShaderError> Errors = new List<ShaderError>();

        [Serializable]
        public struct ShaderError
        {
            public ShaderBlock Block;
            public int Line;
            public string File;
            public string Message;
            public int StartIndex;
            public int EndIndex;
            public string PrettyCode;

            public ShaderError(ShaderBlock block, int line, string file, string message, string prettyCode = "",
                int startIndex = -1, int endIndex = -1)
            {
                Block = block;
                Line = line;
                File = file;
                Message = message;
                PrettyCode = prettyCode;
                StartIndex = startIndex;
                EndIndex = endIndex;
            }
        }

        public string ShaderName;
        public string LightingModel;
        public List<string> IncludedModules = new List<string>();

        #endregion

        #region Internal Block Config

        private readonly HashSet<string> _paramsOnlyBlock = new HashSet<string>
        {
            "%ShaderName",
            "%CustomEditor",
            "%PassName"
        };

        private List<ShaderBlock> _builtInBlocks;

        private List<ModuleRemap> UserModuleRemaps => GeneratorProjectSettings.GetSettings().userModuleRemaps;

        // Cached version of the user module remaps to avoid constant asset pinging
        private List<ModuleRemap> _userModuleRemaps;

        // Some blocks need to be included in all shaders
        private List<string> AlwaysIncludedBlockSources => GeneratorProjectSettings.GetSettings().alwaysIncludedBlocks;

        private List<ShaderBlock> AlwaysIncludedBlocks
        {
            get
            {
                if (_builtInBlocks != null) return _builtInBlocks;
                var blocks = new List<ShaderBlock>();
                foreach (var block in AlwaysIncludedBlockSources)
                {
                    try
                    {
                        var parser = new Parser();
                        var sourceStrings = Utils.GetORLSource(block, _userModuleRemaps, out var path);
                        var blockSource = parser.Parse(sourceStrings, path);
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

        private string DefaultLightingModel => GeneratorProjectSettings.GetSettings().defaultLightingModel;

        #endregion

        // Matches %BlockName without nuking %FunctionName()
        private readonly Regex _replacerRegex = new Regex(@"(?<!\/\/\s*)(%[a-zA-Z]+[\w\d]+)(?:$|[""\;\s])");

        // Matches %TemplateFeature(<FeatureName>)
        private readonly Regex _templateFeatureRegex = new Regex(@"%TemplateFeature\((?<identifier>""\w+"")\)");

        private struct GeneratedExtraPass
        {
            public List<string> content;
            public int count;
            public ShaderBlock.ExtraPassType passType;
        }

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
            FunctionErrors.Clear();
            Errors.Clear();
            var textContent = File.ReadAllLines(ctx.assetPath);
            var workingFolder =
                ctx.assetPath.Substring(0, ctx.assetPath.LastIndexOf("/", StringComparison.InvariantCulture));

            // Cache debug build
            _isDebugBuild = DebugBuild;
            // Cache remaps
            _userModuleRemaps = UserModuleRemaps;
            // Cache context
            _ctx = ctx;

            var parser = new Parser();
            List<ShaderBlock> blocks = new List<ShaderBlock>();

            // Add and register always inlcuded blocks
            AddAlwaysIncludedBlocks(ctx, ref blocks);

            // Load all the direct blocks from the source
            try
            {
                blocks.AddRange(parser.Parse(textContent, ctx.assetPath));
            }
            catch (Exception ex)
            {
                ctx.LogImportError(ex.ToString());
                ctx.LogImportError($"Failed to process the shader definition file {ctx.assetPath}");
                return;
            }

            if (_isDebugBuild)
            {
                Log($"Added {blocks.Count} direct blocks\n{PrintBlocksListWithPaths(blocks)}");
            }

            IncludedModules.Clear();

            // Get the shader name
            string shaderName;
            try
            {
                shaderName = GetShaderName(blocks);
                ShaderName = shaderName;
            }
            catch (Exception ex)
            {
                ctx.LogImportError(ex.ToString());
                ctx.LogImportError($"Failed to get the shader name from {ctx.assetPath}");
                return;
            }

            if (_isDebugBuild)
            {
                Log($"Target shader name: {shaderName}");
            }

            // Recursively get all the blocks
            try
            {
                blocks = RecursivelyGetDirectDependencies(ctx, workingFolder, blocks);
            }
            catch (Exception ex)
            {
                ctx.LogImportError(ex.ToString());
                ctx.LogImportError($"Failed to process the shader definition file {ctx.assetPath}");
                throw;
            }

            if (_isDebugBuild)
            {
                Log($"Block count after recursive resolve: {blocks.Count} \n{string.Join("\n", blocks.OrderBy(b => b.Path).Select(b => $"[{b.Path}]: {b.Name}"))}");
            }

            // Find and load the lighting model
            List<ShaderBlock> lightingModel;
            var lightingModelName = DefaultLightingModel;
            string lightingModelPath;
            try
            {
                GetLightingModel(ctx, workingFolder, blocks, out lightingModel, out lightingModelName,
                    out lightingModelPath);
            }
            catch (Exception ex)
            {
                ctx.LogImportError(ex.ToString());
                ctx.LogImportError($"Failed to load Lighting Model in {ctx.assetPath}", this);
                throw;
            }

            LightingModel = lightingModelName;

            if (_isDebugBuild)
            {
                Log($"Selected lighting model: {LightingModel}");
            }

            // Recursively get all the lighting model blocks
            try
            {
                blocks = RecursivelyGetLightingModelDependencies(ctx, blocks, lightingModel, lightingModelPath);
            }
            catch (Exception ex)
            {
                ctx.LogImportError(ex.ToString());
                ctx.LogImportError($"Failed to load Lighting Model in {ctx.assetPath}", this);
                throw;
            }
            
            if (_isDebugBuild)
            {
                Log($"Block count after Lighting Model load: {blocks.Count} \n{PrintBlocksListWithPaths(blocks)}");
            }

            // Find and load the template file
            string[] template;
            var templateName = "@/Templates/PBR";
            try
            {
                template = GetTemplate(ctx, blocks, lightingModel, out templateName);
            }
            catch (Exception ex)
            {
                ctx.LogImportError(ex.ToString());
                ctx.LogImportError($"Failed to load Template in {ctx.assetPath}", this);
                throw;
            }

            if (_isDebugBuild)
            {
                Log($"Selected template; {templateName}");
            }

            // Find and toggle template features
            try
            {
                template = ToggleTemplateFeatures(ctx, blocks, template).ToArray();
            }
            catch (Exception ex)
            {
                ctx.LogImportError(ex.ToString());
                ctx.LogImportError($"Failed to toggle Template Features in {ctx.assetPath}", this);
                throw;
            }
            
            // Collapse non-function blocks together and de-dupe things where makes sense
            blocks = OptimizeBlocks(blocks);

            // Load all the extra passes
            var extraPasses = blocks.FindAll(b => b.CoreBlockType == BlockType.ExtraPass);
            var generatedExtraPasses = new List<GeneratedExtraPass>();
            var extraPassBlocks = new Dictionary<string, List<ShaderBlock>>();
            foreach (var extraPass in extraPasses)
            {
                try
                {
                    GetExtraPass(ctx, blocks, templateName, ref generatedExtraPasses, ref extraPassBlocks, extraPass);
                }
                catch (Exception ex)
                {
                    ctx.LogImportError(ex.ToString());
                    ctx.LogImportError($"Failed to process the extra pass {extraPass.Name} in {ctx.assetPath}", this);
                    throw;
                }
            }

            if (_isDebugBuild)
            {
                Log($"Extra passes: Requested - {extraPasses.Count}, Generated - {generatedExtraPasses.Count}");
            }

            // Insert blocks at hook points
            var hookPointBlocks = blocks.FindAll(b => (b.HookPoints?.Count ?? 0) > 0).ToList();
            if (_isDebugBuild)
            {
                Log($"Discovered blocks with hook points: {hookPointBlocks.Count}\n{PrintBlocksListWithPaths(hookPointBlocks)}");
            }
            try
            {
                InjectBlocksIntoHookPoints(blocks, hookPointBlocks);
            }
            catch (Exception ex)
            {
                ctx.LogImportError(ex.ToString());
                ctx.LogImportError($"Failed to inject blocks into hook points in {ctx.assetPath}", this);
                throw;
            }

            // Override shader name to be the one from the source shader
            blocks[blocks.FindIndex(b => b.CoreBlockType == BlockType.ShaderName)].Params[0] = shaderName;

            // save function blocks to a separate list as they need special handling
            var functionBlocks = blocks.Where(b => b.IsFunction).Reverse().ToList();

            if (_isDebugBuild)
            {
                Log($"Discovered function blocks: {functionBlocks.Count}\n{PrintBlocksListWithPaths(functionBlocks)}");
            }

            // Re-hydrate function blocks, we allow nesting of up to 1 level deep
            functionBlocks = functionBlocks.Select(b =>
            {
                var filtered = functionBlocks.Where(i => !i.Equals(b)).ToList();
                b.Contents = HydrateTemplate(new StringBuilder(), b.Contents, filtered, filtered, ctx).ToString()
                    .Split(new[] { Environment.NewLine, "\n" }, StringSplitOptions.None).ToList();
                return b;
            }).ToList();

            if (_isDebugBuild)
            {
                Log(
                    $"Final blocks feeding into generation post-dedupe: {blocks.Count}\n{PrintBlocksListWithPaths(blocks)}");
            }

            // Assemble the final shader with all the source and pre-hydrated blocks
            var finalShader = new StringBuilder();
            finalShader = HydrateTemplate(finalShader, template, blocks, functionBlocks, ctx, generatedExtraPasses);

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

            // Dump shader source as a hidden sub-asset
            var textAsset = new TextAsset(shaderString)
            {
                name = "Shader Source",
                hideFlags = HideFlags.HideInHierarchy
            };

            // Dump errors for basic Vert/Frag parameters
            ValidateBasicFunctions(blocks, ref ctx);

            // This is currently too slow
            // We should do this on the parser step
            // UpdateStats(blocks, ref finalShader, ref ctx);

            ctx.AddObjectToAsset("Shader", shader);
            ctx.SetMainObject(shader);
            ctx.AddObjectToAsset("Shader Source", textAsset);
        }

        private void Log(object message)
        {
            var shaderName = Path.GetFileNameWithoutExtension(_ctx.assetPath);
            Debug.Log($"[ORL][{shaderName}]: {message}");
        }

        private string PrintBlocksListWithPaths(IEnumerable<ShaderBlock> blocks)
        {
            return string.Join("\n", blocks.OrderBy(b => b.Path).Select(b => $"[{b.Path}]: {b.Name}"));
        }

        #region Generator Steps
        
        /// <summary>
        /// Add always included blocks to the `blocks` list and register asset dependencies
        /// </summary>
        /// <param name="ctx"></param>
        /// /// <param name="blocks"></param>
        private void AddAlwaysIncludedBlocks(AssetImportContext ctx, ref List<ShaderBlock> blocks)
        {
            var depList = new List<string>();
            depList.AddRange(AlwaysIncludedBlockSources);
            // Registering asset dependencies, so the shader regenerates with them
            RegisterDependencies(depList, ctx);
            // Adding all the dependencies to the list of blocks
            blocks.AddRange(AlwaysIncludedBlocks);
            if (_isDebugBuild)
            {
                Log($"Added {depList.Count} always included blocks: {string.Join("\n", depList)}");
            }
        }

        
        private static string GetShaderName(List<ShaderBlock> blocks)
        {
            string shaderName;
            var shaderNameBlockIndex = blocks.FindIndex(b => b.CoreBlockType == BlockType.ShaderName);
            if (shaderNameBlockIndex == -1)
            {
                throw new MissingBlockException("%ShaderName", "");
            }

            shaderName = blocks[shaderNameBlockIndex].Params[0];
            if (string.IsNullOrWhiteSpace(shaderName?.Replace("\"", "")))
            {
                throw new MissingParameterException("name", "%ShaderName", "");
            }

            return shaderName;
        }
        
        private List<ShaderBlock> RecursivelyGetDirectDependencies(AssetImportContext ctx, string workingFolder,
            List<ShaderBlock> blocks)
        {
            var includesIndex = blocks.FindIndex(b => b.CoreBlockType == BlockType.Includes);
            // Shaders can have direct includes (not via LightingModel or anything else)
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
                        resolvedBlocks.AddRange(blocks.Where(b => b.CoreBlockType != BlockType.Includes));
                        continue;
                    }

                    var blockParser = new Parser();
                    var deepDeps = new List<string>();

                    // Save direct dependencies
                    IncludedModules.Add(Utils.ResolveORLAsset(stripped, stripped.StartsWith("@/"), _userModuleRemaps,
                        workingFolder));

                    // We recursively collect everything that the shader depends on into a flattened list
                    Utils.RecursivelyCollectDependencies(new[] { stripped }.ToList(), ref deepDeps, workingFolder,
                        _userModuleRemaps);
                    var resolvedDeepDeps = deepDeps.Select(dep =>
                        Utils.ResolveORLAsset(dep, dep.StartsWith("@/"), _userModuleRemaps, workingFolder)).ToList();

                    // Register all the dependencies
                    resolvedDeepDeps.ForEach(ctx.DependsOnSourceAsset);

                    // Load all the blocks
                    var deepBlocks = new List<ShaderBlock>();
                    foreach (var deepDep in deepDeps)
                    {
                        // since we already have the deps flattened, we can safely strip all the dependencies here
                        var deepDepSource = Utils.GetAssetSource(deepDep, workingFolder, _userModuleRemaps,
                            out var deepDepPath);
                        deepBlocks.AddRange(blockParser
                            .Parse(deepDepSource, deepDepPath)
                            .Where(b => b.CoreBlockType != BlockType.Includes));
                    }

                    resolvedBlocks.AddRange(deepBlocks);
                }

                blocks = resolvedBlocks;
            }

            return blocks;
        }

        private void GetLightingModel(AssetImportContext ctx, string workingFolder, List<ShaderBlock> blocks,
            out List<ShaderBlock> lightingModel, out string lightingModelName, out string lightingModelPath)
        {
            var lightingModelIndex = blocks.FindIndex(b => b.CoreBlockType == BlockType.LightingModel);
            // If we don't have a lighting model, use the default (PBR)
            lightingModelName = lightingModelIndex == -1
                ? DefaultLightingModel
                : blocks[lightingModelIndex].Params[0].Replace("\"", "");
            lightingModelPath = Utils.ResolveORLAsset(lightingModelName, lightingModelName.StartsWith("@/"),
                _userModuleRemaps, workingFolder);
            var lmParser = new Parser();
            var lmSource = Utils.GetAssetSource(lightingModelName, workingFolder, _userModuleRemaps, out var lmPath);
            lightingModel = lmParser.Parse(lmSource, lmPath);
            if (!string.IsNullOrEmpty(lightingModelPath))
            {
                ctx.DependsOnSourceAsset(lightingModelPath);
            }
        }

        private List<ShaderBlock> RecursivelyGetLightingModelDependencies(AssetImportContext ctx,
            List<ShaderBlock> blocks, List<ShaderBlock> lightingModel, string lightingModelPath)
        {
            // Lighting model defines some basic functions and dictates where the source shader gets plugged in
            var updatedBlocks = new List<ShaderBlock>();
            foreach (var lmInclude in lightingModel.Find(b => b.CoreBlockType == BlockType.Includes).Contents)
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
                Utils.RecursivelyCollectDependencies(new[] { stripped }.ToList(), ref deepDeps, lmWorkingFolder,
                    _userModuleRemaps);
                var resolvedDeepDeps = deepDeps.Select(dep =>
                    Utils.ResolveORLAsset(dep, dep.StartsWith("@/"), _userModuleRemaps, lmWorkingFolder)).ToList();

                // Register all the dependencies
                resolvedDeepDeps.ForEach(ctx.DependsOnSourceAsset);

                // Load all the blocks
                var deepBlocks = new List<ShaderBlock>();
                foreach (var deepDep in deepDeps)
                {
                    // since we already have the deps flattened, we can safely strip all the dependencies here
                    var deepDepSource = Utils.GetAssetSource(deepDep, lmWorkingFolder, _userModuleRemaps, out var deepDepPath);
                    deepBlocks.AddRange(blockParser
                        .Parse(deepDepSource, deepDepPath)
                        .Where(b => b.CoreBlockType != BlockType.Includes));
                }

                updatedBlocks.AddRange(deepBlocks);
            }

            return updatedBlocks;
        }

        private string[] GetTemplate(AssetImportContext ctx, List<ShaderBlock> blocks, List<ShaderBlock> lightingModel,
            out string templateName)
        {
            var templateBlockIndex = blocks.FindIndex(b => b.CoreBlockType == BlockType.Template);
            // if no template is found - use the Lighting Model supplied one
            if (templateBlockIndex > -1)
            {
                templateName = blocks[templateBlockIndex].Params[0].Replace("\"", "");
            }
            else
            {
                templateBlockIndex = lightingModel.FindIndex(b => b.CoreBlockType == BlockType.Template);
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
            if (!string.IsNullOrEmpty(templatePath))
            {
                ctx.DependsOnSourceAsset(templatePath);
            }

            return Utils.GetORLTemplate(templateName, _userModuleRemaps);
        }

        private List<string> ToggleTemplateFeatures(AssetImportContext ctx, List<ShaderBlock> blocks, string[] template)
        {
            var templateFeatures = new List<string>();
            var templateFeaturesIndex = blocks.FindIndex(b => b.CoreBlockType == BlockType.TemplateFeatures);
            if (templateFeaturesIndex > -1)
            {
                templateFeatures = blocks[templateFeaturesIndex].Params.Select(p => p.Replace("\"", "")).ToList();
            }

            // run through the template and mutate it based on the features
            var newTemplate = new List<string>();
            var enteredFeature = false;
            string currentFeatureName = null;
            var skippingFeature = false;
            var nestLevel = 0;
            for (var index = 0; index < template.Length; index++)
            {
                var trimmedLine = template[index].Trim();
                if (trimmedLine.StartsWith("//", StringComparison.InvariantCulture))
                {
                    newTemplate.Add(template[index]);
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
                        newTemplate.Add(template[index]);
                    }

                    continue;
                }

                // if encountered nested feature - abort
                if (enteredFeature)
                {
                    ctx.LogImportError(
                        $"Found nested Template Features in {ctx.assetPath}. {match.Groups["identifier"].Value} was inside {currentFeatureName}",
                        this);
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

            return newTemplate;
        }

        private void GetExtraPass(AssetImportContext ctx, List<ShaderBlock> blocks, string templateName,
            ref List<GeneratedExtraPass> generatedExtraPasses,
            ref Dictionary<string, List<ShaderBlock>> extraPassBlocks, ShaderBlock extraPass)
        {
            var extraPassName = extraPass.Params[0].Replace("\"", "");
            var extraPassType = extraPass.TypedParams?[1] as ShaderBlock.ExtraPassType? ??
                                ShaderBlock.ExtraPassType.PostPass;
            var extraPassParser = new Parser();
            var extraPassBlocksList = extraPassParser.Parse(extraPass.Contents.ToArray(), extraPass.Path);
            extraPassBlocksList.Add(new ShaderBlock
            {
                Name = "%PassName",
                Params = new List<string>() { $"\"{extraPassName}\"" }
            });

            // don't want to include main pass functions in extra pass blocks with an exception for the base functions
            List<ShaderBlock> combinedList = new List<ShaderBlock>();

            if (extraPass.TypedParams.Count <= 2 || extraPass.TypedParams.Count > 2 && ((extraPass.TypedParams?[2] as ShaderBlock.ExtraPassInheritType?) == ShaderBlock.ExtraPassInheritType.InheritParentBlocks || extraPass.TypedParams?[2] == null))
            {
                combinedList = extraPassBlocksList.Concat(blocks.Where(b =>
                (b.IsFunction && b.Name.EndsWith("Base")) || (!b.IsFunction && !b.Name.StartsWith("%Pass")))).ToList();
            }
            else
            {
                combinedList = extraPassBlocksList;
            }

            extraPassBlocksList = OptimizeBlocks(combinedList);
            extraPassBlocks.Add(extraPassName, extraPassBlocksList);
            var extraPassFunctions = extraPassBlocksList.Where(b => b.IsFunction).ToList();

            var extraPassTemplateName = templateName + "ExtraPass";
            var extraPassTemplatePath = Utils.ResolveORLAsset(extraPassTemplateName, true, _userModuleRemaps);
            var extrapassTemplate = Utils.GetORLTemplate(extraPassTemplateName, _userModuleRemaps);
            if (string.IsNullOrEmpty(extraPassTemplatePath)) return;

            ctx.DependsOnSourceAsset(extraPassTemplatePath);
            // Hydrate loaded template
            var hydratedExtraPass = new StringBuilder();
            var hydratedExtraPassString =
                HydrateTemplate(hydratedExtraPass, extrapassTemplate, combinedList, extraPassFunctions, ctx).ToString();
            generatedExtraPasses.Add(new GeneratedExtraPass
            {
                content = hydratedExtraPassString.Split(new[] { Environment.NewLine, "\n" }, StringSplitOptions.None)
                    .ToList(),
                count = hydratedExtraPassString.Length,
                passType = extraPassType
            });
        }


        private void InjectBlocksIntoHookPoints(List<ShaderBlock> blocks, List<ShaderBlock> hookPointBlocks)
        {
            for (var i = 0; i < hookPointBlocks.Count; i++)
            {
                for (var j = 0; j < hookPointBlocks[i].HookPoints.Count; j++)
                {
                    var blocksToInsert = blocks.FindAll(b =>
                    {
                        var hookPointName = hookPointBlocks[i].HookPoints[j].Name;
                        if (b.Name == "%" + hookPointName) return true;
                        if (b.Name == "%" + hookPointName + "Functions") return true;
                        return false;
                    });
                    // No blocks for this hook point, we can skip it
                    if (blocksToInsert.Count == 0) continue;
                    // these blocks are transient and we dont want to keep them around, unless they're functions
                    blocksToInsert.ForEach(b =>
                    {
                        if (b.IsFunction) return;
                        blocks.Remove(b);
                    });

                    var insertedLines = 0;
                    foreach (var block in blocksToInsert)
                    {
                        if (block.IsFunction)
                        {
                            if (hookPointBlocks[i].HookPoints[j].Name.EndsWith("Functions"))
                            {
                                var fnName = "";
                                fnName = hookPointBlocks[i].HookPoints[j].Name.Replace("Functions", "");

                                var fnBlocks = blocks.FindAll(b => b.IsFunction && b.Name == "%" + fnName);
                                fnBlocks.Reverse();
                                fnBlocks.Sort((a, b) => a.Order.CompareTo(b.Order));
                                fnBlocks.Reverse();
                                foreach (var fnBlock in fnBlocks)
                                {
                                    var toInsert = IndentContentsList(new List<string> { fnBlock.CallSign },
                                        hookPointBlocks[i].HookPoints[j].Indentation);
                                    hookPointBlocks[i].Contents
                                        .InsertRange(hookPointBlocks[i].HookPoints[j].Line, toInsert);
                                    insertedLines += toInsert.Count;
                                }

                                continue;
                            }

                            {
                                var toInsert = IndentContentsList(new List<string> { block.CallSign },
                                    hookPointBlocks[i].HookPoints[j].Indentation);
                                hookPointBlocks[i].Contents
                                    .InsertRange(hookPointBlocks[i].HookPoints[j].Line, toInsert);
                                insertedLines += toInsert.Count;
                            }
                            continue;
                        }

                        {
                            if (_isDebugBuild)
                            {
                                Log($"[HookPoints] Injecting [{block.Path}] {block.Name} at {hookPointBlocks[i].HookPoints[j].Line}, with content:\n{string.Join("\n", block.Contents)}");
                                Log($"[HookPoints] Current {hookPointBlocks[i].Name} contents:\n{string.Join("\n", hookPointBlocks[i].Contents)}");
                            }
                            var toInsert = IndentContentsList(block.Contents,
                                hookPointBlocks[i].HookPoints[j].Indentation);
                            hookPointBlocks[i].Contents.InsertRange(hookPointBlocks[i].HookPoints[j].Line, toInsert);
                            insertedLines += toInsert.Count;
                            if (_isDebugBuild)
                            {
                                Log($"[HookPoints] new block contents for {hookPointBlocks[i].Name} (+{insertedLines}):\n{string.Join("\n", hookPointBlocks[i].Contents)}");
                            }
                            
                            // find and offset every hook point after the current one to account for the offset changes
                            for (var k = j + 1; k < hookPointBlocks[i].HookPoints.Count; k++)
                            {
                                var newHookPoints = new List<ShaderBlock.HookPoint>(hookPointBlocks[i].HookPoints);
                                var adjustedHookPoint = ShaderBlock.HookPoint.Clone(hookPointBlocks[i].HookPoints[k]);
                                adjustedHookPoint.Line += insertedLines - 1;
                                newHookPoints[k] = adjustedHookPoint;
                                hookPointBlocks[i].HookPoints = newHookPoints;
                            }
                        }
                    }

                    hookPointBlocks[i].Contents.RemoveAt(hookPointBlocks[i].HookPoints[j].Line + insertedLines);
                }
            }
        }

        /// <summary>
        /// Hydrates the template with provided shader blocks
        /// Optionally injects extra passes (for use in final shader assembly)
        /// </summary>
        /// <param name="finalShader">Target shader</param>
        /// <param name="template">Template to hydrate</param>
        /// <param name="blocks">Shader blocks to insert into the template</param>
        /// <param name="functionBlocks">Function blocks to insert into the template</param>
        /// <param name="ctx">Asset import context for logging</param>
        /// <param name="generatedExtraPasses">Extra passes list to inject into the template, should only be used for final shader assembly</param>
        /// <returns>final shader after hydration</returns>
        private StringBuilder HydrateTemplate(StringBuilder finalShader, IEnumerable<string> template,
            List<ShaderBlock> blocks, List<ShaderBlock> functionBlocks, AssetImportContext ctx,
            List<GeneratedExtraPass> generatedExtraPasses = null)
        {
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

                    // Here we save all the function source code into the shader %Functions space
                    if (matchVal == "%Functions")
                    {
                        InsertContentsAtPosition(ref newLine, functionBlocks, match.Index, matchLen);
                        continue;
                    }

                    // Here we insert actual function calls if they follow a couple rules
                    // - The function block name is the same as the block name, but without the % prefix
                    // - The functio block has a parameter which matches some HLSL function within the block
                    if (matchVal.Contains("Functions") && matchVal != "%LibraryFunctions" &&
                        matchVal != "%FreeFunctions" && matchVal != "%PassFunctions")
                    {
                        var fnName = "";
                        try
                        {
                            fnName = matchVal.Substring(1).Replace("Functions", "");
                        }
                        catch (Exception e)
                        {
                            ctx.LogImportError(
                                $"Failed to extract function name from {matchVal} in {ctx.assetPath}. {e.Message}");
                            continue;
                        }

                        var fnBlocks = functionBlocks.FindAll(b => b.Name == "%" + fnName);
                        fnBlocks.Reverse();
                        fnBlocks.Sort((a, b) => a.Order.CompareTo(b.Order));
                        fnBlocks.Reverse();
                        InsertFnCallAtPosition(ref newLine, fnBlocks, match.Index, matchLen);
                        continue;
                    }

                    // Checked includes are special and just get inserted into ShaderDefines section
                    if (matchVal == "%ShaderDefines")
                    {
                        var checkedIncludes = blocks.FindAll(b => b.CoreBlockType == BlockType.CheckedInclude);
                        foreach (var checkedInclude in checkedIncludes)
                        {
                            if (File.Exists(checkedInclude.Params[0].Replace("\"", "")))
                            {
                                newLine.AppendLine();
                                newLine.Append(new string(' ', match.Index));
                                newLine.Append("#include ");
                                newLine.AppendLine(checkedInclude.Params[0]);
                            }
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
                        newLine.Insert(match.Index, Utils.IndentContents(block.Contents, match.Index));
                        continue;
                    }

                    if (generatedExtraPasses != null)
                    {
                        // Inject pre-hydrated extra pre-passes
                        if (matchVal == "%ExtraPrePasses")
                        {
                            var insertionIndex = match.Index;
                            newLine.Remove(match.Index, matchLen);

                            var onlyPrePasses =
                                generatedExtraPasses.Where(b => b.passType == ShaderBlock.ExtraPassType.PrePass);

                            foreach (var extraPass in onlyPrePasses)
                            {
                                var indented = IndentContentsList(extraPass.content, insertionIndex);
                                foreach (var indentedLine in indented)
                                {
                                    newLine.AppendLine(indentedLine.Replace(Environment.NewLine, string.Empty));
                                    // insertionIndex += indentedLine.Length;
                                }
                                // newLine.Insert(insertionIndex, indented);
                                // insertionIndex += indented.Count`;
                                // newLine.Insert(insertionIndex, Environment.NewLine);
                                // insertionIndex += Environment.NewLine.Length;
                            }

                            continue;
                        }

                        // Inject pre-hydrated extra passes
                        if (matchVal == "%ExtraPasses")
                        {
                            var insertionIndex = match.Index;
                            newLine.Remove(match.Index, matchLen);

                            var onlyPostPasses =
                                generatedExtraPasses.Where(b => b.passType == ShaderBlock.ExtraPassType.PostPass);

                            foreach (var extraPass in onlyPostPasses)
                            {
                                var indented = IndentContentsList(extraPass.content, insertionIndex);
                                foreach (var indentedLine in indented)
                                {
                                    newLine.AppendLine(indentedLine.Replace(Environment.NewLine, string.Empty));
                                    // insertionIndex += indentedLine.Length;
                                }
                                // var indented = IndentContents(extraPass.content, insertionIndex);
                                // newLine.Insert(insertionIndex, indented);
                                // insertionIndex += indented.Length;
                                // newLine.Insert(insertionIndex, Environment.NewLine);
                                // insertionIndex += Environment.NewLine.Length;
                            }

                            continue;
                        }
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

            return finalShader;
        }

        #endregion

        #region Helpers

        private void RegisterDependencies(List<string> dependencyPaths, AssetImportContext ctx)
        {
            var workingFolder =
                ctx.assetPath.Substring(0, ctx.assetPath.LastIndexOf("/", StringComparison.InvariantCulture));
            foreach (var s in dependencyPaths)
            {
                string path;
                if (s.StartsWith("@/"))
                {
                    path = Utils.ResolveORLAsset(s, true, _userModuleRemaps);
                }
                else
                {
                    path = Utils.ResolveORLAsset(s, false, _userModuleRemaps, workingFolder);
                }

                if (!string.IsNullOrEmpty(path))
                {
                    ctx.DependsOnSourceAsset(path);
                    continue;
                }

                ctx.LogImportWarning("Failed to resolve dependency: " + s);
            }
        }

        private readonly List<BlockType> _sortableBlockTypes = new List<ShaderBlock.BlockType>
        {
            BlockType.DataStructs,
            BlockType.LibraryFunctions,
            BlockType.PassModifiers
        };

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

            var sortedBlocks = new Dictionary<BlockType, List<ShaderBlock>>();
            // Pre-collect blocks of sortable types
            foreach (var block in sourceBlocks)
            {
                if (_sortableBlockTypes.Contains(block.CoreBlockType))
                {
                    if (!sortedBlocks.ContainsKey(block.CoreBlockType))
                    {
                        sortedBlocks.Add(block.CoreBlockType, new List<ShaderBlock>());
                    }

                    sortedBlocks[block.CoreBlockType].Add(block);
                }
            }

            // Sort blocks before collapsing
            foreach (var blockType in sortedBlocks.Keys)
            {
                sortedBlocks[blockType].Sort((a, b) => a.Order.CompareTo(b.Order));
            }

            // Remove from the initial list
            var filteredBlocks = new List<ShaderBlock>(sourceBlocks);
            filteredBlocks.RemoveAll(b => sortedBlocks.ContainsKey(b.CoreBlockType));
            filteredBlocks.AddRange(sortedBlocks.Values.SelectMany(b => b));

            if (_isDebugBuild)
            {
                Log($"[OptimizeBlocks]: Filtered blocks - {filteredBlocks.Count}\n{PrintBlocksListWithPaths(filteredBlocks)}");
            }

            // First pass - collapse blocks with the same name
            foreach (var block in filteredBlocks)
            {
                // We do not merge function blocks because they have unique call signs
                if (block.IsFunction)
                {
                    collapsedBlocks.Add(block);
                    continue;
                }

                // We do not merge extra passes
                if (block.CoreBlockType == BlockType.ExtraPass)
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
                if (_isDebugBuild)
                {
                    Log($"[OptimizeBlocks]: Inserting [{block.Path}] {block.Name}");
                    Log($"[OptimizeBlocks]: Current contents for {collapsedBlocks[index].Name}:\n{string.Join("\n", collapsedBlocks[index].Contents)}");
                }
                collapsedBlocks[index].Contents.Add("");
                if (block.HookPoints != null)
                {
                    if (collapsedBlocks[index].HookPoints == null)
                    {
                        collapsedBlocks[index].HookPoints = new List<ShaderBlock.HookPoint>();
                    }

                    collapsedBlocks[index].HookPoints.AddRange(block.HookPoints.Select(h =>
                    {
                        if (_isDebugBuild)
                        {
                            Log($"[OptimizeBlocks] Inserting hook point {h.Name} ({h.Line} [+{collapsedBlocks[index].Contents.Count}]) from [{block.Path}] {block.Name} into [{collapsedBlocks[index].Path}] {collapsedBlocks[index].Name}");
                        }
                        h.Line += collapsedBlocks[index].Contents.Count;
                        return h;
                    }));
                }

                collapsedBlocks[index].Contents.AddRange(block.Contents);
                if (_isDebugBuild)
                {
                    Log($"[OptimizeBlocks]: new block contents for {collapsedBlocks[index].Name}:\n{string.Join("\n", collapsedBlocks[index].Contents)}");
                }
            }

            // Second pass - deduplicate things where it makes sense
            for (var i = 0; i < collapsedBlocks.Count; i++)
            {
                var block = collapsedBlocks[i];
                switch (block.CoreBlockType)
                {
                    case BlockType.ShaderTags:
                        block.Contents = DeDuplicateByParser(block.Contents, DeDupeType.Tags);
                        continue;
                    case BlockType.Properties:
                        collapsedBlocks[i].Contents = DeDuplicateByParser(block.Contents, DeDupeType.Properties);
                        continue;
                    case BlockType.ShaderModifiers:
                    case BlockType.PassModifiers:
                        collapsedBlocks[i].Contents = DeDuplicateByParser(block.Contents, DeDupeType.Modifiers);
                        continue;
                    case BlockType.Variables:
                        collapsedBlocks[i].Contents = DeDuplicateByRegex(block.Contents, _varRegex);
                        continue;
                    case BlockType.Textures:
                        collapsedBlocks[i].Contents = DeDuplicateByRegex(block.Contents, _texSamplerCombinedRegex);
                        continue;
                }
            }

            return collapsedBlocks;
        }

        // Matches floatX halfX and intX variables
        private Regex _varRegex =
            new Regex(
                @"(?:uniform)?(?:\s*)(?:half|float|int|real|fixed|bool|float2x2|float3x3|float4x4|half2x2|half3x3|half4x4|fixed2x2|fixed3x3|fixed4x4|real2x2|real3x3|real4x4){1}(?:\d)?\s+(?<identifier>\w+)");

        // Matches either TEXTUREXXX() or SAMPLER()
        private Regex _texSamplerCombinedRegex =
            new Regex(@"(?:SAMPLER)(?:_CMP)?\(([\w]+)\)|(?:RW_)?(?:TEXTURE[23DCUBE]+[_A-Z]*)\(([\w]+)\)");

        // Matches TEXTUREXXX()
        private Regex _texRegex = new Regex(@"(?:RW_)?(?:TEXTURE[23DCUBE]+[_A-Z]*)\((?<identifier>[\w]+)\)");

        // Matches SAMPLER()
        private Regex _samplerRegex = new Regex(@"(?:SAMPLER)(?:_CMP)?\((?<identifier>[\w]+)\)");
        
        // Matches TEXTURE2D_PARAM()
        private Regex _texParamRegex = new Regex(@"TEXTURE2D_PARAM\((?<identifier>[\w]+),\s*(?<sampler>[\w]+)\)");
        
        // Matches TEXTURE2D_ARGS()
        private Regex _texArgsRegex = new Regex(@"TEXTURE2D_ARGS\((?<identifier>[\w]+),\s?(?<sampler>[\w]+)\)");

        private enum DeDupeType
        {
            Properties,
            Tags,
            Modifiers,
        }

        private List<string> DeDuplicateByParser(List<string> source, DeDupeType type)
        {
            var keySet = new HashSet<string>();
            var deduped = new List<string>();
            var combined = string.Join(Environment.NewLine, source);
            switch (type)
            {
                case DeDupeType.Properties:
                    {
                        var tokens = ShaderLabLexer.Lex(combined, null, null, false, out _);
                        var nodes = ShaderLabParser.ParseShaderProperties(tokens, ShaderAnalyzers.SLConfig, out _);
                        foreach (var node in nodes)
                        {
                            if (keySet.Contains(node.Uniform))
                            {
                                if (_isDebugBuild)
                                {
                                    Debug.LogWarning("Found duplicate item, skipping: " + node.Uniform);
                                }

                                continue;
                            }

                            keySet.Add(node.Uniform);
                            deduped.Add(node.GetCodeInSourceText(combined));
                        }

                        break;
                    }
                case DeDupeType.Tags:
                    {
                        var dedupedTags = new Dictionary<string, string>();
                        var dedupedTagsString = new StringBuilder();
                        combined = $"Tags {{{combined}}}";
                        var tokens = ShaderLabLexer.Lex(combined, null, null, false, out _);
                        var nodes = ShaderLabParser.ParseShaderLabCommands(tokens, ShaderAnalyzers.SLConfig, out _);
                        foreach (var node in nodes)
                        {
                            if (node is ShaderLabCommandTagsNode tags)
                            {
                                foreach (var tag in tags.Tags)
                                {
                                    var tagKey = tag.Key;
                                    var tagValue = tag.Value;
                                    if (keySet.Contains(tagKey))
                                    {
                                        if (_isDebugBuild)
                                        {
                                            Debug.LogWarning("Found duplicate tag, updating: " + tagKey + " to " +
                                                             tagValue);
                                        }

                                        dedupedTags[tagKey] = tagValue;
                                        continue;
                                    }

                                    keySet.Add(tagKey);
                                    dedupedTags.Add(tagKey, tagValue);
                                }
                            }
                        }

                        foreach (var dedupedTag in dedupedTags)
                        {
                            dedupedTagsString.Append($"\"{dedupedTag.Key}\" = \"{dedupedTag.Value}\" ");
                        }

                        deduped.Add(dedupedTagsString.ToString());
                        break;
                    }
                case DeDupeType.Modifiers:
                    {
                        var tokens = ShaderLabLexer.Lex(combined, null, null, false, out _);
                        var nodes = ShaderLabParser.ParseShaderLabCommands(tokens, ShaderAnalyzers.SLConfig, out _);
                        var dedupedModifiers = new Dictionary<Type, ShaderLabCommandNode>();
                        foreach (var node in nodes)
                        {
                            if (dedupedModifiers.ContainsKey(node.GetType()))
                            {
                                if (_isDebugBuild)
                                {
                                    Debug.LogWarning(
                                        $"Found duplicate shader/pass modifier, skipping: {node.GetCodeInSourceText(combined)}");
                                }

                                continue;
                            }

                            dedupedModifiers.Add(node.GetType(), node);
                        }

                        foreach (var dedupedModifier in dedupedModifiers)
                        {
                            deduped.Add(dedupedModifier.Value.GetCodeInSourceText(combined));
                        }

                        break;
                    }
            }

            return deduped;
        }

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

                    // cbuffers are not invalid, so we just paste them as-is silently
                    if (item.Trim().StartsWith("cbuffer"))
                    {
                        deduped.Add(item);
                        continue;
                    }

                    // Also pass through braces (needed for cbuffers)
                    if (item.Trim().StartsWith("{") || item.Trim().StartsWith("}"))
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

                var identifier = matcher.Match(item).Groups.Cast<Group>().Skip(1).ToList()
                    .Find(m => !string.IsNullOrEmpty(m.Value)).Value;
                if (keySet.Contains(identifier))
                {
                    if (_isDebugBuild)
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

        private void InsertContentsAtPosition(ref StringBuilder line, List<ShaderBlock> blocks, int position,
            int cleanLen)
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

                line.Insert(position, Utils.IndentContents(block.Contents, position));
                i++;
            }
        }

        private void InsertFnCallAtPosition(ref StringBuilder line, List<ShaderBlock> blocks, int position,
            int cleanLen)
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

        private List<string> IndentContentsList(List<string> contents, int indentLevel)
        {
            var result = new List<string>(contents.Count);
            foreach (var contentLine in contents)
            {
                // Replace both types of newlines for safety
                var trimmedLine = contentLine.Replace("\r\n", string.Empty);
                trimmedLine = trimmedLine.Replace("\n", string.Empty);
                result.Add(new string(' ', indentLevel) + trimmedLine);
            }

            return result;
        }

        #endregion

        #region Parser-Based Stats and Validation

        private class StatsUpdater : HLSLSyntaxVisitor
        {
            public struct FunctionParamerror
            {
                public string Name;
                public string Type;
                public int StartIndex;
                public int EndIndex;
                public int Line;
            }

            public Dictionary<FunctionParamerror, string> Errors = new Dictionary<FunctionParamerror, string>();

            public override void VisitFunctionDefinitionNode(FunctionDefinitionNode node)
            {
                var allowedParams = new List<string> { "v", "d", "o", "FinalColor" };
                foreach (var parameter in node.Parameters)
                {
                    if (!allowedParams.Contains(parameter.Declarator.Name))
                    {
                        var paramType = "";
                        switch (parameter.ParamType)
                        {
                            case ScalarTypeNode s:
                                paramType = PrintingUtil.GetEnumName(s.Kind);
                                break;
                            case VectorTypeNode v:
                                paramType = PrintingUtil.GetEnumName(v.Kind) + v.Dimension;
                                break;
                        }

                        Errors.Add(new FunctionParamerror
                        {
                            Line = parameter.Span.Start.Line,
                            StartIndex = parameter.Span.Start.Index,
                            EndIndex = parameter.Span.End.Index,
                            Name = parameter.Declarator.Name,
                            Type = paramType,
                        },
                            $"Invalid {paramType} parameter {parameter.Declarator.Name} in function {node.Name.GetName()}, only {string.Join(", ", allowedParams)} are supported");
                        // if (!Errors.ContainsKey(node))
                        // {
                        // }
                        // Debug.LogError($"Invalid {paramType} parameter {parameter.Declarator.Name} in function {node.Name.GetName()}, only {string.Join(", ", allowedParams)} are supported");
                    }
                }
                // Debug.Log($"Function declaration {node.Name.GetName()}");
            }
        }

        private void ValidateBasicFunctions(List<ShaderBlock> blocks, ref AssetImportContext ctx)
        {
            try
            {
                var vertBlock = blocks.Find(b => b.Name == "%Vertex");
                ShaderBlockValidations.ValidateVertexFunction(vertBlock, ref ctx, this);
                var fragBlock = blocks.Find(b => b.Name == "%Fragment");
                ShaderBlockValidations.ValidateFragmentFunction(fragBlock, ref ctx, this);
            }
            catch (Exception e)
            {
                Debug.LogException(e);
            }
        }

        private void UpdateStats(List<ShaderBlock> blocks, ref StringBuilder shaderContent, ref AssetImportContext ctx)
        {
            try
            {
                Undo.RecordObject(this, "Update Stats");
                textureCount = ShaderAnalyzers.CountTextureObjects(blocks, ref ctx, this);
                samplerCount = ShaderAnalyzers.CountSamplers(blocks, ref ctx, this);
                featureCount = ShaderAnalyzers.CountShaderFeatures(shaderContent.ToString());
            }
            catch (Exception e)
            {
                Debug.LogException(e);
            }
        }

        #endregion

        #region Public API

        /// <summary>
        /// Saves the generated shader source to the path provided
        /// </summary>
        /// <param name="assetPath">Path to the source shader</param>
        /// <param name="outputPath">Save path</param>
        /// <param name="stripSamplingMacros">Strips the sampling macros from the final shader</param>
        public static void GenerateShader(string assetPath, string outputPath, bool stripSamplingMacros = false)
        {
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
                var source = textSource.Split(new[] { Environment.NewLine, "\n" }, StringSplitOptions.None);
                var processedSource = new StringBuilder();

                var skippingSampling = false;
                foreach (var line in source)
                {
                    if (line.Contains("// Sampling Library Module Start")
                        || line.Contains("// BiRP to URP Sampling Macros Start"))
                    {
                        skippingSampling = true;
                        continue;
                    }

                    if (line.Contains("// Sampling Library Module End")
                        || line.Contains("// BiRP to URP Sampling Macros End"))
                    {
                        skippingSampling = false;
                        continue;
                    }

                    if (skippingSampling) continue;

                    var texMatch = _texRegex.Match(line);
                    if (texMatch.Success)
                    {
                        var newLine = line.Replace(texMatch.Value,
                            $"Texture2D<float4> {texMatch.Groups["identifier"].Value}");
                        processedSource.AppendLine(newLine);
                        continue;
                    }

                    var samplerMatch = _samplerRegex.Match(line);
                    if (samplerMatch.Success)
                    {
                        var newLine = line.Replace(samplerMatch.Value,
                            $"SamplerState {samplerMatch.Groups["identifier"].Value}");
                        processedSource.AppendLine(newLine);
                        continue;
                    }

                    var paramsMatch = _texParamRegex.Match(line);
                    if (paramsMatch.Success)
                    {
                        var newLine = line.Replace(paramsMatch.Value,
                            $"Texture2D<float4> {paramsMatch.Groups["identifier"].Value}, SamplerState {paramsMatch.Groups["sampler"].Value}");
                        processedSource.AppendLine(newLine);
                        continue;
                    }
                    
                    var argsMatch = _texArgsRegex.Match(line);
                    if (argsMatch.Success)
                    {
                        var newLine = line.Replace(argsMatch.Value,
                            $"{argsMatch.Groups["identifier"].Value}, {argsMatch.Groups["sampler"].Value}");
                        processedSource.AppendLine(newLine);
                        continue;
                    }

                    if (line.Contains("SAMPLE_TEXTURE2D_GRAD("))
                    {
                        // search and parse parameters to rewrite into a `tex.SampleGrad` call
                        var substring = line.Substring(line.IndexOf("SAMPLE_TEXTURE2D_GRAD") + 21);
                        substring = substring.Substring(substring.IndexOf("(") + 1);
                        var levelsIn = 1;
                        var iterations = 0;
                        while (true)
                        {
                            if (substring[iterations] == '(') levelsIn++;
                            if (substring[iterations] == ')') levelsIn--;
                            if (levelsIn == 0) break;
                            iterations++;
                            if (iterations > 10000) break;
                        }

                        if (iterations > 10000)
                        {
                            Debug.LogWarning("Could find the end of macro in 10000 iterations\n" +
                                             $"Line was {substring}");
                            continue;
                        }

                        var parametersString = substring.Substring(0, iterations);
                        var parameterList = Regex.Split(parametersString, @",(?=(?:[^()]*\([^()]*\))*[^()]*$)");
                        var newLine = line.Replace($"SAMPLE_TEXTURE2D_GRAD({parametersString})",
                            $"{parameterList[0].Trim()}.SampleGrad({parameterList[1].Trim()}, {parameterList[2].Trim()}, {parameterList[3].Trim()}, {parameterList[4].Trim()})");
                        processedSource.AppendLine(newLine);
                        continue;
                    }
                    
                    if (line.Contains("SAMPLE_TEXTURE2D_LOD"))
                    {
                        var newLine = line.Replace("SAMPLE_TEXTURE2D_LOD", "UNITY_SAMPLE_TEX2D_SAMPLER_LOD").Replace("sampler", "");
                        processedSource.AppendLine(newLine);
                        continue;
                    }
                    
                    // Special Handling for ScreenSpace textures
                    if (line.Contains("SAMPLE_TEXTURE2D_X"))
                    {
                        var newLine = line.Replace("SAMPLE_TEXTURE2D_X", "UNITY_SAMPLE_TEX2D_SAMPLER").Replace("sampler", "");
                        processedSource.AppendLine(newLine);
                        continue;
                    }

                    if (line.Contains("SAMPLE_TEXTURE2D"))
                    {
                        var newLine = line.Replace("SAMPLE_TEXTURE2D", "UNITY_SAMPLE_TEX2D_SAMPLER").Replace("sampler", "");
                        processedSource.AppendLine(newLine);
                        continue;
                    }

                    if (line.Contains("SAMPLE_TEXTURECUBE_LOD"))
                    {
                        var newLine = line.Replace("SAMPLE_TEXTURECUBE_LOD", "UNITY_SAMPLE_TEXCUBE_SAMPLER_LOD").Replace("sampler", "");
                        processedSource.AppendLine(newLine);
                        continue;
                    }

                    if (line.Contains("SAMPLE_TEXTURECUBE"))
                    {
                        var newLine = line.Replace("SAMPLE_TEXTURECUBE", "UNITY_SAMPLE_TEXCUBE_SAMPLER").Replace("sampler", "");
                        processedSource.AppendLine(newLine);
                        continue;
                    }

                    processedSource.AppendLine(line);
                }

                textSource = processedSource.ToString();
            }

            return textSource;
        }
        
        #endregion
    }

}

