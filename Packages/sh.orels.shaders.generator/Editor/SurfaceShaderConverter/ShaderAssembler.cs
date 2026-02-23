using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NUnit;
using UnityEngine;
using UnityShaderParser.Common;
using UnityShaderParser.HLSL;
using UnityShaderParser.HLSL.PreProcessor;
using UnityShaderParser.ShaderLab;

namespace ORL.ShaderGenerator.Tools.SurfaceShaders
{
    public struct ShaderAssemblerData
    {
        public List<VariableDeclarationStatementNode> Textures { get; set; }
        public List<VariableDeclarationStatementNode> Variables { get; set; }
        public FunctionDefinitionNode SurfaceFunction { get; set; }
        public FunctionDefinitionNode VertexFunction { get; set; }
        public StructTypeNode SurfaceInputStruct { get; set; }
        public StructTypeNode VertexInputStruct { get; set; }
        public List<FunctionDefinitionNode> PassFunctions { get; set; }
        public List<IncludeDirectiveNode> Includes { get; set; }
        public List<string> Defines { get; set; }
        public SurfaceShaderConverter.PragmaInfo PragmaInfo { get; set; }
        public string SurfaceInputName;
        public ShaderNode ShaderNode { get; set; }
        public string LightingModel { get; set; }
        public string Source { get; set; }
        public Dictionary<string, string> VertexInputMappings { get; set; }
        public Dictionary<string, string> SurfaceInputMappings { get; set; }
        public Dictionary<string, string> SurfaceOutputMappings { get; set; }
    }
    
    public static class ShaderAssembler
    {
        private static void InjectShaderBlock(StringBuilder target, ShaderAssemblerData data, string blockName,
            Action<StringBuilder, ShaderAssemblerData> contentFn = null, params string[] blockParameters)
        {
            target.Append("%");
            target.Append(blockName);
            target.Append("(");
            if (blockParameters != null)
            {
                for (var i = 0; i < blockParameters.Length; i++)
                {
                    target.Append(blockParameters[i]);
                    if (i < blockParameters.Length - 1)
                    {
                        target.Append(", ");
                    }
                }
            }
            target.AppendLine(")");
            
            if (contentFn == null) return;
            
            target.AppendLine("{");
            contentFn?.Invoke(target, data);
            target.AppendLine("}");
        }
        
        public static string AssembleORLShader(ShaderAssemblerData data)
        {
            // var passSource = node.SubShaders[0].ProgramBlock.Value.FullCode;
            var sb = new StringBuilder();
            InjectShaderBlock(sb, data, "ShaderName", null, $"\"Converted/{data.ShaderNode.Name}\"");
            InjectShaderBlock(sb, data, "LightingModel",null,$"\"{data.LightingModel}\"");
            InjectShaderBlock(sb, data, "CustomEditor",null,"\"ORL.ShaderInspector.InspectorGUI\"");
            
            sb.AppendLine();
            
            InjectShaderBlock(sb, data, "Properties", CreateProperties);
            
            sb.AppendLine();
            
            if (data.Includes?.Count > 0)
            {
                var nativeIncludes = new List<IncludeDirectiveNode>();
                var rawIncludes = new List<IncludeDirectiveNode>();
                foreach (var inc in data.Includes)
                {
                    // we skip this one for obvious reasons
                    if (inc.Path == "UnityCG.cginc") continue;
                    if (inc.Path.Trim().EndsWith("AudioLink.cginc"))
                    {
                        nativeIncludes.Add(inc);
                        continue;
                    }
                    rawIncludes.Add(inc);
                }
                
                InjectShaderBlock(sb, data, "Includes", (builder, _) =>
                {
                    foreach (var inc in nativeIncludes)
                    {
                        if (inc.Path.Trim().EndsWith("AudioLink.cginc"))
                        {
                            builder.Append("    ");
                            builder.AppendLine("\"@/Modules/AudioLink\",");
                        }
                    }
                    
                    builder.Append("    ");
                    builder.AppendLine("\"self\"");
                });
                
                sb.AppendLine();

                if (rawIncludes.Count > 0)
                {
                    InjectShaderBlock(sb, data, "ShaderDefines", (builder, _) =>
                    {
                        foreach (var inc in rawIncludes)
                        {
                            builder.Append("    ");
                            builder.AppendLine(inc.GetPrettyPrintedCode().Trim());
                        }
                    });
                    sb.AppendLine();
                }
            }

            if (data.Defines?.Count > 0)
            {
                InjectShaderBlock(sb, data, "ShaderDefines", (builder, _) =>
                {
                    foreach (var define in data.Defines)
                    {
                        builder.Append("    ");
                        builder.AppendLine(define);
                    }
                });
                sb.AppendLine();
            }
            
            InjectShaderBlock(sb, data, "Textures", CreateTextures);

            sb.AppendLine();
            
            InjectShaderBlock(sb, data, "Variables", CreateVariables);
            
            sb.AppendLine();

            HandleInputStruct(sb, data);

            if (data.PassFunctions?.Count > 0)
            {
                InjectShaderBlock(sb, data, "PassFunctions", CreatePassFunctions);
                sb.AppendLine();
            }

            if (data.PragmaInfo.ShaderFeatures.Count > 0 || data.PragmaInfo.MultiCompiles.Count > 0)
            {
                InjectShaderBlock(sb, data, "ShaderFeatures", CreateShaderFeatures);
                sb.AppendLine();
            }
            
            if (data.VertexFunction != null)
            {
                var fnName = $"VertexFn_{data.VertexFunction.Name.GetName()}_Vertex";
                InjectShaderBlock(sb, data, "Vertex", (target, data) => { CreateVertex(target, data, fnName); }, $"\"{fnName}\"");
                sb.AppendLine();
            }

            if (data.SurfaceFunction != null)
            {
                var fnName = $"SurfaceFn_{data.SurfaceFunction.Name.GetName()}_Fragment";
                InjectShaderBlock(sb, data, "Fragment", (target, data) => { CreateFragment(target, data, fnName); }, $"\"{fnName}\"");
                sb.AppendLine();
            }
            
            // Debug.Log($"Assembled Shader: {sb}");

            return sb.ToString();
        }

