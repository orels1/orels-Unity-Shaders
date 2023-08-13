using System.Text;
using UnityEditor;
using UnityEditor.Experimental.AssetImporters;
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

            _sourceCodeFoldout = EditorGUILayout.Foldout(_sourceCodeFoldout, "Compiled Source");
            if (_sourceCodeFoldout && !string.IsNullOrWhiteSpace(textSource))
            {
                var style = new GUIStyle(EditorStyles.textArea)
                {
                    font = _monoFont,
                    wordWrap = false
                };
                using (var sv = new EditorGUILayout.ScrollViewScope(_sourceScrollPos, GUILayout.Height(500 * EditorGUIUtility.pixelsPerPoint)))
                {
                    EditorGUILayout.TextArea(string.Join("\n", _linedText), style);
                    _sourceScrollPos = sv.scrollPosition;
                }
            }

            EditorGUILayout.PropertyField(serializedObject.FindProperty("debugBuild"));

            if (GUILayout.Button("Generate Static .shader File"))
            {
                ShaderDefinitionImporter.GenerateShader(importer.assetPath, importer.assetPath.Replace(".orlshader", ".shader").Replace(".orlconfshader", ".shader"));
            }

            serializedObject.ApplyModifiedProperties();
            ApplyRevertGUI();
        }
    }
}