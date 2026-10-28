using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;
#if ORL_SHADER_GENERATOR
using ORL.ShaderGenerator.Settings;
using UnityShaderParser.Common;
#endif

namespace ORL.ShaderInspector
{
    /// <summary>
    /// Session-scoped cache for the localization system
    ///
    /// Localization assets (<see cref="LocalizationData"/>, imported from .orlloc files) are indexed by GUID,
    /// and matched to shader modules by name - a Snow.orlloc file provides localization for the Snow module
    ///
    /// When building a lookup table for a given shader, every localization asset is first merged into a flat pool
    /// (in a path-based order), and then the data of every module included into that shader is
    /// overlaid on top - making module-local files take priority over the shared pool
    ///
    /// The cache is rebuilt automatically whenever any relevant asset is imported
    /// </summary>
    public static class LocalizationCache
    {
        private const string PackageCacheFolder = "Library/PackageCache";

        private class CacheState
        {
            // every loaded localization asset, in a path-based order
            public readonly List<LocalizationData> OrderedAssets = new List<LocalizationData>();
            // guid -> asset, used for the module overlays
            public readonly Dictionary<string, LocalizationData> AssetsByGuid = new Dictionary<string, LocalizationData>();
            // module name -> guid of its localization file
            public readonly Dictionary<string, string> ModuleToGuid = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
            // every known module name, in the same order as OrderedAssets
            public readonly List<string> OrderedModules = new List<string>();
            // module name -> path of its source file (.orlsource / .orlshader)
            public readonly Dictionary<string, string> ModuleToSourcePath = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
            // module name -> (property name -> display name) pairs of its source file
            public readonly Dictionary<string, List<KeyValuePair<string, string>>> ModuleProps = new Dictionary<string, List<KeyValuePair<string, string>>>();
            // shader asset path -> ordered list of modules it includes
            public readonly Dictionary<string, List<string>> ShaderModules = new Dictionary<string, List<string>>();
        }

        private static CacheState _state;
        private static bool _dirty = true;
#if ORL_SHADER_GENERATOR
        // source files parsed with the generator's parser, shared between the include walker and the property extractor
        private static readonly Dictionary<string, List<ORL.ShaderGenerator.ShaderBlock>> _parsedSources =
            new Dictionary<string, List<ORL.ShaderGenerator.ShaderBlock>>();
#endif

        /// <summary>
        /// Marks the cache as stale, it will be rebuilt on the next access
        /// </summary>
        public static void Invalidate()
        {
            _dirty = true;
#if ORL_SHADER_GENERATOR
            _parsedSources.Clear();
#endif
        }

        private static CacheState State
        {
            get
            {
                if (_state != null && !_dirty) return _state;
                _state = BuildState();
                _dirty = false;
                return _state;
            }
        }

        private static string ProjectRoot
        {
            get
            {
                var dataPath = Application.dataPath.Replace('\\', '/');
                return dataPath.EndsWith("/Assets", StringComparison.Ordinal)
                    ? dataPath.Substring(0, dataPath.Length - "/Assets".Length)
                    : dataPath;
            }
        }

        private static CacheState BuildState()
        {
            Debug.Log("[ORL][Localization][Cache] Building Cache");
            var state = new CacheState();
            var entries = new List<(string Guid, string Path, LocalizationData Asset)>();

            foreach (var guid in AssetDatabase.FindAssets("t:LocalizationData"))
            {
                var path = AssetDatabase.GUIDToAssetPath(guid);
                if (string.IsNullOrEmpty(path)) continue;

                var asset = AssetDatabase.LoadAssetAtPath<LocalizationData>(path);
                if (asset == null) continue;

                entries.Add((guid, path, asset));
            }

            foreach (var entry in entries.OrderBy(e => e.Path, StringComparer.InvariantCultureIgnoreCase))
            {
                state.OrderedAssets.Add(entry.Asset);
                state.AssetsByGuid[entry.Guid] = entry.Asset;

                var module = !string.IsNullOrWhiteSpace(entry.Asset.moduleName)
                    ? entry.Asset.moduleName
                    : Path.GetFileNameWithoutExtension(entry.Path);

                if (!state.ModuleToGuid.ContainsKey(module))
                {
                    state.ModuleToGuid.Add(module, entry.Guid);
                    state.OrderedModules.Add(module);
                    state.ModuleToSourcePath[module] = FindModuleShader(module, entry.Path);
                }
            }
            return state;
        }