        private static void CreatePassFunctions(StringBuilder target, ShaderAssemblerData data)
        {
            foreach (var fn in data.PassFunctions)
            {
                // First pass - rewrite texture sampling
                var functionSource = fn.GetPrettyPrintedCode();
                var functionTokens = ShaderParser.ParseTopLevelDeclarations(functionSource, new HLSLParserConfig(), out _, out _);
            
                var functionEditor = new FunctionRewriter(
                    FunctionRewriter.FunctionType.Surface, 
                    FunctionRewriter.RewriteType.TextureCalls,
                    data,
                    functionSource,
                    functionTokens.SelectMany(x => x.Tokens).ToList()
                );
                var edited = functionEditor.ApplyEdits(functionTokens);
                    
                // Second pass - rewrite field access
                functionTokens = ShaderParser.ParseTopLevelDeclarations(edited, new HLSLParserConfig(), out _, out _);
                functionEditor = new FunctionRewriter(
                    FunctionRewriter.FunctionType.Surface,
                    FunctionRewriter.RewriteType.FieldAccess,
                    data,
                    edited,
                    functionTokens.SelectMany(x => x.Tokens).ToList()
                );
                edited = functionEditor.ApplyEdits(functionTokens);
                    
                var split = edited.Split(Environment.NewLine);
                //target.AppendLine(edited);
                InsertIndentedContents(target, split, 0, 0, 0);
            }
        }

        private static void HandleInputStruct(StringBuilder target, ShaderAssemblerData data)
        {
            var extraV2FFields = new List<VariableDeclarationStatementNode>();
            foreach (var field in data.SurfaceInputStruct.Fields)
            {
                // if we can map to the built-in structs - leave as is
                if (SurfaceShaderMappings.SurfaceInputMappings.ContainsKey(field.Declarators[0].Name.Identifier))
                {
                    continue;
                }
                
                // Otherwise - collect those fields to be passed through v2f
                extraV2FFields.Add(field);
            }

            if (extraV2FFields.Count == 0) return;
            
            InjectShaderBlock(target, data, "AdditionalFragmentData", (builder, _) =>
            {
                foreach (var field in extraV2FFields)
                {
                    builder.Append("    ");
                    builder.Append(field.Kind.GetPrettyPrintedCode().Trim());
                    builder.Append(" ");
                    builder.Append(field.Declarators[0].Name.Identifier);
                    builder.Append(" : ");
                    // Prefix everything to avoid any conflicts
                    builder.Append("ORL_C_");
                    builder.Append(field.Declarators[0].Name.Identifier.ToUpperInvariant());
                    builder.AppendLine(";");
                }
            });
            
            target.AppendLine();
            
            InjectShaderBlock(target, data, "AdditionalMeshData", (builder, _) =>
            {
                foreach (var field in extraV2FFields)
                {
                    builder.Append("    ");
                    builder.AppendLine(field.GetPrettyPrintedCode().Trim());
                }
            });
            
            target.AppendLine();
            
            InjectShaderBlock(target, data, "AdditionalMeshDataCreator", (builder, _) =>
            {
                foreach (var field in extraV2FFields)
                {
                    builder.Append("    ");
                    builder.Append("d.");
                    builder.Append(field.Declarators[0].Name.Identifier);
                    builder.Append(" = i.");
                    builder.Append(field.Declarators[0].Name.Identifier);
                    builder.AppendLine(";");
                }
            });

            target.AppendLine();
        }

