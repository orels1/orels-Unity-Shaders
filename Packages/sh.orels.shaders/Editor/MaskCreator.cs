using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using UnityEditor;
using UnityEditor.AssetImporters;
using UnityEditor.ProjectWindowCallback;
using UnityEngine;

namespace ORL.Shaders.Tools
{
    public class MaskCreator : EditorWindow
    {
        [MenuItem("Tools/orels1/Create Mask Texture")]
        [MenuItem("Assets/Create/Textures/Procedural Mask", priority = 9)]
        private static void ShowWindow()
        {
            var window = GetWindow<MaskCreator>(true);
            window.titleContent = new GUIContent("ORL Mask Creator");
            window.Show();
        }

        [HideInInspector]
        public MaskCreatorData data;

        private List<List<float>> _gridValuesStorage;

        private void OnGUI()
        {
            var so = new SerializedObject(this);
            so.Update();
            var dataProp = so.FindProperty("data");
            var typeProp = dataProp.FindPropertyRelative("maskType");
            var gridDataProp = dataProp.FindPropertyRelative("gridData");
            var gridWidthProp = gridDataProp.FindPropertyRelative("width");
            var gridHeightProp = gridDataProp.FindPropertyRelative("height");
            var gridValuesProp = gridDataProp.FindPropertyRelative("values");
            
            EditorGUILayout.PropertyField(typeProp);

            if (_gridValuesStorage == null)
            {
                _gridValuesStorage = new List<List<float>>();
                _gridValuesStorage.Add(new List<float>());
            }

            using (var c = new EditorGUI.ChangeCheckScope())
            {
                if (typeProp.enumValueIndex == 0)
                {
                    EditorGUILayout.PropertyField(gridWidthProp);
                    EditorGUILayout.PropertyField(gridHeightProp);
                }

                if (c.changed)
                {
                    if (_gridValuesStorage.Count != gridHeightProp.intValue)
                    {
                        _gridValuesStorage = new List<List<float>>(gridHeightProp.intValue);
                        for (var y = 0; y < gridHeightProp.intValue; y++)
                        {
                            _gridValuesStorage.Add(new List<float>());
                            for (var x = 0; x < gridWidthProp.intValue; x++)
                            {
                                _gridValuesStorage[y].Add(0);
                            }
                        }
                    }
                }
            }

            // var lastRect = EditorGUIUtility.currentViewWidth;
            // Debug.Log("last rect: " + lastRect);
            var width = EditorGUIUtility.currentViewWidth / _gridValuesStorage[0].Count;
            width -= 4;

            for (var y = 0; y < _gridValuesStorage.Count; y++)
            {
                using (new EditorGUILayout.HorizontalScope())
                {
                    for (var x = 0; x < _gridValuesStorage[y].Count; x++)
                    {
                        _gridValuesStorage[y][x] = EditorGUILayout.Toggle(_gridValuesStorage[y][x] > 0.5,
                            new GUIStyle("button"), GUILayout.Width(width), GUILayout.Height(width))
                            ? 1.0f
                            : 0.0f;
                    }
                }
            }

            if (GUILayout.Button("Create Mask"))
            {
                var scaleFactor = 16;
                if (gridWidthProp.intValue > 4)
                {
                    scaleFactor = 8;
                }

                if (gridWidthProp.intValue > 8)
                {
                    scaleFactor = 4;
                }
                var tex = new Texture2D(gridWidthProp.intValue * scaleFactor,gridHeightProp.intValue * scaleFactor);
                for (var y = 0; y < gridHeightProp.intValue * scaleFactor; y++)
                {
                    for (var x = 0; x < gridWidthProp.intValue * scaleFactor; x++)
                    {
                        tex.SetPixel(x, gridHeightProp.intValue * scaleFactor - y - 1, _gridValuesStorage[Mathf.FloorToInt(y / scaleFactor)][Mathf.FloorToInt(x / scaleFactor)] > 0.5f ? Color.white : Color.black);
                    }
                }
                var bytes = tex.EncodeToPNG();
                var path = Application.dataPath.Replace("Assets", "Library") + "/" + "orl_mask_temp.png";
                File.WriteAllBytes(path, bytes);
                CreateMaskAsset(path);
            }

            so.ApplyModifiedProperties();
        }

        public static void CreateMaskAsset(string tempFilePath)
        {
            Type projectWindowUtilType = typeof(ProjectWindowUtil);
            MethodInfo getActiveFolderPath = projectWindowUtilType.GetMethod("GetActiveFolderPath", BindingFlags.Static | BindingFlags.NonPublic);
            if (getActiveFolderPath == null)
            {
                Debug.LogWarning("Failed to get active folder path");
                return;
            }
            object obj = getActiveFolderPath.Invoke(null, new object[0]);
            string pathToCurrentFolder = obj.ToString();
            string uniquePath = AssetDatabase.GenerateUniqueAssetPath($"{pathToCurrentFolder}/New Mask.png");

            ProjectWindowUtil.StartNameEditingIfProjectWindowExists(0, ScriptableObject.CreateInstance<MaskAssetCreateEndAction>(), uniquePath, null, tempFilePath);
        }

        private class MaskAssetCreateEndAction : EndNameEditAction
        {
            public override void Action(int instanceId, string pathName, string resourceFile)
            {
                File.Copy(resourceFile, pathName, true);

                AssetDatabase.Refresh();
                UnityEngine.Object o = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(pathName);
                Selection.activeObject = o;
            }
        }
    }
}