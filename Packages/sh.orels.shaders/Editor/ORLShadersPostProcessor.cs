using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEditorInternal;
using UnityEngine;

namespace ORL.Shaders
{
    public class ORLShadersPostProcessor : AssetPostprocessor
    {
        private static void OnPostprocessAllAssets(string[] importedAssets, string[] deletedAssets, string[] movedAssets,
            string[] movedFromAssetPaths)
        {
            CheckForShaderMigration(importedAssets);
        }

        private static void CheckForShaderMigration(string[] assets)
        {
            foreach (var asset in assets)
            {
                if (!asset.Contains("sh.orels.shaders")) continue;
                if (!asset.EndsWith("package.json")) continue;
                var jsonString = File.ReadAllLines(asset);
                var version = jsonString.Where(line => line.Contains("\"version\""))
                    .Select(line => line.Trim()).First();
                version = version.Split(new [] { ": " }, StringSplitOptions.None)[1];
                version = version.Substring(1);
                version = version.Substring(0, version.Length - 1);
                version = version.Replace("\"", "");

                var settingsAsset = Resources.Load<ORLShadersSettings>("ORLShadersSettings");
                if (settingsAsset == null)
                {
                    var so = ScriptableObject.CreateInstance<ORLShadersSettings>();
                    so.ShadersVersion = version;
                    AssetDatabase.CreateAsset(so, asset.Substring(0, asset.LastIndexOf("/")) + "/Editor/Resources/ORLShadersSettings.asset");
                    return;
                }
                var currVersion = Resources.Load<ORLShadersSettings>("ORLShadersSettings").ShadersVersion;
                if (int.Parse(currVersion.Substring(0, 1)) >= int.Parse(version.Substring(0, 1))) return;

                ORLShadersMigrator.ShowWindow();
            }
        }
    }
}