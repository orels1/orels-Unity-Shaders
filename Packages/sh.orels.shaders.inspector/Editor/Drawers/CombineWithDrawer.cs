﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using ORL.ShaderInspector;
using UnityEditor;
using UnityEngine;

namespace ORL.Drawers
{
    public class CombineWithDrawer : IDrawerFunc
    {
        public string FunctionName => "CombineWith";

        // Matches %CombineWith(PropNames);
        private Regex _matcher = new Regex(@"%CombineWith\(([\w]+),?\s?([\w]+)?,?\s?([\w]+)?\)");

        private float _baseOffset = 5f * EditorGUIUtility.pixelsPerPoint;

        public string[] PersistentKeys => Array.Empty<string>();

        public bool OnGUI(MaterialEditor editor, MaterialProperty[] properties, MaterialProperty property, int index, ref Dictionary<string, object> uiState, Func<bool> next)
        {
            if (EditorGUI.indentLevel == -1) return true;

            var match = _matcher.Match(property.displayName);
            var strippedName = Utils.StripInternalSymbols(property.displayName);
            var groups = match.Groups.Cast<Group>().Where(g => !string.IsNullOrEmpty(g.Value)).ToList();
            groups.RemoveAt(0);

            var baseRect = EditorGUILayout.GetControlRect();
            var baseSize = baseRect.width / (groups.Count + 1);

            baseRect.width = baseSize;
            baseRect.width -= _baseOffset;
            DrawElement(baseRect, editor, property, index);

            var i = 1;
            foreach (var group in groups)
            {
                var propIndex = Array.FindIndex(properties,
                    p => p.name == group.Value);
                if (propIndex == -1)
                {
                    Debug.LogWarning($"Unable to find prop {group.Value} to draw in a group with {property.name}");
                    continue;
                }

                var newRect = baseRect;
                newRect.x += (baseSize) * i + _baseOffset;
                DrawElement(newRect, editor, properties[propIndex], propIndex);
                i++;
            }
            return true;
        }

        private void DrawElement(Rect controlRect, MaterialEditor editor, MaterialProperty property, int index)
        {
            var localRect = controlRect;
            var name = Utils.StripInternalSymbols(property.displayName);
            var labelSize = EditorStyles.label.CalcSize(new GUIContent(name));
            labelSize.x += _baseOffset;
            var labelRect = localRect;
            labelRect.width = labelSize.x * EditorGUIUtility.pixelsPerPoint;

            var defaultProps = (editor.target as Material).shader.GetPropertyAttributes(index);
            var enumAttribute = Array.Find(defaultProps, attr => attr.StartsWith("Enum("));

            if (!string.IsNullOrWhiteSpace(enumAttribute))
            {
                localRect.xMin += labelSize.x;
                EditorGUI.LabelField(labelRect, name);
                editor.ShaderProperty(localRect, property, new GUIContent(""));
                return;
            }

            editor.ShaderProperty(localRect, property, new GUIContent(name));
        }
    }
}