        private static void CreateShaderFeatures(StringBuilder target, ShaderAssemblerData data)
        {
            foreach (var feature in data.PragmaInfo.ShaderFeatures)
            {
                target.Append("    ");
                target.Append("#pragma ");
                target.AppendLine(feature);
            }

            foreach (var multiCompile in data.PragmaInfo.MultiCompiles)
            {
                target.Append("    ");
                target.Append("#pragma ");
                target.AppendLine(multiCompile);
            }
        }

        private static void CreateVertex(StringBuilder target, ShaderAssemblerData data, string fnName)
        {
            target.Append("    ");
            InsertVertexFn(target, fnName);

            var config = new HLSLParserConfig
            {
                PreProcessorMode = PreProcessorMode.ExpandMacroInvocationsAndPragmas,
            };

            // First pass - rewrite texture sampling
            var functionSource = data.VertexFunction.GetPrettyPrintedCode();
            var functionTokens = ShaderParser.ParseTopLevelDeclarations(functionSource, config, out _, out _);
            var functionEditor = new FunctionRewriter(
                FunctionRewriter.FunctionType.Vertex,
                FunctionRewriter.RewriteType.TextureCalls,
                data,
                functionSource,
                functionTokens.SelectMany(x => x.Tokens).ToList()
            );
            var edited = functionEditor.ApplyEdits(functionTokens);
                
            // Second pass - rewrite field access
            functionTokens = ShaderParser.ParseTopLevelDeclarations(edited, config, out _, out _);
            functionEditor = new FunctionRewriter(
                FunctionRewriter.FunctionType.Vertex,
                FunctionRewriter.RewriteType.FieldAccess,
                data,
                edited,
                functionTokens.SelectMany(x => x.Tokens).ToList()
            );
            edited = functionEditor.ApplyEdits(functionTokens);
            
            // Third pass - rewrite raw identifiers
            functionTokens = ShaderParser.ParseTopLevelDeclarations(edited, config, out _, out _);
            functionEditor = new FunctionRewriter(
                FunctionRewriter.FunctionType.Vertex,
                FunctionRewriter.RewriteType.Identifiers,
                data,
                edited,
                functionTokens.SelectMany(x => x.Tokens).ToList()
            );
            edited = functionEditor.ApplyEdits(functionTokens);
            
            functionTokens = ShaderParser.ParseTopLevelDeclarations(edited, config, out _, out _);
            var pretty = (functionTokens[0] as FunctionDefinitionNode).Body.GetPrettyPrintedCode();
            pretty = string.Join(Environment.NewLine, pretty.Split(Environment.NewLine).Select(l => l.PadLeft(4)));
            target.Append(" ");
            target.AppendLine(pretty);
        }

