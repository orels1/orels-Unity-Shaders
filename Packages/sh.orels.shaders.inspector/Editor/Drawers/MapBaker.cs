
using System;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;
using Object = UnityEngine.Object;
using System.Text;
using UnityEngine.Experimental.Rendering;
using ORL.ShaderInspector;
using JetBrains.Annotations;



#if ORL_SHADER_GENERATOR
using ORL.ShaderGenerator;
#endif

namespace ORL.Drawers
{
    public static class MapBaker
    {
        public enum BakerChannel
        {
            Albedo,
            Mask,
            Normal
        }

        private static Texture _openFolderIcon;
        private static GUIStyle _openFolderIconStyle;

        internal static void DrawMapBaker(MaterialEditor editor, Material material, ref Dictionary<string, object> uiState)
        {
#if ORL_SHADER_GENERATOR
            uiState.TryGetValue("bakePath", out var bakePathBoxed);
            var bakePath = (string)bakePathBoxed;

            var currValue = (bool)uiState["mapBakerShown"];
            var newValue = Styles.DrawFoldoutHeader("Bake Texture Channels", currValue);

            if (currValue != newValue)
            {
                uiState["mapBakerShown"] = newValue;
                editor.Repaint();
            }

            if (!newValue) return;

#if UNITY_2022_1_OR_NEWER
            // Unity 2022 is 1 more level nested
            EditorGUI.indentLevel = 0;
#endif

            if (string.IsNullOrWhiteSpace(bakePath))
            {
                bakePath = Path.GetDirectoryName(AssetDatabase.GetAssetPath(material)).Replace("\\", "/");
            }

            {
                if (_openFolderIcon == null)
                {
                    _openFolderIcon = EditorGUIUtility.IconContent(EditorGUIUtility.isProSkin ? "d_FolderOpened Icon" : "FolderOpened Icon").image;
                }
                if (_openFolderIconStyle == null)
                {
#if UNITY_2022_1_OR_NEWER
                    _openFolderIconStyle = new GUIStyle(EditorStyles.iconButton)
#else
                    _openFolderIconStyle = new GUIStyle(EditorStyles.miniButton)
#endif
                    {
                        alignment = TextAnchor.MiddleCenter,
                        margin = new RectOffset(0, 0, 2, 0)
                    };
                }


                EditorGUILayout.LabelField("This tool allows you to bake down a shader-based effect into static textures.\nNot every effect will work correctly with this system, so feel free to experiment!", Styles.NoteTextStyle);
                EditorGUILayout.Space(10);

                using (new EditorGUILayout.HorizontalScope())
                {
                    bakePath = EditorGUILayout.TextField("Bake Path", bakePath);
                    if (GUILayout.Button(_openFolderIcon, _openFolderIconStyle))
                    {
                        bakePath = EditorUtility.OpenFolderPanel("select Bake Path", "Assets", null);
                        bakePath = "Assets" + bakePath.Replace(Application.dataPath, "");
                    }
                }

                EditorGUILayout.Space();

                var materialName = material.name;
                materialName = materialName.Replace("/", "").Replace("\\", "");

                EditorGUILayout.LabelField("Bake Texture Channels", EditorStyles.boldLabel);
                EditorGUILayout.LabelField("Bakes the selected channels into a new texture", Styles.NoteTextStyle);

                using (new EditorGUILayout.HorizontalScope())
                {
                    if (GUILayout.Button("Albedo"))
                    {
                        BakeMap(material, $"{bakePath}/{materialName}_Baked_Albedo.png", BakerChannel.Albedo);
                    }
                    if (GUILayout.Button("Masks"))
                    {
                        BakeMap(material, $"{bakePath}/{materialName}_Baked_Masks.png", BakerChannel.Mask);
                    }
                    if (GUILayout.Button("Normal"))
                    {
                        BakeMap(material, $"{bakePath}/{materialName}_Baked_Normal.png", BakerChannel.Normal);
                    }
                }

                EditorGUILayout.Space(5);

                EditorGUILayout.LabelField("Bake PBR Material", EditorStyles.boldLabel);
                EditorGUILayout.LabelField("Bakes all the channels into textures and creates a new ORL Standard PBR material with them assigned", Styles.NoteTextStyle);
                EditorGUILayout.Space(5);

                if (GUILayout.Button("Bake Material", GUILayout.Height(25)))
                {
                    BakeMap(material, $"{bakePath}/{materialName}_Baked_Albedo.png", BakerChannel.Albedo);
                    BakeMap(material, $"{bakePath}/{materialName}_Baked_Masks.png", BakerChannel.Mask);
                    BakeMap(material, $"{bakePath}/{materialName}_Baked_Normal.png", BakerChannel.Normal);
                    var pbrShader = Shader.Find("orels1/Standard");
                    var pbrMaterial = new Material(pbrShader);
                    pbrMaterial.SetTexture("_MainTex", AssetDatabase.LoadAssetAtPath<Texture2D>($"{bakePath}/{materialName}_Baked_Albedo.png"));
                    pbrMaterial.SetTexture("_MaskMap", AssetDatabase.LoadAssetAtPath<Texture2D>($"{bakePath}/{materialName}_Baked_Masks.png"));
                    pbrMaterial.SetTexture("_BumpMap", AssetDatabase.LoadAssetAtPath<Texture2D>($"{bakePath}/{materialName}_Baked_Normal.png"));
                    pbrMaterial.SetTexture("_DFG", AssetDatabase.LoadAssetAtPath<Texture2D>("Packages/sh.orels.shaders.generator/Runtime/Assets/dfg-multiscatter.exr"));
                    var materialPath = $"{bakePath}/{materialName}_Baked_PBR.mat";
                    if (File.Exists(materialPath))
                    {
                        File.Delete(materialPath);
                    }
                    AssetDatabase.Refresh();
                    AssetDatabase.CreateAsset(pbrMaterial, $"{bakePath}/{materialName}_Baked_PBR.mat");
                    AssetDatabase.SaveAssets();
                    AssetDatabase.Refresh();
                }
            }
#endif
        }

#if ORL_SHADER_GENERATOR
        [PublicAPI]
        public static void BakeMap(Material material, string bakePath, BakerChannel channel)
        {
            var shaderPath = AssetDatabase.GetAssetPath(material.shader);
            var importer = AssetImporter.GetAtPath(shaderPath);

            // Only show the baker if the shader is generated
            if (importer is ShaderDefinitionImporter shaderImporter)
            {
                // Set up the correct lighting model for map extraction
                var shaderText = File.ReadAllLines(shaderPath);
                var parser = new Parser();
                var blocks = parser.Parse(shaderText);

                var lightingModelIndex = blocks.FindIndex(b => b.Name == "%LightingModel");
                if (lightingModelIndex == -1)
                {
                    blocks.Insert(0, new ShaderBlock
                    {
                        Name = "%LightingModel",
                        Params = new List<string>()
                        {
                            "\"@/LightingModels/MapBaker\""
                        },
                        Order = -1,
                        Contents = new List<string>()
                    });
                }
                else
                {
                    blocks[lightingModelIndex].Params[0] = "\"@/LightingModels/MapBaker\"";
                }

                var shaderNameBlockIndex = blocks.FindIndex(b => b.Name == "%ShaderName");
                if (shaderNameBlockIndex != -1)
                {
                    blocks[shaderNameBlockIndex].Params[0] = $"\"Hidden/orels1/MapBaker\"";
                }

                // Construct the new baker shader
                try
                {
                    if (!Directory.Exists("Assets/orels1_TempAssets"))
                    {
                        Directory.CreateDirectory("Assets/orels1_TempAssets");
                    }

                    var newShaderBuilder = new StringBuilder();

                    foreach (var block in blocks)
                    {
                        newShaderBuilder.AppendLine();
                        newShaderBuilder.Append(block.Name);
                        newShaderBuilder.Append("(");
                        newShaderBuilder.Append(string.Join(", ", block.Params));
                        if (block.Order != -1)
                        {
                            newShaderBuilder.Append(", ");
                            newShaderBuilder.Append(block.Order);
                        }
                        newShaderBuilder.Append(")");
                        newShaderBuilder.AppendLine("{");
                        foreach (var line in block.Contents)
                        {
                            newShaderBuilder.AppendLine(line);
                        }
                        newShaderBuilder.AppendLine("}");
                    }

                    File.WriteAllText("Assets/orels1_TempAssets/Baker.orlshader", newShaderBuilder.ToString());
                    AssetDatabase.Refresh();

                    var clonedMaterial = new Material(material)
                    {
#if UNITY_2022_1_OR_NEWER
                        parent = null
#endif
                    };

                    AssetDatabase.CreateAsset(clonedMaterial, "Assets/orels1_TempAssets/Baker_mat_temp.mat");
                    var bakerShader = AssetDatabase.LoadAssetAtPath<Shader>("Assets/orels1_TempAssets/Baker.orlshader");
                    clonedMaterial.shader = bakerShader;
                    clonedMaterial.SetInt("_BakerChannel", (int)channel);

                    var source = clonedMaterial.GetTexture("_MainTex");
                    var shouldDestroySource = false;
                    if (source == null)
                    {
                        source = new Texture2D(4096, 4096, TextureFormat.RGBA32, true);
                        shouldDestroySource = true;
                    }
                    var target = new Texture2D(4096, 4096, TextureFormat.RGBA32, true);
                    RenderTexture buffer;
                    if (channel == BakerChannel.Normal)
                    {
#if UNITY_2022_1_OR_NEWER
                        buffer = new RenderTexture(4096, 4096, GraphicsFormat.R16G16B16A16_UNorm, GraphicsFormat.D24_UNorm_S8_UInt);
#else
                        buffer = new RenderTexture(4096, 4096, 24, RenderTextureFormat.ARGB64);
#endif
                    }
                    else
                    {
                        buffer = new RenderTexture(4096, 4096, 24, DefaultFormat.LDR);
                    }
                    clonedMaterial.SetVector("__MapBaker_MainTex_ST", material.GetVector("_MainTex_ST"));
                    Graphics.Blit(source, buffer, clonedMaterial);
                    RenderTexture.active = buffer;
                    target.ReadPixels(new Rect(0, 0, 4096, 4096), 0, 0);
                    target.Apply();
                    RenderTexture.active = null;
                    if (shouldDestroySource)
                    {
                        Object.DestroyImmediate(source);
                    }
                    Object.DestroyImmediate(buffer);

                    var final = target.EncodeToPNG();
                    if (File.Exists(bakePath))
                    {
                        File.Delete(bakePath);
                    }
                    File.WriteAllBytes(bakePath, final);
                    Object.DestroyImmediate(target);
                    Directory.Delete("Assets/orels1_TempAssets", true);
                    File.Delete("Assets/orels1_TempAssets.meta");
                    AssetDatabase.Refresh();

                    if (channel == BakerChannel.Normal)
                    {
                        var textureImporter = AssetImporter.GetAtPath(bakePath) as TextureImporter;
                        textureImporter.textureType = TextureImporterType.NormalMap;
                        textureImporter.SaveAndReimport();
                    }
                }
                catch (Exception ex)
                {
                    Debug.LogError("Failed to build the baker shader: " + ex.Message);
                    Debug.LogException(ex);
                }
            }
        }

    }
#endif

}
