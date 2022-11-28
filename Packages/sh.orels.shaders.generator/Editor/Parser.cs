using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using UnityEngine;

namespace ORL.ShaderGenerator
{
    public struct ShaderBlock
    {
        public string Name { get; set; }
        public List<string> Params { get; set; }
        public string Contents { get; set; }

        public bool IsFunction { get; set; }
        
        public string CallSign { get; set; }
    }

    public class Parser
    {
        private static HashSet<string> _functionIdentifiers = new HashSet<string>
        {
            "Fragment",
            "Vertex",
            "TessFactor",
            "Color",
            "Shadow"
        };
        
        private static Regex _callSignRegex = new Regex(@"(?<fnName>[\w]+)\((?<params>[\w\,\s]+)\)");
        public static List<ShaderBlock> ParseShaderDefinition(string[] lines)
        {
            var current = 0;
            var source = string.Join("\n", lines);
            var length = source.Length;
            var results = new List<ShaderBlock>();
            
            var newLine = true;
            while (current < length)
            {
                switch (source[current])
                {
                    case '%':
                        if (!newLine)
                        {
                            break;
                        }
                        if (IsLetter(Peek(current, source)))
                        {
                            var blockName = ConsumeUntil('(', ref current, source);
                            if (!string.IsNullOrEmpty(blockName))
                            {
                                blockName = blockName.Substring(1);
                                current++;
                                var paramsString = ConsumeUntil(')', ref current, source);
                                var paramsList = new List<string>();
                                if (!string.IsNullOrEmpty(paramsString))
                                {
                                    // paramsString = paramsString.Substring(1);
                                    paramsList.AddRange(paramsString.Split(',').Select(s => s.Trim()));
                                }
                                var contents = "";
                                if (ExistsInBlock('{', current, source))
                                {
                                    SeekUntilChar('{', ref current, source);
                                    SeekToNextLine(ref current, source);
                                    current++;
                                    var start = current;
                                    SeekUntilBlockEnd(ref current, source);
                                    contents = source.Substring(start, current - start);
                                    var split = contents.Split('\n');
                                    var baseOffset = 0;
                                    for (int i = 0; i < split.Length; i++)
                                    {
                                        if (string.IsNullOrWhiteSpace(split[i])) continue;
                                        var converted = split[i].Replace("\t", "    ");
                                        var offset = converted.TakeWhile(c => c == ' ').Count();
                                        baseOffset = offset;
                                        break;
                                    }
                                    for (int i = 0; i < split.Length; i++)
                                    {
                                        var lineStart = Mathf.Min(baseOffset, split[i].Replace("\t", "    ").TakeWhile(c => c == ' ').Count());
                                        split[i] = split[i].Substring(lineStart);
                                    }
                                    contents = string.Join("\n", split);
                                }

                                var newBlock = new ShaderBlock
                                {
                                    Name = blockName,
                                    Params = paramsList,
                                    Contents = contents
                                };
                                if (_functionIdentifiers.Contains(blockName))
                                {
                                    newBlock.IsFunction = true;
                                    var fnStartIndex = newBlock.Contents.IndexOf(newBlock.Params[0].Replace("\"", ""),StringComparison.InvariantCulture);
                                    if (fnStartIndex > 0)
                                    {
                                        var callSignLine = newBlock.Contents.Substring(fnStartIndex, newBlock.Contents.Substring(fnStartIndex).IndexOf(')') + 1) + ";";
                                        var callSignMatch = _callSignRegex.Match(callSignLine);
                                        var fnName = callSignMatch.Groups["fnName"].Value;
                                        var paramsStr = callSignMatch.Groups["params"].Value;
                                        var fnParams = paramsStr.Split(',');
                                        fnParams = fnParams.Select(p => p.Split(' ').Last().Trim()).ToArray();
                                        newBlock.CallSign = $"{fnName}({string.Join(", ", fnParams)});";
                                    }
                                }
                                
                                // Debug.Log($"{newBlock.Name}  ({paramsString})\n{contents}");
                                results.Add(newBlock);
                            }
                        }

                        break;
                    case ' ':
                        break;
                    case '\t':
                        break;
                    case '/':
                        if (Match('/', current, source))
                        {
                            SeekToNextLine(ref current, source);
                            newLine = true;
                        }
                        break;
                    case '\n':
                        newLine = true;
                        break;
                    default:
                        newLine = false;
                        break;
                }
                current++;
            }

            return results;
        }

        private static bool IsLetter(char source)
        {
            return char.IsLetter(source);
        }

        private static char Peek(int current, string source)
        {
            if (current + 1 >= source.Length)
            {
                return '\0';
            }
            return source[current + 1];
        }

        private static bool Match(char toMatch, int current, string source)
        {
            if (current + 1 >= source.Length)
            {
                return false;
            }

            return source[current + 1] == toMatch;
        }

        private static void SeekToNextLine(ref int current, string source)
        {
            while (source[current] != '\n')
            {
                if (current + 1 < source.Length)
                {
                    current++;
                }
            }
        }

        private static bool ExistsInBlock(char toFind, int current, string source)
        {
            var pos = current;
            while (pos + 1 < source.Length)
            {
                if (source[pos + 1] == toFind)
                {
                    return true;
                }

                if (source[pos + 1] == '%')
                {
                    return false;
                }
                pos++;
            }

            return false;
        }

        private static void SeekUntilChar(char toMatch, ref int current, string source)
        {
            if (current + 1 >= source.Length)
            {
                return;
            }
            while (source[current + 1] != toMatch)
            {
                if (current + 1 < source.Length)
                {
                    current++;
                }
                else
                {
                    return;
                }
            }

            current++;
        }

        private static void SeekUntilBlockEnd(ref int current, string source)
        {
            var nestLevel = 1;
            while (current + 1 < source.Length)
            {
                switch (source[current + 1])
                {
                    case '{':
                        nestLevel++;
                        break;
                    case '}':
                        nestLevel--;
                        break;
                }
                if (nestLevel == 0)
                {
                    return;
                }

                current++;
            }
        }

        private static string ConsumeUntil(char endMarker, ref int current, string source)
        {
            var start = current;
            while (source[current] != '\n')
            {
                if (current + 1 >= source.Length)
                {
                    return null;
                }
                if (source[current + 1] == endMarker)
                {
                    var result = source.Substring(start, current + 1 - start);
                    current++;
                    return result;
                }
                current++;
            }

            return null;
        }
    }
}