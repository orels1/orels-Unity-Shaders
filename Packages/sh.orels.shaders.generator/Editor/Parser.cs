using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text.RegularExpressions;
using UnityEngine;
using Debug = UnityEngine.Debug;

namespace ORL.ShaderGenerator
{
    public struct ShaderBlock
    {
        public string Name { get; set; }
        public List<string> Params { get; set; }
        public List<string> Contents { get; set; }

        public bool IsFunction { get; set; }
        
        public string CallSign { get; set; }
    }

    public class Parser
    {
        private static HashSet<string> _functionIdentifiers = new HashSet<string>
        {
            "%Fragment",
            "%Vertex",
            "%TessFactor",
            "%Color",
            "%Shadow"
        };
        
        private static Regex _callSignRegex = new Regex(@"(?<fnName>[\w]+)\((?<params>[\w\,\s]+)\)");

        private int current;
        private int start;
        private int total;
        private int lineNumber;
        private string[] lines;
        private string currentLine;

        public List<ShaderBlock> Parse(string[] source)
        {
            lines = source;
            var blocks = new List<ShaderBlock>();
            for (lineNumber = 0; lineNumber <= lines.Length; lineNumber++)
            {
                var line = lines[lineNumber];
                current = 0;
                start = 0;
                total = line.Length;
                currentLine = line;
                while (current < total)
                {
                    switch (currentLine[current])
                    {
                        case ' ':
                            current++;
                            break;
                        case '\t':
                            current++;
                            break;
                        case '%':
                            if (start != 0)
                            {
                                current++;
                                break;
                            }
                            start = current;
                            if (IsLetter(Peek()))
                            {
                                var blockName = ConsumeUntil('(');
                                if (string.IsNullOrEmpty(blockName))
                                {
                                    current++;
                                    break;
                                }
                                Debug.Log($"Found Block: {blockName}");

                                start = current + 1;
                                var paramsString = ConsumeUntil(')');
                                var paramsList = new List<string>();
                                if (!string.IsNullOrEmpty(paramsString))
                                {
                                    paramsList.AddRange(paramsString.Split(',').Select(s => s.Trim()));
                                }
                                Debug.Log($"{blockName} params: ({paramsString})");

                                var contentOffset = BlockHasContent();
                                var blockContent = new List<string>();
                                if (contentOffset > 0)
                                {
                                    lineNumber += contentOffset;
                                    Debug.Log($"{blockName} Has block content");
                                    blockContent = ConsumeBlockContent();
                                    if (blockContent != null)
                                    {
                                        Debug.Log($"{blockName} block content: {string.Join(",",blockContent)}");
                                    }
                                }
                                
                                var newBlock = new ShaderBlock
                                {
                                    Name = blockName,
                                    Params = paramsList,
                                    Contents = blockContent
                                };
                                if (_functionIdentifiers.Contains(blockName))
                                {
                                    newBlock.IsFunction = true;
                                    var fnName = newBlock.Params[0].Replace("\"", "");
                                    var fnLine = newBlock.Contents.Find(s => s.Contains($"void {fnName}"));
                                    var fnStartIndex = fnLine.IndexOf(fnName);
                                    if (fnStartIndex > 0)
                                    {
                                        var callSignLine = fnLine.Substring(fnStartIndex, fnLine.Substring(fnStartIndex).IndexOf(')') + 1) + ";";
                                        var callSignMatch = _callSignRegex.Match(callSignLine);
                                        var paramsStr = callSignMatch.Groups["params"].Value;
                                        var fnParams = paramsStr.Split(',');
                                        fnParams = fnParams.Select(p => p.Split(' ').Last().Trim()).ToArray();
                                        newBlock.CallSign = $"{fnName}({string.Join(", ", fnParams)});";
                                    }
                                }
                                blocks.Add(newBlock);
                            }
                            current++;
                            break;
                        default:
                            current++;
                            break;
                    }
                }

                lineNumber++;
            }

            return blocks;
        }

        private bool IsLetter(char source)
        {
            return char.IsLetter(source);
        }

        private char Peek()
        {
            if (current + 1 >= currentLine.Length)
            {
                return '\0';
            }
            return currentLine[current + 1];
        }

        private int BlockHasContent()
        {
            var line = currentLine.Trim();
            if (line[total - 1] == '{')
            {
                return 1;
            }
            if (lineNumber + 1 >= lines.Length)
            {
                return 0;
            }

            if (string.IsNullOrEmpty(lines[lineNumber + 1].Trim()))
            {
                return 0;
            }
            if (lines[lineNumber + 1].Trim()[0] == '{')
            {
                return 2;
            }

            return 0;
        }

        private List<string> ConsumeBlockContent()
        {
            var result = new List<string>();
            if (lineNumber + 1 >= lines.Length) return null;

            var subset = lines.Skip(lineNumber).ToList();
            var linesSkipped = 0;
            var nestLevel = 1;
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
                        lineNumber += linesSkipped;
                        return result;
                    }
                }

                linesSkipped++;
                result.Add(line);
            }
            return null;
        }

        private string ConsumeUntil(char endMarker)
        {
            while (current < total)
            {
                if (current + 1 >= total)
                {
                    return null;
                }
                if (currentLine[current + 1] == endMarker)
                {
                    var result = currentLine.Substring(start, current + 1 - start);
                    current++;
                    return result;
                }
                current++;
            }

            return null;
        }
    }
}