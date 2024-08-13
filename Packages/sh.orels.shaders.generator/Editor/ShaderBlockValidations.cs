using System;
using System.Collections.Generic;
using System.IO;

#if UNITY_2022_3_OR_NEWER
using UnityEditor.AssetImporters;
#else
using UnityEditor.Experimental.AssetImporters;
#endif
using UnityShaderParser.Common;
using UnityShaderParser.HLSL;
using UnityShaderParser.HLSL.PreProcessor;
using UnityShaderParser.ShaderLab;

namespace ORL.ShaderGenerator
{
    public class ShaderBlockValidations
    {
        private static ShaderLabParserConfig SLConfig = new ShaderLabParserConfig
        {
            IncludeResolver = new DefaultPreProcessorIncludeResolver(new List<string>
            {
                Path.Combine(UnityEditor.EditorApplication.applicationContentsPath, "CGIncludes")
            }),
            PreProcessorMode = PreProcessorMode.ExpandAll,
            Defines = new Dictionary<string, string>
            {
                {"SHADER_API_D3D11", "1"}
            }
        };

        public struct FunctionParamError
        {
            public string Name;
            public string Type;
            public int StartIndex;
            public int EndIndex;
            public int Line;
            public string PrettyCode;
        }

        public struct FunctionParamType
        {
            public Type NodeType;
            public ScalarType Kind;
            public int Dimension;
            public string Name;
        }

        public class FunctionBlockValidator : HLSLSyntaxVisitor
        {
            protected string _mainFnName;

            protected List<(FunctionParamType paramType, string paramName)> _allowedParams;

            protected string AllowedParamsFormatted => string.Join(", ", _allowedParams.ConvertAll(p => $"{p.paramType.Name} {p.paramName}"));

            public Dictionary<FunctionParamError, string> Errors = new Dictionary<FunctionParamError, string>();


            public List<string> FoundFunctions = new List<string>();

            public FunctionBlockValidator(string mainFnName) : base()
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
                            default:
                                UnityEngine.Debug.LogWarning($"Unknown parameter type {parameter.ParamType.GetType()} for {parameter.Declarator.Name}");
                                return false;
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
                        }, $"Invalid <b>{paramType} {parameter.Declarator.Name}</b> parameter in function <b>{node.Name.GetName()}</b>, only <b>{AllowedParamsFormatted}</b> are supported");
                    }
                }
            }
        }

        public class VertexBlockValidator : FunctionBlockValidator
        {
            public VertexBlockValidator(string mainFnName) : base(mainFnName)
            {
                _allowedParams = new List<(FunctionParamType paramType, string paramName)>
                {
                    (new FunctionParamType
                    {
                        NodeType = typeof(NamedTypeNode),
                        Name = "VertexData",
                    }, "v"),
                    (new FunctionParamType
                    {
                        NodeType = typeof(NamedTypeNode),
                        Name = "FragmentData",
                    }, "o")
                };
            }
        }

        public class FragmentBlockValidator : FunctionBlockValidator
        {
            public FragmentBlockValidator(string mainFnName) : base(mainFnName)
            {
                _allowedParams = new List<(FunctionParamType paramType, string paramName)>
                {
                    (new FunctionParamType
                    {
                        NodeType = typeof(NamedTypeNode),
                        Name = "MeshData",
                    }, "d"),
                    (new FunctionParamType
                    {
                        NodeType = typeof(NamedTypeNode),
                        Name = "SurfaceData",
                    }, "o"),
                    (new FunctionParamType
                    {
                        NodeType = typeof(NamedTypeNode),
                        Name = "FragmentData",
                    }, "i"),
                    (new FunctionParamType
                    {
                        NodeType = typeof(ScalarTypeNode),
                        Kind = ScalarType.Bool
                    }, "facing")
                };
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
                ctx.LogImportError("Block source was:\n" + blockSource, importer);
                importer.Errors.Add(new ShaderDefinitionImporter.ShaderError(block, -1, "somefile", message));
            }
            foreach (var error in vertexValidator.Errors)
            {
                ctx.LogImportError(error.Value, importer);
                importer.Errors.Add(new ShaderDefinitionImporter.ShaderError(block, error.Key.Line, "somefile", error.Value, error.Key.PrettyCode, error.Key.StartIndex, error.Key.EndIndex));
            }
        }

        public static void ValidateFragmentFunction(ShaderBlock block, ref AssetImportContext ctx, ShaderDefinitionImporter importer)
        {
            if (block == null) return;
            var blockSource = string.Join("\n", block.Contents.ToArray());
            var parsedBlock = ShaderParser.ParseTopLevelDeclarations(blockSource, SLConfig);
            var strippedName = block.Params[0].Replace("\"", string.Empty);
            var fragmentValidator = new FragmentBlockValidator(strippedName);
            fragmentValidator.VisitMany(parsedBlock);
            if (!fragmentValidator.FoundFunctions.Contains(strippedName))
            {
                var message =
                    $"Fragment function set to <b>{strippedName}</b>, but only <b>{string.Join(", ", fragmentValidator.FoundFunctions)}</b> found";
                ctx.LogImportError(message, importer);
                ctx.LogImportError("Block source was:\n" + blockSource, importer);
                importer.Errors.Add(new ShaderDefinitionImporter.ShaderError(block, -1, "somefile", message));
            }
            foreach (var error in fragmentValidator.Errors)
            {
                ctx.LogImportError(error.Value, importer);
                importer.Errors.Add(new ShaderDefinitionImporter.ShaderError(block, error.Key.Line, "somefile", error.Value, error.Key.PrettyCode, error.Key.StartIndex, error.Key.EndIndex));
            }
        }
    }
}