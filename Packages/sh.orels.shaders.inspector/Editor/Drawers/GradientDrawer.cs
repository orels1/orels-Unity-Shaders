using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using ORL.ShaderInspector;
using UnityEditor;
using UnityEngine;
using UnityEngine.Windows;

namespace ORL.Drawers
{
    public class GradientDrawer : IDrawerFunc
    {
        public string FunctionName => "Gradient";

        // Matches "Gradient((0,0,0,1), (1,1,1,1))"
        // Or "Gradient()"
        private Regex _matcher = new Regex(@"%Gradient\(((?<startColor>\([\,\s\d]+\)),\s?(?<endColor>\([\,\s\d]+\)))?\)");
        
        public string[] PersistentKeys => new [] { "Gradient_" };
        
        public bool OnGUI(MaterialEditor editor, MaterialProperty[] properties, MaterialProperty property, int index, ref Dictionary<string, object> uiState, Func<bool> next)
        {
            if (EditorGUI.indentLevel == -1) return true;
            
            var match = _matcher.Match(property.displayName);
            var groups = match.Groups.Cast<Group>().Where(g => !string.IsNullOrEmpty(g.Value)).ToList();
            groups.RemoveAt(0);

            var startColor = Color.black;
            var endColor = Color.white;
            var propStartColor = groups.Where(g => g.Name == "startColor").ToArray();
            if (propStartColor.Any())
            {
                var val = propStartColor.First();
                var color = val.Value.Trim('(', ')').Split(',');
                startColor = new Color(float.Parse(color[0]), float.Parse(color[1]), float.Parse(color[2]), float.Parse(color[3]));
            }
            var propEndColor = groups.Where(g => g.Name == "endColor").ToArray();
            if (propEndColor.Any())
            {
                var val = propEndColor.First();
                var color = val.Value.Trim('(', ')').Split(',');
                endColor = new Color(float.Parse(color[0]), float.Parse(color[1]), float.Parse(color[2]), float.Parse(color[3]));
            }
            
            var strippedName = Utils.StripInternalSymbols(property.displayName);
            var uiKey = "Gradient_" + strippedName;
            var savedGradient = uiState.ContainsKey(uiKey) ? (Gradient) uiState[uiKey] : null;
            var hasSavedGradient = savedGradient != null;

            EditorGUI.BeginChangeCheck();
            
            var baseRect = EditorGUILayout.GetControlRect();
            var texRect = baseRect;
            texRect.width = 20f;
            editor.TexturePropertyMiniThumbnail(texRect, property, null, null);
            var labelRect = baseRect;
            labelRect.xMin += texRect.width + 10f;
            labelRect.width = Mathf.Min(150f, EditorStyles.label.CalcSize(new GUIContent(strippedName)).x + 20f * EditorGUIUtility.pixelsPerPoint);
            EditorGUI.LabelField(labelRect, strippedName);
            var gradRect = baseRect;
            gradRect.xMin = EditorGUIUtility.labelWidth + 6.0f;
            gradRect.width = EditorGUIUtility.currentViewWidth - EditorGUIUtility.labelWidth - 28f;
            gradRect.width /= 2f;
            gradRect.width -= 5f;
            Gradient grad;
            using (var c = new EditorGUI.ChangeCheckScope())
            {
                var oldGradCopy = new Gradient();
                if (hasSavedGradient)
                {
                    oldGradCopy.SetKeys(savedGradient.colorKeys, savedGradient.alphaKeys);
                }
                else
                {
                    oldGradCopy.SetKeys(new []
                    {
                        new GradientColorKey(startColor, 0f),
                        new GradientColorKey(endColor, 1f)
                    }, new []
                    {
                        new GradientAlphaKey(startColor.a, 0),
                        new GradientAlphaKey(endColor.a, 1)
                    });
                }
                grad = EditorGUI.GradientField(gradRect, new GUIContent(""), oldGradCopy, false);
                if (c.changed)
                {
                    uiState[uiKey] = grad;
                }
            }
            var buttonRect = baseRect;
            buttonRect.xMin = gradRect.xMax + 5f;
            buttonRect.width = gradRect.width + 5f * EditorGUIUtility.pixelsPerPoint;
            if (property.textureValue == null)
            {
                if (GUI.Button(buttonRect, buttonRect.width < 100f ? "Save" : "Save Gradient"))
                {
                    if (grad != null)
                    {
                        var generated = GenerateGradient(grad);
                        var savePath = AssetDatabase.GetAssetPath(editor.target);
                        var saved = SaveTexture(generated, editor.target.name, strippedName, savePath);
                        if (saved == null)
                        {
                            Debug.Log("Failed to save gradient");
                            return true;
                        }
                        property.textureValue = saved;
                    }
                }
            }
            else
            {
                if (GUI.Button(buttonRect, buttonRect.width < 100f ? "Update" : "Update Gradient"))
                {
                    if (grad != null)
                    {
                        var generated = GenerateGradient(grad);
                        var savePath = AssetDatabase.GetAssetPath(editor.target);
                        var saved = SaveTexture(generated, editor.target.name, strippedName, savePath);
                        if (saved == null)
                        {
                            Debug.Log("Failed to save gradient");
                            return true;
                        }
                        property.textureValue = saved;
                    }
                }
            }

            if (property.textureValue == null)
            {
                EditorGUILayout.Space(3);
                EditorGUILayout.LabelField("Dont forget to save your gradients", Styles.NoteTextStyle);
            }
            return true;
        }
        
        private Texture2D GenerateGradient(Gradient gradient)
        {
            var newTex = new Texture2D(256, 4, TextureFormat.RGBA32, false);
            newTex.wrapMode = TextureWrapMode.Clamp;
            newTex.filterMode = FilterMode.Bilinear;
            newTex.anisoLevel = 1;
            for (int i = 0; i < 256; i++)
            {
                var col = gradient.Evaluate(i / 255f);
                newTex.SetPixel(i, 0, col);
                newTex.SetPixel(i, 1, col);
                newTex.SetPixel(i, 2, col);
                newTex.SetPixel(i, 3, col);
            }
            newTex.Apply();
            return newTex;
        }

        private Texture2D SaveTexture(Texture2D generated, string matName, string strippedName, string savePath)
        {
            var folderPath = savePath.Substring(0, savePath.LastIndexOf('/'));
            if (!AssetDatabase.IsValidFolder(folderPath + "/Gradients"))
            {
                AssetDatabase.CreateFolder(folderPath, "Gradients");
            }
            var bytes = generated.EncodeToPNG();
            savePath = folderPath + "/Gradients/" + matName + strippedName + "_gradient.png";
            if (File.Exists(savePath))
            {
                File.Delete(savePath);
            }
            File.WriteAllBytes(savePath, bytes);
            AssetDatabase.Refresh();
            var exported = AssetDatabase.LoadAssetAtPath<Texture2D>(savePath);
            var importer = AssetImporter.GetAtPath(savePath) as TextureImporter;
            if (importer == null)
            {
                Debug.Log("Failed to load texture after packing");
                return null;
            }

            importer.wrapMode = TextureWrapMode.Clamp;
            importer.streamingMipmaps = true;
            importer.textureCompression = TextureImporterCompression.Uncompressed;
            importer.mipmapEnabled = true;
            importer.SaveAndReimport();
            return exported;
        }
    }
    
}