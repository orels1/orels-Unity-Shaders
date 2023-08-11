using UnityEditor;
using UnityEngine;

namespace ORL.ShaderGenerator
{
    public class ORLAssetPostProcessor : AssetPostprocessor
    {
        private static void OnPostprocessAllAssets(string[] importedAssets, string[] deletedAssets, string[] movedAssets,
            string[] movedFromAssetPaths)
        {
            SetupORLShaders(importedAssets);
        }

        private static void SetupORLShaders(string[] assets)
        {
            foreach (var asset in assets)
            {
                if (!asset.EndsWith(".orlshader") && !asset.EndsWith(".orlconfshader")) continue;

                var shader = AssetDatabase.LoadAssetAtPath<Shader>(asset);
                if (shader == null) {
                    continue;
                }
                ShaderUtil.ClearShaderMessages(shader);
                if (!ShaderUtil.ShaderHasError(shader))
                {
                    ShaderUtil.RegisterShader(shader);
                }
            }
        }
    }
}