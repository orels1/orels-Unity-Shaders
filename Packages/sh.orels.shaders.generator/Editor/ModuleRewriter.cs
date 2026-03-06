using System;
using UnityShaderParser.Common;
using UnityShaderParser.HLSL;
using UnityShaderParser.HLSL.PreProcessor;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;
using UnityShaderParser.ShaderLab;
using SLToken = UnityShaderParser.Common.Token<UnityShaderParser.ShaderLab.TokenKind>;
using TokenKind = UnityShaderParser.ShaderLab.TokenKind;

namespace ORL.ShaderGenerator
{
    public class ModuleRewriter : HLSLEditor
    {
        public enum RewriteMode
        {
            PropertyAliasing
        }

        private readonly RewriteMode _mode;

        public ModuleRewriter(RewriteMode mode, string source, List<Token<UnityShaderParser.HLSL.TokenKind>> tokens) : base(source, tokens)
        {
            _mode = mode;
        }

        [MenuItem("Tools/orels1/Rewrite")]
        public static void TestStuff()
        {
            var path = "Packages/sh.orels.shaders.generator/Runtime/Sources/Modules/Emission.orlsource";
            var source = File.ReadAllText(path);
            var config = new HLSLParserConfig()
            {
                PreProcessorMode = PreProcessorMode.ExpandAll,
                Defines = new Dictionary<string, string>
                {
                    {"SHADER_API_D3D11", "1"}
                }
            };

            var orlParser = new Parser();
            var blocks = orlParser.Parse(source.Split(Environment.NewLine), path);

            var newBlocks = new List<ShaderBlock>();
            var aliasedProperties = new Dictionary<string, string>();

            foreach (var block in blocks)
            {
                switch (block.CoreBlockType)
                {
                    case ShaderBlock.BlockType.Properties:
                    {
                        var blockSource = string.Join(Environment.NewLine, block.Contents);
                        var tokens = ShaderLabLexer.Lex(blockSource, null, null, false, out _);
                        var nodes = ShaderLabParser.ParseShaderProperties(tokens, ShaderAnalyzers.SLConfig, out _);
                        
                        var editor = new AliasShaderProperties(1, blockSource, tokens);
                        var edited = editor.ApplyEdits(nodes);
                        aliasedProperties = editor.Aliased;
                        var reconstructed = new List<string>();
                        reconstructed.Add("%Properties()");
                        reconstructed.Add("{");
                        reconstructed.AddRange(edited.Split(Environment.NewLine));
                        reconstructed.Add("}");
                        newBlocks.AddRange(orlParser.Parse(reconstructed.ToArray(), path));
                        break;
                    }
                    case ShaderBlock.BlockType.Textures:
                    {
                        for (var i = 0; i < block.Contents.Count; i++)
                        {
                            // Skip samplers, we want to reuse those
                            if (block.Contents[i].Trim().StartsWith("SAMPLER")) continue;
                            foreach (var aliased in aliasedProperties)
                            {
                                block.Contents[i] = block.Contents[i].Replace(aliased.Key, aliased.Value);
                            }
                        }
                        newBlocks.Add(block);
                        break;
                    }
                    case ShaderBlock.BlockType.Variables:
                    {
                        for (var i = 0; i < block.Contents.Count; i++)
                        {
                            foreach (var aliased in aliasedProperties)
                            {
                                block.Contents[i] = block.Contents[i].Replace(aliased.Key, aliased.Value);
                            }
                        }
                        newBlocks.Add(block);
                        break;
                    }
                    case ShaderBlock.BlockType.Unknown:
                    {
                        if (!block.IsFunction) continue;
                        var blockSource = string.Join(Environment.NewLine, block.Contents);
                        List<HLSLSyntaxNode> decls = ShaderParser.ParseTopLevelDeclarations(blockSource, config);
                        var functionAliaser = new AliasFunctionBlocks(1, aliasedProperties, blockSource, decls.SelectMany(x => x.Tokens).ToList());
                        var edited = functionAliaser.ApplyEdits(decls);
                        var reconstructed = new List<string>();
                        reconstructed.Add($"%{block.Name}({string.Join(", ", block.Params)})");
                        reconstructed.Add("{");
                        reconstructed.AddRange(edited.Split(Environment.NewLine));
                        reconstructed.Add("}");
                        newBlocks.AddRange(orlParser.Parse(reconstructed.ToArray(), path));
                        break;
                    }
                    default:
                        newBlocks.Add(block);
                        break;
                }
            }
            
            Debug.Log("Original Blocks");

            foreach (var block in blocks)
            {
                Debug.Log($"{block.CoreBlockType}\n{string.Join(Environment.NewLine, block.Contents)}");
            }

            Debug.Log("Edited Blocks:");
            foreach (var block in newBlocks)
            {
                Debug.Log($"{block.CoreBlockType}\n{string.Join(Environment.NewLine, block.Contents)}");
            }
        }
        
        public override void VisitIdentifierNode(IdentifierNode node)
        {
            Debug.Log(node.Identifier);
            Debug.Log(node.GetCodeInSourceText(Source));
            base.VisitIdentifierNode(node);
        }
    }
    
    public class AliasFunctionBlocks : HLSLEditor
    {
        private int _offset;
        private Dictionary<string, string> _aliasedProperties;
        public AliasFunctionBlocks(int offset, Dictionary<string, string> aliasedProperties, string source, List<Token<UnityShaderParser.HLSL.TokenKind>> tokens) : base(source, tokens)
        {
            _offset = offset;
            _aliasedProperties = aliasedProperties ?? new Dictionary<string, string>();
        }

        public override void VisitFunctionDefinitionNode(FunctionDefinitionNode node)
        {
            Edit(node.Name, node.Name.GetName() + _offset.ToString("00"));
            base.VisitFunctionDefinitionNode(node);
        }

        public override void VisitIdentifierNode(IdentifierNode node)
        {
            foreach (var aliased in _aliasedProperties)
            {
                var text = node.GetCodeInSourceText(Source);
                if (!text.Contains(aliased.Key)) continue;
                if (text.StartsWith("sampler_")) continue;
                Edit(node, text.Replace(aliased.Key, aliased.Value));
            }
            base.VisitIdentifierNode(node);
        }
    }

    public class AliasShaderProperties : ShaderLabEditor
    {
        private int _offset;
        public Dictionary<string, string> Aliased;
        
        public AliasShaderProperties(int offset, string source, List<Token<TokenKind>> tokens) : base(source, tokens)
        {
            _offset = offset;
            Aliased = new Dictionary<string, string>();
        }

        public override void VisitShaderPropertyNode(ShaderPropertyNode node)
        {
            var old = node.Uniform;
            node.Uniform += _offset.ToString("00");
            Aliased.Add(old, node.Uniform);
            var replaced = Aliased.Keys;
            foreach (var oldProperty in replaced)
            {
                node.Name = node.Name.Replace(oldProperty, Aliased[oldProperty]);
            }
            Edit(node, node.GetPrettyPrintedCode());
            base.VisitShaderPropertyNode(node);
        }
    }
}
