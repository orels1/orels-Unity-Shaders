using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using ORL.ShaderInspector;
using UnityEditor;
using UnityEngine;

namespace ORL.Drawers
{
    public class Vector3Drawer : IDrawerFunc
    {
        public string FunctionName => "Vector3";

        // Matches "RemapSlider(0, 1)"
        private Regex _matcher = new Regex(@"%Vector3\(([\w\s]+),?\s?([\w\s]+),?\s?([\w\s]+)+\)");

        private float _baseOffset = 5f * EditorGUIUtility.pixelsPerPoint;

        public string[] PersistentKeys => Array.Empty<string>();

        public bool OnGUI(MaterialEditor editor, MaterialProperty[] properties, MaterialProperty property, int index,
            ref Dictionary<string, object> uiState, Func<bool> next)
        {
            if (EditorGUI.indentLevel == -1) return true;
            var match = _matcher.Match(property.displayName);
            var groups = match.Groups.Cast<Group>().Where(g => !string.IsNullOrEmpty(g.Value)).ToList();
            groups.RemoveAt(0);

            var label1 = groups[0].Value;
            var label2 = groups[1].Value;
            var label3 = groups[2].Value;

            var baseRect = EditorGUILayout.GetControlRect();
            var oldSize = EditorGUIUtility.labelWidth;
            var baseSize = (baseRect.width - oldSize) / 3.0f - 2f;
            var labelRect = baseRect;
            labelRect.width = oldSize;
            EditorGUI.LabelField(labelRect, new GUIContent(Utils.StripInternalSymbols(property.displayName)));

            EditorGUIUtility.labelWidth = baseSize - EditorGUIUtility.fieldWidth + 15f;

            baseRect.width = baseSize;
            baseRect.width -= _baseOffset;
            baseRect.x += oldSize;
            var currentValue = property.vectorValue;

            currentValue.x = EditorGUI.FloatField(baseRect, new GUIContent(label1), currentValue.x);

            var newRect = baseRect;
            newRect.x += baseSize + _baseOffset;
            currentValue.y = EditorGUI.FloatField(newRect, new GUIContent(label2), currentValue.y);

            var newRect2 = newRect;
            newRect2.x += baseSize + _baseOffset;
            currentValue.z = EditorGUI.FloatField(newRect2, new GUIContent(label3), currentValue.z);

            EditorGUIUtility.labelWidth = oldSize;

            property.vectorValue = currentValue;
            return true;
        }
    }
}
