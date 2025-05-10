using UnityEngine;
using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine.Rendering;

[CreateAssetMenu(fileName = "ORLMaterialConverterPreset", menuName = "Shader/orels1/Material Converter Preset", order = 0)]
public class ORLMaterialConverterPreset : ScriptableObject
{
    public Shader sourceShader;
    public List<Shader> sourceAlternatives;
    public Shader targetShader;
    public List<Shader> targetAlternatives;
    public enum PropertyType
    {
        Number,
        Color,
        Vector,
        Texture2D,
        Texture3D,
        TextureCube,
        Keyword,
    }

    public enum TransferType
    {
        Copy,
        Set
    }

    public enum TextureChannel
    {
        R,
        G,
        B,
        A
    }

    public enum VectorChannel
    {
        X,
        Y,
        Z,
        W
    }

    public enum ConversionType
    {
        Copy,
        OneMinus,
        FlatValue,
    }

    [Serializable]
    public struct TextureConverterSetup
    {
        public TextureChannel sourceChannel;
        public TextureChannel targetChannel;
        public ConversionType conversionType;
        public float convertedValue;
    }

    [Serializable]
    public struct VectorConverterSetup
    {
        public VectorChannel sourceChannel;
        public VectorChannel targetChannel;
        public ConversionType conversionType;
        public float convertedValue;
    }

    [Serializable]
    public struct PropertyMap
    {
        public PropertyType type;
        public string sourceName;
        public string targetName;
        public TransferType transferType;
        public float transferValue;
        public string keywordBackigPropertyName;
        public List<TextureConverterSetup> textureConverterSetup;
        public List<VectorConverterSetup> vectorConverterSetup;
    }

    public List<PropertyMap> propertyMaps = new List<PropertyMap>();

    public Material Convert(Material sourceMaterial, bool inPlace = false)
    {
        var newMat = new Material(targetShader);
        newMat.CopyMatchingPropertiesFromMaterial(sourceMaterial);

        // Perform manual conversions where necessary
        foreach (var propertyMap in propertyMaps)
        {
            switch (propertyMap.type)
            {
                case PropertyType.Number:
                    if (propertyMap.transferType == TransferType.Copy)
                    {
                        newMat.SetFloat(propertyMap.targetName, sourceMaterial.GetFloat(propertyMap.sourceName));
                    }
                    else
                    {
                        newMat.SetFloat(propertyMap.targetName, propertyMap.transferValue);
                    }
                    break;
                case PropertyType.Color:
                    if (propertyMap.transferType == TransferType.Copy)
                    {
                        newMat.SetColor(propertyMap.targetName, sourceMaterial.GetColor(propertyMap.sourceName));
                    }
                    else
                    {
                        newMat.SetColor(propertyMap.targetName, new Color(propertyMap.transferValue, propertyMap.transferValue, propertyMap.transferValue));
                    }
                    break;
                case PropertyType.Vector:
                    if (propertyMap.transferType == TransferType.Copy)
                    {
                        newMat.SetVector(propertyMap.targetName, sourceMaterial.GetVector(propertyMap.sourceName));
                    }
                    else
                    {
                        newMat.SetVector(propertyMap.targetName, new Vector4(propertyMap.transferValue, propertyMap.transferValue, propertyMap.transferValue, propertyMap.transferValue));
                    }
                    break;
                case PropertyType.Texture2D:
                    var allTextureSources = propertyMaps.Where(map => map.targetName == propertyMap.targetName).ToList();
                    // Already transferred this texture
                    if (allTextureSources.IndexOf(propertyMap) > 0) break;
                    Debug.Log($"Transfering texture: {propertyMap.sourceName} -> {propertyMap.targetName}");
                    // If just need to re-assign the texture
                    if (allTextureSources.Count == 1)
                    {
                        Debug.Log($"Only one source for {propertyMap.targetName}");
                        var allChannelsMatch = propertyMap.textureConverterSetup.All(c => c.sourceChannel == c.targetChannel && c.conversionType == ConversionType.Copy);
                        if (allChannelsMatch)
                        {
                            Debug.Log($"All channels match for {propertyMap.targetName}");
                            newMat.SetTexture(propertyMap.targetName, sourceMaterial.GetTexture(propertyMap.sourceName));
                        }
                        else
                        {
#if ORL_SHADER_INSPECTOR
                            var newTexture = CombineTexture(sourceMaterial, propertyMap, propertyMaps);
                            newMat.SetTexture(propertyMap.targetName, newTexture);
#endif
                        }
                    }
                    else
                    {
#if ORL_SHADER_INSPECTOR
                        var newTexture = CombineTexture(sourceMaterial, propertyMap, propertyMaps);
                        newMat.SetTexture(propertyMap.targetName, newTexture);
#endif
                    }
                    break;
                case PropertyType.Texture3D:
                    break;
                case PropertyType.TextureCube:
                    break;
                case PropertyType.Keyword:
                    if (propertyMap.transferType == TransferType.Copy)
                    {
                        var isEnabled = sourceMaterial.IsKeywordEnabled(propertyMap.sourceName);
                        newMat.SetFloat(propertyMap.keywordBackigPropertyName, isEnabled ? 1 : 0);
                        newMat.SetKeyword(new LocalKeyword(targetShader, propertyMap.targetName), isEnabled);
                    }
                    else
                    {
                        var isEnabled = propertyMap.transferValue > 0;
                        newMat.SetFloat(propertyMap.keywordBackigPropertyName, isEnabled ? 1 : 0);
                        newMat.SetKeyword(new LocalKeyword(targetShader, propertyMap.targetName), isEnabled);
                    }
                    break;
            }
        }

        return newMat;
    }

