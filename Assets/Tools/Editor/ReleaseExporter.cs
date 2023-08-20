using System.IO;
using UnityEditor;
using UnityEngine;
using VRC.PackageManagement.Core.Types.Packages;

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

        [MenuItem("Tools/orels1/Export Release")]
        private static void ExportAsUnityPackage ()
        {
            var manifestPath = Path.Combine(_exportFolders[0], VRCPackageManifest.Filename);
            var manifest = VRCPackageManifest.GetManifestAtPath(manifestPath);
            if (manifest == null)
            {
                Debug.LogError("Failed to load main package manifest to extract version, aborting");
                return;
            }

            var exportDir = Path.Combine(Directory.GetCurrentDirectory(), "Exports");
            Directory.CreateDirectory(exportDir);
            AssetDatabase.ExportPackage
            (
                _exportFolders, 
                Path.Combine(exportDir, $"orl-shaders-combined-{manifest.Version}.unitypackage"),
                ExportPackageOptions.Recurse | ExportPackageOptions.Interactive
            );
            
            AssetDatabase.ExportPackage
            (
                _exportFolders[0], 
                Path.Combine(exportDir, $"sh.orels.shaders-standalone-{manifest.Version}.unitypackage"),
                ExportPackageOptions.Recurse | ExportPackageOptions.Interactive
            );
            
            AssetDatabase.ExportPackage
            (
                _exportFolders[1], 
                Path.Combine(exportDir, $"sh.orels.shaders.inspector-standalone-{manifest.Version}.unitypackage"),
                ExportPackageOptions.Recurse | ExportPackageOptions.Interactive
            );
            
            AssetDatabase.ExportPackage
            (
                _exportFolders[2], 
                Path.Combine(exportDir, $"sh.orels.shaders.generator-standalone-{manifest.Version}.unitypackage"),
                ExportPackageOptions.Recurse | ExportPackageOptions.Interactive
            );
        }
    }
}