        /// <summary>
        /// Builds the localization lookup table for a given shader
        /// Merges every localization asset into a flat pool, then overlays the data
        /// of every module included into the shader (in include order, later wins)
        /// </summary>
        /// Mostly called by the InspectorGUI stuff when loading up a material
        public static Dictionary<string, LocalizationData.LocalizedPropData> GetShaderLocalization(Shader shader)
        {
            var state = State;
            var result = new Dictionary<string, LocalizationData.LocalizedPropData>();
            // flat pool
            foreach (var asset in state.OrderedAssets)
            {
                for (var i = 0; i < asset.properties.Count; i++)
                {
                    if (!result.ContainsKey(asset.properties[i]))
                    {
                        result.Add(asset.properties[i], asset.data[i]);
                    }
                }
            }
            var shaderPath = shader == null ? null : AssetDatabase.GetAssetPath(shader);
            if (string.IsNullOrWhiteSpace(shaderPath)) return result;

            // module overlays, module-local files win over the shared pool
            foreach (var module in GetShaderModules(shaderPath))
            {
                var guid = FindLocalizationGuid(state, module);
                if (guid == null) continue;

                if (!state.AssetsByGuid.TryGetValue(guid, out var asset)) continue;

                for (var i = 0; i < asset.properties.Count; i++)
                {
                    result[asset.properties[i]] = asset.data[i];
                }
            }
            return result;
        }

        /// <summary>
        /// Finds the localization asset bound to a given shader module
        /// Binds by the module path (e.g. `Modules/Toon/Main`) first,
        /// falling back to the module file name (e.g. `Main`) for the flat naming convention
        /// </summary>
        /// This is mostly needed to disambiguate between Main.orlloc in Toon and Main.orlloc in Toon/v2
        private static string FindLocalizationGuid(CacheState state, string module)
        {
            if (string.IsNullOrWhiteSpace(module)) return null;
            if (state.ModuleToGuid.TryGetValue(module, out var guid)) return guid;
            var fileName = Path.GetFileName(module);
            return state.ModuleToGuid.TryGetValue(fileName, out var fileGuid) ? fileGuid : null;
        }

        /// <summary>
        /// Returns the names of all modules that have localization data, in a deterministic order
        /// </summary>
        /// Only used by the docs exporter, as it clones on get
        public static List<string> GetAllModules()
        {
            return new List<string>(State.OrderedModules);
        }

        /// <summary>
        /// Returns the localization asset bound to a given module name, if any
        /// </summary>
        public static LocalizationData GetModuleLocalization(string module)
        {
            var state = State;
            return state.ModuleToGuid.TryGetValue(module, out var guid) && state.AssetsByGuid.TryGetValue(guid, out var asset)
                ? asset
                : null;
        }

        #region LocalizationDocsExporter helpers

        // These are mostly used by the documentation exporter, so it needs to grab the list of props

        /// <summary>
        /// Returns the (property name -> display name) pairs defined in the source file of a given module
        /// </summary>
        public static List<KeyValuePair<string, string>> GetModuleProperties(string module)
        {
            var state = State;
            if (state.ModuleProps.TryGetValue(module, out var cached)) return cached;
            var result = GetAssetProperties(GetModuleSourcePath(module));
            state.ModuleProps[module] = result;
            return result;
        }

        /// <summary>
        /// Returns the (property name -> display name) pairs defined in the given asset
        /// </summary>
        public static List<KeyValuePair<string, string>> GetAssetProperties(string assetPath)
        {
#if ORL_SHADER_GENERATOR
            if (!string.IsNullOrWhiteSpace(assetPath))
            {
                var fullPath = ToFullPath(assetPath);
                if (fullPath != null && File.Exists(fullPath))
                {
                    return ParseProperties(fullPath);
                }
            }
#endif
            // without the generator there are no orl sources to extract properties from
            return new List<KeyValuePair<string, string>>();
        }

