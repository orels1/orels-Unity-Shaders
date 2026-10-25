using System;
using System.Collections.Generic;
using System.Text;
using UnityEditor;
using UnityEngine;
#if ORL_SHADER_GENERATOR
using ORL.ShaderGenerator;
using UnityShaderParser.ShaderLab;
#endif

namespace ORL.ShaderInspector
{
    public class LocalizationHelpers: EditorWindow
    {
        [MenuItem("Tools/orels1/Localization Helpers")]
        public static void ShowWindow()
        {
            var window = GetWindow<LocalizationHelpers>(true);
            window.titleContent = new GUIContent($"ORL Localization Helpers");
            window.minSize = new Vector2(300, 600);
            window.Show();
        }

        private TextAsset _sourceAsset;
        private Dictionary<string, string> _properties;

        private void OnGUI()
        {
            using var check = new EditorGUI.ChangeCheckScope();
            _sourceAsset = EditorGUILayout.ObjectField(_sourceAsset, typeof(TextAsset), false) as TextAsset;

            if (check.changed)
            {
#if ORL_SHADER_GENERATOR
                var parser = new Parser();
                _properties = new Dictionary<string, string>();
                var lines = _sourceAsset.text.Split(Environment.NewLine);
                var blocks = parser.Parse(lines, AssetDatabase.GetAssetPath(_sourceAsset));
                var properties = blocks.Find(b => b.CoreBlockType == ShaderBlock.BlockType.Properties);
                
                var combined = string.Join(Environment.NewLine, properties.Contents);
                var tokens = ShaderLabLexer.Lex(combined, null, null, false, out _);
                var nodes = ShaderLabParser.ParseShaderProperties(tokens, ShaderAnalyzers.SLConfig, out _);
                foreach (var node in nodes)
                {
                    _properties.Add(node.Uniform, Utils.StripInternalSymbols(node.Name.Replace("#", "")));
                }
#endif
            }
            
            if (GUILayout.Button("Copy Names"))
            {
                var sb = new StringBuilder();
                foreach (var kvp in _properties)
                {
                    sb.Append(kvp.Key);
                    sb.Append(";");
                    sb.Append(kvp.Value);
                    sb.AppendLine();
                }

                EditorGUIUtility.systemCopyBuffer = sb.ToString();
            }
        }
    }
}