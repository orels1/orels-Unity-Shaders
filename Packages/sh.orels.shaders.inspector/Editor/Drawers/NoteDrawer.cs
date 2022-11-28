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
        private Regex _matcher = new Regex(@"^>\s");
        public bool MatchDrawer(MaterialProperty property)
        {
            return _matcher.IsMatch(property.displayName);
        }

        public bool OnGUI(MaterialEditor editor, MaterialProperty[] properties, MaterialProperty property, int index, Dictionary<string, object> uiState, Func<bool> next)
        {
            if (EditorGUI.indentLevel == -1) return true;
            var label = _matcher.Replace(property.displayName, "");

            var strippedText = Utils.StripInternalSymbols(label);

            EditorGUILayout.LabelField(strippedText, Styles.NoteTextStyle);
            
            return true;
        }
    }
}