        private static string FindModuleShader(string locModuleName, string path)
        {
            // if there is a direct module specifier, user ORL module resolution
            if (locModuleName.Contains("/"))
            {
                var resolveAssetPath = ResolveAssetPath("@/" + locModuleName, null);
                return resolveAssetPath != null ? ToUnityPath(resolveAssetPath) : null;
            }
            
            // check same folder first
            var orlShaderPath = path.Replace(".orlloc", ".orlshader");
            if (File.Exists(orlShaderPath))
            {
                return orlShaderPath;
            }

            var orlSourcePath = path.Replace(".orlloc", ".orlsource");
            if (File.Exists(orlSourcePath))
            {
                return orlSourcePath;
            }
            
            var orlConfShaderPath =  path.Replace(".orlloc", ".orlconfshader"); 
            if (File.Exists(orlConfShaderPath))
            {
                return orlConfShaderPath;
            }
            
            // Now check the folder hierarchy for a Localization folder
            var lastIndex = path.LastIndexOf("Localization");
            // we haven't found anything
            if (lastIndex == -1) return null;
            var root = path.Substring(0, lastIndex);

            var remainderPath =  path.Substring(lastIndex + 13);
            var remainderWithoutFilename = remainderPath.Replace(Path.GetFileName(remainderPath), "");
            var combinedPath = root + remainderWithoutFilename + locModuleName;
            
            
            orlShaderPath = combinedPath + ".orlshader";
            if (File.Exists(orlShaderPath))
            {
                return orlShaderPath;
            }

            orlSourcePath = combinedPath + ".orlsource";
            if (File.Exists(orlSourcePath))
            {
                return orlSourcePath;
            }
            
            orlConfShaderPath =  combinedPath + ".orlconfshader";
            if (File.Exists(orlConfShaderPath))
            {
                return orlConfShaderPath;
            }

            return null;
        }

        /// <summary>
        /// Returns the path of the source file (.orlsource / .orlshader) of a given module, if any
        /// </summary>
        public static string GetModuleSourcePath(string module)
        {
            var state = State;
            if (state.ModuleToSourcePath.TryGetValue(module, out var cached)) return cached;
            var path = FindModuleSource(module);
            state.ModuleToSourcePath[module] = path;
            return path;
        }

        private static string FindModuleSource(string module)
        {
#if ORL_SHADER_GENERATOR
            // the module identity is the path relative to the generator sources, e.g. `Modules/Toon/Main`
            // flat names (e.g. `Snow`) are looked up under Modules/ as well, matching the flat naming convention
            if (string.IsNullOrWhiteSpace(module)) return null;
            // resolve in modules first (most things are there)
            foreach (var candidate in new[] { "@/" + module, "@/Modules/" + module })
            {
                var full = ResolveAssetPath(candidate, null);
                if (full == null) continue;
                return ToUnityPath(full);
            }
            return null;
#else
            // without the generator there are no orl source assets to resolve
            return null;
#endif
        }

#if ORL_SHADER_GENERATOR

        /// <summary>
        /// Parses a source file into blocks with the generator's own parser, caching the result
        /// </summary>
        private static List<ORL.ShaderGenerator.ShaderBlock> GetParsedBlocks(string fullPath)
        {
            if (_parsedSources.TryGetValue(fullPath, out var cached)) return cached;
            var blocks = new List<ORL.ShaderGenerator.ShaderBlock>();
            try
            {
                blocks = new ORL.ShaderGenerator.Parser().Parse(ReadAllLinesOrDefault(fullPath), fullPath);
            }
            catch (Exception ex)
            {
                Debug.LogWarning($"[ORL] Failed to parse the source file '{fullPath}': {ex.Message}");
            }
            _parsedSources[fullPath] = blocks;
            return blocks;
        }

        /// <summary>
        /// Extracts the (property name -> display name) pairs of the %Properties() block of an ORL source file
        /// </summary>
        private static List<KeyValuePair<string, string>> ParseProperties(string fullPath)
        {
            var result = new List<KeyValuePair<string, string>>();
            var block = GetParsedBlocks(fullPath).Find(b => b.CoreBlockType == ORL.ShaderGenerator.ShaderBlock.BlockType.Properties);
            if (block == null) return result;
            // grab all the props using UnityShaderParser to stay consistent with the generator
            var nodes = ShaderParser.ParseUnityShaderProperties(string.Join(Environment.NewLine, block.Contents));
            foreach (var node in nodes)
            {
                var display = Utils.StripInternalSymbols(node.Name);
                display = display.Replace("#", "").Trim();
                result.Add(new KeyValuePair<string, string>(node.Uniform, display));
            }
            return result;
        }

#endif

        private static string[] ReadAllLinesOrDefault(string fullPath)
        {
            try
            {
                return File.Exists(fullPath) ? File.ReadAllLines(fullPath) : new string[0];
            }
            catch
            {
                return new string[0];
            }
        }

