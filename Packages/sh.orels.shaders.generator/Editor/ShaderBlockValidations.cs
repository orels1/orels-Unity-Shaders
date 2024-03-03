using System;
using System.Collections.Generic;
#if UNITY_2022_3_OR_NEWER
using UnityEditor.AssetImporters;
#else
using UnityEditor.Experimental.AssetImporters;
#endif
using UnityShaderParser.Common;
using UnityShaderParser.HLSL;
using UnityShaderParser.HLSL.PreProcessor;
using UnityShaderParser.ShaderLab;
using TokenKind = UnityShaderParser.HLSL.TokenKind;

namespace ORL.ShaderGenerator
{
    public class ShaderBlockValidations
    {
        private static ShaderLabParserConfig SLConfig = new ShaderLabParserConfig
        {
            IncludeResolver = new DefaultPreProcessorIncludeResolver(new List<string>
            {
                "C:\\Program Files\\Unity\\Hub\\Editor\\2019.4.31f1\\Editor\\Data\\CGIncludes"
            }),
            PreProcessorMode = PreProcessorMode.ExpandAll,
            Defines = new Dictionary<string, string>
            {
                {"SHADER_API_D3D11", "1"}
            }
        };
        
        public class VertexBlockValidator : HLSLSyntaxVisitor
        {
            private readonly string _mainFnName;
            
            public struct FunctionParamError
            {
                public string Name;
                public string Type;
                public int StartIndex;
                public int EndIndex;
                public int Line;
                public string PrettyCode;
            }

            public struct ParamType
            {
                public Type NodeType;
                public ScalarType Kind;
                public int Dimension;
                public string Name;
            }

            private readonly List<(ParamType paramType, string paramName)> _allowedParams =
                new List<(ParamType paramType, string paramName)>
                {
                    (new ParamType
                    {
                        NodeType = typeof(NamedTypeNode),
                        Name = "VertexData",
                    }, "v"),
                    (new ParamType
                    {
                        NodeType = typeof(NamedTypeNode),
                        Name = "FragmentData",
                    }, "o")
                };
            
            private readonly string _allowedParamsFormatted = "VertexData v, FragmentData o";
            
            public Dictionary<FunctionParamError, string> Errors = new Dictionary<FunctionParamError, string>();
            public List<string> FoundFunctions = new List<string>();

            public VertexBlockValidator(string mainFnName) : base()
            {
                _mainFnName = mainFnName;
            }
        
            public override void VisitFunctionDefinitionNode(FunctionDefinitionNode node)
            {
                FoundFunctions.Add(node.Name.GetName());
                if (node.Name.GetName() != _mainFnName) return;
                foreach (var parameter in node.Parameters)
                {
                    var matchedParams = _allowedParams.FindAll(p =>
                    {
                        if (parameter.Declarator.Name != p.paramName) return false;
                        if (parameter.ParamType.GetType() != p.paramType.NodeType) return false;
                        switch (parameter.ParamType)
                        {
                            case NamedTypeNode named:
                                if (named.Name != p.paramType.Name) return false;
                                break;
                            case ScalarTypeNode scalar:
                                if (scalar.Kind != p.paramType.Kind) return false;
                                break;
                            case VectorTypeNode vector:
                                if (vector.Kind != p.paramType.Kind || vector.Dimension != p.paramType.Dimension) return false;
                                break;
                        }
                        return true;
                    });
                    if (matchedParams.Count == 0)
                    {
                        var paramType = "";
                        switch (parameter.ParamType)
                        {
                            case ScalarTypeNode s:
                                paramType = PrintingUtil.GetEnumName(s.Kind);
                                break;
                            case VectorTypeNode v:
                                paramType = PrintingUtil.GetEnumName(v.Kind) + v.Dimension;
                                break;
                        }

                        Errors.Add(new FunctionParamError
                            {
                                Line = parameter.Span.Start.Line,
                                StartIndex = parameter.Span.Start.Index,
                                EndIndex = parameter.Span.End.Index,
                                Name = parameter.Declarator.Name,
                                Type = paramType,
                                PrettyCode = node.GetPrettyPrintedCode()
                            }, $"Invalid <b>{paramType} {parameter.Declarator.Name}</b> parameter in function <b>{node.Name.GetName()}</b>, only <b>{_allowedParamsFormatted}</b> are supported");
                    }
                }
            }
        }


        public static void ValidateVertexFunction(ShaderBlock block, ref AssetImportContext ctx, ShaderDefinitionImporter importer)
        {
            if (block == null) return;
            var blockSource = string.Join("\n", block.Contents.ToArray());
            var parsedBlock = ShaderParser.ParseTopLevelDeclarations(blockSource, SLConfig);
            var strippedName = block.Params[0].Replace("\"", string.Empty);
            var vertexValidator = new VertexBlockValidator(strippedName);
            vertexValidator.VisitMany(parsedBlock);
            if (!vertexValidator.FoundFunctions.Contains(strippedName))
            {
                var message =
                    $"Vertex function set to <b>{strippedName}</b>, but only <b>{string.Join(", ", vertexValidator.FoundFunctions)}</b> found";
                ctx.LogImportError(message, importer);
                importer.Errors.Add(new ShaderDefinitionImporter.ShaderError(block, -1, "somefile", message));
            }
            foreach (var error in vertexValidator.Errors)
            {
                ctx.LogImportError(error.Value, importer);
                importer.Errors.Add(new ShaderDefinitionImporter.ShaderError(block, error.Key.Line, "somefile", error.Value, error.Key.PrettyCode, error.Key.StartIndex, error.Key.EndIndex));
            }
        }
    }
}