using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;
using Debug = UnityEngine.Debug;

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

            // Get a list of new files from git
            var processInfo = new ProcessStartInfo("git", "status -s")
            {
                WorkingDirectory = new FileInfo(".").FullName,
                UseShellExecute = false,
                CreateNoWindow = true,
                RedirectStandardOutput = true
            };
            var gitProc = Process.Start(processInfo);
            gitProc.WaitForExit();
            if (gitProc.ExitCode != 0)
            {
                Debug.LogError("Failed to get git status, aborting");
                return;
            }
            var ignored = new List<string>();
            while (!gitProc.StandardOutput.EndOfStream)
            {
                var line = gitProc.StandardOutput.ReadLine();
                if (line.StartsWith("??"))
                {
                    ignored.Add(line.Substring(2).Trim().Replace('/', '\\'));
                }
            }

            Debug.Log($"Exporting version {manifest.version}");

            var exportDir = Path.Combine(Directory.GetCurrentDirectory(), "Exports");
            Directory.CreateDirectory(exportDir);

            ExportAsUnityPackage(_exportFolders, ignored, Path.Combine(exportDir, $"sh.orels.shaders-combined-{manifest.version}.unitypackage"), manifest.version);
            ExportAsUnityPackage(_exportFolders[0], ignored, Path.Combine(exportDir, $"sh.orels.shaders-standalone-{manifest.version}.unitypackage"), manifest.version);
            ExportAsUnityPackage(_exportFolders[1], ignored, Path.Combine(exportDir, $"sh.orels.shaders.inspector-standalone-{manifest.version}.unitypackage"), manifest.version);
            ExportAsUnityPackage(_exportFolders[2], ignored, Path.Combine(exportDir, $"sh.orels.shaders.generator-standalone-{manifest.version}.unitypackage"), manifest.version);

            // Open the export folder
            var exportedPath = new FileInfo("Exports").FullName;
            Process.Start(exportedPath);
        }

        private static void ExportAsUnityPackage(string[] baseFolders, List<string> ingored, string exportPath, string version)
        {
            var list = baseFolders.SelectMany(f => Directory.GetFiles(f, "*", SearchOption.AllDirectories))
                .Select(f => f.Replace('/', '\\'))
                .Where(f => !ingored.Any(i => f.Contains(i, StringComparison.InvariantCultureIgnoreCase)))
                .ToArray();

            Debug.Log("Packages\\sh.orels.shaders\\Editor\\Dependencies\\ORLLayoutToolkit.cs".Contains("Packages\\sh.orels.shaders\\Editor\\Dependencies\\"));
            AssetDatabase.ExportPackage(list, exportPath, ExportPackageOptions.Recurse);
        }

        private static void ExportAsUnityPackage(string baseFolder, List<string> ingored, string exportPath, string version)
        {
            var list = Directory.GetFiles(baseFolder, "*", SearchOption.AllDirectories)
                .Select(f => f.Replace('/', '\\'))
                .Where(f => !ingored.Any(i => f.Contains(i, StringComparison.InvariantCultureIgnoreCase)))
                .ToArray();
            AssetDatabase.ExportPackage(list, exportPath, ExportPackageOptions.Recurse);
        }
    }
}