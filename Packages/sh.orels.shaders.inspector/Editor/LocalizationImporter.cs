using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using UnityEngine;
#if UNITY_2022_3_OR_NEWER
using UnityEditor.AssetImporters;
#else
using UnityEditor.Experimental.AssetImporters;
#endif


namespace ORL.ShaderInspector
{
    /*
        Localization format is as follows
        [_PropName] for the property
        name.<languageCode> = <displayName>
        tooltip.<languageCode> = tooltip

        Supports `\n` for tooltips
        Supports `@[_PropName]` to reuse the value of `name` or `tooltip from a different property
    */
    [ScriptedImporter(1, "orlloc")]
    public class LocalizationImporter : ScriptedImporter
    {
        // Matches the `[ _PropertyName ]` block headers of the block format
        private static readonly Regex BlockStartRegex = new Regex(@"^\[([^\]]+)\]$", RegexOptions.Compiled);

        // Matches `@[ _PropertyName ]` references of the block format
        private static readonly Regex RefRegex = new Regex(@"^@\[\s*([^\]]+?)\s*\]$", RegexOptions.Compiled);

        private enum LocalizationKey
        {
            Unknown,
            Name,
            Tooltip,
        }

        public override void OnImportAsset(AssetImportContext ctx)
        {
            var textContent = File.ReadAllText(ctx.assetPath);
            var textAsset = new TextAsset(textContent);
            textAsset.name = "Content";
            ctx.AddObjectToAsset("Collection", textAsset);

            var lines = File.ReadAllLines(ctx.assetPath);

            var output = ScriptableObject.CreateInstance<LocalizationData>();
            var properties = new List<string>();
            var data = new List<LocalizationData.LocalizedPropData>();

            var combined = new Dictionary<string, Dictionary<string, LocalizationData.LocalizedLanguageData>>();
            var propOrder = new List<string>();
            var moduleName = "";

            ParseBlockFormat(lines, combined, propOrder, ref moduleName);

            // resolve `@[Prop]` references between blocks, chains included
            ResolveReferences(combined, propOrder, ctx);

            foreach (var prop in propOrder)
            {
                properties.Add(prop);
                data.Add(new LocalizationData.LocalizedPropData
                {
                    propName = prop,
                    data = combined[prop].Values.ToList()
                });
            }

            output.moduleName = !string.IsNullOrWhiteSpace(moduleName)
                ? moduleName
                : Path.GetFileNameWithoutExtension(ctx.assetPath);
            output.properties = properties;
            output.data = data;
            ctx.AddObjectToAsset("LocalizationData", output);
            ctx.SetMainObject(output);
        }

        /// <summary>
        /// Parses the block format, see top of the file
        /// </summary>
        private static void ParseBlockFormat(
            string[] lines,
            Dictionary<string, Dictionary<string, LocalizationData.LocalizedLanguageData>> combined,
            List<string> propOrder,
            ref string moduleName)
        {
            string currentProp = null;
            foreach (var line in lines)
            {
                var trimmed = line.Trim();
                if (trimmed.Length == 0 || trimmed.StartsWith("#")) continue;
                var blockMatch = BlockStartRegex.Match(trimmed);

                // Set up a new block
                if (blockMatch.Success)
                {
                    currentProp = blockMatch.Groups[1].Value.Trim();
                    if (string.IsNullOrWhiteSpace(currentProp))
                    {
                        currentProp = null;
                        continue;
                    }
                    if (!combined.ContainsKey(currentProp))
                    {
                        combined.Add(currentProp, new Dictionary<string, LocalizationData.LocalizedLanguageData>());
                        propOrder.Add(currentProp);
                    }
                    continue;
                }

                // parse the individual entry
                var split = trimmed.Split('=', StringSplitOptions.RemoveEmptyEntries);
                if (split.Length == 1) continue;
                var key = split[0].Trim();
                var value = split[1].Trim();
                if (string.IsNullOrWhiteSpace(key)) continue;

                // Handle the root level stuff like the `module` marker
                if (currentProp == null)
                {
                    if (key.Equals("module", StringComparison.OrdinalIgnoreCase))
                    {
                        moduleName = value;
                    }
                    continue;
                }

                // keys are `name` / `tooltip` with an optional `.language` suffix, english by default
                var field = key;
                var lang = "EN";
                var dotIndex = key.LastIndexOf('.');
                if (dotIndex > 0)
                {
                    field = key.Substring(0, dotIndex).Trim().ToLowerInvariant();
                    lang = LocalizationCache.NormalizeLanguage(key.Substring(dotIndex + 1));
                }
                else
                {
                    field = field.ToLowerInvariant();
                }

                // Ensure only supported properties are actually parsed
                if (!Enum.TryParse<LocalizationKey>(field[..1].ToUpperInvariant() + field.Substring(1), out var keyKind) || keyKind == LocalizationKey.Unknown)
                {
                    continue;
                }

                // Insert things back into the combined list
                var dict = combined[currentProp];
                LocalizationData.LocalizedLanguageData entry;
                if (dict.TryGetValue(lang, out var existing))
                {
                    entry = existing;
                }
                else
                {
                    entry = new LocalizationData.LocalizedLanguageData { language = lang };
                }

                switch (keyKind)
                {
                    case LocalizationKey.Name:
                        entry.name = value;
                        break;
                    case LocalizationKey.Tooltip:
                        entry.tooltip = value;
                        break;
                }

                // if there are duplicates - we'll just overwrite
                dict[lang] = entry;
            }
        }

