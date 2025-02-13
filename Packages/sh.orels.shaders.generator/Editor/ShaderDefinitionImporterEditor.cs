using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading;
using UnityEditor;
#if UNITY_2022_3_OR_NEWER
using UnityEditor.AssetImporters;
#else
using UnityEditor.Experimental.AssetImporters;
#endif
using UnityEngine;

namespace ORL.ShaderGenerator
{
    [CustomEditor(typeof(ShaderDefinitionImporter))]
    public class ShaderDefinitionImporterEditor : ScriptedImporterEditor
    {
        private bool _includedModulesFoldout;
        private bool _sourceCodeFoldout;
        private bool _shaderCompilationIssuesFoldout;
        private bool _shaderGenerationIssuesFoldout;
        private Font _monoFont;
        private GUIStyle _monoStyle;
        private GUIStyle _boldFoldoutStyle;
        private GUIStyle _richLabelStyle;
        private Vector2 _sourceScrollPos;
        private string[] _linedText;
        private ulong _lastTimestamp;
        private int _goToLineNum;
        private int _currentLine;
        private bool _stripMacros;

        private readonly string[] _passList = {
            "ForwardBase",
            "ForwardAdd",
            "Meta",
            "ShadowCaster"
        };


        public override void OnInspectorGUI()
        {
            serializedObject.Update();
            if (_monoFont == null)
            {
                _monoFont = Font.CreateDynamicFontFromOSFont("Consolas", 12);
                _monoStyle = new GUIStyle(EditorStyles.textArea)
                {
                    font = _monoFont,
                    wordWrap = false,
                    richText = true
                };
            }

            if (_boldFoldoutStyle == null)
            {
                _boldFoldoutStyle = new GUIStyle(EditorStyles.foldout)
                {
                    fontStyle = FontStyle.Bold
                };
            }

            if (_richLabelStyle == null)
            {
                _richLabelStyle = new GUIStyle(EditorStyles.wordWrappedLabel)
                {
                    richText = true,
                };
            }

            var importer = target as ShaderDefinitionImporter;
            if (importer == null) return;

            var textSource = "";
            var assets = AssetDatabase.LoadAllAssetsAtPath(importer.assetPath);
            foreach (var asset in assets)
            {
                if (asset is TextAsset textAsset)
                {
                    var text = textAsset.text;
                    textSource = text;
                }
            }

            if (string.IsNullOrWhiteSpace(textSource))
            {
                EditorGUILayout.HelpBox("Shader failed to generate, check console for errors", MessageType.Error);
                return;
            }

            if (_linedText == null)
            {
                _linedText = textSource.Split('\n');
                for (int i = 0; i < _linedText.Length; i++)
                {
                    _linedText[i] = $"{(i + 1).ToString(),4}    {_linedText[i]}";
                }
                _lastTimestamp = importer.assetTimeStamp;
            }
            else if (_lastTimestamp != importer.assetTimeStamp)
            {
                _lastTimestamp = importer.assetTimeStamp;
                _linedText = textSource.Split('\n');
                for (int i = 0; i < _linedText.Length; i++)
                {
                    _linedText[i] = $"{(i + 1).ToString(),4}    {_linedText[i]}";
                }
            }

            if (importer.Errors.Any())
            {
                EditorGUILayout.LabelField("Shader Generation Issues", EditorStyles.boldLabel);
                foreach (var error in importer.Errors)
                {
                    var line = error.Line + error.Block.Line;
                    var snippet = new StringBuilder();
                    var currFile = string.IsNullOrWhiteSpace(error.Block.Path);
                    string[] fileContents = new string[0];
                    if (currFile)
                    {
                        fileContents = File.ReadAllLines(importer.assetPath);
                    }

                    var startLine = Mathf.Max(0, line - 5);
                    var endLine = Mathf.Min(fileContents.Length, line + 5);
                    for (int i = startLine; i < endLine; i++)
                    {
                        snippet.AppendFormat("{0,4}", i + 1);
                        snippet.Append(" ");
                        if (i + 1 == line)
                        {
                            if (error.StartIndex > -1)
                            {
                                var offset = fileContents[i].Length - fileContents[i].TrimStart().Length;
                                if (fileContents[i].Length == 0 || (error.StartIndex + offset) > fileContents[i].Length)
                                {
                                    continue;
                                }
                                snippet.Append(fileContents[i].Substring(0, error.StartIndex + offset));
                                snippet.Append("<color=#ff6188>");
                                snippet.Append(fileContents[i].Substring(error.StartIndex + offset, error.EndIndex - error.StartIndex));
                                snippet.Append("</color>");
                                snippet.Append(fileContents[i].Substring(error.EndIndex + offset));
                                snippet.AppendLine();
                            }
                            else
                            {
                                snippet.Append("<color=#ff6188>");
                                snippet.Append(fileContents[i]);
                                snippet.Append("</color>");
                                snippet.AppendLine();
                            }
                        }
                        else
                        {
                            snippet.AppendLine(fileContents[i]);
                        }
                    }

                    var message = $"{error.Message} on line <b>{line}</b>";
                    if (!currFile)
                    {
                        message += $" in {error.Block.Path}";
                    }

                    EditorGUILayout.LabelField(message, _richLabelStyle);
                    EditorGUILayout.TextArea(snippet.ToString(), _monoStyle);
                }
            }

            var finalShader = AssetDatabase.LoadAssetAtPath<Shader>(importer.assetPath);
            if (ShaderUtil.ShaderHasError(finalShader))
            {
                _shaderCompilationIssuesFoldout =
                    EditorGUILayout.Foldout(_shaderCompilationIssuesFoldout, "Shader Compilation Issues", _boldFoldoutStyle);
                // EditorGUILayout.LabelField("Shader Compilation Issues", EditorStyles.boldLabel);
                if (_shaderCompilationIssuesFoldout)
                {
                    var errors = ShaderUtil.GetShaderMessages(finalShader);
                    foreach (var error in errors)
                    {
                        var line = error.line;
                        var snippet = new StringBuilder();
                        for (int i = Mathf.Max(0, line - 5); i < Mathf.Min(_linedText.Length, line + 5); i++)
                        {
                            if (i + 1 == line)
                            {
                                snippet.Append("<color=#ff6188>");
                            }
                            snippet.Append(_linedText[i]);
                            if (i + 1 == line)
                            {
                                snippet.Append("</color>");
                            }

                            snippet.AppendLine();
                        }

                        EditorGUILayout.LabelField($"{error.message} on line {line}");
                        EditorGUILayout.TextArea(snippet.ToString(), _monoStyle);
                    }
                }
            }

            // TODO: re-enable it when parsing of shaders is multi-threaded and fast
            // EditorGUILayout.LabelField("Stats", EditorStyles.boldLabel);
            // var oldWidth = EditorGUIUtility.labelWidth;
            // EditorGUIUtility.labelWidth = 64;
            // using (new EditorGUILayout.HorizontalScope())
            // {
            //     using (new EditorGUI.DisabledScope(true))
            //     {
            //         EditorGUILayout.IntField("Features:", serializedObject.FindProperty("featureCount").intValue);
            //         EditorGUILayout.IntField("Textures:", serializedObject.FindProperty("textureCount").intValue);
            //         EditorGUILayout.IntField("Samplers:", serializedObject.FindProperty("samplerCount").intValue);
            //     }
            // }

            // EditorGUIUtility.labelWidth = oldWidth;
            // EditorGUILayout.Space();

            EditorGUILayout.LabelField("Shader Info", EditorStyles.miniBoldLabel);
            EditorGUILayout.LabelField("Lighting Model", importer.LightingModel);


            _includedModulesFoldout = EditorGUILayout.Foldout(_includedModulesFoldout, "Included Modules");
            if (_includedModulesFoldout)
            {
                using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
                {
                    foreach (var module in importer.IncludedModules)
                    {
                        var sourceAsset = AssetDatabase.LoadAssetAtPath<TextAsset>(module);
                        var sourceShader = AssetDatabase.LoadAssetAtPath<Shader>(module);
                        EditorGUILayout.ObjectField(sourceAsset != null ? sourceAsset : sourceShader, typeof(UnityEngine.Object), false);
                    }
                }
            }

            _sourceCodeFoldout = EditorGUILayout.Foldout(_sourceCodeFoldout, "Compiled Source");
            if (_sourceCodeFoldout && !string.IsNullOrWhiteSpace(textSource))
            {
                using (var c = new EditorGUI.ChangeCheckScope())
                {
                    _goToLineNum = EditorGUILayout.IntField("Go To Line", _goToLineNum);
                    if (c.changed)
                    {
                        _sourceScrollPos = new Vector2(0, 1) * (Mathf.Max(0, _goToLineNum - 5) * _monoStyle.lineHeight);
                    }
                }

                _currentLine = Mathf.Max(0, Mathf.FloorToInt(_sourceScrollPos.y / _monoStyle.lineHeight));
                EditorGUILayout.LabelField("Quick Jump", EditorStyles.boldLabel);
                using (new EditorGUILayout.HorizontalScope())
                {
                    foreach (var pass in _passList)
                    {
                        if (GUILayout.Button(pass))
                        {
                            var lineNum = Array.FindIndex(_linedText, l => l.Contains($"{pass} Pass Start"));
                            if (lineNum > -1)
                            {
                                _sourceScrollPos = new Vector2(0, 1) * (Mathf.Max(0, lineNum - 5) * _monoStyle.lineHeight);
                            }
                        }
                    }
                }
                EditorGUILayout.LabelField(new GUIContent("Closest Jump", "Jumps to the closest instance of selected type"), EditorStyles.boldLabel);
                using (new EditorGUILayout.HorizontalScope())
                {
                    var lineNum = 0;
                    if (GUILayout.Button("Vertex"))
                    {
                        lineNum = Array.FindIndex(_linedText.Skip(_currentLine).ToArray(), l => l.Contains("FragmentData Vertex(VertexData v)"));
                    }
                    if (GUILayout.Button("Fragment"))
                    {
                        lineNum = Array.FindIndex(_linedText.Skip(_currentLine).ToArray(), l => l.Contains("half4 Fragment(FragmentData i, bool facing: SV_IsFrontFace)"));
                    }

                    if (GUILayout.Button("Variables"))
                    {
                        lineNum = Array.FindIndex(_linedText.Skip(_currentLine).ToArray(), l => l.Contains("// Variables"));
                    }

                    if (GUILayout.Button("Textures"))
                    {
                        lineNum = Array.FindIndex(_linedText.Skip(_currentLine).ToArray(), l => l.Contains("// Textures"));
                    }

                    if (GUILayout.Button("Functions"))
                    {
                        lineNum = Array.FindIndex(_linedText.Skip(_currentLine).ToArray(), l => l.Contains("// Functions"));
                    }

                    if (lineNum > 0)
                    {
                        _sourceScrollPos = new Vector2(0, 1) * (Mathf.Max(0, lineNum + _currentLine - 5) * _monoStyle.lineHeight);
                    }
                }
                EditorGUILayout.Space();
                using (var sv = new EditorGUILayout.ScrollViewScope(_sourceScrollPos, GUILayout.Height(500 * EditorGUIUtility.pixelsPerPoint)))
                {
                    EditorGUILayout.TextArea(string.Join("\n", _linedText), _monoStyle);
                    _sourceScrollPos = sv.scrollPosition;
                }
                using (new EditorGUILayout.HorizontalScope())
                {
                    if (GUILayout.Button("Copy Generated Code"))
                    {
                        GUIUtility.systemCopyBuffer = textSource;
                    }
                    if (GUILayout.Button("Open in Text Editor"))
                    {
                        var path = Application.dataPath.Replace("/Assets", "/Library/TempArtifacts/Extra/");
                        var filename = Path.GetFileNameWithoutExtension(importer.assetPath);
                        path += filename + ".shader";
                        File.WriteAllText(path, textSource);
                        EditorUtility.OpenWithDefaultApp(path);
                    }
                }
            }

            EditorGUILayout.PropertyField(serializedObject.FindProperty("debugBuild"));

            EditorGUILayout.LabelField("Conversions", EditorStyles.miniBoldLabel);

            if (GUILayout.Button("Generate Static .shader File"))
            {
                ShaderDefinitionImporter.GenerateShader(importer.assetPath, importer.assetPath.Replace(".orlshader", ".shader").Replace(".orlconfshader", ".shader"), _stripMacros);
            }
            _stripMacros = EditorGUILayout.ToggleLeft("Strip Sampling Macros", _stripMacros);

            serializedObject.ApplyModifiedProperties();
            ApplyRevertGUI();
        }
    }
}