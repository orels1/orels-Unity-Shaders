using System;
using System.Collections.Generic;
using System.Text;
using UnityEditor;
using UnityEngine;

namespace ORL.ShaderInspector
{
    public class LocalizationHelpers : EditorWindow
    {
        // Generates a localization scaffolding for a shader
        [MenuItem("Tools/orels1/Localization Helpers")]
        public static void ShowWindow()
        {
            var window = GetWindow<LocalizationHelpers>(true);
            window.titleContent = new GUIContent("ORL Localization Helpers");
            window.minSize = new Vector2(300, 600);
            window.Show();
        }

        private TextAsset _sourceAsset;
        private List<KeyValuePair<string, string>> _properties;

        private void OnGUI()
        {
            using var check = new EditorGUI.ChangeCheckScope();
            _sourceAsset = (TextAsset)EditorGUILayout.ObjectField("Source File", _sourceAsset, typeof(TextAsset), false);
            if (check.changed)
            {
                _properties = _sourceAsset == null
                    ? new List<KeyValuePair<string, string>>()
                    : LocalizationCache.GetAssetProperties(AssetDatabase.GetAssetPath(_sourceAsset));
            }

            if (_sourceAsset == null)
            {
                EditorGUILayout.HelpBox("Assign a .orlsource file to extract the property names from", MessageType.Info);
                return;
            }
            if (_properties == null || _properties.Count == 0)
            {
                EditorGUILayout.HelpBox("No properties found in the assigned file", MessageType.Warning);
                return;
            }

            EditorGUILayout.LabelField($"Found {_properties.Count} properties", EditorStyles.miniLabel);

            if (GUILayout.Button("Copy Localization Template"))
            {
                var sb = new StringBuilder();
                sb.AppendLine("# Localization for <module name>");
                sb.AppendLine();
                foreach (var kvp in _properties)
                {
                    sb.Append('[').Append(kvp.Key).AppendLine("]");
                    sb.Append("name.en = ").AppendLine(kvp.Value);
                    sb.AppendLine();
                }
                EditorGUIUtility.systemCopyBuffer = sb.ToString();
            }

            EditorGUILayout.HelpBox(
                "\"Copy Localization Template\" copies a ready-to-fill block-format localization file.",
                MessageType.None);
        }
    }
}
