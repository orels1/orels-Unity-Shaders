using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using ORL.OdinSerializer;
using UnityEditor;
using UnityEditor.Experimental.AssetImporters;
using UnityEngine;

namespace ORL.ShaderGenerator
{
    [ScriptedImporter(1, "orlshader")]
    public class ShaderDefinitionImporter : ScriptedImporter
    {
        [OdinSerialize]
        public Dictionary<string, Shader> dependencies;

        private HashSet<string> _paramsOnlyBlock = new HashSet<string>
        {
            "ShaderName",
            "CustomEditor"
        };

        private List<ShaderBlock> _builtInBlocks;

        private string[] _dataStructs = {
            "@/Structs/VertexData",
            "@/Structs/FragmentData",
            "@/Structs/SurfaceData",
            "@/Structs/MeshData"
        };
        
        private List<ShaderBlock> BuiltInBlocks
        {
            get
            {
                if (_builtInBlocks != null) return _builtInBlocks;
                var blocks = new List<ShaderBlock>();
                var structsBlock = new ShaderBlock
                {
                    Name = "DataStructs",
                    Params = new List<string>(),
                    Contents = ""
                };
                var structs = new StringBuilder();
                foreach (var block in _dataStructs)
                {
                    var blockSource = Utils.GetORLSource(block);
                    structs.Append(string.Join("\n", blockSource));
                    // avoiding appending \r\n at the end of the file
                    structs.Append('\n');
                }

                structsBlock.Contents = structs.ToString();
                blocks.Add(structsBlock);
                _builtInBlocks = blocks;
                return _builtInBlocks;
            }
        }
        
        private List<ShaderBlock> _builtInFunctions;
        
        private Dictionary<string, string> _functions = new Dictionary<string, string>
        {
            { "VertexBase", "@/Functions/VertexBase" },
            { "FragmentBase", "@/Functions/FragmentBase" }
        };

        private Regex _callSignRegex = new Regex(@"(?:^void\s*)(?<fnName>[\w]+)\((?<params>[\w\,\s]+)\)");
        private List<ShaderBlock> BuiltInFunctions
        {
            get
            {
                if (_builtInFunctions != null) return _builtInFunctions;
                var blocks = new List<ShaderBlock>();
                foreach (var function in _functions)
                {
                    var functionBlock = new ShaderBlock
                    {
                        Name = function.Key,
                        Params = new List<string>(),
                        Contents = "",
                        IsFunction = true
                    };
                    functionBlock.Contents = string.Join("\n", Utils.GetORLSource(function.Value)) + "\n";
                    var callSignMatch = _callSignRegex.Match(functionBlock.Contents.Split('\n')[0]);
                    if (callSignMatch.Success)
                    {
                        var fnName = callSignMatch.Groups["fnName"].Value;
                        var paramsStr = callSignMatch.Groups["params"].Value;
                        var paramsList = paramsStr.Split(',');
                        paramsList = paramsList.Select(p => p.Split(' ').Last().Trim()).ToArray();
                        functionBlock.CallSign = $"{fnName}({string.Join(", ", paramsList)});";
                    }
                    blocks.Add(functionBlock);
                }

                _builtInFunctions = blocks;
                return _builtInFunctions;
            }
        }

        private string[] _libraries = {
            "@/Libraries/LightingHelpers",
            "@/Libraries/Utilities"
        };

        private string _samplingLib = "@/Libraries/SamplingLibrary";
        
        private List<ShaderBlock> _builtInLibraries;
        