        /// <summary>
        /// Converts a unity-relative asset path into a full os path,
        /// falling back to the package cache for non-embedded packages
        /// </summary>
        private static string ToFullPath(string unityPath)
        {
            if (string.IsNullOrWhiteSpace(unityPath)) return null;
            var path = unityPath.Replace('\\', '/');
            if (Path.IsPathRooted(path)) return path;
            var direct = ProjectRoot + "/" + path;
            if (File.Exists(direct)) return direct;
            if (path.StartsWith("Packages/", StringComparison.Ordinal))
            {
                var rest = path.Substring("Packages/".Length);
                var slash = rest.IndexOf('/');
                if (slash > 0)
                {
                    var packageName = rest.Substring(0, slash);
                    var subPath = rest.Substring(slash + 1);
                    var cacheRoot = ProjectRoot + "/" + PackageCacheFolder;
                    if (Directory.Exists(cacheRoot))
                    {
                        foreach (var dir in Directory.GetDirectories(cacheRoot, "*@" + packageName))
                        {
                            var candidate = dir.Replace('\\', '/') + "/" + subPath;
                            if (File.Exists(candidate)) return candidate;
                        }
                    }
                }
            }
            return direct;
        }

        #endregion

        #region Shader module resolution

#if ORL_SHADER_GENERATOR

        // Walking `%Includes()` blocks requires the generator to be present,
        // as that is what imports the orl source assets in the first place.
        // Include resolution reuses the generator's own Utils, so `@/` shorthands
        // and user module remaps resolve exactly like they do at import time.

        private static readonly Regex IncludeRegex = new Regex(@"""([^""]+)""", RegexOptions.Compiled);

        /// <summary>
        /// Recursively collects the names of all modules included into a given shader,
        /// in include order. Dependencies come first, so the including module wins on conflicts
        /// </summary>
        public static List<string> GetShaderModules(string shaderAssetPath)
        {
            var state = State;
            if (string.IsNullOrWhiteSpace(shaderAssetPath)) return new List<string>();
            if (state.ShaderModules.TryGetValue(shaderAssetPath, out var cached)) return cached;
            var modules = new List<string>();


            CollectModules(shaderAssetPath, null, modules, new HashSet<string>(StringComparer.OrdinalIgnoreCase));
            state.ShaderModules.Add(shaderAssetPath, modules);
            return modules;
        }

        private static void CollectModules(string includePath, string baseDir, List<string> modules, HashSet<string> visited)
        {
            var fullPath = ResolveAssetPath(includePath, baseDir);
            if (fullPath == null || visited.Contains(fullPath)) return;
            visited.Add(fullPath);
            var dir = Path.GetDirectoryName(fullPath)?.Replace('\\', '/');
            foreach (var include in GetIncludes(fullPath))
            {
                var value = include.Trim();
                // `self` is the file itself, `target` is the shader being built - both are added implicitly
                if (string.Equals(value, "self", StringComparison.OrdinalIgnoreCase)) continue;
                if (string.Equals(value, "target", StringComparison.OrdinalIgnoreCase)) continue;
                CollectModules(value, dir, modules, visited);
            }
            AddModule(modules, GetModuleIdentity(fullPath));
        }

        /// <summary>
        /// Computes the identity of a module from its source file path:
        /// the path relative to the generator sources folder (e.g. `Modules/Toon/Main`) when bundled,
        /// the plain file name otherwise. The relative path keeps same-named modules in
        /// different folders (e.g. `Toon/Main` vs `Toon/v2/Main`) distinct
        /// </summary>
        private static string GetModuleIdentity(string fullPath)
        {
            var normalized = fullPath.Replace('\\', '/');
            var sources = (ProjectRoot + ORL.ShaderGenerator.Utils.GetORLSourceFolder()).Replace('\\', '/').TrimEnd('/');
            if (normalized.StartsWith(sources + "/", StringComparison.OrdinalIgnoreCase))
            {
                var rel = normalized.Substring(sources.Length + 1);
                var dot = rel.LastIndexOf('.');
                return dot > 0 ? rel.Substring(0, dot) : rel;
            }
            return Path.GetFileNameWithoutExtension(fullPath);
        }

        /// <summary>
        /// Converts a full os path into a unity-relative asset path
        /// </summary>
        private static string ToUnityPath(string fullPath)
        {
            var normalized = fullPath.Replace('\\', '/');
            var root = ProjectRoot;
            return normalized.StartsWith(root, StringComparison.OrdinalIgnoreCase)
                ? normalized.Substring(root.Length + 1)
                : normalized;
        }

        private static void AddModule(List<string> modules, string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return;
            if (!modules.Exists(m => string.Equals(m, name, StringComparison.OrdinalIgnoreCase)))
            {
                modules.Add(name);
            }
        }

