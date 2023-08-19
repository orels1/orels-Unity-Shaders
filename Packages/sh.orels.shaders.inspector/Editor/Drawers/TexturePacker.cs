using System;
using System.Collections.Generic;
using System.IO;
using ORL.ShaderInspector;
using UnityEditor;
using UnityEngine;

namespace ORL.Drawers
{
    public static class TexturePacker
    {
        private static int[] _sizeOptions = {
            64,
            128,
            256,
            512,
            1024,
            2048,
            4096
        };

        private static string[] _sizeOptionLabels = {
            "64",
            "128",
            "256",
            "512",
            "1024",
            "2048",
            "4096"
        };
        
        public static bool DrawPacker(Rect position, bool visible, ref Dictionary<string, object> uiState, string uiKey, Material material, MaterialProperty property, MaterialEditor materialEditor)
        {
            if (EditorGUI.indentLevel == -1) return visible;
            if (GUI.Button(position, "Repack Texture"))
            {
                return !visible;
            }

            if (!visible) return false;
            var oldIndent = EditorGUI.indentLevel;
            EditorGUI.indentLevel = 0;
            var paddedBox = new GUIStyle(EditorStyles.helpBox)
            {
                margin = new RectOffset(15 * (oldIndent + 1), 0, 0, 5),
                padding = new RectOffset(5,5,5,5)
            };
            using (new GUILayout.VerticalScope(paddedBox))
            {
                var redTex = (Texture2D) uiState[uiKey + "_red_tex"];
                var redChannel = (int) uiState[uiKey + "_red_channel"];
                var redVal = (float) uiState[uiKey + "_red_val"];
                var redInvert = (bool) uiState[uiKey + "_red_invert"];
                DrawPackerRow("Red", ref redTex, ref redChannel, ref redVal, ref redInvert);
                
                var greenTex = (Texture2D) uiState[uiKey + "_green_tex"];
                var greenChannel = (int) uiState[uiKey + "_green_channel"];
                var greenVal = (float) uiState[uiKey + "_green_val"];
                var greenInvert = (bool) uiState[uiKey + "_green_invert"];
                DrawPackerRow("Green", ref greenTex, ref greenChannel, ref greenVal, ref greenInvert);
                
                var blueTex = (Texture2D) uiState[uiKey + "_blue_tex"];
                var blueChannel = (int) uiState[uiKey + "_blue_channel"];
                var blueVal = (float) uiState[uiKey + "_blue_val"];
                var blueInvert = (bool) uiState[uiKey + "_blue_invert"];
                DrawPackerRow("Blue", ref blueTex, ref blueChannel, ref blueVal, ref blueInvert);
                
                var alphaTex = (Texture2D) uiState[uiKey + "_alpha_tex"];
                var alphaChannel = (int) uiState[uiKey + "_alpha_channel"];
                var alphaVal = (float) uiState[uiKey + "_alpha_val"];
                var alphaInvert = (bool) uiState[uiKey + "_alpha_invert"];
                DrawPackerRow("Alpha", ref alphaTex, ref alphaChannel, ref alphaVal, ref alphaInvert);
                
                uiState[uiKey + "_red_tex"] = redTex;
                uiState[uiKey + "_red_channel"] = redChannel;
                uiState[uiKey + "_red_val"] = redVal;
                uiState[uiKey + "_red_invert"] = redInvert;
                uiState[uiKey + "_green_tex"] = greenTex;
                uiState[uiKey + "_green_channel"] = greenChannel;
                uiState[uiKey + "_green_val"] = greenVal;
                uiState[uiKey + "_green_invert"] = greenInvert;
                uiState[uiKey + "_blue_tex"] = blueTex;
                uiState[uiKey + "_blue_channel"] = blueChannel;
                uiState[uiKey + "_blue_val"] = blueVal;
                uiState[uiKey + "_blue_invert"] = blueInvert;
                uiState[uiKey + "_alpha_tex"] = alphaTex;
                uiState[uiKey + "_alpha_channel"] = alphaChannel;
                uiState[uiKey + "_alpha_val"] = alphaVal;
                uiState[uiKey + "_alpha_invert"] = alphaInvert;

                var isLinear = (bool) uiState[uiKey + "_linear"];
                isLinear = EditorGUILayout.Toggle(new GUIContent("Linear Texture", "Reads source textures in linear mode, and saves the final texture as linear"), isLinear);
                uiState[uiKey + "_linear"] = isLinear;
                
                var size = Array.IndexOf(_sizeOptions, (int) uiState[uiKey + "_size"]);
                size = _sizeOptions[EditorGUILayout.Popup(size, _sizeOptionLabels)];
                uiState[uiKey + "_size"] = size;
                
                var texName = (string) uiState[uiKey + "_name"];
                texName = EditorGUILayout.TextField(texName);
                uiState[uiKey + "_name"] = texName;

                if (GUILayout.Button("Pack Texture", GUILayout.Height(25)))
                {
                    var folder = AssetDatabase.GetAssetPath(materialEditor.target);
                    folder = folder.Substring(0, folder.LastIndexOf("/"));
                    var savePath = folder + "/" + texName;
                    if (texName == "")
                    {
                        savePath += GUID.Generate().ToString();
                    }

                    savePath += ".png";
                    var result = PackTexture(
                        new [] { redTex, greenTex, blueTex, alphaTex },
                        new [] { redChannel, greenChannel, blueChannel, alphaChannel },
                        new [] { redVal, greenVal, blueVal, alphaVal },
                        new [] { redInvert, greenInvert, blueInvert, alphaInvert },
                        isLinear,
                        size,
                        savePath
                    );
                    if (result == null)
                    {
                        Debug.Log("Failed to pack texture");
                        return true;
                    }
                    
                    Undo.RecordObject(materialEditor.target, "Assigned Packed Texture");
                    (materialEditor.target as Material).SetTexture(property.name, result);
                }
            }

            EditorGUI.indentLevel = oldIndent;
            return true;
        }

