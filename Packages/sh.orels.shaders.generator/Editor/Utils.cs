using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;

namespace ORL.ShaderGenerator
{
    public class Utils
    {
        public static TextAsset Locator => Resources.Load<TextAsset>("ORLLocator");
        
        public static string GetORLSourceFolder()
        {
            var locatorPath = AssetDatabase.GetAssetPath(Locator);
            var sourceFolder = locatorPath.Substring(0, locatorPath.LastIndexOf('/'));
            sourceFolder = sourceFolder.Replace("/Resources", "/Sources");
            return sourceFolder;
        }

        public static string GetFullPath(string assetPath)
        {
            return Application.dataPath.Replace("\\", "/").Replace("Assets", "") + assetPath;
        }

        public static string ResolveORLAsset(string path)
        {
            var cleaned = path.Replace("@", "");
            var sourcesFolder = GetORLSourceFolder();
            var fullPath = GetFullPath(sourcesFolder + cleaned);
            if (!File.Exists(fullPath))
            {
                Debug.LogWarning($"Unable to find built-in asset {cleaned}. Make sure it exists in {sourcesFolder}");
                return null;
            }

            return sourcesFolder + cleaned;
        }
        
        public static string[] GetORLTemplate(string path)
        {
            var cleaned = path.Replace("@", "");
            var sourcesFolder = GetORLSourceFolder();
            var fullPath = GetFullPath(sourcesFolder + cleaned + ".orltemplate");
            if (!File.Exists(fullPath))
            {
                Debug.LogWarning($"Unable to find built-in asset {cleaned}. Make sure it exists in {sourcesFolder}");
                return null;
            }

            return File.ReadAllLines(fullPath);
        }
        
        public static string[] GetORLSource(string path)
        {
            var cleaned = path.Replace("@", "");
            var sourcesFolder = GetORLSourceFolder();
            var fullPath = GetFullPath(sourcesFolder + cleaned + ".orlsource");
            if (!File.Exists(fullPath))
            {
                Debug.LogWarning($"Unable to find built-in asset {cleaned}. Make sure it exists in {sourcesFolder}");
                return null;
            }

            return File.ReadAllLines(fullPath);
        }

        public static void RecursivelyCollectDependencies(List<string> sourceList, ref List<string> dependencies)
        {
            var parser = new Parser();
            foreach (var source in sourceList)
            {
                var blocks = parser.Parse(GetORLSource(source));
                var includesBlockIndex = blocks.FindIndex(b => b.Name == "%Includes");
                if (includesBlockIndex == -1)
                {
                    dependencies.Add(source);
                    continue;
                }
                var cleanDepPaths = blocks[includesBlockIndex].Contents
                    .Select(l => l.Replace("\"", "").Replace(",", "").Trim()).ToList();
                foreach (var depPath in cleanDepPaths)
                {
                    if (depPath == "self")
                    {
                        if (!dependencies.Contains(source))
                        {
                            dependencies.Add(source);
                        }
                        continue;
                    }
                    if (!dependencies.Contains(depPath))
                    {
                        var deepDeps = new List<string>();
                        RecursivelyCollectDependencies(new List<string> {depPath}, ref deepDeps);
                        dependencies.AddRange(deepDeps);
                    }
                }
            }
        }
    }
}