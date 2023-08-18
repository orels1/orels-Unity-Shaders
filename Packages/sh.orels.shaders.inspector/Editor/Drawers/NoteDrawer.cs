using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using ORL.ShaderInspector;
using UnityEditor;
using UnityEngine;

namespace ORL.Drawers
{
    public class NoteDrawer : IDrawer
    {
        private Regex _matcher = new Regex(@"^\??>\s");
        public bool MatchDrawer(MaterialProperty property)
        {
            return _matcher.IsMatch(property.displayName);
        }
        
        public string[] PersistentKeys => Array.Empty<string>();

        public bool OnGUI(MaterialEditor editor, MaterialProperty[] properties, MaterialProperty property, int index, ref Dictionary<string, object> uiState, Func<bool> next)
        {
            if (EditorGUI.indentLevel == -1) return true;
            var label = _matcher.Replace(property.displayName, "");
            var isConditional = property.displayName.Contains("?>");
            
            if (isConditional)
            {
                var uiKey = $"{property.name}_note_expanded";
                object isExpanded;
                if (uiState.TryGetValue(uiKey, out isExpanded))
                {
                    EditorGUILayout.LabelField(!(bool) isExpanded ? "Show Note" : "Hide Note", Styles.LinkTextStyle);

                    var lastRect = GUILayoutUtility.GetLastRect();
                    if (lastRect.Contains(Event.current.mousePosition) && Event.current.type == EventType.MouseDown)
                    {
                        uiState[uiKey] = !(bool) isExpanded;
                    }
                    if (!(bool) isExpanded) return true;
                }
                else
                {
                    isExpanded = false;
                    uiState[uiKey] = isExpanded;
                }
            }

            var strippedText = Utils.StripInternalSymbols(label);
            EditorGUILayout.LabelField(strippedText.Replace("\\n", "\n"), Styles.NoteTextStyle);
            
            return true;
        }
    }
}