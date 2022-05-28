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
        }
    }
}