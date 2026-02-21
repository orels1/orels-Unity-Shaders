using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using UnityShaderParser.Common;
using UnityShaderParser.HLSL;
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
            
            InjectShaderBlock(sb, data, "Textures", CreateTextures);

            sb.AppendLine();
            
            InjectShaderBlock(sb, data, "Variables", CreateVariables);
            
            sb.AppendLine();

            if (data.PragmaInfo.ShaderFeatures.Count > 0 || data.PragmaInfo.MultiCompiles.Count > 0)
            {
                InjectShaderBlock(sb, data, "ShaderFeatures", CreateShaderFeatures);
                sb.AppendLine();
            }

            if (data.SurfaceFunction != null)
            {
                var fnName = $"SurfaceFn_{data.SurfaceFunction.Name.GetName()}_Fragment";
                InjectShaderBlock(sb, data, "Fragment", (target, data) => { CreateFragment(target, data, fnName); }, $"\"{fnName}\"");
                sb.AppendLine();
            }

            if (data.VertexFunction != null)
            {
                var fnName = $"VertexFn_{data.VertexFunction.Name.GetName()}_Vertex";
                InjectShaderBlock(sb, data, "Vertex", (target, data) => { CreateVertex(target, data, fnName); }, $"\"{fnName}\"");
                sb.AppendLine();
            }
            
            Debug.Log($"Assembled Shader: {sb}");

            return sb.ToString();
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
            target.AppendLine("    {");

            // First pass - rewrite texture sampling
            var functionSource = data.VertexFunction.GetPrettyPrintedCode();
            var functionTokens = ShaderParser.ParseTopLevelDeclarations(functionSource, new HLSLParserConfig(), out _, out _);
            var functionEditor = new FunctionRewriter(
                FunctionRewriter.FunctionType.Vertex,
                FunctionRewriter.RewriteType.TextureCalls,
                data,
                functionSource,
                functionTokens.SelectMany(x => x.Tokens).ToList()
            );
            var edited = functionEditor.ApplyEdits(functionTokens);
                
            // Second pass - rewrite field access
            functionTokens = ShaderParser.ParseTopLevelDeclarations(edited, new HLSLParserConfig(), out _, out _);
            functionEditor = new FunctionRewriter(
                FunctionRewriter.FunctionType.Vertex,
                FunctionRewriter.RewriteType.FieldAccess,
                data,
                edited,
                functionTokens.SelectMany(x => x.Tokens).ToList()
            );
            edited = functionEditor.ApplyEdits(functionTokens);
                
            var split = edited.Split(Environment.NewLine);
            var startIndex = split[1].Trim().StartsWith("{") ? 2 : 1;
            InsertIndentedContents(target, split, 2, startIndex);
                
            target.AppendLine("    }");
        }

        private static void CreateFragment(StringBuilder target, ShaderAssemblerData data, string fnName)
        {
            target.Append("    ");
            InsertFragmentFn(target, fnName);
            target.AppendLine("    {");

            // First pass - rewrite texture sampling
            var functionSource = data.SurfaceFunction.GetPrettyPrintedCode();
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
            InsertIndentedContents(target, split);
            
            target.AppendLine("    }");
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
            target.AppendLine("(inout VertexData v)");
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