
using System;
using System.Collections.Generic;
using System.IO;
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

            var localizedData = new Dictionary<string, string>();

            var index = 0;
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

                var split = line.Split(';', StringSplitOptions.RemoveEmptyEntries);
                if (!localizedData.ContainsKey(split[0]))
                {
                    localizedData.Add(split[0], split[1].Replace("\\n", "\n"));
                }

                index++;
            }

            var output = ScriptableObject.CreateInstance<LocalizationData>();
            var properties = new List<string>();
            var data = new List<LocalizationData.LocalizedPropData>();
            foreach (var kvp in localizedData)
            {
                properties.Add(kvp.Key);
                data.Add(new LocalizationData.LocalizedPropData
                {
                    langauge = "EN",
                    tooltip = kvp.Value,
                });
            }
            output.properties = properties;
            output.data = data;
            ctx.AddObjectToAsset("LocalizationData", output);
            ctx.SetMainObject(output);
        }
    }
}
