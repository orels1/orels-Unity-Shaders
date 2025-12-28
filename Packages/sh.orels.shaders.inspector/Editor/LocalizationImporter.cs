
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEngine;
#if UNITY_2022_3_OR_NEWER
using UnityEditor.AssetImporters;
#else
using UnityEditor.Experimental.AssetImporters;
#endif

namespace ORL.ShaderInspector
{
    [ScriptedImporter(1, "orlloc")]
    public class LocalizationImporter : ScriptedImporter
    {
        public override void OnImportAsset(AssetImportContext ctx)
        {
            var textContent = File.ReadAllText(ctx.assetPath);
            var textAsset = new TextAsset(textContent);
            textAsset.name = "Content";
            ctx.AddObjectToAsset("Collection", textAsset);

            var lines = File.ReadAllLines(ctx.assetPath);

            var index = 0;

            var output = ScriptableObject.CreateInstance<LocalizationData>();
            var properties = new List<string>();
            var data = new List<LocalizationData.LocalizedPropData>();

            var combined = new Dictionary<string, Dictionary<string, LocalizationData.LocalizedLanguageData>>();

            var tooltipMode = false;
            var nameMode = false;

            foreach (var line in lines)
            {
                if (index == 0)
                {
                    // do header stuff here;
                    index++;
                    continue;
                }

                if (string.IsNullOrWhiteSpace(line))
                {
                    index++;
                    continue;
                }

                if (line.Trim().Equals("=== TOOLTIPS ==="))
                {
                    tooltipMode = true;
                    nameMode = false;
                    index++;
                    continue;
                }

                if (line.Trim().Equals("=== NAMES ==="))
                {
                    nameMode = true;
                    tooltipMode = false;
                    index++;
                    continue;
                }

                var split = line.Split(';', StringSplitOptions.RemoveEmptyEntries);

                if (!combined.ContainsKey(split[0]))
                {
                    combined[split[0]] = new Dictionary<string, LocalizationData.LocalizedLanguageData>();
                }
                
                if (split.Length >= 2)
                {
                    var entry = new LocalizationData.LocalizedLanguageData();
                    entry.language = "EN";
                    if (tooltipMode)
                    {
                        entry.tooltip = split[1];
                        if (combined[split[0]].ContainsKey("EN"))
                        {
                            entry.name = combined[split[0]]["EN"].name;
                        }
                    }

                    if (nameMode)
                    {
                        entry.name = split[1];
                        if (combined[split[0]].ContainsKey("EN"))
                        {
                            entry.name = combined[split[0]]["EN"].tooltip;
                        }
                    }

                    combined[split[0]]["EN"] = entry;
                }
                if (split.Length >= 3)
                {
                    var entry = new LocalizationData.LocalizedLanguageData();
                    entry.language = "JP";
                    if (tooltipMode)
                    {
                        entry.tooltip = split[2];
                        if (combined[split[0]].ContainsKey("JP"))
                        {
                            entry.name = combined[split[0]]["JP"].name;
                        }
                    }

                    if (nameMode)
                    {
                        entry.name = split[2];
                        if (combined[split[0]].ContainsKey("JP"))
                        {
                            entry.name = combined[split[0]]["JP"].tooltip;
                        }
                    }
                    combined[split[0]]["JP"] = entry;
                }

                index++;
            }

            foreach (var entry in combined)
            {
                properties.Add(entry.Key);
                data.Add(new LocalizationData.LocalizedPropData
                {
                    propName = entry.Key,
                    data = entry.Value.Values.ToList()
                });
            }

            output.properties = properties;
            output.data = data;
            ctx.AddObjectToAsset("LocalizationData", output);
            ctx.SetMainObject(output);
        }
    }
}
