using System.Reflection;
using UnityEditor;
using UnityEngine;

namespace ORL.ShaderInspector
{
    public static class Styles
    {
        public static void InitTextureStyles() {
            Header1BgStyle = new GUIStyle
            {
                normal = new GUIStyleState
                {
                    background = CreateTexture(new Color(0f,0f,0f,0.3f))
                }
            };

            Divider = new GUIStyle
            {
                fixedHeight = 1f,
                normal = new GUIStyleState
                {
                    background = CreateTexture(new Color(0f, 0f, 0f, 0.6f))
                }
            };
        }

        public static Texture2D CreateTexture(Color color)
        {
            var tex = new Texture2D(1, 1);
            tex.SetPixel(0, 0, color);
            tex.Apply();
            return tex;
        }

        public static GUIStyle Divider = new GUIStyle
        {
            fixedHeight = 1f,
            normal = new GUIStyleState
            {
                background = CreateTexture(new Color(0f, 0f, 0f, 0.6f))
            }
        };

        public static GUIStyle CustomDividerStyle(float height, Color color)
        {
            return new GUIStyle
            {
                fixedHeight = height,
                normal = new GUIStyleState
                {
                    background = CreateTexture(color),
                }
            };
        }

        public static GUIStyle Header1BgStyle = new GUIStyle
        {
            normal = new GUIStyleState
            {
                background = CreateTexture(new Color(0f,0f,0f,0.3f))
            }
        };

        public static GUIStyle Header1TextStyle = new GUIStyle
        {
            fontSize = 12,
            fontStyle = FontStyle.Bold,
            alignment = TextAnchor.MiddleLeft,
            normal = new GUIStyleState
            {
                textColor = new Color(1f,1f,1f, 0.8f),
            }
        };

        public static GUIStyle NoteTextStyle = new GUIStyle
        {
            fontSize = 11,
            wordWrap = true,
            margin = new RectOffset(19, 0, 0, 0),
            normal = new GUIStyleState
            {
                textColor = new Color(1f,1f,1f, 0.5f),
            }
        };

        public static GUIStyle LinkTextStyle = new GUIStyle
        {
            fontSize = 11,
            wordWrap = true,
            normal = new GUIStyleState
            {
                textColor = new Color(64f/255f, 206f/255f, 245f/255f),
            }
        };

        private static GUIStyle _foldoutFolded;

        public static GUIStyle FoldoutFolded
        {
            get
            {
                if (_foldoutFolded != null) return _foldoutFolded;
                _foldoutFolded = new GUIStyle
                {
                    fixedWidth = 10f,
                    fixedHeight = 10f,
                    normal = new GUIStyleState
                    {
                        background = Resources.Load<Texture2D>("Arrow_R"),
                    }
                };
                return _foldoutFolded;
            }
        }

        private static GUIStyle _foldoutUnfolded;

        public static GUIStyle FoldoutUnfolded
        {
            get
            {
                if (_foldoutUnfolded != null) return _foldoutUnfolded;
                _foldoutUnfolded = new GUIStyle
                {
                    fixedWidth = 10f,
                    fixedHeight = 10f,
                    normal = new GUIStyleState
                    {
                        background = Resources.Load<Texture2D>("Arrow_D"),
                    }
                };
                return _foldoutUnfolded;
            }
        }

        public static void DrawStaticHeader(string text)
        {
            EditorGUI.indentLevel = 0;
            EditorGUILayout.Space(8f * EditorGUIUtility.pixelsPerPoint);
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
            GUI.Box(dividerRect, "", Divider);
            GUI.Box(rect, "", Header1BgStyle);
            var labelRect = rect;
            labelRect.y -= 1f * EditorGUIUtility.pixelsPerPoint;
            labelRect.xMin += 27f * EditorGUIUtility.pixelsPerPoint;
            GUI.Label(labelRect, text, Header1TextStyle);
            EditorGUILayout.Space(8f * EditorGUIUtility.pixelsPerPoint);
        }

        public static bool DrawFoldoutHeader(string text, bool open) {
            EditorGUI.indentLevel = 0;
            EditorGUILayout.Space(8f * EditorGUIUtility.pixelsPerPoint);
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
            GUI.Box(dividerRect, "", Divider);
            GUI.Box(rect, "", Header1BgStyle);
            var labelRect = rect;
            labelRect.y -= 1f * EditorGUIUtility.pixelsPerPoint;
            labelRect.xMin += 27f * EditorGUIUtility.pixelsPerPoint;
            GUI.Label(labelRect, text, Header1TextStyle);
            EditorGUILayout.Space(8f * EditorGUIUtility.pixelsPerPoint);

            var foldoutRect = rect;
            foldoutRect.xMin = 15f * EditorGUIUtility.pixelsPerPoint;
            foldoutRect.y += 2.5f * EditorGUIUtility.pixelsPerPoint;
            foldoutRect.height -= 2.5f * EditorGUIUtility.pixelsPerPoint;
            var evt = Event.current;

            EditorGUI.indentLevel = 1;
            switch (evt.type)
            {
                case EventType.Repaint:
                {
                    if (open)
                    {
                        FoldoutUnfolded.Draw(foldoutRect, "", false, false, true, false);
                    }
                    else
                    {
                        FoldoutFolded.Draw(foldoutRect, "", false, false, true, false);
                    }

                    break;
                }
                case EventType.MouseDown:
                {
                    if (rect.Contains(evt.mousePosition))
                    {
                        return !open;
                    }

                    break;
                }
            }

            GUI.Label(labelRect, text, Styles.Header1TextStyle);
            return open;
        }

        public static Texture DrawSingleLineTextureGUI<T>(string label, Texture current, int maxWidth = -1)
        {
            var rect = EditorGUILayout.GetControlRect(true, 20f, EditorStyles.layerMaskField);
            return DrawSingleLineTextureGUI<T>(rect, label, current, maxWidth);
        }
        
        public static Texture DrawSingleLineTextureGUI<T>(Rect position, string label, Texture current, int maxWidth = -1)
        {
            var rect = position;
            if (maxWidth > 0)
            {
                rect.width = maxWidth;
            }
            var labelRect = new Rect();
            var fieldRect = new Rect();
            var rects = new object[] {rect, labelRect, fieldRect};
            typeof(EditorGUI)
                .GetMethod("GetRectsForMiniThumbnailField", BindingFlags.Static | BindingFlags.NonPublic | BindingFlags.Instance)
                ?.Invoke(null, rects);
            labelRect = (Rect) rects[2];
            fieldRect = (Rect) rects[1];
            EditorGUI.LabelField(labelRect, label);
            return EditorGUI.ObjectField(fieldRect, current, typeof(T), false) as Texture;
        }
    }
}