        private List<ShaderBlock> BuiltInLibraries
        {
            get
            {
                if (_builtInLibraries != null) return _builtInLibraries;
                var blocks = new List<ShaderBlock>();
                var libraryBlock = new ShaderBlock
                {
                    Name = "LibraryFunctions",
                    Params = new List<string>(),
                    Contents = ""
                };
                var library = new StringBuilder();
                foreach (var block in _libraries)
                {
                    var blockSource = Utils.GetORLSource(block);
                    library.Append(string.Join("\n", blockSource));
                    // avoiding appending \r\n at the end of the file
                    library.Append('\n');
                }
                libraryBlock.Contents = library.ToString();
                blocks.Add(libraryBlock);
                
                // Add sampling lib directly as well, we want it everywhere
                var samplingLibBlock = new ShaderBlock
                {
                    Name = "SamplingLibrary",
                    Params = new List<string>(),
                    Contents = string.Join("\n", Utils.GetORLSource(_samplingLib)) + "\n"
                };
                blocks.Add(samplingLibBlock);
                
                _builtInLibraries = blocks;
                return _builtInLibraries;
            }
        }
        
        // Matches %BlockName without nuking %FunctionName()
        private Regex _replacerRegex = new Regex(@"(?<!\/\/\s*)(%[a-zA-Z]+[\w\d]+)(?:$|[""\;\s])");

