using System.Linq;
using ORL.ModularShaderSystem;
using UnityEditor;
using UnityEngine;

namespace ORL
{
    public class ORLShaderPostProcessor : AssetPostprocessor
    {
        public static void OnPostprocessAllAssets(string[] importedAssets, string[] deletedAssets, string[] movedAssets,
            string[] movedFromAssetPath)
        {
            var shaderList = Resources.Load<ORLShaderList>("ORLShaderList");
            if (shaderList == null) return;
            foreach (var asset in importedAssets)
            {
                if (!asset.EndsWith(".orlshader")) continue;
                if (!shaderList.shadersList.ContainsKey(asset)) continue;
                var shaderDefinition = AssetDatabase.LoadAssetAtPath<ORLShaderDefinition>(asset);
                if (shaderDefinition == null || shaderDefinition.GeneratedShader == null) continue;
                var filename = asset;
                filename = filename.Replace('\\', '/');
                filename = filename.Substring(filename.LastIndexOf("/") + 1);
                filename = filename.Replace(".orlshader", "");
                ShaderGenerator.GenerateShader(shaderList.shadersList[asset], shaderDefinition.GeneratedShader, filename);
            }

            var shouldSave = false;
            for (int i = 0; i < movedAssets.Length; i++)
            {
                var newPath = movedAssets[i];
                var oldPath = movedFromAssetPath[i];
                if (newPath.EndsWith(".orlshader"))
                {
                    if (!shaderList.shadersList.ContainsKey(oldPath)) continue;
                    var value = shaderList.shadersList[oldPath];
                    shaderList.shadersList.Remove(oldPath);
                    shaderList.shadersList.Add(newPath, value);
                    shouldSave = true;
                }

                if (newPath.EndsWith(".shader"))
                {
                    var oldFolder = oldPath.Substring(0, oldPath.LastIndexOf("/"));
                    if (!shaderList.shadersList.ContainsValue(oldFolder)) continue;
                    var parent = shaderList.shadersList.FirstOrDefault(entry => entry.Value == oldFolder).Key;
                    var newFolder = newPath.Substring(0, newPath.LastIndexOf("/"));
                    shaderList.shadersList[parent] = newFolder;
                    shouldSave = true;
                }
                
            }

            foreach (var asset in deletedAssets)
            {
                if (!asset.EndsWith(".orlshader")) continue;
                if (!shaderList.shadersList.ContainsKey(asset)) continue;
                shaderList.shadersList.Remove(asset);
                shouldSave = true;
            }

            if (!shouldSave) return;
            EditorUtility.SetDirty(shaderList);
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
        }
    }
}