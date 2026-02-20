using System.Collections.Generic;
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
            }

            private readonly FunctionType _functionType = FunctionType.Surface;
            private readonly RewriteType _rewriteType = RewriteType.TextureCalls;
            private readonly ShaderAssemblerData _data;
            
            public FunctionRewriter(FunctionType functionType, RewriteType rewriteType, ShaderAssemblerData data, string source, List<Token<TokenKind>> tokens) : base(source, tokens)
            {
                _functionType = functionType;
                _rewriteType = rewriteType;
                _data = data;
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
                        if (identifier.Name.Identifier == _data.SurfaceInputName)
                        {
                            // avoid editing `uv_` accessors, as they're handled at the callsite directly
                            // uv_texcoord is a special amplify-ism
                            if (!node.Name.Identifier.StartsWith("uv_") || node.Name.Identifier.Equals("uv_texcoord"))
                            {
                                var mappedName = _data.SurfaceInputMappings.TryGetValue(node.Name.Identifier, out var mapping) ? mapping : node.Name.Identifier;
                                Edit(node, "d." + mappedName);
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
                            var mappedName = _data.VertexInputMappings.TryGetValue(node.Name.Identifier, out var mapping) ? mapping : node.Name.Identifier;
                            Edit(node, "v." + mappedName);
                        }
                    }
                }
                base.VisitFieldAccessExpressionNode(node);
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
                    var uvString = new StringBuilder();
                    // if this is referencing to the input struct variable - convert it to the correct value
                    if (node.Arguments[1] is FieldAccessExpressionNode uvFieldAccess)
                    {
                        var uvName = uvFieldAccess.Name.Identifier;
                        if (uvName.StartsWith("uv_"))
                        {
                            uvString.Append("d.uv0.xy * "); 
                        } else if (uvName.StartsWith("uv2_"))
                        {
                            uvString.Append("d.uv1.xy * ");
                        }
                        var texName = uvName[uvName.IndexOf('_')..]; 
                        uvString.Append(texName);
                        uvString.Append("_ST.xy + ");
                        uvString.Append(texName);
                        uvString.Append("_ST.zw");
                    }
                    // if this is just a variable - simply use it as-is
                    else if (node.Arguments[1] is IdentifierExpressionNode uvIdentifier)
                    {
                        uvString.Append(uvIdentifier.Name.Identifier);
                    }
                
                    sb.Append("SAMPLE_TEXTURE2D(");
                    sb.Append(node.Arguments[0].GetPrettyPrintedCode());
                    sb.Append(", ");
                    sb.Append("sampler");
                    sb.Append(textureName);
                    sb.Append(", ");
                    sb.Append(uvString.ToString());
                    sb.Append(")");
                
                    Edit(node, sb.ToString());
                }

                if (node.Name.GetName() == "tex2Dlod")
                {
                    var sb = new StringBuilder();
                    var textureName = (node.Arguments[0] as IdentifierExpressionNode).Name.Identifier;
                    
                    // Convert `float4(uvs, 0, lod)` to `uvs`/`float2(uv.x, uv.y)`
                    var samplerParams = (node.Arguments[1] as NumericConstructorCallExpressionNode).Arguments;
                    var uvXYSeparate = samplerParams.Count == 4;
                    var uvParam = new StringBuilder();
                    if (!uvXYSeparate)
                    {
                        var uvName =
                            ((samplerParams[0] as FieldAccessExpressionNode).Target as FieldAccessExpressionNode).Name.Identifier;
                        var texName = uvName[uvName.IndexOf('_')..]; 
                        if (uvName.StartsWith("uv2_"))
                        {
                            uvParam.Append("d.uv1.xy * ");
                        }
                        else
                        {
                            uvParam.Append("d.uv0.xy * "); 
                        }
                        uvParam.Append(texName);
                        uvParam.Append("_ST.xy + ");
                        uvParam.Append(texName);
                        uvParam.Append("_ST.zw");
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
                    sb.Append("mul(d.TBNMatrix, ");
                    sb.Append(target);
                    sb.Append(")");
                    Edit(node, sb.ToString());
                }
                
                base.VisitFunctionCallExpressionNode(node);
            }
        }
}