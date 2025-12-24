using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
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
    public class ShaderAnalyzers
    {
        public static ShaderLabParserConfig SLConfig = new ShaderLabParserConfig
        {
            IncludeResolver = new DefaultPreProcessorIncludeResolver(new List<string>
            {
                Path.Combine(UnityEditor.EditorApplication.applicationContentsPath, "CGIncludes")
            }),
            PreProcessorMode = PreProcessorMode.ExpandAllExceptIncludes,
            Defines = new Dictionary<string, string>
            {
                {"SHADER_API_D3D11", "1"},
                {"UNITY_BRANCH", ""},
                {"TEXTURE2D(textureName)", "Texture2D textureName"},
                {"SAMPLER(samplerName)", "SamplerState samplerName"},
                {"TEXTURE2D_PARAM(textureName, samplerName)", "TEXTURE2D(textureName), SAMPLER(samplerName)"},
                {"TEXTURE2D_ARGS(textureName, samplerName)", "textureName, samplerName"},
            }
        };

        public class TextureObjectCounter : HLSLSyntaxVisitor
        {
            private readonly string _source;

            public TextureObjectCounter(string source)
            {
                _source = source;
            }

            public int texturesFound;

            private PredefinedObjectType[] _supportedTexTypes = new PredefinedObjectType[]
            {
                PredefinedObjectType.Texture,
                PredefinedObjectType.Texture2D,
                PredefinedObjectType.Texture2DArray,
                PredefinedObjectType.Texture3D,
                PredefinedObjectType.TextureCube,
                PredefinedObjectType.TextureCubeArray,
            };

            public override void VisitVariableDeclarationStatementNode(VariableDeclarationStatementNode node)
            {
#if UNITY_2021_3_OR_NEWER
                if (node.Kind is not PredefinedObjectTypeNode predefinedObjectTypeNode) return;
                if (_supportedTexTypes.Contains(predefinedObjectTypeNode.Kind))
                {
                    texturesFound++;
                }
#endif
            }
        }

        public class SamplerCounter : HLSLSyntaxVisitor
        {
            private readonly string _source;

            public SamplerCounter(string source)
            {
                _source = source;
            }

            public int samplersFound;

            public override void VisitVariableDeclarationStatementNode(VariableDeclarationStatementNode node)
            {
#if UNITY_2021_3_OR_NEWER
                if (node.Kind is not PredefinedObjectTypeNode predefinedObjectTypeNode) return;
                if (predefinedObjectTypeNode.Kind == PredefinedObjectType.SamplerState)
                {
                    samplersFound++;
                }
#endif
            }
        }


        public static int CountTextureObjects(List<ShaderBlock> blocks, ref AssetImportContext ctx, ShaderDefinitionImporter importer)
        {
            var textures = 0;
            var samplingLib = File.ReadAllLines("Packages/sh.orels.shaders.generator/Runtime/Sources/Libraries/SamplingLibrary.orlsource");
            var samplingLibText = string.Join(Environment.NewLine, samplingLib.Skip(2).Take(samplingLib.Length - 3));
            foreach (var block in blocks)
            {
                if (block == null) continue;
                var blockSource = string.Join("\n", block.Contents.ToArray());
                blockSource = samplingLibText + Environment.NewLine + blockSource;
                var parsedBlock = ShaderParser.ParseTopLevelDeclarations(blockSource, SLConfig);
                var texVisitor = new TextureObjectCounter(blockSource);
                texVisitor.VisitMany(parsedBlock);
                textures += texVisitor.texturesFound;
            }

            return textures;
        }

        public static int CountSamplers(List<ShaderBlock> blocks, ref AssetImportContext ctx, ShaderDefinitionImporter importer)
        {
            var samplers = 0;
            var samplingLib = File.ReadAllLines("Packages/sh.orels.shaders.generator/Runtime/Sources/Libraries/SamplingLibrary.orlsource");
            var samplingLibText = string.Join(Environment.NewLine, samplingLib.Skip(2).Take(samplingLib.Length - 3));
            foreach (var block in blocks)
            {
                if (block == null) continue;
                var blockSource = string.Join(Environment.NewLine, block.Contents.ToArray());
                blockSource = samplingLibText + Environment.NewLine + blockSource;
                var parsedBlock = ShaderParser.ParseTopLevelDeclarations(blockSource, SLConfig);
                var samplerVisitor = new SamplerCounter(blockSource);
                samplerVisitor.VisitMany(parsedBlock);
                samplers += samplerVisitor.samplersFound;
            }

            return samplers;
        }

        public static int CountShaderFeatures(string finalShader)
        {
            ShaderParser.ParseTopLevelDeclarations(finalShader, SLConfig, out _, out var pragmas);
            var pragmaSet = new HashSet<string>();
            foreach (var pragma in pragmas)
            {
                if (!pragma.Contains("shader_feature")) continue;
                pragmaSet.Add(pragma);
            }

            return pragmaSet.Count;
        }
    }
}