using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using Debug = UnityEngine.Debug;

namespace ORL.ShaderGenerator
{
    [Serializable]
    public class ShaderBlock
    {
        public string Name;
        public List<string> Params;
        public List<string> Contents;
        public bool IsFunction;
        public string CallSign;
        public int Order;
        public string Path;
        public int Line;
        public int Indentation;
    }

    public class Parser
    {
        private static HashSet<string> _functionIdentifiers = new HashSet<string>
        {
            "%PrePassColor",
            "%Fragment",
            "%FragmentBase",
            "%Vertex",
            "%VertexBase",
            "%TessFactor",
            "%Color",
            "%Shadow"
        };
        
        private static Regex _callSignRegex = new Regex(@"(?<fnName>[\w]+)\((?<params>[\w\,\s]+)\)");

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
                                            Debug.Log($"{blockName} block content: {string.Join(",",blockContent)}");
                                        }
                                    }
                                }
                                
                                var newBlock = new ShaderBlock
                                {
                                    Name = blockName,
                                    Params = paramsList,
                                    Contents = blockContent,
                                    Path = path,
                                    Line = blockStartLine,
                                    Indentation = blockIndentation
                                };
                                if (_functionIdentifiers.Contains(blockName))
                                {
                                    var fnName = newBlock.Params[0].Replace("\"", "");
                                    var fnLine = newBlock.Contents.Find(s => s.Contains($"void {fnName}"));
                                    if (!string.IsNullOrEmpty(fnLine))
                                    {
                                        var fnStartIndex = fnLine.IndexOf(fnName, StringComparison.InvariantCulture);
                                        if (fnStartIndex > 0)
                                        {
                                            var callSignLine = fnLine.Substring(fnStartIndex, fnLine.Substring(fnStartIndex).IndexOf(')') + 1) + ";";
                                            var callSignMatch = _callSignRegex.Match(callSignLine);
                                            var paramsStr = callSignMatch.Groups["params"].Value;
                                            var fnParams = paramsStr.Split(',');
                                            fnParams = fnParams.Select(p => p.Split(' ').Last().Trim()).ToArray();
                                            newBlock.IsFunction = true;
                                            newBlock.Order = newBlock.Params.Count > 1
                                                ? int.Parse(newBlock.Params[1].Replace("\"", ""))
                                                : 0; 
                                            newBlock.CallSign = $"{fnName}({string.Join(", ", fnParams)});";
                                        }
                                        
                                    }
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