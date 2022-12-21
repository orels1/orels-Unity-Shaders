using System.Collections.Generic;
using System.Reflection;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEditor.Experimental.AssetImporters;
using UnityEngine;

namespace ORL.ShaderGenerator
{
    [CustomEditor(typeof(ShaderDefinitionImporter))]
    public class ShaderDefinitionImporterEditor : ScriptedImporterEditor
    {
        private bool _sourceCodeFoldout;
        private Font _monoFont;
        private Vector2 _sourceScrollPos;

        public override void OnInspectorGUI()
        {
            serializedObject.Update();
            if (_monoFont == null)
            {
                _monoFont = Font.CreateDynamicFontFromOSFont("Consolas", 12);
            }

            var importer = target as ShaderDefinitionImporter;
            if (importer == null) return;

            var finalShader = AssetDatabase.LoadAssetAtPath<Shader>(importer.assetPath);

            // if (importer.nonModifiableTextures.Count > 0)
            // {
            //     var nonModNamesProp = serializedObject.FindProperty("nonModifiableTextures");
            //     var nonModAssetsProp = serializedObject.FindProperty("nonModifiableTextureAssets");
            //     if (importer.nonModifiableTextureAssets.Count < importer.nonModifiableTextures.Count) {
            //         nonModAssetsProp.arraySize = importer.nonModifiableTextures.Count;
            //         serializedObject.ApplyModifiedProperties();
            //         return;
            //     }
            //     EditorGUILayout.LabelField("Non Modifiable Textures", EditorStyles.boldLabel);
            //     var newTextures = new List<Texture>();
            //     using (var c = new EditorGUI.ChangeCheckScope())
            //     {
            //         var j = 0;
            //         foreach (var nonModTex in importer.nonModifiableTextures)
            //         {
            //             using (new EditorGUILayout.HorizontalScope())
            //             {
            //                 var rect = EditorGUILayout.GetControlRect(true, 20f, EditorStyles.layerMaskField);
            //                 var labelRect = new Rect();
            //                 var fieldRect = new Rect();
            //                 var rects = new object[] {rect, labelRect, fieldRect};
            //                 typeof(EditorGUI)
            //                     .GetMethod("GetRectsForMiniThumbnailField", BindingFlags.Static | BindingFlags.NonPublic | BindingFlags.Instance)
            //                     ?.Invoke(null, rects);
            //                 EditorGUI.LabelField((Rect) rects[2], nonModTex);
            //                 var newTex = EditorGUI.ObjectField((Rect) rects[1], importer.nonModifiableTextureAssets[j],
            //                     typeof(Texture2D), false) as Texture;
            //                 newTextures.Add(newTex);
            //             }
            //             j++;
            //         }
            //         if (c.changed)
            //         {
            //             nonModNamesProp.ClearArray();
            //             nonModAssetsProp.ClearArray();
            //             nonModNamesProp.arraySize = importer.nonModifiableTextures.Count;
            //             nonModAssetsProp.arraySize = importer.nonModifiableTextures.Count;
            //             var i = 0;
            //             foreach (var newTex in newTextures)
            //             {
            //                 nonModNamesProp.GetArrayElementAtIndex(i).stringValue = importer.nonModifiableTextures[i];
            //                 nonModAssetsProp.GetArrayElementAtIndex(i).objectReferenceValue = newTextures[i];
            //                 i++;
            //             }
            //             EditorMaterialUtility.SetShaderNonModifiableDefaults(finalShader, importer.nonModifiableTextures.ToArray(), newTextures.ToArray());
            //             EditorUtility.SetDirty(finalShader);
            //             serializedObject.ApplyModifiedProperties();
            //         }
            //     }
            // }

            _sourceCodeFoldout = EditorGUILayout.Foldout(_sourceCodeFoldout, "Source");
            var textSource = "";
            var assets = AssetDatabase.LoadAllAssetsAtPath(importer.assetPath);
            foreach (var asset in assets)
            {
                if (asset is TextAsset textAsset)
                {
                    var text = textAsset.text;
                    textSource = text;
                }
            }
            if (_sourceCodeFoldout && !string.IsNullOrWhiteSpace(textSource))
            {
                var linedText = textSource;
                var split = linedText.Split('\n');
                for (int i = 0; i < split.Length; i++)
                {
                    split[i] = $"{(i + 1).ToString(),4}    {split[i]}";
                }

                linedText = string.Join("\n", split);
                var style = new GUIStyle(EditorStyles.textArea)
                {
                    font = _monoFont,
                    wordWrap = false
                };
                using (var sv = new EditorGUILayout.ScrollViewScope(_sourceScrollPos, GUILayout.Height(500 * EditorGUIUtility.pixelsPerPoint)))
                {
                    EditorGUILayout.TextArea(linedText, style);
                    _sourceScrollPos = sv.scrollPosition;
                }
            }

            if (GUILayout.Button("Generate Static .shader File")) {
                ShaderDefinitionImporter.GenerateShader(importer.assetPath, importer.assetPath.Replace(".orlshader", ".shader"));
            }

            serializedObject.ApplyModifiedProperties();
            ApplyRevertGUI();
        }
    }
}