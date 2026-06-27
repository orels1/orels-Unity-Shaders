using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using ORL.ShaderInspector;
using UnityEditor;
using UnityEngine;

namespace ORL.Drawers
{
    public class LinearDrawer : IDrawerFunc
    {
        public string FunctionName => "Linear";
        public bool InvokeAfterDraw => true;

        // Matches %Linear(Optional Message)
        private Regex _matcher = new Regex(@"%Linear\((?<message>[\w\d\s]*)?\)");

        public string[] PersistentKeys => Array.Empty<string>();
        
        private const string DEFAULT_MESSAGE = "Provided texture is set to sRGB, while this texture slot expects a linear texture. This is likely to cause incorrect results.";

        public bool OnGUI(MaterialEditor editor, MaterialProperty[] properties, MaterialProperty property, int index, ref Dictionary<string, object> uiState, Func<bool> next)
        {
            if (EditorGUI.indentLevel == -1) return true;

            var match = _matcher.Match(property.displayName);
            var message = match.Groups["message"].Value;
            if (property.type != MaterialProperty.PropType.Texture) return next();

            var isLinear = !property.textureValue.isDataSRGB;

            if (!isLinear)
            {
                using var box = new EditorGUILayout.VerticalScope(EditorStyles.helpBox);
                using (new EditorGUILayout.HorizontalScope())
                {
                    EditorGUILayout.LabelField(string.IsNullOrWhiteSpace(message) ? DEFAULT_MESSAGE : message, EditorStyles.wordWrappedLabel);
                    if (GUILayout.Button(new GUIContent("Auto Fix", "Switches the texture to use linear color space"), GUILayout.ExpandHeight(true)))
                    {
                        var assetPath = AssetDatabase.GetAssetPath(property.textureValue);
                        var importer = AssetImporter.GetAtPath(assetPath) as TextureImporter;
                        if (importer == null) return next();
                        Undo.RegisterImporterUndo(assetPath, $"Switching {property.textureValue.name} to Linear");
                        importer.sRGBTexture = false;
                        importer.SaveAndReimport();
                    }
                }
            }

            return next();
        }
    }
}
