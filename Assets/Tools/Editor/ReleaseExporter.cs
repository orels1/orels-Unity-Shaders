using System;
using System.IO;
using UnityEditor;
using UnityEngine;

namespace ORL.Tools
{
    public static class ReleaseExporter
    {
        private readonly static string[] _exportFolders =
        {
            "Packages/sh.orels.shaders",
            "Packages/sh.orels.shaders.inspector",
            "Packages/sh.orels.shaders.generator",
        };

        [Serializable]
        public class PackageInfo
        {
            public string name;
            public string displayName;
            public string version;
        }

        [MenuItem("Tools/orels1/Export Release")]
        private static void ExportAsUnityPackage()
        {
            var manifestPath = Path.Combine(_exportFolders[0], "package.json");
            var manifest = JsonUtility.FromJson<PackageInfo>(File.ReadAllText(manifestPath));
            if (manifest == null)
            {
                Debug.LogError("Failed to load main package manifest to extract version, aborting");
                return;
            }

            Debug.Log($"Exporting version {manifest.version}");

            var exportDir = Path.Combine(Directory.GetCurrentDirectory(), "Exports");
            Directory.CreateDirectory(exportDir);
            AssetDatabase.ExportPackage
            (
                _exportFolders,
                Path.Combine(exportDir, $"orl-shaders-combined-{manifest.version}.unitypackage"),
                ExportPackageOptions.Recurse | ExportPackageOptions.Interactive
            );

            AssetDatabase.ExportPackage
            (
                _exportFolders[0],
                Path.Combine(exportDir, $"sh.orels.shaders-standalone-{manifest.version}.unitypackage"),
                ExportPackageOptions.Recurse | ExportPackageOptions.Interactive
            );

            AssetDatabase.ExportPackage
            (
                _exportFolders[1],
                Path.Combine(exportDir, $"sh.orels.shaders.inspector-standalone-{manifest.version}.unitypackage"),
                ExportPackageOptions.Recurse | ExportPackageOptions.Interactive
            );

            AssetDatabase.ExportPackage
            (
                _exportFolders[2],
                Path.Combine(exportDir, $"sh.orels.shaders.generator-standalone-{manifest.version}.unitypackage"),
                ExportPackageOptions.Recurse | ExportPackageOptions.Interactive
            );
        }
    }
}