        private static void CreateFragment(StringBuilder target, ShaderAssemblerData data, string fnName)
        {
            target.Append("    ");
            InsertFragmentFn(target, fnName);
            // target.AppendLine("    {");
            
            var config = new HLSLParserConfig
            {
                PreProcessorMode = PreProcessorMode.ExpandMacroInvocationsAndPragmas,
            };

            // First pass - rewrite texture sampling
            var functionSource = data.SurfaceFunction.GetPrettyPrintedCode();
            var functionTokens = ShaderParser.ParseTopLevelDeclarations(functionSource, config, out _, out _);
            
            var functionEditor = new FunctionRewriter(
                FunctionRewriter.FunctionType.Surface, 
                FunctionRewriter.RewriteType.TextureCalls,
                data,
                functionSource,
                functionTokens.SelectMany(x => x.Tokens).ToList()
            );
            var edited = functionEditor.ApplyEdits(functionTokens);
                    
            // Second pass - rewrite field access
            functionTokens = ShaderParser.ParseTopLevelDeclarations(edited, config, out _, out _);
            functionEditor = new FunctionRewriter(
                FunctionRewriter.FunctionType.Surface,
                FunctionRewriter.RewriteType.FieldAccess,
                data,
                edited,
                functionTokens.SelectMany(x => x.Tokens).ToList()
            );
            edited = functionEditor.ApplyEdits(functionTokens);
            
            // Third pass - rewrite raw identifiers
            functionTokens = ShaderParser.ParseTopLevelDeclarations(edited, config, out _, out _);
            functionEditor = new FunctionRewriter(
                FunctionRewriter.FunctionType.Surface,
                FunctionRewriter.RewriteType.Identifiers,
                data,
                edited,
                functionTokens.SelectMany(x => x.Tokens).ToList()
            );
            edited = functionEditor.ApplyEdits(functionTokens);
            
            functionTokens = ShaderParser.ParseTopLevelDeclarations(edited, config, out _, out _);
            var pretty = (functionTokens[0] as FunctionDefinitionNode).Body.GetPrettyPrintedCode();
            pretty = string.Join(Environment.NewLine, pretty.Split(Environment.NewLine).Select(l => l.PadLeft(4)));
            target.Append(" ");
            target.AppendLine(pretty);
        }

        private static void InsertIndentedContents(StringBuilder target, string[] split, int indentationLevel = 2, int startOffset = 1, int endOffset = 1)
        {
            foreach (var line in split[startOffset..^endOffset])
            {
                for (var i = 0; i < indentationLevel; i++)
                {
                    target.Append("    ");
                }
                target.AppendLine(line.Trim());
            }
        }
        
        private static void InsertVertexFn(StringBuilder target, string fnName)
        {
            target.Append("void ");
            target.Append(fnName);
            target.AppendLine("(inout VertexData v, inout FragmentData o)");
        }

        private static void InsertFragmentFn(StringBuilder target, string fnName)
        {
            target.Append("void ");
            target.Append(fnName);
            target.AppendLine("(MeshData d, inout SurfaceData o)");
        }

        private static void CreateVariables(StringBuilder target, ShaderAssemblerData data)
        {
            // Insert _ST variables for every texture, as they are implicitly used by surface shaders
            foreach (var texture in data.Textures)
            {
                target.Append("    ");
                target.Append("float4 ");
                target.Append(texture.Declarators[0].Name.Identifier);
                target.AppendLine("_ST;");
            }

            foreach (var variable in data.Variables)
            {
                target.Append("    ");
                // paste the variable declaration as-is
                target.AppendLine(variable.GetPrettyPrintedCode().Trim());
            }
        }

        private static void CreateTextures(StringBuilder target, ShaderAssemblerData data)
        {
            foreach (var texture in data.Textures)
            {
                target.Append("    ");
                target.AppendLine($"TEXTURE2D({texture.Declarators[0].Name});");
                target.Append("    ");
                target.AppendLine($"SAMPLER(sampler{texture.Declarators[0].Name});");
            }
        }

        private static void CreateProperties(StringBuilder target, ShaderAssemblerData data)
        {
            foreach (var prop in data.ShaderNode.Properties)
            {
                target.Append("    ");
                target.AppendLine(RewriteThryPropertyDrawers(prop.GetPrettyPrintedCode().Trim()));
            }
        }

        private static string RewriteThryPropertyDrawers(string source)
        {
            var drawerStart = source.IndexOf("--{");
            
            // perform simple rewrites
            if (drawerStart == -1)
            {
                return source
                    .Replace("[ThryToggle]", "[ToggleUI]")
                    .Replace("[ThryToggle()]", "[ToggleUI]")
                    .Replace("ThryWideEnum", "Enum")
                    .Replace("[hdr]", "[HDR]");
            }
            
            var drawerEnd = drawerStart + 3 + source[(drawerStart + 3)..].IndexOf("}", StringComparison.Ordinal);
            var condition = source[(drawerStart + 3)..drawerEnd].Split(':');

            switch (condition[0])
            {
                case "condition_show":
                {
                    var sb = new StringBuilder();
                    sb.Append(source[..drawerStart]);
                    sb.Append(" %ShowIf(");
                    sb.Append(condition[1][1..^1]);
                    sb.Append(")");
                    sb.Append(source[(drawerEnd + 1)..]);
                    return sb.ToString();
                }
                default:
                    return source;
            }
        }
    }
}