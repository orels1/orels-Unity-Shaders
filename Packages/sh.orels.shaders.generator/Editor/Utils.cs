using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;

namespace ORL.ShaderGenerator
{
    public static class Utils
    {

        /// <summary>
        /// You might look at this and go "gee, this does look very hardcoded!" and believe me, this used to be nice
        /// and based on the Resources folder, utilizing the unity apis and everything
        /// The problem is that unity hates first imports of anything, and while a lot of things are still in motion
        /// it would not correctly resolve the path to the locator file
        /// even when manually doing AssetDatabase.ImportAsset on it
        /// So i gave up and, at least for now, the path is hardcoded. The good thing is - is that this path should be stable
        /// Unless someone manually tampers with how packages are stored
        /// </summary>
        /// <returns>The path to ORL generator sources</returns>
        public static string GetORLSourceFolder()
        {
            return "/Packages/sh.orels.shaders.generator/Runtime/Sources";
        }
        
        public static string ResolveORLAsset(string path, bool bundled, string basePath = null)
        {
            if (bundled)
            {
                return ResolveBundledAsset(path);
            }

            var freeAsset = ResolveFreeAsset(path, basePath);
            if (freeAsset == null)
            {
                throw new SourceAssetNotFoundException(path, new[] {basePath});
            }

            return freeAsset;
        }

        private static string ResolveBundledAsset(string path)
        {
            var cleaned = path.Replace("@/", "");
            var sourcesFolder = GetORLSourceFolder();
            // this package is split off but we still want to have nice shorthands into it
            var shaderSourcesFolder = "/Packages/sh.orels.shaders/Runtime";

            var builtInAsset = ResolveFreeAsset(cleaned, sourcesFolder);
            if (!string.IsNullOrWhiteSpace(builtInAsset)) return builtInAsset;

            var shaderPackageAsset = ResolveFreeAsset(cleaned, shaderSourcesFolder);
            
            if (builtInAsset == null && shaderPackageAsset == null)
            {
                throw new SourceAssetNotFoundException(path, new[] { sourcesFolder, shaderSourcesFolder });
            }

            return shaderPackageAsset;
        }

        private static string ResolveFreeAsset(string path, string basePath)
        {
            var fullPath = basePath + "/" + path;
            // Resolve absolute paths
            var isAbsoluteImport = path.StartsWith("/");
            if (isAbsoluteImport) {
                fullPath = path.Substring(1);
            }
            // Resolve relative paths
            if (path.StartsWith(".."))
            {
                var parts = path.Split('/').ToList();
                var fileName = parts[parts.Count - 1];
                parts.RemoveAt(parts.Count - 1);
                foreach (var part in parts)
                {
                    if (part == "..")
                    {
                        basePath = basePath.Substring(0, basePath.LastIndexOf('/'));
                    }
                    else
                    {
                        basePath += "/" + part;
                    }
                }
                fullPath = basePath + "/" + fileName;
            }

            if (fullPath.StartsWith("/"))
            {
                fullPath = fullPath.Substring(1);
            }
            var directExists = File.Exists(fullPath);
            var orlSourceExists = File.Exists($"{fullPath}.orlsource");
            var orlShaderExists = File.Exists($"{fullPath}.orlshader");
            var orlTemplateExists = File.Exists($"{fullPath}.orltemplate");
            if (!directExists && !orlSourceExists && !orlShaderExists && !orlTemplateExists)
            {
                return null;
            }

            if (directExists)
            {
                return isAbsoluteImport ? path.Substring(1) : fullPath;
            }

            if (orlSourceExists)
            {
                return (isAbsoluteImport ? path.Substring(1) : fullPath) + ".orlsource";
            }
            
            if (orlShaderExists)
            {
                return (isAbsoluteImport ? path.Substring(1) : fullPath) + ".orlshader";
            }
            
            if (orlTemplateExists)
            {
                return (isAbsoluteImport ? path.Substring(1) : fullPath) + ".orltemplate";
            }

            return fullPath;
        }

        public static string ResolveORLAsset(string path)
        {
            return ResolveORLAsset(path, true);
        }
        
        public static string[] GetORLTemplate(string path)
        {
            var fullPath = ResolveORLAsset(path, true);
            return File.ReadAllLines(fullPath);
        }
        
        public static string[] GetORLSource(string path)
        {
            var fullPath = ResolveORLAsset(path, true);
            return File.ReadAllLines(fullPath);
        }

        public static string[] GetAssetSource(string path, string basePath)
        {
            return File.ReadAllLines(ResolveORLAsset(path, path.StartsWith("@/"), basePath));
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