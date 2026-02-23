using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityShaderParser.Common;
using UnityShaderParser.HLSL;

namespace ORL.ShaderGenerator.Tools.SurfaceShaders
{
    public class FunctionRewriter : HLSLEditor
        {
            public enum FunctionType
            {
                Vertex,
                Surface
            }

            // We need to separate these into separate passes otherwise the offsets are broken
            public enum RewriteType
            {
                FieldAccess,
                TextureCalls,
                Identifiers,
            }

            private readonly FunctionType _functionType = FunctionType.Surface;
            private readonly RewriteType _rewriteType = RewriteType.TextureCalls;
            private readonly ShaderAssemblerData _data;
            private readonly FunctionDefinitionNode _functionDefinitionNode;

            private string _surfaceInputStructType;
            
            public FunctionRewriter(FunctionType functionType, RewriteType rewriteType, FunctionDefinitionNode functionDefinitionNode, ShaderAssemblerData data, string source, List<Token<TokenKind>> tokens) : base(source, tokens)
            {
                _functionType = functionType;
                _rewriteType = rewriteType;
                _functionDefinitionNode = functionDefinitionNode;
                _data = data;
                _surfaceInputStructType =
                    (data.SurfaceInputStruct.Parent as StructDefinitionNode).StructType.Name.GetName();
            }

            public override void VisitIdentifierNode(IdentifierNode node)
            {
                if (_rewriteType != RewriteType.Identifiers)
                {
                    base.VisitIdentifierNode(node);
                    return;
                }

                // this handles cases like `o = (StructName)0;`
                if (_functionType == FunctionType.Vertex)
                {
                    if (node.Identifier == _surfaceInputStructType)
                    {
                        Edit(node, "FragmentData");
                    }
                }
                
                if (node.Identifier == _data.SurfaceInputName)
                {
                    Edit(node, "d");
                    base.VisitIdentifierNode(node);
                }
            }

            public override void VisitFieldAccessExpressionNode(FieldAccessExpressionNode node)
            {
                if (_rewriteType != RewriteType.FieldAccess)
                {
                    base.VisitFieldAccessExpressionNode(node);
                    return;
                }
                
                if (node.Target is IdentifierExpressionNode identifier)
                {
                    // if we're targeting MeshData - rewrite it here
                    if (_functionType == FunctionType.Surface)
                    {
                        // Only rewrite if it is actually an input parameter
                        if (identifier.Name.Identifier == _data.SurfaceInputName && _functionDefinitionNode.Parameters.Any(p => p.Declarator.Name.Identifier == _data.SurfaceInputName))
                        {
                            // avoid editing `uv_` accessors, as they're handled at the callsite directly
                            // uv_texcoord is a special amplify-ism
                            if (
                                !node.Name.Identifier.StartsWith("uv_")
                                || node.Name.Identifier.Equals("uv_texcoord")
                                || node.Name.Identifier.Equals("uv2_texcoord2")
                            )
                            {
                                var mappedName = _data.SurfaceInputMappings.TryGetValue(node.Name.Identifier, out var mapping) ? mapping : node.Name.Identifier;
                                Edit(node, "d." + mappedName);
                            }
                            else
                            {
                                var sb = new StringBuilder();
                                sb.Append("d.");
                                var offset = 3;
                                if (node.Name.Identifier.StartsWith("uv_"))
                                {
                                    sb.Append("d.uv0.xy * ");
                                }

                                if (node.Name.Identifier.StartsWith("uv2_"))
                                {
                                    sb.Append("d.uv1.xy * ");
                                    offset = 4;
                                }
                                sb.Append(node.Name.Identifier[offset..]);
                                sb.Append("_ST + ");
                                sb.Append(node.Name.Identifier[offset..]);
                                sb.Append("_ST.zw");
                                Edit(node, sb.ToString());
                            }

                        }

                        if (identifier.Name.Identifier == "o")
                        {
                            // If there are no mappings - pass as-is
                            if (_data.SurfaceOutputMappings != null)
                            {
                                var mappedName = _data.SurfaceOutputMappings.TryGetValue(node.Name.Identifier, out var mapping) ? mapping : node.Name.Identifier;
                                Edit(node, "o." + mappedName);
                            }
                        }
                    }

                    if (_functionType == FunctionType.Vertex)
                    {
                        if (identifier.Name.Identifier == "v")
                        {
                            // use fallback mappings or same name if no struct is provided
                            // usually means a built-in struct is used
                            string mappedName;
                            if (_data.VertexInputStruct == null)
                            {
                                mappedName = _data.FallbackVertexInputMappings.TryGetValue(node.Name.Identifier, out var mapping) ? mapping : node.Name.Identifier;
                            }
                            else
                            {
                                var vertDataType =
                                    (_data.VertexInputStruct.Fields.Find(f => (f.Declarators[0].Name.Identifier == node.Name.Identifier))
                                        .Declarators[0].Qualifiers[0] as SemanticNode).Name.Identifier;
                                mappedName = _data.VertexInputMappings.TryGetValue(vertDataType, out var mapping) ? mapping : node.Name.Identifier;
                            }
                            Edit(node, "v." + mappedName);
                        }
                    }
                }
                base.VisitFieldAccessExpressionNode(node);
            }

