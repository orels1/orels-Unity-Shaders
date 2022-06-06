#if IMAGE_LOADER_PRESENT && MARKDOWN_PRESENT
using System;
using System.Collections.Generic;
using System.IO;
using Needle.ShaderGraphMarkdown;
using UnityEditor;
using UnityEngine;

namespace ORL
{
    public class TexturePackerDrawer : MarkdownMaterialPropertyDrawer
    {
        public override void OnDrawerGUI(MaterialEditor materialEditor, MaterialProperty[] properties, DrawerParameters parameters)
        {
            if (parameters.Count < 1)
                throw new ArgumentException("No parameters to " + nameof(InlineTextureDrawer) + ". Please provide _TextureProperty and optional _Float or _Color property names.");
            var textureProperty = parameters.Get(0, properties);
            if (textureProperty == null)
                throw new ArgumentNullException("No property named " + parameters.Get(0, ""));
            
            var displayName = textureProperty.displayName;
            // strip condition
            var lastIndex = displayName.LastIndexOf('[');
            if (lastIndex > 0)
                displayName = displayName.Substring(0, lastIndex);
            // strip inlining
            var inliningIndex = displayName.IndexOf("&&", StringComparison.Ordinal);
            if (inliningIndex > 0)
                displayName = displayName.Substring(0, inliningIndex);

            var linearSwitch = parameters.Get(1, "sRGB");
            
            OnDrawerGUI(materialEditor, properties, textureProperty, displayName, linearSwitch);
        }

        private static Rect lastInlineTextureRect; 
        internal static Rect LastInlineTextureRect => lastInlineTextureRect;
        private bool packerExpanded;
        private Texture2D redChannel;
        private int pickedRedChannel = 0;
        private float redFill;
        private bool redChannelInvert = false;
        private Texture2D greenChannel;
        private float greenFill;
        private bool greenChannelInvert = false;
        private int pickedGreenChannel = 1;
        private Texture2D blueChannel;
        private int pickedBlueChannel = 2;
        private float blueFill;
        private bool blueChannelInvert = false;
        private Texture2D alphaChannel;
        private int pickedAlphaChannel = 3;
        private bool alphaChannelInvert = false;
        private float alphaFill;
        private string savedTexName = "";
        private int texSize = 2048;
        private Texture packerIcon;

        private int[] sizeOptions = new[]
        {
            64,
            128,
            256,
            512,
            1024,
            2048,
            4096
        };

        private string[] sizeOptionLabels = new[]
        {
            "64",
            "128",
            "256",
            "512",
            "1024",
            "2048",
            "4096"
        };

