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
            "%ShaderName",
            "%CustomEditor"
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
                foreach (var block in _dataStructs)
                {
                    var parser = new Parser();
                    var sourceStrings = Utils.GetORLSource(block);
                    var blockSource = parser.Parse(sourceStrings);
                    blocks.AddRange(blockSource);
                }
                _builtInBlocks = blocks;
                return _builtInBlocks;
            }
        }
        
        private List<ShaderBlock> _builtInFunctions;
        
        private string[] _functions = {
            "@/Functions/VertexBase",
            "@/Functions/FragmentBase"
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
                    var parser = new Parser();
                    var sourceStrings = Utils.GetORLSource(function);
                    var blockSource = parser.Parse(sourceStrings);
                    blocks.AddRange(blockSource);
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
                foreach (var library in _libraries)
                {
                    var parser = new Parser();
                    var sourceStrings = Utils.GetORLSource(library);
                    var blockSource = parser.Parse(sourceStrings);
                    blocks.AddRange(blockSource);
                }

                // Add sampling lib directly as well, we want it everywhere
                {
                    var parser = new Parser();
                    var sourceStrings = Utils.GetORLSource(_samplingLib);
                    var blockSource = parser.Parse(sourceStrings);
                    blocks.AddRange(blockSource);
                }

                _builtInLibraries = blocks;
                return _builtInLibraries;
            }
        }
        
        // Matches %BlockName without nuking %FunctionName()
        private Regex _replacerRegex = new Regex(@"(?<!\/\/\s*)(%[a-zA-Z]+[\w\d]+)(?:$|[""\;\s])");

        public override void OnImportAsset(AssetImportContext ctx)
        {
            var textContent = File.ReadAllLines(ctx.assetPath);

            var parser = new Parser();
            List<ShaderBlock> blocks;
            try
            {
                blocks = parser.Parse(textContent);
            }
            catch (Exception)
            {
                ctx.LogImportError($"Failed to parse source shader file {ctx.assetPath}");
                throw;
            }

            // Find and load the template file
            var templateBlockIndex = blocks.FindIndex(b => b.Name == "%Template");
            if (templateBlockIndex == -1)
            {
                throw new Exception("Failed to find a template block in the shader file");
            }
            var templateName = blocks[templateBlockIndex].Params[0].Replace("\"", "");
            var templatePath = Utils.ResolveORLAsset($"{templateName}.orltemplate");
            var template = Utils.GetORLTemplate(templateName);
            if (!string.IsNullOrEmpty(templatePath))
            {
                ctx.DependsOnSourceAsset(templatePath);
            }
            
            // Collecting and registering all the dependency objects
            var depList = new List<string>();
            depList.AddRange(_dataStructs);
            depList.AddRange(_functions);
            depList.AddRange(_libraries);
            depList.Add(_samplingLib);
            RegisterDependencies(depList, ctx);
            
            // Adding all the dependencies to the list of blocks
            blocks.AddRange(BuiltInBlocks);
            blocks.AddRange(BuiltInFunctions);
            blocks.AddRange(BuiltInLibraries);

            // Collapse non-function blocks together and de-dupe things where makes sense
            blocks = OptimizeBlocks(blocks);
            
            // save function blocks to a separate list as they need special handling
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

                    // Functions are a special case, they insert their code into the %Functions block
                    // And then insert a call to the function in the respective stage
                    switch (matchVal)
                    {
                        // Here we save all the function source code into the shader %Functions space
                        case "%Functions":
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
                        // Here we insert function calls into the fragment stage
                        case "%FragmentFunctions":
                        {
                            var fragmentFns = functionBlocks.FindAll(b => b.Name == "%Fragment");
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
                        // Here we insert function calls into the vertex stage
                        case "%VertexFunctions":
                        {
                            var vertexFns = functionBlocks.FindAll(b => b.Name == "%Vertex");
                            newLine.Remove(match.Index, matchLen);
                            var i = 0;
                            foreach (var functionBlock in vertexFns)
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
                    }

                    // For non-function blocks - we simply replace the block name with the block contents
                    var foundBlockIndex = blocks.FindIndex(b => b.Name == matchVal);
                    if (foundBlockIndex != -1)
                    {
                        var block = blocks[foundBlockIndex];
                        
                        // These are special single-line blocks that only insert their params value
                        if (_paramsOnlyBlock.Contains(block.Name))
                        {
                            newLine.Remove(match.Index, matchLen);
                            // To appease unity gods - we define CustomEditor "" as the template, so then if nothing is passed
                            // It doesnt outright fail
                            // We should probably just insert a fallback block instead and remove this weird condition
                            if (block.Name == "%CustomEditor")
                            {
                                newLine.Insert(match.Index, block.Params[0].Replace("\"", ""));
                            }
                            else
                            {
                                newLine.Insert(match.Index, string.Join("", block.Params));
                            }
                            continue;
                        }

                        // This is a case for special functions that are unique per shader
                        // like Vert/Fragment base
                        if (block.IsFunction)
                        {
                            newLine.Remove(match.Index, matchLen);
                            newLine.Insert(match.Index, block.CallSign);
                            continue;
                        }

                        // Simply insert the block lines if no special cases are met
                        newLine.Remove(match.Index, matchLen);
                        newLine.Insert(match.Index, IndentContents(block.Contents, match.Index));
                        continue;
                    }
                    
                    // if nothing matched - clear out the current template hook and move on
                    {
                        newLine.Remove(match.Index, matchLen);
                    }
                }

                var stringLine = newLine.ToString();
                // if there was no match - just add the line as-is
                // otherwise only add if the result wasn't whitespace
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

        private void RegisterDependencies(List<string> dependencyPaths, AssetImportContext ctx)
        {
            foreach (var s in dependencyPaths)
            {
                var path = Utils.ResolveORLAsset($"{s}.orlsource");
                if (!string.IsNullOrEmpty(path))
                {
                    ctx.DependsOnSourceAsset(path);
                    continue;
                }
                ctx.LogImportWarning("Failed to resolve dependency: " + s);
            }
        }
        
        private List<ShaderBlock> OptimizeBlocks(List<ShaderBlock> sourceBlocks)
        {
            var keySet = new Dictionary<string, int>();
            var collapsedBlocks = new List<ShaderBlock>();
            // First pass - collapse blocks with the same name
            foreach (var block in sourceBlocks)
            {
                // We do not merge function blocks because they have unique call signs
                if (block.IsFunction)
                {
                    collapsedBlocks.Add(block);
                    continue;
                }

                if (!keySet.ContainsKey(block.Name))
                {
                    keySet.Add(block.Name, collapsedBlocks.Count);
                    collapsedBlocks.Add(block);
                    continue;
                }
            
                var index = keySet[block.Name];
                collapsedBlocks[index].Contents.Add("");
                collapsedBlocks[index].Contents.AddRange(block.Contents);
            }
            // Second pass - deduplicate things where it makes sense
            for (var i = 0; i < collapsedBlocks.Count; i++)
            {
                var block = collapsedBlocks[i];
                switch (block.Name)
                {
                    case "%Properties":
                        collapsedBlocks[i].Contents = DeDuplicateByRegex(block.Contents, _propertyRegex);
                        continue;
                    case "%Variables":
                        collapsedBlocks[i].Contents = DeDuplicateByRegex(block.Contents, _varRegex);
                        continue;
                    case "%Textures":
                        collapsedBlocks[i].Contents = DeDuplicateByRegex(block.Contents, _texSamplerCombinedRegex);
                        continue;
                }
            }


            return collapsedBlocks;
        }

        // Matches _VarNames
        private Regex _propertyRegex = new Regex(@"(?:\[.*\])*\s*(?<identifier>[\w]+)(?:\(\"".*\""\,[\w\s\(\,\-\)]+\)\s*=)");
        // Matches floatX halfX and intX variables
        private Regex _varRegex = new Regex(@"(?:uniform)?(?:\s*)(?:half|float|int|real|fixed){1}(?:\d)?\s+(?<identifier>\w+)");

        // Matches either TEXTUREXXX() or SAMPLER()
        private Regex _texSamplerCombinedRegex =
            new Regex(@"(?:SAMPLER)(?:_CMP)?\(([\w]+)\)|(?:RW_)?(?:TEXTURE[23DCUBE]+[_A-Z]*)\(([\w]+)\)");
        // Matches TEXTUREXXX()
        private Regex _texRegex = new Regex(@"(?:RW_)?(?:TEXTURE[23DCUBE]+[_A-Z]*)\((?<identifier>[\w]+)\)");
        // Matches SAMPLER()
        private Regex _samplerRegex = new Regex(@"(?:SAMPLER)(?:_CMP)?\((?<identifier>[\w]+)\)");
        
        private List<string> DeDuplicateByRegex(List<String> source, Regex matcher)
        {
            var keySet = new HashSet<string>();
            var deduped = new List<string>();
            foreach (var item in source)
            {
                if (string.IsNullOrWhiteSpace(item)) continue;
                if (!matcher.IsMatch(item))
                {
                    Debug.LogWarning($"Could not find a item in {item}, adding as-is");
                    deduped.Add(item);
                    continue;
                }
                var identifier = matcher.Match(item).Groups.Cast<Group>().Skip(1).ToList().Find(m => !string.IsNullOrEmpty(m.Value)).Value;
                if (keySet.Contains(identifier))
                {
                    Debug.LogWarning("Found duplicate item, skipping: " + identifier);
                    continue;
                }
                keySet.Add(identifier);
                deduped.Add(item);
            }

            return deduped;
        }
        
        // private List<string> DeDuplicateProperties(List<String> sourceVariables)
        // {
        //     var keySet = new HashSet<string>();
        //     var deduped = new List<string>();
        //     foreach (var variable in sourceVariables)
        //     {
        //         if (string.IsNullOrWhiteSpace(variable)) continue;
        //         if (!_varRegex.IsMatch(variable))
        //         {
        //             Debug.LogWarning($"Could not find a variable in {variable}, adding as-is");
        //             deduped.Add(variable);
        //             continue;
        //         }
        //         var varName = _varRegex.Match(variable).Groups["identifier"].Value.Trim();
        //         if (keySet.Contains(varName))
        //         {
        //             Debug.LogWarning("Found duplicate variable, skipping: " + varName);
        //             continue;
        //         }
        //         keySet.Add(varName);
        //         deduped.Add(variable);
        //     }
        //
        //     return deduped;
        // }

        private string IndentContents(List<string> contents, int indentLevel)
        {
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

                if (i == contents.Count - 1)
                {
                    sb.Append(new string(' ', indentLevel) + contentLine);
                }
                else
                {
                    sb.Append(new string(' ', indentLevel) + contentLine + '\n');
                }
                i++;
            }

            return sb.ToString();
        }
    }
}