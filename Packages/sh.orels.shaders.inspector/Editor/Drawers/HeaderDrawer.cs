using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;
using ORL.ShaderInspector;

namespace ORL.Drawers
{
    public class HeaderDrawer : IDrawer
    {
        // Matches %ShowIf(Condition);
        private readonly Regex _matcher = new Regex(@"^(#+)");

        public bool MatchDrawer(MaterialProperty property)
        {
            return _matcher.IsMatch(property.displayName);
        }

        public string[] PersistentKeys => Array.Empty<string>();

        public bool OnGUI(
            MaterialEditor editor,
            MaterialProperty[] properties,
            MaterialProperty property,
            int index,
            ref Dictionary<string, object> uiState,
            Func<bool> next)
        {
            var matchLevel = _matcher.Match(property.displayName).Value.Length;
            if (index != 0 && EditorGUI.indentLevel > -1)
            {
                var offset = matchLevel > 1 ? 4f : 8f;
                EditorGUILayout.Space(offset * EditorGUIUtility.pixelsPerPoint);
            }

            var filteredName = property.displayName.Replace("#", "");
            filteredName = Utils.StripInternalSymbols(filteredName);
            if (matchLevel == 1)
            {
                EditorGUI.indentLevel = 0;
                var expanded = property.floatValue > 0;
                var rect = EditorGUILayout.GetControlRect();
                rect.yMax += 1f * EditorGUIUtility.pixelsPerPoint;
                rect.xMin -= 15f * EditorGUIUtility.pixelsPerPoint;
                #if UNITY_2022_1_OR_NEWER
                rect.xMin -= 15f * EditorGUIUtility.pixelsPerPoint;
                #endif
                rect.xMax += 5f * EditorGUIUtility.pixelsPerPoint;
                var dividerRect = rect;
                dividerRect.y -= 1f;
                dividerRect.height = 1f;
                GUI.Box(dividerRect, "", Styles.Divider);
                GUI.Box(rect, "", Styles.Header1BgStyle);
                var labelRect = rect;
                labelRect.y -= 1f * EditorGUIUtility.pixelsPerPoint;
                labelRect.xMin += 25f * EditorGUIUtility.pixelsPerPoint;

                if (property.floatValue < 0)
                {
                    EditorGUI.indentLevel = 1;
                }
                else
                {
                    var foldoutRect = rect;
                    foldoutRect.xMin = 15f * EditorGUIUtility.pixelsPerPoint;
                    foldoutRect.y += 2.5f * EditorGUIUtility.pixelsPerPoint;
                    foldoutRect.height -= 2.5f * EditorGUIUtility.pixelsPerPoint;
                    var evt = Event.current;

                    EditorGUI.indentLevel = expanded ? 1 : -1;
                    switch (evt.type)
                    {
                        case EventType.Repaint:
                        {
                            if (expanded)
                            {
                                Styles.FoldoutUnfolded.Draw(foldoutRect, "", false, false, true, false);
                            }
                            else
                            {
                                Styles.FoldoutFolded.Draw(foldoutRect, "", false, false, true, false);
                            }

                            break;
                        }
                        case EventType.MouseDown:
                        {
                            if (rect.Contains(evt.mousePosition))
                            {
                                property.floatValue = property.floatValue > 0 ? 0 : 1;
                            }

                            break;
                        }
                    }
                }

                GUI.Label(labelRect, filteredName, Styles.Header1TextStyle);
            }
            else if (EditorGUI.indentLevel == -1)
            {
                return true;
            }
            else
            {
                EditorGUI.indentLevel = Mathf.Min(EditorGUI.indentLevel, 1);
                var rect = EditorGUILayout.GetControlRect();
                rect.xMin -= 3f * EditorGUIUtility.pixelsPerPoint;
                EditorGUI.LabelField(rect, filteredName, EditorStyles.boldLabel);
            }

            if (EditorGUI.indentLevel > -1)
            {
                var offset = matchLevel > 1 ? 1f : 5f;
                EditorGUILayout.Space(offset * EditorGUIUtility.pixelsPerPoint);
            }

            return true;
        }
    }
}