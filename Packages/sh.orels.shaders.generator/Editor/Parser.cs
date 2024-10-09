﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using UnityShaderParser.Common;
using UnityShaderParser.HLSL;
using Debug = UnityEngine.Debug;

namespace ORL.ShaderGenerator
{
    [Serializable]
    public class ShaderBlock
    {
        public enum BlockType
        {
            Unknown,
            ShaderName,
            Template,
            TemplateFeatures,
            LightingModel,
            Properties,
            Includes,
            ShaderTags,
            ShaderModifiers,
            PassModifiers,
            Variables,
            GlobalVariables,
            Textures,
            ShaderFeatures,
            ShaderDefines,
            CheckedInclude,
            FreeFunctions,
            LibraryFunctions,
            DataStructs,
            VertexBase,
            FragmentBase,
            ExtraPass,
            Custom
        }

        public static BlockType GetBlockType(string name)
        {
            switch (name)
            {
                case "%ShaderName":
                    return BlockType.ShaderName;
                case "%Template":
                    return BlockType.Template;
                case "%TemplateFeatures":
                    return BlockType.TemplateFeatures;
                case "%LightingModel":
                    return BlockType.LightingModel;
                case "%Properties":
                    return BlockType.Properties;
                case "%Includes":
                    return BlockType.Includes;
                case "%ShaderTags":
                    return BlockType.ShaderTags;
                case "%ShaderModifiers":
                    return BlockType.ShaderModifiers;
                case "%PassModifiers":
                case "%AddPassModifiers":
                case "%MetaPassModifiers":
                case "%ShadowPassModifiers":
                case "%OutlinePassModifiers":
                    return BlockType.PassModifiers;
                case "%Variables":
                    return BlockType.Variables;
                case "%GlobalVariables":
                    return BlockType.GlobalVariables;
                case "%Textures":
                    return BlockType.Textures;
                case "%ShaderFeatures":
                    return BlockType.ShaderFeatures;
                case "%ShaderDefines":
                    return BlockType.ShaderDefines;
                case "%CheckedInclude":
                    return BlockType.CheckedInclude;
                case "%FreeFunctions":
                    return BlockType.FreeFunctions;
                case "%LibraryFunctions":
                    return BlockType.LibraryFunctions;
                case "%DataStructs":
                    return BlockType.DataStructs;
                case "%VertexBase":
                    return BlockType.VertexBase;
                case "%FragmentBase":
                    return BlockType.FragmentBase;
                case "%ExtraPass":
                    return BlockType.ExtraPass;
                case "%Custom":
                    return BlockType.Custom;
                default:
                    return BlockType.Unknown;
            }
        }


        public string Name;
        public BlockType CoreBlockType;
        public List<string> Params;
        public List<string> Contents;
        public bool IsFunction;
        public string CallSign;
        public int Order;
        public string Path;
        public int Line;
        public int Indentation;

        private List<HLSLSyntaxNode> _nodes;
        public List<HLSLSyntaxNode> Nodes
        {
            get
            {
                if (_nodes == null)
                {
                    _nodes = ShaderParser.ParseTopLevelDeclarations(string.Join(Environment.NewLine, Contents), ShaderAnalyzers.SLConfig);
                }
                return _nodes;
            }
        }

        private FunctionDefinitionNode _functionNode;

        public FunctionDefinitionNode FunctionNode
        {
            get
            {
                if (Params.Count == 0) return null;
                if (_functionNode == null)
                {
                    foreach (var node in Nodes)
                    {
                        if (node is FunctionDefinitionNode fnNode)
                        {
                            if (fnNode.Name.GetName() == Params[0].Replace("\"", ""))
                            {
                                _functionNode = fnNode;
                                return _functionNode;
                            }
                        }
                    }
                }
                return _functionNode;
            }
        }
    }

    public class Parser
    {
        private int _current;
        private int _start;
        private int _total;
        private int _lineNumber;
        private string[] _lines;
        private string _currentLine;
        private bool _debugMode;

