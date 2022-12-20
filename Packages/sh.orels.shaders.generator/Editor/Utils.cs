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

        public static string ResolveORLAsset(string path, bool bundled, string basePath = null)
        {
            if (bundled)
            {
                return ResolveBundledAsset(path);
            }

            return ResolveFreeAsset(path, basePath);
        }

        private static string ResolveBundledAsset(string path)
        {
            var cleaned = path.Replace("@/", "");
            var sourcesFolder = GetORLSourceFolder();
            return ResolveFreeAsset(cleaned, sourcesFolder);
        }

        private static string ResolveFreeAsset(string path, string basePath)
        {
            var combined = basePath + "/" + path;
            var fullPath = GetFullPath(combined);
            // Resolve absolute paths
            var isAbsoluteImport = path.StartsWith("/");
            if (path.StartsWith("/")) {
                fullPath = GetFullPath(path.Substring(1));
            }
            // Resolve relative paths
            if (path.StartsWith("..")) {
                var parts = path.Split('/');
                foreach (var part in parts)
                {
                    if (part == "..")
                    {
                        basePath = basePath.Substring(0, basePath.LastIndexOf('/'));
                    }
                    else
                    {
                        fullPath = basePath + "/" + part;
                    }
                }
            }
            var directExists = File.Exists(fullPath);
            var orlSourceExists = File.Exists($"{fullPath}.orlsource");
            var orlShaderExists = File.Exists($"{fullPath}.orlshader");
            var orlTemplateExists = File.Exists($"{fullPath}.orltemplate");
            if (!directExists && !orlSourceExists && !orlShaderExists && !orlTemplateExists)
            {
                Debug.LogWarning($"Unable to find asset {path}. Make sure it exists in {combined}");
                return null;
            }

            if (directExists)
            {
                return isAbsoluteImport ? path.Substring(1) : combined;
            }

            if (orlSourceExists)
            {
                return (isAbsoluteImport ? path.Substring(1) : combined) + ".orlsource";
            }
            
            if (orlShaderExists)
            {
                return (isAbsoluteImport ? path.Substring(1) : combined) + ".orlshader";
            }
            
            if (orlTemplateExists)
            {
                return (isAbsoluteImport ? path.Substring(1) : combined) + ".orltemplate";
            }

            return combined;
        }

        public static string ResolveORLAsset(string path)
        {
            return ResolveORLAsset(path, true);
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

        public static string[] GetAssetSource(string path, string basePath)
        {
            return File.ReadAllLines(GetFullPath(ResolveORLAsset(path, path.StartsWith("@/"), basePath)));
        }

        public static Texture2D GetNonModifiableTexture(Shader shader, string name)
        {
            var so = new SerializedObject(shader);
            var texList = so.FindProperty("m_NonModifiableTextures");
            if (texList.arraySize == 0) return null;
            
            for (var i = 0; i < texList.arraySize; i++)
            {
                var tex = texList.GetArrayElementAtIndex(i);
                var texName = tex.FindPropertyRelative("first").stringValue;
                if (texName != name) continue;
                var texValue = tex.FindPropertyRelative("second");
                return texValue.objectReferenceValue as Texture2D;
            }

            return null;
        }

        public static void RecursivelyCollectDependencies(List<string> sourceList, ref List<string> dependencies, string basePath)
        {
            var parser = new Parser();
            foreach (var source in sourceList)
            {
                var blocks = parser.Parse(GetAssetSource(source, basePath));
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
                        RecursivelyCollectDependencies(new List<string> {depPath}, ref deepDeps, basePath);
                        dependencies.AddRange(deepDeps);
                    }
                }
            }
        }
    }
}