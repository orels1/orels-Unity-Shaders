using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using ORL.ShaderGenerator.Tools.SurfaceShaders;
using Unity.Properties;
using UnityEditor;
using UnityEditor.Graphs;
using UnityEngine;
using UnityShaderParser.Common;
using UnityShaderParser.HLSL;
using UnityShaderParser.HLSL.PreProcessor;
using UnityShaderParser.ShaderLab;
using TokenKind = UnityShaderParser.HLSL.TokenKind;

namespace ORL.ShaderGenerator.Tools
{
    public class SurfaceShaderConverter: EditorWindow
    {
        [MenuItem("Tools/orels1/Convert Surface Shader")]
        private static void ShowWindow()
        {
            var window = GetWindow<SurfaceShaderConverter>(true);
            window.titleContent = new GUIContent("ORL Shader Converter");
            window.Show();
        }

        private Shader source;

        private void OnGUI()
        {
            source = EditorGUILayout.ObjectField("Source", source, typeof(Shader), false) as Shader;
            if (source == null) return;
            if (GUILayout.Button("Convert"))
            {
                ConvertShader(source);
            }
        }

        public struct PragmaInfo
        {
            public string SurfaceFnName;
            public string VertexFnName;
            public string LightingModel;
            public List<string> ShaderFeatures;
            public List<string> MultiCompiles;
        }

        private void ConvertShader(Shader source)
        {
            var path = AssetDatabase.GetAssetPath(source);
            var config = new ShaderLabParserConfig
            {
                IncludeResolver = new DefaultPreProcessorIncludeResolver(new List<string>
                {
                    Path.Combine(UnityEditor.EditorApplication.applicationContentsPath, "CGIncludes")
                }),
                PreProcessorMode = PreProcessorMode.ExpandMacroInvocationsAndPragmas,
                Defines = new Dictionary<string, string>
                {
                    {"SHADER_API_D3D11", "1"},
                    { "INTERNAL_DATA", "" },
                    {"UNITY_VERTEX_OUTPUT_STEREO", ""},
                    {"UNITY_VERTEX_INPUT_INSTANCE_ID", ""},
                    {"UNITY_INSTANCING_BUFFER_START(Props)", ""},
                    {"UNITY_INSTANCING_BUFFER_END(Props)", ""},
                }
            };

            var sourceText = File.ReadAllText(path);
            var parser = ShaderParser.ParseUnityShader(sourceText, config);
            var properties = parser.Properties.Select(p => p.Uniform).ToList();
            var subshader = parser.SubShaders[0];
            var pragmaInfo = GetPragmaInfo(subshader.ProgramBlock.Value.Pragmas);
            var visitor = new PassVisitor(properties, pragmaInfo);

            var hasPasses = subshader.Passes.Count > 0;
            var hasLightModeFowardBasePass = false;
            if (hasPasses)
            {
                hasLightModeFowardBasePass = (subshader.Passes[0] as ShaderCodePassNode).Commands.Any(c =>
                {
                    if (c is ShaderLabCommandTagsNode tags)
                    {
                        if (!tags.Tags.ContainsKey("LightMode")) return true;
                        return tags.Tags.ContainsValue("ForwardBase");
                    }

                    return false;
                });
            }
            if (!hasPasses || !hasLightModeFowardBasePass)
            {
                // var cleanPass =
                //     ShaderParser.ParseUnityShaderPass(subshader.ProgramBlock.Value.CodeWithoutIncludes);
                visitor.VisitMany(subshader.ProgramBlock.Value.TopLevelDeclarations);
                if (visitor.surfaceFunction != null)
                {
                    // The variable name used for the surface input
                    var surfInName = visitor.surfaceFunction.Parameters
                        .Find(p => (p.ParamType as NamedTypeNode).Name.Identifier == "Input").Declarator.Name
                        .Identifier;
                    visitor.surfaceInputStruct = visitor.structs.Find(s => s.Name.GetName() == "Input");
                    visitor.surfaceInputName = surfInName;
                }

                if (visitor.vertexFunction != null)
                {
                    // The variable name used for the surface input
                    var vertexStructTypeName = (visitor.vertexFunction.Parameters
                        .Find(p => p.Modifiers[0] == BindingModifier.Inout).ParamType as NamedTypeNode)
                        .Name.Identifier;
                    visitor.vertexInputStruct = visitor.structs.Find(s => s.Name.GetName() == vertexStructTypeName);
                }
                
                var surfaceOutputStructNode =
                    visitor.surfaceFunction.Parameters.Find(p => p.Modifiers.Count > 0 && p.Modifiers[0] == BindingModifier.Inout);
                var surfaceOutputStructType = (surfaceOutputStructNode.ParamType as NamedTypeNode).Name.Identifier;

                var passFunctions = new List<FunctionDefinitionNode>();
                foreach (var fn in visitor.functions)
                {
                    if (fn == visitor.surfaceFunction || fn == visitor.vertexFunction) continue;
                    passFunctions.Add(fn);
                }

                var assemblerData = new ShaderAssemblerData
                {
                    ShaderNode = parser,
                    PragmaInfo = pragmaInfo,
                    Textures = visitor.textures,
                    Variables = visitor.variables,
                    SurfaceFunction = visitor.surfaceFunction,
                    VertexFunction = visitor.vertexFunction,
                    PassFunctions = passFunctions,
                    Includes = visitor.includes,
                    Defines = visitor.defines,
                    SurfaceInputStruct = visitor.surfaceInputStruct,
                    VertexInputStruct = visitor.vertexInputStruct,
                    SurfaceInputName = visitor.surfaceInputName,
                    LightingModel = SurfaceShaderMappings.LightingModelMappings[pragmaInfo.LightingModel],
                    SurfaceInputMappings = SurfaceShaderMappings.SurfaceInputMappings,
                    SurfaceOutputMappings = SurfaceShaderMappings.OutputMappings[surfaceOutputStructType],
                    VertexInputMappings = SurfaceShaderMappings.VertexInputMappings,
                    Source = sourceText
                };
                var result = ShaderAssembler.AssembleORLShader(assemblerData);
                File.WriteAllText(path.Replace(".shader", ".orlshader"), result);
                AssetDatabase.Refresh();
            }
        }

        private PragmaInfo GetPragmaInfo(List<string> pragmas)
        {
            var surfacePragma = pragmas.Find(p => p.StartsWith("surface"));
            var splitPragma = surfacePragma.Split(" ", StringSplitOptions.RemoveEmptyEntries);
            var surfaceFunctionName = splitPragma[1];
            
            var lightingModel = splitPragma[2];
            
            var vertexFunctionIndex = Array.IndexOf(splitPragma, "vertex");
            string vertexFunctionName = null;
            if (vertexFunctionIndex != -1 && splitPragma[vertexFunctionIndex + 1] == ":")
            {
                vertexFunctionName = splitPragma[vertexFunctionIndex + 2];
            }

            var shaderFeatures = new List<string>();
            var multiCompiles = new List<string>();
            foreach (var pragma in pragmas)
            {
                if (pragma.StartsWith("shader_feature"))
                {
                    shaderFeatures.Add(pragma);
                    continue;
                }

                if (pragma.StartsWith("multi_compile"))
                {
                    multiCompiles.Add(pragma);
                }
            }

            return new PragmaInfo
            {
                SurfaceFnName = surfaceFunctionName,
                VertexFnName = vertexFunctionName,
                LightingModel = lightingModel,
                ShaderFeatures =  shaderFeatures,
                MultiCompiles = multiCompiles,
            };
        }
        
    }
}