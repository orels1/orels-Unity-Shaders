using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
#if UNITY_2022_3_OR_NEWER
using UnityEditor.AssetImporters;
#else
using UnityEditor.Experimental.AssetImporters;
#endif

namespace ORL.ShaderGenerator
{
    [ScriptedImporter(1, "orlconfshader")]
    public class ConfiguredShaderDefinitionImporter: ShaderDefinitionImporter
    {
        public string shaderName = "Configurable/NewShader";
        public string lightingModel;
        public string baseShader;
        public List<string> modules = new List<string>
        {
            "@/Modules/BaseColor"
        };
        
        public override void OnImportAsset(AssetImportContext ctx)
        {
            var generated = new StringBuilder();
            generated.AppendLine($@"%ShaderName(""{shaderName}"")");
            if (!string.IsNullOrWhiteSpace(lightingModel) && string.IsNullOrWhiteSpace(baseShader))
            {
                generated.AppendLine($@"%LightingModel(""{lightingModel}"")");
            }
            generated.AppendLine(@"%CustomEditor(""ORL.ShaderInspector.InspectorGUI"")");
            generated.AppendLine();
            generated.AppendLine("%Includes()");
            generated.AppendLine("{");
            if (!string.IsNullOrWhiteSpace(baseShader))
            {
                generated.AppendLine($@"    ""{baseShader}"",");
            }

            foreach (var module in modules)
            {
                generated.AppendLine($@"    ""{module}"",");
            }

            generated.AppendLine(@"    ""self""");
            generated.AppendLine("}");

            var finalCode = generated.ToString();
            if (!finalCode.Equals(File.ReadAllText(ctx.assetPath), StringComparison.InvariantCulture))
            {
                File.WriteAllText(ctx.assetPath, finalCode);
            }
            base.OnImportAsset(ctx);
        }
    }
}