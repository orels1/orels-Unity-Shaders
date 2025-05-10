using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.Linq;

public class ORLMaterialConverter : EditorWindow
{
    [MenuItem("Tools/orels1/Convert Materials")]
    private static void ShowWindow()
    {
        var window = GetWindow<ORLMaterialConverter>(true);
        window.titleContent = new GUIContent("ORL Material Converter");
        window.Show();
    }

    private ORLMaterialConverterPreset _preset;
    private Material _sourceMaterial;
    private Material _targetMaterial;

    private List<ORLMaterialConverterPreset> _presets = new();

    private List<ORLMaterialConverterPreset> FindConverterPresets()
    {
        return AssetDatabase.FindAssets("t:ORLMaterialConverterPreset").Select(p => AssetDatabase.LoadAssetAtPath<ORLMaterialConverterPreset>(AssetDatabase.GUIDToAssetPath(p))).ToList();
    }

    private List<string> _presetNames = new();
    private int _selectedPresetIndex;

    private void OnGUI()
    {
        if (_presets.Count == 0)
        {
            _presets = FindConverterPresets();
            if (_presets.Count > 0 && _preset == null)
            {
                _preset = _presets[0];
                _selectedPresetIndex = 0;
            }
        }
        if (_presetNames.Count != _presets.Count)
        {
            _presets.ForEach(p => _presetNames.Add($"{p.sourceShader.name} -> {p.targetShader.name}"));
        }

        using (var c = new EditorGUI.ChangeCheckScope())
        {
            _selectedPresetIndex = EditorGUILayout.Popup("Preset", _selectedPresetIndex, _presetNames.ToArray());
            if (c.changed)
            {
                _preset = _presets[_selectedPresetIndex];
            }
        }

        _sourceMaterial = (Material)EditorGUILayout.ObjectField("Source Material", _sourceMaterial, typeof(Material), false);
        _targetMaterial = (Material)EditorGUILayout.ObjectField("Target Material", _targetMaterial, typeof(Material), false);

        var currentEvent = Event.current;
        var width = EditorGUIUtility.currentViewWidth / 2.0f;
        width -= 10;
        using (new GUILayout.HorizontalScope())
        {
            using (new GUILayout.VerticalScope(EditorStyles.helpBox, GUILayout.MinHeight(200), GUILayout.MaxWidth(width)))
            {
                if (_sourceMaterial == null)
                {
                    GUILayout.FlexibleSpace();
                    EditorGUILayout.LabelField("Source", new GUIStyle(EditorStyles.boldLabel) { alignment = TextAnchor.MiddleCenter, fontSize = 20 });
                    GUILayout.FlexibleSpace();
                }
                else
                {
                    GUILayout.FlexibleSpace();
                }
            }
            var sourceRect = GUILayoutUtility.GetLastRect();
            if (_sourceMaterial != null)
            {
                var newRect = sourceRect;
                newRect.x += 4;
                newRect.y += 4;
                newRect.width -= 8;
                newRect.height -= 8;
                if (newRect.width > newRect.height)
                {
                    newRect.width = newRect.height;
                }
                else
                {
                    newRect.height = newRect.width;
                }
                newRect.x = sourceRect.x + (sourceRect.width - newRect.width) / 2;
                var previewTex = AssetPreview.GetAssetPreview(_sourceMaterial);
                if (previewTex != null)
                {
                    EditorGUI.DrawTextureTransparent(newRect, previewTex);
                }
            }
            GUILayout.FlexibleSpace();
            using (new GUILayout.VerticalScope(EditorStyles.helpBox, GUILayout.MinHeight(200), GUILayout.MaxWidth(width)))
            {
                if (_targetMaterial == null)
                {
                    GUILayout.FlexibleSpace();
                    EditorGUILayout.LabelField("Target", new GUIStyle(EditorStyles.boldLabel) { alignment = TextAnchor.MiddleCenter, fontSize = 20 });
                    GUILayout.FlexibleSpace();
                }
                else
                {
                    GUILayout.FlexibleSpace();
                }
            }
            var targetRect = GUILayoutUtility.GetLastRect();
            if (_targetMaterial != null)
            {
                var newRect = targetRect;
                newRect.x += 4;
                newRect.y += 4;
                newRect.width -= 8;
                newRect.height -= 8;
                if (newRect.width > newRect.height)
                {
                    newRect.width = newRect.height;
                }
                else
                {
                    newRect.height = newRect.width;
                }
                newRect.x = targetRect.x + (targetRect.width - newRect.width) / 2;
                var previewTex = AssetPreview.GetAssetPreview(_targetMaterial);
                if (previewTex != null)
                {
                    EditorGUI.DrawTextureTransparent(newRect, previewTex);
                }
            }

            if (currentEvent.type == EventType.DragPerform || currentEvent.type == EventType.DragUpdated)
            {
                if (sourceRect.Contains(currentEvent.mousePosition))
                {
                    DragAndDrop.visualMode = DragAndDropVisualMode.Copy;
                    if (currentEvent.type == EventType.DragPerform)
                    {
                        var sourceMat = (Material)DragAndDrop.objectReferences[0];
                        if (sourceMat != null)
                        {
                            DragAndDrop.AcceptDrag();
                            Debug.Log("Dropped Source" + sourceMat.name);
                            _sourceMaterial = sourceMat;
                        }
                    }
                }

                if (targetRect.Contains(currentEvent.mousePosition))
                {
                    DragAndDrop.visualMode = DragAndDropVisualMode.Copy;
                    if (currentEvent.type == EventType.DragPerform)
                    {
                        var targetMat = (Material)DragAndDrop.objectReferences[0];
                        if (targetMat != null)
                        {
                            DragAndDrop.AcceptDrag();
                            Debug.Log("Dropped Target" + targetMat.name);
                            _targetMaterial = targetMat;
                        }
                        DragAndDrop.AcceptDrag();
                    }
                }
            }
        }

        if (GUILayout.Button("Convert", GUILayout.Height(30)))
        {
            if (_preset == null || _sourceMaterial == null) return;

            if (_targetMaterial != null)
            {
                var tempMat = _preset.Convert(_sourceMaterial, true);
                Undo.RecordObject(tempMat, "Convert Material");
                _targetMaterial.CopyMatchingPropertiesFromMaterial(tempMat);
                AssetDatabase.SaveAssets();
                AssetDatabase.Refresh();
                DestroyImmediate(tempMat);
                return;
            }

            var newMat = _preset.Convert(_sourceMaterial);
            var newMatPath = AssetDatabase.GetAssetPath(newMat);
            newMatPath = newMatPath.Replace(".mat", "-converted.mat");
            AssetDatabase.CreateAsset(newMat, newMatPath);
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
        }
    }
}