        public override void OnImportAsset(AssetImportContext ctx)
        {
            var textContent = File.ReadAllLines(ctx.assetPath);
            // var shader = ShaderUtil.CreateShaderAsset("");
            
            var template = Utils.GetORLTemplate("@/Templates/Basic");
            var templatePath = Utils.ResolveORLAsset("@/Templates/Basic.orltemplate");
            if (!string.IsNullOrEmpty(templatePath))
            {
                ctx.DependsOnSourceAsset(templatePath);
            }

            foreach (var s in _dataStructs)
            {
                var path = Utils.ResolveORLAsset($"{s}.orlsource");
                if (!string.IsNullOrEmpty(path))
                {
                    ctx.DependsOnSourceAsset(path);
                }
            }

            foreach (var function in _functions)
            {
                var path = Utils.ResolveORLAsset($"{function.Value}.orlsource");
                if (!string.IsNullOrEmpty(path))
                {
                    ctx.DependsOnSourceAsset(path);
                }
            }
            
            foreach (var s in _libraries)
            {
                var path = Utils.ResolveORLAsset($"{s}.orlsource");
                if (!string.IsNullOrEmpty(path))
                {
                    ctx.DependsOnSourceAsset(path);
                }
            }

            var samplingLibPath = Utils.ResolveORLAsset($"{_samplingLib}.orlsource");
            if (!string.IsNullOrEmpty(samplingLibPath))
            {
                ctx.DependsOnSourceAsset(samplingLibPath);
            }

            var blocks = Parser.ParseShaderDefinition(textContent);
            blocks.AddRange(BuiltInBlocks);
            blocks.AddRange(BuiltInFunctions);
            blocks.AddRange(BuiltInLibraries);
            
            var functionBlocks = blocks.Where(b => b.IsFunction).Reverse().ToList();

            var finalShader = new StringBuilder();
            foreach (var line in template)
            {
                var newLine = new StringBuilder(line);
                var hadMatch = false;
                while (_replacerRegex.IsMatch(newLine.ToString()))
                {
                    hadMatch = true;
                    var match = _replacerRegex.Match(newLine.ToString());
                    var matchVal = match.Groups[1].Value;
                    var matchLen = matchVal.Length;
                    if (matchVal == "%Functions")
                    {
                        newLine.Remove(match.Index, matchLen);
                        var i = 0;
                        foreach (var functionBlock in functionBlocks)
                        {
                            if (i > 0)
                            {
                                newLine.Insert(match.Index, new string(' ', match.Index));
                                newLine.Insert(match.Index, "\n\n");
                            }
                            newLine.Insert(match.Index, IndentContents(functionBlock.Contents, match.Index));
                            i++;
                        }

                        continue;
                    }

                    if (matchVal == "%FragmentFunctions")
                    {
                        var fragmentFns = functionBlocks.FindAll(b => b.Name == "Fragment");
                        newLine.Remove(match.Index, matchLen);
                        var i = 0;
                        foreach (var functionBlock in fragmentFns)
                        {
                            if (i > 0)
                            {
                                newLine.Insert(match.Index, new string(' ', match.Index));
                                newLine.Insert(match.Index, "\n\n");
                            }
                            newLine.Insert(match.Index, functionBlock.CallSign);
                            i++;
                        }
                        continue;
                    }
                    var foundBlockIndex = blocks.FindIndex(b => $"%{b.Name}" == matchVal);
                    if (foundBlockIndex != -1)
                    {
                        var block = blocks[foundBlockIndex];
                        // These are special single-line blocks that only insert their params value
                        if (_paramsOnlyBlock.Contains(block.Name))
                        {
                            newLine.Remove(match.Index, matchLen);
                            if (block.Name == "CustomEditor")
                            {
                                newLine.Insert(match.Index, block.Params[0].Replace("\"", ""));
                            }
                            else
                            {
                                newLine.Insert(match.Index, string.Join("", block.Params));
                            }
                            continue;
                        }

                        // We only want to insert function calls into the main hook spots
                        // Function source is inserted differently
                        // These are handled for unique blocks like Vert/Fragment base
                        if (block.IsFunction)
                        {
                            newLine.Remove(match.Index, matchLen);
                            newLine.Insert(match.Index, block.CallSign);
                            continue;
                        }

                        var baseOffset = match.Index;
                        var contents = block.Contents.Split('\n');
                        var sb = new StringBuilder();
                        var i = 0;
                        foreach (var contentLine in contents)
                        {
                            if (i == 0)
                            {
                                sb.Append(contentLine + '\n');
                                i++;
                                continue;
                            }

                            if (i == contents.Length - 1)
                            {
                                sb.Append(contentLine.Insert(0, new string(' ', baseOffset)));
                            }
                            else
                            {
                                sb.Append(contentLine.Insert(0, new string(' ', baseOffset)) + '\n');
                            }
                            i++;
                        }

                        newLine.Remove(match.Index, matchLen);
                        newLine.Insert(match.Index, sb.ToString());
                        continue;
                    }
                    
                    // if nothing matched - clear out the current template hook and move on
                    {
                        newLine.Remove(match.Index, matchLen);
                    }
                }

                var stringLine = newLine.ToString();
                if (!string.IsNullOrWhiteSpace(stringLine) || !hadMatch)
                {
                    finalShader.AppendLine(stringLine);
                }
            }
            
            var shaderString = finalShader.ToString();
            // Debug.Log(shaderString);
            var shader = ShaderUtil.CreateShaderAsset(ctx, shaderString, true);
            // shader.name = Path.GetFileNameWithoutExtension(Utils.GetFullPath(ctx.assetPath));

            if (ShaderUtil.ShaderHasError(shader))
            {
                var errors = ShaderUtil.GetShaderMessages(shader);
                foreach (var error in errors)
                {
                    ctx.LogImportError(error.message + $"on line {error.line} in {ctx.assetPath}");
                }
            }
            else
            {
                ShaderUtil.ClearShaderMessages(shader);
            }

            var textAsset = new TextAsset(shaderString)
            {
                name = "Shader Source",
                hideFlags = HideFlags.HideInHierarchy
            };
            
            ctx.AddObjectToAsset("Shader", shader);
            ctx.SetMainObject(shader);
            ctx.AddObjectToAsset("Shader Source", textAsset);
        }

        private string IndentContents(string contents, int indentLevel)
        {
            var split = contents.Split('\n');
            var sb = new StringBuilder();
            var i = 0;
            foreach (var contentLine in split)
            {
                if (i == 0)
                {
                    sb.Append(contentLine + '\n');
                    i++;
                    continue;
                }

                if (i == split.Length - 1)
                {
                    sb.Append(contentLine.Insert(0, new string(' ', indentLevel)));
                }
                else
                {
                    sb.Append(contentLine.Insert(0, new string(' ', indentLevel)) + '\n');
                }
                i++;
            }

            return sb.ToString();
        }
    }
}