    private Texture2D CombineTexture(Material sourceMaterial, PropertyMap propertyMap, List<PropertyMap> propertyMaps)
    {
#if ORL_SHADER_INSPECTOR
        var textures = new Texture2D[4];
        var channels = new int[4];
        var values = new float[4];
        var inverts = new bool[4];
        var sourceSrgb = new bool[4];

        var allTextureSources = propertyMaps.Where(map => map.targetName == propertyMap.targetName).ToList();

        foreach (var textureEntry in allTextureSources)
        {
            foreach (var setup in textureEntry.textureConverterSetup)
            {
                Debug.Log($"Transfering texture: {textureEntry.sourceName}[{setup.sourceChannel}]({setup.convertedValue}) -> {propertyMap.targetName}[{setup.targetChannel}]");
                textures[(int)setup.targetChannel] = setup.conversionType == ConversionType.FlatValue ? null : (Texture2D)sourceMaterial.GetTexture(textureEntry.sourceName);
                channels[(int)setup.targetChannel] = (int)setup.sourceChannel;
                values[(int)setup.targetChannel] = setup.convertedValue;
                inverts[(int)setup.targetChannel] = setup.conversionType == ConversionType.OneMinus;

                sourceSrgb[(int)setup.targetChannel] = textures[(int)setup.targetChannel] != null && AssetImporter.GetAtPath(AssetDatabase.GetAssetPath(textures[(int)setup.targetChannel])) is TextureImporter importer && importer.sRGBTexture;
            }
        }

        var size = 2048;
        var folder = AssetDatabase.GetAssetPath(sourceMaterial);
        folder = folder.Substring(0, folder.LastIndexOf("/"));
        var texName = propertyMap.sourceName == null ? "" : sourceMaterial.GetTexture(propertyMap.sourceName).name;
        var savePath = folder + "/" + texName;
        if (texName == "")
        {
            savePath += GUID.Generate().ToString();
        }
        savePath += ".png";

        var newTexture = ORL.Drawers.TexturePacker.PackTexture(
            textures,
            channels,
            values,
            inverts,
            sourceSrgb,
            false,
            size,
            savePath
        );

        return newTexture;
#else
        return null;
#endif
    }
}