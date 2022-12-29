using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using ORL.ShaderInspector;
using UnityEditor;
using UnityEngine;

namespace ORL.Drawers
{
    public class RemapSliderDrawer : IDrawerFunc
    {
        public string FunctionName => "RemapSlider";

        // Matches "RemapSlider(0, 1)"
        private Regex _matcher = new Regex(@"%RemapSlider\(([\d]+),?\s?([\d]+)+\)");
        
        public string[] PersistentKeys => Array.Empty<string>();
        
        public bool OnGUI(MaterialEditor editor, MaterialProperty[] properties, MaterialProperty property, int index, ref Dictionary<string, object> uiState, Func<bool> next)
        {
            if (EditorGUI.indentLevel == -1) return true;
            
            var match = _matcher.Match(property.displayName);
            var groups = match.Groups.Cast<Group>().Where(g => !string.IsNullOrEmpty(g.Value)).ToList();
            groups.RemoveAt(0);

            var min = float.Parse(groups[0].Value);
            var max = float.Parse(groups[1].Value);

            var currValue = property.vectorValue;

            var strippedName = Utils.StripInternalSymbols(property.displayName);
            
            var baseRect = EditorGUILayout.GetControlRect();
            var maxSliderSize = baseRect.width * 0.62f;
            var labelRect = baseRect;
            labelRect.width = EditorStyles.label.CalcSize(new GUIContent(strippedName)).x + 20f * EditorGUIUtility.pixelsPerPoint;
            baseRect.x = EditorGUIUtility.labelWidth + 6.0f;
            baseRect.width = EditorGUIUtility.currentViewWidth - EditorGUIUtility.labelWidth - 28f;

            EditorGUI.BeginChangeCheck();
            EditorGUI.LabelField(labelRect, strippedName);
            EditorGUI.MinMaxSlider(baseRect, "", ref currValue.x, ref currValue.y, min, max);
            if (EditorGUI.EndChangeCheck())
            {
                property.vectorValue = currValue;
            }
            return true;
        }
    }
}