using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;

namespace ORL.Drawers
{
    public class SeparatorDrawer : IDrawer
    {
        private Regex _matcher = new Regex(@"^---");
        public bool MatchDrawer(MaterialProperty property)
        {
            return _matcher.IsMatch(property.displayName);
        }

        public string[] PersistentKeys => Array.Empty<string>();

        public bool OnGUI(MaterialEditor editor, MaterialProperty[] properties, MaterialProperty property, int index, ref Dictionary<string, object> uiState, Func<bool> next)
        {
            if (EditorGUI.indentLevel == -1) return true;

            EditorGUILayout.Space(8);
            var rect = EditorGUILayout.GetControlRect(GUILayout.Height(1));
            rect.xMin += 1;
            EditorGUI.DrawRect(rect, new Color(0.5f, 0.5f, 0.5f, 1));

            return true;
        }
    }
}