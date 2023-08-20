using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEditor.Experimental.AssetImporters;

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