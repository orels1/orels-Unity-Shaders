using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using ORL.ShaderInspector;
using UnityEditor;
using UnityEngine;

namespace ORL.Drawers
{
    public class LinkDrawer : IDrawer
    {
        private Regex _matcher = new Regex(@"^\[(?<label>[\w\d\(\)\s\?\!\>\<\:]+)\]\((?<link>[\w\-\+\:\/\/\.\#\$\?\=]+)\)");
        public bool MatchDrawer(MaterialProperty property)
        {
            return _matcher.IsMatch(property.displayName);
        }
        
        public string[] PersistentKeys => Array.Empty<string>();

        public bool OnGUI(MaterialEditor editor, MaterialProperty[] properties, MaterialProperty property, int index,
            ref Dictionary<string, object> uiState, Func<bool> next)
        {
            if (EditorGUI.indentLevel == -1) return true;

            var match = _matcher.Match(property.displayName);
            var label = match.Groups["label"].Value;

            EditorGUILayout.LabelField(label, Styles.LinkTextStyle);
            var rect = GUILayoutUtility.GetLastRect();
            EditorGUIUtility.AddCursorRect(rect, MouseCursor.Link);
            if (Event.current.type is EventType.MouseDown)
            {
                if (rect.Contains(Event.current.mousePosition))
                {
                    Application.OpenURL(match.Groups["link"].Value);
                }
            }
            var labelSize = Styles.LinkTextStyle.CalcSize(new GUIContent(label));
            rect.y += labelSize.y + 0.5f * EditorGUIUtility.pixelsPerPoint;
            rect.xMin += EditorGUI.indentLevel * 15f;
            rect.width = labelSize.x;
            rect.height = 0.5f * EditorGUIUtility.pixelsPerPoint;
            EditorGUI.DrawRect(rect, Styles.LinkTextStyle.normal.textColor);

            return true;
        }
    }
}