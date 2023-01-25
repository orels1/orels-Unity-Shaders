using System.Collections.Generic;
using System.Reflection;
using UnityEditor;
using UnityEngine;

namespace ORL.Shaders
{
    public class AssetMigrator : EditorWindow
    {
        [MenuItem("Tools/orels1/Migrate Assets to ORL Shaders")]
        private static void ShowWindow()
        {
            var window = GetWindow<AssetMigrator>();
            window.titleContent = new GUIContent("Assets to ORL Shaders");
            window.minSize = new Vector2(400, 600);
            window.Show();
        }

        private List<Material> _selectedMaterials = new List<Material>();
        private Vector2 _selectedMaterialScrollPos = Vector2.zero;
        private Vector2 _processingScrollPos = Vector2.zero;
        private bool _processing;
        private int _matIndex = 0;
        private void OnGUI()
        {
            using (new GUILayout.VerticalScope(new GUIStyle
                   {
                       margin = new RectOffset(10, 10, 10, 10)
                   }))
            {
                if (!_processing)
                {
                    using (new GUILayout.VerticalScope(EditorStyles.helpBox))
                    {
                        if (GUILayout.Button("Add Selected"))
                        {
                            AddSelectedMaterials();
                        }
                        using (var scroller = new GUILayout.ScrollViewScope(_selectedMaterialScrollPos))
                        {
                            _selectedMaterialScrollPos = scroller.scrollPosition;
                            foreach (var mat in _selectedMaterials)
                            {
                                EditorGUILayout.ObjectField(mat, typeof (Material), false);
                            }
                        }
                    }
                    if (GUILayout.Button("Start Processing", GUILayout.Height(30)))
                    {
                        _processing = true;
                    }
                }

                if (!_processing) return;
                EditorGUILayout.HelpBox("All of the textures present on the original material are displayed in the list below\n" +
                                        "You can now map them to the textures present in the ORL Shader", MessageType.None);
                using (new EditorGUILayout.VerticalScope())
                {
                    var mat = _selectedMaterials[_matIndex];
                    using (var scroller = new GUILayout.ScrollViewScope(_processingScrollPos))
                    {
                        _processingScrollPos = scroller.scrollPosition;
                        var textures = mat.GetTexturePropertyNames();
                        foreach (var tex in textures)
                        {
                            var texObj = mat.GetTexture(tex);
                            // we dont want to show empty textures
                            if (texObj == null) continue;
                            using (new EditorGUILayout.HorizontalScope(EditorStyles.helpBox))
                            {
                                using (new EditorGUILayout.VerticalScope())
                                {
                                    EditorGUILayout.LabelField(tex);
                                    var rect = EditorGUILayout.GetControlRect(true, 128, EditorStyles.layerMaskField);
                                    rect.width = 128f;
                                    EditorGUI.ObjectField((Rect) rect, texObj, typeof(Texture2D), false);

                                }
                                using (new EditorGUILayout.VerticalScope())
                                {
                                    EditorGUILayout.Toggle("Base Color", false);
                                    using (new EditorGUILayout.HorizontalScope())
                                    {
                                        EditorGUILayout.Toggle("Metallic", false);
                                        DrawChannelDropdown();
                                    }
                                    using (new EditorGUILayout.HorizontalScope())
                                    {
                                        EditorGUILayout.Toggle("AO", false);
                                        DrawChannelDropdown(1);
                                    }
                                    using (new EditorGUILayout.HorizontalScope())
                                    {
                                        EditorGUILayout.Toggle("Smoothness", false);
                                        DrawChannelDropdown(3);
                                    }

                                    EditorGUILayout.Toggle("Normal", false);
                                    EditorGUILayout.Toggle("Transparency", false);
                                    EditorGUILayout.Toggle("Emission", false);
                                }
                            }
                        }
                    }
                    
                    EditorGUILayout.HelpBox($"Current: {_matIndex + 1} / {_selectedMaterials.Count}. Processed {_matIndex} / {_selectedMaterials.Count}", MessageType.None);
                    using (new EditorGUILayout.HorizontalScope())
                    {
                        if (GUILayout.Button("Previous Material", GUILayout.Height(30)))
                        {
                            if (_matIndex > 0)
                            {
                                _matIndex--;
                            }
                            else
                            {
                                _matIndex = _selectedMaterials.Count - 1;
                            }
                            _processingScrollPos = Vector2.zero;
                        }

                        if (GUILayout.Button("Next Material", GUILayout.Height(30)))
                        {
                            if (_matIndex == _selectedMaterials.Count - 1)
                            {
                                _matIndex = 0;
                            }
                            else
                            {
                                _matIndex++;
                            }
                            _processingScrollPos = Vector2.zero;
                        }
                    }
                }
            }
        }

        private void DrawChannelDropdown(int channelDefault = 0)
        {
            EditorGUILayout.Popup(channelDefault, new[] {"R", "G", "B", "A"});
        }

        private void AddSelectedMaterials()
        {
            if (Selection.objects.Length == 0) return;
            foreach (var o in Selection.objects)
            {
                if (o is Material)
                {
                    _selectedMaterials.Add((Material) o);
                }
            }
        }
    }
}