            public override void VisitFunctionDefinitionNode(FunctionDefinitionNode node)
            {
                foreach (var param in node.Parameters)
                {
                    if (param.Declarator.Name.Identifier == _data.SurfaceInputName)
                    {
                        Edit(param, "MeshData d");
                    }
                }
                base.VisitFunctionDefinitionNode(node);
            }

            public override void VisitFunctionCallExpressionNode(FunctionCallExpressionNode node)
            {
                if (_rewriteType != RewriteType.TextureCalls)
                {
                    base.VisitFunctionCallExpressionNode(node);
                    return;
                }
                
                if (node.Name.GetName() == "tex2D")
                {
                    var sb = new StringBuilder();
                    var textureName = (node.Arguments[0] as IdentifierExpressionNode).Name.Identifier;
                
                    sb.Append("SAMPLE_TEXTURE2D(");
                    sb.Append(node.Arguments[0].GetPrettyPrintedCode());
                    sb.Append(", ");
                    sb.Append("sampler");
                    sb.Append(textureName);
                    sb.Append(", ");
                    sb.Append(node.Arguments[1].GetPrettyPrintedCode());
                    sb.Append(")");
                
                    Edit(node, sb.ToString());
                }

                if (node.Name.GetName() == "tex2Dlod")
                {
                    var sb = new StringBuilder();
                    var textureName = (node.Arguments[0] as IdentifierExpressionNode).Name.Identifier;
                    
                    var samplerParams = (node.Arguments[1] as NumericConstructorCallExpressionNode).Arguments;
                    var uvXYSeparate = samplerParams.Count == 4;
                    var uvParam = new StringBuilder();
                    if (!uvXYSeparate)
                    {
                        uvParam.Append(samplerParams[0].GetPrettyPrintedCode());
                    }
                    else
                    {
                        uvParam.Append("float2(");
                        uvParam.Append(samplerParams[0].GetPrettyPrintedCode());
                        uvParam.Append(", ");
                        uvParam.Append(samplerParams[1].GetPrettyPrintedCode());
                        uvParam.Append(")");
                    }
                
                    sb.Append("SAMPLE_TEXTURE2D_LOD(");
                    sb.Append(node.Arguments[0].GetPrettyPrintedCode());
                    sb.Append(", ");
                    sb.Append("sampler");
                    sb.Append(textureName);
                    sb.Append(", ");
                    sb.Append(uvParam.ToString());
                    sb.Append(", ");
                    sb.Append(samplerParams[^1].GetPrettyPrintedCode());
                    sb.Append(")");
                
                    Edit(node, sb.ToString());
                }
                
                // Outputs per-pixel world-space normal
                if (node.Name.GetName() == "WorldNormalVector")
                {
                    var sb = new StringBuilder();
                    var target = node.Arguments[1].GetPrettyPrintedCode();
                    sb.Append("mul(");
                    sb.Append(target);
                    sb.Append(", d.TBNMatrix");
                    sb.Append(")");
                    Edit(node, sb.ToString());
                }
                
                base.VisitFunctionCallExpressionNode(node);
            }
        }
}