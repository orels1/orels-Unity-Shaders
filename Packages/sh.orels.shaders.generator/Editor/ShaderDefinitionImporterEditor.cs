using System;
using System.Linq;
using System.Text;
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
        private bool _sourceCodeFoldout;
        private Font _monoFont;
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
            } else if (_lastTimestamp != importer.assetTimeStamp)
            {
                _lastTimestamp = importer.assetTimeStamp;
                _linedText = textSource.Split('\n');
                for (int i = 0; i < _linedText.Length; i++)
                {
                    _linedText[i] = $"{(i + 1).ToString(),4}    {_linedText[i]}";
                }
            }

            var finalShader = AssetDatabase.LoadAssetAtPath<Shader>(importer.assetPath);
            if (ShaderUtil.ShaderHasError(finalShader))
            {
                EditorGUILayout.LabelField("Shader Compilation Issues", EditorStyles.boldLabel);
                var errors = ShaderUtil.GetShaderMessages(finalShader);
                foreach (var error in errors)
                {
                    var line = error.line;
                    var snippet = new StringBuilder();
                    for (int i = Mathf.Max(0, line - 10); i < Mathf.Min(_linedText.Length, line + 10); i++)
                    {
                        snippet.AppendLine(_linedText[i]);
                    }

                    EditorGUILayout.LabelField($"{error.message} on line {line}");
                    EditorGUILayout.TextArea(snippet.ToString());
                }
            }

            EditorGUILayout.LabelField("Stats", EditorStyles.boldLabel);
            var oldWidth = EditorGUIUtility.labelWidth;
            EditorGUIUtility.labelWidth = 64;
            using (new EditorGUILayout.HorizontalScope())
            {
                using (new EditorGUI.DisabledScope(true))
                {
                    EditorGUILayout.IntField("Features:", serializedObject.FindProperty("featureCount").intValue);
                    EditorGUILayout.IntField("Textures:", serializedObject.FindProperty("textureCount").intValue);
                    EditorGUILayout.IntField("Samplers:", serializedObject.FindProperty("samplerCount").intValue);
                }
            }

            EditorGUIUtility.labelWidth = oldWidth;
            EditorGUILayout.Space();
            _sourceCodeFoldout = EditorGUILayout.Foldout(_sourceCodeFoldout, "Compiled Source");
            if (_sourceCodeFoldout && !string.IsNullOrWhiteSpace(textSource))
            {
                var style = new GUIStyle(EditorStyles.textArea)
                {
                    font = _monoFont,
                    wordWrap = false
                };
                using (var c = new EditorGUI.ChangeCheckScope())
                {
                    _goToLineNum = EditorGUILayout.IntField("Go To Line", _goToLineNum);
                    if (c.changed)
                    {
                        _sourceScrollPos = new Vector2(0, 1) * (Mathf.Max(0, _goToLineNum - 5) * (style.lineHeight + 0.4f));
                    }
                }

                _currentLine = Mathf.Max(0, Mathf.FloorToInt(_sourceScrollPos.y / (style.lineHeight + 0.4f)));
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
                                _sourceScrollPos = new Vector2(0, 1) * (Mathf.Max(0, lineNum - 5) * (style.lineHeight + 0.4f));
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
                        _sourceScrollPos = new Vector2(0, 1) * (Mathf.Max(0, lineNum + _currentLine - 5) * (style.lineHeight + 0.4f));
                    }
                }
                EditorGUILayout.Space();
                using (var sv = new EditorGUILayout.ScrollViewScope(_sourceScrollPos, GUILayout.Height(500 * EditorGUIUtility.pixelsPerPoint)))
                {
                    EditorGUILayout.TextArea(string.Join("\n", _linedText), style);
                    _sourceScrollPos = sv.scrollPosition;
                }
            }

            EditorGUILayout.PropertyField(serializedObject.FindProperty("debugBuild"));

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