        /// <summary>
        /// Resolves `@[Prop]` references between blocks, e.g.
        ///
        /// [_LMLayer2Color]
        /// name.en = @[_LMLayer1Color]
        ///
        /// A reference copies the same field (name / tooltip) of the target property
        /// in the same language, falling back to english when the target has none
        ///
        /// Chains are resolved iteratively, cycles and dangling targets are dropped with a warning
        /// </summary>
        private static void ResolveReferences(
            Dictionary<string, Dictionary<string, LocalizationData.LocalizedLanguageData>> combined,
            List<string> propOrder,
            AssetImportContext ctx)
        {
            var changed = true;
            while (changed)
            {
                // i am not good at writing these, so just in case we're gonna play it safe
                changed = false;
                foreach (var prop in propOrder)
                {
                    var cloned = new Dictionary<string, LocalizationData.LocalizedLanguageData>(combined[prop]);
                    foreach (var lang in cloned.Keys)
                    {
                        var entry = combined[prop][lang];
                        if (ResolveField(combined, entry.name, lang, "name", out var name))
                        {
                            entry.name = name;
                            changed = true;
                        }
                        if (ResolveField(combined, entry.tooltip, lang, "tooltip", out var tooltip))
                        {
                            entry.tooltip = tooltip;
                            changed = true;
                        }
                        combined[prop][lang] = entry;
                    }
                }
            }

            // whatever is left is a cycle or a dangling target
            foreach (var prop in propOrder)
            {
                var cloned = new Dictionary<string, LocalizationData.LocalizedLanguageData>(combined[prop]);
                foreach (var lang in cloned.Keys)
                {
                    var entry = combined[prop][lang];
                    if (TryGetRef(entry.name, out _))
                    {
                        ctx.LogImportWarning($"[ORL] Unresolved localization reference '{entry.name}' in '{prop}' ({lang})");
                        entry.name = "";
                    }
                    if (TryGetRef(entry.tooltip, out _))
                    {
                        ctx.LogImportWarning($"[ORL] Unresolved localization reference '{entry.tooltip}' in '{prop}' ({lang})");
                        entry.tooltip = "";
                    }
                    combined[prop][lang] = entry;
                }
            }
        }

        private static bool ResolveField(
            Dictionary<string, Dictionary<string, LocalizationData.LocalizedLanguageData>> combined,
            string value,
            string lang,
            string field,
            out string resolved)
        {
            resolved = value;
            // check if its a ref at all
            if (!TryGetRef(value, out var target)) return false;
            // check if we even have this property in the dict
            if (!combined.TryGetValue(target, out var targetDict)) return false;

            // same language, english as a fallback
            if (!targetDict.ContainsKey(lang) && !targetDict.ContainsKey("EN")) return false;
            var source = targetDict.ContainsKey(lang) ? targetDict[lang] : targetDict["EN"];
            var sourceValue = field == "name" ? source.name : source.tooltip;
            // the target chains into another reference, resolve it on a later pass
            // might be worth not supporting this at all, but it works for now, it seems
            if (TryGetRef(sourceValue, out _)) return false;
            resolved = sourceValue ?? "";
            return true;
        }

        // Get the name of the prop to find from a ref like `@[_PropName]`
        private static bool TryGetRef(string value, out string target)
        {
            target = null;
            if (string.IsNullOrEmpty(value)) return false;
            var match = RefRegex.Match(value);
            if (!match.Success) return false;

            target = match.Groups[1].Value.Trim();
            return true;
        }

    }
}
