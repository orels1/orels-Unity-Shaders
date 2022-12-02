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

        public override void OnInspectorGUI()
        {
            serializedObject.Update();
            if (_monoFont == null)
            {
                _monoFont = Font.CreateDynamicFontFromOSFont("Consolas", 12);
            }

            var importer = target as ShaderDefinitionImporter;
            if (importer == null) return;

            _sourceCodeFoldout = EditorGUILayout.Foldout(_sourceCodeFoldout, "Source");
            if (_sourceCodeFoldout)
            {
                EditorGUI.indentLevel++;
                var assets = AssetDatabase.LoadAllAssetsAtPath(importer.assetPath);
                foreach (var asset in assets)
                {
                    if (asset is TextAsset textAsset)
                    {
                        var text = textAsset.text;
                        var split = text.Split('\n');
                        for (int i = 0; i < split.Length; i++)
                        {
                            split[i] = $"{(i + 1).ToString(),4}    {split[i]}";
                        }

                        text = string.Join("\n", split);
                        var style = new GUIStyle(EditorStyles.textArea)
                        {
                            font = _monoFont,
                            wordWrap = false
                        };
                        EditorGUILayout.TextArea(text, style);
                    }
                }

                EditorGUI.indentLevel--;
            }

            serializedObject.ApplyModifiedProperties();
            ApplyRevertGUI();
        }
    }
}