using System.IO;
using System.Linq;
using UnityEngine;
using UnityEditor;
using UnityShaderParser;
using UnityShaderParser.Common;
using UnityShaderParser.HLSL;
using UnityShaderParser.ShaderLab;
using UnityShaderParser.HLSL.PreProcessor;
using System.Collections.Generic;
using System.Text;
using ORL.ShaderGenerator;

namespace ORL.Tools
{
    public class VRCLVImporter
    {
        // TODO: can probably remove this, the new structure isnt very v2 compatible
        // [MenuItem("Tools/orels1/Import and Parse VRC Light Volumes v2")]
        // public static void ImportAndParseV2()
        // {
        //     ImportAndParse(2);
        // }

        [MenuItem("Tools/orels1/Import and Parse VRC Light Volumes v3")]
        public static void ImportAndParseV3()
        {
            ImportAndParse(3);
        }

        public static void ImportAndParse(int version)
        {
            var projectPath = Application.dataPath.Replace("/Assets", "");
            if (!Directory.Exists(Path.Combine(projectPath, "Temp", "VRCLV")))
            {
                Directory.CreateDirectory(Path.Combine(projectPath, "Temp", "VRCLV"));
            }

            string lvText = null;

            if (!File.Exists(Path.Combine(projectPath, "Temp", "VRCLV", "LightVolumes.cginc")))
            {
                Debug.Log("No VRCLightVolumes include found, downloading...");
                var branch = version == 3 ? "lv-3" : "main";
                var url = $"https://github.com/REDSIM/VRCLightVolumes/raw/refs/heads/{branch}/Packages/red.sim.lightvolumes/Shaders/LightVolumes.cginc";
                var client = new System.Net.Http.HttpClient();
                var response =
                    client.GetAsync(url);
                response.Wait(5000);
                if (response.IsCompletedSuccessfully)
                {
                    lvText = response.Result.Content.ReadAsStringAsync().Result;
                    File.WriteAllText(Path.Combine(projectPath, "Temp", "VRCLV", "LightVolumes.cginc"), lvText);
                    Debug.Log("VRCLightVolumes include downloaded");
                }
                else
                {
                    Debug.LogError("Failed to download VRCLV");
                    return;
                }
            }
            else
            {
                Debug.Log("VRCLightVolumes include found");
                lvText = File.ReadAllText(Path.Combine(projectPath, "Temp", "VRCLV", "LightVolumes.cginc"));
            }


            Debug.Log("Parsing LightVolumes.cginc");
            var nodes = ShaderParser.ParseTopLevelDeclarations(lvText, new ShaderLabParserConfig
            {
                IncludeResolver = new DefaultPreProcessorIncludeResolver(new List<string>
                {
                    Path.Combine(EditorApplication.applicationContentsPath, "CGIncludes")
                }),
                PreProcessorMode = PreProcessorMode.ExpandAllExceptIncludes,
                Defines = new Dictionary<string, string>()
            });
            var uniformVisitor = new UniformVisitor(lvText);
            uniformVisitor.VisitMany(nodes);


            var template = Resources.Load<TextAsset>("VRCLVImporterTemplate");

            // Variables
            var variablesBlock = new StringBuilder();
            variablesBlock.AppendLine("%Variables()");
            variablesBlock.AppendLine("{");
            variablesBlock.AppendLine("    #if defined(INTEGRATE_VRCLIGHTVOLUMES)");
            variablesBlock.AppendLine("    float _VRCLightVolumesSurfacePushoff;");
            variablesBlock.AppendLine();
            variablesBlock.AppendLine("    cbuffer LightVolumeUniforms {");
            foreach (var variable in uniformVisitor.Variables)
            {
                variablesBlock.AppendLine($"        {variable};");
                variablesBlock.AppendLine();
            }
            variablesBlock.AppendLine("    }");
            variablesBlock.AppendLine("    #endif");
            variablesBlock.AppendLine("}");

            // Textures
            var texturesBlock = new StringBuilder();
            texturesBlock.AppendLine("%Textures()");
            texturesBlock.AppendLine("{");
            texturesBlock.AppendLine("    #if defined(INTEGRATE_VRCLIGHTVOLUMES)");
            foreach (var texture in uniformVisitor.Textures)
            {
                texturesBlock.AppendLine($"    {texture};");
            }
            foreach (var sampler in uniformVisitor.Samplers)
            {
                texturesBlock.AppendLine($"    {sampler};");
            }
            texturesBlock.AppendLine("    #define LV_SAMPLE(tex, uvw) tex.SampleLevel(sampler_UdonLightVolume, uvw, 0)");
            if (version == 3)
            {
                texturesBlock.AppendLine("    #define LV_SAMPLE_POINT(uvw) _UdonPointLightVolumeTexture.SampleLevel(sampler_UdonPointLightVolumeTexture, uvw, 0)");
                texturesBlock.AppendLine("    #define LV_SAMPLE_POINT_LOD(uvw, lod) _UdonPointLightVolumeTexture.SampleLevel(sampler_UdonPointLightVolumeTexture, uvw, lod)");
                texturesBlock.AppendLine("    #define LV_SAMPLE_SHADOW(uvw) _UdonPointLightVolumeShadowTexture.SampleLevel(sampler_UdonPointLightVolumeShadowTexture, uvw, 0)");
            }
            texturesBlock.AppendLine("    #endif");
            texturesBlock.AppendLine("}");

            // Functions
            var functionVisitor = new FunctionVisitor(lvText);
            functionVisitor.VisitMany(nodes);

            var functionsBlock = new StringBuilder();
            functionsBlock.AppendLine("%PassFunctions()");
            functionsBlock.AppendLine("{");
            functionsBlock.AppendLine("    #if defined(INTEGRATE_VRCLIGHTVOLUMES)");
            functionsBlock.AppendLine();
            foreach (var function in functionVisitor.Functions)
            {
                var indentend = "    " + function;
                functionsBlock.AppendLine(Utils.IndentContents(indentend.Split(new string[] { "\n", "\r\n" }, System.StringSplitOptions.None).ToList(), 4));
                functionsBlock.AppendLine();
            }
            functionsBlock.AppendLine("    #endif");
            functionsBlock.AppendLine("}");

            var finalModule = template.text;
            finalModule = finalModule.Replace("%%VARIABLES", variablesBlock.ToString());
            finalModule = finalModule.Replace("%%TEXTURES", texturesBlock.ToString());
            finalModule = finalModule.Replace("%%FUNCTIONS", functionsBlock.ToString());

            // File.WriteAllText(Path.Combine(projectPath, "Temp", "VRCLV", "VRCLightVolumes.orlsource"), finalModule);
            File.WriteAllText(Path.Combine(projectPath, "Packages", "sh.orels.shaders.generator", "Runtime", "Sources", "Modules", "VRCLightVolumes.orlsource"), finalModule);

            Debug.Log("VRCLightVolumes.orlsource generated");

            File.Delete(Path.Combine(projectPath, "Temp", "VRCLV", "LightVolumes.cginc"));

            Debug.Log("LightVolumes.cginc deleted");
        }
    }