        private static void DrawPackerRow(string label, ref Texture2D currTex, ref int currChannel, ref float currValue, ref bool currInvert)
        {
            using (new GUILayout.HorizontalScope())
            {
                var rowRect = EditorGUILayout.GetControlRect(true, 20f, EditorStyles.layerMaskField);
                var texFieldRect = rowRect;
                texFieldRect.xMax = 70;
                currTex = (Texture2D) Styles.DrawSingleLineTextureGUI<Texture2D>(texFieldRect, label, currTex);
                var dropdownRect = rowRect;
                dropdownRect.xMin += 70;
                dropdownRect.xMax = dropdownRect.xMin + 30;
                currChannel = EditorGUI.Popup(dropdownRect, currChannel, new []{
                    new GUIContent("R", $"Fills the {label} channel of the packed texture with values from the Red channel of the source texture"),
                    new GUIContent("G", $"Fills the {label} channel of the packed texture with values from the Green channel of the source texture"),
                    new GUIContent("B", $"Fills the {label} channel of the packed texture with values from the Blue channel of the source texture"),
                    new GUIContent("A", $"Fills the {label} channel of the packed texture with values from the Alpha channel of the source texture")
                });
                var sliderRect = rowRect;
                sliderRect.xMin += 110f;
                sliderRect.xMax -= 30f;
                var oldWidth = EditorGUIUtility.fieldWidth;
                EditorGUIUtility.fieldWidth = 40;
                var oldLabelField = EditorGUIUtility.labelWidth;
                EditorGUIUtility.labelWidth = 15;
                using (new EditorGUI.DisabledScope(currTex != null))
                {
                    currValue = EditorGUI.Slider(sliderRect, new GUIContent("V","Fill Value. This channel will be filled uniformly with this value"), currValue, 0, 1);
                }
                EditorGUIUtility.fieldWidth = oldWidth;
                var invertRect = rowRect;
                invertRect.xMin = invertRect.xMax - 25f;
                EditorGUIUtility.labelWidth = 7;
                currInvert = EditorGUI.Toggle(invertRect, new GUIContent("I", "Invert Texture. Checking this box will inverted the selected channel values"), currInvert);
                EditorGUIUtility.labelWidth = oldLabelField;
            }
        }

        public static Texture2D PackTexture(Texture2D[] textures, int[] channels, float[] values, bool[] inverts, bool isLinear, int size, string savePath)
        {
            var rawTextures = new Texture2D[4];
            for (int i = 0; i < rawTextures.Length; i++)
            {
                if (textures[i] == null) continue;
                var channelTexPath = AssetDatabase.GetAssetPath(textures[i]);
                var tex = new Texture2D(4, 4, TextureFormat.RGBA32, false, true);
                tex.LoadImage(File.ReadAllBytes(channelTexPath));
                rawTextures[i] = tex;
            }
            var packerShader = Resources.Load<Shader>("PackerShader");
            if (packerShader == null)
            {
                Debug.Log("Could not load packer shader");
                return null;
            }

            var mat = new Material(packerShader);
            SetPackerPropsForChannel("Red", ref mat, textures[0], channels[0], values[0], inverts[0]);
            SetPackerPropsForChannel("Green", ref mat, textures[1], channels[1], values[1], inverts[1]);
            SetPackerPropsForChannel("Blue", ref mat, textures[2], channels[2], values[2], inverts[2]);
            SetPackerPropsForChannel("Alpha", ref mat, textures[3], channels[3], values[3], inverts[3]);
            mat.SetInt("_IsLinear", isLinear ? 1 : 0);
            var source = new Texture2D(size, size);
            var buffer = new RenderTexture(size, size, 24, RenderTextureFormat.ARGB32);
            var target = new Texture2D(size, size, TextureFormat.ARGB32, true);
            Graphics.Blit(source, buffer, mat);
            RenderTexture.active = buffer;
            target.ReadPixels(new Rect(0, 0, size, size), 0, 0);
            target.Apply();
            RenderTexture.active = null;
            UnityEngine.Object.DestroyImmediate(source);
            UnityEngine.Object.DestroyImmediate(buffer);
            UnityEngine.Object.DestroyImmediate(mat);

            var final = target.EncodeToPNG();
            if (File.Exists(savePath))
            {
                File.Delete(savePath);
            }

            if (final == null)
            {
                Debug.Log("Final encode result is null, packing failed");
                return null;
            }
            File.WriteAllBytes(savePath, final);
            UnityEngine.Object.DestroyImmediate(target);
            AssetDatabase.Refresh();
            var importer = AssetImporter.GetAtPath(savePath) as TextureImporter;
            if (importer == null)
            {
                Debug.Log("Failed to load texture after packing");
                return null;
            }
            importer.streamingMipmaps = true;
            importer.sRGBTexture = !isLinear;
            importer.textureCompression = TextureImporterCompression.CompressedHQ;
            importer.SaveAndReimport();
            Debug.Log($"saved Packed Texture to: {savePath}");
            return AssetDatabase.LoadAssetAtPath<Texture2D>(savePath);
        }

        private static void SetPackerPropsForChannel(string channelName, ref Material mat, Texture2D tex, int channel, float fill, bool invert)
        {
            if (tex != null)
            {
                mat.SetTexture($"_{channelName}Tex", tex);
                mat.SetInt($"_{channelName}TexPresent", 1);
            }
            mat.SetInt($"_{channelName}Channel", channel);
            mat.SetFloat($"_{channelName}Fill", fill);
            mat.SetInt($"_{channelName}Invert", invert ? 1 : 0);
        }
    }
}