        public List<ShaderBlock> Parse(string[] source, string path = null)
        {
            _lines = source;
            var blocks = new List<ShaderBlock>();
            for (_lineNumber = 0; _lineNumber < _lines.Length; _lineNumber++)
            {
                var line = _lines[_lineNumber];
                _current = 0;
                _start = 0;
                _total = line.Length;
                _currentLine = line;
                while (_current < _total)
                {
                    switch (_currentLine[_current])
                    {
                        case ' ':
                            _current++;
                            break;
                        case '\t':
                            _current++;
                            break;
                        case '%':
                            if (_start != 0)
                            {
                                _current++;
                                break;
                            }
                            _start = _current;
                            if (IsLetter(Peek()))
                            {
                                var blockName = ConsumeUntil('(');
                                if (string.IsNullOrEmpty(blockName))
                                {
                                    _current++;
                                    break;
                                }

                                if (_debugMode)
                                {
                                    Debug.Log($"Found Block: {blockName}");
                                }

                                var blockIndentation = _current;
                                _start = _current + 1;
                                var paramsString = ConsumeUntil(')');
                                var paramsList = new List<string>();
                                if (!string.IsNullOrEmpty(paramsString))
                                {
                                    paramsList.AddRange(paramsString.Split(',').Select(s => s.Trim()));
                                }

                                if (_debugMode)
                                {
                                    Debug.Log($"{blockName} params: ({paramsString})");
                                }

                                var contentOffset = BlockHasContent();
                                var blockContent = new List<string>();
                                var blockStartLine = _lineNumber;
                                if (contentOffset > 0)
                                {
                                    _lineNumber += contentOffset;
                                    blockStartLine = _lineNumber;
                                    if (_debugMode)
                                    {
                                        Debug.Log($"{blockName} Has block content");
                                    }
                                    var contents = ConsumeBlockContent();
                                    if (contents != null)
                                    {
                                        blockContent = contents;

                                        if (_debugMode)
                                        {
                                            Debug.Log($"{blockName} block content: {string.Join(",", blockContent)}");
                                        }
                                    }
                                }

                                var newBlock = new ShaderBlock
                                {
                                    Name = blockName,
                                    CoreBlockType = ShaderBlock.GetBlockType(blockName),
                                    Params = paramsList,
                                    Contents = blockContent,
                                    Path = path,
                                    Line = blockStartLine,
                                    Indentation = blockIndentation,
                                };

                                newBlock.IsFunction = newBlock.FunctionNode != null;
                                if (newBlock.IsFunction)
                                {
                                    newBlock.Order = newBlock.Params.Count > 1
                                        ? int.Parse(newBlock.Params[1].Replace("\"", ""))
                                        : 0;
                                    newBlock.CallSign = $"{newBlock.FunctionNode.Name.GetName()}({string.Join(", ", newBlock.FunctionNode.Parameters.Select(p => p.Declarator.Name))});";
                                }
                                blocks.Add(newBlock);
                            }
                            _current++;
                            break;
                        default:
                            _current++;
                            break;
                    }
                }
            }

            return blocks;
        }

        private bool IsLetter(char source)
        {
            return char.IsLetter(source);
        }

        private char Peek()
        {
            if (_current + 1 >= _currentLine.Length)
            {
                return '\0';
            }
            return _currentLine[_current + 1];
        }

        private int BlockHasContent()
        {
            var line = _currentLine.Trim();
            if (line[_total - 1] == '{')
            {
                return 1;
            }
            if (_lineNumber + 1 >= _lines.Length)
            {
                return 0;
            }

            if (string.IsNullOrEmpty(_lines[_lineNumber + 1].Trim()))
            {
                return 0;
            }
            if (_lines[_lineNumber + 1].Trim()[0] == '{')
            {
                return 2;
            }

            return 0;
        }

        private List<string> ConsumeBlockContent()
        {
            var result = new List<string>();
            if (_lineNumber + 1 >= _lines.Length) return null;

            var subset = _lines.Skip(_lineNumber).ToList();
            var linesSkipped = 0;
            var nestLevel = 1;
            var offset = 0;
            foreach (var line in subset)
            {
                var curr = 0;
                while (curr + 1 <= line.Length)
                {
                    switch (line[curr])
                    {
                        case '{':
                            nestLevel++;
                            break;
                        case '}':
                            nestLevel--;
                            break;
                    }

                    curr++;
                    if (nestLevel == 0)
                    {
                        _lineNumber += linesSkipped;
                        return result;
                    }
                }

                linesSkipped++;
                if (linesSkipped == 1)
                {
                    offset = line.Length - line.TrimStart().Length;
                }
                result.Add(line.Substring(string.IsNullOrWhiteSpace(line) ? 0 : offset));
            }
            return null;
        }

        private string ConsumeUntil(char endMarker)
        {
            while (_current < _total)
            {
                if (_current + 1 >= _total)
                {
                    return null;
                }
                if (_currentLine[_current + 1] == endMarker)
                {
                    var result = _currentLine.Substring(_start, _current + 1 - _start);
                    _current++;
                    return result;
                }
                _current++;
            }

            return null;
        }
    }
}