        /// <summary>
        /// Extracts the contents of the %Includes() block of an ORL source file
        /// </summary>
        private static List<string> GetIncludes(string fullPath)
        {
            var includes = new List<string>();
            var block = GetParsedBlocks(fullPath).Find(b => b.CoreBlockType == ORL.ShaderGenerator.ShaderBlock.BlockType.Includes);
            if (block == null) return includes;
            foreach (var line in block.Contents)
            {
                foreach (Match match in IncludeRegex.Matches(line))
                {
                    var value = match.Groups[1].Value.Trim();
                    if (value.Length > 0) includes.Add(value);
                }
            }
            return includes;
        }

        /// <summary>
        /// Resolves an ORL include path into a full os path,
        /// reusing the generator's resolution to support module remapping and such
        /// </summary>
        private static string ResolveAssetPath(string path, string baseDir)
        {
            if (string.IsNullOrWhiteSpace(path)) return null;
            var cleaned = path.Trim().Replace('\\', '/');
            var remaps = GeneratorProjectSettings.GetSettings().userModuleRemaps;
            try
            {
                var resolved = ORL.ShaderGenerator.Utils.ResolveORLAsset(cleaned, cleaned.StartsWith("@/"), remaps, baseDir);
                return string.IsNullOrWhiteSpace(resolved) ? null : Path.GetFullPath(resolved);
            }
            catch (Exception ex)
            {
                Debug.LogWarning($"[ORL] Failed to resolve the ORL asset '{cleaned}': {ex.Message}");
                return null;
            }
        }

#else

        // Without the generator there are no orl source assets, so there is nothing to resolve
        public static List<string> GetShaderModules(string shaderAssetPath)
        {
            return new List<string>();
        }

#endif

        #endregion

        /// <summary>
        /// Returns the list of languages available across all localization assets
        /// This drives the UI selector, so we insert EN first
        /// </summary>
        public static List<string> GetAvailableLanguages()
        {
            var set = new SortedSet<string>(StringComparer.OrdinalIgnoreCase);
            foreach (var asset in State.OrderedAssets)
            {
                foreach (var prop in asset.data)
                {
                    foreach (var lang in prop.data)
                    {
                        var normalized = NormalizeLanguage(lang.language);
                        if (!string.IsNullOrEmpty(normalized)) set.Add(normalized);
                    }
                }
            }
            var result = new List<string>();
            // Insert EN up-top so everything defaults to that
            if (set.Contains("EN"))
            {
                result.Add("EN");
                set.Remove("EN");
            }
            result.AddRange(set);
            return result;
        }

        /// <summary>
        /// Normalizes a language code into a canonical form (japanese is `JA`)
        ///
        /// This used to handle things like `JP` -> `JA` conversion
        /// left it for now in case some extra remapping needs to be added
        /// </summary>
        public static string NormalizeLanguage(string code)
        {
            if (string.IsNullOrWhiteSpace(code)) return string.Empty;
            code = code.Trim().ToUpperInvariant();
            return code;
        }

        private static readonly Dictionary<string, string> LanguageNames = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
        {
            { "EN", "English" },
            { "JA", "日本語" },
            { "FR", "Français" },
            { "DE", "Deutsch" },
            { "ES", "Español" },
            { "PT", "Português" },
            { "RU", "Русский" },
            { "ZH", "中文" },
            { "KO", "한국어" },
        };

        public static string GetLanguageDisplayName(string code)
        {
            return LanguageNames.TryGetValue(code, out var name) ? name : code;
        }
    }

    /// <summary>
    /// Invalidates the localization cache whenever any relevant asset is imported
    /// </summary>
    public class LocalizationCachePostprocessor : AssetPostprocessor
    {
        private static void OnPostprocessAllAssets(string[] importedAssets, string[] deletedAssets, string[] movedAssets, string[] movedFromAssetPaths)
        {
            if (
                IsRelevant(importedAssets) ||
                IsRelevant(deletedAssets) ||
                IsRelevant(movedAssets) ||
                IsRelevant(movedFromAssetPaths))
            {
                LocalizationCache.Invalidate();
            }
        }

        private static bool IsRelevant(string[] paths)
        {
            if (paths == null) return false;
            foreach (var path in paths)
            {
                // Since localization is connected to shader props, we invalidate the cache on those as well
                var ext = Path.GetExtension(path);
                if (
                    string.Equals(ext, ".orlloc", StringComparison.OrdinalIgnoreCase) ||
                    string.Equals(ext, ".orlsource", StringComparison.OrdinalIgnoreCase) ||
                    string.Equals(ext, ".orlshader", StringComparison.OrdinalIgnoreCase) ||
                    string.Equals(ext, ".orlconfshader", StringComparison.OrdinalIgnoreCase))
                {
                    return true;
                }
            }
            return false;
        }
    }
}