        internal void OnDrawerGUI(MaterialEditor materialEditor, MaterialProperty[] properties, MaterialProperty textureProperty, string displayName, string linearSwitch)
        {
            lastInlineTextureRect = Rect.zero;
            EditorGUILayout.BeginHorizontal();
            var rect = materialEditor.TexturePropertySingleLine(new GUIContent(displayName), textureProperty);
            lastInlineTextureRect = rect;
            lastInlineTextureRect.x += EditorGUIUtility.labelWidth;
            lastInlineTextureRect.width -= EditorGUIUtility.labelWidth;

            if (packerIcon == null)
            {
                packerIcon = Resources.Load<Texture>("Packer Icon");
            }

            GUI.backgroundColor = new Color(1, 1, 1, packerExpanded ? 0.5f : 1f);
            var style = new GUIStyle("button")
            {
                fixedWidth = 18 * EditorGUIUtility.pixelsPerPoint,
                fixedHeight = 18 * EditorGUIUtility.pixelsPerPoint,
                padding = new RectOffset(1,1,1,1)
            };
            packerExpanded = GUILayout.Toggle(packerExpanded, new GUIContent(packerIcon, "Texture Packer"),style);
            GUI.backgroundColor = Color.white;
            EditorGUILayout.EndHorizontal();
            
            if (!packerExpanded) return;

            var oldIndent = EditorGUI.indentLevel;
            EditorGUI.indentLevel = 0;
            using (var v = new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
            {
                DrawPackerHeader();
                DrawPackerRow("Red", ref redChannel, ref pickedRedChannel, ref redChannelInvert, ref redFill);
                DrawPackerRow("Green", ref greenChannel, ref pickedGreenChannel, ref greenChannelInvert, ref greenFill);
                DrawPackerRow("Blue", ref blueChannel, ref pickedBlueChannel, ref blueChannelInvert, ref blueFill);
                DrawPackerRow("Alpha", ref alphaChannel, ref pickedAlphaChannel, ref alphaChannelInvert, ref alphaFill);
                if (savedTexName.Trim() == "")
                {
                    if (redChannel != null)
                    {
                        savedTexName = redChannel.name + "_packed";
                    } else if (greenChannel != null)
                    {
                        savedTexName = greenChannel.name + "_packed";
                    } else if (blueChannel != null)
                    {
                        savedTexName = blueChannel.name + "_packed";
                    } else if (alphaChannel != null)
                    {
                        savedTexName = alphaChannel.name + "_packed";
                    }
                }
                EditorGUILayout.Space();
                
                EditorGUILayout.LabelField("New Texture Name");
                savedTexName = EditorGUILayout.TextField(savedTexName);
                texSize = EditorGUILayout.IntPopup(texSize, sizeOptionLabels, sizeOptions);
                if (linearSwitch == "linear")
                {
                    GUILayout.Label("Texture will be combined in linear mode", EditorStyles.helpBox);
                }

                EditorGUILayout.Space();
                if (GUILayout.Button("PACK!"))
                {
                    var folder = AssetDatabase.GetAssetPath(Selection.activeObject.GetInstanceID());
                    folder = folder.Substring(0, folder.LastIndexOf("/"));
                    var savePath = folder + "/" + savedTexName;
                    if (savedTexName == "")
                    {
                        savePath += GUID.Generate().ToString();
                    }

                    savePath += ".png";

                    PackTextures(new PackParams()
                    {
                        isLinear = linearSwitch == "linear",
                        texSize = texSize,
                        redPath = redChannel == null ? "" : AssetDatabase.GetAssetPath(redChannel),
                        redChannel = pickedRedChannel,
                        redInvert = redChannelInvert,
                        redFill = redFill,
                        greenPath = greenChannel == null ? "" : AssetDatabase.GetAssetPath(greenChannel),
                        greenChannel = pickedGreenChannel,
                        greenInvert = greenChannelInvert,
                        greenFill = greenFill,
                        bluePath = blueChannel == null ? "" : AssetDatabase.GetAssetPath(blueChannel),
                        blueChannel = pickedBlueChannel,
                        blueInvert = blueChannelInvert,
                        blueFill = blueFill,
                        alphaPath = alphaChannel == null ? "" : AssetDatabase.GetAssetPath(alphaChannel),
                        alphaChannel = pickedAlphaChannel,
                        alphaInvert = alphaChannelInvert,
                        alphaFill = alphaFill,
                    }, materialEditor.target as Material, textureProperty.name, savePath);
                }
            }

            EditorGUI.indentLevel = oldIndent;
        }

        public struct PackParams
        {
            public bool isLinear;
            public int texSize;
            
            public string redPath;
            public int redChannel;
            public bool redInvert;
            public float redFill;
            
            public string greenPath;
            public int greenChannel;
            public bool greenInvert;
            public float greenFill;

            public string bluePath;
            public int blueChannel;
            public bool blueInvert;
            public float blueFill;

            public string alphaPath;
            public int alphaChannel;
            public bool alphaInvert;
            public float alphaFill;
        }

        public static void PackTextures(PackParams passedParams, Material targetMat, string targetProperty, string savePath)
        {
            var settings = new AsyncImageLoader.LoaderSettings()
            {
                linear = passedParams.isLinear,
            };
            var redTex = GetUncompressedTextureByPath(passedParams.redPath, settings);
            var greenTex = GetUncompressedTextureByPath(passedParams.greenPath, settings);
            var blueTex = GetUncompressedTextureByPath(passedParams.bluePath, settings);
            var alphaTex = GetUncompressedTextureByPath(passedParams.alphaPath, settings);
            var packerShader = Resources.Load<Shader>("PackerShader");
            if (packerShader == null)
            {
                Debug.Log("Could not load packer shader");
                return;
            }

            var mat = new Material(packerShader);
            SetPackerPropsForChannel("Red", ref mat, redTex, passedParams.redChannel, passedParams.redFill, passedParams.redInvert);
            SetPackerPropsForChannel("Green", ref mat, greenTex, passedParams.greenChannel, passedParams.greenFill, passedParams.greenInvert);
            SetPackerPropsForChannel("Blue", ref mat, blueTex, passedParams.blueChannel, passedParams.blueFill, passedParams.blueInvert);
            SetPackerPropsForChannel("Alpha", ref mat, alphaTex, passedParams.alphaChannel, passedParams.alphaFill, passedParams.alphaInvert);
            var source = new Texture2D(passedParams.texSize, passedParams.texSize);
            var buffer = new RenderTexture(passedParams.texSize, passedParams.texSize, 24, RenderTextureFormat.ARGB32);
            var target = new Texture2D(passedParams.texSize, passedParams.texSize, TextureFormat.ARGB32, true);
            Graphics.Blit(source, buffer, mat);
            RenderTexture.active = buffer;
            target.ReadPixels(new Rect(0, 0, passedParams.texSize, passedParams.texSize), 0, 0);
            target.Apply();
            RenderTexture.active = null;
            DestroyImmediate(source);
            DestroyImmediate(buffer);
            DestroyImmediate(mat);
            var final = target.EncodeToPNG();
            if (File.Exists(savePath))
            {
                File.Delete(savePath);
            }

            if (final == null)
            {
                Debug.Log("Final encode result is null, packing failed");
                return;
            }
            File.WriteAllBytes(savePath, final);
            DestroyImmediate(target);
            AssetDatabase.Refresh();
            var exported = AssetDatabase.LoadAssetAtPath<Texture2D>(savePath);
            var importer = AssetImporter.GetAtPath(savePath) as TextureImporter;
            if (importer == null)
            {
                Debug.Log("Failed to load texture after packing");
                return;
            }
            importer.streamingMipmaps = true;
            importer.sRGBTexture = !passedParams.isLinear;
            importer.textureCompression = TextureImporterCompression.CompressedHQ;
            importer.SaveAndReimport();
            Debug.Log($"saved Packed Texture to: {savePath}");
            Undo.RecordObject(targetMat, "Assigned Packed Texture");
            targetMat.SetTexture(targetProperty, exported);
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
            mat.SetInt($"_{channel}Invert", invert ? 1 : 0);
        }

        private static AsyncImageLoader.FreeImage.Format GetFormat(string extension)
        {
            switch (extension)
            {
                case ".jpg": return AsyncImageLoader.FreeImage.Format.FIF_JPEG;
                case ".png": return AsyncImageLoader.FreeImage.Format.FIF_PNG;
                case ".tga": return AsyncImageLoader.FreeImage.Format.FIF_TARGA;
                case ".exr": return AsyncImageLoader.FreeImage.Format.FIF_EXR;
                case ".tiff": return AsyncImageLoader.FreeImage.Format.FIF_TIFF;
                case ".bmp": return AsyncImageLoader.FreeImage.Format.FIF_BMP;
                case ".psd": return AsyncImageLoader.FreeImage.Format.FIF_PSD;
            }

            return AsyncImageLoader.FreeImage.Format.FIF_UNKNOWN;
        }
        
        private static Texture2D GetUncompressedTextureByPath(string path, AsyncImageLoader.LoaderSettings settings)
        {
            var texExists = path != "";
            
            if (texExists)
            {
                var extension = path.Substring(path.LastIndexOf("."));
                settings.format = GetFormat(extension);
                var imageData = File.ReadAllBytes(path);
                var loaded = AsyncImageLoader.CreateFromImage(imageData, settings);
                if (loaded == null)
                {
                    return null;
                }

                return loaded;
            }
            else
            {
                return null;
            }
        }
        
        private void DrawPackerHeader()
        {
            var rect = EditorGUILayout.GetControlRect();
            var columnWidth = rect.width / 3 + 4 * EditorGUIUtility.pixelsPerPoint;
            GUI.Label(new Rect(rect)
            {
                width = columnWidth,
            }, "Texture");
            
            GUI.Label(new Rect(rect)
            {
                x = columnWidth,
                width = columnWidth + columnWidth / 2
            }, "Value/Channel");
        }

        private void DrawPackerRow(string rowName, ref Texture2D targetTex, ref int pickedChannel, ref bool channelInvert, ref float fillValue)
        {
            var rect = EditorGUILayout.GetControlRect();
            var columnWidth = rect.width / 3 + 4 * EditorGUIUtility.pixelsPerPoint;
            targetTex = EditorGUI.ObjectField(new Rect(rect) { width = EditorStyles.objectFieldMiniThumb.fixedWidth, height = EditorStyles.objectFieldMiniThumb.fixedHeight }, targetTex, typeof(Texture2D), false) as Texture2D;
            GUI.Label(new Rect(rect)
            {
                width = columnWidth - EditorStyles.objectFieldMiniThumb.fixedWidth - 20,
                x = EditorStyles.objectFieldMiniThumb.fixedWidth + 20
            }, rowName);

            if (targetTex != null)
            {
                pickedChannel = EditorGUI.Popup(new Rect(rect)
                {
                    x = columnWidth,
                    width = columnWidth + columnWidth / 2
                }, pickedChannel, new[] {"Red", "Green", "Blue", "Alpha"});
            }
            else
            {
                fillValue = EditorGUI.Slider(new Rect(rect)
                {
                    x = columnWidth,
                    width = columnWidth + columnWidth / 2
                }, fillValue, 0, 1);
            }

            var labelWidth = columnWidth - 10 - columnWidth / 2;
            GUI.Label(new Rect(rect)
            {
                width = labelWidth - 10,
                x = columnWidth * 2 + columnWidth / 2
            },"Invert", new GUIStyle(EditorStyles.label) { alignment = TextAnchor.MiddleRight});
            channelInvert = EditorGUI.Toggle(new Rect(rect)
            {
                width = 10,
                x = columnWidth * 2 + columnWidth / 2 + labelWidth
            }, channelInvert);
        }

        public override IEnumerable<MaterialProperty> GetReferencedProperties(MaterialEditor materialEditor, MaterialProperty[] properties, DrawerParameters parameters)
        {
            var textureProperty = parameters.Get(0, properties);
            var extraProperty = parameters.Get(1, properties);
            
            return new[] { textureProperty, extraProperty };
        }
    }
}
#endif