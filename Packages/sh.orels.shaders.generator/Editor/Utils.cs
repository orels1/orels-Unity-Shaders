using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using ORL.ShaderGenerator.Settings;
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
                throw new SourceAssetNotFoundException(path, new[] { basePath });
            }

            return freeAsset;
        }

        public static string ResolveORLAsset(string path, bool bundled, List<ModuleRemap> remaps, string basePath = null)
        {
            if (remaps != null)
            {
                foreach (var remap in remaps)
                {
                    // Ignore empty entries
                    if (string.IsNullOrWhiteSpace(remap.Source) || string.IsNullOrWhiteSpace(remap.Destination)) continue;

                    if (path.Equals(remap.Source, StringComparison.InvariantCultureIgnoreCase))
                    {
                        path = remap.Destination;
                    }
                    // If the remap is not bundled, resolve as free asset
                    if (!path.StartsWith("@/"))
                    {
                        bundled = false;
                    }
                }
            }

            if (bundled)
            {
                return ResolveBundledAsset(path);
            }

            var freeAsset = ResolveFreeAsset(path, basePath);
            if (freeAsset == null)
            {
                throw new SourceAssetNotFoundException(path, new[] { basePath });
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
            if (isAbsoluteImport)
            {
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
            return GetORLTemplate(path, null);
        }

        public static string[] GetORLTemplate(string path, List<ModuleRemap> remaps)
        {
            var fullPath = ResolveORLAsset(path, true, remaps);
            return File.ReadAllLines(fullPath);
        }

        public static string[] GetORLSource(string path)
        {
            return GetORLSource(path, null);
        }

        public static string[] GetORLSource(string path, List<ModuleRemap> remaps)
        {
            var fullPath = ResolveORLAsset(path, true, remaps);
            return File.ReadAllLines(fullPath);
        }
        
        public static string[] GetORLSource(string path, List<ModuleRemap> remaps, out string fullPath)
        {
            fullPath = ResolveORLAsset(path, true, remaps);
            return File.ReadAllLines(fullPath);
        }

        public static string[] GetAssetSource(string path, string basePath)
        {
            return File.ReadAllLines(ResolveORLAsset(path, path.StartsWith("@/"), basePath));
        }

        public static string[] GetAssetSource(string path, string basePath, List<ModuleRemap> remaps)
        {
            return File.ReadAllLines(ResolveORLAsset(path, path.StartsWith("@/"), remaps, basePath));
        }
        
        public static string[] GetAssetSource(string path, string basePath, List<ModuleRemap> remaps, out string fullPath)
        {
            fullPath = ResolveORLAsset(path, path.StartsWith("@/"), remaps, basePath);
            return File.ReadAllLines(fullPath);
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
            RecursivelyCollectDependencies(sourceList, ref dependencies, basePath, null);
        }

        public static void RecursivelyCollectDependencies(List<string> sourceList, ref List<string> dependencies, string basePath, List<ModuleRemap> remaps)
        {
            var parser = new Parser();
            foreach (var source in sourceList)
            {
                var sourceContents = GetAssetSource(source, basePath, remaps, out var fullPath);
                var blocks = parser.Parse(sourceContents, fullPath);
                var includesBlockIndex = blocks.FindIndex(b => b.CoreBlockType == ShaderBlock.BlockType.Includes);
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
                        RecursivelyCollectDependencies(new List<string> { depPath }, ref deepDeps, basePath, remaps);
                        dependencies.AddRange(deepDeps);
                    }
                }
            }
        }

        public static string IndentContents(List<string> contents, int indentLevel)
        {
            var sb = new StringBuilder();
            var i = 0;
            foreach (var contentLine in contents)
            {
                if (i == 0)
                {
                    sb.Append(contentLine + (contents.Count == 1 ? "" : "\n"));
                    i++;
                    continue;
                }

                if (i == contents.Count - 1)
                {
                    sb.Append(new string(' ', indentLevel) + contentLine);
                }
                else
                {
                    sb.Append(new string(' ', indentLevel) + contentLine + '\n');
                }

                i++;
            }

            return sb.ToString();
        }
    }
}