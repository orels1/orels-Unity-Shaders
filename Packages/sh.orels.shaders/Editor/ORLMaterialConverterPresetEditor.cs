using UnityEngine;
using UnityEditor;
using System;
using System.Linq;

[CustomEditor(typeof(ORLMaterialConverterPreset))]
public class ORLMaterialConverterPresetEditor : Editor
{
    private Vector2 _scrollPos;
    private readonly ORLMaterialConverterPreset.PropertyType[] _texturePropertyTypes = new ORLMaterialConverterPreset.PropertyType[] {
        ORLMaterialConverterPreset.PropertyType.Texture2D,
        ORLMaterialConverterPreset.PropertyType.Texture3D,
        ORLMaterialConverterPreset.PropertyType.TextureCube
    };
    public override void OnInspectorGUI()
    {
        EditorGUILayout.LabelField("Converter Preset", EditorStyles.boldLabel);
        serializedObject.Update();

        EditorGUILayout.LabelField("Source Configuration", EditorStyles.miniBoldLabel);
        EditorGUILayout.PropertyField(serializedObject.FindProperty("sourceShader"));
        EditorGUILayout.PropertyField(serializedObject.FindProperty("sourceAlternatives"));

        EditorGUILayout.Space();

        EditorGUILayout.LabelField("Target Configuration", EditorStyles.miniBoldLabel);
        EditorGUILayout.PropertyField(serializedObject.FindProperty("targetShader"));
        EditorGUILayout.PropertyField(serializedObject.FindProperty("targetAlternatives"));

        EditorGUILayout.Space();

        EditorGUILayout.LabelField("Conversion Settings", EditorStyles.miniBoldLabel);

        var propertyMaps = serializedObject.FindProperty("propertyMaps");

        using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
        {
            using (var scroller = new GUILayout.ScrollViewScope(_scrollPos))
            {
                _scrollPos = scroller.scrollPosition;
                using (new EditorGUI.IndentLevelScope())
                {
                    for (int i = 0; i < propertyMaps.arraySize; i++)
                    {
                        using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
                        {
                            var propertyMap = propertyMaps.GetArrayElementAtIndex(i);
                            using (new EditorGUILayout.HorizontalScope())
                            {
                                propertyMap.isExpanded = EditorGUILayout.Foldout(propertyMap.isExpanded, string.IsNullOrWhiteSpace(propertyMap.FindPropertyRelative("sourceName").displayName) ? $"Property {i}" : propertyMap.FindPropertyRelative("sourceName").stringValue, true);
                                if (GUILayout.Button("-", GUILayout.Width(20), GUILayout.Height(15)))
                                {
                                    propertyMaps.DeleteArrayElementAtIndex(i);
                                    break;
                                }
                            }
                            if (!propertyMap.isExpanded) continue;

                            using (new EditorGUILayout.HorizontalScope())
                            {
                                EditorGUILayout.PropertyField(propertyMap.FindPropertyRelative("sourceName"), GUIContent.none);
                                EditorGUILayout.LabelField("→", GUILayout.Width(40));
                                EditorGUILayout.PropertyField(propertyMap.FindPropertyRelative("targetName"), GUIContent.none);
                            }
                            var typeProp = propertyMap.FindPropertyRelative("type");
                            typeProp.enumValueIndex = EditorGUILayout.Popup("Type", typeProp.enumValueIndex, typeProp.enumDisplayNames);
                            var transferTypeProp = propertyMap.FindPropertyRelative("transferType");

                            var typeValue = (ORLMaterialConverterPreset.PropertyType)typeProp.enumValueIndex;
                            switch (typeValue)
                            {
                                case ORLMaterialConverterPreset.PropertyType.Number:
                                    {
                                        transferTypeProp.enumValueIndex = EditorGUILayout.Popup(GUIContent.none, transferTypeProp.enumValueIndex, transferTypeProp.enumDisplayNames);
                                        var transferTypeValue = (ORLMaterialConverterPreset.TransferType)transferTypeProp.enumValueIndex;
                                        if (transferTypeValue == ORLMaterialConverterPreset.TransferType.Set)
                                        {
                                            EditorGUILayout.PropertyField(propertyMap.FindPropertyRelative("transferValue"), new GUIContent("Value"));
                                        }
                                        break;
                                    }
                                case ORLMaterialConverterPreset.PropertyType.Keyword:
                                    {
                                        EditorGUILayout.PropertyField(propertyMap.FindPropertyRelative("keywordBackigPropertyName"), new GUIContent("Backing Property", "Keywords are backed by shader properties. Both need to be set at the same time, otherwise unity will reset the value back"));
                                        transferTypeProp.enumValueIndex = EditorGUILayout.Popup(GUIContent.none, transferTypeProp.enumValueIndex, transferTypeProp.enumDisplayNames);
                                        var transferTypeValue = (ORLMaterialConverterPreset.TransferType)transferTypeProp.enumValueIndex;
                                        if (transferTypeValue == ORLMaterialConverterPreset.TransferType.Set)
                                        {
                                            var keywordValueProp = propertyMap.FindPropertyRelative("transferValue");
                                            keywordValueProp.floatValue = EditorGUILayout.Toggle("Value", keywordValueProp.floatValue > 0) ? 1 : 0;
                                        }
                                        break;

                                    }
                                case ORLMaterialConverterPreset.PropertyType.Texture2D:
                                case ORLMaterialConverterPreset.PropertyType.Texture3D:
                                case ORLMaterialConverterPreset.PropertyType.TextureCube:
                                    {
                                        var textureConverterSetup = propertyMap.FindPropertyRelative("textureConverterSetup");
                                        for (int j = 0; j < textureConverterSetup.arraySize; j++)
                                        {
                                            var channelConverter = textureConverterSetup.GetArrayElementAtIndex(j);
                                            using (new EditorGUILayout.HorizontalScope())
                                            {
                                                using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
                                                {
                                                    using (new EditorGUILayout.HorizontalScope())
                                                    {
                                                        var newRect = EditorGUILayout.GetControlRect();
                                                        var channelRect = newRect;
                                                        channelRect.width = newRect.width / 2.0f;
                                                        channelRect.x -= 15;
                                                        channelConverter.FindPropertyRelative("sourceChannel").enumValueIndex = EditorGUI.Popup(channelRect, channelConverter.FindPropertyRelative("sourceChannel").enumValueIndex, channelConverter.FindPropertyRelative("sourceChannel").enumDisplayNames);
                                                        channelRect.x += channelRect.width;
                                                        EditorGUI.LabelField(channelRect, "→");
                                                        channelRect.x += 40;
                                                        channelRect.width -= 25;
                                                        channelConverter.FindPropertyRelative("targetChannel").enumValueIndex = EditorGUI.Popup(channelRect, channelConverter.FindPropertyRelative("targetChannel").enumValueIndex, channelConverter.FindPropertyRelative("targetChannel").enumDisplayNames);
                                                    }
                                                    var conversionTypeProp = channelConverter.FindPropertyRelative("conversionType");
                                                    EditorGUI.indentLevel--;
                                                    conversionTypeProp.enumValueIndex = EditorGUILayout.Popup(GUIContent.none, conversionTypeProp.enumValueIndex, conversionTypeProp.enumDisplayNames);
                                                    if (conversionTypeProp.enumValueIndex != (int)ORLMaterialConverterPreset.ConversionType.FlatValue)
                                                    {
                                                        EditorGUILayout.PropertyField(channelConverter.FindPropertyRelative("convertedValue"), new GUIContent("Default Value", "Default value will be used if the texture is not set"));
                                                    }
                                                    if (conversionTypeProp.enumValueIndex == (int)ORLMaterialConverterPreset.ConversionType.FlatValue)
                                                    {
                                                        EditorGUILayout.PropertyField(channelConverter.FindPropertyRelative("convertedValue"));
                                                    }
                                                    EditorGUI.indentLevel++;
                                                }
                                                if (GUILayout.Button("-", GUILayout.Width(20), GUILayout.ExpandHeight(true)))
                                                {
                                                    textureConverterSetup.DeleteArrayElementAtIndex(j);
                                                    break;
                                                }
                                            }
                                        }
                                        if (textureConverterSetup.arraySize == 0)
                                        {
                                            if (GUILayout.Button("Add RGBA Channels"))
                                            {
                                                textureConverterSetup.InsertArrayElementAtIndex(textureConverterSetup.arraySize);
                                                textureConverterSetup.GetArrayElementAtIndex(textureConverterSetup.arraySize - 1).FindPropertyRelative("sourceChannel").enumValueIndex = (int)ORLMaterialConverterPreset.TextureChannel.R;
                                                textureConverterSetup.GetArrayElementAtIndex(textureConverterSetup.arraySize - 1).FindPropertyRelative("targetChannel").enumValueIndex = (int)ORLMaterialConverterPreset.TextureChannel.R;
                                                textureConverterSetup.InsertArrayElementAtIndex(textureConverterSetup.arraySize);
                                                textureConverterSetup.GetArrayElementAtIndex(textureConverterSetup.arraySize - 1).FindPropertyRelative("sourceChannel").enumValueIndex = (int)ORLMaterialConverterPreset.TextureChannel.G;
                                                textureConverterSetup.GetArrayElementAtIndex(textureConverterSetup.arraySize - 1).FindPropertyRelative("targetChannel").enumValueIndex = (int)ORLMaterialConverterPreset.TextureChannel.G;
                                                textureConverterSetup.InsertArrayElementAtIndex(textureConverterSetup.arraySize);
                                                textureConverterSetup.GetArrayElementAtIndex(textureConverterSetup.arraySize - 1).FindPropertyRelative("sourceChannel").enumValueIndex = (int)ORLMaterialConverterPreset.TextureChannel.B;
                                                textureConverterSetup.GetArrayElementAtIndex(textureConverterSetup.arraySize - 1).FindPropertyRelative("targetChannel").enumValueIndex = (int)ORLMaterialConverterPreset.TextureChannel.B;
                                                textureConverterSetup.InsertArrayElementAtIndex(textureConverterSetup.arraySize);
                                                textureConverterSetup.GetArrayElementAtIndex(textureConverterSetup.arraySize - 1).FindPropertyRelative("sourceChannel").enumValueIndex = (int)ORLMaterialConverterPreset.TextureChannel.A;
                                                textureConverterSetup.GetArrayElementAtIndex(textureConverterSetup.arraySize - 1).FindPropertyRelative("targetChannel").enumValueIndex = (int)ORLMaterialConverterPreset.TextureChannel.A;
                                            }
                                        }
                                        else if (GUILayout.Button("Add Channel"))
                                        {
                                            textureConverterSetup.InsertArrayElementAtIndex(textureConverterSetup.arraySize);
                                        }
                                        break;
                                    }
                            }
                        }
                    }
                }
            }
            if (GUILayout.Button("Add Property Map", GUILayout.Height(30)))
            {
                propertyMaps.InsertArrayElementAtIndex(propertyMaps.arraySize);
            }
        }

        EditorGUILayout.Space(10);
        EditorGUILayout.LabelField("Property Mappings (manual)", EditorStyles.miniBoldLabel);
        EditorGUILayout.PropertyField(propertyMaps);

        serializedObject.ApplyModifiedProperties();
    }
}