    internal class UniformVisitor : HLSLSyntaxVisitor<VariableDeclarationStatementNode>
    {
        private string _contents;

        public List<string> Variables = new List<string>();
        public List<string> Textures = new List<string>();
        public List<string> Samplers = new List<string>();

        public UniformVisitor(string contents = null) : base()
        {
            _contents = contents;
        }

        public override VariableDeclarationStatementNode VisitVariableDeclarationStatementNode(VariableDeclarationStatementNode node)
        {
            // Debug.Log($"Variable: {node.Declarators[0].Name}: {string.Join(", ", node.Modifiers)}");
            if (node.Modifiers.Contains(BindingModifier.Uniform))
            {
                var declaration = _contents.Substring(node.Declarators[0].OriginalSpan.StartIndex, node.Declarators[0].OriginalSpan.Length);
                var type = _contents.Substring(node.Kind.OriginalSpan.StartIndex, node.Kind.OriginalSpan.Length);

                if (node.Kind is PredefinedObjectTypeNode objectTypeNode)
                {
                    if (objectTypeNode.Kind == PredefinedObjectType.Texture2D)
                    {
                        Textures.Add($"TEXTURE2D({declaration})");
                    }
                    else if (objectTypeNode.Kind == PredefinedObjectType.Texture2DArray)
                    {
                        Textures.Add($"TEXTURE2D_ARRAY({declaration})");
                    }
                    else if (objectTypeNode.Kind == PredefinedObjectType.Texture3D)
                    {
                        Textures.Add($"TEXTURE3D({declaration})");
                    }
                    else if (objectTypeNode.Kind == PredefinedObjectType.SamplerState)
                    {
                        Samplers.Add($"SAMPLER({declaration})");
                    }
                }
                else
                {
                    Variables.Add($"{type} {declaration}");
                }
            }
            return node;
        }
    }

    internal class FunctionVisitor : HLSLSyntaxVisitor<FunctionDefinitionNode>
    {
        private string _contents;

        public List<string> Functions = new List<string>();

        public FunctionVisitor(string contents = null) : base()
        {
            _contents = contents;
        }

        public override FunctionDefinitionNode VisitFunctionDefinitionNode(FunctionDefinitionNode node)
        {
            var source = _contents.Substring(node.OriginalSpan.StartIndex, node.OriginalSpan.Length);
            Functions.Add(source);
            // Debug.Log($"Function: {node.Name.GetName()}");
            return node;
        }
    }
}
