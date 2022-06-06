Shader "orels1/Toon/Main"
{
	Properties
	{
		[ToggleUI] UI_MainHeader("# Main Settings", Int) =  0
		_Color("Main Color", Color) =  (1, 1, 1, 1)
		[ToggleUI] _TintByVertexColor("Tint By Vertex Color", Int) =  0
		_MainTex("Albedo", 2D) =  "white" {}
		[ToggleUI] UI_RampRef("!REF _Ramp", Int) =  0
		_ShadowSharpness("Shadow Sharpness", Range(0,1)) =  0.5
		_OcclusionMap("Occlusion &&", 2D) =  "white" {}
		_OcclusionStrength("Occlusion Strength", Range(0,1)) =  0
		[Enum(Classic, 0, Integrated, 1)] _OcclusionMode("Occlusion Mode", Int) =  0
		[ToggleUI] UI_OcclusionIndirectModeNote("!NOTE Classic - Multiplies indirect light by occlusion", Int) =  0
		[ToggleUI] UI_OcclusionIntegrateModeNote("!NOTE Integrated - Multiplies the shadow ramp by occlusion", Int) =  0
		[ToggleUI] UI_NormalsHeader("# Normals", Int) =  0
		[NoScaleOffset] _BumpMap("Normal Map &&", 2D) =  "bump" {}
		_BumpScale("Normal Map Scale", Range(-2, 2)) =  1
		[ToggleUI][_BumpMap] _FlipBumpY("Flip Y (UE Mode) [_BumpMap]", Int) =  0
		[ToggleUI] UI_DetailNormalsHeader("## Detail Normals", Int) =  0
		_DetailNormalMap("Detail Normal", 2D) =  "bump" {}
		[Enum(UV1, 0, UV2, 1, UV3, 2, UV4, 3)][_DetailNormalMap] _DetailNormalsUVSet("UV Set [_DetailNormalMap]", Int) =  0
		[_DetailNormalMap] _DetailNormalScale("Detail Normal Map Scale [_DetailNormalMap]", Range(-2, 2)) =  1
		[ToggleUI][_DetailNormalMap] _FlipDetailNormalY("Flip Y (UE Mode) [_DetailNormalMap]", Int) =  0
		[_DetailNormalMap] _DetailNormalsMask("Detail Normal Mask && [_DetailNormalMap]", 2D) =  "white" {}
		[Enum(UV1, 0, UV2, 1, UV3, 2, UV4, 3)][_DetailNormalMap] _DetailNormalUVSet("UV Set [_DetailNormalMap]", Int) =  0
		[ToggleUI] UI_OutlineHeader("# Outline", Int) =  0
		[Toggle(OUTLINE_ENABLED)] _Outline("Enable Outline", Int) =  0
		[HDR][OUTLINE_ENABLED] _OutlineColor("Color [OUTLINE_ENABLED]", Color) =  (0.5, 0.5, 0.5, 1)
		[Enum(Lit, 0, Emissive, 1)][OUTLINE_ENABLED] _OutlineLightingMode("Lighting Mode [OUTLINE_ENABLED]", Int) =  0
		[OUTLINE_ENABLED] _OutlineAlbedoTint("Albedo Tint [OUTLINE_ENABLED]", Range(0, 1)) =  0
		[OUTLINE_ENABLED] _OutlineMask("Width Mask [OUTLINE_ENABLED]", 2D) =  "white" {}
		[OUTLINE_ENABLED] _OutlineWidth("Width [OUTLINE_ENABLED]", Range(0, 5)) =  1
		[ToggleUI] UI_SpecularHeader("# Specular Settings", Int) =  0
		[ToggleUI] UI_SpecularMapPacker("!DRAWER TexturePacker _SpecularMap", Int) =  0
		_SpecularMap("Specular Map", 2D) =  "white" {}
		[ToggleUI] UI_SpecMapdNote("!NOTE Red - Intensity, Green - Albedo Tint, Blue - Smoothness", Int) =  0
		[Enum(UV1, 0, UV2, 1, UV3, 2, UV4, 3)] _SpecularMapUVSet("UV Set", Int) =  0
		[Space(10)] _SpecularIntensity("Intensity", Float) =  0
		_SpecularRoughness("Roughness", Range(0, 1)) =  0
		_SpecularSharpness("Sharpness", Range(0, 1)) =  0
		_SpecularAnisotropy("Anisotropy", Range(-1.0, 1.0)) =  0
		_SpecularAlbedoTint("Albedo Tint", Range(0, 1)) =  1
		[ToggleUI] UI_ReflectionsHeader("# Reflection Settings", Int) =  0
		[Enum(PBR(Unity Metallic Standard),0,Baked Cubemap,1,Matcap,2,Off,3)] _ReflectionMode("Reflection Mode", Int) =  3
		[Enum(Additive,0,Multiply,1,Subtract,2)] _ReflectionBlendMode("Reflection Blend Mode [_ReflectionMode != 3]", Int) =  0
		[ToggleUI] UI_BakedCubemapRef("!REF _BakedCubemap [_ReflectionMode == 0 || _ReflectionMode == 1]", Cube) =  "black" {}
		[ToggleUI] UI_FallbackNote("!NOTE Will be used if world has no reflections [_ReflectionMode == 0]", Int) =  0
		_MetallicGlossMap("Metallic Smoothness & [_ReflectionMode == 0 || _ReflectionMode == 1]", 2D) =  "white" {}
		[ToggleUI] UI_MetallicNote("!NOTE R - Metallic, A - Smoothness [_ReflectionMode == 0 || _ReflectionMode == 1]", Int) =  0
		_Smoothness("Smoothness [!_MetallicGlossMap && (_ReflectionMode == 0 || _ReflectionMode == 1)]", Range(0, 1)) =  0.5
		[ToggleUI] _RoughnessMode("Roughness Mode [_MetallicGlossMap && (_ReflectionMode == 0 || _ReflectionMode == 1)]", Int) =  0
		[ToggleUI] UI_SmoothnessRemap("!DRAWER MinMax _SmoothnessRemap.x _SmoothnessRemap.y [_MetallicGlossMap && (_ReflectionMode == 0 || _ReflectionMode == 1)]", Float) =  0
		_Metallic("Metallic [!_MetallicGlossMap && (_ReflectionMode == 0 || _ReflectionMode == 1)]", Range(0, 1)) =  0
		[ToggleUI] UI_MetallicRemap("!DRAWER MinMax _MetallicRemap.x _MetallicRemap.y [_MetallicGlossMap && (_ReflectionMode == 0 || _ReflectionMode == 1)]", Float) =  0
		[HideInInspector] _MetallicRemap("Metallic Remap", Vector) =  (0, 1, 0, 1)
		[HideInInspector] _SmoothnessRemap("Smoothness Remap", Vector) =  (0, 1, 0, 1)
		_ReflectionAnisotropy("Anisotropy [_ReflectionMode == 0]", Range(-1, 1)) =  0
		_Matcap("Matcap & [_ReflectionMode == 2]", 2D) =  "black" {}
		_MatcapBlur("Matcap Blur Level [_ReflectionMode == 2]", Range(0, 1)) =  0
		_MatcapTintToDiffuse("Tint Matcap to Diffuse [_ReflectionMode == 2]", Range(0, 1)) =  0
		_ReflectivityMask("Reflectivity Mask && [_ReflectionMode != 3]", 2D) =  "white" {}
		_ReflectivityLevel("Reflectivity [_ReflectionMode != 3]", Range(0, 1)) =  0.5
		[ToggleUI] UI_AudioLink("# AudioLink Settings", Int) =  0
		[Enum(None,0,Single Channel,1,Packed Map,2,UV Based,3)] _ALMode("Audio Link Mode", Int) =  0
		[NoScaleOffset] _ALMap("Audio Link Map && [_ALMode != 0]", 2D) =  "white" {}
		[Enum(UV1, 0, UV2, 1, UV3, 2, UV4, 3)] _ALMapUVSet("UV Set [_ALMode != 0]", Int) =  0
		[HDR] _ALEmissionColor("Color [_ALMode != 0 && _ALMode != 2]", Color) =  (0,0,0,0)
		[Enum(Bass,0,Low Mids,1,High Mids,3,Treble,4)] _ALBand("Frequency Band [_ALMode == 1]", Int) =  0
		[ToggleUI] UI_ALPackedRedHeader("## Red Channel [_ALMode == 2]", Int) =  0
		[ToggleUI] UI_ALPackedPropRed("!DRAWER MultiProperty _ALGradientOnRed _ALPackedRedColor [_ALMode == 2]", Int) =  0
		[ToggleUI] _ALGradientOnRed("Gradient", Int) =  0
		[HDR] _ALPackedRedColor("Color", Color) =  (0,0,0,0)
		[ToggleUI] UI_ALPackedGreenHeader("## Green Channel [_ALMode == 2]", Int) =  0
		[ToggleUI] UI_ALPackedPropGreen("!DRAWER MultiProperty _ALGradientOnGreen _ALPackedGreenColor [_ALMode == 2]", Int) =  0
		[ToggleUI] _ALGradientOnGreen("Gradient", Int) =  0
		[HDR] _ALPackedGreenColor("Color", Color) =  (0,0,0,0)
		[ToggleUI] UI_ALPackedBlueHeader("## Blue Channel [_ALMode == 2]", Int) =  0
		[ToggleUI] UI_ALPackedPropBlue("!DRAWER MultiProperty _ALGradientOnBlue _ALPackedBlueColor [_ALMode == 2]", Int) =  0
		[ToggleUI] _ALGradientOnBlue("Gradient", Int) =  0
		[HDR] _ALPackedBlueColor("Color", Color) =  (0,0,0,0)
		[IntRange] _ALUVWidth("History Sample Amount [_ALMode == 3]", Range(0,128)) =  128
		[ToggleUI] UI_EmissionHeader("# Emission Settings", Int) =  0
		[NoScaleOffset] _EmissionMap("Emission Map &&", 2D) =  "white" {}
		[HDR] _EmissionColor("Emission Color", Color) =  (0,0,0,1)
		_EmissionTintToDiffuse("Emission Tint To Diffuse", Range(0,1)) =  0
		[Enum(Yes,0,No,1)] _EmissionScaleWithLight("Emission Scale w/ Light", Int) =  1
		_EmissionScaleWithLightSensitivity("Scaling Sensitivity [_EmissionScaleWithLight == 0]", Range(0,1)) =  1
		[ToggleUI] UI_RimLightHeader("# Rim Light Settings", Int) =  0
		_RimTint("Tint", Color) =  (1,1,1,1)
		_RimIntensity("Intensity", Float) =  0
		_RimAlbedoTint("Albedo Tint", Range(0,1)) =  0
		_RimEnvironmentTint("Environment Tint", Range(0,1)) =  0
		_RimAttenuation("Attenuation", Range(0,1)) =  1
		_RimRange("Range", Range(0, 1)) =  0.7
		_RimThreshold("Threshold", Range(0, 1)) =  0.1
		_RimSharpness("Sarpness", Range(0,1)) =  0.1
		[ToggleUI] UI_RimShadowHeader("# Rim Shadow Settings", Int) =  0
		_ShadowRimTint("Tint", Color) =  (1,1,1,1)
		_ShadowRimRange("Range", Range(0,1)) =  0.7
		_ShadowRimThreshold("Threshold", Range(0,1)) =  0.1
		_ShadowRimSharpness("Sarpness", Range(0,1)) =  0.3
		_ShadowRimAlbedoTint("Albedo Tint", Range(0,1)) =  0
		[HideInInspector][NoScaleOffset] _Ramp("Shadow Ramp", 2D) = "white" {}
		[HideInInspector][NoScaleOffset][SingleLineTexture] _BakedCubemap("Baked Cubemap", Cube) = ""{}
		[ToggleUI] UI_AdvancedHeader("# Advanced Features", Float) = 0
		[Enum(UnityEngine.Rendering.CullMode)] _CullMode("Culling Mode", Int) = 2
		[Enum(Off, 0, On, 1)] _ZWrite("Depth Write", Int) = 1
		[Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("Depth Test", Int) = 4
	}
	SubShader
	{
		Tags {  }
		
		ZTest[_ZTest]
		ZWrite[_ZWrite]
		Cull[_CullMode]
		
		Pass
		{
			Tags { "LightMode" = "ForwardBase"  }
			
			// ForwardBase Pass Start
			CGPROGRAM
			#pragma target 4.5
			#pragma multi_compile_instancing
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			#pragma vertex Vertex
			#pragma fragment Fragment
			#pragma shader_feature_local OUTLINE_ENABLED
			
			#define UNITY_INSTANCED_LOD_FADE
			#define UNITY_INSTANCED_SH
			#define UNITY_INSTANCED_LIGHTMAPSTS
			
			#ifndef UNITY_PASS_FORWARDBASE
			#define UNITY_PASS_FORWARDBASE
			#endif
			
			#include "UnityStandardUtils.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			
			#define FLT_EPSILON     1.192092896e-07
			
			#if defined(UNITY_PBS_USE_BRDF2) || defined(SHADER_API_MOBILE)
			#define PLAT_QUEST
			#else
			#ifdef PLAT_QUEST
			#undef PLAT_QUEST
			#endif
			#endif
			
			#define NEED_SCREEN_POS
			
			#define grayscaleVec float3(0.2125, 0.7154, 0.0721)
			
			// Credit to Jason Booth for digging this all up
			// This originally comes from CoreRP, see Jason's comment below
			
			// If your looking in here and thinking WTF, yeah, I know. These are taken from the SRPs, to allow us to use the same
			// texturing library they use. However, since they are not included in the standard pipeline by default, there is no
			// way to include them in and they have to be inlined, since someone could copy this shader onto another machine without
			// Better Shaders installed. Unfortunate, but I'd rather do this and have a nice library for texture sampling instead
			// of the patchy one Unity provides being inlined/emulated in HDRP/URP. Strangely, PSSL and XBoxOne libraries are not
			// included in the standard SRP code, but they are in tons of Unity own projects on the web, so I grabbed them from there.
			
			#if defined(SHADER_API_XBOXONE)
			
			// Initialize arbitrary structure with zero values.
			// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
			#define ZERO_INITIALIZE(type, name) name = (type)0;
			#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }
			
			// Texture util abstraction
			
			#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) textureName.CalculateLevelOfDetail(samplerName, coord2)
			
			// Texture abstraction
			
			#define TEXTURE2D(textureName)                Texture2D textureName
			#define TEXTURE2D_ARRAY(textureName)          Texture2DArray textureName
			#define TEXTURECUBE(textureName)              TextureCube textureName
			#define TEXTURECUBE_ARRAY(textureName)        TextureCubeArray textureName
			#define TEXTURE3D(textureName)                Texture3D textureName
			
			#define TEXTURE2D_FLOAT(textureName)          TEXTURE2D(textureName)
			#define TEXTURE2D_ARRAY_FLOAT(textureName)    TEXTURE2D_ARRAY(textureName)
			#define TEXTURECUBE_FLOAT(textureName)        TEXTURECUBE(textureName)
			#define TEXTURECUBE_ARRAY_FLOAT(textureName)  TEXTURECUBE_ARRAY(textureName)
			#define TEXTURE3D_FLOAT(textureName)          TEXTURE3D(textureName)
			
			#define TEXTURE2D_HALF(textureName)           TEXTURE2D(textureName)
			#define TEXTURE2D_ARRAY_HALF(textureName)     TEXTURE2D_ARRAY(textureName)
			#define TEXTURECUBE_HALF(textureName)         TEXTURECUBE(textureName)
			#define TEXTURECUBE_ARRAY_HALF(textureName)   TEXTURECUBE_ARRAY(textureName)
			#define TEXTURE3D_HALF(textureName)           TEXTURE3D(textureName)
			
			#define TEXTURE2D_SHADOW(textureName)         TEXTURE2D(textureName)
			#define TEXTURE2D_ARRAY_SHADOW(textureName)   TEXTURE2D_ARRAY(textureName)
			#define TEXTURECUBE_SHADOW(textureName)       TEXTURECUBE(textureName)
			#define TEXTURECUBE_ARRAY_SHADOW(textureName) TEXTURECUBE_ARRAY(textureName)
			
			#define RW_TEXTURE2D(type, textureName)       RWTexture2D<type> textureName
			#define RW_TEXTURE2D_ARRAY(type, textureName) RWTexture2DArray<type> textureName
			#define RW_TEXTURE3D(type, textureName)       RWTexture3D<type> textureName
			
			#define SAMPLER(samplerName)                  SamplerState samplerName
			#define SAMPLER_CMP(samplerName)              SamplerComparisonState samplerName
			
			#define TEXTURE2D_PARAM(textureName, samplerName)                 TEXTURE2D(textureName), SAMPLER(samplerName)
			#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)           TEXTURE2D_ARRAY(textureName), SAMPLER(samplerName)
			#define TEXTURECUBE_PARAM(textureName, samplerName)               TEXTURECUBE(textureName), SAMPLER(samplerName)
			#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)         TEXTURECUBE_ARRAY(textureName), SAMPLER(samplerName)
			#define TEXTURE3D_PARAM(textureName, samplerName)                 TEXTURE3D(textureName), SAMPLER(samplerName)
			
			#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)          TEXTURE2D(textureName), SAMPLER_CMP(samplerName)
			#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)    TEXTURE2D_ARRAY(textureName), SAMPLER_CMP(samplerName)
			#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)        TEXTURECUBE(textureName), SAMPLER_CMP(samplerName)
			#define TEXTURECUBE_ARRAY_SHADOW_PARAM(textureName, samplerName)  TEXTURECUBE_ARRAY(textureName), SAMPLER_CMP(samplerName)
			
			#define TEXTURE2D_ARGS(textureName, samplerName)                textureName, samplerName
			#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)          textureName, samplerName
			#define TEXTURECUBE_ARGS(textureName, samplerName)              textureName, samplerName
			#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)        textureName, samplerName
			#define TEXTURE3D_ARGS(textureName, samplerName)                textureName, samplerName
			
			#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)         textureName, samplerName
			#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)   textureName, samplerName
			#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)       textureName, samplerName
			#define TEXTURECUBE_ARRAY_SHADOW_ARGS(textureName, samplerName) textureName, samplerName
			
			#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
			#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod)                      textureName.SampleLevel(samplerName, coord2, lod)
			#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                    textureName.SampleBias(samplerName, coord2, bias)
			#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, dpdx, dpdy)              textureName.SampleGrad(samplerName, coord2, dpdx, dpdy)
			#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                  textureName.Sample(samplerName, float3(coord2, index))
			#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)         textureName.SampleLevel(samplerName, float3(coord2, index), lod)
			#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)       textureName.SampleBias(samplerName, float3(coord2, index), bias)
			#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy) textureName.SampleGrad(samplerName, float3(coord2, index), dpdx, dpdy)
			#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                             textureName.Sample(samplerName, coord3)
			#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                    textureName.SampleLevel(samplerName, coord3, lod)
			#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                  textureName.SampleBias(samplerName, coord3, bias)
			#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)                textureName.Sample(samplerName, float4(coord3, index))
			#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)       textureName.SampleLevel(samplerName, float4(coord3, index), lod)
			#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)     textureName.SampleBias(samplerName, float4(coord3, index), bias)
			#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                               textureName.Sample(samplerName, coord3)
			#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                      textureName.SampleLevel(samplerName, coord3, lod)
			
			#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                    textureName.SampleCmpLevelZero(samplerName, (coord3).xy, (coord3).z)
			#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)       textureName.SampleCmpLevelZero(samplerName, float3((coord3).xy, index), (coord3).z)
			#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                  textureName.SampleCmpLevelZero(samplerName, (coord4).xyz, (coord4).w)
			#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)     textureName.SampleCmpLevelZero(samplerName, float4((coord4).xyz, index), (coord4).w)
			
			#define LOAD_TEXTURE2D(textureName, unCoord2)                                   textureName.Load(int3(unCoord2, 0))
			#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)                          textureName.Load(int3(unCoord2, lod))
			#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)                 textureName.Load(unCoord2, sampleIndex)
			#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)                      textureName.Load(int4(unCoord2, index, 0))
			#define LOAD_TEXTURE2D_ARRAY_MSAA(textureName, unCoord2, index, sampleIndex)    textureName.Load(int3(unCoord2, index), sampleIndex)
			#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod)             textureName.Load(int4(unCoord2, index, lod))
			#define LOAD_TEXTURE3D(textureName, unCoord3)                                   textureName.Load(int4(unCoord3, 0))
			#define LOAD_TEXTURE3D_LOD(textureName, unCoord3, lod)                          textureName.Load(int4(unCoord3, lod))
			
			#define PLATFORM_SUPPORT_GATHER
			#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                textureName.Gather(samplerName, coord2)
			#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)   textureName.Gather(samplerName, float3(coord2, index))
			#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)              textureName.Gather(samplerName, coord3)
			#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index) textureName.Gather(samplerName, float4(coord3, index))
			#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)            textureName.GatherRed(samplerName, coord2)
			#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherGreen(samplerName, coord2)
			#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)           textureName.GatherBlue(samplerName, coord2)
			#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherAlpha(samplerName, coord2)
			
			#elif defined(SHADER_API_PSSL)
			
			// Initialize arbitrary structure with zero values.
			// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
			#define ZERO_INITIALIZE(type, name) name = (type)0;
			#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }
			
			// Texture util abstraction
			
			#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) textureName.GetLOD(samplerName, coord2)
			
			// Texture abstraction
			
			#define TEXTURE2D(textureName)                Texture2D textureName
			#define TEXTURE2D_ARRAY(textureName)          Texture2DArray textureName
			#define TEXTURECUBE(textureName)              TextureCube textureName
			#define TEXTURECUBE_ARRAY(textureName)        TextureCubeArray textureName
			#define TEXTURE3D(textureName)                Texture3D textureName
			
			#define TEXTURE2D_FLOAT(textureName)          TEXTURE2D(textureName)
			#define TEXTURE2D_ARRAY_FLOAT(textureName)    TEXTURE2D_ARRAY(textureName)
			#define TEXTURECUBE_FLOAT(textureName)        TEXTURECUBE(textureName)
			#define TEXTURECUBE_ARRAY_FLOAT(textureName)  TEXTURECUBE_ARRAY(textureName)
			#define TEXTURE3D_FLOAT(textureName)          TEXTURE3D(textureName)
			
			#define TEXTURE2D_HALF(textureName)           TEXTURE2D(textureName)
			#define TEXTURE2D_ARRAY_HALF(textureName)     TEXTURE2D_ARRAY(textureName)
			#define TEXTURECUBE_HALF(textureName)         TEXTURECUBE(textureName)
			#define TEXTURECUBE_ARRAY_HALF(textureName)   TEXTURECUBE_ARRAY(textureName)
			#define TEXTURE3D_HALF(textureName)           TEXTURE3D(textureName)
			
			#define TEXTURE2D_SHADOW(textureName)         TEXTURE2D(textureName)
			#define TEXTURE2D_ARRAY_SHADOW(textureName)   TEXTURE2D_ARRAY(textureName)
			#define TEXTURECUBE_SHADOW(textureName)       TEXTURECUBE(textureName)
			#define TEXTURECUBE_ARRAY_SHADOW(textureName) TEXTURECUBE_ARRAY(textureName)
			
			#define RW_TEXTURE2D(type, textureName)       RW_Texture2D<type> textureName
			#define RW_TEXTURE2D_ARRAY(type, textureName) RW_Texture2D_Array<type> textureName
			#define RW_TEXTURE3D(type, textureName)       RW_Texture3D<type> textureName
			
			#define SAMPLER(samplerName)                  SamplerState samplerName
			#define SAMPLER_CMP(samplerName)              SamplerComparisonState samplerName
			
			#define TEXTURE2D_PARAM(textureName, samplerName)                 TEXTURE2D(textureName), SAMPLER(samplerName)
			#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)           TEXTURE2D_ARRAY(textureName), SAMPLER(samplerName)
			#define TEXTURECUBE_PARAM(textureName, samplerName)               TEXTURECUBE(textureName), SAMPLER(samplerName)
			#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)         TEXTURECUBE_ARRAY(textureName), SAMPLER(samplerName)
			#define TEXTURE3D_PARAM(textureName, samplerName)                 TEXTURE3D(textureName), SAMPLER(samplerName)
			
			#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)          TEXTURE2D(textureName), SAMPLER_CMP(samplerName)
			#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)    TEXTURE2D_ARRAY(textureName), SAMPLER_CMP(samplerName)
			#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)        TEXTURECUBE(textureName), SAMPLER_CMP(samplerName)
			#define TEXTURECUBE_ARRAY_SHADOW_PARAM(textureName, samplerName)  TEXTURECUBE_ARRAY(textureName), SAMPLER_CMP(samplerName)
			
			#define TEXTURE2D_ARGS(textureName, samplerName)                textureName, samplerName
			#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)          textureName, samplerName
			#define TEXTURECUBE_ARGS(textureName, samplerName)              textureName, samplerName
			#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)        textureName, samplerName
			#define TEXTURE3D_ARGS(textureName, samplerName)                textureName, samplerName
			
			#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)         textureName, samplerName
			#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)   textureName, samplerName
			#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)       textureName, samplerName
			#define TEXTURECUBE_ARRAY_SHADOW_ARGS(textureName, samplerName) textureName, samplerName
			
			#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
			#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod)                      textureName.SampleLevel(samplerName, coord2, lod)
			#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                    textureName.SampleBias(samplerName, coord2, bias)
			#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, dpdx, dpdy)              textureName.SampleGrad(samplerName, coord2, dpdx, dpdy)
			#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                  textureName.Sample(samplerName, float3(coord2, index))
			#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)         textureName.SampleLevel(samplerName, float3(coord2, index), lod)
			#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)       textureName.SampleBias(samplerName, float3(coord2, index), bias)
			#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy) textureName.SampleGrad(samplerName, float3(coord2, index), dpdx, dpdy)
			#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                             textureName.Sample(samplerName, coord3)
			#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                    textureName.SampleLevel(samplerName, coord3, lod)
			#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                  textureName.SampleBias(samplerName, coord3, bias)
			#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)                textureName.Sample(samplerName, float4(coord3, index))
			#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)       textureName.SampleLevel(samplerName, float4(coord3, index), lod)
			#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)     textureName.SampleBias(samplerName, float4(coord3, index), bias)
			#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                               textureName.Sample(samplerName, coord3)
			#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                      textureName.SampleLevel(samplerName, coord3, lod)
			
			#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                    textureName.SampleCmpLevelZero(samplerName, (coord3).xy, (coord3).z)
			#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)       textureName.SampleCmpLevelZero(samplerName, float3((coord3).xy, index), (coord3).z)
			#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                  textureName.SampleCmpLevelZero(samplerName, (coord4).xyz, (coord4).w)
			#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)     textureName.SampleCmpLevelZero(samplerName, float4((coord4).xyz, index), (coord4).w)
			
			#define LOAD_TEXTURE2D(textureName, unCoord2)                                   textureName.Load(int3(unCoord2, 0))
			#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)                          textureName.Load(int3(unCoord2, lod))
			#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)                 textureName.Load(unCoord2, sampleIndex)
			#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)                      textureName.Load(int4(unCoord2, index, 0))
			#define LOAD_TEXTURE2D_ARRAY_MSAA(textureName, unCoord2, index, sampleIndex)    textureName.Load(int3(unCoord2, index), sampleIndex)
			#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod)             textureName.Load(int4(unCoord2, index, lod))
			#define LOAD_TEXTURE3D(textureName, unCoord3)                                   textureName.Load(int4(unCoord3, 0))
			#define LOAD_TEXTURE3D_LOD(textureName, unCoord3, lod)                          textureName.Load(int4(unCoord3, lod))
			
			#define PLATFORM_SUPPORT_GATHER
			#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                textureName.Gather(samplerName, coord2)
			#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)   textureName.Gather(samplerName, float3(coord2, index))
			#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)              textureName.Gather(samplerName, coord3)
			#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index) textureName.Gather(samplerName, float4(coord3, index))
			#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)            textureName.GatherRed(samplerName, coord2)
			#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherGreen(samplerName, coord2)
			#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)           textureName.GatherBlue(samplerName, coord2)
			#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherAlpha(samplerName, coord2)
			
			#elif defined(SHADER_API_D3D11)
			
			// Initialize arbitrary structure with zero values.
			// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
			#define ZERO_INITIALIZE(type, name) name = (type)0;
			#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }
			
			// Texture util abstraction
			
			#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) textureName.CalculateLevelOfDetail(samplerName, coord2)
			
			// Texture abstraction
			
			#define TEXTURE2D(textureName)                Texture2D textureName
			#define TEXTURE2D_ARRAY(textureName)          Texture2DArray textureName
			#define TEXTURECUBE(textureName)              TextureCube textureName
			#define TEXTURECUBE_ARRAY(textureName)        TextureCubeArray textureName
			#define TEXTURE3D(textureName)                Texture3D textureName
			
			#define TEXTURE2D_FLOAT(textureName)          TEXTURE2D(textureName)
			#define TEXTURE2D_ARRAY_FLOAT(textureName)    TEXTURE2D_ARRAY(textureName)
			#define TEXTURECUBE_FLOAT(textureName)        TEXTURECUBE(textureName)
			#define TEXTURECUBE_ARRAY_FLOAT(textureName)  TEXTURECUBE_ARRAY(textureName)
			#define TEXTURE3D_FLOAT(textureName)          TEXTURE3D(textureName)
			
			#define TEXTURE2D_HALF(textureName)           TEXTURE2D(textureName)
			#define TEXTURE2D_ARRAY_HALF(textureName)     TEXTURE2D_ARRAY(textureName)
			#define TEXTURECUBE_HALF(textureName)         TEXTURECUBE(textureName)
			#define TEXTURECUBE_ARRAY_HALF(textureName)   TEXTURECUBE_ARRAY(textureName)
			#define TEXTURE3D_HALF(textureName)           TEXTURE3D(textureName)
			
			#define TEXTURE2D_SHADOW(textureName)         TEXTURE2D(textureName)
			#define TEXTURE2D_ARRAY_SHADOW(textureName)   TEXTURE2D_ARRAY(textureName)
			#define TEXTURECUBE_SHADOW(textureName)       TEXTURECUBE(textureName)
			#define TEXTURECUBE_ARRAY_SHADOW(textureName) TEXTURECUBE_ARRAY(textureName)
			
			#define RW_TEXTURE2D(type, textureName)       RWTexture2D<type> textureName
			#define RW_TEXTURE2D_ARRAY(type, textureName) RWTexture2DArray<type> textureName
			#define RW_TEXTURE3D(type, textureName)       RWTexture3D<type> textureName
			
			#define SAMPLER(samplerName)                  SamplerState samplerName
			#define SAMPLER_CMP(samplerName)              SamplerComparisonState samplerName
			
			#define TEXTURE2D_PARAM(textureName, samplerName)                 TEXTURE2D(textureName), SAMPLER(samplerName)
			#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)           TEXTURE2D_ARRAY(textureName), SAMPLER(samplerName)
			#define TEXTURECUBE_PARAM(textureName, samplerName)               TEXTURECUBE(textureName), SAMPLER(samplerName)
			#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)         TEXTURECUBE_ARRAY(textureName), SAMPLER(samplerName)
			#define TEXTURE3D_PARAM(textureName, samplerName)                 TEXTURE3D(textureName), SAMPLER(samplerName)
			
			#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)          TEXTURE2D(textureName), SAMPLER_CMP(samplerName)
			#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)    TEXTURE2D_ARRAY(textureName), SAMPLER_CMP(samplerName)
			#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)        TEXTURECUBE(textureName), SAMPLER_CMP(samplerName)
			#define TEXTURECUBE_ARRAY_SHADOW_PARAM(textureName, samplerName)  TEXTURECUBE_ARRAY(textureName), SAMPLER_CMP(samplerName)
			
			#define TEXTURE2D_ARGS(textureName, samplerName)                textureName, samplerName
			#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)          textureName, samplerName
			#define TEXTURECUBE_ARGS(textureName, samplerName)              textureName, samplerName
			#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)        textureName, samplerName
			#define TEXTURE3D_ARGS(textureName, samplerName)                textureName, samplerName
			
			#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)         textureName, samplerName
			#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)   textureName, samplerName
			#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)       textureName, samplerName
			#define TEXTURECUBE_ARRAY_SHADOW_ARGS(textureName, samplerName) textureName, samplerName
			
			#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
			#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod)                      textureName.SampleLevel(samplerName, coord2, lod)
			#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                    textureName.SampleBias(samplerName, coord2, bias)
			#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, dpdx, dpdy)              textureName.SampleGrad(samplerName, coord2, dpdx, dpdy)
			#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                  textureName.Sample(samplerName, float3(coord2, index))
			#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)         textureName.SampleLevel(samplerName, float3(coord2, index), lod)
			#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)       textureName.SampleBias(samplerName, float3(coord2, index), bias)
			#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy) textureName.SampleGrad(samplerName, float3(coord2, index), dpdx, dpdy)
			#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                             textureName.Sample(samplerName, coord3)
			#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                    textureName.SampleLevel(samplerName, coord3, lod)
			#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                  textureName.SampleBias(samplerName, coord3, bias)
			#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)                textureName.Sample(samplerName, float4(coord3, index))
			#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)       textureName.SampleLevel(samplerName, float4(coord3, index), lod)
			#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)     textureName.SampleBias(samplerName, float4(coord3, index), bias)
			#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                               textureName.Sample(samplerName, coord3)
			#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                      textureName.SampleLevel(samplerName, coord3, lod)
			
			#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                    textureName.SampleCmpLevelZero(samplerName, (coord3).xy, (coord3).z)
			#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)       textureName.SampleCmpLevelZero(samplerName, float3((coord3).xy, index), (coord3).z)
			#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                  textureName.SampleCmpLevelZero(samplerName, (coord4).xyz, (coord4).w)
			#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)     textureName.SampleCmpLevelZero(samplerName, float4((coord4).xyz, index), (coord4).w)
			
			#define LOAD_TEXTURE2D(textureName, unCoord2)                                   textureName.Load(int3(unCoord2, 0))
			#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)                          textureName.Load(int3(unCoord2, lod))
			#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)                 textureName.Load(unCoord2, sampleIndex)
			#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)                      textureName.Load(int4(unCoord2, index, 0))
			#define LOAD_TEXTURE2D_ARRAY_MSAA(textureName, unCoord2, index, sampleIndex)    textureName.Load(int3(unCoord2, index), sampleIndex)
			#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod)             textureName.Load(int4(unCoord2, index, lod))
			#define LOAD_TEXTURE3D(textureName, unCoord3)                                   textureName.Load(int4(unCoord3, 0))
			#define LOAD_TEXTURE3D_LOD(textureName, unCoord3, lod)                          textureName.Load(int4(unCoord3, lod))
			
			#define PLATFORM_SUPPORT_GATHER
			#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                textureName.Gather(samplerName, coord2)
			#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)   textureName.Gather(samplerName, float3(coord2, index))
			#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)              textureName.Gather(samplerName, coord3)
			#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index) textureName.Gather(samplerName, float4(coord3, index))
			#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)            textureName.GatherRed(samplerName, coord2)
			#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherGreen(samplerName, coord2)
			#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)           textureName.GatherBlue(samplerName, coord2)
			#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherAlpha(samplerName, coord2)
			
			#elif defined(SHADER_API_METAL)
			
			// Initialize arbitrary structure with zero values.
			// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
			#define ZERO_INITIALIZE(type, name) name = (type)0;
			#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }
			
			// Texture util abstraction
			
			#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) textureName.CalculateLevelOfDetail(samplerName, coord2)
			
			// Texture abstraction
			
			#define TEXTURE2D(textureName)                Texture2D textureName
			#define TEXTURE2D_ARRAY(textureName)          Texture2DArray textureName
			#define TEXTURECUBE(textureName)              TextureCube textureName
			#define TEXTURECUBE_ARRAY(textureName)        TextureCubeArray textureName
			#define TEXTURE3D(textureName)                Texture3D textureName
			
			#define TEXTURE2D_FLOAT(textureName)          Texture2D_float textureName
			#define TEXTURE2D_ARRAY_FLOAT(textureName)    Texture2DArray textureName    // no support to _float on Array, it's being added
			#define TEXTURECUBE_FLOAT(textureName)        TextureCube_float textureName
			#define TEXTURECUBE_ARRAY_FLOAT(textureName)  TextureCubeArray textureName  // no support to _float on Array, it's being added
			#define TEXTURE3D_FLOAT(textureName)          Texture3D_float textureName
			
			#define TEXTURE2D_HALF(textureName)           Texture2D_half textureName
			#define TEXTURE2D_ARRAY_HALF(textureName)     Texture2DArray textureName    // no support to _float on Array, it's being added
			#define TEXTURECUBE_HALF(textureName)         TextureCube_half textureName
			#define TEXTURECUBE_ARRAY_HALF(textureName)   TextureCubeArray textureName  // no support to _float on Array, it's being added
			#define TEXTURE3D_HALF(textureName)           Texture3D_half textureName
			
			#define TEXTURE2D_SHADOW(textureName)         TEXTURE2D(textureName)
			#define TEXTURE2D_ARRAY_SHADOW(textureName)   TEXTURE2D_ARRAY(textureName)
			#define TEXTURECUBE_SHADOW(textureName)       TEXTURECUBE(textureName)
			#define TEXTURECUBE_ARRAY_SHADOW(textureName) TEXTURECUBE_ARRAY(textureName)
			
			#define RW_TEXTURE2D(type, textureName)       RWTexture2D<type> textureName
			#define RW_TEXTURE2D_ARRAY(type, textureName) RWTexture2DArray<type> textureName
			#define RW_TEXTURE3D(type, textureName)       RWTexture3D<type> textureName
			
			#define SAMPLER(samplerName)                  SamplerState samplerName
			#define SAMPLER_CMP(samplerName)              SamplerComparisonState samplerName
			
			#define TEXTURE2D_PARAM(textureName, samplerName)                 TEXTURE2D(textureName), SAMPLER(samplerName)
			#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)           TEXTURE2D_ARRAY(textureName), SAMPLER(samplerName)
			#define TEXTURECUBE_PARAM(textureName, samplerName)               TEXTURECUBE(textureName), SAMPLER(samplerName)
			#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)         TEXTURECUBE_ARRAY(textureName), SAMPLER(samplerName)
			#define TEXTURE3D_PARAM(textureName, samplerName)                 TEXTURE3D(textureName), SAMPLER(samplerName)
			
			#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)          TEXTURE2D(textureName), SAMPLER_CMP(samplerName)
			#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)    TEXTURE2D_ARRAY(textureName), SAMPLER_CMP(samplerName)
			#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)        TEXTURECUBE(textureName), SAMPLER_CMP(samplerName)
			#define TEXTURECUBE_ARRAY_SHADOW_PARAM(textureName, samplerName)  TEXTURECUBE_ARRAY(textureName), SAMPLER_CMP(samplerName)
			
			#define TEXTURE2D_ARGS(textureName, samplerName)                textureName, samplerName
			#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)          textureName, samplerName
			#define TEXTURECUBE_ARGS(textureName, samplerName)              textureName, samplerName
			#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)        textureName, samplerName
			#define TEXTURE3D_ARGS(textureName, samplerName)                textureName, samplerName
			
			#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)         textureName, samplerName
			#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)   textureName, samplerName
			#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)       textureName, samplerName
			#define TEXTURECUBE_ARRAY_SHADOW_ARGS(textureName, samplerName) textureName, samplerName
			
			#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
			#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod)                      textureName.SampleLevel(samplerName, coord2, lod)
			#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                    textureName.SampleBias(samplerName, coord2, bias)
			#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, dpdx, dpdy)              textureName.SampleGrad(samplerName, coord2, dpdx, dpdy)
			#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                  textureName.Sample(samplerName, float3(coord2, index))
			#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)         textureName.SampleLevel(samplerName, float3(coord2, index), lod)
			#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)       textureName.SampleBias(samplerName, float3(coord2, index), bias)
			#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy) textureName.SampleGrad(samplerName, float3(coord2, index), dpdx, dpdy)
			#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                             textureName.Sample(samplerName, coord3)
			#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                    textureName.SampleLevel(samplerName, coord3, lod)
			#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                  textureName.SampleBias(samplerName, coord3, bias)
			#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)                textureName.Sample(samplerName, float4(coord3, index))
			#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)       textureName.SampleLevel(samplerName, float4(coord3, index), lod)
			#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)     textureName.SampleBias(samplerName, float4(coord3, index), bias)
			#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                               textureName.Sample(samplerName, coord3)
			#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                      textureName.SampleLevel(samplerName, coord3, lod)
			
			#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                    textureName.SampleCmpLevelZero(samplerName, (coord3).xy, (coord3).z)
			#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)       textureName.SampleCmpLevelZero(samplerName, float3((coord3).xy, index), (coord3).z)
			#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                  textureName.SampleCmpLevelZero(samplerName, (coord4).xyz, (coord4).w)
			#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)     textureName.SampleCmpLevelZero(samplerName, float4((coord4).xyz, index), (coord4).w)
			
			#define LOAD_TEXTURE2D(textureName, unCoord2)                                   textureName.Load(int3(unCoord2, 0))
			#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)                          textureName.Load(int3(unCoord2, lod))
			#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)                 textureName.Load(unCoord2, sampleIndex)
			#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)                      textureName.Load(int4(unCoord2, index, 0))
			#define LOAD_TEXTURE2D_ARRAY_MSAA(textureName, unCoord2, index, sampleIndex)    textureName.Load(int3(unCoord2, index), sampleIndex)
			#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod)             textureName.Load(int4(unCoord2, index, lod))
			#define LOAD_TEXTURE3D(textureName, unCoord3)                                   textureName.Load(int4(unCoord3, 0))
			#define LOAD_TEXTURE3D_LOD(textureName, unCoord3, lod)                          textureName.Load(int4(unCoord3, lod))
			
			#define PLATFORM_SUPPORT_GATHER
			#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                textureName.Gather(samplerName, coord2)
			#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)   textureName.Gather(samplerName, float3(coord2, index))
			#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)              textureName.Gather(samplerName, coord3)
			#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index) textureName.Gather(samplerName, float4(coord3, index))
			#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)            textureName.GatherRed(samplerName, coord2)
			#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherGreen(samplerName, coord2)
			#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)           textureName.GatherBlue(samplerName, coord2)
			#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherAlpha(samplerName, coord2)
			
			#elif defined(SHADER_API_VULKAN)
			// This file assume SHADER_API_VULKAN is defined
			// TODO: This is a straight copy from D3D11.hlsl. Go through all this stuff and adjust where needed.
			
			// Initialize arbitrary structure with zero values.
			// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
			#define ZERO_INITIALIZE(type, name) name = (type)0;
			#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }
			
			// Texture util abstraction
			
			#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) textureName.CalculateLevelOfDetail(samplerName, coord2)
			
			// Texture abstraction
			
			#define TEXTURE2D(textureName)                Texture2D textureName
			#define TEXTURE2D_ARRAY(textureName)          Texture2DArray textureName
			#define TEXTURECUBE(textureName)              TextureCube textureName
			#define TEXTURECUBE_ARRAY(textureName)        TextureCubeArray textureName
			#define TEXTURE3D(textureName)                Texture3D textureName
			
			#define TEXTURE2D_FLOAT(textureName)          Texture2D_float textureName
			#define TEXTURE2D_ARRAY_FLOAT(textureName)    Texture2DArray textureName    // no support to _float on Array, it's being added
			#define TEXTURECUBE_FLOAT(textureName)        TextureCube_float textureName
			#define TEXTURECUBE_ARRAY_FLOAT(textureName)  TextureCubeArray textureName  // no support to _float on Array, it's being added
			#define TEXTURE3D_FLOAT(textureName)          Texture3D_float textureName
			
			#define TEXTURE2D_HALF(textureName)           Texture2D_half textureName
			#define TEXTURE2D_ARRAY_HALF(textureName)     Texture2DArray textureName    // no support to _float on Array, it's being added
			#define TEXTURECUBE_HALF(textureName)         TextureCube_half textureName
			#define TEXTURECUBE_ARRAY_HALF(textureName)   TextureCubeArray textureName  // no support to _float on Array, it's being added
			#define TEXTURE3D_HALF(textureName)           Texture3D_half textureName
			
			#define TEXTURE2D_SHADOW(textureName)         TEXTURE2D(textureName)
			#define TEXTURE2D_ARRAY_SHADOW(textureName)   TEXTURE2D_ARRAY(textureName)
			#define TEXTURECUBE_SHADOW(textureName)       TEXTURECUBE(textureName)
			#define TEXTURECUBE_ARRAY_SHADOW(textureName) TEXTURECUBE_ARRAY(textureName)
			
			#define RW_TEXTURE2D(type, textureName)       RWTexture2D<type> textureName
			#define RW_TEXTURE2D_ARRAY(type, textureName) RWTexture2DArray<type> textureName
			#define RW_TEXTURE3D(type, textureName)       RWTexture3D<type> textureName
			
			#define SAMPLER(samplerName)                  SamplerState samplerName
			#define SAMPLER_CMP(samplerName)              SamplerComparisonState samplerName
			
			#define TEXTURE2D_PARAM(textureName, samplerName)                 TEXTURE2D(textureName), SAMPLER(samplerName)
			#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)           TEXTURE2D_ARRAY(textureName), SAMPLER(samplerName)
			#define TEXTURECUBE_PARAM(textureName, samplerName)               TEXTURECUBE(textureName), SAMPLER(samplerName)
			#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)         TEXTURECUBE_ARRAY(textureName), SAMPLER(samplerName)
			#define TEXTURE3D_PARAM(textureName, samplerName)                 TEXTURE3D(textureName), SAMPLER(samplerName)
			
			#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)          TEXTURE2D(textureName), SAMPLER_CMP(samplerName)
			#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)    TEXTURE2D_ARRAY(textureName), SAMPLER_CMP(samplerName)
			#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)        TEXTURECUBE(textureName), SAMPLER_CMP(samplerName)
			#define TEXTURECUBE_ARRAY_SHADOW_PARAM(textureName, samplerName)  TEXTURECUBE_ARRAY(textureName), SAMPLER_CMP(samplerName)
			
			#define TEXTURE2D_ARGS(textureName, samplerName)                textureName, samplerName
			#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)          textureName, samplerName
			#define TEXTURECUBE_ARGS(textureName, samplerName)              textureName, samplerName
			#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)        textureName, samplerName
			#define TEXTURE3D_ARGS(textureName, samplerName)                textureName, samplerName
			
			#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)         textureName, samplerName
			#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)   textureName, samplerName
			#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)       textureName, samplerName
			#define TEXTURECUBE_ARRAY_SHADOW_ARGS(textureName, samplerName) textureName, samplerName
			
			#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
			#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod)                      textureName.SampleLevel(samplerName, coord2, lod)
			#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                    textureName.SampleBias(samplerName, coord2, bias)
			#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, dpdx, dpdy)              textureName.SampleGrad(samplerName, coord2, dpdx, dpdy)
			#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                  textureName.Sample(samplerName, float3(coord2, index))
			#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)         textureName.SampleLevel(samplerName, float3(coord2, index), lod)
			#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)       textureName.SampleBias(samplerName, float3(coord2, index), bias)
			#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy) textureName.SampleGrad(samplerName, float3(coord2, index), dpdx, dpdy)
			#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                             textureName.Sample(samplerName, coord3)
			#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                    textureName.SampleLevel(samplerName, coord3, lod)
			#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                  textureName.SampleBias(samplerName, coord3, bias)
			#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)                textureName.Sample(samplerName, float4(coord3, index))
			#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)       textureName.SampleLevel(samplerName, float4(coord3, index), lod)
			#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)     textureName.SampleBias(samplerName, float4(coord3, index), bias)
			#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                               textureName.Sample(samplerName, coord3)
			#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                      textureName.SampleLevel(samplerName, coord3, lod)
			
			#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                    textureName.SampleCmpLevelZero(samplerName, (coord3).xy, (coord3).z)
			#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)       textureName.SampleCmpLevelZero(samplerName, float3((coord3).xy, index), (coord3).z)
			#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                  textureName.SampleCmpLevelZero(samplerName, (coord4).xyz, (coord4).w)
			#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)     textureName.SampleCmpLevelZero(samplerName, float4((coord4).xyz, index), (coord4).w)
			
			#define LOAD_TEXTURE2D(textureName, unCoord2)                                   textureName.Load(int3(unCoord2, 0))
			#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)                          textureName.Load(int3(unCoord2, lod))
			#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)                 textureName.Load(unCoord2, sampleIndex)
			#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)                      textureName.Load(int4(unCoord2, index, 0))
			#define LOAD_TEXTURE2D_ARRAY_MSAA(textureName, unCoord2, index, sampleIndex)    textureName.Load(int3(unCoord2, index), sampleIndex)
			#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod)             textureName.Load(int4(unCoord2, index, lod))
			#define LOAD_TEXTURE3D(textureName, unCoord3)                                   textureName.Load(int4(unCoord3, 0))
			#define LOAD_TEXTURE3D_LOD(textureName, unCoord3, lod)                          textureName.Load(int4(unCoord3, lod))
			
			#define PLATFORM_SUPPORT_GATHER
			#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                textureName.Gather(samplerName, coord2)
			#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)   textureName.Gather(samplerName, float3(coord2, index))
			#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)              textureName.Gather(samplerName, coord3)
			#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index) textureName.Gather(samplerName, float4(coord3, index))
			#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)            textureName.GatherRed(samplerName, coord2)
			#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherGreen(samplerName, coord2)
			#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)           textureName.GatherBlue(samplerName, coord2)
			#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherAlpha(samplerName, coord2)
			
			#elif defined(SHADER_API_SWITCH)
			// This file assume SHADER_API_SWITCH is defined
			
			// Initialize arbitrary structure with zero values.
			// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
			#define ZERO_INITIALIZE(type, name) name = (type)0;
			#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }
			
			// Texture util abstraction
			
			#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) textureName.CalculateLevelOfDetail(samplerName, coord2)
			
			// Texture abstraction
			
			#define TEXTURE2D(textureName)                Texture2D textureName
			#define TEXTURE2D_ARRAY(textureName)          Texture2DArray textureName
			#define TEXTURECUBE(textureName)              TextureCube textureName
			#define TEXTURECUBE_ARRAY(textureName)        TextureCubeArray textureName
			#define TEXTURE3D(textureName)                Texture3D textureName
			
			#define TEXTURE2D_FLOAT(textureName)          Texture2D_float textureName
			#define TEXTURE2D_ARRAY_FLOAT(textureName)    Texture2DArray textureName    // no support to _float on Array, it's being added
			#define TEXTURECUBE_FLOAT(textureName)        TextureCube_float textureName
			#define TEXTURECUBE_ARRAY_FLOAT(textureName)  TextureCubeArray textureName  // no support to _float on Array, it's being added
			#define TEXTURE3D_FLOAT(textureName)          Texture3D_float textureName
			
			#define TEXTURE2D_HALF(textureName)           Texture2D_half textureName
			#define TEXTURE2D_ARRAY_HALF(textureName)     Texture2DArray textureName    // no support to _float on Array, it's being added
			#define TEXTURECUBE_HALF(textureName)         TextureCube_half textureName
			#define TEXTURECUBE_ARRAY_HALF(textureName)   TextureCubeArray textureName  // no support to _float on Array, it's being added
			#define TEXTURE3D_HALF(textureName)           Texture3D_half textureName
			
			#define TEXTURE2D_SHADOW(textureName)         TEXTURE2D(textureName)
			#define TEXTURE2D_ARRAY_SHADOW(textureName)   TEXTURE2D_ARRAY(textureName)
			#define TEXTURECUBE_SHADOW(textureName)       TEXTURECUBE(textureName)
			#define TEXTURECUBE_ARRAY_SHADOW(textureName) TEXTURECUBE_ARRAY(textureName)
			
			#define RW_TEXTURE2D(type, textureName)       RWTexture2D<type> textureName
			#define RW_TEXTURE2D_ARRAY(type, textureName) RWTexture2DArray<type> textureName
			#define RW_TEXTURE3D(type, textureName)       RWTexture3D<type> textureName
			
			#define SAMPLER(samplerName)                  SamplerState samplerName
			#define SAMPLER_CMP(samplerName)              SamplerComparisonState samplerName
			
			#define TEXTURE2D_PARAM(textureName, samplerName)                 TEXTURE2D(textureName), SAMPLER(samplerName)
			#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)           TEXTURE2D_ARRAY(textureName), SAMPLER(samplerName)
			#define TEXTURECUBE_PARAM(textureName, samplerName)               TEXTURECUBE(textureName), SAMPLER(samplerName)
			#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)         TEXTURECUBE_ARRAY(textureName), SAMPLER(samplerName)
			#define TEXTURE3D_PARAM(textureName, samplerName)                 TEXTURE3D(textureName), SAMPLER(samplerName)
			
			#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)          TEXTURE2D(textureName), SAMPLER_CMP(samplerName)
			#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)    TEXTURE2D_ARRAY(textureName), SAMPLER_CMP(samplerName)
			#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)        TEXTURECUBE(textureName), SAMPLER_CMP(samplerName)
			#define TEXTURECUBE_ARRAY_SHADOW_PARAM(textureName, samplerName)  TEXTURECUBE_ARRAY(textureName), SAMPLER_CMP(samplerName)
			
			#define TEXTURE2D_ARGS(textureName, samplerName)                textureName, samplerName
			#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)          textureName, samplerName
			#define TEXTURECUBE_ARGS(textureName, samplerName)              textureName, samplerName
			#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)        textureName, samplerName
			#define TEXTURE3D_ARGS(textureName, samplerName)                textureName, samplerName
			
			#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)         textureName, samplerName
			#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)   textureName, samplerName
			#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)       textureName, samplerName
			#define TEXTURECUBE_ARRAY_SHADOW_ARGS(textureName, samplerName) textureName, samplerName
			
			#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
			#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod)                      textureName.SampleLevel(samplerName, coord2, lod)
			#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                    textureName.SampleBias(samplerName, coord2, bias)
			#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, dpdx, dpdy)              textureName.SampleGrad(samplerName, coord2, dpdx, dpdy)
			#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                  textureName.Sample(samplerName, float3(coord2, index))
			#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)         textureName.SampleLevel(samplerName, float3(coord2, index), lod)
			#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)       textureName.SampleBias(samplerName, float3(coord2, index), bias)
			#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy) textureName.SampleGrad(samplerName, float3(coord2, index), dpdx, dpdy)
			#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                             textureName.Sample(samplerName, coord3)
			#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                    textureName.SampleLevel(samplerName, coord3, lod)
			#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                  textureName.SampleBias(samplerName, coord3, bias)
			#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)                textureName.Sample(samplerName, float4(coord3, index))
			#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)       textureName.SampleLevel(samplerName, float4(coord3, index), lod)
			#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)     textureName.SampleBias(samplerName, float4(coord3, index), bias)
			#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                               textureName.Sample(samplerName, coord3)
			#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                      textureName.SampleLevel(samplerName, coord3, lod)
			
			#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                    textureName.SampleCmpLevelZero(samplerName, (coord3).xy, (coord3).z)
			#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)       textureName.SampleCmpLevelZero(samplerName, float3((coord3).xy, index), (coord3).z)
			#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                  textureName.SampleCmpLevelZero(samplerName, (coord4).xyz, (coord4).w)
			#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)     textureName.SampleCmpLevelZero(samplerName, float4((coord4).xyz, index), (coord4).w)
			
			#define LOAD_TEXTURE2D(textureName, unCoord2)                       textureName.Load(int3(unCoord2, 0))
			#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)              textureName.Load(int3(unCoord2, lod))
			#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)     textureName.Load(unCoord2, sampleIndex)
			#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)          textureName.Load(int4(unCoord2, index, 0))
			#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod) textureName.Load(int4(unCoord2, index, lod))
			#define LOAD_TEXTURE3D(textureName, unCoord3)                       textureName.Load(int4(unCoord3, 0))
			#define LOAD_TEXTURE3D_LOD(textureName, unCoord3, lod)              textureName.Load(int4(unCoord3, lod))
			
			#define PLATFORM_SUPPORT_GATHER
			#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                textureName.Gather(samplerName, coord2)
			#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)   textureName.Gather(samplerName, float3(coord2, index))
			#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)              textureName.Gather(samplerName, coord3)
			#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index) textureName.Gather(samplerName, float4(coord3, index))
			#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)            textureName.GatherRed(samplerName, coord2)
			#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherGreen(samplerName, coord2)
			#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)           textureName.GatherBlue(samplerName, coord2)
			#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherAlpha(samplerName, coord2)
			
			#elif defined(SHADER_API_GLCORE)
			
			// OpenGL 4.1 SM 5.0 https://docs.unity3d.com/Manual/SL-ShaderCompileTargets.html
			#if (SHADER_TARGET >= 46)
			#define OPENGL4_1_SM5 1
			#else
			#define OPENGL4_1_SM5 0
			#endif
			
			// Initialize arbitrary structure with zero values.
			// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
			#define ZERO_INITIALIZE(type, name) name = (type)0;
			#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }
			
			// Texture util abstraction
			
			#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) textureName.CalculateLevelOfDetail(samplerName, coord2)
			
			// Texture abstraction
			
			#define TEXTURE2D(textureName)                  Texture2D textureName
			#define TEXTURE2D_ARRAY(textureName)            Texture2DArray textureName
			#define TEXTURECUBE(textureName)                TextureCube textureName
			#define TEXTURECUBE_ARRAY(textureName)          TextureCubeArray textureName
			#define TEXTURE3D(textureName)                  Texture3D textureName
			
			#define TEXTURE2D_FLOAT(textureName)            TEXTURE2D(textureName)
			#define TEXTURE2D_ARRAY_FLOAT(textureName)      TEXTURE2D_ARRAY(textureName)
			#define TEXTURECUBE_FLOAT(textureName)          TEXTURECUBE(textureName)
			#define TEXTURECUBE_ARRAY_FLOAT(textureName)    TEXTURECUBE_ARRAY(textureName)
			#define TEXTURE3D_FLOAT(textureName)            TEXTURE3D(textureName)
			
			#define TEXTURE2D_HALF(textureName)             TEXTURE2D(textureName)
			#define TEXTURE2D_ARRAY_HALF(textureName)       TEXTURE2D_ARRAY(textureName)
			#define TEXTURECUBE_HALF(textureName)           TEXTURECUBE(textureName)
			#define TEXTURECUBE_ARRAY_HALF(textureName)     TEXTURECUBE_ARRAY(textureName)
			#define TEXTURE3D_HALF(textureName)             TEXTURE3D(textureName)
			
			#define TEXTURE2D_SHADOW(textureName)           TEXTURE2D(textureName)
			#define TEXTURE2D_ARRAY_SHADOW(textureName)     TEXTURE2D_ARRAY(textureName)
			#define TEXTURECUBE_SHADOW(textureName)         TEXTURECUBE(textureName)
			#define TEXTURECUBE_ARRAY_SHADOW(textureName)   TEXTURECUBE_ARRAY(textureName)
			
			#define RW_TEXTURE2D(type, textureName)         RWTexture2D<type> textureName
			#define RW_TEXTURE2D_ARRAY(type, textureName)   RWTexture2DArray<type> textureName
			#define RW_TEXTURE3D(type, textureName)         RWTexture3D<type> textureName
			
			#define SAMPLER(samplerName)                    SamplerState samplerName
			#define SAMPLER_CMP(samplerName)                SamplerComparisonState samplerName
			
			#define TEXTURE2D_PARAM(textureName, samplerName)                 TEXTURE2D(textureName), SAMPLER(samplerName)
			#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)           TEXTURE2D_ARRAY(textureName), SAMPLER(samplerName)
			#define TEXTURECUBE_PARAM(textureName, samplerName)               TEXTURECUBE(textureName), SAMPLER(samplerName)
			#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)         TEXTURECUBE_ARRAY(textureName), SAMPLER(samplerName)
			#define TEXTURE3D_PARAM(textureName, samplerName)                 TEXTURE3D(textureName), SAMPLER(samplerName)
			
			#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)          TEXTURE2D(textureName), SAMPLER_CMP(samplerName)
			#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)    TEXTURE2D_ARRAY(textureName), SAMPLER_CMP(samplerName)
			#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)        TEXTURECUBE(textureName), SAMPLER_CMP(samplerName)
			#define TEXTURECUBE_ARRAY_SHADOW_PARAM(textureName, samplerName)  TEXTURECUBE_ARRAY(textureName), SAMPLER_CMP(samplerName)
			
			#define TEXTURE2D_ARGS(textureName, samplerName)                textureName, samplerName
			#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)          textureName, samplerName
			#define TEXTURECUBE_ARGS(textureName, samplerName)              textureName, samplerName
			#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)        textureName, samplerName
			#define TEXTURE3D_ARGS(textureName, samplerName)                textureName, samplerName
			
			#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)         textureName, samplerName
			#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)   textureName, samplerName
			#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)       textureName, samplerName
			#define TEXTURECUBE_ARRAY_SHADOW_ARGS(textureName, samplerName) textureName, samplerName
			
			#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
			#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod)                      textureName.SampleLevel(samplerName, coord2, lod)
			#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                    textureName.SampleBias(samplerName, coord2, bias)
			#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, ddx, ddy)                textureName.SampleGrad(samplerName, coord2, ddx, ddy)
			#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                  textureName.Sample(samplerName, float3(coord2, index))
			#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)         textureName.SampleLevel(samplerName, float3(coord2, index), lod)
			#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)       textureName.SampleBias(samplerName, float3(coord2, index), bias)
			#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy) textureName.SampleGrad(samplerName, float3(coord2, index), dpdx, dpdy)
			#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                             textureName.Sample(samplerName, coord3)
			#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                    textureName.SampleLevel(samplerName, coord3, lod)
			#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                  textureName.SampleBias(samplerName, coord3, bias)
			#ifdef UNITY_NO_CUBEMAP_ARRAY
			#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)           ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY)
			#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)  ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY_LOD)
			#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, bias) ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY_LOD)
			#else
			#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)           textureName.Sample(samplerName, float4(coord3, index))
			#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)  textureName.SampleLevel(samplerName, float4(coord3, index), lod)
			#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)textureName.SampleBias(samplerName, float4(coord3, index), bias)
			#endif
			#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                          textureName.Sample(samplerName, coord3)
			#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                 textureName.SampleLevel(samplerName, coord3, lod)
			
			#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                   textureName.SampleCmpLevelZero(samplerName, (coord3).xy, (coord3).z)
			#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)      textureName.SampleCmpLevelZero(samplerName, float3((coord3).xy, index), (coord3).z)
			#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                 textureName.SampleCmpLevelZero(samplerName, (coord4).xyz, (coord4).w)
			#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)    textureName.SampleCmpLevelZero(samplerName, float4((coord4).xyz, index), (coord4).w)
			
			#define LOAD_TEXTURE2D(textureName, unCoord2)                                   textureName.Load(int3(unCoord2, 0))
			#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)                          textureName.Load(int3(unCoord2, lod))
			#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)                 textureName.Load(unCoord2, sampleIndex)
			#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)                      textureName.Load(int4(unCoord2, index, 0))
			#define LOAD_TEXTURE2D_ARRAY_MSAA(textureName, unCoord2, index, sampleIndex)    textureName.Load(int3(unCoord2, index), sampleIndex)
			#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod)             textureName.Load(int4(unCoord2, index, lod))
			
			#if OPENGL4_1_SM5
			#define PLATFORM_SUPPORT_GATHER
			#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                  textureName.Gather(samplerName, coord2)
			#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)     textureName.Gather(samplerName, float3(coord2, index))
			#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)                textureName.Gather(samplerName, coord3)
			#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)   textureName.Gather(samplerName, float4(coord3, index))
			#else
			#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                  ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURE2D)
			#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)     ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURE2D_ARRAY)
			#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)                ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURECUBE)
			#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)   ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURECUBE_ARRAY)
			#endif
			
			#elif defined(SHADER_API_GLES3)
			
			// GLES 3.1 + AEP shader feature https://docs.unity3d.com/Manual/SL-ShaderCompileTargets.html
			#if (SHADER_TARGET >= 40)
			#define GLES3_1_AEP 1
			#else
			#define GLES3_1_AEP 0
			#endif
			
			// Initialize arbitrary structure with zero values.
			// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
			#define ZERO_INITIALIZE(type, name) name = (type)0;
			#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }
			
			// Texture util abstraction
			
			#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) textureName.CalculateLevelOfDetail(samplerName, coord2)
			
			// Texture abstraction
			
			#define TEXTURE2D(textureName)                  Texture2D textureName
			#define TEXTURE2D_ARRAY(textureName)            Texture2DArray textureName
			#define TEXTURECUBE(textureName)                TextureCube textureName
			#define TEXTURECUBE_ARRAY(textureName)          TextureCubeArray textureName
			#define TEXTURE3D(textureName)                  Texture3D textureName
			
			#define TEXTURE2D_FLOAT(textureName)            Texture2D_float textureName
			#define TEXTURE2D_ARRAY_FLOAT(textureName)      Texture2DArray textureName    // no support to _float on Array, it's being added
			#define TEXTURECUBE_FLOAT(textureName)          TextureCube_float textureName
			#define TEXTURECUBE_ARRAY_FLOAT(textureName)    TextureCubeArray textureName  // no support to _float on Array, it's being added
			#define TEXTURE3D_FLOAT(textureName)            Texture3D_float textureName
			
			#define TEXTURE2D_HALF(textureName)             Texture2D_half textureName
			#define TEXTURE2D_ARRAY_HALF(textureName)       Texture2DArray textureName    // no support to _float on Array, it's being added
			#define TEXTURECUBE_HALF(textureName)           TextureCube_half textureName
			#define TEXTURECUBE_ARRAY_HALF(textureName)     TextureCubeArray textureName  // no support to _float on Array, it's being added
			#define TEXTURE3D_HALF(textureName)             Texture3D_half textureName
			
			#define TEXTURE2D_SHADOW(textureName)           TEXTURE2D(textureName)
			#define TEXTURE2D_ARRAY_SHADOW(textureName)     TEXTURE2D_ARRAY(textureName)
			#define TEXTURECUBE_SHADOW(textureName)         TEXTURECUBE(textureName)
			#define TEXTURECUBE_ARRAY_SHADOW(textureName)   TEXTURECUBE_ARRAY(textureName)
			
			#if GLES3_1_AEP
			#define RW_TEXTURE2D(type, textureName)         RWTexture2D<type> textureName
			#define RW_TEXTURE2D_ARRAY(type, textureName)   RWTexture2DArray<type> textureName
			#define RW_TEXTURE3D(type, textureName)         RWTexture3D<type> textureName
			#else
			#define RW_TEXTURE2D(type, textureName)         ERROR_ON_UNSUPPORTED_FUNCTION(RWTexture2D)
			#define RW_TEXTURE2D_ARRAY(type, textureName)   ERROR_ON_UNSUPPORTED_FUNCTION(RWTexture2DArray)
			#define RW_TEXTURE3D(type, textureName)         ERROR_ON_UNSUPPORTED_FUNCTION(RWTexture3D)
			#endif
			
			#define SAMPLER(samplerName)                    SamplerState samplerName
			#define SAMPLER_CMP(samplerName)                SamplerComparisonState samplerName
			
			#define TEXTURE2D_PARAM(textureName, samplerName)                 TEXTURE2D(textureName), SAMPLER(samplerName)
			#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)           TEXTURE2D_ARRAY(textureName), SAMPLER(samplerName)
			#define TEXTURECUBE_PARAM(textureName, samplerName)               TEXTURECUBE(textureName), SAMPLER(samplerName)
			#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)         TEXTURECUBE_ARRAY(textureName), SAMPLER(samplerName)
			#define TEXTURE3D_PARAM(textureName, samplerName)                 TEXTURE3D(textureName), SAMPLER(samplerName)
			
			#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)          TEXTURE2D(textureName), SAMPLER_CMP(samplerName)
			#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)    TEXTURE2D_ARRAY(textureName), SAMPLER_CMP(samplerName)
			#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)        TEXTURECUBE(textureName), SAMPLER_CMP(samplerName)
			#define TEXTURECUBE_ARRAY_SHADOW_PARAM(textureName, samplerName)  TEXTURECUBE_ARRAY(textureName), SAMPLER_CMP(samplerName)
			
			#define TEXTURE2D_ARGS(textureName, samplerName)                textureName, samplerName
			#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)          textureName, samplerName
			#define TEXTURECUBE_ARGS(textureName, samplerName)              textureName, samplerName
			#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)        textureName, samplerName
			#define TEXTURE3D_ARGS(textureName, samplerName)                textureName, samplerName
			
			#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)         textureName, samplerName
			#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)   textureName, samplerName
			#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)       textureName, samplerName
			#define TEXTURECUBE_ARRAY_SHADOW_ARGS(textureName, samplerName) textureName, samplerName
			
			#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
			#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod)                      textureName.SampleLevel(samplerName, coord2, lod)
			#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                    textureName.SampleBias(samplerName, coord2, bias)
			#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, ddx, ddy)                textureName.SampleGrad(samplerName, coord2, ddx, ddy)
			#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                  textureName.Sample(samplerName, float3(coord2, index))
			#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)         textureName.SampleLevel(samplerName, float3(coord2, index), lod)
			#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)       textureName.SampleBias(samplerName, float3(coord2, index), bias)
			#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy) textureName.SampleGrad(samplerName, float3(coord2, index), dpdx, dpdy)
			#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                             textureName.Sample(samplerName, coord3)
			#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                    textureName.SampleLevel(samplerName, coord3, lod)
			#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                  textureName.SampleBias(samplerName, coord3, bias)
			
			#ifdef UNITY_NO_CUBEMAP_ARRAY
			#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)           ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY)
			#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)  ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY_LOD)
			#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY_BIAS)
			#else
			#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)           textureName.Sample(samplerName, float4(coord3, index))
			#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)  textureName.SampleLevel(samplerName, float4(coord3, index), lod)
			#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)textureName.SampleBias(samplerName, float4(coord3, index), bias)
			#endif
			
			#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                          textureName.Sample(samplerName, coord3)
			#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                 textureName.SampleLevel(samplerName, coord3, lod)
			
			#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                   textureName.SampleCmpLevelZero(samplerName, (coord3).xy, (coord3).z)
			#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)      textureName.SampleCmpLevelZero(samplerName, float3((coord3).xy, index), (coord3).z)
			#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                 textureName.SampleCmpLevelZero(samplerName, (coord4).xyz, (coord4).w)
			#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)    textureName.SampleCmpLevelZero(samplerName, float4((coord4).xyz, index), (coord4).w)
			
			#define LOAD_TEXTURE2D(textureName, unCoord2)                                       textureName.Load(int3(unCoord2, 0))
			#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)                              textureName.Load(int3(unCoord2, lod))
			#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)                     textureName.Load(unCoord2, sampleIndex)
			#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)                          textureName.Load(int4(unCoord2, index, 0))
			#define LOAD_TEXTURE2D_ARRAY_MSAA(textureName, unCoord2, index, sampleIndex)        textureName.Load(int3(unCoord2, index), sampleIndex)
			#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod)                 textureName.Load(int4(unCoord2, index, lod))
			#define LOAD_TEXTURE3D(textureName, unCoord3)                                       textureName.Load(int4(unCoord3, 0))
			#define LOAD_TEXTURE3D_LOD(textureName, unCoord3, lod)                              textureName.Load(int4(unCoord3, lod))
			
			#if GLES3_1_AEP
			#define PLATFORM_SUPPORT_GATHER
			#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                  textureName.Gather(samplerName, coord2)
			#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)     textureName.Gather(samplerName, float3(coord2, index))
			#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)                textureName.Gather(samplerName, coord3)
			#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)   textureName.Gather(samplerName, float4(coord3, index))
			#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)              textureName.GatherRed(samplerName, coord2)
			#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)            textureName.GatherGreen(samplerName, coord2)
			#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)             textureName.GatherBlue(samplerName, coord2)
			#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)            textureName.GatherAlpha(samplerName, coord2)
			#else
			#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                  ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURE2D)
			#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)     ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURE2D_ARRAY)
			#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)                ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURECUBE)
			#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)   ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURECUBE_ARRAY)
			#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)              ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_RED_TEXTURE2D)
			#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)            ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_GREEN_TEXTURE2D)
			#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)             ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_BLUE_TEXTURE2D)
			#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)            ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_ALPHA_TEXTURE2D)
			#endif
			
			#elif defined(SHADER_API_GLES)
			
			#define uint int
			
			#define rcp(x) 1.0 / (x)
			#define ddx_fine ddx
			#define ddy_fine ddy
			#define asfloat
			#define asuint(x) asint(x)
			#define f32tof16
			#define f16tof32
			
			#define ERROR_ON_UNSUPPORTED_FUNCTION(funcName) #error #funcName is not supported on GLES 2.0
			
			// Initialize arbitrary structure with zero values.
			// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
			#define ZERO_INITIALIZE(type, name) name = (type)0;
			#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }
			
			// Texture util abstraction
			
			#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) #error calculate Level of Detail not supported in GLES2
			
			// Texture abstraction
			
			#define TEXTURE2D(textureName)                          sampler2D textureName
			#define TEXTURE2D_ARRAY(textureName)                    samplerCUBE textureName // No support to texture2DArray
			#define TEXTURECUBE(textureName)                        samplerCUBE textureName
			#define TEXTURECUBE_ARRAY(textureName)                  samplerCUBE textureName // No supoport to textureCubeArray and can't emulate with texture2DArray
			#define TEXTURE3D(textureName)                          sampler3D textureName
			
			#define TEXTURE2D_FLOAT(textureName)                    sampler2D_float textureName
			#define TEXTURE2D_ARRAY_FLOAT(textureName)              TEXTURECUBE_FLOAT(textureName) // No support to texture2DArray
			#define TEXTURECUBE_FLOAT(textureName)                  samplerCUBE_float textureName
			#define TEXTURECUBE_ARRAY_FLOAT(textureName)            TEXTURECUBE_FLOAT(textureName) // No support to textureCubeArray
			#define TEXTURE3D_FLOAT(textureName)                    sampler3D_float textureName
			
			#define TEXTURE2D_HALF(textureName)                     sampler2D_half textureName
			#define TEXTURE2D_ARRAY_HALF(textureName)               TEXTURECUBE_HALF(textureName) // No support to texture2DArray
			#define TEXTURECUBE_HALF(textureName)                   samplerCUBE_half textureName
			#define TEXTURECUBE_ARRAY_HALF(textureName)             TEXTURECUBE_HALF(textureName) // No support to textureCubeArray
			#define TEXTURE3D_HALF(textureName)                     sampler3D_half textureName
			
			#define TEXTURE2D_SHADOW(textureName)                   SHADOW2D_TEXTURE_AND_SAMPLER textureName
			#define TEXTURE2D_ARRAY_SHADOW(textureName)             TEXTURECUBE_SHADOW(textureName) // No support to texture array
			#define TEXTURECUBE_SHADOW(textureName)                 SHADOWCUBE_TEXTURE_AND_SAMPLER textureName
			#define TEXTURECUBE_ARRAY_SHADOW(textureName)           TEXTURECUBE_SHADOW(textureName) // No support to texture array
			
			#define RW_TEXTURE2D(type, textureNam)                  ERROR_ON_UNSUPPORTED_FUNCTION(RWTexture2D)
			#define RW_TEXTURE2D_ARRAY(type, textureName)           ERROR_ON_UNSUPPORTED_FUNCTION(RWTexture2DArray)
			#define RW_TEXTURE3D(type, textureNam)                  ERROR_ON_UNSUPPORTED_FUNCTION(RWTexture3D)
			
			#define SAMPLER(samplerName)
			#define SAMPLER_CMP(samplerName)
			
			#define TEXTURE2D_PARAM(textureName, samplerName)                sampler2D textureName
			#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)          samplerCUBE textureName
			#define TEXTURECUBE_PARAM(textureName, samplerName)              samplerCUBE textureName
			#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)        samplerCUBE textureName
			#define TEXTURE3D_PARAM(textureName, samplerName)                sampler3D textureName
			#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)         SHADOW2D_TEXTURE_AND_SAMPLER textureName
			#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)   SHADOWCUBE_TEXTURE_AND_SAMPLER textureName
			#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)       SHADOWCUBE_TEXTURE_AND_SAMPLER textureName
			
			#define TEXTURE2D_ARGS(textureName, samplerName)               textureName
			#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)         textureName
			#define TEXTURECUBE_ARGS(textureName, samplerName)             textureName
			#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)       textureName
			#define TEXTURE3D_ARGS(textureName, samplerName)               textureName
			#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)        textureName
			#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)  textureName
			#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)      textureName
			
			#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2) tex2D(textureName, coord2)
			
			#if (SHADER_TARGET >= 30)
			#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod) tex2Dlod(textureName, float4(coord2, 0, lod))
			#else
			// No lod support. Very poor approximation with bias.
			#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod) SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, lod)
			#endif
			
			#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                       tex2Dbias(textureName, float4(coord2, 0, bias))
			#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, ddx, ddy)                   SAMPLE_TEXTURE2D(textureName, samplerName, coord2)
			#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                     ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURE2D_ARRAY)
			#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)            ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURE2D_ARRAY_LOD)
			#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)          ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURE2D_ARRAY_BIAS)
			#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy)    ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURE2D_ARRAY_GRAD)
			#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                                texCUBE(textureName, coord3)
			// No lod support. Very poor approximation with bias.
			#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                       SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, lod)
			#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                     texCUBEbias(textureName, float4(coord3, bias))
			#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)                   ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY)
			#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)          ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY_LOD)
			#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)        ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY_BIAS)
			#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                                  tex3D(textureName, coord3)
			#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                         ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURE3D_LOD)
			
			#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                           SHADOW2D_SAMPLE(textureName, samplerName, coord3)
			#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)              ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURE2D_ARRAY_SHADOW)
			#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                         SHADOWCUBE_SAMPLE(textureName, samplerName, coord4)
			#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)            ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY_SHADOW)
			
			// Not supported. Can't define as error because shader library is calling these functions.
			#define LOAD_TEXTURE2D(textureName, unCoord2)                                               half4(0, 0, 0, 0)
			#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)                                      half4(0, 0, 0, 0)
			#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)                             half4(0, 0, 0, 0)
			#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)                                  half4(0, 0, 0, 0)
			#define LOAD_TEXTURE2D_ARRAY_MSAA(textureName, unCoord2, index, sampleIndex)                half4(0, 0, 0, 0)
			#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod)                         half4(0, 0, 0, 0)
			#define LOAD_TEXTURE3D(textureName, unCoord3)                                               ERROR_ON_UNSUPPORTED_FUNCTION(LOAD_TEXTURE3D)
			#define LOAD_TEXTURE3D_LOD(textureName, unCoord3, lod)                                      ERROR_ON_UNSUPPORTED_FUNCTION(LOAD_TEXTURE3D_LOD)
			
			// Gather not supported. Fallback to regular texture sampling.
			#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                  ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURE2D)
			#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)     ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURE2D_ARRAY)
			#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)                ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURECUBE)
			#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)   ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURECUBE_ARRAY)
			#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)              ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_RED_TEXTURE2D)
			#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)            ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_GREEN_TEXTURE2D)
			#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)             ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_BLUE_TEXTURE2D)
			#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)            ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_ALPHA_TEXTURE2D)
			
			#else
			#error unsupported shader api
			#endif
			
			// default flow control attributes
			#ifndef UNITY_BRANCH
			#   define UNITY_BRANCH
			#endif
			#ifndef UNITY_FLATTEN
			#   define UNITY_FLATTEN
			#endif
			#ifndef UNITY_UNROLL
			#   define UNITY_UNROLL
			#endif
			#ifndef UNITY_UNROLLX
			#   define UNITY_UNROLLX(_x)
			#endif
			#ifndef UNITY_LOOP
			#   define UNITY_LOOP
			#endif
			
			struct VertexData
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 color : COLOR;
				float2 uv0 : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float2 uv2 : TEXCOORD2;
				float2 uv3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct FragmentData
			{
				#if defined(UNITY_PASS_SHADOWCASTER)
				V2F_SHADOW_CASTER;
				float2 uv0 : TEXCOORD1;
				float2 uv1 : TEXCOORD2;
				float2 uv2 : TEXCOORD3;
				float2 uv3 : TEXCOORD4;
				float3 worldPos : TEXCOORD5;
				float3 worldNormal : TEXCOORD6;
				float4 worldTangent : TEXCOORD7;
				#else
				float4 pos : SV_POSITION;
				float3 normal : NORMAL;
				float2 uv0 : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float2 uv2 : TEXCOORD2;
				float2 uv3 : TEXCOORD3;
				float3 worldPos : TEXCOORD4;
				float3 worldNormal : TEXCOORD5;
				float4 worldTangent : TEXCOORD6;
				float4 lightmapUv : TEXCOORD7;
				float4 vertexColor : TEXCOORD8;
				
				#if !defined(UNITY_PASS_META)
				UNITY_LIGHTING_COORDS(9, 10)
				UNITY_FOG_COORDS(11)
				#endif
				#endif
				
				#if defined(EDITOR_VISUALIZATION)
				float2 vizUV : TEXCOORD9;
				float4 lightCoord : TEXCOORD10;
				#endif
				
				#if defined(NEED_SCREEN_POS)
				float4 screenPos: SCREENPOS;
				#endif
				
				#if defined(EXTRA_V2F_0)
				#if defined(UNITY_PASS_SHADOWCASTER)
				float4 extraV2F0 : TEXCOORD8;
				#else
				#if !defined(UNITY_PASS_META)
				float4 extraV2F0 : TEXCOORD12;
				#else
				#if defined(EDITOR_VISUALIZATION)
				float4 extraV2F0 : TEXCOORD11;
				#else
				float4 extraV2F0 : TEXCOORD9;
				#endif
				#endif
				#endif
				#endif
				#if defined(EXTRA_V2F_1)
				#if defined(UNITY_PASS_SHADOWCASTER)
				float4 extraV2F1 : TEXCOORD9;
				#else
				#if !defined(UNITY_PASS_META)
				float4 extraV2F1 : TEXCOORD13;
				#else
				#if defined(EDITOR_VISUALIZATION)
				float4 extraV2F1 : TEXCOORD14;
				#else
				float4 extraV2F1 : TEXCOORD15;
				#endif
				#endif
				#endif
				#endif
				#if defined(EXTRA_V2F_2)
				#if defined(UNITY_PASS_SHADOWCASTER)
				float4 extraV2F2 : TEXCOORD10;
				#else
				#if !defined(UNITY_PASS_META)
				float4 extraV2F2 : TEXCOORD14;
				#else
				#if defined(EDITOR_VISUALIZATION)
				float4 extraV2F2 : TEXCOORD15
				#else
				float4 extraV2F2 : TEXCOORD16;
				#endif
				#endif
				#endif
				#endif
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			
			struct MeshData
			{
				half2 uv0;
				half2 uv1;
				half2 uv2;
				half2 uv3;
				half3 vertexColor;
				half3 normal;
				half3 worldNormal;
				half3 localSpacePosition;
				half3 worldSpacePosition;
				half3 worldSpaceViewDir;
				half3 tangentSpaceViewDir;
				half3 worldSpaceTangent;
				float3 bitangent;
				float3x3 TBNMatrix;
				half3 svdn;
				float4 extraV2F0;
				float4 extraV2F1;
				float4 extraV2F2;
				float4 screenPos;
			};
			
			MeshData CreateMeshData(FragmentData i)
			{
				MeshData m = (MeshData) 0;
				m.uv0 = i.uv0;
				m.uv1 = i.uv1;
				m.uv2 = i.uv2;
				m.uv3 = i.uv3;
				m.worldNormal = normalize(i.worldNormal);
				m.localSpacePosition = mul(unity_WorldToObject, float4(i.worldPos, 1)).xyz;
				m.worldSpacePosition = i.worldPos;
				m.worldSpaceViewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
				
				#if !defined(UNITY_PASS_SHADOWCASTER)
				m.vertexColor = i.vertexColor;
				m.normal = i.normal;
				m.bitangent = cross(i.worldTangent.xyz, i.worldNormal) * i.worldTangent.w * - 1;
				m.worldSpaceTangent = i.worldTangent.xyz;
				m.TBNMatrix = float3x3(normalize(i.worldTangent.xyz), m.bitangent, m.worldNormal);
				m.tangentSpaceViewDir = mul(m.TBNMatrix, m.worldSpaceViewDir);
				#endif
				
				#if UNITY_SINGLE_PASS_STEREO
				half3 stereoCameraPos = half3((unity_StereoWorldSpaceCameraPos[0]+ unity_StereoWorldSpaceCameraPos[1])*.5);
				m.svdn = normalize(stereoCameraPos - m.worldSpacePosition);
				#else
				m.svdn = m.worldSpaceViewDir;
				#endif
				
				#if defined(EXTRA_V2F_0)
				m.extraV2F0 = i.extraV2F0;
				#endif
				#if defined(EXTRA_V2F_1)
				m.extraV2F1 = i.extraV2F1;
				#endif
				#if defined(EXTRA_V2F_2)
				m.extraV2F2 = i.extraV2F2;
				#endif
				#if defined(NEED_SCREEN_POS)
				m.screenPos = i.screenPos;
				#endif
				
				return m;
			}
			
			struct SurfaceData
			{
				half3 Albedo;
				half3 Emission;
				int EmissionScaleWithLight;
				half EmissionLightThreshold;
				half Metallic;
				half Smoothness;
				half Occlusion;
				int OcclusionMode;
				half3 Normal;
				half Alpha;
				half Anisotropy;
				half ShadowSharpness;
				half4 RimLight;
				half RimAttenuation;
				half4 RimShadow;
				half SpecularIntensity;
				half SpecularArea;
				half SpecularAlbedoTint;
				half SpecularAnisotropy;
				half SpecularSharpness;
				half Reflectivity;
				half3 BakedReflection;
				int ReflectionBlendMode;
				int EnableReflections;
				half3 OutlineColor;
				int OutlineLightingMode;
			};
			
			FragmentData FragData;
			SurfaceData o;
			MeshData d;
			VertexData vD;
			float4 FinalColor;
			
			half invLerp(half a, half b, half v)
			{
				return (v - a) / (b - a);
			}
			
			half getBakedNoise(Texture2D noiseTex, SamplerState noiseTexSampler, half3 p)
			{
				half3 i = floor(p); p -= i; p *= p * (3. - 2. * p);
				half2 uv = (p.xy + i.xy + half2(37, 17) * i.z + .5) / 256.;
				uv.y *= -1;
				p.xy = noiseTex.SampleLevel(noiseTexSampler, uv, 0).yx;
				return lerp(p.x, p.y, p.z);
			}
			
			half3 TransformObjectToWorld(half3 pos)
			{
				return mul(unity_ObjectToWorld, half4(pos, 1)).xyz;
			};
			
			// mostly taken from the Amplify shader reference
			half2 POM(Texture2D heightMap, SamplerState heightSampler, half2 uvs, half2 dx, half2 dy, half3 normalWorld, half3 viewWorld, half3 viewDirTan, int minSamples, int maxSamples, half parallax, half refPlane, half2 tilling, half2 curv, int index, inout half finalHeight)
			{
				half3 result = 0;
				int stepIndex = 0;
				int numSteps = (int)lerp((half)maxSamples, (half)minSamples, saturate(dot(normalWorld, viewWorld)));
				half layerHeight = 1.0 / numSteps;
				half2 plane = parallax * (viewDirTan.xy / viewDirTan.z);
				uvs.xy += refPlane * plane;
				half2 deltaTex = -plane * layerHeight;
				half2 prevTexOffset = 0;
				half prevRayZ = 1.0f;
				half prevHeight = 0.0f;
				half2 currTexOffset = deltaTex;
				half currRayZ = 1.0f - layerHeight;
				half currHeight = 0.0f;
				half intersection = 0;
				half2 finalTexOffset = 0;
				while (stepIndex < numSteps + 1)
				{
					currHeight = SAMPLE_TEXTURE2D_GRAD(heightMap, heightSampler, uvs + currTexOffset, dx, dy).r;
					if (currHeight > currRayZ)
					{
						stepIndex = numSteps + 1;
					}
					else
					{
						stepIndex++;
						prevTexOffset = currTexOffset;
						prevRayZ = currRayZ;
						prevHeight = currHeight;
						currTexOffset += deltaTex;
						currRayZ -= layerHeight;
					}
				}
				int sectionSteps = 2;
				int sectionIndex = 0;
				half newZ = 0;
				half newHeight = 0;
				while (sectionIndex < sectionSteps)
				{
					intersection = (prevHeight - prevRayZ) / (prevHeight - currHeight + currRayZ - prevRayZ);
					finalTexOffset = prevTexOffset +intersection * deltaTex;
					newZ = prevRayZ - intersection * layerHeight;
					newHeight = SAMPLE_TEXTURE2D_GRAD(heightMap, heightSampler, uvs + finalTexOffset, dx, dy).r;
					if (newHeight > newZ)
					{
						currTexOffset = finalTexOffset;
						currHeight = newHeight;
						currRayZ = newZ;
						deltaTex = intersection * deltaTex;
						layerHeight = intersection * layerHeight;
					}
					else
					{
						prevTexOffset = finalTexOffset;
						prevHeight = newHeight;
						prevRayZ = newZ;
						deltaTex = (1 - intersection) * deltaTex;
						layerHeight = (1 - intersection) * layerHeight;
					}
					sectionIndex++;
				}
				finalHeight = newHeight;
				return uvs.xy + finalTexOffset;
			}
			
			half remap(half s, half a1, half a2, half b1, half b2)
			{
				return b1 + (s - a1) * (b2 - b1) / (a2 - a1);
			}
			
			half3 ApplyLut2D(Texture2D LUT2D, SamplerState lutSampler, half3 uvw)
			{
				half3 scaleOffset = half3(1.0 / 1024.0, 1.0 / 32.0, 31.0);
				// Strip format where `height = sqrt(width)`
				uvw.z *= scaleOffset.z;
				half shift = floor(uvw.z);
				uvw.xy = uvw.xy * scaleOffset.z * scaleOffset.xy + scaleOffset.xy * 0.5;
				uvw.x += shift * scaleOffset.y;
				uvw.xyz = lerp(
				SAMPLE_TEXTURE2D(LUT2D, lutSampler, uvw.xy).rgb,
				SAMPLE_TEXTURE2D(LUT2D, lutSampler, uvw.xy + half2(scaleOffset.y, 0.0)).rgb,
				uvw.z - shift
				);
				return uvw;
			}
			
			half3 AdjustContrast(half3 color, half contrast)
			{
				color = saturate(lerp(half3(0.5, 0.5, 0.5), color, contrast));
				return color;
			}
			
			half3 AdjustSaturation(half3 color, half saturation)
			{
				half3 intensity = dot(color.rgb, half3(0.299, 0.587, 0.114));
				color = lerp(intensity, color.rgb, saturation);
				return color;
			}
			
			half3 AdjustBrightness(half3 color, half brightness)
			{
				color += brightness;
				return color;
			}
			
			struct ParamsLogC
			{
				half cut;
				half a, b, c, d, e, f;
			};
			
			static const ParamsLogC LogC = {
				0.011361, // cut
				5.555556, // a
				0.047996, // b
				0.244161, // c
				0.386036, // d
				5.301883, // e
				0.092819  // f
				
			};
			
			half LinearToLogC_Precise(half x)
			{
				half o;
				if (x > LogC.cut)
				o = LogC.c * log10(LogC.a * x + LogC.b) + LogC.d;
				else
				o = LogC.e * x + LogC.f;
				return o;
			}
			
			half PositivePow(half base, half power)
			{
				return pow(max(abs(base), half(FLT_EPSILON)), power);
			}
			
			half3 LinearToLogC(half3 x)
			{
				return LogC.c * log10(LogC.a * x + LogC.b) + LogC.d;
			}
			
			half3 LinerToSRGB(half3 c)
			{
				return c * (c * (c * 0.305306011 + 0.682171111) + 0.012522878);
			}
			
			half3 SRGBToLiner(half3 c)
			{
				return max(1.055 * PositivePow(c, 0.416666667) - 0.055, 0.0);
			}
			
			half3 LogCToLinear(half3 c)
			{
				return (pow(10.0, (c - LogC.d) / LogC.c) - LogC.b) / LogC.a;
			}
			
			// Specular stuff taken from https://github.com/z3y/shaders/
			float pow5(float x)
			{
				float x2 = x * x;
				return x2 * x2 * x;
			}
			
			float sq(float x)
			{
				return x * x;
			}
			
			struct Gradient
			{
				int type;
				int colorsLength;
				int alphasLength;
				half4 colors[8];
				half2 alphas[8];
			};
			
			Gradient NewGradient(int type, int colorsLength, int alphasLength,
			half4 colors0, half4 colors1, half4 colors2, half4 colors3, half4 colors4, half4 colors5, half4 colors6, half4 colors7,
			half2 alphas0, half2 alphas1, half2 alphas2, half2 alphas3, half2 alphas4, half2 alphas5, half2 alphas6, half2 alphas7)
			{
				Gradient g;
				g.type = type;
				g.colorsLength = colorsLength;
				g.alphasLength = alphasLength;
				g.colors[ 0 ] = colors0;
				g.colors[ 1 ] = colors1;
				g.colors[ 2 ] = colors2;
				g.colors[ 3 ] = colors3;
				g.colors[ 4 ] = colors4;
				g.colors[ 5 ] = colors5;
				g.colors[ 6 ] = colors6;
				g.colors[ 7 ] = colors7;
				g.alphas[ 0 ] = alphas0;
				g.alphas[ 1 ] = alphas1;
				g.alphas[ 2 ] = alphas2;
				g.alphas[ 3 ] = alphas3;
				g.alphas[ 4 ] = alphas4;
				g.alphas[ 5 ] = alphas5;
				g.alphas[ 6 ] = alphas6;
				g.alphas[ 7 ] = alphas7;
				return g;
			}
			
			half4 SampleGradient(Gradient gradient, half time)
			{
				half3 color = gradient.colors[0].rgb;
				UNITY_UNROLL
				for (int c = 1; c < 8; c++)
				{
					half colorPos = saturate((time - gradient.colors[c - 1].w) / (0.00001 + (gradient.colors[c].w - gradient.colors[c - 1].w)) * step(c, (half)gradient.colorsLength - 1));
					color = lerp(color, gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), gradient.type));
				}
				#ifndef UNITY_COLORSPACE_GAMMA
				color = half3(GammaToLinearSpaceExact(color.r), GammaToLinearSpaceExact(color.g), GammaToLinearSpaceExact(color.b));
				#endif
				half alpha = gradient.alphas[0].x;
				UNITY_UNROLL
				for (int a = 1; a < 8; a++)
				{
					half alphaPos = saturate((time - gradient.alphas[a - 1].y) / (0.00001 + (gradient.alphas[a].y - gradient.alphas[a - 1].y)) * step(a, (half)gradient.alphasLength - 1));
					alpha = lerp(alpha, gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), gradient.type));
				}
				return half4(color, alpha);
			}
			
			float3 RotateAroundAxis(float3 center, float3 original, float3 u, float angle)
			{
				original -= center;
				float C = cos(angle);
				float S = sin(angle);
				float t = 1 - C;
				float m00 = t * u.x * u.x + C;
				float m01 = t * u.x * u.y - S * u.z;
				float m02 = t * u.x * u.z + S * u.y;
				float m10 = t * u.x * u.y + S * u.z;
				float m11 = t * u.y * u.y + C;
				float m12 = t * u.y * u.z - S * u.x;
				float m20 = t * u.x * u.z - S * u.y;
				float m21 = t * u.y * u.z + S * u.x;
				float m22 = t * u.z * u.z + C;
				float3x3 finalMatrix = float3x3(m00, m01, m02, m10, m11, m12, m20, m21, m22);
				return mul(finalMatrix, original) + center;
			}
			
			// Map of where features in AudioLink are.
			#define ALPASS_DFT                      uint2(0, 4)  //Size: 128, 2
			#define ALPASS_WAVEFORM                 uint2(0, 6)  //Size: 128, 16
			#define ALPASS_AUDIOLINK                uint2(0, 0)  //Size: 128, 4
			#define ALPASS_AUDIOBASS                uint2(0, 0)  //Size: 128, 1
			#define ALPASS_AUDIOLOWMIDS             uint2(0, 1)  //Size: 128, 1
			#define ALPASS_AUDIOHIGHMIDS            uint2(0, 2)  //Size: 128, 1
			#define ALPASS_AUDIOTREBLE              uint2(0, 3)  //Size: 128, 1
			#define ALPASS_AUDIOLINKHISTORY         uint2(1, 0)  //Size: 127, 4
			#define ALPASS_GENERALVU                uint2(0, 22) //Size: 12, 1
			#define ALPASS_GENERALVU_INSTANCE_TIME  uint2(2, 22)
			#define ALPASS_GENERALVU_LOCAL_TIME     uint2(3, 22)
			#define ALPASS_GENERALVU_NETWORK_TIME   uint2(4, 22)
			#define ALPASS_GENERALVU_PLAYERINFO     uint2(6, 22)
			#define ALPASS_THEME_COLOR0             uint2(0, 23)
			#define ALPASS_THEME_COLOR1             uint2(1, 23)
			#define ALPASS_THEME_COLOR2             uint2(2, 23)
			#define ALPASS_THEME_COLOR3             uint2(3, 23)
			#define ALPASS_CCINTERNAL               uint2(12, 22) //Size: 12, 2
			#define ALPASS_CCCOLORS                 uint2(25, 22) //Size: 12, 1 (Note Color #0 is always black, Colors start at 1)
			#define ALPASS_CCSTRIP                  uint2(0, 24)  //Size: 128, 1
			#define ALPASS_CCLIGHTS                 uint2(0, 25)  //Size: 128, 2
			#define ALPASS_AUTOCORRELATOR           uint2(0, 27)  //Size: 128, 1
			#define ALPASS_FILTEREDAUDIOLINK        uint2(0, 28)  //Size: 16, 4
			#define ALPASS_CHRONOTENSITY            uint2(16, 28) //Size: 8, 4
			#define ALPASS_FILTEREDVU               uint2(24, 28) //Size: 4, 4
			#define ALPASS_FILTEREDVU_INTENSITY     uint2(24, 28) //Size: 4, 1
			#define ALPASS_FILTEREDVU_MARKER        uint2(24, 29) //Size: 4, 1
			
			// Some basic constants to use (Note, these should be compatible with
			// future version of AudioLink, but may change.
			#define AUDIOLINK_SAMPHIST              3069        // Internal use for algos, do not change.
			#define AUDIOLINK_SAMPLEDATA24          2046
			#define AUDIOLINK_EXPBINS               24
			#define AUDIOLINK_EXPOCT                10
			#define AUDIOLINK_ETOTALBINS (AUDIOLINK_EXPBINS * AUDIOLINK_EXPOCT)
			#define AUDIOLINK_WIDTH                 128
			#define AUDIOLINK_SPS                   48000       // Samples per second
			#define AUDIOLINK_ROOTNOTE              0
			#define AUDIOLINK_4BAND_FREQFLOOR       0.123
			#define AUDIOLINK_4BAND_FREQCEILING     1
			#define AUDIOLINK_BOTTOM_FREQUENCY      13.75
			#define AUDIOLINK_BASE_AMPLITUDE        2.5
			#define AUDIOLINK_DELAY_COEFFICIENT_MIN 0.3
			#define AUDIOLINK_DELAY_COEFFICIENT_MAX 0.9
			#define AUDIOLINK_DFT_Q                 4.0
			#define AUDIOLINK_TREBLE_CORRECTION     5.0
			#define AUDIOLINK_4BAND_TARGET_RATE     90.0
			
			// ColorChord constants
			#define COLORCHORD_EMAXBIN              192
			#define COLORCHORD_NOTE_CLOSEST         3.0
			#define COLORCHORD_NEW_NOTE_GAIN        8.0
			#define COLORCHORD_MAX_NOTES            10
			
			// We use glsl_mod for most calculations because it behaves better
			// on negative numbers, and in some situations actually outperforms
			// HLSL's modf().
			#ifndef glsl_mod
			#define glsl_mod(x, y) (((x) - (y) * floor((x) / (y))))
			#endif
			
			uniform float4               _AudioTexture_TexelSize;
			
			#ifdef SHADER_TARGET_SURFACE_ANALYSIS
			#define AUDIOLINK_STANDARD_INDEXING
			#endif
			
			// Mechanism to index into texture.
			#ifdef AUDIOLINK_STANDARD_INDEXING
			sampler2D _AudioTexture;
			#define AudioLinkData(xycoord) tex2Dlod(_AudioTexture, float4(uint2(xycoord) * _AudioTexture_TexelSize.xy, 0, 0))
			#else
			uniform Texture2D<float4> _AudioTexture;
			#define AudioLinkData(xycoord) _AudioTexture[uint2(xycoord)]
			#endif
			
			// Convenient mechanism to read from the AudioLink texture that handles reading off the end of one line and onto the next above it.
			float4 AudioLinkDataMultiline(uint2 xycoord)
			{
				return AudioLinkData(uint2(xycoord.x % AUDIOLINK_WIDTH, xycoord.y + xycoord.x / AUDIOLINK_WIDTH));
			}
			
			// Mechanism to sample between two adjacent pixels and lerp between them, like "linear" supesampling
			float4 AudioLinkLerp(float2 xy)
			{
				return lerp(AudioLinkData(xy), AudioLinkData(xy + int2(1, 0)), frac(xy.x));
			}
			
			// Same as AudioLinkLerp but properly handles multiline reading.
			float4 AudioLinkLerpMultiline(float2 xy)
			{
				return lerp(AudioLinkDataMultiline(xy), AudioLinkDataMultiline(xy + float2(1, 0)), frac(xy.x));
			}
			
			//Tests to see if Audio Link texture is available
			bool AudioLinkIsAvailable()
			{
				#if !defined(AUDIOLINK_STANDARD_INDEXING)
				int width, height;
				_AudioTexture.GetDimensions(width, height);
				return width > 16;
				#else
				return _AudioTexture_TexelSize.z > 16;
				#endif
			}
			
			//Get version of audiolink present in the world, 0 if no audiolink is present
			float AudioLinkGetVersion()
			{
				int2 dims;
				#if !defined(AUDIOLINK_STANDARD_INDEXING)
				_AudioTexture.GetDimensions(dims.x, dims.y);
				#else
				dims = _AudioTexture_TexelSize.zw;
				#endif
				
				if (dims.x >= 128)
				return AudioLinkData(ALPASS_GENERALVU).x;
				else if (dims.x > 16)
				return 1;
				else
				return 0;
			}
			
			// This pulls data from this texture.
			#define AudioLinkGetSelfPixelData(xy) _SelfTexture2D[xy]
			
			// Extra utility functions for time.
			uint AudioLinkDecodeDataAsUInt(uint2 indexloc)
			{
				uint4 rpx = AudioLinkData(indexloc);
				return rpx.r + rpx.g * 1024 + rpx.b * 1048576 + rpx.a * 1073741824;
			}
			
			//Note: This will truncate time to every 134,217.728 seconds (~1.5 days of an instance being up) to prevent floating point aliasing.
			// if your code will alias sooner, you will need to use a different function.  It should be safe to use this on all times.
			float AudioLinkDecodeDataAsSeconds(uint2 indexloc)
			{
				uint time = AudioLinkDecodeDataAsUInt(indexloc) & 0x7ffffff;
				//Can't just divide by float.  Bug in Unity's HLSL compiler.
				return float(time / 1000) + float(time % 1000) / 1000.;
			}
			
			#define ALDecodeDataAsSeconds(x) AudioLinkDecodeDataAsSeconds(x)
			#define ALDecodeDataAsUInt(x) AudioLinkDecodeDataAsUInt(x)
			
			float AudioLinkRemap(float t, float a, float b, float u, float v)
			{
				return ((t - a) / (b - a)) * (v - u) + u;
			}
			
			float3 AudioLinkHSVtoRGB(float3 HSV)
			{
				float3 RGB = 0;
				float C = HSV.z * HSV.y;
				float H = HSV.x * 6;
				float X = C * (1 - abs(fmod(H, 2) - 1));
				if (HSV.y != 0)
				{
					float I = floor(H);
					if (I == 0)
					{
						RGB = float3(C, X, 0);
					}
					else if (I == 1)
					{
						RGB = float3(X, C, 0);
					}
					else if (I == 2)
					{
						RGB = float3(0, C, X);
					}
					else if (I == 3)
					{
						RGB = float3(0, X, C);
					}
					else if (I == 4)
					{
						RGB = float3(X, 0, C);
					}
					else
					{
						RGB = float3(C, 0, X);
					}
				}
				float M = HSV.z - C;
				return RGB + M;
			}
			
			float3 AudioLinkCCtoRGB(float bin, float intensity, int rootNote)
			{
				float note = bin / AUDIOLINK_EXPBINS;
				
				float hue = 0.0;
				note *= 12.0;
				note = glsl_mod(4. - note + rootNote, 12.0);
				{
					if (note < 4.0)
					{
						//Needs to be YELLOW->RED
						hue = (note) / 24.0;
					}
					else if (note < 8.0)
					{
						//            [4]  [8]
						//Needs to be RED->BLUE
						hue = (note - 2.0) / 12.0;
					}
					else
					{
						//             [8] [12]
						//Needs to be BLUE->YELLOW
						hue = (note - 4.0) / 8.0;
					}
				}
				float val = intensity - 0.1;
				return AudioLinkHSVtoRGB(float3(fmod(hue, 1.0), 1.0, clamp(val, 0.0, 1.0)));
			}
			
			// Sample the amplitude of a given frequency in the DFT, supports frequencies in [13.75; 14080].
			float4 AudioLinkGetAmplitudeAtFrequency(float hertz)
			{
				float note = AUDIOLINK_EXPBINS * log2(hertz / AUDIOLINK_BOTTOM_FREQUENCY);
				return AudioLinkLerpMultiline(ALPASS_DFT + float2(note, 0));
			}
			
			// Sample the amplitude of a given semitone in an octave. Octave is in [0; 9] while note is [0; 11].
			float AudioLinkGetAmplitudeAtNote(float octave, float note)
			{
				float quarter = note * 2.0;
				return AudioLinkLerpMultiline(ALPASS_DFT + float2(octave * AUDIOLINK_EXPBINS + quarter, 0));
			}
			
			// Get a reasonable drop-in replacement time value for _Time.y with the
			// given chronotensity index [0; 7] and AudioLink band [0; 3].
			float AudioLinkGetChronoTime(uint index, uint band)
			{
				return (AudioLinkDecodeDataAsUInt(ALPASS_CHRONOTENSITY + uint2(index, band))) / 100000.0;
			}
			
			// Get a chronotensity value in the interval [0; 1], modulated by the speed input,
			// with the given chronotensity index [0; 7] and AudioLink band [0; 3].
			float AudioLinkGetChronoTimeNormalized(uint index, uint band, float speed)
			{
				return frac(AudioLinkGetChronoTime(index, band) * speed);
			}
			
			// Get a chronotensity value in the interval [0; interval], modulated by the speed input,
			// with the given chronotensity index [0; 7] and AudioLink band [0; 3].
			float AudioLinkGetChronoTimeInterval(uint index, uint band, float speed, float interval)
			{
				return AudioLinkGetChronoTimeNormalized(index, band, speed) * interval;
			}
			half D_GGX(half NoH, half roughness)
			{
				half a = NoH * roughness;
				half k = roughness / (1.0 - NoH * NoH + a * a);
				return k * k * (1.0 / UNITY_PI);
			}
			
			half D_GGX_Anisotropic(half NoH, const half3 h, const half3 t, const half3 b, half at, half ab)
			{
				half ToH = dot(t, h);
				half BoH = dot(b, h);
				half a2 = at * ab;
				half3 v = half3(ab * ToH, at * BoH, a2 * NoH);
				half v2 = dot(v, v);
				half w2 = a2 / v2;
				return a2 * w2 * w2 * (1.0 / UNITY_PI);
			}
			
			half V_SmithGGXCorrelated(half NoV, half NoL, half roughness)
			{
				half a2 = roughness * roughness;
				half GGXV = NoL * sqrt(NoV * NoV * (1.0 - a2) + a2);
				half GGXL = NoV * sqrt(NoL * NoL * (1.0 - a2) + a2);
				return 0.5 / (GGXV + GGXL);
			}
			
			half3 F_Schlick(half u, half3 f0)
			{
				return f0 + (1.0 - f0) * pow(1.0 - u, 5.0);
			}
			
			half3 F_Schlick(half3 f0, half f90, half VoH)
			{
				// Schlick 1994, "An Inexpensive BRDF Model for Physically-Based Rendering"
				return f0 + (f90 - f0) * pow(1.0 - VoH, 5);
			}
			
			half3 fresnel(half3 f0, half LoH)
			{
				half f90 = saturate(dot(f0, half(50.0 / 3).xxx));
				return F_Schlick(f0, f90, LoH);
			}
			
			half Fd_Burley(half perceptualRoughness, half NoV, half NoL, half LoH)
			{
				// Burley 2012, "Physically-Based Shading at Disney"
				half f90 = 0.5 + 2.0 * perceptualRoughness * LoH * LoH;
				half lightScatter = F_Schlick(1.0, f90, NoL);
				half viewScatter = F_Schlick(1.0, f90, NoV);
				return lightScatter * viewScatter;
			}
			
			half3 getBoxProjection(half3 direction, half3 position, half4 cubemapPosition, half3 boxMin, half3 boxMax)
			{
				#if defined(UNITY_SPECCUBE_BOX_PROJECTION) && !defined(UNITY_PBS_USE_BRDF2) || defined(FORCE_BOX_PROJECTION)
				if (cubemapPosition.w > 0)
				{
					half3 factors = ((direction > 0 ? boxMax : boxMin) - position) / direction;
					half scalar = min(min(factors.x, factors.y), factors.z);
					direction = direction * scalar + (position - cubemapPosition.xyz);
				}
				#endif
				
				return direction;
			}
			
			half3 getEnvReflection(half3 worldSpaceViewDir, half3 worldSpacePosition, half3 normal, half smoothness, int mip)
			{
				half3 env = 0;
				half3 reflDir = reflect(worldSpaceViewDir, normal);
				half perceptualRoughness = 1 - smoothness;
				half rough = perceptualRoughness * perceptualRoughness;
				reflDir = lerp(reflDir, normal, rough * rough);
				
				half3 reflectionUV1 = getBoxProjection(reflDir, worldSpacePosition, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin.xyz, unity_SpecCube0_BoxMax.xyz);
				half4 probe0 = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectionUV1, mip);
				half3 probe0sample = DecodeHDR(probe0, unity_SpecCube0_HDR);
				
				half3 indirectSpecular;
				half interpolator = unity_SpecCube0_BoxMin.w;
				
				UNITY_BRANCH
				if (interpolator < 0.99999)
				{
					half3 reflectionUV2 = getBoxProjection(reflDir, worldSpacePosition, unity_SpecCube1_ProbePosition, unity_SpecCube1_BoxMin.xyz, unity_SpecCube1_BoxMax.xyz);
					half4 probe1 = UNITY_SAMPLE_TEXCUBE_SAMPLER_LOD(unity_SpecCube1, unity_SpecCube0, reflectionUV2, mip);
					half3 probe1sample = DecodeHDR(probe1, unity_SpecCube1_HDR);
					indirectSpecular = lerp(probe1sample, probe0sample, interpolator);
				}
				else
				{
					indirectSpecular = probe0sample;
				}
				
				env = indirectSpecular;
				return env;
			}
			
			half3 EnvBRDFMultiscatter(half2 dfg, half3 f0)
			{
				return lerp(dfg.xxx, dfg.yyy, f0);
			}
			
			half3 EnvBRDFApprox(half perceptualRoughness, half NoV, half3 f0)
			{
				half g = 1 - perceptualRoughness;
				//https://blog.selfshadow.com/publications/s2013-shading-course/lazarov/s2013_pbs_black_ops_2_notes.pdf
				half4 t = half4(1 / 0.96, 0.475, (0.0275 - 0.25 * 0.04) / 0.96, 0.25);
				t *= half4(g, g, g, g);
				t += half4(0, 0, (0.015 - 0.75 * 0.04) / 0.96, 0.75);
				half a0 = t.x * min(t.y, exp2(-9.28 * NoV)) + t.z;
				half a1 = t.w;
				return saturate(lerp(a0, a1, f0));
			}
			
			half GSAA_Filament(half3 worldNormal, half perceptualRoughness, half inputVariance, half threshold)
			{
				// Kaplanyan 2016, "Stable specular highlights"
				// Tokuyoshi 2017, "Error Reduction and Simplification for Shading Anti-Aliasing"
				// Tokuyoshi and Kaplanyan 2019, "Improved Geometric Specular Antialiasing"
				
				// This implementation is meant for deferred rendering in the original paper but
				// we use it in forward rendering as well (as discussed in Tokuyoshi and Kaplanyan
				// 2019). The main reason is that the forward version requires an expensive transform
				// of the half vector by the tangent frame for every light. This is therefore an
				// approximation but it works well enough for our needs and provides an improvement
				// over our original implementation based on Vlachos 2015, "Advanced VR Rendering".
				
				half3 du = ddx(worldNormal);
				half3 dv = ddy(worldNormal);
				
				half variance = inputVariance * (dot(du, du) + dot(dv, dv));
				
				half roughness = perceptualRoughness * perceptualRoughness;
				half kernelRoughness = min(2.0 * variance, threshold);
				half squareRoughness = saturate(roughness * roughness + kernelRoughness);
				
				return sqrt(sqrt(squareRoughness));
			}
			
			// w0, w1, w2, and w3 are the four cubic B-spline basis functions
			half w0(half a)
			{
				//    return (1.0f/6.0f)*(-a*a*a + 3.0f*a*a - 3.0f*a + 1.0f);
				return (1.0f / 6.0f) * (a * (a * (-a + 3.0f) - 3.0f) + 1.0f);   // optimized
				
			}
			
			half w1(half a)
			{
				//    return (1.0f/6.0f)*(3.0f*a*a*a - 6.0f*a*a + 4.0f);
				return (1.0f / 6.0f) * (a * a * (3.0f * a - 6.0f) + 4.0f);
			}
			
			half w2(half a)
			{
				//    return (1.0f/6.0f)*(-3.0f*a*a*a + 3.0f*a*a + 3.0f*a + 1.0f);
				return (1.0f / 6.0f) * (a * (a * (-3.0f * a + 3.0f) + 3.0f) + 1.0f);
			}
			
			half w3(half a)
			{
				return (1.0f / 6.0f) * (a * a * a);
			}
			
			// g0 and g1 are the two amplitude functions
			half g0(half a)
			{
				return w0(a) + w1(a);
			}
			
			half g1(half a)
			{
				return w2(a) + w3(a);
			}
			
			// h0 and h1 are the two offset functions
			half h0(half a)
			{
				// note +0.5 offset to compensate for CUDA linear filtering convention
				return -1.0f + w1(a) / (w0(a) + w1(a)) + 0.5f;
			}
			
			half h1(half a)
			{
				return 1.0f + w3(a) / (w2(a) + w3(a)) + 0.5f;
			}
			
			//https://ndotl.wordpress.com/2018/08/29/baking-artifact-free-lightmaps
			half3 tex2DFastBicubicLightmap(half2 uv, inout half4 bakedColorTex)
			{
				#if !defined(PLAT_QUEST) && defined(BICUBIC_LIGHTMAP)
				half width;
				half height;
				unity_Lightmap.GetDimensions(width, height);
				half x = uv.x * width;
				half y = uv.y * height;
				
				x -= 0.5f;
				y -= 0.5f;
				half px = floor(x);
				half py = floor(y);
				half fx = x - px;
				half fy = y - py;
				
				// note: we could store these functions in a lookup table texture, but maths is cheap
				half g0x = g0(fx);
				half g1x = g1(fx);
				half h0x = h0(fx);
				half h1x = h1(fx);
				half h0y = h0(fy);
				half h1y = h1(fy);
				
				half4 r = g0(fy) * (g0x * UNITY_SAMPLE_TEX2D(unity_Lightmap, (half2(px + h0x, py + h0y) * 1.0f / width)) +
				g1x * UNITY_SAMPLE_TEX2D(unity_Lightmap, (half2(px + h1x, py + h0y) * 1.0f / width))) +
				g1(fy) * (g0x * UNITY_SAMPLE_TEX2D(unity_Lightmap, (half2(px + h0x, py + h1y) * 1.0f / width)) +
				g1x * UNITY_SAMPLE_TEX2D(unity_Lightmap, (half2(px + h1x, py + h1y) * 1.0f / width)));
				bakedColorTex = r;
				return DecodeLightmap(r);
				#else
				bakedColorTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, uv);
				return DecodeLightmap(bakedColorTex);
				#endif
			}
			
			half3 GetSpecularHighlights(half3 worldNormal, half3 lightColor, half3 lightDirection, half3 f0, half3 viewDir, half clampedRoughness, half NoV, half3 energyCompensation)
			{
				half3 halfVector = Unity_SafeNormalize(lightDirection + viewDir);
				
				half NoH = saturate(dot(worldNormal, halfVector));
				half NoL = saturate(dot(worldNormal, lightDirection));
				half LoH = saturate(dot(lightDirection, halfVector));
				
				half3 F = F_Schlick(LoH, f0);
				half D = D_GGX(NoH, clampedRoughness);
				half V = V_SmithGGXCorrelated(NoV, NoL, clampedRoughness);
				
				#ifndef UNITY_PBS_USE_BRDF2
				F *= energyCompensation;
				#endif
				
				return max(0, (D * V) * F) * lightColor * NoL * UNITY_PI;
			}
			
			#ifdef DYNAMICLIGHTMAP_ON
			half3 getRealtimeLightmap(half2 uv, half3 worldNormal)
			{
				half2 realtimeUV = uv;
				half4 bakedCol = UNITY_SAMPLE_TEX2D(unity_DynamicLightmap, realtimeUV);
				half3 realtimeLightmap = DecodeRealtimeLightmap(bakedCol);
				
				#ifdef DIRLIGHTMAP_COMBINED
				half4 realtimeDirTex = UNITY_SAMPLE_TEX2D_SAMPLER(unity_DynamicDirectionality, unity_DynamicLightmap, realtimeUV);
				realtimeLightmap += DecodeDirectionalLightmap(realtimeLightmap, realtimeDirTex, worldNormal);
				#endif
				
				return realtimeLightmap;
			}
			#endif
			
			half computeSpecularAO(half NoV, half ao, half roughness)
			{
				return clamp(pow(NoV + ao, exp2(-16.0 * roughness - 1.0)) - 1.0 + ao, 0.0, 1.0);
			}
			
			half shEvaluateDiffuseL1Geomerics_local(half L0, half3 L1, half3 n)
			{
				// average energy
				half R0 = L0;
				
				// avg direction of incoming light
				half3 R1 = 0.5f * L1;
				
				// directional brightness
				half lenR1 = length(R1);
				
				// linear angle between normal and direction 0-1
				//half q = 0.5f * (1.0f + dot(R1 / lenR1, n));
				//half q = dot(R1 / lenR1, n) * 0.5 + 0.5;
				half q = dot(normalize(R1), n) * 0.5 + 0.5;
				q = saturate(q); // Thanks to ScruffyRuffles for the bug identity.
				
				// power for q
				// lerps from 1 (linear) to 3 (cubic) based on directionality
				half p = 1.0f + 2.0f * lenR1 / R0;
				
				// dynamic range constant
				// should vary between 4 (highly directional) and 0 (ambient)
				half a = (1.0f - lenR1 / R0) / (1.0f + lenR1 / R0);
				
				return R0 * (a + (1.0f - a) * (p + 1.0f) * pow(q, p));
			}
			
			TEXTURE2D(_Ramp);
			SAMPLER(sampler_Ramp);
			TEXTURECUBE(_BakedCubemap);
			SAMPLER(sampler_BakedCubemap);
			
			half3 getReflectionUV(half3 direction, half3 position, half4 cubemapPosition, half3 boxMin, half3 boxMax)
			{
				#if UNITY_SPECCUBE_BOX_PROJECTION
				if (cubemapPosition.w > 0) {
					half3 factors = ((direction > 0 ? boxMax : boxMin) - position) / direction;
					half scalar = min(min(factors.x, factors.y), factors.z);
					direction = direction * scalar + (position - cubemapPosition);
				}
				#endif
				return direction;
			}
			
			half3 calcReflView(half3 viewDir, half3 normal)
			{
				return reflect(-viewDir, normal);
			}
			
			half3 calcStereoViewDir(half3 worldPos)
			{
				#if UNITY_SINGLE_PASS_STEREO
				half3 cameraPos = half3((unity_StereoWorldSpaceCameraPos[0]+ unity_StereoWorldSpaceCameraPos[1])*.5);
				#else
				half3 cameraPos = _WorldSpaceCameraPos;
				#endif
				half3 viewDir = cameraPos - worldPos;
				return normalize(viewDir);
			}
			
			half4 calcRamp(half NdL, half attenuation, half occlusion, int occlusionMode)
			{
				half remapRamp;
				remapRamp = NdL * 0.5 + 0.5;
				remapRamp *= lerp(1, occlusion, occlusionMode);
				#if defined(UNITY_PASS_FORWARDBASE)
				remapRamp *= attenuation;
				#endif
				half4 ramp = SAMPLE_TEXTURE2D(_Ramp, sampler_Ramp, half2(remapRamp, 0));
				return ramp;
			}
			
			half4 calcDiffuse(half attenuation, half3 albedo, half3 indirectDiffuse, half3 lightCol, half4 ramp)
			{
				half4 diffuse;
				half4 indirect = indirectDiffuse.xyzz;
				
				half grayIndirect = dot(indirectDiffuse, float3(1,1,1));
				half attenFactor = lerp(attenuation, 1, smoothstep(0, 0.2, grayIndirect));
				
				diffuse = ramp * attenFactor * half4(lightCol, 1) + indirect;
				diffuse = albedo.xyzz * diffuse;
				return diffuse;
			}
			
			half2 calcMatcapUV(half3 worldUp, half3 viewDirection, half3 normalDirection)
			{
				half3 worldViewUp = normalize(worldUp - viewDirection * dot(viewDirection, worldUp));
				half3 worldViewRight = normalize(cross(viewDirection, worldViewUp));
				half2 matcapUV = half2(dot(worldViewRight, normalDirection), dot(worldViewUp, normalDirection)) * 0.5 + 0.5;
				return matcapUV;
			}
			
			half3 calcIndirectSpecular(half lightAttenuation, MeshData d, SurfaceData o, half roughness, half3 reflDir, half3 indirectLight, float3 fresnel, half4 ramp)
			{//This function handls Unity style reflections, Matcaps, and a baked in fallback cubemap.
				half3 spec = half3(0,0,0);
				
				UNITY_BRANCH
				if (!o.EnableReflections) {
					spec = 0;
				} else if(any(o.BakedReflection.rgb)) {
					spec = o.BakedReflection;
					if(o.ReflectionBlendMode != 1)
					{
						spec *= (indirectLight + (_LightColor0 * lightAttenuation) * 0.5);
					}
				} else
				{
					#if defined(UNITY_PASS_FORWARDBASE) //Indirect PBR specular should only happen in the forward base pass. Otherwise each extra light adds another indirect sample, which could mean you're getting too much light.
					half3 reflectionUV1 = getReflectionUV(reflDir, d.worldSpacePosition, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax);
					half4 probe0 = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectionUV1, roughness * UNITY_SPECCUBE_LOD_STEPS);
					half3 probe0sample = DecodeHDR(probe0, unity_SpecCube0_HDR);
					
					half3 indirectSpecular;
					half interpolator = unity_SpecCube0_BoxMin.w;
					
					UNITY_BRANCH
					if (interpolator < 0.99999)
					{
						half3 reflectionUV2 = getReflectionUV(reflDir, d.worldSpacePosition, unity_SpecCube1_ProbePosition, unity_SpecCube1_BoxMin, unity_SpecCube1_BoxMax);
						half4 probe1 = UNITY_SAMPLE_TEXCUBE_SAMPLER_LOD(unity_SpecCube1, unity_SpecCube0, reflectionUV2, roughness * UNITY_SPECCUBE_LOD_STEPS);
						half3 probe1sample = DecodeHDR(probe1, unity_SpecCube1_HDR);
						indirectSpecular = lerp(probe1sample, probe0sample, interpolator);
					}
					else
					{
						indirectSpecular = probe0sample;
					}
					
					if (!any(indirectSpecular))
					{
						indirectSpecular = SAMPLE_TEXTURECUBE_LOD(_BakedCubemap, sampler_BakedCubemap, reflDir, roughness * UNITY_SPECCUBE_LOD_STEPS);
						indirectSpecular *= indirectLight;
					}
					spec = indirectSpecular * fresnel;
					#endif
				}
				// else if(_ReflectionMode == 1) //Baked Cubemap
				// {
				//     half3 indirectSpecular = SAMPLE_TEXTURECUBE_LOD(_BakedCubemap, sampler_BakedCubemap, reflDir, roughness * UNITY_SPECCUBE_LOD_STEPS);
				//     spec = indirectSpecular * fresnel;
				
				//     if(_ReflectionBlendMode != 1)
				//     {
				//         spec *= (indirectLight + (_LightColor0 * lightAttenuation) * 0.5);
				//     }
				// }
				// else if (_ReflectionMode == 2) //Matcap
				// {
				//     half3 upVector = half3(0,1,0);
				//     half2 remapUV = calcMatcapUV(upVector, d.worldSpaceViewDir, o.Normal);
				//     spec = SAMPLE_TEXTURE2D_LOD(_Matcap, remapUV, (1-roughness) * UNITY_SPECCUBE_LOD_STEPS) * _MatcapTint;
				
				//     if(_ReflectionBlendMode != 1)
				//     {
				//         spec *= (indirectLight + (_LightColor0 * lightAttenuation) * 0.5);
				//     }
				
				//     spec *= lerp(1, o.Albedo, _MatcapTintToDiffuse);
				// }
				return spec;
			}
			
			half3 calcDirectSpecular(MeshData d, SurfaceData o, float lightNoL, float NoH, float NoV, float lightLoH, half3 lightColor, half3 lightHalfVector, half anisotropy)
			{
				half specularIntensity = o.SpecularIntensity;
				half3 specular = half3(0,0,0);
				half smoothness = max(0.01, (o.SpecularArea));
				smoothness *= 1.7 - 0.7 * smoothness;
				
				float rough = max(smoothness * smoothness, 0.0045);
				float Dn = D_GGX(NoH, rough);
				float3 F = 1-F_Schlick(lightLoH, 0);
				float V = V_SmithGGXCorrelated(NoV, lightNoL, rough);
				float3 directSpecularNonAniso = max(0, (Dn * V) * F);
				
				anisotropy *= saturate(5.0 * smoothness);
				float at = max(rough * (1.0 + anisotropy), 0.001);
				float ab = max(rough * (1.0 - anisotropy), 0.001);
				float D = D_GGX_Anisotropic(NoH, lightHalfVector, d.worldSpaceTangent, d.bitangent, at, ab);
				float3 directSpecularAniso = max(0, (D * V) * F);
				
				specular = lerp(directSpecularNonAniso, directSpecularAniso, saturate(abs(anisotropy * 100)));
				specular = lerp(specular, smoothstep(0.5, 0.51, specular), o.SpecularSharpness) * 3 * lightColor.xyz * specularIntensity; // Multiply by 3 to bring up to brightness of standard
				specular *= lerp(1, o.Albedo, o.SpecularAlbedoTint);
				return specular;
			}
			
			half4 calcReflectionBlending(SurfaceData o, half reflectivity, half4 col, half3 indirectSpecular)
			{
				if (o.ReflectionBlendMode == 0) { // Additive
				col += indirectSpecular.xyzz * reflectivity;
				return col;
			} else if (o.ReflectionBlendMode == 1) { //Multiplicitive
			col = lerp(col, col * indirectSpecular.xyzz, reflectivity);
			return col;
		} else if(o.ReflectionBlendMode == 2) { //Subtractive
		col -= indirectSpecular.xyzz * reflectivity;
		return col;
	}
	return col;
}

half4 calcEmission(SurfaceData o, half lightAvg)
{
	#if defined(UNITY_PASS_FORWARDBASE) // Emission only in Base Pass, and vertex lights
	float4 emission = 0;
	emission = half4(o.Emission, 1);
	
	float4 scaledEmission = emission * saturate(smoothstep(1 - o.EmissionLightThreshold, 1 + o.EmissionLightThreshold, 1 - lightAvg));
	float4 em = lerp(scaledEmission, emission, o.EmissionScaleWithLight);
	
	// em.rgb = rgb2hsv(em.rgb);
	// em.x += fmod(_Hue, 360);
	// em.y = saturate(em.y * _Saturation);
	// em.z *= _Value;
	// em.rgb = hsv2rgb(em.rgb);
	
	return em;
	#else
	return 0;
	#endif
}

#if defined(NEED_DEPTH)
UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
#endif

half _ShadowSharpness;
half _OcclusionStrength;
half _BumpScale;
half _DetailNormalScale;
half _FlipDetailNormalY;
half _OutlineAlbedoTint;
half _OutlineWidth;
half _SpecularIntensity;
half _SpecularRoughness;
half _SpecularSharpness;
half _SpecularAnisotropy;
half _SpecularAlbedoTint;
half _Smoothness;
half _Metallic;
half _ReflectionAnisotropy;
half _MatcapBlur;
half _MatcapTintToDiffuse;
half _ReflectivityLevel;
half _EmissionTintToDiffuse;
half _EmissionScaleWithLightSensitivity;
half _RimIntensity;
half _RimAlbedoTint;
half _RimEnvironmentTint;
half _RimAttenuation;
half _RimRange;
half _RimThreshold;
half _RimSharpness;
half _ShadowRimRange;
half _ShadowRimThreshold;
half _ShadowRimSharpness;
half _ShadowRimAlbedoTint;
half2 GLOBAL_uv;
half3 GLOBAL_pixelNormal;
half4 _Color;
half4 _DetailNormalMap_ST;
half4 _OutlineColor;
half4 _MetallicRemap;
half4 _SmoothnessRemap;
half4 _MetallicGlossMap_TexelSize;
half4 _ALEmissionColor;
half4 _ALPackedRedColor;
half4 _ALPackedGreenColor;
half4 _ALPackedBlueColor;
half4 _EmissionColor;
half4 _RimTint;
half4 _ShadowRimTint;
float4 _MainTex_ST;
int _TintByVertexColor;
TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);
int _OcclusionMode;
TEXTURE2D(_OcclusionMap);
int _FlipBumpY;
int _DetailNormalsUVSet;
int _DetailNormalUVSet;
TEXTURE2D(_BumpMap);
SAMPLER(sampler_BumpMap);
TEXTURE2D(_DetailNormalMap);
SAMPLER(sampler_DetailNormalMap);
TEXTURE2D(_DetailNormalsMask);
SAMPLER(sampler_DetailNormalsMask);
int _OutlineLightingMode;
TEXTURE2D(_OutlineMask);
SAMPLER(sampler_OutlineMask);
int _SpecularMapUVSet;
TEXTURE2D(_SpecularMap);
int _ReflectionMode;
int _ReflectionBlendMode;
int _RoughnessMode;
TEXTURE2D(_Matcap);
SAMPLER(sampler_Matcap);
TEXTURE2D(_MetallicGlossMap);
TEXTURE2D(_ReflectivityMask);
int _ALMode;
int _ALBand;
int _ALGradientOnRed;
int _ALGradientOnGreen;
int _ALGradientOnBlue;
int _ALUVWidth;
int _ALMapUVSet;
TEXTURE2D(_ALMap);
SAMPLER(sampler_ALMap);
int _EmissionScaleWithLight;
TEXTURE2D(_EmissionMap);

void ToonOutlineVertex() {
	#if defined(PASS_OUTLINE)
	half mask = SAMPLE_TEXTURE2D_LOD(_OutlineMask, sampler_OutlineMask, vD.uv0, 0);
	half3 width = mask * _OutlineWidth * .01;
	width *= min(distance(mul(unity_ObjectToWorld, vD.vertex), _WorldSpaceCameraPos) * 3, 1);
	vD.vertex.xyz += vD.normal.xyz * width;
	#endif
}

void ToonFragment() {
	half2 uv = d.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
	GLOBAL_uv = uv;
	half3 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, GLOBAL_uv).rgb;
	albedo *= _Color;
	if (_TintByVertexColor) {
		albedo *= d.vertexColor.rgb;
	}
	o.Albedo = albedo;
	o.ShadowSharpness = _ShadowSharpness;
}

void ToonOcclusionFragment() {
	half occlusion = SAMPLE_TEXTURE2D(_OcclusionMap, sampler_MainTex, GLOBAL_uv).r;
	o.Occlusion = lerp(1, occlusion, _OcclusionStrength);
	o.OcclusionMode = _OcclusionMode;
}

void ToonNormalsFragment() {
	half4 normalTex = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, GLOBAL_uv);
	if (_FlipBumpY)
	{
		normalTex.y = 1 - normalTex.y;
	}
	half3 normal = UnpackScaleNormal(normalTex, _BumpScale);
	
	o.Normal = BlendNormals(o.Normal, normal);
	
	half2 detailUV = 0;
	switch (_DetailNormalsUVSet) {
		case 0: detailUV = d.uv0; break;
		case 1: detailUV = d.uv1; break;
		case 2: detailUV = d.uv2; break;
		case 3: detailUV = d.uv3; break;
	}
	detailUV = detailUV * _DetailNormalMap_ST.xy + _DetailNormalMap_ST.zw;
	half4 detailNormalTex = SAMPLE_TEXTURE2D(_DetailNormalMap, sampler_DetailNormalMap, detailUV);
	if (_FlipDetailNormalY)
	{
		detailNormalTex.y = 1 - detailNormalTex.y;
	}
	
	half2 detailMaskUV = 0;
	switch (_DetailNormalUVSet) {
		case 0: detailMaskUV = d.uv0; break;
		case 1: detailMaskUV = d.uv1; break;
		case 2: detailMaskUV = d.uv2; break;
		case 3: detailMaskUV = d.uv3; break;
	}
	half detailMask = SAMPLE_TEXTURE2D(_DetailNormalsMask, sampler_MainTex, GLOBAL_uv).r;
	
	half3 detailNormal = UnpackScaleNormal(detailNormalTex, _DetailNormalScale);
	
	o.Normal = lerp(o.Normal, BlendNormals(o.Normal, detailNormal), detailMask);
	
	half3 properNormal = normalize(o.Normal.x * d.worldSpaceTangent.xyz + o.Normal.y * d.bitangent.xyz + o.Normal.z * d.worldNormal.xyz);
	d.worldSpaceTangent.xyz = cross(d.bitangent.xyz, properNormal);
	d.bitangent.xyz = cross(properNormal, d.worldSpaceTangent.xyz);
	d.TBNMatrix = float3x3(normalize(d.worldSpaceTangent.xyz), d.bitangent, d.worldNormal);
	GLOBAL_pixelNormal = properNormal;
}

void ToonOutlineFragment() {
	o.OutlineColor = lerp(_OutlineColor, _OutlineColor * o.Albedo, _OutlineAlbedoTint);
	o.OutlineLightingMode = _OutlineLightingMode;
}

void ToonSpecularFragment() {
	half2 maskUV = 0;
	switch (_DetailNormalsUVSet) {
		case 0: maskUV = d.uv0; break;
		case 1: maskUV = d.uv1; break;
		case 2: maskUV = d.uv2; break;
		case 3: maskUV = d.uv3; break;
	}
	
	half3 specMap = SAMPLE_TEXTURE2D(_SpecularMap, sampler_MainTex, maskUV);
	o.SpecularIntensity = _SpecularIntensity * specMap.r;
	o.SpecularArea = max(0.01, _SpecularRoughness * specMap.b);
	o.SpecularAnisotropy = _SpecularAnisotropy;
	o.SpecularAlbedoTint = _SpecularAlbedoTint * specMap.g;
	o.SpecularSharpness = _SpecularSharpness;
}

void ToonReflectionFragment() {
	o.EnableReflections = _ReflectionMode != 3;
	o.ReflectionBlendMode = _ReflectionBlendMode;
	
	half mask = SAMPLE_TEXTURE2D(_ReflectivityMask, sampler_MainTex, GLOBAL_uv).r;
	mask *= _ReflectivityLevel;
	
	UNITY_BRANCH
	if (_ReflectionMode == 0) {
		half4 metalSmooth = SAMPLE_TEXTURE2D(_MetallicGlossMap, sampler_MainTex, GLOBAL_uv);
		int hasMetallicSmooth = _MetallicGlossMap_TexelSize.z > 8;
		half metal = metalSmooth.r;
		half smooth = metalSmooth.a;
		if (_RoughnessMode)
		{
			smooth = 1 - smooth;
		}
		metal = remap(metal, 0, 1, _MetallicRemap.x, _MetallicRemap.y);
		smooth = remap(smooth, 0, 1, _SmoothnessRemap.x, _SmoothnessRemap.y);
		o.Metallic = lerp(_Metallic, metal, hasMetallicSmooth);
		o.Smoothness = lerp(_Smoothness, smooth, hasMetallicSmooth);
		o.Anisotropy = _ReflectionAnisotropy;
	}
	UNITY_BRANCH
	if (_ReflectionMode == 2) {
		half3 upVector = half3(0,1,0);
		half2 remapUV = calcMatcapUV(upVector, d.worldSpaceViewDir, GLOBAL_pixelNormal);
		half4 spec = 0;
		spec = SAMPLE_TEXTURE2D_LOD(_Matcap, sampler_Matcap, remapUV, _MatcapBlur * UNITY_SPECCUBE_LOD_STEPS);
		
		spec.rgb *= lerp(1, o.Albedo, _MatcapTintToDiffuse);
		o.BakedReflection = spec.rgb;
	}
	o.Reflectivity = mask;
}

void ToonALFragment() {
	if(AudioLinkIsAvailable() && _ALMode != 0) {
		half2 alUV = 0;
		switch (_ALMapUVSet) {
			case 0: alUV = GLOBAL_uv; break;
			case 1: alUV = d.uv1; break;
			case 2: alUV = d.uv2; break;
			case 3: alUV = d.uv3; break;
		}
		half4 alMask = SAMPLE_TEXTURE2D(_ALMap, sampler_ALMap, alUV);
		if (_ALMode == 2) {
			half audioDataBass = AudioLinkData(ALPASS_AUDIOBASS).x;
			half audioDataMids = AudioLinkData(ALPASS_AUDIOLOWMIDS).x;
			half audioDataHighs = (AudioLinkData(ALPASS_AUDIOHIGHMIDS).x + AudioLinkData(ALPASS_AUDIOTREBLE).x) * 0.5;
			
			half tLow = smoothstep((1-audioDataBass), (1-audioDataBass) + 0.01, alMask.r) * alMask.a;
			half tMid = smoothstep((1-audioDataMids), (1-audioDataMids) + 0.01, alMask.g) * alMask.a;
			half tHigh = smoothstep((1-audioDataHighs), (1-audioDataHighs) + 0.01, alMask.b) * alMask.a;
			
			half4 emissionChannelRed = lerp(alMask.r, tLow, _ALGradientOnRed) * _ALPackedRedColor * audioDataBass;
			half4 emissionChannelGreen = lerp(alMask.g, tMid, _ALGradientOnGreen) * _ALPackedGreenColor * audioDataMids;
			half4 emissionChannelBlue = lerp(alMask.b, tHigh, _ALGradientOnBlue) * _ALPackedBlueColor * audioDataHighs;
			o.Emission += emissionChannelRed.rgb + emissionChannelGreen.rgb + emissionChannelBlue.rgb;
		} else {
			int2 aluv;
			if (_ALMode == 1) {
				aluv = int2(0, _ALBand);
			} else {
				aluv = int2(GLOBAL_uv.x * _ALUVWidth, GLOBAL_uv.y);
			}
			half sampledAL = AudioLinkData(aluv).x;
			o.Emission +=  alMask.rgb * _ALEmissionColor.rgb * sampledAL;
		}
	}
}

void ToonEmissionFragment() {
	half3 emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_MainTex, GLOBAL_uv).rgb;
	emission *= lerp(emission, emission * o.Albedo, _EmissionTintToDiffuse) * _EmissionColor;
	o.Emission += emission;
	o.EmissionScaleWithLight = _EmissionScaleWithLight;
	o.EmissionLightThreshold = _EmissionScaleWithLightSensitivity;
}

void ToonRimLightFragment() {
	#ifndef USING_DIRECTIONAL_LIGHT
	fixed3 lightDir = normalize(UnityWorldSpaceLightDir(d.worldSpacePosition));
	#else
	fixed3 lightDir = _WorldSpaceLightPos0.xyz;
	#endif
	half lightNoL = saturate(dot(GLOBAL_pixelNormal, lightDir));
	half SVDNoN = abs(dot(d.svdn, GLOBAL_pixelNormal));
	
	half rimIntensity = saturate((1 - SVDNoN)) * pow(lightNoL, _RimThreshold);
	rimIntensity = smoothstep(_RimRange - _RimSharpness, _RimRange + _RimSharpness, rimIntensity);
	half4 rim = rimIntensity * _RimIntensity;
	
	half3 env = 0;
	#if defined(UNITY_PASS_FORWARDBASE)
	env = getEnvReflection(d.worldSpaceViewDir.xyz, d.worldSpacePosition.xyz, GLOBAL_pixelNormal, o.Smoothness, 5);
	#endif
	
	o.RimLight = rim * _RimTint * lerp(1, o.Albedo.rgbb, _RimAlbedoTint) * lerp(1, env.rgbb, _RimEnvironmentTint);
	o.RimAttenuation = _RimAttenuation;
}

void ToonShadowRimFragment() {
	#ifndef USING_DIRECTIONAL_LIGHT
	fixed3 lightDir = normalize(UnityWorldSpaceLightDir(d.worldSpacePosition));
	#else
	fixed3 lightDir = _WorldSpaceLightPos0.xyz;
	#endif
	half lightNoL = saturate(dot(GLOBAL_pixelNormal, lightDir));
	half SVDNoN = abs(dot(d.svdn, GLOBAL_pixelNormal));
	half shadowRimIntensity = saturate((1 - SVDNoN)) * pow(1 - lightNoL, _ShadowRimThreshold * 2);
	shadowRimIntensity = smoothstep(_ShadowRimRange - _ShadowRimSharpness, _ShadowRimRange + _ShadowRimSharpness, shadowRimIntensity);
	
	o.RimShadow = lerp(1, (_ShadowRimTint * lerp(1, o.Albedo.rgbb, _ShadowRimAlbedoTint)), shadowRimIntensity);
}

void XSToonLighting()
{
	#if !defined(UNITY_PASS_SHADOWCASTER)
	half reflectance = o.Reflectivity;
	half3 f0 = 0.16 * reflectance * reflectance * (1 - o.Metallic) + o.Albedo * o.Metallic;
	half3 indirectDiffuse = 1;
	half3 indirectSpecular = 0;
	half3 directSpecular = 0;
	half occlusion = o.Occlusion;
	half perceptualRoughness = 1 - o.Smoothness;
	half3 tangentNormal = o.Normal;
	o.Normal = normalize(mul(o.Normal, d.TBNMatrix));
	half3 reflDir = calcReflView(d.worldSpaceViewDir, o.Normal);
	
	#ifndef USING_DIRECTIONAL_LIGHT
	fixed3 lightDir = normalize(UnityWorldSpaceLightDir(d.worldSpacePosition));
	#else
	fixed3 lightDir = _WorldSpaceLightPos0.xyz;
	#endif
	
	// Attenuation
	UNITY_LIGHT_ATTENUATION(lightAttenuation, FragData, d.worldSpacePosition);
	
	// fix for rare bug where light atten is 0 when there is no directional light in the scene
	#ifdef UNITY_PASS_FORWARDBASE
	if(all(_LightColor0.rgb == 0.0))
	lightAttenuation = 1.0;
	#endif
	
	#if defined(USING_DIRECTIONAL_LIGHT)
	half sharp = o.ShadowSharpness * 0.5;
	lightAttenuation = smoothstep(sharp, 1 - sharp, lightAttenuation); //Converge at the center line
	#endif
	
	half3 lightColor = _LightColor0.rgb;
	
	half3 lightHalfVector = Unity_SafeNormalize(lightDir + d.worldSpaceViewDir);
	half lightNoL = saturate(dot(o.Normal, lightDir));
	half lightLoH = saturate(dot(lightDir, lightHalfVector));
	
	half NoV = abs(dot(o.Normal, d.worldSpaceViewDir)) + 1e-5;
	half NoH = saturate(dot(o.Normal, lightHalfVector));
	half3 stereoViewDir = calcStereoViewDir(d.worldSpacePosition);
	half NoSVDN = abs(dot(stereoViewDir, o.Normal));
	
	// Aniso Refl
	half3 reflViewAniso = 0;
	
	float3 anisotropicDirection = o.Anisotropy >= 0.0 ? d.bitangent : FragData.worldTangent.xyz;
	float3 anisotropicTangent = cross(anisotropicDirection, d.worldSpaceViewDir);
	float3 anisotropicNormal = cross(anisotropicTangent, anisotropicDirection);
	float bendFactor = abs(o.Anisotropy) * saturate(5.0 * perceptualRoughness);
	float3 bentNormal = normalize(lerp(o.Normal, anisotropicNormal, bendFactor));
	reflViewAniso = reflect(-d.worldSpaceViewDir, bentNormal);
	
	// Indirect diffuse
	#if !defined(LIGHTMAP_ON)
	indirectDiffuse = ShadeSH9(float4(0,0.5,0,1));
	#else
	indirectDiffuse = 0;
	#endif
	indirectDiffuse *= lerp(occlusion, 1, o.OcclusionMode);
	
	bool lightEnv = any(lightDir.xyz);
	// if there is no realtime light - we create it from indirect diffuse
	if (!lightEnv) {
		lightColor = indirectDiffuse.xyz * 0.6;
		indirectDiffuse = indirectDiffuse * 0.4;
	}
	
	half lightAvg = (dot(indirectDiffuse.rgb, grayscaleVec) + dot(lightColor.rgb, grayscaleVec)) / 2;
	
	// Light Ramp
	half4 ramp = 1;
	half4 diffuse = 1;
	ramp = calcRamp(lightNoL, lightAttenuation, occlusion, _OcclusionMode);
	diffuse = calcDiffuse(lightAttenuation, o.Albedo.rgb * perceptualRoughness, indirectDiffuse, lightColor, ramp);
	
	// Rims
	half4 rimLight = o.RimLight;
	rimLight *= lightColor.xyzz + indirectDiffuse.xyzz;
	rimLight *= lerp(1, lightAttenuation + indirectDiffuse.xyzz, o.RimAttenuation);
	half4 rimShadow = o.RimShadow;
	
	float3 fresnel = F_Schlick(NoV, f0);
	indirectSpecular = calcIndirectSpecular(lightAttenuation, d, o, perceptualRoughness, reflViewAniso, indirectDiffuse, fresnel, ramp) * occlusion;
	directSpecular = calcDirectSpecular(d, o, lightNoL, NoH, NoV, lightLoH, lightColor, lightHalfVector, o.SpecularAnisotropy) * lightNoL * occlusion * lightAttenuation;
	
	FinalColor = diffuse * o.RimShadow;
	FinalColor = calcReflectionBlending(o, reflectance, FinalColor, indirectSpecular);
	FinalColor += max(directSpecular.xyzz, rimLight);
	FinalColor.rgb += calcEmission(o, lightAvg);
	
	// Outline
	#if defined(PASS_OUTLINE)
	half3 outlineColor = 0;
	half3 ol = o.OutlineColor;
	outlineColor = ol * saturate(lightAttenuation * lightNoL) * lightColor.rgb;
	outlineColor += indirectDiffuse * ol;
	outlineColor = lerp(outlineColor, ol, o.OutlineLightingMode);
	FinalColor.rgb = outlineColor;
	#endif
	
	#endif
}

// ForwardBase Vertex
FragmentData Vertex(VertexData v)
{
	UNITY_SETUP_INSTANCE_ID(v);
	FragmentData i;
	UNITY_INITIALIZE_OUTPUT(FragmentData, i);
	UNITY_TRANSFER_INSTANCE_ID(v, i);
	UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(i);
	
	vD = v;
	FragData = i;
	ToonOutlineVertex();
	
	i = FragData;
	v = vD;
	#if defined(UNITY_PASS_SHADOWCASTER)
	i.worldNormal = UnityObjectToWorldNormal(v.normal);
	i.worldPos = mul(unity_ObjectToWorld, v.vertex);
	i.uv0 = v.uv0;
	i.uv1 = v.uv1;
	i.uv2 = v.uv2;
	i.uv3 = v.uv3;
	i.worldTangent.xyz = UnityObjectToWorldDir(v.tangent.xyz);
	i.worldTangent.w = v.tangent.w * unity_WorldTransformParams.w;
	#else
	i.pos = UnityObjectToClipPos(v.vertex);
	i.normal = v.normal;
	i.worldNormal = UnityObjectToWorldNormal(v.normal);
	i.worldPos = mul(unity_ObjectToWorld, v.vertex);
	i.uv0 = v.uv0;
	i.uv1 = v.uv1;
	i.uv2 = v.uv2;
	i.uv3 = v.uv3;
	i.worldTangent.xyz = UnityObjectToWorldDir(v.tangent.xyz);
	i.worldTangent.w = v.tangent.w * unity_WorldTransformParams.w;
	i.vertexColor = v.color;
	
	#if defined(NEED_SCREEN_POS)
	i.screenPos = ComputeScreenPos(i.pos);
	#endif
	
	#if defined(LIGHTMAP_ON)
	i.lightmapUv.xy = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
	#endif
	#if defined(DYNAMICLIGHTMAP_ON)
	i.lightmapUv.zw = v.uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
	#endif
	
	UNITY_TRANSFER_LIGHTING(i, v.uv1.xy);
	
	#if !defined(UNITY_PASS_FORWARDADD)
	// unity does some funky stuff for different platforms with these macros
	#ifdef FOG_COMBINED_WITH_TSPACE
	UNITY_TRANSFER_FOG_COMBINED_WITH_TSPACE(i, i.pos);
	#elif defined(FOG_COMBINED_WITH_WORLD_POS)
	UNITY_TRANSFER_FOG_COMBINED_WITH_WORLD_POS(i, i.pos);
	#else
	UNITY_TRANSFER_FOG(i, i.pos);
	#endif
	#else
	UNITY_TRANSFER_FOG(i, i.pos);
	#endif
	#endif
	
	return i;
}

// ForwardBase Fragment
half4 Fragment(FragmentData i) : SV_TARGET
{
	UNITY_SETUP_INSTANCE_ID(i);
	#ifdef FOG_COMBINED_WITH_TSPACE
	UNITY_EXTRACT_FOG_FROM_TSPACE(i);
	#elif defined(FOG_COMBINED_WITH_WORLD_POS)
	UNITY_EXTRACT_FOG_FROM_WORLD_POS(i);
	#else
	UNITY_EXTRACT_FOG(i);
	#endif
	
	FragData = i;
	o = (SurfaceData) 0;
	d = CreateMeshData(i);
	o.Albedo = half3(0.5, 0.5, 0.5);
	o.Normal = half3(0, 0, 1);
	o.Smoothness = 0;
	o.Occlusion = 1;
	o.Alpha = 1;
	o.RimShadow = 1;
	o.RimAttenuation = 1;
	FinalColor = half4(o.Albedo, o.Alpha);
	
	ToonFragment();
	ToonOcclusionFragment();
	ToonNormalsFragment();
	ToonOutlineFragment();
	ToonSpecularFragment();
	ToonReflectionFragment();
	ToonALFragment();
	ToonEmissionFragment();
	ToonRimLightFragment();
	ToonShadowRimFragment();
	
	XSToonLighting();
	
	UNITY_APPLY_FOG(_unity_fogCoord, FinalColor);
	
	return FinalColor;
}

ENDCG
// ForwardBase Pass End

}

Pass
{
Tags { "LightMode" = "ForwardAdd"  }
ZWrite Off
Blend One One

// ForwardAdd Pass Start
CGPROGRAM
#pragma target 4.5
#pragma multi_compile_instancing
#pragma multi_compile_fog
#pragma multi_compile_fwdadd_fullshadows
#pragma vertex Vertex
#pragma fragment Fragment

#define UNITY_INSTANCED_LOD_FADE
#define UNITY_INSTANCED_SH
#define UNITY_INSTANCED_LIGHTMAPSTS

#ifndef UNITY_PASS_FORWARDADD
#define UNITY_PASS_FORWARDADD
#endif

#include "UnityStandardUtils.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

#define FLT_EPSILON     1.192092896e-07

#if defined(UNITY_PBS_USE_BRDF2) || defined(SHADER_API_MOBILE)
#define PLAT_QUEST
#else
#ifdef PLAT_QUEST
#undef PLAT_QUEST
#endif
#endif

#define NEED_SCREEN_POS

#define grayscaleVec float3(0.2125, 0.7154, 0.0721)

// Credit to Jason Booth for digging this all up
// This originally comes from CoreRP, see Jason's comment below

// If your looking in here and thinking WTF, yeah, I know. These are taken from the SRPs, to allow us to use the same
// texturing library they use. However, since they are not included in the standard pipeline by default, there is no
// way to include them in and they have to be inlined, since someone could copy this shader onto another machine without
// Better Shaders installed. Unfortunate, but I'd rather do this and have a nice library for texture sampling instead
// of the patchy one Unity provides being inlined/emulated in HDRP/URP. Strangely, PSSL and XBoxOne libraries are not
// included in the standard SRP code, but they are in tons of Unity own projects on the web, so I grabbed them from there.

#if defined(SHADER_API_XBOXONE)

// Initialize arbitrary structure with zero values.
// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
#define ZERO_INITIALIZE(type, name) name = (type)0;
#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }

// Texture util abstraction

#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) textureName.CalculateLevelOfDetail(samplerName, coord2)

// Texture abstraction

#define TEXTURE2D(textureName)                Texture2D textureName
#define TEXTURE2D_ARRAY(textureName)          Texture2DArray textureName
#define TEXTURECUBE(textureName)              TextureCube textureName
#define TEXTURECUBE_ARRAY(textureName)        TextureCubeArray textureName
#define TEXTURE3D(textureName)                Texture3D textureName

#define TEXTURE2D_FLOAT(textureName)          TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_FLOAT(textureName)    TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_FLOAT(textureName)        TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_FLOAT(textureName)  TEXTURECUBE_ARRAY(textureName)
#define TEXTURE3D_FLOAT(textureName)          TEXTURE3D(textureName)

#define TEXTURE2D_HALF(textureName)           TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_HALF(textureName)     TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_HALF(textureName)         TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_HALF(textureName)   TEXTURECUBE_ARRAY(textureName)
#define TEXTURE3D_HALF(textureName)           TEXTURE3D(textureName)

#define TEXTURE2D_SHADOW(textureName)         TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_SHADOW(textureName)   TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_SHADOW(textureName)       TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_SHADOW(textureName) TEXTURECUBE_ARRAY(textureName)

#define RW_TEXTURE2D(type, textureName)       RWTexture2D<type> textureName
#define RW_TEXTURE2D_ARRAY(type, textureName) RWTexture2DArray<type> textureName
#define RW_TEXTURE3D(type, textureName)       RWTexture3D<type> textureName

#define SAMPLER(samplerName)                  SamplerState samplerName
#define SAMPLER_CMP(samplerName)              SamplerComparisonState samplerName

#define TEXTURE2D_PARAM(textureName, samplerName)                 TEXTURE2D(textureName), SAMPLER(samplerName)
#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)           TEXTURE2D_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_PARAM(textureName, samplerName)               TEXTURECUBE(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)         TEXTURECUBE_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURE3D_PARAM(textureName, samplerName)                 TEXTURE3D(textureName), SAMPLER(samplerName)

#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)          TEXTURE2D(textureName), SAMPLER_CMP(samplerName)
#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)    TEXTURE2D_ARRAY(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)        TEXTURECUBE(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_ARRAY_SHADOW_PARAM(textureName, samplerName)  TEXTURECUBE_ARRAY(textureName), SAMPLER_CMP(samplerName)

#define TEXTURE2D_ARGS(textureName, samplerName)                textureName, samplerName
#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)          textureName, samplerName
#define TEXTURECUBE_ARGS(textureName, samplerName)              textureName, samplerName
#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)        textureName, samplerName
#define TEXTURE3D_ARGS(textureName, samplerName)                textureName, samplerName

#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)         textureName, samplerName
#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)   textureName, samplerName
#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)       textureName, samplerName
#define TEXTURECUBE_ARRAY_SHADOW_ARGS(textureName, samplerName) textureName, samplerName

#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod)                      textureName.SampleLevel(samplerName, coord2, lod)
#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                    textureName.SampleBias(samplerName, coord2, bias)
#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, dpdx, dpdy)              textureName.SampleGrad(samplerName, coord2, dpdx, dpdy)
#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                  textureName.Sample(samplerName, float3(coord2, index))
#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)         textureName.SampleLevel(samplerName, float3(coord2, index), lod)
#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)       textureName.SampleBias(samplerName, float3(coord2, index), bias)
#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy) textureName.SampleGrad(samplerName, float3(coord2, index), dpdx, dpdy)
#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                             textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                    textureName.SampleLevel(samplerName, coord3, lod)
#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                  textureName.SampleBias(samplerName, coord3, bias)
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)                textureName.Sample(samplerName, float4(coord3, index))
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)       textureName.SampleLevel(samplerName, float4(coord3, index), lod)
#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)     textureName.SampleBias(samplerName, float4(coord3, index), bias)
#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                               textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                      textureName.SampleLevel(samplerName, coord3, lod)

#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                    textureName.SampleCmpLevelZero(samplerName, (coord3).xy, (coord3).z)
#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)       textureName.SampleCmpLevelZero(samplerName, float3((coord3).xy, index), (coord3).z)
#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                  textureName.SampleCmpLevelZero(samplerName, (coord4).xyz, (coord4).w)
#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)     textureName.SampleCmpLevelZero(samplerName, float4((coord4).xyz, index), (coord4).w)

#define LOAD_TEXTURE2D(textureName, unCoord2)                                   textureName.Load(int3(unCoord2, 0))
#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)                          textureName.Load(int3(unCoord2, lod))
#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)                 textureName.Load(unCoord2, sampleIndex)
#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)                      textureName.Load(int4(unCoord2, index, 0))
#define LOAD_TEXTURE2D_ARRAY_MSAA(textureName, unCoord2, index, sampleIndex)    textureName.Load(int3(unCoord2, index), sampleIndex)
#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod)             textureName.Load(int4(unCoord2, index, lod))
#define LOAD_TEXTURE3D(textureName, unCoord3)                                   textureName.Load(int4(unCoord3, 0))
#define LOAD_TEXTURE3D_LOD(textureName, unCoord3, lod)                          textureName.Load(int4(unCoord3, lod))

#define PLATFORM_SUPPORT_GATHER
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                textureName.Gather(samplerName, coord2)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)   textureName.Gather(samplerName, float3(coord2, index))
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)              textureName.Gather(samplerName, coord3)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index) textureName.Gather(samplerName, float4(coord3, index))
#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)            textureName.GatherRed(samplerName, coord2)
#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherGreen(samplerName, coord2)
#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)           textureName.GatherBlue(samplerName, coord2)
#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherAlpha(samplerName, coord2)

#elif defined(SHADER_API_PSSL)

// Initialize arbitrary structure with zero values.
// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
#define ZERO_INITIALIZE(type, name) name = (type)0;
#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }

// Texture util abstraction

#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) textureName.GetLOD(samplerName, coord2)

// Texture abstraction

#define TEXTURE2D(textureName)                Texture2D textureName
#define TEXTURE2D_ARRAY(textureName)          Texture2DArray textureName
#define TEXTURECUBE(textureName)              TextureCube textureName
#define TEXTURECUBE_ARRAY(textureName)        TextureCubeArray textureName
#define TEXTURE3D(textureName)                Texture3D textureName

#define TEXTURE2D_FLOAT(textureName)          TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_FLOAT(textureName)    TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_FLOAT(textureName)        TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_FLOAT(textureName)  TEXTURECUBE_ARRAY(textureName)
#define TEXTURE3D_FLOAT(textureName)          TEXTURE3D(textureName)

#define TEXTURE2D_HALF(textureName)           TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_HALF(textureName)     TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_HALF(textureName)         TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_HALF(textureName)   TEXTURECUBE_ARRAY(textureName)
#define TEXTURE3D_HALF(textureName)           TEXTURE3D(textureName)

#define TEXTURE2D_SHADOW(textureName)         TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_SHADOW(textureName)   TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_SHADOW(textureName)       TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_SHADOW(textureName) TEXTURECUBE_ARRAY(textureName)

#define RW_TEXTURE2D(type, textureName)       RW_Texture2D<type> textureName
#define RW_TEXTURE2D_ARRAY(type, textureName) RW_Texture2D_Array<type> textureName
#define RW_TEXTURE3D(type, textureName)       RW_Texture3D<type> textureName

#define SAMPLER(samplerName)                  SamplerState samplerName
#define SAMPLER_CMP(samplerName)              SamplerComparisonState samplerName

#define TEXTURE2D_PARAM(textureName, samplerName)                 TEXTURE2D(textureName), SAMPLER(samplerName)
#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)           TEXTURE2D_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_PARAM(textureName, samplerName)               TEXTURECUBE(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)         TEXTURECUBE_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURE3D_PARAM(textureName, samplerName)                 TEXTURE3D(textureName), SAMPLER(samplerName)

#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)          TEXTURE2D(textureName), SAMPLER_CMP(samplerName)
#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)    TEXTURE2D_ARRAY(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)        TEXTURECUBE(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_ARRAY_SHADOW_PARAM(textureName, samplerName)  TEXTURECUBE_ARRAY(textureName), SAMPLER_CMP(samplerName)

#define TEXTURE2D_ARGS(textureName, samplerName)                textureName, samplerName
#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)          textureName, samplerName
#define TEXTURECUBE_ARGS(textureName, samplerName)              textureName, samplerName
#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)        textureName, samplerName
#define TEXTURE3D_ARGS(textureName, samplerName)                textureName, samplerName

#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)         textureName, samplerName
#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)   textureName, samplerName
#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)       textureName, samplerName
#define TEXTURECUBE_ARRAY_SHADOW_ARGS(textureName, samplerName) textureName, samplerName

#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod)                      textureName.SampleLevel(samplerName, coord2, lod)
#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                    textureName.SampleBias(samplerName, coord2, bias)
#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, dpdx, dpdy)              textureName.SampleGrad(samplerName, coord2, dpdx, dpdy)
#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                  textureName.Sample(samplerName, float3(coord2, index))
#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)         textureName.SampleLevel(samplerName, float3(coord2, index), lod)
#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)       textureName.SampleBias(samplerName, float3(coord2, index), bias)
#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy) textureName.SampleGrad(samplerName, float3(coord2, index), dpdx, dpdy)
#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                             textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                    textureName.SampleLevel(samplerName, coord3, lod)
#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                  textureName.SampleBias(samplerName, coord3, bias)
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)                textureName.Sample(samplerName, float4(coord3, index))
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)       textureName.SampleLevel(samplerName, float4(coord3, index), lod)
#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)     textureName.SampleBias(samplerName, float4(coord3, index), bias)
#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                               textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                      textureName.SampleLevel(samplerName, coord3, lod)

#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                    textureName.SampleCmpLevelZero(samplerName, (coord3).xy, (coord3).z)
#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)       textureName.SampleCmpLevelZero(samplerName, float3((coord3).xy, index), (coord3).z)
#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                  textureName.SampleCmpLevelZero(samplerName, (coord4).xyz, (coord4).w)
#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)     textureName.SampleCmpLevelZero(samplerName, float4((coord4).xyz, index), (coord4).w)

#define LOAD_TEXTURE2D(textureName, unCoord2)                                   textureName.Load(int3(unCoord2, 0))
#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)                          textureName.Load(int3(unCoord2, lod))
#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)                 textureName.Load(unCoord2, sampleIndex)
#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)                      textureName.Load(int4(unCoord2, index, 0))
#define LOAD_TEXTURE2D_ARRAY_MSAA(textureName, unCoord2, index, sampleIndex)    textureName.Load(int3(unCoord2, index), sampleIndex)
#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod)             textureName.Load(int4(unCoord2, index, lod))
#define LOAD_TEXTURE3D(textureName, unCoord3)                                   textureName.Load(int4(unCoord3, 0))
#define LOAD_TEXTURE3D_LOD(textureName, unCoord3, lod)                          textureName.Load(int4(unCoord3, lod))

#define PLATFORM_SUPPORT_GATHER
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                textureName.Gather(samplerName, coord2)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)   textureName.Gather(samplerName, float3(coord2, index))
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)              textureName.Gather(samplerName, coord3)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index) textureName.Gather(samplerName, float4(coord3, index))
#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)            textureName.GatherRed(samplerName, coord2)
#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherGreen(samplerName, coord2)
#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)           textureName.GatherBlue(samplerName, coord2)
#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherAlpha(samplerName, coord2)

#elif defined(SHADER_API_D3D11)

// Initialize arbitrary structure with zero values.
// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
#define ZERO_INITIALIZE(type, name) name = (type)0;
#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }

// Texture util abstraction

#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) textureName.CalculateLevelOfDetail(samplerName, coord2)

// Texture abstraction

#define TEXTURE2D(textureName)                Texture2D textureName
#define TEXTURE2D_ARRAY(textureName)          Texture2DArray textureName
#define TEXTURECUBE(textureName)              TextureCube textureName
#define TEXTURECUBE_ARRAY(textureName)        TextureCubeArray textureName
#define TEXTURE3D(textureName)                Texture3D textureName

#define TEXTURE2D_FLOAT(textureName)          TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_FLOAT(textureName)    TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_FLOAT(textureName)        TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_FLOAT(textureName)  TEXTURECUBE_ARRAY(textureName)
#define TEXTURE3D_FLOAT(textureName)          TEXTURE3D(textureName)

#define TEXTURE2D_HALF(textureName)           TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_HALF(textureName)     TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_HALF(textureName)         TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_HALF(textureName)   TEXTURECUBE_ARRAY(textureName)
#define TEXTURE3D_HALF(textureName)           TEXTURE3D(textureName)

#define TEXTURE2D_SHADOW(textureName)         TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_SHADOW(textureName)   TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_SHADOW(textureName)       TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_SHADOW(textureName) TEXTURECUBE_ARRAY(textureName)

#define RW_TEXTURE2D(type, textureName)       RWTexture2D<type> textureName
#define RW_TEXTURE2D_ARRAY(type, textureName) RWTexture2DArray<type> textureName
#define RW_TEXTURE3D(type, textureName)       RWTexture3D<type> textureName

#define SAMPLER(samplerName)                  SamplerState samplerName
#define SAMPLER_CMP(samplerName)              SamplerComparisonState samplerName

#define TEXTURE2D_PARAM(textureName, samplerName)                 TEXTURE2D(textureName), SAMPLER(samplerName)
#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)           TEXTURE2D_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_PARAM(textureName, samplerName)               TEXTURECUBE(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)         TEXTURECUBE_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURE3D_PARAM(textureName, samplerName)                 TEXTURE3D(textureName), SAMPLER(samplerName)

#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)          TEXTURE2D(textureName), SAMPLER_CMP(samplerName)
#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)    TEXTURE2D_ARRAY(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)        TEXTURECUBE(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_ARRAY_SHADOW_PARAM(textureName, samplerName)  TEXTURECUBE_ARRAY(textureName), SAMPLER_CMP(samplerName)

#define TEXTURE2D_ARGS(textureName, samplerName)                textureName, samplerName
#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)          textureName, samplerName
#define TEXTURECUBE_ARGS(textureName, samplerName)              textureName, samplerName
#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)        textureName, samplerName
#define TEXTURE3D_ARGS(textureName, samplerName)                textureName, samplerName

#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)         textureName, samplerName
#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)   textureName, samplerName
#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)       textureName, samplerName
#define TEXTURECUBE_ARRAY_SHADOW_ARGS(textureName, samplerName) textureName, samplerName

#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod)                      textureName.SampleLevel(samplerName, coord2, lod)
#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                    textureName.SampleBias(samplerName, coord2, bias)
#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, dpdx, dpdy)              textureName.SampleGrad(samplerName, coord2, dpdx, dpdy)
#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                  textureName.Sample(samplerName, float3(coord2, index))
#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)         textureName.SampleLevel(samplerName, float3(coord2, index), lod)
#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)       textureName.SampleBias(samplerName, float3(coord2, index), bias)
#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy) textureName.SampleGrad(samplerName, float3(coord2, index), dpdx, dpdy)
#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                             textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                    textureName.SampleLevel(samplerName, coord3, lod)
#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                  textureName.SampleBias(samplerName, coord3, bias)
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)                textureName.Sample(samplerName, float4(coord3, index))
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)       textureName.SampleLevel(samplerName, float4(coord3, index), lod)
#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)     textureName.SampleBias(samplerName, float4(coord3, index), bias)
#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                               textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                      textureName.SampleLevel(samplerName, coord3, lod)

#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                    textureName.SampleCmpLevelZero(samplerName, (coord3).xy, (coord3).z)
#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)       textureName.SampleCmpLevelZero(samplerName, float3((coord3).xy, index), (coord3).z)
#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                  textureName.SampleCmpLevelZero(samplerName, (coord4).xyz, (coord4).w)
#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)     textureName.SampleCmpLevelZero(samplerName, float4((coord4).xyz, index), (coord4).w)

#define LOAD_TEXTURE2D(textureName, unCoord2)                                   textureName.Load(int3(unCoord2, 0))
#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)                          textureName.Load(int3(unCoord2, lod))
#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)                 textureName.Load(unCoord2, sampleIndex)
#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)                      textureName.Load(int4(unCoord2, index, 0))
#define LOAD_TEXTURE2D_ARRAY_MSAA(textureName, unCoord2, index, sampleIndex)    textureName.Load(int3(unCoord2, index), sampleIndex)
#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod)             textureName.Load(int4(unCoord2, index, lod))
#define LOAD_TEXTURE3D(textureName, unCoord3)                                   textureName.Load(int4(unCoord3, 0))
#define LOAD_TEXTURE3D_LOD(textureName, unCoord3, lod)                          textureName.Load(int4(unCoord3, lod))

#define PLATFORM_SUPPORT_GATHER
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                textureName.Gather(samplerName, coord2)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)   textureName.Gather(samplerName, float3(coord2, index))
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)              textureName.Gather(samplerName, coord3)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index) textureName.Gather(samplerName, float4(coord3, index))
#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)            textureName.GatherRed(samplerName, coord2)
#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherGreen(samplerName, coord2)
#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)           textureName.GatherBlue(samplerName, coord2)
#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherAlpha(samplerName, coord2)

#elif defined(SHADER_API_METAL)

// Initialize arbitrary structure with zero values.
// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
#define ZERO_INITIALIZE(type, name) name = (type)0;
#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }

// Texture util abstraction

#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) textureName.CalculateLevelOfDetail(samplerName, coord2)

// Texture abstraction

#define TEXTURE2D(textureName)                Texture2D textureName
#define TEXTURE2D_ARRAY(textureName)          Texture2DArray textureName
#define TEXTURECUBE(textureName)              TextureCube textureName
#define TEXTURECUBE_ARRAY(textureName)        TextureCubeArray textureName
#define TEXTURE3D(textureName)                Texture3D textureName

#define TEXTURE2D_FLOAT(textureName)          Texture2D_float textureName
#define TEXTURE2D_ARRAY_FLOAT(textureName)    Texture2DArray textureName    // no support to _float on Array, it's being added
#define TEXTURECUBE_FLOAT(textureName)        TextureCube_float textureName
#define TEXTURECUBE_ARRAY_FLOAT(textureName)  TextureCubeArray textureName  // no support to _float on Array, it's being added
#define TEXTURE3D_FLOAT(textureName)          Texture3D_float textureName

#define TEXTURE2D_HALF(textureName)           Texture2D_half textureName
#define TEXTURE2D_ARRAY_HALF(textureName)     Texture2DArray textureName    // no support to _float on Array, it's being added
#define TEXTURECUBE_HALF(textureName)         TextureCube_half textureName
#define TEXTURECUBE_ARRAY_HALF(textureName)   TextureCubeArray textureName  // no support to _float on Array, it's being added
#define TEXTURE3D_HALF(textureName)           Texture3D_half textureName

#define TEXTURE2D_SHADOW(textureName)         TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_SHADOW(textureName)   TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_SHADOW(textureName)       TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_SHADOW(textureName) TEXTURECUBE_ARRAY(textureName)

#define RW_TEXTURE2D(type, textureName)       RWTexture2D<type> textureName
#define RW_TEXTURE2D_ARRAY(type, textureName) RWTexture2DArray<type> textureName
#define RW_TEXTURE3D(type, textureName)       RWTexture3D<type> textureName

#define SAMPLER(samplerName)                  SamplerState samplerName
#define SAMPLER_CMP(samplerName)              SamplerComparisonState samplerName

#define TEXTURE2D_PARAM(textureName, samplerName)                 TEXTURE2D(textureName), SAMPLER(samplerName)
#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)           TEXTURE2D_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_PARAM(textureName, samplerName)               TEXTURECUBE(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)         TEXTURECUBE_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURE3D_PARAM(textureName, samplerName)                 TEXTURE3D(textureName), SAMPLER(samplerName)

#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)          TEXTURE2D(textureName), SAMPLER_CMP(samplerName)
#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)    TEXTURE2D_ARRAY(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)        TEXTURECUBE(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_ARRAY_SHADOW_PARAM(textureName, samplerName)  TEXTURECUBE_ARRAY(textureName), SAMPLER_CMP(samplerName)

#define TEXTURE2D_ARGS(textureName, samplerName)                textureName, samplerName
#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)          textureName, samplerName
#define TEXTURECUBE_ARGS(textureName, samplerName)              textureName, samplerName
#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)        textureName, samplerName
#define TEXTURE3D_ARGS(textureName, samplerName)                textureName, samplerName

#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)         textureName, samplerName
#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)   textureName, samplerName
#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)       textureName, samplerName
#define TEXTURECUBE_ARRAY_SHADOW_ARGS(textureName, samplerName) textureName, samplerName

#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod)                      textureName.SampleLevel(samplerName, coord2, lod)
#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                    textureName.SampleBias(samplerName, coord2, bias)
#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, dpdx, dpdy)              textureName.SampleGrad(samplerName, coord2, dpdx, dpdy)
#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                  textureName.Sample(samplerName, float3(coord2, index))
#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)         textureName.SampleLevel(samplerName, float3(coord2, index), lod)
#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)       textureName.SampleBias(samplerName, float3(coord2, index), bias)
#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy) textureName.SampleGrad(samplerName, float3(coord2, index), dpdx, dpdy)
#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                             textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                    textureName.SampleLevel(samplerName, coord3, lod)
#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                  textureName.SampleBias(samplerName, coord3, bias)
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)                textureName.Sample(samplerName, float4(coord3, index))
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)       textureName.SampleLevel(samplerName, float4(coord3, index), lod)
#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)     textureName.SampleBias(samplerName, float4(coord3, index), bias)
#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                               textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                      textureName.SampleLevel(samplerName, coord3, lod)

#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                    textureName.SampleCmpLevelZero(samplerName, (coord3).xy, (coord3).z)
#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)       textureName.SampleCmpLevelZero(samplerName, float3((coord3).xy, index), (coord3).z)
#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                  textureName.SampleCmpLevelZero(samplerName, (coord4).xyz, (coord4).w)
#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)     textureName.SampleCmpLevelZero(samplerName, float4((coord4).xyz, index), (coord4).w)

#define LOAD_TEXTURE2D(textureName, unCoord2)                                   textureName.Load(int3(unCoord2, 0))
#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)                          textureName.Load(int3(unCoord2, lod))
#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)                 textureName.Load(unCoord2, sampleIndex)
#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)                      textureName.Load(int4(unCoord2, index, 0))
#define LOAD_TEXTURE2D_ARRAY_MSAA(textureName, unCoord2, index, sampleIndex)    textureName.Load(int3(unCoord2, index), sampleIndex)
#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod)             textureName.Load(int4(unCoord2, index, lod))
#define LOAD_TEXTURE3D(textureName, unCoord3)                                   textureName.Load(int4(unCoord3, 0))
#define LOAD_TEXTURE3D_LOD(textureName, unCoord3, lod)                          textureName.Load(int4(unCoord3, lod))

#define PLATFORM_SUPPORT_GATHER
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                textureName.Gather(samplerName, coord2)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)   textureName.Gather(samplerName, float3(coord2, index))
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)              textureName.Gather(samplerName, coord3)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index) textureName.Gather(samplerName, float4(coord3, index))
#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)            textureName.GatherRed(samplerName, coord2)
#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherGreen(samplerName, coord2)
#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)           textureName.GatherBlue(samplerName, coord2)
#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherAlpha(samplerName, coord2)

#elif defined(SHADER_API_VULKAN)
// This file assume SHADER_API_VULKAN is defined
// TODO: This is a straight copy from D3D11.hlsl. Go through all this stuff and adjust where needed.

// Initialize arbitrary structure with zero values.
// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
#define ZERO_INITIALIZE(type, name) name = (type)0;
#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }

// Texture util abstraction

#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) textureName.CalculateLevelOfDetail(samplerName, coord2)

// Texture abstraction

#define TEXTURE2D(textureName)                Texture2D textureName
#define TEXTURE2D_ARRAY(textureName)          Texture2DArray textureName
#define TEXTURECUBE(textureName)              TextureCube textureName
#define TEXTURECUBE_ARRAY(textureName)        TextureCubeArray textureName
#define TEXTURE3D(textureName)                Texture3D textureName

#define TEXTURE2D_FLOAT(textureName)          Texture2D_float textureName
#define TEXTURE2D_ARRAY_FLOAT(textureName)    Texture2DArray textureName    // no support to _float on Array, it's being added
#define TEXTURECUBE_FLOAT(textureName)        TextureCube_float textureName
#define TEXTURECUBE_ARRAY_FLOAT(textureName)  TextureCubeArray textureName  // no support to _float on Array, it's being added
#define TEXTURE3D_FLOAT(textureName)          Texture3D_float textureName

#define TEXTURE2D_HALF(textureName)           Texture2D_half textureName
#define TEXTURE2D_ARRAY_HALF(textureName)     Texture2DArray textureName    // no support to _float on Array, it's being added
#define TEXTURECUBE_HALF(textureName)         TextureCube_half textureName
#define TEXTURECUBE_ARRAY_HALF(textureName)   TextureCubeArray textureName  // no support to _float on Array, it's being added
#define TEXTURE3D_HALF(textureName)           Texture3D_half textureName

#define TEXTURE2D_SHADOW(textureName)         TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_SHADOW(textureName)   TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_SHADOW(textureName)       TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_SHADOW(textureName) TEXTURECUBE_ARRAY(textureName)

#define RW_TEXTURE2D(type, textureName)       RWTexture2D<type> textureName
#define RW_TEXTURE2D_ARRAY(type, textureName) RWTexture2DArray<type> textureName
#define RW_TEXTURE3D(type, textureName)       RWTexture3D<type> textureName

#define SAMPLER(samplerName)                  SamplerState samplerName
#define SAMPLER_CMP(samplerName)              SamplerComparisonState samplerName

#define TEXTURE2D_PARAM(textureName, samplerName)                 TEXTURE2D(textureName), SAMPLER(samplerName)
#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)           TEXTURE2D_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_PARAM(textureName, samplerName)               TEXTURECUBE(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)         TEXTURECUBE_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURE3D_PARAM(textureName, samplerName)                 TEXTURE3D(textureName), SAMPLER(samplerName)

#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)          TEXTURE2D(textureName), SAMPLER_CMP(samplerName)
#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)    TEXTURE2D_ARRAY(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)        TEXTURECUBE(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_ARRAY_SHADOW_PARAM(textureName, samplerName)  TEXTURECUBE_ARRAY(textureName), SAMPLER_CMP(samplerName)

#define TEXTURE2D_ARGS(textureName, samplerName)                textureName, samplerName
#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)          textureName, samplerName
#define TEXTURECUBE_ARGS(textureName, samplerName)              textureName, samplerName
#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)        textureName, samplerName
#define TEXTURE3D_ARGS(textureName, samplerName)                textureName, samplerName

#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)         textureName, samplerName
#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)   textureName, samplerName
#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)       textureName, samplerName
#define TEXTURECUBE_ARRAY_SHADOW_ARGS(textureName, samplerName) textureName, samplerName

#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod)                      textureName.SampleLevel(samplerName, coord2, lod)
#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                    textureName.SampleBias(samplerName, coord2, bias)
#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, dpdx, dpdy)              textureName.SampleGrad(samplerName, coord2, dpdx, dpdy)
#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                  textureName.Sample(samplerName, float3(coord2, index))
#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)         textureName.SampleLevel(samplerName, float3(coord2, index), lod)
#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)       textureName.SampleBias(samplerName, float3(coord2, index), bias)
#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy) textureName.SampleGrad(samplerName, float3(coord2, index), dpdx, dpdy)
#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                             textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                    textureName.SampleLevel(samplerName, coord3, lod)
#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                  textureName.SampleBias(samplerName, coord3, bias)
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)                textureName.Sample(samplerName, float4(coord3, index))
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)       textureName.SampleLevel(samplerName, float4(coord3, index), lod)
#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)     textureName.SampleBias(samplerName, float4(coord3, index), bias)
#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                               textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                      textureName.SampleLevel(samplerName, coord3, lod)

#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                    textureName.SampleCmpLevelZero(samplerName, (coord3).xy, (coord3).z)
#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)       textureName.SampleCmpLevelZero(samplerName, float3((coord3).xy, index), (coord3).z)
#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                  textureName.SampleCmpLevelZero(samplerName, (coord4).xyz, (coord4).w)
#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)     textureName.SampleCmpLevelZero(samplerName, float4((coord4).xyz, index), (coord4).w)

#define LOAD_TEXTURE2D(textureName, unCoord2)                                   textureName.Load(int3(unCoord2, 0))
#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)                          textureName.Load(int3(unCoord2, lod))
#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)                 textureName.Load(unCoord2, sampleIndex)
#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)                      textureName.Load(int4(unCoord2, index, 0))
#define LOAD_TEXTURE2D_ARRAY_MSAA(textureName, unCoord2, index, sampleIndex)    textureName.Load(int3(unCoord2, index), sampleIndex)
#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod)             textureName.Load(int4(unCoord2, index, lod))
#define LOAD_TEXTURE3D(textureName, unCoord3)                                   textureName.Load(int4(unCoord3, 0))
#define LOAD_TEXTURE3D_LOD(textureName, unCoord3, lod)                          textureName.Load(int4(unCoord3, lod))

#define PLATFORM_SUPPORT_GATHER
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                textureName.Gather(samplerName, coord2)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)   textureName.Gather(samplerName, float3(coord2, index))
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)              textureName.Gather(samplerName, coord3)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index) textureName.Gather(samplerName, float4(coord3, index))
#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)            textureName.GatherRed(samplerName, coord2)
#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherGreen(samplerName, coord2)
#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)           textureName.GatherBlue(samplerName, coord2)
#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherAlpha(samplerName, coord2)

#elif defined(SHADER_API_SWITCH)
// This file assume SHADER_API_SWITCH is defined

// Initialize arbitrary structure with zero values.
// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
#define ZERO_INITIALIZE(type, name) name = (type)0;
#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }

// Texture util abstraction

#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) textureName.CalculateLevelOfDetail(samplerName, coord2)

// Texture abstraction

#define TEXTURE2D(textureName)                Texture2D textureName
#define TEXTURE2D_ARRAY(textureName)          Texture2DArray textureName
#define TEXTURECUBE(textureName)              TextureCube textureName
#define TEXTURECUBE_ARRAY(textureName)        TextureCubeArray textureName
#define TEXTURE3D(textureName)                Texture3D textureName

#define TEXTURE2D_FLOAT(textureName)          Texture2D_float textureName
#define TEXTURE2D_ARRAY_FLOAT(textureName)    Texture2DArray textureName    // no support to _float on Array, it's being added
#define TEXTURECUBE_FLOAT(textureName)        TextureCube_float textureName
#define TEXTURECUBE_ARRAY_FLOAT(textureName)  TextureCubeArray textureName  // no support to _float on Array, it's being added
#define TEXTURE3D_FLOAT(textureName)          Texture3D_float textureName

#define TEXTURE2D_HALF(textureName)           Texture2D_half textureName
#define TEXTURE2D_ARRAY_HALF(textureName)     Texture2DArray textureName    // no support to _float on Array, it's being added
#define TEXTURECUBE_HALF(textureName)         TextureCube_half textureName
#define TEXTURECUBE_ARRAY_HALF(textureName)   TextureCubeArray textureName  // no support to _float on Array, it's being added
#define TEXTURE3D_HALF(textureName)           Texture3D_half textureName

#define TEXTURE2D_SHADOW(textureName)         TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_SHADOW(textureName)   TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_SHADOW(textureName)       TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_SHADOW(textureName) TEXTURECUBE_ARRAY(textureName)

#define RW_TEXTURE2D(type, textureName)       RWTexture2D<type> textureName
#define RW_TEXTURE2D_ARRAY(type, textureName) RWTexture2DArray<type> textureName
#define RW_TEXTURE3D(type, textureName)       RWTexture3D<type> textureName

#define SAMPLER(samplerName)                  SamplerState samplerName
#define SAMPLER_CMP(samplerName)              SamplerComparisonState samplerName

#define TEXTURE2D_PARAM(textureName, samplerName)                 TEXTURE2D(textureName), SAMPLER(samplerName)
#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)           TEXTURE2D_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_PARAM(textureName, samplerName)               TEXTURECUBE(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)         TEXTURECUBE_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURE3D_PARAM(textureName, samplerName)                 TEXTURE3D(textureName), SAMPLER(samplerName)

#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)          TEXTURE2D(textureName), SAMPLER_CMP(samplerName)
#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)    TEXTURE2D_ARRAY(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)        TEXTURECUBE(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_ARRAY_SHADOW_PARAM(textureName, samplerName)  TEXTURECUBE_ARRAY(textureName), SAMPLER_CMP(samplerName)

#define TEXTURE2D_ARGS(textureName, samplerName)                textureName, samplerName
#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)          textureName, samplerName
#define TEXTURECUBE_ARGS(textureName, samplerName)              textureName, samplerName
#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)        textureName, samplerName
#define TEXTURE3D_ARGS(textureName, samplerName)                textureName, samplerName

#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)         textureName, samplerName
#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)   textureName, samplerName
#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)       textureName, samplerName
#define TEXTURECUBE_ARRAY_SHADOW_ARGS(textureName, samplerName) textureName, samplerName

#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod)                      textureName.SampleLevel(samplerName, coord2, lod)
#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                    textureName.SampleBias(samplerName, coord2, bias)
#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, dpdx, dpdy)              textureName.SampleGrad(samplerName, coord2, dpdx, dpdy)
#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                  textureName.Sample(samplerName, float3(coord2, index))
#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)         textureName.SampleLevel(samplerName, float3(coord2, index), lod)
#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)       textureName.SampleBias(samplerName, float3(coord2, index), bias)
#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy) textureName.SampleGrad(samplerName, float3(coord2, index), dpdx, dpdy)
#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                             textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                    textureName.SampleLevel(samplerName, coord3, lod)
#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                  textureName.SampleBias(samplerName, coord3, bias)
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)                textureName.Sample(samplerName, float4(coord3, index))
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)       textureName.SampleLevel(samplerName, float4(coord3, index), lod)
#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)     textureName.SampleBias(samplerName, float4(coord3, index), bias)
#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                               textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                      textureName.SampleLevel(samplerName, coord3, lod)

#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                    textureName.SampleCmpLevelZero(samplerName, (coord3).xy, (coord3).z)
#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)       textureName.SampleCmpLevelZero(samplerName, float3((coord3).xy, index), (coord3).z)
#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                  textureName.SampleCmpLevelZero(samplerName, (coord4).xyz, (coord4).w)
#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)     textureName.SampleCmpLevelZero(samplerName, float4((coord4).xyz, index), (coord4).w)

#define LOAD_TEXTURE2D(textureName, unCoord2)                       textureName.Load(int3(unCoord2, 0))
#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)              textureName.Load(int3(unCoord2, lod))
#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)     textureName.Load(unCoord2, sampleIndex)
#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)          textureName.Load(int4(unCoord2, index, 0))
#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod) textureName.Load(int4(unCoord2, index, lod))
#define LOAD_TEXTURE3D(textureName, unCoord3)                       textureName.Load(int4(unCoord3, 0))
#define LOAD_TEXTURE3D_LOD(textureName, unCoord3, lod)              textureName.Load(int4(unCoord3, lod))

#define PLATFORM_SUPPORT_GATHER
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                textureName.Gather(samplerName, coord2)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)   textureName.Gather(samplerName, float3(coord2, index))
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)              textureName.Gather(samplerName, coord3)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index) textureName.Gather(samplerName, float4(coord3, index))
#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)            textureName.GatherRed(samplerName, coord2)
#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherGreen(samplerName, coord2)
#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)           textureName.GatherBlue(samplerName, coord2)
#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherAlpha(samplerName, coord2)

#elif defined(SHADER_API_GLCORE)

// OpenGL 4.1 SM 5.0 https://docs.unity3d.com/Manual/SL-ShaderCompileTargets.html
#if (SHADER_TARGET >= 46)
#define OPENGL4_1_SM5 1
#else
#define OPENGL4_1_SM5 0
#endif

// Initialize arbitrary structure with zero values.
// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
#define ZERO_INITIALIZE(type, name) name = (type)0;
#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }

// Texture util abstraction

#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) textureName.CalculateLevelOfDetail(samplerName, coord2)

// Texture abstraction

#define TEXTURE2D(textureName)                  Texture2D textureName
#define TEXTURE2D_ARRAY(textureName)            Texture2DArray textureName
#define TEXTURECUBE(textureName)                TextureCube textureName
#define TEXTURECUBE_ARRAY(textureName)          TextureCubeArray textureName
#define TEXTURE3D(textureName)                  Texture3D textureName

#define TEXTURE2D_FLOAT(textureName)            TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_FLOAT(textureName)      TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_FLOAT(textureName)          TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_FLOAT(textureName)    TEXTURECUBE_ARRAY(textureName)
#define TEXTURE3D_FLOAT(textureName)            TEXTURE3D(textureName)

#define TEXTURE2D_HALF(textureName)             TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_HALF(textureName)       TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_HALF(textureName)           TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_HALF(textureName)     TEXTURECUBE_ARRAY(textureName)
#define TEXTURE3D_HALF(textureName)             TEXTURE3D(textureName)

#define TEXTURE2D_SHADOW(textureName)           TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_SHADOW(textureName)     TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_SHADOW(textureName)         TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_SHADOW(textureName)   TEXTURECUBE_ARRAY(textureName)

#define RW_TEXTURE2D(type, textureName)         RWTexture2D<type> textureName
#define RW_TEXTURE2D_ARRAY(type, textureName)   RWTexture2DArray<type> textureName
#define RW_TEXTURE3D(type, textureName)         RWTexture3D<type> textureName

#define SAMPLER(samplerName)                    SamplerState samplerName
#define SAMPLER_CMP(samplerName)                SamplerComparisonState samplerName

#define TEXTURE2D_PARAM(textureName, samplerName)                 TEXTURE2D(textureName), SAMPLER(samplerName)
#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)           TEXTURE2D_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_PARAM(textureName, samplerName)               TEXTURECUBE(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)         TEXTURECUBE_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURE3D_PARAM(textureName, samplerName)                 TEXTURE3D(textureName), SAMPLER(samplerName)

#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)          TEXTURE2D(textureName), SAMPLER_CMP(samplerName)
#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)    TEXTURE2D_ARRAY(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)        TEXTURECUBE(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_ARRAY_SHADOW_PARAM(textureName, samplerName)  TEXTURECUBE_ARRAY(textureName), SAMPLER_CMP(samplerName)

#define TEXTURE2D_ARGS(textureName, samplerName)                textureName, samplerName
#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)          textureName, samplerName
#define TEXTURECUBE_ARGS(textureName, samplerName)              textureName, samplerName
#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)        textureName, samplerName
#define TEXTURE3D_ARGS(textureName, samplerName)                textureName, samplerName

#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)         textureName, samplerName
#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)   textureName, samplerName
#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)       textureName, samplerName
#define TEXTURECUBE_ARRAY_SHADOW_ARGS(textureName, samplerName) textureName, samplerName

#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod)                      textureName.SampleLevel(samplerName, coord2, lod)
#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                    textureName.SampleBias(samplerName, coord2, bias)
#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, ddx, ddy)                textureName.SampleGrad(samplerName, coord2, ddx, ddy)
#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                  textureName.Sample(samplerName, float3(coord2, index))
#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)         textureName.SampleLevel(samplerName, float3(coord2, index), lod)
#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)       textureName.SampleBias(samplerName, float3(coord2, index), bias)
#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy) textureName.SampleGrad(samplerName, float3(coord2, index), dpdx, dpdy)
#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                             textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                    textureName.SampleLevel(samplerName, coord3, lod)
#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                  textureName.SampleBias(samplerName, coord3, bias)
#ifdef UNITY_NO_CUBEMAP_ARRAY
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)           ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY)
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)  ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY_LOD)
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, bias) ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY_LOD)
#else
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)           textureName.Sample(samplerName, float4(coord3, index))
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)  textureName.SampleLevel(samplerName, float4(coord3, index), lod)
#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)textureName.SampleBias(samplerName, float4(coord3, index), bias)
#endif
#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                          textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                 textureName.SampleLevel(samplerName, coord3, lod)

#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                   textureName.SampleCmpLevelZero(samplerName, (coord3).xy, (coord3).z)
#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)      textureName.SampleCmpLevelZero(samplerName, float3((coord3).xy, index), (coord3).z)
#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                 textureName.SampleCmpLevelZero(samplerName, (coord4).xyz, (coord4).w)
#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)    textureName.SampleCmpLevelZero(samplerName, float4((coord4).xyz, index), (coord4).w)

#define LOAD_TEXTURE2D(textureName, unCoord2)                                   textureName.Load(int3(unCoord2, 0))
#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)                          textureName.Load(int3(unCoord2, lod))
#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)                 textureName.Load(unCoord2, sampleIndex)
#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)                      textureName.Load(int4(unCoord2, index, 0))
#define LOAD_TEXTURE2D_ARRAY_MSAA(textureName, unCoord2, index, sampleIndex)    textureName.Load(int3(unCoord2, index), sampleIndex)
#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod)             textureName.Load(int4(unCoord2, index, lod))

#if OPENGL4_1_SM5
#define PLATFORM_SUPPORT_GATHER
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                  textureName.Gather(samplerName, coord2)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)     textureName.Gather(samplerName, float3(coord2, index))
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)                textureName.Gather(samplerName, coord3)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)   textureName.Gather(samplerName, float4(coord3, index))
#else
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                  ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURE2D)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)     ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURE2D_ARRAY)
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)                ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURECUBE)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)   ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURECUBE_ARRAY)
#endif

#elif defined(SHADER_API_GLES3)

// GLES 3.1 + AEP shader feature https://docs.unity3d.com/Manual/SL-ShaderCompileTargets.html
#if (SHADER_TARGET >= 40)
#define GLES3_1_AEP 1
#else
#define GLES3_1_AEP 0
#endif

// Initialize arbitrary structure with zero values.
// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
#define ZERO_INITIALIZE(type, name) name = (type)0;
#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }

// Texture util abstraction

#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) textureName.CalculateLevelOfDetail(samplerName, coord2)

// Texture abstraction

#define TEXTURE2D(textureName)                  Texture2D textureName
#define TEXTURE2D_ARRAY(textureName)            Texture2DArray textureName
#define TEXTURECUBE(textureName)                TextureCube textureName
#define TEXTURECUBE_ARRAY(textureName)          TextureCubeArray textureName
#define TEXTURE3D(textureName)                  Texture3D textureName

#define TEXTURE2D_FLOAT(textureName)            Texture2D_float textureName
#define TEXTURE2D_ARRAY_FLOAT(textureName)      Texture2DArray textureName    // no support to _float on Array, it's being added
#define TEXTURECUBE_FLOAT(textureName)          TextureCube_float textureName
#define TEXTURECUBE_ARRAY_FLOAT(textureName)    TextureCubeArray textureName  // no support to _float on Array, it's being added
#define TEXTURE3D_FLOAT(textureName)            Texture3D_float textureName

#define TEXTURE2D_HALF(textureName)             Texture2D_half textureName
#define TEXTURE2D_ARRAY_HALF(textureName)       Texture2DArray textureName    // no support to _float on Array, it's being added
#define TEXTURECUBE_HALF(textureName)           TextureCube_half textureName
#define TEXTURECUBE_ARRAY_HALF(textureName)     TextureCubeArray textureName  // no support to _float on Array, it's being added
#define TEXTURE3D_HALF(textureName)             Texture3D_half textureName

#define TEXTURE2D_SHADOW(textureName)           TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_SHADOW(textureName)     TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_SHADOW(textureName)         TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_SHADOW(textureName)   TEXTURECUBE_ARRAY(textureName)

#if GLES3_1_AEP
#define RW_TEXTURE2D(type, textureName)         RWTexture2D<type> textureName
#define RW_TEXTURE2D_ARRAY(type, textureName)   RWTexture2DArray<type> textureName
#define RW_TEXTURE3D(type, textureName)         RWTexture3D<type> textureName
#else
#define RW_TEXTURE2D(type, textureName)         ERROR_ON_UNSUPPORTED_FUNCTION(RWTexture2D)
#define RW_TEXTURE2D_ARRAY(type, textureName)   ERROR_ON_UNSUPPORTED_FUNCTION(RWTexture2DArray)
#define RW_TEXTURE3D(type, textureName)         ERROR_ON_UNSUPPORTED_FUNCTION(RWTexture3D)
#endif

#define SAMPLER(samplerName)                    SamplerState samplerName
#define SAMPLER_CMP(samplerName)                SamplerComparisonState samplerName

#define TEXTURE2D_PARAM(textureName, samplerName)                 TEXTURE2D(textureName), SAMPLER(samplerName)
#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)           TEXTURE2D_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_PARAM(textureName, samplerName)               TEXTURECUBE(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)         TEXTURECUBE_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURE3D_PARAM(textureName, samplerName)                 TEXTURE3D(textureName), SAMPLER(samplerName)

#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)          TEXTURE2D(textureName), SAMPLER_CMP(samplerName)
#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)    TEXTURE2D_ARRAY(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)        TEXTURECUBE(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_ARRAY_SHADOW_PARAM(textureName, samplerName)  TEXTURECUBE_ARRAY(textureName), SAMPLER_CMP(samplerName)

#define TEXTURE2D_ARGS(textureName, samplerName)                textureName, samplerName
#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)          textureName, samplerName
#define TEXTURECUBE_ARGS(textureName, samplerName)              textureName, samplerName
#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)        textureName, samplerName
#define TEXTURE3D_ARGS(textureName, samplerName)                textureName, samplerName

#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)         textureName, samplerName
#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)   textureName, samplerName
#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)       textureName, samplerName
#define TEXTURECUBE_ARRAY_SHADOW_ARGS(textureName, samplerName) textureName, samplerName

#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod)                      textureName.SampleLevel(samplerName, coord2, lod)
#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                    textureName.SampleBias(samplerName, coord2, bias)
#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, ddx, ddy)                textureName.SampleGrad(samplerName, coord2, ddx, ddy)
#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                  textureName.Sample(samplerName, float3(coord2, index))
#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)         textureName.SampleLevel(samplerName, float3(coord2, index), lod)
#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)       textureName.SampleBias(samplerName, float3(coord2, index), bias)
#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy) textureName.SampleGrad(samplerName, float3(coord2, index), dpdx, dpdy)
#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                             textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                    textureName.SampleLevel(samplerName, coord3, lod)
#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                  textureName.SampleBias(samplerName, coord3, bias)

#ifdef UNITY_NO_CUBEMAP_ARRAY
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)           ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY)
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)  ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY_LOD)
#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY_BIAS)
#else
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)           textureName.Sample(samplerName, float4(coord3, index))
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)  textureName.SampleLevel(samplerName, float4(coord3, index), lod)
#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)textureName.SampleBias(samplerName, float4(coord3, index), bias)
#endif

#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                          textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                 textureName.SampleLevel(samplerName, coord3, lod)

#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                   textureName.SampleCmpLevelZero(samplerName, (coord3).xy, (coord3).z)
#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)      textureName.SampleCmpLevelZero(samplerName, float3((coord3).xy, index), (coord3).z)
#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                 textureName.SampleCmpLevelZero(samplerName, (coord4).xyz, (coord4).w)
#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)    textureName.SampleCmpLevelZero(samplerName, float4((coord4).xyz, index), (coord4).w)

#define LOAD_TEXTURE2D(textureName, unCoord2)                                       textureName.Load(int3(unCoord2, 0))
#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)                              textureName.Load(int3(unCoord2, lod))
#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)                     textureName.Load(unCoord2, sampleIndex)
#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)                          textureName.Load(int4(unCoord2, index, 0))
#define LOAD_TEXTURE2D_ARRAY_MSAA(textureName, unCoord2, index, sampleIndex)        textureName.Load(int3(unCoord2, index), sampleIndex)
#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod)                 textureName.Load(int4(unCoord2, index, lod))
#define LOAD_TEXTURE3D(textureName, unCoord3)                                       textureName.Load(int4(unCoord3, 0))
#define LOAD_TEXTURE3D_LOD(textureName, unCoord3, lod)                              textureName.Load(int4(unCoord3, lod))

#if GLES3_1_AEP
#define PLATFORM_SUPPORT_GATHER
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                  textureName.Gather(samplerName, coord2)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)     textureName.Gather(samplerName, float3(coord2, index))
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)                textureName.Gather(samplerName, coord3)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)   textureName.Gather(samplerName, float4(coord3, index))
#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)              textureName.GatherRed(samplerName, coord2)
#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)            textureName.GatherGreen(samplerName, coord2)
#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)             textureName.GatherBlue(samplerName, coord2)
#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)            textureName.GatherAlpha(samplerName, coord2)
#else
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                  ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURE2D)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)     ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURE2D_ARRAY)
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)                ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURECUBE)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)   ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURECUBE_ARRAY)
#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)              ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_RED_TEXTURE2D)
#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)            ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_GREEN_TEXTURE2D)
#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)             ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_BLUE_TEXTURE2D)
#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)            ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_ALPHA_TEXTURE2D)
#endif

#elif defined(SHADER_API_GLES)

#define uint int

#define rcp(x) 1.0 / (x)
#define ddx_fine ddx
#define ddy_fine ddy
#define asfloat
#define asuint(x) asint(x)
#define f32tof16
#define f16tof32

#define ERROR_ON_UNSUPPORTED_FUNCTION(funcName) #error #funcName is not supported on GLES 2.0

// Initialize arbitrary structure with zero values.
// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
#define ZERO_INITIALIZE(type, name) name = (type)0;
#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }

// Texture util abstraction

#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) #error calculate Level of Detail not supported in GLES2

// Texture abstraction

#define TEXTURE2D(textureName)                          sampler2D textureName
#define TEXTURE2D_ARRAY(textureName)                    samplerCUBE textureName // No support to texture2DArray
#define TEXTURECUBE(textureName)                        samplerCUBE textureName
#define TEXTURECUBE_ARRAY(textureName)                  samplerCUBE textureName // No supoport to textureCubeArray and can't emulate with texture2DArray
#define TEXTURE3D(textureName)                          sampler3D textureName

#define TEXTURE2D_FLOAT(textureName)                    sampler2D_float textureName
#define TEXTURE2D_ARRAY_FLOAT(textureName)              TEXTURECUBE_FLOAT(textureName) // No support to texture2DArray
#define TEXTURECUBE_FLOAT(textureName)                  samplerCUBE_float textureName
#define TEXTURECUBE_ARRAY_FLOAT(textureName)            TEXTURECUBE_FLOAT(textureName) // No support to textureCubeArray
#define TEXTURE3D_FLOAT(textureName)                    sampler3D_float textureName

#define TEXTURE2D_HALF(textureName)                     sampler2D_half textureName
#define TEXTURE2D_ARRAY_HALF(textureName)               TEXTURECUBE_HALF(textureName) // No support to texture2DArray
#define TEXTURECUBE_HALF(textureName)                   samplerCUBE_half textureName
#define TEXTURECUBE_ARRAY_HALF(textureName)             TEXTURECUBE_HALF(textureName) // No support to textureCubeArray
#define TEXTURE3D_HALF(textureName)                     sampler3D_half textureName

#define TEXTURE2D_SHADOW(textureName)                   SHADOW2D_TEXTURE_AND_SAMPLER textureName
#define TEXTURE2D_ARRAY_SHADOW(textureName)             TEXTURECUBE_SHADOW(textureName) // No support to texture array
#define TEXTURECUBE_SHADOW(textureName)                 SHADOWCUBE_TEXTURE_AND_SAMPLER textureName
#define TEXTURECUBE_ARRAY_SHADOW(textureName)           TEXTURECUBE_SHADOW(textureName) // No support to texture array

#define RW_TEXTURE2D(type, textureNam)                  ERROR_ON_UNSUPPORTED_FUNCTION(RWTexture2D)
#define RW_TEXTURE2D_ARRAY(type, textureName)           ERROR_ON_UNSUPPORTED_FUNCTION(RWTexture2DArray)
#define RW_TEXTURE3D(type, textureNam)                  ERROR_ON_UNSUPPORTED_FUNCTION(RWTexture3D)

#define SAMPLER(samplerName)
#define SAMPLER_CMP(samplerName)

#define TEXTURE2D_PARAM(textureName, samplerName)                sampler2D textureName
#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)          samplerCUBE textureName
#define TEXTURECUBE_PARAM(textureName, samplerName)              samplerCUBE textureName
#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)        samplerCUBE textureName
#define TEXTURE3D_PARAM(textureName, samplerName)                sampler3D textureName
#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)         SHADOW2D_TEXTURE_AND_SAMPLER textureName
#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)   SHADOWCUBE_TEXTURE_AND_SAMPLER textureName
#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)       SHADOWCUBE_TEXTURE_AND_SAMPLER textureName

#define TEXTURE2D_ARGS(textureName, samplerName)               textureName
#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)         textureName
#define TEXTURECUBE_ARGS(textureName, samplerName)             textureName
#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)       textureName
#define TEXTURE3D_ARGS(textureName, samplerName)               textureName
#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)        textureName
#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)  textureName
#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)      textureName

#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2) tex2D(textureName, coord2)

#if (SHADER_TARGET >= 30)
#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod) tex2Dlod(textureName, float4(coord2, 0, lod))
#else
// No lod support. Very poor approximation with bias.
#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod) SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, lod)
#endif

#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                       tex2Dbias(textureName, float4(coord2, 0, bias))
#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, ddx, ddy)                   SAMPLE_TEXTURE2D(textureName, samplerName, coord2)
#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                     ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURE2D_ARRAY)
#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)            ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURE2D_ARRAY_LOD)
#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)          ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURE2D_ARRAY_BIAS)
#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy)    ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURE2D_ARRAY_GRAD)
#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                                texCUBE(textureName, coord3)
// No lod support. Very poor approximation with bias.
#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                       SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, lod)
#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                     texCUBEbias(textureName, float4(coord3, bias))
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)                   ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY)
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)          ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY_LOD)
#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)        ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY_BIAS)
#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                                  tex3D(textureName, coord3)
#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                         ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURE3D_LOD)

#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                           SHADOW2D_SAMPLE(textureName, samplerName, coord3)
#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)              ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURE2D_ARRAY_SHADOW)
#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                         SHADOWCUBE_SAMPLE(textureName, samplerName, coord4)
#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)            ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY_SHADOW)

// Not supported. Can't define as error because shader library is calling these functions.
#define LOAD_TEXTURE2D(textureName, unCoord2)                                               half4(0, 0, 0, 0)
#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)                                      half4(0, 0, 0, 0)
#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)                             half4(0, 0, 0, 0)
#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)                                  half4(0, 0, 0, 0)
#define LOAD_TEXTURE2D_ARRAY_MSAA(textureName, unCoord2, index, sampleIndex)                half4(0, 0, 0, 0)
#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod)                         half4(0, 0, 0, 0)
#define LOAD_TEXTURE3D(textureName, unCoord3)                                               ERROR_ON_UNSUPPORTED_FUNCTION(LOAD_TEXTURE3D)
#define LOAD_TEXTURE3D_LOD(textureName, unCoord3, lod)                                      ERROR_ON_UNSUPPORTED_FUNCTION(LOAD_TEXTURE3D_LOD)

// Gather not supported. Fallback to regular texture sampling.
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                  ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURE2D)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)     ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURE2D_ARRAY)
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)                ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURECUBE)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)   ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURECUBE_ARRAY)
#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)              ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_RED_TEXTURE2D)
#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)            ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_GREEN_TEXTURE2D)
#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)             ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_BLUE_TEXTURE2D)
#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)            ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_ALPHA_TEXTURE2D)

#else
#error unsupported shader api
#endif

// default flow control attributes
#ifndef UNITY_BRANCH
#   define UNITY_BRANCH
#endif
#ifndef UNITY_FLATTEN
#   define UNITY_FLATTEN
#endif
#ifndef UNITY_UNROLL
#   define UNITY_UNROLL
#endif
#ifndef UNITY_UNROLLX
#   define UNITY_UNROLLX(_x)
#endif
#ifndef UNITY_LOOP
#   define UNITY_LOOP
#endif

struct VertexData
{
	float4 vertex : POSITION;
	float3 normal : NORMAL;
	float4 tangent : TANGENT;
	float4 color : COLOR;
	float2 uv0 : TEXCOORD0;
	float2 uv1 : TEXCOORD1;
	float2 uv2 : TEXCOORD2;
	float2 uv3 : TEXCOORD3;
	UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct FragmentData
{
	#if defined(UNITY_PASS_SHADOWCASTER)
	V2F_SHADOW_CASTER;
	float2 uv0 : TEXCOORD1;
	float2 uv1 : TEXCOORD2;
	float2 uv2 : TEXCOORD3;
	float2 uv3 : TEXCOORD4;
	float3 worldPos : TEXCOORD5;
	float3 worldNormal : TEXCOORD6;
	float4 worldTangent : TEXCOORD7;
	#else
	float4 pos : SV_POSITION;
	float3 normal : NORMAL;
	float2 uv0 : TEXCOORD0;
	float2 uv1 : TEXCOORD1;
	float2 uv2 : TEXCOORD2;
	float2 uv3 : TEXCOORD3;
	float3 worldPos : TEXCOORD4;
	float3 worldNormal : TEXCOORD5;
	float4 worldTangent : TEXCOORD6;
	float4 lightmapUv : TEXCOORD7;
	float4 vertexColor : TEXCOORD8;
	
	#if !defined(UNITY_PASS_META)
	UNITY_LIGHTING_COORDS(9, 10)
	UNITY_FOG_COORDS(11)
	#endif
	#endif
	
	#if defined(EDITOR_VISUALIZATION)
	float2 vizUV : TEXCOORD9;
	float4 lightCoord : TEXCOORD10;
	#endif
	
	#if defined(NEED_SCREEN_POS)
	float4 screenPos: SCREENPOS;
	#endif
	
	#if defined(EXTRA_V2F_0)
	#if defined(UNITY_PASS_SHADOWCASTER)
	float4 extraV2F0 : TEXCOORD8;
	#else
	#if !defined(UNITY_PASS_META)
	float4 extraV2F0 : TEXCOORD12;
	#else
	#if defined(EDITOR_VISUALIZATION)
	float4 extraV2F0 : TEXCOORD11;
	#else
	float4 extraV2F0 : TEXCOORD9;
	#endif
	#endif
	#endif
	#endif
	#if defined(EXTRA_V2F_1)
	#if defined(UNITY_PASS_SHADOWCASTER)
	float4 extraV2F1 : TEXCOORD9;
	#else
	#if !defined(UNITY_PASS_META)
	float4 extraV2F1 : TEXCOORD13;
	#else
	#if defined(EDITOR_VISUALIZATION)
	float4 extraV2F1 : TEXCOORD14;
	#else
	float4 extraV2F1 : TEXCOORD15;
	#endif
	#endif
	#endif
	#endif
	#if defined(EXTRA_V2F_2)
	#if defined(UNITY_PASS_SHADOWCASTER)
	float4 extraV2F2 : TEXCOORD10;
	#else
	#if !defined(UNITY_PASS_META)
	float4 extraV2F2 : TEXCOORD14;
	#else
	#if defined(EDITOR_VISUALIZATION)
	float4 extraV2F2 : TEXCOORD15
	#else
	float4 extraV2F2 : TEXCOORD16;
	#endif
	#endif
	#endif
	#endif
	
	UNITY_VERTEX_INPUT_INSTANCE_ID
	UNITY_VERTEX_OUTPUT_STEREO
};

struct MeshData
{
	half2 uv0;
	half2 uv1;
	half2 uv2;
	half2 uv3;
	half3 vertexColor;
	half3 normal;
	half3 worldNormal;
	half3 localSpacePosition;
	half3 worldSpacePosition;
	half3 worldSpaceViewDir;
	half3 tangentSpaceViewDir;
	half3 worldSpaceTangent;
	float3 bitangent;
	float3x3 TBNMatrix;
	half3 svdn;
	float4 extraV2F0;
	float4 extraV2F1;
	float4 extraV2F2;
	float4 screenPos;
};

MeshData CreateMeshData(FragmentData i)
{
	MeshData m = (MeshData) 0;
	m.uv0 = i.uv0;
	m.uv1 = i.uv1;
	m.uv2 = i.uv2;
	m.uv3 = i.uv3;
	m.worldNormal = normalize(i.worldNormal);
	m.localSpacePosition = mul(unity_WorldToObject, float4(i.worldPos, 1)).xyz;
	m.worldSpacePosition = i.worldPos;
	m.worldSpaceViewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
	
	#if !defined(UNITY_PASS_SHADOWCASTER)
	m.vertexColor = i.vertexColor;
	m.normal = i.normal;
	m.bitangent = cross(i.worldTangent.xyz, i.worldNormal) * i.worldTangent.w * - 1;
	m.worldSpaceTangent = i.worldTangent.xyz;
	m.TBNMatrix = float3x3(normalize(i.worldTangent.xyz), m.bitangent, m.worldNormal);
	m.tangentSpaceViewDir = mul(m.TBNMatrix, m.worldSpaceViewDir);
	#endif
	
	#if UNITY_SINGLE_PASS_STEREO
	half3 stereoCameraPos = half3((unity_StereoWorldSpaceCameraPos[0]+ unity_StereoWorldSpaceCameraPos[1])*.5);
	m.svdn = normalize(stereoCameraPos - m.worldSpacePosition);
	#else
	m.svdn = m.worldSpaceViewDir;
	#endif
	
	#if defined(EXTRA_V2F_0)
	m.extraV2F0 = i.extraV2F0;
	#endif
	#if defined(EXTRA_V2F_1)
	m.extraV2F1 = i.extraV2F1;
	#endif
	#if defined(EXTRA_V2F_2)
	m.extraV2F2 = i.extraV2F2;
	#endif
	#if defined(NEED_SCREEN_POS)
	m.screenPos = i.screenPos;
	#endif
	
	return m;
}

struct SurfaceData
{
	half3 Albedo;
	half3 Emission;
	int EmissionScaleWithLight;
	half EmissionLightThreshold;
	half Metallic;
	half Smoothness;
	half Occlusion;
	int OcclusionMode;
	half3 Normal;
	half Alpha;
	half Anisotropy;
	half ShadowSharpness;
	half4 RimLight;
	half RimAttenuation;
	half4 RimShadow;
	half SpecularIntensity;
	half SpecularArea;
	half SpecularAlbedoTint;
	half SpecularAnisotropy;
	half SpecularSharpness;
	half Reflectivity;
	half3 BakedReflection;
	int ReflectionBlendMode;
	int EnableReflections;
	half3 OutlineColor;
	int OutlineLightingMode;
};

FragmentData FragData;
SurfaceData o;
MeshData d;
VertexData vD;
float4 FinalColor;

half invLerp(half a, half b, half v)
{
	return (v - a) / (b - a);
}

half getBakedNoise(Texture2D noiseTex, SamplerState noiseTexSampler, half3 p)
{
	half3 i = floor(p); p -= i; p *= p * (3. - 2. * p);
	half2 uv = (p.xy + i.xy + half2(37, 17) * i.z + .5) / 256.;
	uv.y *= -1;
	p.xy = noiseTex.SampleLevel(noiseTexSampler, uv, 0).yx;
	return lerp(p.x, p.y, p.z);
}

half3 TransformObjectToWorld(half3 pos)
{
	return mul(unity_ObjectToWorld, half4(pos, 1)).xyz;
};

// mostly taken from the Amplify shader reference
half2 POM(Texture2D heightMap, SamplerState heightSampler, half2 uvs, half2 dx, half2 dy, half3 normalWorld, half3 viewWorld, half3 viewDirTan, int minSamples, int maxSamples, half parallax, half refPlane, half2 tilling, half2 curv, int index, inout half finalHeight)
{
	half3 result = 0;
	int stepIndex = 0;
	int numSteps = (int)lerp((half)maxSamples, (half)minSamples, saturate(dot(normalWorld, viewWorld)));
	half layerHeight = 1.0 / numSteps;
	half2 plane = parallax * (viewDirTan.xy / viewDirTan.z);
	uvs.xy += refPlane * plane;
	half2 deltaTex = -plane * layerHeight;
	half2 prevTexOffset = 0;
	half prevRayZ = 1.0f;
	half prevHeight = 0.0f;
	half2 currTexOffset = deltaTex;
	half currRayZ = 1.0f - layerHeight;
	half currHeight = 0.0f;
	half intersection = 0;
	half2 finalTexOffset = 0;
	while (stepIndex < numSteps + 1)
	{
		currHeight = SAMPLE_TEXTURE2D_GRAD(heightMap, heightSampler, uvs + currTexOffset, dx, dy).r;
		if (currHeight > currRayZ)
		{
			stepIndex = numSteps + 1;
		}
		else
		{
			stepIndex++;
			prevTexOffset = currTexOffset;
			prevRayZ = currRayZ;
			prevHeight = currHeight;
			currTexOffset += deltaTex;
			currRayZ -= layerHeight;
		}
	}
	int sectionSteps = 2;
	int sectionIndex = 0;
	half newZ = 0;
	half newHeight = 0;
	while (sectionIndex < sectionSteps)
	{
		intersection = (prevHeight - prevRayZ) / (prevHeight - currHeight + currRayZ - prevRayZ);
		finalTexOffset = prevTexOffset +intersection * deltaTex;
		newZ = prevRayZ - intersection * layerHeight;
		newHeight = SAMPLE_TEXTURE2D_GRAD(heightMap, heightSampler, uvs + finalTexOffset, dx, dy).r;
		if (newHeight > newZ)
		{
			currTexOffset = finalTexOffset;
			currHeight = newHeight;
			currRayZ = newZ;
			deltaTex = intersection * deltaTex;
			layerHeight = intersection * layerHeight;
		}
		else
		{
			prevTexOffset = finalTexOffset;
			prevHeight = newHeight;
			prevRayZ = newZ;
			deltaTex = (1 - intersection) * deltaTex;
			layerHeight = (1 - intersection) * layerHeight;
		}
		sectionIndex++;
	}
	finalHeight = newHeight;
	return uvs.xy + finalTexOffset;
}

half remap(half s, half a1, half a2, half b1, half b2)
{
	return b1 + (s - a1) * (b2 - b1) / (a2 - a1);
}

half3 ApplyLut2D(Texture2D LUT2D, SamplerState lutSampler, half3 uvw)
{
	half3 scaleOffset = half3(1.0 / 1024.0, 1.0 / 32.0, 31.0);
	// Strip format where `height = sqrt(width)`
	uvw.z *= scaleOffset.z;
	half shift = floor(uvw.z);
	uvw.xy = uvw.xy * scaleOffset.z * scaleOffset.xy + scaleOffset.xy * 0.5;
	uvw.x += shift * scaleOffset.y;
	uvw.xyz = lerp(
	SAMPLE_TEXTURE2D(LUT2D, lutSampler, uvw.xy).rgb,
	SAMPLE_TEXTURE2D(LUT2D, lutSampler, uvw.xy + half2(scaleOffset.y, 0.0)).rgb,
	uvw.z - shift
	);
	return uvw;
}

half3 AdjustContrast(half3 color, half contrast)
{
	color = saturate(lerp(half3(0.5, 0.5, 0.5), color, contrast));
	return color;
}

half3 AdjustSaturation(half3 color, half saturation)
{
	half3 intensity = dot(color.rgb, half3(0.299, 0.587, 0.114));
	color = lerp(intensity, color.rgb, saturation);
	return color;
}

half3 AdjustBrightness(half3 color, half brightness)
{
	color += brightness;
	return color;
}

struct ParamsLogC
{
	half cut;
	half a, b, c, d, e, f;
};

static const ParamsLogC LogC = {
	0.011361, // cut
	5.555556, // a
	0.047996, // b
	0.244161, // c
	0.386036, // d
	5.301883, // e
	0.092819  // f
	
};

half LinearToLogC_Precise(half x)
{
	half o;
	if (x > LogC.cut)
	o = LogC.c * log10(LogC.a * x + LogC.b) + LogC.d;
	else
	o = LogC.e * x + LogC.f;
	return o;
}

half PositivePow(half base, half power)
{
	return pow(max(abs(base), half(FLT_EPSILON)), power);
}

half3 LinearToLogC(half3 x)
{
	return LogC.c * log10(LogC.a * x + LogC.b) + LogC.d;
}

half3 LinerToSRGB(half3 c)
{
	return c * (c * (c * 0.305306011 + 0.682171111) + 0.012522878);
}

half3 SRGBToLiner(half3 c)
{
	return max(1.055 * PositivePow(c, 0.416666667) - 0.055, 0.0);
}

half3 LogCToLinear(half3 c)
{
	return (pow(10.0, (c - LogC.d) / LogC.c) - LogC.b) / LogC.a;
}

// Specular stuff taken from https://github.com/z3y/shaders/
float pow5(float x)
{
	float x2 = x * x;
	return x2 * x2 * x;
}

float sq(float x)
{
	return x * x;
}

struct Gradient
{
	int type;
	int colorsLength;
	int alphasLength;
	half4 colors[8];
	half2 alphas[8];
};

Gradient NewGradient(int type, int colorsLength, int alphasLength,
half4 colors0, half4 colors1, half4 colors2, half4 colors3, half4 colors4, half4 colors5, half4 colors6, half4 colors7,
half2 alphas0, half2 alphas1, half2 alphas2, half2 alphas3, half2 alphas4, half2 alphas5, half2 alphas6, half2 alphas7)
{
	Gradient g;
	g.type = type;
	g.colorsLength = colorsLength;
	g.alphasLength = alphasLength;
	g.colors[ 0 ] = colors0;
	g.colors[ 1 ] = colors1;
	g.colors[ 2 ] = colors2;
	g.colors[ 3 ] = colors3;
	g.colors[ 4 ] = colors4;
	g.colors[ 5 ] = colors5;
	g.colors[ 6 ] = colors6;
	g.colors[ 7 ] = colors7;
	g.alphas[ 0 ] = alphas0;
	g.alphas[ 1 ] = alphas1;
	g.alphas[ 2 ] = alphas2;
	g.alphas[ 3 ] = alphas3;
	g.alphas[ 4 ] = alphas4;
	g.alphas[ 5 ] = alphas5;
	g.alphas[ 6 ] = alphas6;
	g.alphas[ 7 ] = alphas7;
	return g;
}

half4 SampleGradient(Gradient gradient, half time)
{
	half3 color = gradient.colors[0].rgb;
	UNITY_UNROLL
	for (int c = 1; c < 8; c++)
	{
		half colorPos = saturate((time - gradient.colors[c - 1].w) / (0.00001 + (gradient.colors[c].w - gradient.colors[c - 1].w)) * step(c, (half)gradient.colorsLength - 1));
		color = lerp(color, gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), gradient.type));
	}
	#ifndef UNITY_COLORSPACE_GAMMA
	color = half3(GammaToLinearSpaceExact(color.r), GammaToLinearSpaceExact(color.g), GammaToLinearSpaceExact(color.b));
	#endif
	half alpha = gradient.alphas[0].x;
	UNITY_UNROLL
	for (int a = 1; a < 8; a++)
	{
		half alphaPos = saturate((time - gradient.alphas[a - 1].y) / (0.00001 + (gradient.alphas[a].y - gradient.alphas[a - 1].y)) * step(a, (half)gradient.alphasLength - 1));
		alpha = lerp(alpha, gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), gradient.type));
	}
	return half4(color, alpha);
}

float3 RotateAroundAxis(float3 center, float3 original, float3 u, float angle)
{
	original -= center;
	float C = cos(angle);
	float S = sin(angle);
	float t = 1 - C;
	float m00 = t * u.x * u.x + C;
	float m01 = t * u.x * u.y - S * u.z;
	float m02 = t * u.x * u.z + S * u.y;
	float m10 = t * u.x * u.y + S * u.z;
	float m11 = t * u.y * u.y + C;
	float m12 = t * u.y * u.z - S * u.x;
	float m20 = t * u.x * u.z - S * u.y;
	float m21 = t * u.y * u.z + S * u.x;
	float m22 = t * u.z * u.z + C;
	float3x3 finalMatrix = float3x3(m00, m01, m02, m10, m11, m12, m20, m21, m22);
	return mul(finalMatrix, original) + center;
}

// Map of where features in AudioLink are.
#define ALPASS_DFT                      uint2(0, 4)  //Size: 128, 2
#define ALPASS_WAVEFORM                 uint2(0, 6)  //Size: 128, 16
#define ALPASS_AUDIOLINK                uint2(0, 0)  //Size: 128, 4
#define ALPASS_AUDIOBASS                uint2(0, 0)  //Size: 128, 1
#define ALPASS_AUDIOLOWMIDS             uint2(0, 1)  //Size: 128, 1
#define ALPASS_AUDIOHIGHMIDS            uint2(0, 2)  //Size: 128, 1
#define ALPASS_AUDIOTREBLE              uint2(0, 3)  //Size: 128, 1
#define ALPASS_AUDIOLINKHISTORY         uint2(1, 0)  //Size: 127, 4
#define ALPASS_GENERALVU                uint2(0, 22) //Size: 12, 1
#define ALPASS_GENERALVU_INSTANCE_TIME  uint2(2, 22)
#define ALPASS_GENERALVU_LOCAL_TIME     uint2(3, 22)
#define ALPASS_GENERALVU_NETWORK_TIME   uint2(4, 22)
#define ALPASS_GENERALVU_PLAYERINFO     uint2(6, 22)
#define ALPASS_THEME_COLOR0             uint2(0, 23)
#define ALPASS_THEME_COLOR1             uint2(1, 23)
#define ALPASS_THEME_COLOR2             uint2(2, 23)
#define ALPASS_THEME_COLOR3             uint2(3, 23)
#define ALPASS_CCINTERNAL               uint2(12, 22) //Size: 12, 2
#define ALPASS_CCCOLORS                 uint2(25, 22) //Size: 12, 1 (Note Color #0 is always black, Colors start at 1)
#define ALPASS_CCSTRIP                  uint2(0, 24)  //Size: 128, 1
#define ALPASS_CCLIGHTS                 uint2(0, 25)  //Size: 128, 2
#define ALPASS_AUTOCORRELATOR           uint2(0, 27)  //Size: 128, 1
#define ALPASS_FILTEREDAUDIOLINK        uint2(0, 28)  //Size: 16, 4
#define ALPASS_CHRONOTENSITY            uint2(16, 28) //Size: 8, 4
#define ALPASS_FILTEREDVU               uint2(24, 28) //Size: 4, 4
#define ALPASS_FILTEREDVU_INTENSITY     uint2(24, 28) //Size: 4, 1
#define ALPASS_FILTEREDVU_MARKER        uint2(24, 29) //Size: 4, 1

// Some basic constants to use (Note, these should be compatible with
// future version of AudioLink, but may change.
#define AUDIOLINK_SAMPHIST              3069        // Internal use for algos, do not change.
#define AUDIOLINK_SAMPLEDATA24          2046
#define AUDIOLINK_EXPBINS               24
#define AUDIOLINK_EXPOCT                10
#define AUDIOLINK_ETOTALBINS (AUDIOLINK_EXPBINS * AUDIOLINK_EXPOCT)
#define AUDIOLINK_WIDTH                 128
#define AUDIOLINK_SPS                   48000       // Samples per second
#define AUDIOLINK_ROOTNOTE              0
#define AUDIOLINK_4BAND_FREQFLOOR       0.123
#define AUDIOLINK_4BAND_FREQCEILING     1
#define AUDIOLINK_BOTTOM_FREQUENCY      13.75
#define AUDIOLINK_BASE_AMPLITUDE        2.5
#define AUDIOLINK_DELAY_COEFFICIENT_MIN 0.3
#define AUDIOLINK_DELAY_COEFFICIENT_MAX 0.9
#define AUDIOLINK_DFT_Q                 4.0
#define AUDIOLINK_TREBLE_CORRECTION     5.0
#define AUDIOLINK_4BAND_TARGET_RATE     90.0

// ColorChord constants
#define COLORCHORD_EMAXBIN              192
#define COLORCHORD_NOTE_CLOSEST         3.0
#define COLORCHORD_NEW_NOTE_GAIN        8.0
#define COLORCHORD_MAX_NOTES            10

// We use glsl_mod for most calculations because it behaves better
// on negative numbers, and in some situations actually outperforms
// HLSL's modf().
#ifndef glsl_mod
#define glsl_mod(x, y) (((x) - (y) * floor((x) / (y))))
#endif

uniform float4               _AudioTexture_TexelSize;

#ifdef SHADER_TARGET_SURFACE_ANALYSIS
#define AUDIOLINK_STANDARD_INDEXING
#endif

// Mechanism to index into texture.
#ifdef AUDIOLINK_STANDARD_INDEXING
sampler2D _AudioTexture;
#define AudioLinkData(xycoord) tex2Dlod(_AudioTexture, float4(uint2(xycoord) * _AudioTexture_TexelSize.xy, 0, 0))
#else
uniform Texture2D<float4> _AudioTexture;
#define AudioLinkData(xycoord) _AudioTexture[uint2(xycoord)]
#endif

// Convenient mechanism to read from the AudioLink texture that handles reading off the end of one line and onto the next above it.
float4 AudioLinkDataMultiline(uint2 xycoord)
{
	return AudioLinkData(uint2(xycoord.x % AUDIOLINK_WIDTH, xycoord.y + xycoord.x / AUDIOLINK_WIDTH));
}

// Mechanism to sample between two adjacent pixels and lerp between them, like "linear" supesampling
float4 AudioLinkLerp(float2 xy)
{
	return lerp(AudioLinkData(xy), AudioLinkData(xy + int2(1, 0)), frac(xy.x));
}

// Same as AudioLinkLerp but properly handles multiline reading.
float4 AudioLinkLerpMultiline(float2 xy)
{
	return lerp(AudioLinkDataMultiline(xy), AudioLinkDataMultiline(xy + float2(1, 0)), frac(xy.x));
}

//Tests to see if Audio Link texture is available
bool AudioLinkIsAvailable()
{
	#if !defined(AUDIOLINK_STANDARD_INDEXING)
	int width, height;
	_AudioTexture.GetDimensions(width, height);
	return width > 16;
	#else
	return _AudioTexture_TexelSize.z > 16;
	#endif
}

//Get version of audiolink present in the world, 0 if no audiolink is present
float AudioLinkGetVersion()
{
	int2 dims;
	#if !defined(AUDIOLINK_STANDARD_INDEXING)
	_AudioTexture.GetDimensions(dims.x, dims.y);
	#else
	dims = _AudioTexture_TexelSize.zw;
	#endif
	
	if (dims.x >= 128)
	return AudioLinkData(ALPASS_GENERALVU).x;
	else if (dims.x > 16)
	return 1;
	else
	return 0;
}

// This pulls data from this texture.
#define AudioLinkGetSelfPixelData(xy) _SelfTexture2D[xy]

// Extra utility functions for time.
uint AudioLinkDecodeDataAsUInt(uint2 indexloc)
{
	uint4 rpx = AudioLinkData(indexloc);
	return rpx.r + rpx.g * 1024 + rpx.b * 1048576 + rpx.a * 1073741824;
}

//Note: This will truncate time to every 134,217.728 seconds (~1.5 days of an instance being up) to prevent floating point aliasing.
// if your code will alias sooner, you will need to use a different function.  It should be safe to use this on all times.
float AudioLinkDecodeDataAsSeconds(uint2 indexloc)
{
	uint time = AudioLinkDecodeDataAsUInt(indexloc) & 0x7ffffff;
	//Can't just divide by float.  Bug in Unity's HLSL compiler.
	return float(time / 1000) + float(time % 1000) / 1000.;
}

#define ALDecodeDataAsSeconds(x) AudioLinkDecodeDataAsSeconds(x)
#define ALDecodeDataAsUInt(x) AudioLinkDecodeDataAsUInt(x)

float AudioLinkRemap(float t, float a, float b, float u, float v)
{
	return ((t - a) / (b - a)) * (v - u) + u;
}

float3 AudioLinkHSVtoRGB(float3 HSV)
{
	float3 RGB = 0;
	float C = HSV.z * HSV.y;
	float H = HSV.x * 6;
	float X = C * (1 - abs(fmod(H, 2) - 1));
	if (HSV.y != 0)
	{
		float I = floor(H);
		if (I == 0)
		{
			RGB = float3(C, X, 0);
		}
		else if (I == 1)
		{
			RGB = float3(X, C, 0);
		}
		else if (I == 2)
		{
			RGB = float3(0, C, X);
		}
		else if (I == 3)
		{
			RGB = float3(0, X, C);
		}
		else if (I == 4)
		{
			RGB = float3(X, 0, C);
		}
		else
		{
			RGB = float3(C, 0, X);
		}
	}
	float M = HSV.z - C;
	return RGB + M;
}

float3 AudioLinkCCtoRGB(float bin, float intensity, int rootNote)
{
	float note = bin / AUDIOLINK_EXPBINS;
	
	float hue = 0.0;
	note *= 12.0;
	note = glsl_mod(4. - note + rootNote, 12.0);
	{
		if (note < 4.0)
		{
			//Needs to be YELLOW->RED
			hue = (note) / 24.0;
		}
		else if (note < 8.0)
		{
			//            [4]  [8]
			//Needs to be RED->BLUE
			hue = (note - 2.0) / 12.0;
		}
		else
		{
			//             [8] [12]
			//Needs to be BLUE->YELLOW
			hue = (note - 4.0) / 8.0;
		}
	}
	float val = intensity - 0.1;
	return AudioLinkHSVtoRGB(float3(fmod(hue, 1.0), 1.0, clamp(val, 0.0, 1.0)));
}

// Sample the amplitude of a given frequency in the DFT, supports frequencies in [13.75; 14080].
float4 AudioLinkGetAmplitudeAtFrequency(float hertz)
{
	float note = AUDIOLINK_EXPBINS * log2(hertz / AUDIOLINK_BOTTOM_FREQUENCY);
	return AudioLinkLerpMultiline(ALPASS_DFT + float2(note, 0));
}

// Sample the amplitude of a given semitone in an octave. Octave is in [0; 9] while note is [0; 11].
float AudioLinkGetAmplitudeAtNote(float octave, float note)
{
	float quarter = note * 2.0;
	return AudioLinkLerpMultiline(ALPASS_DFT + float2(octave * AUDIOLINK_EXPBINS + quarter, 0));
}

// Get a reasonable drop-in replacement time value for _Time.y with the
// given chronotensity index [0; 7] and AudioLink band [0; 3].
float AudioLinkGetChronoTime(uint index, uint band)
{
	return (AudioLinkDecodeDataAsUInt(ALPASS_CHRONOTENSITY + uint2(index, band))) / 100000.0;
}

// Get a chronotensity value in the interval [0; 1], modulated by the speed input,
// with the given chronotensity index [0; 7] and AudioLink band [0; 3].
float AudioLinkGetChronoTimeNormalized(uint index, uint band, float speed)
{
	return frac(AudioLinkGetChronoTime(index, band) * speed);
}

// Get a chronotensity value in the interval [0; interval], modulated by the speed input,
// with the given chronotensity index [0; 7] and AudioLink band [0; 3].
float AudioLinkGetChronoTimeInterval(uint index, uint band, float speed, float interval)
{
	return AudioLinkGetChronoTimeNormalized(index, band, speed) * interval;
}
half D_GGX(half NoH, half roughness)
{
	half a = NoH * roughness;
	half k = roughness / (1.0 - NoH * NoH + a * a);
	return k * k * (1.0 / UNITY_PI);
}

half D_GGX_Anisotropic(half NoH, const half3 h, const half3 t, const half3 b, half at, half ab)
{
	half ToH = dot(t, h);
	half BoH = dot(b, h);
	half a2 = at * ab;
	half3 v = half3(ab * ToH, at * BoH, a2 * NoH);
	half v2 = dot(v, v);
	half w2 = a2 / v2;
	return a2 * w2 * w2 * (1.0 / UNITY_PI);
}

half V_SmithGGXCorrelated(half NoV, half NoL, half roughness)
{
	half a2 = roughness * roughness;
	half GGXV = NoL * sqrt(NoV * NoV * (1.0 - a2) + a2);
	half GGXL = NoV * sqrt(NoL * NoL * (1.0 - a2) + a2);
	return 0.5 / (GGXV + GGXL);
}

half3 F_Schlick(half u, half3 f0)
{
	return f0 + (1.0 - f0) * pow(1.0 - u, 5.0);
}

half3 F_Schlick(half3 f0, half f90, half VoH)
{
	// Schlick 1994, "An Inexpensive BRDF Model for Physically-Based Rendering"
	return f0 + (f90 - f0) * pow(1.0 - VoH, 5);
}

half3 fresnel(half3 f0, half LoH)
{
	half f90 = saturate(dot(f0, half(50.0 / 3).xxx));
	return F_Schlick(f0, f90, LoH);
}

half Fd_Burley(half perceptualRoughness, half NoV, half NoL, half LoH)
{
	// Burley 2012, "Physically-Based Shading at Disney"
	half f90 = 0.5 + 2.0 * perceptualRoughness * LoH * LoH;
	half lightScatter = F_Schlick(1.0, f90, NoL);
	half viewScatter = F_Schlick(1.0, f90, NoV);
	return lightScatter * viewScatter;
}

half3 getBoxProjection(half3 direction, half3 position, half4 cubemapPosition, half3 boxMin, half3 boxMax)
{
	#if defined(UNITY_SPECCUBE_BOX_PROJECTION) && !defined(UNITY_PBS_USE_BRDF2) || defined(FORCE_BOX_PROJECTION)
	if (cubemapPosition.w > 0)
	{
		half3 factors = ((direction > 0 ? boxMax : boxMin) - position) / direction;
		half scalar = min(min(factors.x, factors.y), factors.z);
		direction = direction * scalar + (position - cubemapPosition.xyz);
	}
	#endif
	
	return direction;
}

half3 getEnvReflection(half3 worldSpaceViewDir, half3 worldSpacePosition, half3 normal, half smoothness, int mip)
{
	half3 env = 0;
	half3 reflDir = reflect(worldSpaceViewDir, normal);
	half perceptualRoughness = 1 - smoothness;
	half rough = perceptualRoughness * perceptualRoughness;
	reflDir = lerp(reflDir, normal, rough * rough);
	
	half3 reflectionUV1 = getBoxProjection(reflDir, worldSpacePosition, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin.xyz, unity_SpecCube0_BoxMax.xyz);
	half4 probe0 = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectionUV1, mip);
	half3 probe0sample = DecodeHDR(probe0, unity_SpecCube0_HDR);
	
	half3 indirectSpecular;
	half interpolator = unity_SpecCube0_BoxMin.w;
	
	UNITY_BRANCH
	if (interpolator < 0.99999)
	{
		half3 reflectionUV2 = getBoxProjection(reflDir, worldSpacePosition, unity_SpecCube1_ProbePosition, unity_SpecCube1_BoxMin.xyz, unity_SpecCube1_BoxMax.xyz);
		half4 probe1 = UNITY_SAMPLE_TEXCUBE_SAMPLER_LOD(unity_SpecCube1, unity_SpecCube0, reflectionUV2, mip);
		half3 probe1sample = DecodeHDR(probe1, unity_SpecCube1_HDR);
		indirectSpecular = lerp(probe1sample, probe0sample, interpolator);
	}
	else
	{
		indirectSpecular = probe0sample;
	}
	
	env = indirectSpecular;
	return env;
}

half3 EnvBRDFMultiscatter(half2 dfg, half3 f0)
{
	return lerp(dfg.xxx, dfg.yyy, f0);
}

half3 EnvBRDFApprox(half perceptualRoughness, half NoV, half3 f0)
{
	half g = 1 - perceptualRoughness;
	//https://blog.selfshadow.com/publications/s2013-shading-course/lazarov/s2013_pbs_black_ops_2_notes.pdf
	half4 t = half4(1 / 0.96, 0.475, (0.0275 - 0.25 * 0.04) / 0.96, 0.25);
	t *= half4(g, g, g, g);
	t += half4(0, 0, (0.015 - 0.75 * 0.04) / 0.96, 0.75);
	half a0 = t.x * min(t.y, exp2(-9.28 * NoV)) + t.z;
	half a1 = t.w;
	return saturate(lerp(a0, a1, f0));
}

half GSAA_Filament(half3 worldNormal, half perceptualRoughness, half inputVariance, half threshold)
{
	// Kaplanyan 2016, "Stable specular highlights"
	// Tokuyoshi 2017, "Error Reduction and Simplification for Shading Anti-Aliasing"
	// Tokuyoshi and Kaplanyan 2019, "Improved Geometric Specular Antialiasing"
	
	// This implementation is meant for deferred rendering in the original paper but
	// we use it in forward rendering as well (as discussed in Tokuyoshi and Kaplanyan
	// 2019). The main reason is that the forward version requires an expensive transform
	// of the half vector by the tangent frame for every light. This is therefore an
	// approximation but it works well enough for our needs and provides an improvement
	// over our original implementation based on Vlachos 2015, "Advanced VR Rendering".
	
	half3 du = ddx(worldNormal);
	half3 dv = ddy(worldNormal);
	
	half variance = inputVariance * (dot(du, du) + dot(dv, dv));
	
	half roughness = perceptualRoughness * perceptualRoughness;
	half kernelRoughness = min(2.0 * variance, threshold);
	half squareRoughness = saturate(roughness * roughness + kernelRoughness);
	
	return sqrt(sqrt(squareRoughness));
}

// w0, w1, w2, and w3 are the four cubic B-spline basis functions
half w0(half a)
{
	//    return (1.0f/6.0f)*(-a*a*a + 3.0f*a*a - 3.0f*a + 1.0f);
	return (1.0f / 6.0f) * (a * (a * (-a + 3.0f) - 3.0f) + 1.0f);   // optimized
	
}

half w1(half a)
{
	//    return (1.0f/6.0f)*(3.0f*a*a*a - 6.0f*a*a + 4.0f);
	return (1.0f / 6.0f) * (a * a * (3.0f * a - 6.0f) + 4.0f);
}

half w2(half a)
{
	//    return (1.0f/6.0f)*(-3.0f*a*a*a + 3.0f*a*a + 3.0f*a + 1.0f);
	return (1.0f / 6.0f) * (a * (a * (-3.0f * a + 3.0f) + 3.0f) + 1.0f);
}

half w3(half a)
{
	return (1.0f / 6.0f) * (a * a * a);
}

// g0 and g1 are the two amplitude functions
half g0(half a)
{
	return w0(a) + w1(a);
}

half g1(half a)
{
	return w2(a) + w3(a);
}

// h0 and h1 are the two offset functions
half h0(half a)
{
	// note +0.5 offset to compensate for CUDA linear filtering convention
	return -1.0f + w1(a) / (w0(a) + w1(a)) + 0.5f;
}

half h1(half a)
{
	return 1.0f + w3(a) / (w2(a) + w3(a)) + 0.5f;
}

//https://ndotl.wordpress.com/2018/08/29/baking-artifact-free-lightmaps
half3 tex2DFastBicubicLightmap(half2 uv, inout half4 bakedColorTex)
{
	#if !defined(PLAT_QUEST) && defined(BICUBIC_LIGHTMAP)
	half width;
	half height;
	unity_Lightmap.GetDimensions(width, height);
	half x = uv.x * width;
	half y = uv.y * height;
	
	x -= 0.5f;
	y -= 0.5f;
	half px = floor(x);
	half py = floor(y);
	half fx = x - px;
	half fy = y - py;
	
	// note: we could store these functions in a lookup table texture, but maths is cheap
	half g0x = g0(fx);
	half g1x = g1(fx);
	half h0x = h0(fx);
	half h1x = h1(fx);
	half h0y = h0(fy);
	half h1y = h1(fy);
	
	half4 r = g0(fy) * (g0x * UNITY_SAMPLE_TEX2D(unity_Lightmap, (half2(px + h0x, py + h0y) * 1.0f / width)) +
	g1x * UNITY_SAMPLE_TEX2D(unity_Lightmap, (half2(px + h1x, py + h0y) * 1.0f / width))) +
	g1(fy) * (g0x * UNITY_SAMPLE_TEX2D(unity_Lightmap, (half2(px + h0x, py + h1y) * 1.0f / width)) +
	g1x * UNITY_SAMPLE_TEX2D(unity_Lightmap, (half2(px + h1x, py + h1y) * 1.0f / width)));
	bakedColorTex = r;
	return DecodeLightmap(r);
	#else
	bakedColorTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, uv);
	return DecodeLightmap(bakedColorTex);
	#endif
}

half3 GetSpecularHighlights(half3 worldNormal, half3 lightColor, half3 lightDirection, half3 f0, half3 viewDir, half clampedRoughness, half NoV, half3 energyCompensation)
{
	half3 halfVector = Unity_SafeNormalize(lightDirection + viewDir);
	
	half NoH = saturate(dot(worldNormal, halfVector));
	half NoL = saturate(dot(worldNormal, lightDirection));
	half LoH = saturate(dot(lightDirection, halfVector));
	
	half3 F = F_Schlick(LoH, f0);
	half D = D_GGX(NoH, clampedRoughness);
	half V = V_SmithGGXCorrelated(NoV, NoL, clampedRoughness);
	
	#ifndef UNITY_PBS_USE_BRDF2
	F *= energyCompensation;
	#endif
	
	return max(0, (D * V) * F) * lightColor * NoL * UNITY_PI;
}

#ifdef DYNAMICLIGHTMAP_ON
half3 getRealtimeLightmap(half2 uv, half3 worldNormal)
{
	half2 realtimeUV = uv;
	half4 bakedCol = UNITY_SAMPLE_TEX2D(unity_DynamicLightmap, realtimeUV);
	half3 realtimeLightmap = DecodeRealtimeLightmap(bakedCol);
	
	#ifdef DIRLIGHTMAP_COMBINED
	half4 realtimeDirTex = UNITY_SAMPLE_TEX2D_SAMPLER(unity_DynamicDirectionality, unity_DynamicLightmap, realtimeUV);
	realtimeLightmap += DecodeDirectionalLightmap(realtimeLightmap, realtimeDirTex, worldNormal);
	#endif
	
	return realtimeLightmap;
}
#endif

half computeSpecularAO(half NoV, half ao, half roughness)
{
	return clamp(pow(NoV + ao, exp2(-16.0 * roughness - 1.0)) - 1.0 + ao, 0.0, 1.0);
}

half shEvaluateDiffuseL1Geomerics_local(half L0, half3 L1, half3 n)
{
	// average energy
	half R0 = L0;
	
	// avg direction of incoming light
	half3 R1 = 0.5f * L1;
	
	// directional brightness
	half lenR1 = length(R1);
	
	// linear angle between normal and direction 0-1
	//half q = 0.5f * (1.0f + dot(R1 / lenR1, n));
	//half q = dot(R1 / lenR1, n) * 0.5 + 0.5;
	half q = dot(normalize(R1), n) * 0.5 + 0.5;
	q = saturate(q); // Thanks to ScruffyRuffles for the bug identity.
	
	// power for q
	// lerps from 1 (linear) to 3 (cubic) based on directionality
	half p = 1.0f + 2.0f * lenR1 / R0;
	
	// dynamic range constant
	// should vary between 4 (highly directional) and 0 (ambient)
	half a = (1.0f - lenR1 / R0) / (1.0f + lenR1 / R0);
	
	return R0 * (a + (1.0f - a) * (p + 1.0f) * pow(q, p));
}

TEXTURE2D(_Ramp);
SAMPLER(sampler_Ramp);
TEXTURECUBE(_BakedCubemap);
SAMPLER(sampler_BakedCubemap);

half3 getReflectionUV(half3 direction, half3 position, half4 cubemapPosition, half3 boxMin, half3 boxMax)
{
	#if UNITY_SPECCUBE_BOX_PROJECTION
	if (cubemapPosition.w > 0) {
		half3 factors = ((direction > 0 ? boxMax : boxMin) - position) / direction;
		half scalar = min(min(factors.x, factors.y), factors.z);
		direction = direction * scalar + (position - cubemapPosition);
	}
	#endif
	return direction;
}

half3 calcReflView(half3 viewDir, half3 normal)
{
	return reflect(-viewDir, normal);
}

half3 calcStereoViewDir(half3 worldPos)
{
	#if UNITY_SINGLE_PASS_STEREO
	half3 cameraPos = half3((unity_StereoWorldSpaceCameraPos[0]+ unity_StereoWorldSpaceCameraPos[1])*.5);
	#else
	half3 cameraPos = _WorldSpaceCameraPos;
	#endif
	half3 viewDir = cameraPos - worldPos;
	return normalize(viewDir);
}

half4 calcRamp(half NdL, half attenuation, half occlusion, int occlusionMode)
{
	half remapRamp;
	remapRamp = NdL * 0.5 + 0.5;
	remapRamp *= lerp(1, occlusion, occlusionMode);
	#if defined(UNITY_PASS_FORWARDBASE)
	remapRamp *= attenuation;
	#endif
	half4 ramp = SAMPLE_TEXTURE2D(_Ramp, sampler_Ramp, half2(remapRamp, 0));
	return ramp;
}

half4 calcDiffuse(half attenuation, half3 albedo, half3 indirectDiffuse, half3 lightCol, half4 ramp)
{
	half4 diffuse;
	half4 indirect = indirectDiffuse.xyzz;
	
	half grayIndirect = dot(indirectDiffuse, float3(1,1,1));
	half attenFactor = lerp(attenuation, 1, smoothstep(0, 0.2, grayIndirect));
	
	diffuse = ramp * attenFactor * half4(lightCol, 1) + indirect;
	diffuse = albedo.xyzz * diffuse;
	return diffuse;
}

half2 calcMatcapUV(half3 worldUp, half3 viewDirection, half3 normalDirection)
{
	half3 worldViewUp = normalize(worldUp - viewDirection * dot(viewDirection, worldUp));
	half3 worldViewRight = normalize(cross(viewDirection, worldViewUp));
	half2 matcapUV = half2(dot(worldViewRight, normalDirection), dot(worldViewUp, normalDirection)) * 0.5 + 0.5;
	return matcapUV;
}

half3 calcIndirectSpecular(half lightAttenuation, MeshData d, SurfaceData o, half roughness, half3 reflDir, half3 indirectLight, float3 fresnel, half4 ramp)
{//This function handls Unity style reflections, Matcaps, and a baked in fallback cubemap.
	half3 spec = half3(0,0,0);
	
	UNITY_BRANCH
	if (!o.EnableReflections) {
		spec = 0;
	} else if(any(o.BakedReflection.rgb)) {
		spec = o.BakedReflection;
		if(o.ReflectionBlendMode != 1)
		{
			spec *= (indirectLight + (_LightColor0 * lightAttenuation) * 0.5);
		}
	} else
	{
		#if defined(UNITY_PASS_FORWARDBASE) //Indirect PBR specular should only happen in the forward base pass. Otherwise each extra light adds another indirect sample, which could mean you're getting too much light.
		half3 reflectionUV1 = getReflectionUV(reflDir, d.worldSpacePosition, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax);
		half4 probe0 = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectionUV1, roughness * UNITY_SPECCUBE_LOD_STEPS);
		half3 probe0sample = DecodeHDR(probe0, unity_SpecCube0_HDR);
		
		half3 indirectSpecular;
		half interpolator = unity_SpecCube0_BoxMin.w;
		
		UNITY_BRANCH
		if (interpolator < 0.99999)
		{
			half3 reflectionUV2 = getReflectionUV(reflDir, d.worldSpacePosition, unity_SpecCube1_ProbePosition, unity_SpecCube1_BoxMin, unity_SpecCube1_BoxMax);
			half4 probe1 = UNITY_SAMPLE_TEXCUBE_SAMPLER_LOD(unity_SpecCube1, unity_SpecCube0, reflectionUV2, roughness * UNITY_SPECCUBE_LOD_STEPS);
			half3 probe1sample = DecodeHDR(probe1, unity_SpecCube1_HDR);
			indirectSpecular = lerp(probe1sample, probe0sample, interpolator);
		}
		else
		{
			indirectSpecular = probe0sample;
		}
		
		if (!any(indirectSpecular))
		{
			indirectSpecular = SAMPLE_TEXTURECUBE_LOD(_BakedCubemap, sampler_BakedCubemap, reflDir, roughness * UNITY_SPECCUBE_LOD_STEPS);
			indirectSpecular *= indirectLight;
		}
		spec = indirectSpecular * fresnel;
		#endif
	}
	// else if(_ReflectionMode == 1) //Baked Cubemap
	// {
	//     half3 indirectSpecular = SAMPLE_TEXTURECUBE_LOD(_BakedCubemap, sampler_BakedCubemap, reflDir, roughness * UNITY_SPECCUBE_LOD_STEPS);
	//     spec = indirectSpecular * fresnel;
	
	//     if(_ReflectionBlendMode != 1)
	//     {
	//         spec *= (indirectLight + (_LightColor0 * lightAttenuation) * 0.5);
	//     }
	// }
	// else if (_ReflectionMode == 2) //Matcap
	// {
	//     half3 upVector = half3(0,1,0);
	//     half2 remapUV = calcMatcapUV(upVector, d.worldSpaceViewDir, o.Normal);
	//     spec = SAMPLE_TEXTURE2D_LOD(_Matcap, remapUV, (1-roughness) * UNITY_SPECCUBE_LOD_STEPS) * _MatcapTint;
	
	//     if(_ReflectionBlendMode != 1)
	//     {
	//         spec *= (indirectLight + (_LightColor0 * lightAttenuation) * 0.5);
	//     }
	
	//     spec *= lerp(1, o.Albedo, _MatcapTintToDiffuse);
	// }
	return spec;
}

half3 calcDirectSpecular(MeshData d, SurfaceData o, float lightNoL, float NoH, float NoV, float lightLoH, half3 lightColor, half3 lightHalfVector, half anisotropy)
{
	half specularIntensity = o.SpecularIntensity;
	half3 specular = half3(0,0,0);
	half smoothness = max(0.01, (o.SpecularArea));
	smoothness *= 1.7 - 0.7 * smoothness;
	
	float rough = max(smoothness * smoothness, 0.0045);
	float Dn = D_GGX(NoH, rough);
	float3 F = 1-F_Schlick(lightLoH, 0);
	float V = V_SmithGGXCorrelated(NoV, lightNoL, rough);
	float3 directSpecularNonAniso = max(0, (Dn * V) * F);
	
	anisotropy *= saturate(5.0 * smoothness);
	float at = max(rough * (1.0 + anisotropy), 0.001);
	float ab = max(rough * (1.0 - anisotropy), 0.001);
	float D = D_GGX_Anisotropic(NoH, lightHalfVector, d.worldSpaceTangent, d.bitangent, at, ab);
	float3 directSpecularAniso = max(0, (D * V) * F);
	
	specular = lerp(directSpecularNonAniso, directSpecularAniso, saturate(abs(anisotropy * 100)));
	specular = lerp(specular, smoothstep(0.5, 0.51, specular), o.SpecularSharpness) * 3 * lightColor.xyz * specularIntensity; // Multiply by 3 to bring up to brightness of standard
	specular *= lerp(1, o.Albedo, o.SpecularAlbedoTint);
	return specular;
}

half4 calcReflectionBlending(SurfaceData o, half reflectivity, half4 col, half3 indirectSpecular)
{
	if (o.ReflectionBlendMode == 0) { // Additive
	col += indirectSpecular.xyzz * reflectivity;
	return col;
} else if (o.ReflectionBlendMode == 1) { //Multiplicitive
col = lerp(col, col * indirectSpecular.xyzz, reflectivity);
return col;
} else if(o.ReflectionBlendMode == 2) { //Subtractive
col -= indirectSpecular.xyzz * reflectivity;
return col;
}
return col;
}

half4 calcEmission(SurfaceData o, half lightAvg)
{
#if defined(UNITY_PASS_FORWARDBASE) // Emission only in Base Pass, and vertex lights
float4 emission = 0;
emission = half4(o.Emission, 1);

float4 scaledEmission = emission * saturate(smoothstep(1 - o.EmissionLightThreshold, 1 + o.EmissionLightThreshold, 1 - lightAvg));
float4 em = lerp(scaledEmission, emission, o.EmissionScaleWithLight);

// em.rgb = rgb2hsv(em.rgb);
// em.x += fmod(_Hue, 360);
// em.y = saturate(em.y * _Saturation);
// em.z *= _Value;
// em.rgb = hsv2rgb(em.rgb);

return em;
#else
return 0;
#endif
}

#if defined(NEED_DEPTH)
UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
#endif

half _ShadowSharpness;
half _OcclusionStrength;
half _BumpScale;
half _DetailNormalScale;
half _FlipDetailNormalY;
half _OutlineAlbedoTint;
half _OutlineWidth;
half _SpecularIntensity;
half _SpecularRoughness;
half _SpecularSharpness;
half _SpecularAnisotropy;
half _SpecularAlbedoTint;
half _Smoothness;
half _Metallic;
half _ReflectionAnisotropy;
half _MatcapBlur;
half _MatcapTintToDiffuse;
half _ReflectivityLevel;
half _EmissionTintToDiffuse;
half _EmissionScaleWithLightSensitivity;
half _RimIntensity;
half _RimAlbedoTint;
half _RimEnvironmentTint;
half _RimAttenuation;
half _RimRange;
half _RimThreshold;
half _RimSharpness;
half _ShadowRimRange;
half _ShadowRimThreshold;
half _ShadowRimSharpness;
half _ShadowRimAlbedoTint;
half2 GLOBAL_uv;
half3 GLOBAL_pixelNormal;
half4 _Color;
half4 _DetailNormalMap_ST;
half4 _OutlineColor;
half4 _MetallicRemap;
half4 _SmoothnessRemap;
half4 _MetallicGlossMap_TexelSize;
half4 _ALEmissionColor;
half4 _ALPackedRedColor;
half4 _ALPackedGreenColor;
half4 _ALPackedBlueColor;
half4 _EmissionColor;
half4 _RimTint;
half4 _ShadowRimTint;
float4 _MainTex_ST;
int _TintByVertexColor;
TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);
int _OcclusionMode;
TEXTURE2D(_OcclusionMap);
int _FlipBumpY;
int _DetailNormalsUVSet;
int _DetailNormalUVSet;
TEXTURE2D(_BumpMap);
SAMPLER(sampler_BumpMap);
TEXTURE2D(_DetailNormalMap);
SAMPLER(sampler_DetailNormalMap);
TEXTURE2D(_DetailNormalsMask);
SAMPLER(sampler_DetailNormalsMask);
int _OutlineLightingMode;
TEXTURE2D(_OutlineMask);
SAMPLER(sampler_OutlineMask);
int _SpecularMapUVSet;
TEXTURE2D(_SpecularMap);
int _ReflectionMode;
int _ReflectionBlendMode;
int _RoughnessMode;
TEXTURE2D(_Matcap);
SAMPLER(sampler_Matcap);
TEXTURE2D(_MetallicGlossMap);
TEXTURE2D(_ReflectivityMask);
int _ALMode;
int _ALBand;
int _ALGradientOnRed;
int _ALGradientOnGreen;
int _ALGradientOnBlue;
int _ALUVWidth;
int _ALMapUVSet;
TEXTURE2D(_ALMap);
SAMPLER(sampler_ALMap);
int _EmissionScaleWithLight;
TEXTURE2D(_EmissionMap);

void ToonOutlineVertex() {
#if defined(PASS_OUTLINE)
half mask = SAMPLE_TEXTURE2D_LOD(_OutlineMask, sampler_OutlineMask, vD.uv0, 0);
half3 width = mask * _OutlineWidth * .01;
width *= min(distance(mul(unity_ObjectToWorld, vD.vertex), _WorldSpaceCameraPos) * 3, 1);
vD.vertex.xyz += vD.normal.xyz * width;
#endif
}

void ToonFragment() {
half2 uv = d.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
GLOBAL_uv = uv;
half3 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, GLOBAL_uv).rgb;
albedo *= _Color;
if (_TintByVertexColor) {
albedo *= d.vertexColor.rgb;
}
o.Albedo = albedo;
o.ShadowSharpness = _ShadowSharpness;
}

void ToonOcclusionFragment() {
half occlusion = SAMPLE_TEXTURE2D(_OcclusionMap, sampler_MainTex, GLOBAL_uv).r;
o.Occlusion = lerp(1, occlusion, _OcclusionStrength);
o.OcclusionMode = _OcclusionMode;
}

void ToonNormalsFragment() {
half4 normalTex = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, GLOBAL_uv);
if (_FlipBumpY)
{
normalTex.y = 1 - normalTex.y;
}
half3 normal = UnpackScaleNormal(normalTex, _BumpScale);

o.Normal = BlendNormals(o.Normal, normal);

half2 detailUV = 0;
switch (_DetailNormalsUVSet) {
case 0: detailUV = d.uv0; break;
case 1: detailUV = d.uv1; break;
case 2: detailUV = d.uv2; break;
case 3: detailUV = d.uv3; break;
}
detailUV = detailUV * _DetailNormalMap_ST.xy + _DetailNormalMap_ST.zw;
half4 detailNormalTex = SAMPLE_TEXTURE2D(_DetailNormalMap, sampler_DetailNormalMap, detailUV);
if (_FlipDetailNormalY)
{
detailNormalTex.y = 1 - detailNormalTex.y;
}

half2 detailMaskUV = 0;
switch (_DetailNormalUVSet) {
case 0: detailMaskUV = d.uv0; break;
case 1: detailMaskUV = d.uv1; break;
case 2: detailMaskUV = d.uv2; break;
case 3: detailMaskUV = d.uv3; break;
}
half detailMask = SAMPLE_TEXTURE2D(_DetailNormalsMask, sampler_MainTex, GLOBAL_uv).r;

half3 detailNormal = UnpackScaleNormal(detailNormalTex, _DetailNormalScale);

o.Normal = lerp(o.Normal, BlendNormals(o.Normal, detailNormal), detailMask);

half3 properNormal = normalize(o.Normal.x * d.worldSpaceTangent.xyz + o.Normal.y * d.bitangent.xyz + o.Normal.z * d.worldNormal.xyz);
d.worldSpaceTangent.xyz = cross(d.bitangent.xyz, properNormal);
d.bitangent.xyz = cross(properNormal, d.worldSpaceTangent.xyz);
d.TBNMatrix = float3x3(normalize(d.worldSpaceTangent.xyz), d.bitangent, d.worldNormal);
GLOBAL_pixelNormal = properNormal;
}

void ToonOutlineFragment() {
o.OutlineColor = lerp(_OutlineColor, _OutlineColor * o.Albedo, _OutlineAlbedoTint);
o.OutlineLightingMode = _OutlineLightingMode;
}

void ToonSpecularFragment() {
half2 maskUV = 0;
switch (_DetailNormalsUVSet) {
case 0: maskUV = d.uv0; break;
case 1: maskUV = d.uv1; break;
case 2: maskUV = d.uv2; break;
case 3: maskUV = d.uv3; break;
}

half3 specMap = SAMPLE_TEXTURE2D(_SpecularMap, sampler_MainTex, maskUV);
o.SpecularIntensity = _SpecularIntensity * specMap.r;
o.SpecularArea = max(0.01, _SpecularRoughness * specMap.b);
o.SpecularAnisotropy = _SpecularAnisotropy;
o.SpecularAlbedoTint = _SpecularAlbedoTint * specMap.g;
o.SpecularSharpness = _SpecularSharpness;
}

void ToonReflectionFragment() {
o.EnableReflections = _ReflectionMode != 3;
o.ReflectionBlendMode = _ReflectionBlendMode;

half mask = SAMPLE_TEXTURE2D(_ReflectivityMask, sampler_MainTex, GLOBAL_uv).r;
mask *= _ReflectivityLevel;

UNITY_BRANCH
if (_ReflectionMode == 0) {
half4 metalSmooth = SAMPLE_TEXTURE2D(_MetallicGlossMap, sampler_MainTex, GLOBAL_uv);
int hasMetallicSmooth = _MetallicGlossMap_TexelSize.z > 8;
half metal = metalSmooth.r;
half smooth = metalSmooth.a;
if (_RoughnessMode)
{
smooth = 1 - smooth;
}
metal = remap(metal, 0, 1, _MetallicRemap.x, _MetallicRemap.y);
smooth = remap(smooth, 0, 1, _SmoothnessRemap.x, _SmoothnessRemap.y);
o.Metallic = lerp(_Metallic, metal, hasMetallicSmooth);
o.Smoothness = lerp(_Smoothness, smooth, hasMetallicSmooth);
o.Anisotropy = _ReflectionAnisotropy;
}
UNITY_BRANCH
if (_ReflectionMode == 2) {
half3 upVector = half3(0,1,0);
half2 remapUV = calcMatcapUV(upVector, d.worldSpaceViewDir, GLOBAL_pixelNormal);
half4 spec = 0;
spec = SAMPLE_TEXTURE2D_LOD(_Matcap, sampler_Matcap, remapUV, _MatcapBlur * UNITY_SPECCUBE_LOD_STEPS);

spec.rgb *= lerp(1, o.Albedo, _MatcapTintToDiffuse);
o.BakedReflection = spec.rgb;
}
o.Reflectivity = mask;
}

void ToonALFragment() {
if(AudioLinkIsAvailable() && _ALMode != 0) {
half2 alUV = 0;
switch (_ALMapUVSet) {
case 0: alUV = GLOBAL_uv; break;
case 1: alUV = d.uv1; break;
case 2: alUV = d.uv2; break;
case 3: alUV = d.uv3; break;
}
half4 alMask = SAMPLE_TEXTURE2D(_ALMap, sampler_ALMap, alUV);
if (_ALMode == 2) {
half audioDataBass = AudioLinkData(ALPASS_AUDIOBASS).x;
half audioDataMids = AudioLinkData(ALPASS_AUDIOLOWMIDS).x;
half audioDataHighs = (AudioLinkData(ALPASS_AUDIOHIGHMIDS).x + AudioLinkData(ALPASS_AUDIOTREBLE).x) * 0.5;

half tLow = smoothstep((1-audioDataBass), (1-audioDataBass) + 0.01, alMask.r) * alMask.a;
half tMid = smoothstep((1-audioDataMids), (1-audioDataMids) + 0.01, alMask.g) * alMask.a;
half tHigh = smoothstep((1-audioDataHighs), (1-audioDataHighs) + 0.01, alMask.b) * alMask.a;

half4 emissionChannelRed = lerp(alMask.r, tLow, _ALGradientOnRed) * _ALPackedRedColor * audioDataBass;
half4 emissionChannelGreen = lerp(alMask.g, tMid, _ALGradientOnGreen) * _ALPackedGreenColor * audioDataMids;
half4 emissionChannelBlue = lerp(alMask.b, tHigh, _ALGradientOnBlue) * _ALPackedBlueColor * audioDataHighs;
o.Emission += emissionChannelRed.rgb + emissionChannelGreen.rgb + emissionChannelBlue.rgb;
} else {
int2 aluv;
if (_ALMode == 1) {
	aluv = int2(0, _ALBand);
} else {
	aluv = int2(GLOBAL_uv.x * _ALUVWidth, GLOBAL_uv.y);
}
half sampledAL = AudioLinkData(aluv).x;
o.Emission +=  alMask.rgb * _ALEmissionColor.rgb * sampledAL;
}
}
}

void ToonEmissionFragment() {
half3 emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_MainTex, GLOBAL_uv).rgb;
emission *= lerp(emission, emission * o.Albedo, _EmissionTintToDiffuse) * _EmissionColor;
o.Emission += emission;
o.EmissionScaleWithLight = _EmissionScaleWithLight;
o.EmissionLightThreshold = _EmissionScaleWithLightSensitivity;
}

void ToonRimLightFragment() {
#ifndef USING_DIRECTIONAL_LIGHT
fixed3 lightDir = normalize(UnityWorldSpaceLightDir(d.worldSpacePosition));
#else
fixed3 lightDir = _WorldSpaceLightPos0.xyz;
#endif
half lightNoL = saturate(dot(GLOBAL_pixelNormal, lightDir));
half SVDNoN = abs(dot(d.svdn, GLOBAL_pixelNormal));

half rimIntensity = saturate((1 - SVDNoN)) * pow(lightNoL, _RimThreshold);
rimIntensity = smoothstep(_RimRange - _RimSharpness, _RimRange + _RimSharpness, rimIntensity);
half4 rim = rimIntensity * _RimIntensity;

half3 env = 0;
#if defined(UNITY_PASS_FORWARDBASE)
env = getEnvReflection(d.worldSpaceViewDir.xyz, d.worldSpacePosition.xyz, GLOBAL_pixelNormal, o.Smoothness, 5);
#endif

o.RimLight = rim * _RimTint * lerp(1, o.Albedo.rgbb, _RimAlbedoTint) * lerp(1, env.rgbb, _RimEnvironmentTint);
o.RimAttenuation = _RimAttenuation;
}

void ToonShadowRimFragment() {
#ifndef USING_DIRECTIONAL_LIGHT
fixed3 lightDir = normalize(UnityWorldSpaceLightDir(d.worldSpacePosition));
#else
fixed3 lightDir = _WorldSpaceLightPos0.xyz;
#endif
half lightNoL = saturate(dot(GLOBAL_pixelNormal, lightDir));
half SVDNoN = abs(dot(d.svdn, GLOBAL_pixelNormal));
half shadowRimIntensity = saturate((1 - SVDNoN)) * pow(1 - lightNoL, _ShadowRimThreshold * 2);
shadowRimIntensity = smoothstep(_ShadowRimRange - _ShadowRimSharpness, _ShadowRimRange + _ShadowRimSharpness, shadowRimIntensity);

o.RimShadow = lerp(1, (_ShadowRimTint * lerp(1, o.Albedo.rgbb, _ShadowRimAlbedoTint)), shadowRimIntensity);
}

void XSToonLighting()
{
#if !defined(UNITY_PASS_SHADOWCASTER)
half reflectance = o.Reflectivity;
half3 f0 = 0.16 * reflectance * reflectance * (1 - o.Metallic) + o.Albedo * o.Metallic;
half3 indirectDiffuse = 1;
half3 indirectSpecular = 0;
half3 directSpecular = 0;
half occlusion = o.Occlusion;
half perceptualRoughness = 1 - o.Smoothness;
half3 tangentNormal = o.Normal;
o.Normal = normalize(mul(o.Normal, d.TBNMatrix));
half3 reflDir = calcReflView(d.worldSpaceViewDir, o.Normal);

#ifndef USING_DIRECTIONAL_LIGHT
fixed3 lightDir = normalize(UnityWorldSpaceLightDir(d.worldSpacePosition));
#else
fixed3 lightDir = _WorldSpaceLightPos0.xyz;
#endif

// Attenuation
UNITY_LIGHT_ATTENUATION(lightAttenuation, FragData, d.worldSpacePosition);

// fix for rare bug where light atten is 0 when there is no directional light in the scene
#ifdef UNITY_PASS_FORWARDBASE
if(all(_LightColor0.rgb == 0.0))
lightAttenuation = 1.0;
#endif

#if defined(USING_DIRECTIONAL_LIGHT)
half sharp = o.ShadowSharpness * 0.5;
lightAttenuation = smoothstep(sharp, 1 - sharp, lightAttenuation); //Converge at the center line
#endif

half3 lightColor = _LightColor0.rgb;

half3 lightHalfVector = Unity_SafeNormalize(lightDir + d.worldSpaceViewDir);
half lightNoL = saturate(dot(o.Normal, lightDir));
half lightLoH = saturate(dot(lightDir, lightHalfVector));

half NoV = abs(dot(o.Normal, d.worldSpaceViewDir)) + 1e-5;
half NoH = saturate(dot(o.Normal, lightHalfVector));
half3 stereoViewDir = calcStereoViewDir(d.worldSpacePosition);
half NoSVDN = abs(dot(stereoViewDir, o.Normal));

// Aniso Refl
half3 reflViewAniso = 0;

float3 anisotropicDirection = o.Anisotropy >= 0.0 ? d.bitangent : FragData.worldTangent.xyz;
float3 anisotropicTangent = cross(anisotropicDirection, d.worldSpaceViewDir);
float3 anisotropicNormal = cross(anisotropicTangent, anisotropicDirection);
float bendFactor = abs(o.Anisotropy) * saturate(5.0 * perceptualRoughness);
float3 bentNormal = normalize(lerp(o.Normal, anisotropicNormal, bendFactor));
reflViewAniso = reflect(-d.worldSpaceViewDir, bentNormal);

// Indirect diffuse
#if !defined(LIGHTMAP_ON)
indirectDiffuse = ShadeSH9(float4(0,0.5,0,1));
#else
indirectDiffuse = 0;
#endif
indirectDiffuse *= lerp(occlusion, 1, o.OcclusionMode);

bool lightEnv = any(lightDir.xyz);
// if there is no realtime light - we create it from indirect diffuse
if (!lightEnv) {
lightColor = indirectDiffuse.xyz * 0.6;
indirectDiffuse = indirectDiffuse * 0.4;
}

half lightAvg = (dot(indirectDiffuse.rgb, grayscaleVec) + dot(lightColor.rgb, grayscaleVec)) / 2;

// Light Ramp
half4 ramp = 1;
half4 diffuse = 1;
ramp = calcRamp(lightNoL, lightAttenuation, occlusion, _OcclusionMode);
diffuse = calcDiffuse(lightAttenuation, o.Albedo.rgb * perceptualRoughness, indirectDiffuse, lightColor, ramp);

// Rims
half4 rimLight = o.RimLight;
rimLight *= lightColor.xyzz + indirectDiffuse.xyzz;
rimLight *= lerp(1, lightAttenuation + indirectDiffuse.xyzz, o.RimAttenuation);
half4 rimShadow = o.RimShadow;

float3 fresnel = F_Schlick(NoV, f0);
indirectSpecular = calcIndirectSpecular(lightAttenuation, d, o, perceptualRoughness, reflViewAniso, indirectDiffuse, fresnel, ramp) * occlusion;
directSpecular = calcDirectSpecular(d, o, lightNoL, NoH, NoV, lightLoH, lightColor, lightHalfVector, o.SpecularAnisotropy) * lightNoL * occlusion * lightAttenuation;

FinalColor = diffuse * o.RimShadow;
FinalColor = calcReflectionBlending(o, reflectance, FinalColor, indirectSpecular);
FinalColor += max(directSpecular.xyzz, rimLight);
FinalColor.rgb += calcEmission(o, lightAvg);

// Outline
#if defined(PASS_OUTLINE)
half3 outlineColor = 0;
half3 ol = o.OutlineColor;
outlineColor = ol * saturate(lightAttenuation * lightNoL) * lightColor.rgb;
outlineColor += indirectDiffuse * ol;
outlineColor = lerp(outlineColor, ol, o.OutlineLightingMode);
FinalColor.rgb = outlineColor;
#endif

#endif
}

// ForwardAdd Vertex
FragmentData Vertex(VertexData v)
{
UNITY_SETUP_INSTANCE_ID(v);
FragmentData i;
UNITY_INITIALIZE_OUTPUT(FragmentData, i);
UNITY_TRANSFER_INSTANCE_ID(v, i);
UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(i);

vD = v;
FragData = i;
ToonOutlineVertex();

i = FragData;
v = vD;
#if defined(UNITY_PASS_SHADOWCASTER)
i.worldNormal = UnityObjectToWorldNormal(v.normal);
i.worldPos = mul(unity_ObjectToWorld, v.vertex);
i.uv0 = v.uv0;
i.uv1 = v.uv1;
i.uv2 = v.uv2;
i.uv3 = v.uv3;
i.worldTangent.xyz = UnityObjectToWorldDir(v.tangent.xyz);
i.worldTangent.w = v.tangent.w * unity_WorldTransformParams.w;
#else
i.pos = UnityObjectToClipPos(v.vertex);
i.normal = v.normal;
i.worldNormal = UnityObjectToWorldNormal(v.normal);
i.worldPos = mul(unity_ObjectToWorld, v.vertex);
i.uv0 = v.uv0;
i.uv1 = v.uv1;
i.uv2 = v.uv2;
i.uv3 = v.uv3;
i.worldTangent.xyz = UnityObjectToWorldDir(v.tangent.xyz);
i.worldTangent.w = v.tangent.w * unity_WorldTransformParams.w;
i.vertexColor = v.color;

#if defined(NEED_SCREEN_POS)
i.screenPos = ComputeScreenPos(i.pos);
#endif

#if defined(LIGHTMAP_ON)
i.lightmapUv.xy = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
#endif
#if defined(DYNAMICLIGHTMAP_ON)
i.lightmapUv.zw = v.uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
#endif

UNITY_TRANSFER_LIGHTING(i, v.uv1.xy);

#if !defined(UNITY_PASS_FORWARDADD)
// unity does some funky stuff for different platforms with these macros
#ifdef FOG_COMBINED_WITH_TSPACE
UNITY_TRANSFER_FOG_COMBINED_WITH_TSPACE(i, i.pos);
#elif defined(FOG_COMBINED_WITH_WORLD_POS)
UNITY_TRANSFER_FOG_COMBINED_WITH_WORLD_POS(i, i.pos);
#else
UNITY_TRANSFER_FOG(i, i.pos);
#endif
#else
UNITY_TRANSFER_FOG(i, i.pos);
#endif
#endif

return i;
}

// ForwardAdd Fragment
half4 Fragment(FragmentData i) : SV_TARGET
{
UNITY_SETUP_INSTANCE_ID(i);
#ifdef FOG_COMBINED_WITH_TSPACE
UNITY_EXTRACT_FOG_FROM_TSPACE(i);
#elif defined(FOG_COMBINED_WITH_WORLD_POS)
UNITY_EXTRACT_FOG_FROM_WORLD_POS(i);
#else
UNITY_EXTRACT_FOG(i);
#endif

FragData = i;
o = (SurfaceData) 0;
d = CreateMeshData(i);
o.Albedo = half3(0.5, 0.5, 0.5);
o.Normal = half3(0, 0, 1);
o.Smoothness = 0;
o.Occlusion = 1;
o.Alpha = 1;
o.RimShadow = 1;
o.RimAttenuation = 1;
FinalColor = half4(o.Albedo, o.Alpha);

ToonFragment();
ToonOcclusionFragment();
ToonNormalsFragment();
ToonOutlineFragment();
ToonSpecularFragment();
ToonReflectionFragment();
ToonALFragment();
ToonEmissionFragment();
ToonRimLightFragment();
ToonShadowRimFragment();

XSToonLighting();

UNITY_APPLY_FOG(_unity_fogCoord, FinalColor);

return FinalColor;
}

ENDCG
// ForwardAdd Pass End

}

Pass
{
Tags { "LightMode" = "ShadowCaster"  }

// Shadow Pass Start
CGPROGRAM
#pragma target 4.5
#pragma multi_compile_instancing
#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
#pragma multi_compile_shadowcaster
#pragma vertex Vertex
#pragma fragment Fragment
#pragma shader_feature_local OUTLINE_ENABLED

#define UNITY_INSTANCED_LOD_FADE
#define UNITY_INSTANCED_SH
#define UNITY_INSTANCED_LIGHTMAPSTS

#ifndef UNITY_PASS_SHADOWCASTER
#define UNITY_PASS_SHADOWCASTER
#endif

#include "UnityStandardUtils.cginc"
#include "Lighting.cginc"
#include "UnityPBSLighting.cginc"

#define FLT_EPSILON     1.192092896e-07

#if defined(UNITY_PBS_USE_BRDF2) || defined(SHADER_API_MOBILE)
#define PLAT_QUEST
#else
#ifdef PLAT_QUEST
#undef PLAT_QUEST
#endif
#endif

#define NEED_SCREEN_POS

#define grayscaleVec float3(0.2125, 0.7154, 0.0721)

// Credit to Jason Booth for digging this all up
// This originally comes from CoreRP, see Jason's comment below

// If your looking in here and thinking WTF, yeah, I know. These are taken from the SRPs, to allow us to use the same
// texturing library they use. However, since they are not included in the standard pipeline by default, there is no
// way to include them in and they have to be inlined, since someone could copy this shader onto another machine without
// Better Shaders installed. Unfortunate, but I'd rather do this and have a nice library for texture sampling instead
// of the patchy one Unity provides being inlined/emulated in HDRP/URP. Strangely, PSSL and XBoxOne libraries are not
// included in the standard SRP code, but they are in tons of Unity own projects on the web, so I grabbed them from there.

#if defined(SHADER_API_XBOXONE)

// Initialize arbitrary structure with zero values.
// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
#define ZERO_INITIALIZE(type, name) name = (type)0;
#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }

// Texture util abstraction

#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) textureName.CalculateLevelOfDetail(samplerName, coord2)

// Texture abstraction

#define TEXTURE2D(textureName)                Texture2D textureName
#define TEXTURE2D_ARRAY(textureName)          Texture2DArray textureName
#define TEXTURECUBE(textureName)              TextureCube textureName
#define TEXTURECUBE_ARRAY(textureName)        TextureCubeArray textureName
#define TEXTURE3D(textureName)                Texture3D textureName

#define TEXTURE2D_FLOAT(textureName)          TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_FLOAT(textureName)    TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_FLOAT(textureName)        TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_FLOAT(textureName)  TEXTURECUBE_ARRAY(textureName)
#define TEXTURE3D_FLOAT(textureName)          TEXTURE3D(textureName)

#define TEXTURE2D_HALF(textureName)           TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_HALF(textureName)     TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_HALF(textureName)         TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_HALF(textureName)   TEXTURECUBE_ARRAY(textureName)
#define TEXTURE3D_HALF(textureName)           TEXTURE3D(textureName)

#define TEXTURE2D_SHADOW(textureName)         TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_SHADOW(textureName)   TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_SHADOW(textureName)       TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_SHADOW(textureName) TEXTURECUBE_ARRAY(textureName)

#define RW_TEXTURE2D(type, textureName)       RWTexture2D<type> textureName
#define RW_TEXTURE2D_ARRAY(type, textureName) RWTexture2DArray<type> textureName
#define RW_TEXTURE3D(type, textureName)       RWTexture3D<type> textureName

#define SAMPLER(samplerName)                  SamplerState samplerName
#define SAMPLER_CMP(samplerName)              SamplerComparisonState samplerName

#define TEXTURE2D_PARAM(textureName, samplerName)                 TEXTURE2D(textureName), SAMPLER(samplerName)
#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)           TEXTURE2D_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_PARAM(textureName, samplerName)               TEXTURECUBE(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)         TEXTURECUBE_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURE3D_PARAM(textureName, samplerName)                 TEXTURE3D(textureName), SAMPLER(samplerName)

#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)          TEXTURE2D(textureName), SAMPLER_CMP(samplerName)
#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)    TEXTURE2D_ARRAY(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)        TEXTURECUBE(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_ARRAY_SHADOW_PARAM(textureName, samplerName)  TEXTURECUBE_ARRAY(textureName), SAMPLER_CMP(samplerName)

#define TEXTURE2D_ARGS(textureName, samplerName)                textureName, samplerName
#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)          textureName, samplerName
#define TEXTURECUBE_ARGS(textureName, samplerName)              textureName, samplerName
#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)        textureName, samplerName
#define TEXTURE3D_ARGS(textureName, samplerName)                textureName, samplerName

#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)         textureName, samplerName
#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)   textureName, samplerName
#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)       textureName, samplerName
#define TEXTURECUBE_ARRAY_SHADOW_ARGS(textureName, samplerName) textureName, samplerName

#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod)                      textureName.SampleLevel(samplerName, coord2, lod)
#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                    textureName.SampleBias(samplerName, coord2, bias)
#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, dpdx, dpdy)              textureName.SampleGrad(samplerName, coord2, dpdx, dpdy)
#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                  textureName.Sample(samplerName, float3(coord2, index))
#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)         textureName.SampleLevel(samplerName, float3(coord2, index), lod)
#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)       textureName.SampleBias(samplerName, float3(coord2, index), bias)
#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy) textureName.SampleGrad(samplerName, float3(coord2, index), dpdx, dpdy)
#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                             textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                    textureName.SampleLevel(samplerName, coord3, lod)
#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                  textureName.SampleBias(samplerName, coord3, bias)
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)                textureName.Sample(samplerName, float4(coord3, index))
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)       textureName.SampleLevel(samplerName, float4(coord3, index), lod)
#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)     textureName.SampleBias(samplerName, float4(coord3, index), bias)
#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                               textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                      textureName.SampleLevel(samplerName, coord3, lod)

#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                    textureName.SampleCmpLevelZero(samplerName, (coord3).xy, (coord3).z)
#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)       textureName.SampleCmpLevelZero(samplerName, float3((coord3).xy, index), (coord3).z)
#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                  textureName.SampleCmpLevelZero(samplerName, (coord4).xyz, (coord4).w)
#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)     textureName.SampleCmpLevelZero(samplerName, float4((coord4).xyz, index), (coord4).w)

#define LOAD_TEXTURE2D(textureName, unCoord2)                                   textureName.Load(int3(unCoord2, 0))
#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)                          textureName.Load(int3(unCoord2, lod))
#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)                 textureName.Load(unCoord2, sampleIndex)
#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)                      textureName.Load(int4(unCoord2, index, 0))
#define LOAD_TEXTURE2D_ARRAY_MSAA(textureName, unCoord2, index, sampleIndex)    textureName.Load(int3(unCoord2, index), sampleIndex)
#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod)             textureName.Load(int4(unCoord2, index, lod))
#define LOAD_TEXTURE3D(textureName, unCoord3)                                   textureName.Load(int4(unCoord3, 0))
#define LOAD_TEXTURE3D_LOD(textureName, unCoord3, lod)                          textureName.Load(int4(unCoord3, lod))

#define PLATFORM_SUPPORT_GATHER
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                textureName.Gather(samplerName, coord2)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)   textureName.Gather(samplerName, float3(coord2, index))
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)              textureName.Gather(samplerName, coord3)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index) textureName.Gather(samplerName, float4(coord3, index))
#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)            textureName.GatherRed(samplerName, coord2)
#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherGreen(samplerName, coord2)
#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)           textureName.GatherBlue(samplerName, coord2)
#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherAlpha(samplerName, coord2)

#elif defined(SHADER_API_PSSL)

// Initialize arbitrary structure with zero values.
// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
#define ZERO_INITIALIZE(type, name) name = (type)0;
#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }

// Texture util abstraction

#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) textureName.GetLOD(samplerName, coord2)

// Texture abstraction

#define TEXTURE2D(textureName)                Texture2D textureName
#define TEXTURE2D_ARRAY(textureName)          Texture2DArray textureName
#define TEXTURECUBE(textureName)              TextureCube textureName
#define TEXTURECUBE_ARRAY(textureName)        TextureCubeArray textureName
#define TEXTURE3D(textureName)                Texture3D textureName

#define TEXTURE2D_FLOAT(textureName)          TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_FLOAT(textureName)    TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_FLOAT(textureName)        TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_FLOAT(textureName)  TEXTURECUBE_ARRAY(textureName)
#define TEXTURE3D_FLOAT(textureName)          TEXTURE3D(textureName)

#define TEXTURE2D_HALF(textureName)           TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_HALF(textureName)     TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_HALF(textureName)         TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_HALF(textureName)   TEXTURECUBE_ARRAY(textureName)
#define TEXTURE3D_HALF(textureName)           TEXTURE3D(textureName)

#define TEXTURE2D_SHADOW(textureName)         TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_SHADOW(textureName)   TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_SHADOW(textureName)       TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_SHADOW(textureName) TEXTURECUBE_ARRAY(textureName)

#define RW_TEXTURE2D(type, textureName)       RW_Texture2D<type> textureName
#define RW_TEXTURE2D_ARRAY(type, textureName) RW_Texture2D_Array<type> textureName
#define RW_TEXTURE3D(type, textureName)       RW_Texture3D<type> textureName

#define SAMPLER(samplerName)                  SamplerState samplerName
#define SAMPLER_CMP(samplerName)              SamplerComparisonState samplerName

#define TEXTURE2D_PARAM(textureName, samplerName)                 TEXTURE2D(textureName), SAMPLER(samplerName)
#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)           TEXTURE2D_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_PARAM(textureName, samplerName)               TEXTURECUBE(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)         TEXTURECUBE_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURE3D_PARAM(textureName, samplerName)                 TEXTURE3D(textureName), SAMPLER(samplerName)

#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)          TEXTURE2D(textureName), SAMPLER_CMP(samplerName)
#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)    TEXTURE2D_ARRAY(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)        TEXTURECUBE(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_ARRAY_SHADOW_PARAM(textureName, samplerName)  TEXTURECUBE_ARRAY(textureName), SAMPLER_CMP(samplerName)

#define TEXTURE2D_ARGS(textureName, samplerName)                textureName, samplerName
#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)          textureName, samplerName
#define TEXTURECUBE_ARGS(textureName, samplerName)              textureName, samplerName
#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)        textureName, samplerName
#define TEXTURE3D_ARGS(textureName, samplerName)                textureName, samplerName

#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)         textureName, samplerName
#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)   textureName, samplerName
#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)       textureName, samplerName
#define TEXTURECUBE_ARRAY_SHADOW_ARGS(textureName, samplerName) textureName, samplerName

#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod)                      textureName.SampleLevel(samplerName, coord2, lod)
#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                    textureName.SampleBias(samplerName, coord2, bias)
#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, dpdx, dpdy)              textureName.SampleGrad(samplerName, coord2, dpdx, dpdy)
#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                  textureName.Sample(samplerName, float3(coord2, index))
#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)         textureName.SampleLevel(samplerName, float3(coord2, index), lod)
#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)       textureName.SampleBias(samplerName, float3(coord2, index), bias)
#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy) textureName.SampleGrad(samplerName, float3(coord2, index), dpdx, dpdy)
#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                             textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                    textureName.SampleLevel(samplerName, coord3, lod)
#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                  textureName.SampleBias(samplerName, coord3, bias)
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)                textureName.Sample(samplerName, float4(coord3, index))
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)       textureName.SampleLevel(samplerName, float4(coord3, index), lod)
#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)     textureName.SampleBias(samplerName, float4(coord3, index), bias)
#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                               textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                      textureName.SampleLevel(samplerName, coord3, lod)

#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                    textureName.SampleCmpLevelZero(samplerName, (coord3).xy, (coord3).z)
#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)       textureName.SampleCmpLevelZero(samplerName, float3((coord3).xy, index), (coord3).z)
#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                  textureName.SampleCmpLevelZero(samplerName, (coord4).xyz, (coord4).w)
#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)     textureName.SampleCmpLevelZero(samplerName, float4((coord4).xyz, index), (coord4).w)

#define LOAD_TEXTURE2D(textureName, unCoord2)                                   textureName.Load(int3(unCoord2, 0))
#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)                          textureName.Load(int3(unCoord2, lod))
#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)                 textureName.Load(unCoord2, sampleIndex)
#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)                      textureName.Load(int4(unCoord2, index, 0))
#define LOAD_TEXTURE2D_ARRAY_MSAA(textureName, unCoord2, index, sampleIndex)    textureName.Load(int3(unCoord2, index), sampleIndex)
#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod)             textureName.Load(int4(unCoord2, index, lod))
#define LOAD_TEXTURE3D(textureName, unCoord3)                                   textureName.Load(int4(unCoord3, 0))
#define LOAD_TEXTURE3D_LOD(textureName, unCoord3, lod)                          textureName.Load(int4(unCoord3, lod))

#define PLATFORM_SUPPORT_GATHER
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                textureName.Gather(samplerName, coord2)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)   textureName.Gather(samplerName, float3(coord2, index))
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)              textureName.Gather(samplerName, coord3)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index) textureName.Gather(samplerName, float4(coord3, index))
#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)            textureName.GatherRed(samplerName, coord2)
#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherGreen(samplerName, coord2)
#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)           textureName.GatherBlue(samplerName, coord2)
#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherAlpha(samplerName, coord2)

#elif defined(SHADER_API_D3D11)

// Initialize arbitrary structure with zero values.
// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
#define ZERO_INITIALIZE(type, name) name = (type)0;
#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }

// Texture util abstraction

#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) textureName.CalculateLevelOfDetail(samplerName, coord2)

// Texture abstraction

#define TEXTURE2D(textureName)                Texture2D textureName
#define TEXTURE2D_ARRAY(textureName)          Texture2DArray textureName
#define TEXTURECUBE(textureName)              TextureCube textureName
#define TEXTURECUBE_ARRAY(textureName)        TextureCubeArray textureName
#define TEXTURE3D(textureName)                Texture3D textureName

#define TEXTURE2D_FLOAT(textureName)          TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_FLOAT(textureName)    TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_FLOAT(textureName)        TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_FLOAT(textureName)  TEXTURECUBE_ARRAY(textureName)
#define TEXTURE3D_FLOAT(textureName)          TEXTURE3D(textureName)

#define TEXTURE2D_HALF(textureName)           TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_HALF(textureName)     TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_HALF(textureName)         TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_HALF(textureName)   TEXTURECUBE_ARRAY(textureName)
#define TEXTURE3D_HALF(textureName)           TEXTURE3D(textureName)

#define TEXTURE2D_SHADOW(textureName)         TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_SHADOW(textureName)   TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_SHADOW(textureName)       TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_SHADOW(textureName) TEXTURECUBE_ARRAY(textureName)

#define RW_TEXTURE2D(type, textureName)       RWTexture2D<type> textureName
#define RW_TEXTURE2D_ARRAY(type, textureName) RWTexture2DArray<type> textureName
#define RW_TEXTURE3D(type, textureName)       RWTexture3D<type> textureName

#define SAMPLER(samplerName)                  SamplerState samplerName
#define SAMPLER_CMP(samplerName)              SamplerComparisonState samplerName

#define TEXTURE2D_PARAM(textureName, samplerName)                 TEXTURE2D(textureName), SAMPLER(samplerName)
#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)           TEXTURE2D_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_PARAM(textureName, samplerName)               TEXTURECUBE(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)         TEXTURECUBE_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURE3D_PARAM(textureName, samplerName)                 TEXTURE3D(textureName), SAMPLER(samplerName)

#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)          TEXTURE2D(textureName), SAMPLER_CMP(samplerName)
#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)    TEXTURE2D_ARRAY(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)        TEXTURECUBE(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_ARRAY_SHADOW_PARAM(textureName, samplerName)  TEXTURECUBE_ARRAY(textureName), SAMPLER_CMP(samplerName)

#define TEXTURE2D_ARGS(textureName, samplerName)                textureName, samplerName
#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)          textureName, samplerName
#define TEXTURECUBE_ARGS(textureName, samplerName)              textureName, samplerName
#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)        textureName, samplerName
#define TEXTURE3D_ARGS(textureName, samplerName)                textureName, samplerName

#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)         textureName, samplerName
#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)   textureName, samplerName
#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)       textureName, samplerName
#define TEXTURECUBE_ARRAY_SHADOW_ARGS(textureName, samplerName) textureName, samplerName

#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod)                      textureName.SampleLevel(samplerName, coord2, lod)
#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                    textureName.SampleBias(samplerName, coord2, bias)
#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, dpdx, dpdy)              textureName.SampleGrad(samplerName, coord2, dpdx, dpdy)
#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                  textureName.Sample(samplerName, float3(coord2, index))
#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)         textureName.SampleLevel(samplerName, float3(coord2, index), lod)
#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)       textureName.SampleBias(samplerName, float3(coord2, index), bias)
#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy) textureName.SampleGrad(samplerName, float3(coord2, index), dpdx, dpdy)
#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                             textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                    textureName.SampleLevel(samplerName, coord3, lod)
#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                  textureName.SampleBias(samplerName, coord3, bias)
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)                textureName.Sample(samplerName, float4(coord3, index))
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)       textureName.SampleLevel(samplerName, float4(coord3, index), lod)
#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)     textureName.SampleBias(samplerName, float4(coord3, index), bias)
#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                               textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                      textureName.SampleLevel(samplerName, coord3, lod)

#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                    textureName.SampleCmpLevelZero(samplerName, (coord3).xy, (coord3).z)
#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)       textureName.SampleCmpLevelZero(samplerName, float3((coord3).xy, index), (coord3).z)
#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                  textureName.SampleCmpLevelZero(samplerName, (coord4).xyz, (coord4).w)
#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)     textureName.SampleCmpLevelZero(samplerName, float4((coord4).xyz, index), (coord4).w)

#define LOAD_TEXTURE2D(textureName, unCoord2)                                   textureName.Load(int3(unCoord2, 0))
#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)                          textureName.Load(int3(unCoord2, lod))
#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)                 textureName.Load(unCoord2, sampleIndex)
#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)                      textureName.Load(int4(unCoord2, index, 0))
#define LOAD_TEXTURE2D_ARRAY_MSAA(textureName, unCoord2, index, sampleIndex)    textureName.Load(int3(unCoord2, index), sampleIndex)
#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod)             textureName.Load(int4(unCoord2, index, lod))
#define LOAD_TEXTURE3D(textureName, unCoord3)                                   textureName.Load(int4(unCoord3, 0))
#define LOAD_TEXTURE3D_LOD(textureName, unCoord3, lod)                          textureName.Load(int4(unCoord3, lod))

#define PLATFORM_SUPPORT_GATHER
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                textureName.Gather(samplerName, coord2)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)   textureName.Gather(samplerName, float3(coord2, index))
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)              textureName.Gather(samplerName, coord3)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index) textureName.Gather(samplerName, float4(coord3, index))
#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)            textureName.GatherRed(samplerName, coord2)
#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherGreen(samplerName, coord2)
#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)           textureName.GatherBlue(samplerName, coord2)
#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherAlpha(samplerName, coord2)

#elif defined(SHADER_API_METAL)

// Initialize arbitrary structure with zero values.
// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
#define ZERO_INITIALIZE(type, name) name = (type)0;
#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }

// Texture util abstraction

#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) textureName.CalculateLevelOfDetail(samplerName, coord2)

// Texture abstraction

#define TEXTURE2D(textureName)                Texture2D textureName
#define TEXTURE2D_ARRAY(textureName)          Texture2DArray textureName
#define TEXTURECUBE(textureName)              TextureCube textureName
#define TEXTURECUBE_ARRAY(textureName)        TextureCubeArray textureName
#define TEXTURE3D(textureName)                Texture3D textureName

#define TEXTURE2D_FLOAT(textureName)          Texture2D_float textureName
#define TEXTURE2D_ARRAY_FLOAT(textureName)    Texture2DArray textureName    // no support to _float on Array, it's being added
#define TEXTURECUBE_FLOAT(textureName)        TextureCube_float textureName
#define TEXTURECUBE_ARRAY_FLOAT(textureName)  TextureCubeArray textureName  // no support to _float on Array, it's being added
#define TEXTURE3D_FLOAT(textureName)          Texture3D_float textureName

#define TEXTURE2D_HALF(textureName)           Texture2D_half textureName
#define TEXTURE2D_ARRAY_HALF(textureName)     Texture2DArray textureName    // no support to _float on Array, it's being added
#define TEXTURECUBE_HALF(textureName)         TextureCube_half textureName
#define TEXTURECUBE_ARRAY_HALF(textureName)   TextureCubeArray textureName  // no support to _float on Array, it's being added
#define TEXTURE3D_HALF(textureName)           Texture3D_half textureName

#define TEXTURE2D_SHADOW(textureName)         TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_SHADOW(textureName)   TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_SHADOW(textureName)       TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_SHADOW(textureName) TEXTURECUBE_ARRAY(textureName)

#define RW_TEXTURE2D(type, textureName)       RWTexture2D<type> textureName
#define RW_TEXTURE2D_ARRAY(type, textureName) RWTexture2DArray<type> textureName
#define RW_TEXTURE3D(type, textureName)       RWTexture3D<type> textureName

#define SAMPLER(samplerName)                  SamplerState samplerName
#define SAMPLER_CMP(samplerName)              SamplerComparisonState samplerName

#define TEXTURE2D_PARAM(textureName, samplerName)                 TEXTURE2D(textureName), SAMPLER(samplerName)
#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)           TEXTURE2D_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_PARAM(textureName, samplerName)               TEXTURECUBE(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)         TEXTURECUBE_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURE3D_PARAM(textureName, samplerName)                 TEXTURE3D(textureName), SAMPLER(samplerName)

#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)          TEXTURE2D(textureName), SAMPLER_CMP(samplerName)
#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)    TEXTURE2D_ARRAY(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)        TEXTURECUBE(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_ARRAY_SHADOW_PARAM(textureName, samplerName)  TEXTURECUBE_ARRAY(textureName), SAMPLER_CMP(samplerName)

#define TEXTURE2D_ARGS(textureName, samplerName)                textureName, samplerName
#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)          textureName, samplerName
#define TEXTURECUBE_ARGS(textureName, samplerName)              textureName, samplerName
#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)        textureName, samplerName
#define TEXTURE3D_ARGS(textureName, samplerName)                textureName, samplerName

#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)         textureName, samplerName
#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)   textureName, samplerName
#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)       textureName, samplerName
#define TEXTURECUBE_ARRAY_SHADOW_ARGS(textureName, samplerName) textureName, samplerName

#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod)                      textureName.SampleLevel(samplerName, coord2, lod)
#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                    textureName.SampleBias(samplerName, coord2, bias)
#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, dpdx, dpdy)              textureName.SampleGrad(samplerName, coord2, dpdx, dpdy)
#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                  textureName.Sample(samplerName, float3(coord2, index))
#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)         textureName.SampleLevel(samplerName, float3(coord2, index), lod)
#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)       textureName.SampleBias(samplerName, float3(coord2, index), bias)
#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy) textureName.SampleGrad(samplerName, float3(coord2, index), dpdx, dpdy)
#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                             textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                    textureName.SampleLevel(samplerName, coord3, lod)
#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                  textureName.SampleBias(samplerName, coord3, bias)
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)                textureName.Sample(samplerName, float4(coord3, index))
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)       textureName.SampleLevel(samplerName, float4(coord3, index), lod)
#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)     textureName.SampleBias(samplerName, float4(coord3, index), bias)
#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                               textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                      textureName.SampleLevel(samplerName, coord3, lod)

#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                    textureName.SampleCmpLevelZero(samplerName, (coord3).xy, (coord3).z)
#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)       textureName.SampleCmpLevelZero(samplerName, float3((coord3).xy, index), (coord3).z)
#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                  textureName.SampleCmpLevelZero(samplerName, (coord4).xyz, (coord4).w)
#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)     textureName.SampleCmpLevelZero(samplerName, float4((coord4).xyz, index), (coord4).w)

#define LOAD_TEXTURE2D(textureName, unCoord2)                                   textureName.Load(int3(unCoord2, 0))
#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)                          textureName.Load(int3(unCoord2, lod))
#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)                 textureName.Load(unCoord2, sampleIndex)
#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)                      textureName.Load(int4(unCoord2, index, 0))
#define LOAD_TEXTURE2D_ARRAY_MSAA(textureName, unCoord2, index, sampleIndex)    textureName.Load(int3(unCoord2, index), sampleIndex)
#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod)             textureName.Load(int4(unCoord2, index, lod))
#define LOAD_TEXTURE3D(textureName, unCoord3)                                   textureName.Load(int4(unCoord3, 0))
#define LOAD_TEXTURE3D_LOD(textureName, unCoord3, lod)                          textureName.Load(int4(unCoord3, lod))

#define PLATFORM_SUPPORT_GATHER
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                textureName.Gather(samplerName, coord2)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)   textureName.Gather(samplerName, float3(coord2, index))
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)              textureName.Gather(samplerName, coord3)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index) textureName.Gather(samplerName, float4(coord3, index))
#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)            textureName.GatherRed(samplerName, coord2)
#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherGreen(samplerName, coord2)
#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)           textureName.GatherBlue(samplerName, coord2)
#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherAlpha(samplerName, coord2)

#elif defined(SHADER_API_VULKAN)
// This file assume SHADER_API_VULKAN is defined
// TODO: This is a straight copy from D3D11.hlsl. Go through all this stuff and adjust where needed.

// Initialize arbitrary structure with zero values.
// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
#define ZERO_INITIALIZE(type, name) name = (type)0;
#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }

// Texture util abstraction

#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) textureName.CalculateLevelOfDetail(samplerName, coord2)

// Texture abstraction

#define TEXTURE2D(textureName)                Texture2D textureName
#define TEXTURE2D_ARRAY(textureName)          Texture2DArray textureName
#define TEXTURECUBE(textureName)              TextureCube textureName
#define TEXTURECUBE_ARRAY(textureName)        TextureCubeArray textureName
#define TEXTURE3D(textureName)                Texture3D textureName

#define TEXTURE2D_FLOAT(textureName)          Texture2D_float textureName
#define TEXTURE2D_ARRAY_FLOAT(textureName)    Texture2DArray textureName    // no support to _float on Array, it's being added
#define TEXTURECUBE_FLOAT(textureName)        TextureCube_float textureName
#define TEXTURECUBE_ARRAY_FLOAT(textureName)  TextureCubeArray textureName  // no support to _float on Array, it's being added
#define TEXTURE3D_FLOAT(textureName)          Texture3D_float textureName

#define TEXTURE2D_HALF(textureName)           Texture2D_half textureName
#define TEXTURE2D_ARRAY_HALF(textureName)     Texture2DArray textureName    // no support to _float on Array, it's being added
#define TEXTURECUBE_HALF(textureName)         TextureCube_half textureName
#define TEXTURECUBE_ARRAY_HALF(textureName)   TextureCubeArray textureName  // no support to _float on Array, it's being added
#define TEXTURE3D_HALF(textureName)           Texture3D_half textureName

#define TEXTURE2D_SHADOW(textureName)         TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_SHADOW(textureName)   TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_SHADOW(textureName)       TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_SHADOW(textureName) TEXTURECUBE_ARRAY(textureName)

#define RW_TEXTURE2D(type, textureName)       RWTexture2D<type> textureName
#define RW_TEXTURE2D_ARRAY(type, textureName) RWTexture2DArray<type> textureName
#define RW_TEXTURE3D(type, textureName)       RWTexture3D<type> textureName

#define SAMPLER(samplerName)                  SamplerState samplerName
#define SAMPLER_CMP(samplerName)              SamplerComparisonState samplerName

#define TEXTURE2D_PARAM(textureName, samplerName)                 TEXTURE2D(textureName), SAMPLER(samplerName)
#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)           TEXTURE2D_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_PARAM(textureName, samplerName)               TEXTURECUBE(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)         TEXTURECUBE_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURE3D_PARAM(textureName, samplerName)                 TEXTURE3D(textureName), SAMPLER(samplerName)

#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)          TEXTURE2D(textureName), SAMPLER_CMP(samplerName)
#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)    TEXTURE2D_ARRAY(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)        TEXTURECUBE(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_ARRAY_SHADOW_PARAM(textureName, samplerName)  TEXTURECUBE_ARRAY(textureName), SAMPLER_CMP(samplerName)

#define TEXTURE2D_ARGS(textureName, samplerName)                textureName, samplerName
#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)          textureName, samplerName
#define TEXTURECUBE_ARGS(textureName, samplerName)              textureName, samplerName
#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)        textureName, samplerName
#define TEXTURE3D_ARGS(textureName, samplerName)                textureName, samplerName

#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)         textureName, samplerName
#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)   textureName, samplerName
#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)       textureName, samplerName
#define TEXTURECUBE_ARRAY_SHADOW_ARGS(textureName, samplerName) textureName, samplerName

#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod)                      textureName.SampleLevel(samplerName, coord2, lod)
#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                    textureName.SampleBias(samplerName, coord2, bias)
#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, dpdx, dpdy)              textureName.SampleGrad(samplerName, coord2, dpdx, dpdy)
#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                  textureName.Sample(samplerName, float3(coord2, index))
#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)         textureName.SampleLevel(samplerName, float3(coord2, index), lod)
#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)       textureName.SampleBias(samplerName, float3(coord2, index), bias)
#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy) textureName.SampleGrad(samplerName, float3(coord2, index), dpdx, dpdy)
#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                             textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                    textureName.SampleLevel(samplerName, coord3, lod)
#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                  textureName.SampleBias(samplerName, coord3, bias)
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)                textureName.Sample(samplerName, float4(coord3, index))
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)       textureName.SampleLevel(samplerName, float4(coord3, index), lod)
#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)     textureName.SampleBias(samplerName, float4(coord3, index), bias)
#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                               textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                      textureName.SampleLevel(samplerName, coord3, lod)

#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                    textureName.SampleCmpLevelZero(samplerName, (coord3).xy, (coord3).z)
#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)       textureName.SampleCmpLevelZero(samplerName, float3((coord3).xy, index), (coord3).z)
#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                  textureName.SampleCmpLevelZero(samplerName, (coord4).xyz, (coord4).w)
#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)     textureName.SampleCmpLevelZero(samplerName, float4((coord4).xyz, index), (coord4).w)

#define LOAD_TEXTURE2D(textureName, unCoord2)                                   textureName.Load(int3(unCoord2, 0))
#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)                          textureName.Load(int3(unCoord2, lod))
#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)                 textureName.Load(unCoord2, sampleIndex)
#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)                      textureName.Load(int4(unCoord2, index, 0))
#define LOAD_TEXTURE2D_ARRAY_MSAA(textureName, unCoord2, index, sampleIndex)    textureName.Load(int3(unCoord2, index), sampleIndex)
#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod)             textureName.Load(int4(unCoord2, index, lod))
#define LOAD_TEXTURE3D(textureName, unCoord3)                                   textureName.Load(int4(unCoord3, 0))
#define LOAD_TEXTURE3D_LOD(textureName, unCoord3, lod)                          textureName.Load(int4(unCoord3, lod))

#define PLATFORM_SUPPORT_GATHER
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                textureName.Gather(samplerName, coord2)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)   textureName.Gather(samplerName, float3(coord2, index))
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)              textureName.Gather(samplerName, coord3)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index) textureName.Gather(samplerName, float4(coord3, index))
#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)            textureName.GatherRed(samplerName, coord2)
#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherGreen(samplerName, coord2)
#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)           textureName.GatherBlue(samplerName, coord2)
#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherAlpha(samplerName, coord2)

#elif defined(SHADER_API_SWITCH)
// This file assume SHADER_API_SWITCH is defined

// Initialize arbitrary structure with zero values.
// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
#define ZERO_INITIALIZE(type, name) name = (type)0;
#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }

// Texture util abstraction

#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) textureName.CalculateLevelOfDetail(samplerName, coord2)

// Texture abstraction

#define TEXTURE2D(textureName)                Texture2D textureName
#define TEXTURE2D_ARRAY(textureName)          Texture2DArray textureName
#define TEXTURECUBE(textureName)              TextureCube textureName
#define TEXTURECUBE_ARRAY(textureName)        TextureCubeArray textureName
#define TEXTURE3D(textureName)                Texture3D textureName

#define TEXTURE2D_FLOAT(textureName)          Texture2D_float textureName
#define TEXTURE2D_ARRAY_FLOAT(textureName)    Texture2DArray textureName    // no support to _float on Array, it's being added
#define TEXTURECUBE_FLOAT(textureName)        TextureCube_float textureName
#define TEXTURECUBE_ARRAY_FLOAT(textureName)  TextureCubeArray textureName  // no support to _float on Array, it's being added
#define TEXTURE3D_FLOAT(textureName)          Texture3D_float textureName

#define TEXTURE2D_HALF(textureName)           Texture2D_half textureName
#define TEXTURE2D_ARRAY_HALF(textureName)     Texture2DArray textureName    // no support to _float on Array, it's being added
#define TEXTURECUBE_HALF(textureName)         TextureCube_half textureName
#define TEXTURECUBE_ARRAY_HALF(textureName)   TextureCubeArray textureName  // no support to _float on Array, it's being added
#define TEXTURE3D_HALF(textureName)           Texture3D_half textureName

#define TEXTURE2D_SHADOW(textureName)         TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_SHADOW(textureName)   TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_SHADOW(textureName)       TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_SHADOW(textureName) TEXTURECUBE_ARRAY(textureName)

#define RW_TEXTURE2D(type, textureName)       RWTexture2D<type> textureName
#define RW_TEXTURE2D_ARRAY(type, textureName) RWTexture2DArray<type> textureName
#define RW_TEXTURE3D(type, textureName)       RWTexture3D<type> textureName

#define SAMPLER(samplerName)                  SamplerState samplerName
#define SAMPLER_CMP(samplerName)              SamplerComparisonState samplerName

#define TEXTURE2D_PARAM(textureName, samplerName)                 TEXTURE2D(textureName), SAMPLER(samplerName)
#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)           TEXTURE2D_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_PARAM(textureName, samplerName)               TEXTURECUBE(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)         TEXTURECUBE_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURE3D_PARAM(textureName, samplerName)                 TEXTURE3D(textureName), SAMPLER(samplerName)

#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)          TEXTURE2D(textureName), SAMPLER_CMP(samplerName)
#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)    TEXTURE2D_ARRAY(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)        TEXTURECUBE(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_ARRAY_SHADOW_PARAM(textureName, samplerName)  TEXTURECUBE_ARRAY(textureName), SAMPLER_CMP(samplerName)

#define TEXTURE2D_ARGS(textureName, samplerName)                textureName, samplerName
#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)          textureName, samplerName
#define TEXTURECUBE_ARGS(textureName, samplerName)              textureName, samplerName
#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)        textureName, samplerName
#define TEXTURE3D_ARGS(textureName, samplerName)                textureName, samplerName

#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)         textureName, samplerName
#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)   textureName, samplerName
#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)       textureName, samplerName
#define TEXTURECUBE_ARRAY_SHADOW_ARGS(textureName, samplerName) textureName, samplerName

#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod)                      textureName.SampleLevel(samplerName, coord2, lod)
#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                    textureName.SampleBias(samplerName, coord2, bias)
#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, dpdx, dpdy)              textureName.SampleGrad(samplerName, coord2, dpdx, dpdy)
#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                  textureName.Sample(samplerName, float3(coord2, index))
#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)         textureName.SampleLevel(samplerName, float3(coord2, index), lod)
#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)       textureName.SampleBias(samplerName, float3(coord2, index), bias)
#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy) textureName.SampleGrad(samplerName, float3(coord2, index), dpdx, dpdy)
#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                             textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                    textureName.SampleLevel(samplerName, coord3, lod)
#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                  textureName.SampleBias(samplerName, coord3, bias)
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)                textureName.Sample(samplerName, float4(coord3, index))
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)       textureName.SampleLevel(samplerName, float4(coord3, index), lod)
#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)     textureName.SampleBias(samplerName, float4(coord3, index), bias)
#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                               textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                      textureName.SampleLevel(samplerName, coord3, lod)

#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                    textureName.SampleCmpLevelZero(samplerName, (coord3).xy, (coord3).z)
#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)       textureName.SampleCmpLevelZero(samplerName, float3((coord3).xy, index), (coord3).z)
#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                  textureName.SampleCmpLevelZero(samplerName, (coord4).xyz, (coord4).w)
#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)     textureName.SampleCmpLevelZero(samplerName, float4((coord4).xyz, index), (coord4).w)

#define LOAD_TEXTURE2D(textureName, unCoord2)                       textureName.Load(int3(unCoord2, 0))
#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)              textureName.Load(int3(unCoord2, lod))
#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)     textureName.Load(unCoord2, sampleIndex)
#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)          textureName.Load(int4(unCoord2, index, 0))
#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod) textureName.Load(int4(unCoord2, index, lod))
#define LOAD_TEXTURE3D(textureName, unCoord3)                       textureName.Load(int4(unCoord3, 0))
#define LOAD_TEXTURE3D_LOD(textureName, unCoord3, lod)              textureName.Load(int4(unCoord3, lod))

#define PLATFORM_SUPPORT_GATHER
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                textureName.Gather(samplerName, coord2)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)   textureName.Gather(samplerName, float3(coord2, index))
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)              textureName.Gather(samplerName, coord3)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index) textureName.Gather(samplerName, float4(coord3, index))
#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)            textureName.GatherRed(samplerName, coord2)
#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherGreen(samplerName, coord2)
#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)           textureName.GatherBlue(samplerName, coord2)
#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherAlpha(samplerName, coord2)

#elif defined(SHADER_API_GLCORE)

// OpenGL 4.1 SM 5.0 https://docs.unity3d.com/Manual/SL-ShaderCompileTargets.html
#if (SHADER_TARGET >= 46)
#define OPENGL4_1_SM5 1
#else
#define OPENGL4_1_SM5 0
#endif

// Initialize arbitrary structure with zero values.
// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
#define ZERO_INITIALIZE(type, name) name = (type)0;
#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }

// Texture util abstraction

#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) textureName.CalculateLevelOfDetail(samplerName, coord2)

// Texture abstraction

#define TEXTURE2D(textureName)                  Texture2D textureName
#define TEXTURE2D_ARRAY(textureName)            Texture2DArray textureName
#define TEXTURECUBE(textureName)                TextureCube textureName
#define TEXTURECUBE_ARRAY(textureName)          TextureCubeArray textureName
#define TEXTURE3D(textureName)                  Texture3D textureName

#define TEXTURE2D_FLOAT(textureName)            TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_FLOAT(textureName)      TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_FLOAT(textureName)          TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_FLOAT(textureName)    TEXTURECUBE_ARRAY(textureName)
#define TEXTURE3D_FLOAT(textureName)            TEXTURE3D(textureName)

#define TEXTURE2D_HALF(textureName)             TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_HALF(textureName)       TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_HALF(textureName)           TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_HALF(textureName)     TEXTURECUBE_ARRAY(textureName)
#define TEXTURE3D_HALF(textureName)             TEXTURE3D(textureName)

#define TEXTURE2D_SHADOW(textureName)           TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_SHADOW(textureName)     TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_SHADOW(textureName)         TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_SHADOW(textureName)   TEXTURECUBE_ARRAY(textureName)

#define RW_TEXTURE2D(type, textureName)         RWTexture2D<type> textureName
#define RW_TEXTURE2D_ARRAY(type, textureName)   RWTexture2DArray<type> textureName
#define RW_TEXTURE3D(type, textureName)         RWTexture3D<type> textureName

#define SAMPLER(samplerName)                    SamplerState samplerName
#define SAMPLER_CMP(samplerName)                SamplerComparisonState samplerName

#define TEXTURE2D_PARAM(textureName, samplerName)                 TEXTURE2D(textureName), SAMPLER(samplerName)
#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)           TEXTURE2D_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_PARAM(textureName, samplerName)               TEXTURECUBE(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)         TEXTURECUBE_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURE3D_PARAM(textureName, samplerName)                 TEXTURE3D(textureName), SAMPLER(samplerName)

#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)          TEXTURE2D(textureName), SAMPLER_CMP(samplerName)
#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)    TEXTURE2D_ARRAY(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)        TEXTURECUBE(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_ARRAY_SHADOW_PARAM(textureName, samplerName)  TEXTURECUBE_ARRAY(textureName), SAMPLER_CMP(samplerName)

#define TEXTURE2D_ARGS(textureName, samplerName)                textureName, samplerName
#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)          textureName, samplerName
#define TEXTURECUBE_ARGS(textureName, samplerName)              textureName, samplerName
#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)        textureName, samplerName
#define TEXTURE3D_ARGS(textureName, samplerName)                textureName, samplerName

#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)         textureName, samplerName
#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)   textureName, samplerName
#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)       textureName, samplerName
#define TEXTURECUBE_ARRAY_SHADOW_ARGS(textureName, samplerName) textureName, samplerName

#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod)                      textureName.SampleLevel(samplerName, coord2, lod)
#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                    textureName.SampleBias(samplerName, coord2, bias)
#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, ddx, ddy)                textureName.SampleGrad(samplerName, coord2, ddx, ddy)
#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                  textureName.Sample(samplerName, float3(coord2, index))
#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)         textureName.SampleLevel(samplerName, float3(coord2, index), lod)
#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)       textureName.SampleBias(samplerName, float3(coord2, index), bias)
#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy) textureName.SampleGrad(samplerName, float3(coord2, index), dpdx, dpdy)
#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                             textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                    textureName.SampleLevel(samplerName, coord3, lod)
#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                  textureName.SampleBias(samplerName, coord3, bias)
#ifdef UNITY_NO_CUBEMAP_ARRAY
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)           ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY)
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)  ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY_LOD)
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, bias) ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY_LOD)
#else
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)           textureName.Sample(samplerName, float4(coord3, index))
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)  textureName.SampleLevel(samplerName, float4(coord3, index), lod)
#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)textureName.SampleBias(samplerName, float4(coord3, index), bias)
#endif
#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                          textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                 textureName.SampleLevel(samplerName, coord3, lod)

#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                   textureName.SampleCmpLevelZero(samplerName, (coord3).xy, (coord3).z)
#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)      textureName.SampleCmpLevelZero(samplerName, float3((coord3).xy, index), (coord3).z)
#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                 textureName.SampleCmpLevelZero(samplerName, (coord4).xyz, (coord4).w)
#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)    textureName.SampleCmpLevelZero(samplerName, float4((coord4).xyz, index), (coord4).w)

#define LOAD_TEXTURE2D(textureName, unCoord2)                                   textureName.Load(int3(unCoord2, 0))
#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)                          textureName.Load(int3(unCoord2, lod))
#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)                 textureName.Load(unCoord2, sampleIndex)
#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)                      textureName.Load(int4(unCoord2, index, 0))
#define LOAD_TEXTURE2D_ARRAY_MSAA(textureName, unCoord2, index, sampleIndex)    textureName.Load(int3(unCoord2, index), sampleIndex)
#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod)             textureName.Load(int4(unCoord2, index, lod))

#if OPENGL4_1_SM5
#define PLATFORM_SUPPORT_GATHER
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                  textureName.Gather(samplerName, coord2)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)     textureName.Gather(samplerName, float3(coord2, index))
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)                textureName.Gather(samplerName, coord3)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)   textureName.Gather(samplerName, float4(coord3, index))
#else
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                  ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURE2D)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)     ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURE2D_ARRAY)
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)                ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURECUBE)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)   ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURECUBE_ARRAY)
#endif

#elif defined(SHADER_API_GLES3)

// GLES 3.1 + AEP shader feature https://docs.unity3d.com/Manual/SL-ShaderCompileTargets.html
#if (SHADER_TARGET >= 40)
#define GLES3_1_AEP 1
#else
#define GLES3_1_AEP 0
#endif

// Initialize arbitrary structure with zero values.
// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
#define ZERO_INITIALIZE(type, name) name = (type)0;
#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }

// Texture util abstraction

#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) textureName.CalculateLevelOfDetail(samplerName, coord2)

// Texture abstraction

#define TEXTURE2D(textureName)                  Texture2D textureName
#define TEXTURE2D_ARRAY(textureName)            Texture2DArray textureName
#define TEXTURECUBE(textureName)                TextureCube textureName
#define TEXTURECUBE_ARRAY(textureName)          TextureCubeArray textureName
#define TEXTURE3D(textureName)                  Texture3D textureName

#define TEXTURE2D_FLOAT(textureName)            Texture2D_float textureName
#define TEXTURE2D_ARRAY_FLOAT(textureName)      Texture2DArray textureName    // no support to _float on Array, it's being added
#define TEXTURECUBE_FLOAT(textureName)          TextureCube_float textureName
#define TEXTURECUBE_ARRAY_FLOAT(textureName)    TextureCubeArray textureName  // no support to _float on Array, it's being added
#define TEXTURE3D_FLOAT(textureName)            Texture3D_float textureName

#define TEXTURE2D_HALF(textureName)             Texture2D_half textureName
#define TEXTURE2D_ARRAY_HALF(textureName)       Texture2DArray textureName    // no support to _float on Array, it's being added
#define TEXTURECUBE_HALF(textureName)           TextureCube_half textureName
#define TEXTURECUBE_ARRAY_HALF(textureName)     TextureCubeArray textureName  // no support to _float on Array, it's being added
#define TEXTURE3D_HALF(textureName)             Texture3D_half textureName

#define TEXTURE2D_SHADOW(textureName)           TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_SHADOW(textureName)     TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_SHADOW(textureName)         TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_SHADOW(textureName)   TEXTURECUBE_ARRAY(textureName)

#if GLES3_1_AEP
#define RW_TEXTURE2D(type, textureName)         RWTexture2D<type> textureName
#define RW_TEXTURE2D_ARRAY(type, textureName)   RWTexture2DArray<type> textureName
#define RW_TEXTURE3D(type, textureName)         RWTexture3D<type> textureName
#else
#define RW_TEXTURE2D(type, textureName)         ERROR_ON_UNSUPPORTED_FUNCTION(RWTexture2D)
#define RW_TEXTURE2D_ARRAY(type, textureName)   ERROR_ON_UNSUPPORTED_FUNCTION(RWTexture2DArray)
#define RW_TEXTURE3D(type, textureName)         ERROR_ON_UNSUPPORTED_FUNCTION(RWTexture3D)
#endif

#define SAMPLER(samplerName)                    SamplerState samplerName
#define SAMPLER_CMP(samplerName)                SamplerComparisonState samplerName

#define TEXTURE2D_PARAM(textureName, samplerName)                 TEXTURE2D(textureName), SAMPLER(samplerName)
#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)           TEXTURE2D_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_PARAM(textureName, samplerName)               TEXTURECUBE(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)         TEXTURECUBE_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURE3D_PARAM(textureName, samplerName)                 TEXTURE3D(textureName), SAMPLER(samplerName)

#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)          TEXTURE2D(textureName), SAMPLER_CMP(samplerName)
#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)    TEXTURE2D_ARRAY(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)        TEXTURECUBE(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_ARRAY_SHADOW_PARAM(textureName, samplerName)  TEXTURECUBE_ARRAY(textureName), SAMPLER_CMP(samplerName)

#define TEXTURE2D_ARGS(textureName, samplerName)                textureName, samplerName
#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)          textureName, samplerName
#define TEXTURECUBE_ARGS(textureName, samplerName)              textureName, samplerName
#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)        textureName, samplerName
#define TEXTURE3D_ARGS(textureName, samplerName)                textureName, samplerName

#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)         textureName, samplerName
#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)   textureName, samplerName
#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)       textureName, samplerName
#define TEXTURECUBE_ARRAY_SHADOW_ARGS(textureName, samplerName) textureName, samplerName

#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod)                      textureName.SampleLevel(samplerName, coord2, lod)
#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                    textureName.SampleBias(samplerName, coord2, bias)
#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, ddx, ddy)                textureName.SampleGrad(samplerName, coord2, ddx, ddy)
#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                  textureName.Sample(samplerName, float3(coord2, index))
#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)         textureName.SampleLevel(samplerName, float3(coord2, index), lod)
#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)       textureName.SampleBias(samplerName, float3(coord2, index), bias)
#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy) textureName.SampleGrad(samplerName, float3(coord2, index), dpdx, dpdy)
#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                             textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                    textureName.SampleLevel(samplerName, coord3, lod)
#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                  textureName.SampleBias(samplerName, coord3, bias)

#ifdef UNITY_NO_CUBEMAP_ARRAY
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)           ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY)
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)  ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY_LOD)
#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY_BIAS)
#else
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)           textureName.Sample(samplerName, float4(coord3, index))
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)  textureName.SampleLevel(samplerName, float4(coord3, index), lod)
#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)textureName.SampleBias(samplerName, float4(coord3, index), bias)
#endif

#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                          textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                 textureName.SampleLevel(samplerName, coord3, lod)

#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                   textureName.SampleCmpLevelZero(samplerName, (coord3).xy, (coord3).z)
#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)      textureName.SampleCmpLevelZero(samplerName, float3((coord3).xy, index), (coord3).z)
#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                 textureName.SampleCmpLevelZero(samplerName, (coord4).xyz, (coord4).w)
#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)    textureName.SampleCmpLevelZero(samplerName, float4((coord4).xyz, index), (coord4).w)

#define LOAD_TEXTURE2D(textureName, unCoord2)                                       textureName.Load(int3(unCoord2, 0))
#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)                              textureName.Load(int3(unCoord2, lod))
#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)                     textureName.Load(unCoord2, sampleIndex)
#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)                          textureName.Load(int4(unCoord2, index, 0))
#define LOAD_TEXTURE2D_ARRAY_MSAA(textureName, unCoord2, index, sampleIndex)        textureName.Load(int3(unCoord2, index), sampleIndex)
#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod)                 textureName.Load(int4(unCoord2, index, lod))
#define LOAD_TEXTURE3D(textureName, unCoord3)                                       textureName.Load(int4(unCoord3, 0))
#define LOAD_TEXTURE3D_LOD(textureName, unCoord3, lod)                              textureName.Load(int4(unCoord3, lod))

#if GLES3_1_AEP
#define PLATFORM_SUPPORT_GATHER
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                  textureName.Gather(samplerName, coord2)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)     textureName.Gather(samplerName, float3(coord2, index))
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)                textureName.Gather(samplerName, coord3)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)   textureName.Gather(samplerName, float4(coord3, index))
#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)              textureName.GatherRed(samplerName, coord2)
#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)            textureName.GatherGreen(samplerName, coord2)
#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)             textureName.GatherBlue(samplerName, coord2)
#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)            textureName.GatherAlpha(samplerName, coord2)
#else
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                  ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURE2D)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)     ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURE2D_ARRAY)
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)                ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURECUBE)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)   ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURECUBE_ARRAY)
#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)              ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_RED_TEXTURE2D)
#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)            ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_GREEN_TEXTURE2D)
#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)             ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_BLUE_TEXTURE2D)
#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)            ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_ALPHA_TEXTURE2D)
#endif

#elif defined(SHADER_API_GLES)

#define uint int

#define rcp(x) 1.0 / (x)
#define ddx_fine ddx
#define ddy_fine ddy
#define asfloat
#define asuint(x) asint(x)
#define f32tof16
#define f16tof32

#define ERROR_ON_UNSUPPORTED_FUNCTION(funcName) #error #funcName is not supported on GLES 2.0

// Initialize arbitrary structure with zero values.
// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
#define ZERO_INITIALIZE(type, name) name = (type)0;
#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }

// Texture util abstraction

#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) #error calculate Level of Detail not supported in GLES2

// Texture abstraction

#define TEXTURE2D(textureName)                          sampler2D textureName
#define TEXTURE2D_ARRAY(textureName)                    samplerCUBE textureName // No support to texture2DArray
#define TEXTURECUBE(textureName)                        samplerCUBE textureName
#define TEXTURECUBE_ARRAY(textureName)                  samplerCUBE textureName // No supoport to textureCubeArray and can't emulate with texture2DArray
#define TEXTURE3D(textureName)                          sampler3D textureName

#define TEXTURE2D_FLOAT(textureName)                    sampler2D_float textureName
#define TEXTURE2D_ARRAY_FLOAT(textureName)              TEXTURECUBE_FLOAT(textureName) // No support to texture2DArray
#define TEXTURECUBE_FLOAT(textureName)                  samplerCUBE_float textureName
#define TEXTURECUBE_ARRAY_FLOAT(textureName)            TEXTURECUBE_FLOAT(textureName) // No support to textureCubeArray
#define TEXTURE3D_FLOAT(textureName)                    sampler3D_float textureName

#define TEXTURE2D_HALF(textureName)                     sampler2D_half textureName
#define TEXTURE2D_ARRAY_HALF(textureName)               TEXTURECUBE_HALF(textureName) // No support to texture2DArray
#define TEXTURECUBE_HALF(textureName)                   samplerCUBE_half textureName
#define TEXTURECUBE_ARRAY_HALF(textureName)             TEXTURECUBE_HALF(textureName) // No support to textureCubeArray
#define TEXTURE3D_HALF(textureName)                     sampler3D_half textureName

#define TEXTURE2D_SHADOW(textureName)                   SHADOW2D_TEXTURE_AND_SAMPLER textureName
#define TEXTURE2D_ARRAY_SHADOW(textureName)             TEXTURECUBE_SHADOW(textureName) // No support to texture array
#define TEXTURECUBE_SHADOW(textureName)                 SHADOWCUBE_TEXTURE_AND_SAMPLER textureName
#define TEXTURECUBE_ARRAY_SHADOW(textureName)           TEXTURECUBE_SHADOW(textureName) // No support to texture array

#define RW_TEXTURE2D(type, textureNam)                  ERROR_ON_UNSUPPORTED_FUNCTION(RWTexture2D)
#define RW_TEXTURE2D_ARRAY(type, textureName)           ERROR_ON_UNSUPPORTED_FUNCTION(RWTexture2DArray)
#define RW_TEXTURE3D(type, textureNam)                  ERROR_ON_UNSUPPORTED_FUNCTION(RWTexture3D)

#define SAMPLER(samplerName)
#define SAMPLER_CMP(samplerName)

#define TEXTURE2D_PARAM(textureName, samplerName)                sampler2D textureName
#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)          samplerCUBE textureName
#define TEXTURECUBE_PARAM(textureName, samplerName)              samplerCUBE textureName
#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)        samplerCUBE textureName
#define TEXTURE3D_PARAM(textureName, samplerName)                sampler3D textureName
#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)         SHADOW2D_TEXTURE_AND_SAMPLER textureName
#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)   SHADOWCUBE_TEXTURE_AND_SAMPLER textureName
#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)       SHADOWCUBE_TEXTURE_AND_SAMPLER textureName

#define TEXTURE2D_ARGS(textureName, samplerName)               textureName
#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)         textureName
#define TEXTURECUBE_ARGS(textureName, samplerName)             textureName
#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)       textureName
#define TEXTURE3D_ARGS(textureName, samplerName)               textureName
#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)        textureName
#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)  textureName
#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)      textureName

#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2) tex2D(textureName, coord2)

#if (SHADER_TARGET >= 30)
#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod) tex2Dlod(textureName, float4(coord2, 0, lod))
#else
// No lod support. Very poor approximation with bias.
#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod) SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, lod)
#endif

#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                       tex2Dbias(textureName, float4(coord2, 0, bias))
#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, ddx, ddy)                   SAMPLE_TEXTURE2D(textureName, samplerName, coord2)
#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                     ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURE2D_ARRAY)
#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)            ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURE2D_ARRAY_LOD)
#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)          ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURE2D_ARRAY_BIAS)
#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy)    ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURE2D_ARRAY_GRAD)
#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                                texCUBE(textureName, coord3)
// No lod support. Very poor approximation with bias.
#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                       SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, lod)
#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                     texCUBEbias(textureName, float4(coord3, bias))
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)                   ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY)
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)          ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY_LOD)
#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)        ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY_BIAS)
#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                                  tex3D(textureName, coord3)
#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                         ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURE3D_LOD)

#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                           SHADOW2D_SAMPLE(textureName, samplerName, coord3)
#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)              ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURE2D_ARRAY_SHADOW)
#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                         SHADOWCUBE_SAMPLE(textureName, samplerName, coord4)
#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)            ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY_SHADOW)

// Not supported. Can't define as error because shader library is calling these functions.
#define LOAD_TEXTURE2D(textureName, unCoord2)                                               half4(0, 0, 0, 0)
#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)                                      half4(0, 0, 0, 0)
#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)                             half4(0, 0, 0, 0)
#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)                                  half4(0, 0, 0, 0)
#define LOAD_TEXTURE2D_ARRAY_MSAA(textureName, unCoord2, index, sampleIndex)                half4(0, 0, 0, 0)
#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod)                         half4(0, 0, 0, 0)
#define LOAD_TEXTURE3D(textureName, unCoord3)                                               ERROR_ON_UNSUPPORTED_FUNCTION(LOAD_TEXTURE3D)
#define LOAD_TEXTURE3D_LOD(textureName, unCoord3, lod)                                      ERROR_ON_UNSUPPORTED_FUNCTION(LOAD_TEXTURE3D_LOD)

// Gather not supported. Fallback to regular texture sampling.
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                  ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURE2D)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)     ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURE2D_ARRAY)
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)                ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURECUBE)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)   ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURECUBE_ARRAY)
#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)              ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_RED_TEXTURE2D)
#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)            ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_GREEN_TEXTURE2D)
#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)             ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_BLUE_TEXTURE2D)
#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)            ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_ALPHA_TEXTURE2D)

#else
#error unsupported shader api
#endif

// default flow control attributes
#ifndef UNITY_BRANCH
#   define UNITY_BRANCH
#endif
#ifndef UNITY_FLATTEN
#   define UNITY_FLATTEN
#endif
#ifndef UNITY_UNROLL
#   define UNITY_UNROLL
#endif
#ifndef UNITY_UNROLLX
#   define UNITY_UNROLLX(_x)
#endif
#ifndef UNITY_LOOP
#   define UNITY_LOOP
#endif

struct VertexData
{
float4 vertex : POSITION;
float3 normal : NORMAL;
float4 tangent : TANGENT;
float4 color : COLOR;
float2 uv0 : TEXCOORD0;
float2 uv1 : TEXCOORD1;
float2 uv2 : TEXCOORD2;
float2 uv3 : TEXCOORD3;
UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct FragmentData
{
#if defined(UNITY_PASS_SHADOWCASTER)
V2F_SHADOW_CASTER;
float2 uv0 : TEXCOORD1;
float2 uv1 : TEXCOORD2;
float2 uv2 : TEXCOORD3;
float2 uv3 : TEXCOORD4;
float3 worldPos : TEXCOORD5;
float3 worldNormal : TEXCOORD6;
float4 worldTangent : TEXCOORD7;
#else
float4 pos : SV_POSITION;
float3 normal : NORMAL;
float2 uv0 : TEXCOORD0;
float2 uv1 : TEXCOORD1;
float2 uv2 : TEXCOORD2;
float2 uv3 : TEXCOORD3;
float3 worldPos : TEXCOORD4;
float3 worldNormal : TEXCOORD5;
float4 worldTangent : TEXCOORD6;
float4 lightmapUv : TEXCOORD7;
float4 vertexColor : TEXCOORD8;

#if !defined(UNITY_PASS_META)
UNITY_LIGHTING_COORDS(9, 10)
UNITY_FOG_COORDS(11)
#endif
#endif

#if defined(EDITOR_VISUALIZATION)
float2 vizUV : TEXCOORD9;
float4 lightCoord : TEXCOORD10;
#endif

#if defined(NEED_SCREEN_POS)
float4 screenPos: SCREENPOS;
#endif

#if defined(EXTRA_V2F_0)
#if defined(UNITY_PASS_SHADOWCASTER)
float4 extraV2F0 : TEXCOORD8;
#else
#if !defined(UNITY_PASS_META)
float4 extraV2F0 : TEXCOORD12;
#else
#if defined(EDITOR_VISUALIZATION)
float4 extraV2F0 : TEXCOORD11;
#else
float4 extraV2F0 : TEXCOORD9;
#endif
#endif
#endif
#endif
#if defined(EXTRA_V2F_1)
#if defined(UNITY_PASS_SHADOWCASTER)
float4 extraV2F1 : TEXCOORD9;
#else
#if !defined(UNITY_PASS_META)
float4 extraV2F1 : TEXCOORD13;
#else
#if defined(EDITOR_VISUALIZATION)
float4 extraV2F1 : TEXCOORD14;
#else
float4 extraV2F1 : TEXCOORD15;
#endif
#endif
#endif
#endif
#if defined(EXTRA_V2F_2)
#if defined(UNITY_PASS_SHADOWCASTER)
float4 extraV2F2 : TEXCOORD10;
#else
#if !defined(UNITY_PASS_META)
float4 extraV2F2 : TEXCOORD14;
#else
#if defined(EDITOR_VISUALIZATION)
float4 extraV2F2 : TEXCOORD15
#else
float4 extraV2F2 : TEXCOORD16;
#endif
#endif
#endif
#endif

UNITY_VERTEX_INPUT_INSTANCE_ID
UNITY_VERTEX_OUTPUT_STEREO
};

struct MeshData
{
half2 uv0;
half2 uv1;
half2 uv2;
half2 uv3;
half3 vertexColor;
half3 normal;
half3 worldNormal;
half3 localSpacePosition;
half3 worldSpacePosition;
half3 worldSpaceViewDir;
half3 tangentSpaceViewDir;
half3 worldSpaceTangent;
float3 bitangent;
float3x3 TBNMatrix;
half3 svdn;
float4 extraV2F0;
float4 extraV2F1;
float4 extraV2F2;
float4 screenPos;
};

MeshData CreateMeshData(FragmentData i)
{
MeshData m = (MeshData) 0;
m.uv0 = i.uv0;
m.uv1 = i.uv1;
m.uv2 = i.uv2;
m.uv3 = i.uv3;
m.worldNormal = normalize(i.worldNormal);
m.localSpacePosition = mul(unity_WorldToObject, float4(i.worldPos, 1)).xyz;
m.worldSpacePosition = i.worldPos;
m.worldSpaceViewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

#if !defined(UNITY_PASS_SHADOWCASTER)
m.vertexColor = i.vertexColor;
m.normal = i.normal;
m.bitangent = cross(i.worldTangent.xyz, i.worldNormal) * i.worldTangent.w * - 1;
m.worldSpaceTangent = i.worldTangent.xyz;
m.TBNMatrix = float3x3(normalize(i.worldTangent.xyz), m.bitangent, m.worldNormal);
m.tangentSpaceViewDir = mul(m.TBNMatrix, m.worldSpaceViewDir);
#endif

#if UNITY_SINGLE_PASS_STEREO
half3 stereoCameraPos = half3((unity_StereoWorldSpaceCameraPos[0]+ unity_StereoWorldSpaceCameraPos[1])*.5);
m.svdn = normalize(stereoCameraPos - m.worldSpacePosition);
#else
m.svdn = m.worldSpaceViewDir;
#endif

#if defined(EXTRA_V2F_0)
m.extraV2F0 = i.extraV2F0;
#endif
#if defined(EXTRA_V2F_1)
m.extraV2F1 = i.extraV2F1;
#endif
#if defined(EXTRA_V2F_2)
m.extraV2F2 = i.extraV2F2;
#endif
#if defined(NEED_SCREEN_POS)
m.screenPos = i.screenPos;
#endif

return m;
}

struct SurfaceData
{
half3 Albedo;
half3 Emission;
int EmissionScaleWithLight;
half EmissionLightThreshold;
half Metallic;
half Smoothness;
half Occlusion;
int OcclusionMode;
half3 Normal;
half Alpha;
half Anisotropy;
half ShadowSharpness;
half4 RimLight;
half RimAttenuation;
half4 RimShadow;
half SpecularIntensity;
half SpecularArea;
half SpecularAlbedoTint;
half SpecularAnisotropy;
half SpecularSharpness;
half Reflectivity;
half3 BakedReflection;
int ReflectionBlendMode;
int EnableReflections;
half3 OutlineColor;
int OutlineLightingMode;
};

FragmentData FragData;
SurfaceData o;
MeshData d;
VertexData vD;
float4 FinalColor;

half invLerp(half a, half b, half v)
{
return (v - a) / (b - a);
}

half getBakedNoise(Texture2D noiseTex, SamplerState noiseTexSampler, half3 p)
{
half3 i = floor(p); p -= i; p *= p * (3. - 2. * p);
half2 uv = (p.xy + i.xy + half2(37, 17) * i.z + .5) / 256.;
uv.y *= -1;
p.xy = noiseTex.SampleLevel(noiseTexSampler, uv, 0).yx;
return lerp(p.x, p.y, p.z);
}

half3 TransformObjectToWorld(half3 pos)
{
return mul(unity_ObjectToWorld, half4(pos, 1)).xyz;
};

// mostly taken from the Amplify shader reference
half2 POM(Texture2D heightMap, SamplerState heightSampler, half2 uvs, half2 dx, half2 dy, half3 normalWorld, half3 viewWorld, half3 viewDirTan, int minSamples, int maxSamples, half parallax, half refPlane, half2 tilling, half2 curv, int index, inout half finalHeight)
{
half3 result = 0;
int stepIndex = 0;
int numSteps = (int)lerp((half)maxSamples, (half)minSamples, saturate(dot(normalWorld, viewWorld)));
half layerHeight = 1.0 / numSteps;
half2 plane = parallax * (viewDirTan.xy / viewDirTan.z);
uvs.xy += refPlane * plane;
half2 deltaTex = -plane * layerHeight;
half2 prevTexOffset = 0;
half prevRayZ = 1.0f;
half prevHeight = 0.0f;
half2 currTexOffset = deltaTex;
half currRayZ = 1.0f - layerHeight;
half currHeight = 0.0f;
half intersection = 0;
half2 finalTexOffset = 0;
while (stepIndex < numSteps + 1)
{
currHeight = SAMPLE_TEXTURE2D_GRAD(heightMap, heightSampler, uvs + currTexOffset, dx, dy).r;
if (currHeight > currRayZ)
{
stepIndex = numSteps + 1;
}
else
{
stepIndex++;
prevTexOffset = currTexOffset;
prevRayZ = currRayZ;
prevHeight = currHeight;
currTexOffset += deltaTex;
currRayZ -= layerHeight;
}
}
int sectionSteps = 2;
int sectionIndex = 0;
half newZ = 0;
half newHeight = 0;
while (sectionIndex < sectionSteps)
{
intersection = (prevHeight - prevRayZ) / (prevHeight - currHeight + currRayZ - prevRayZ);
finalTexOffset = prevTexOffset +intersection * deltaTex;
newZ = prevRayZ - intersection * layerHeight;
newHeight = SAMPLE_TEXTURE2D_GRAD(heightMap, heightSampler, uvs + finalTexOffset, dx, dy).r;
if (newHeight > newZ)
{
currTexOffset = finalTexOffset;
currHeight = newHeight;
currRayZ = newZ;
deltaTex = intersection * deltaTex;
layerHeight = intersection * layerHeight;
}
else
{
prevTexOffset = finalTexOffset;
prevHeight = newHeight;
prevRayZ = newZ;
deltaTex = (1 - intersection) * deltaTex;
layerHeight = (1 - intersection) * layerHeight;
}
sectionIndex++;
}
finalHeight = newHeight;
return uvs.xy + finalTexOffset;
}

half remap(half s, half a1, half a2, half b1, half b2)
{
return b1 + (s - a1) * (b2 - b1) / (a2 - a1);
}

half3 ApplyLut2D(Texture2D LUT2D, SamplerState lutSampler, half3 uvw)
{
half3 scaleOffset = half3(1.0 / 1024.0, 1.0 / 32.0, 31.0);
// Strip format where `height = sqrt(width)`
uvw.z *= scaleOffset.z;
half shift = floor(uvw.z);
uvw.xy = uvw.xy * scaleOffset.z * scaleOffset.xy + scaleOffset.xy * 0.5;
uvw.x += shift * scaleOffset.y;
uvw.xyz = lerp(
SAMPLE_TEXTURE2D(LUT2D, lutSampler, uvw.xy).rgb,
SAMPLE_TEXTURE2D(LUT2D, lutSampler, uvw.xy + half2(scaleOffset.y, 0.0)).rgb,
uvw.z - shift
);
return uvw;
}

half3 AdjustContrast(half3 color, half contrast)
{
color = saturate(lerp(half3(0.5, 0.5, 0.5), color, contrast));
return color;
}

half3 AdjustSaturation(half3 color, half saturation)
{
half3 intensity = dot(color.rgb, half3(0.299, 0.587, 0.114));
color = lerp(intensity, color.rgb, saturation);
return color;
}

half3 AdjustBrightness(half3 color, half brightness)
{
color += brightness;
return color;
}

struct ParamsLogC
{
half cut;
half a, b, c, d, e, f;
};

static const ParamsLogC LogC = {
0.011361, // cut
5.555556, // a
0.047996, // b
0.244161, // c
0.386036, // d
5.301883, // e
0.092819  // f

};

half LinearToLogC_Precise(half x)
{
half o;
if (x > LogC.cut)
o = LogC.c * log10(LogC.a * x + LogC.b) + LogC.d;
else
o = LogC.e * x + LogC.f;
return o;
}

half PositivePow(half base, half power)
{
return pow(max(abs(base), half(FLT_EPSILON)), power);
}

half3 LinearToLogC(half3 x)
{
return LogC.c * log10(LogC.a * x + LogC.b) + LogC.d;
}

half3 LinerToSRGB(half3 c)
{
return c * (c * (c * 0.305306011 + 0.682171111) + 0.012522878);
}

half3 SRGBToLiner(half3 c)
{
return max(1.055 * PositivePow(c, 0.416666667) - 0.055, 0.0);
}

half3 LogCToLinear(half3 c)
{
return (pow(10.0, (c - LogC.d) / LogC.c) - LogC.b) / LogC.a;
}

// Specular stuff taken from https://github.com/z3y/shaders/
float pow5(float x)
{
float x2 = x * x;
return x2 * x2 * x;
}

float sq(float x)
{
return x * x;
}

struct Gradient
{
int type;
int colorsLength;
int alphasLength;
half4 colors[8];
half2 alphas[8];
};

Gradient NewGradient(int type, int colorsLength, int alphasLength,
half4 colors0, half4 colors1, half4 colors2, half4 colors3, half4 colors4, half4 colors5, half4 colors6, half4 colors7,
half2 alphas0, half2 alphas1, half2 alphas2, half2 alphas3, half2 alphas4, half2 alphas5, half2 alphas6, half2 alphas7)
{
Gradient g;
g.type = type;
g.colorsLength = colorsLength;
g.alphasLength = alphasLength;
g.colors[ 0 ] = colors0;
g.colors[ 1 ] = colors1;
g.colors[ 2 ] = colors2;
g.colors[ 3 ] = colors3;
g.colors[ 4 ] = colors4;
g.colors[ 5 ] = colors5;
g.colors[ 6 ] = colors6;
g.colors[ 7 ] = colors7;
g.alphas[ 0 ] = alphas0;
g.alphas[ 1 ] = alphas1;
g.alphas[ 2 ] = alphas2;
g.alphas[ 3 ] = alphas3;
g.alphas[ 4 ] = alphas4;
g.alphas[ 5 ] = alphas5;
g.alphas[ 6 ] = alphas6;
g.alphas[ 7 ] = alphas7;
return g;
}

half4 SampleGradient(Gradient gradient, half time)
{
half3 color = gradient.colors[0].rgb;
UNITY_UNROLL
for (int c = 1; c < 8; c++)
{
half colorPos = saturate((time - gradient.colors[c - 1].w) / (0.00001 + (gradient.colors[c].w - gradient.colors[c - 1].w)) * step(c, (half)gradient.colorsLength - 1));
color = lerp(color, gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), gradient.type));
}
#ifndef UNITY_COLORSPACE_GAMMA
color = half3(GammaToLinearSpaceExact(color.r), GammaToLinearSpaceExact(color.g), GammaToLinearSpaceExact(color.b));
#endif
half alpha = gradient.alphas[0].x;
UNITY_UNROLL
for (int a = 1; a < 8; a++)
{
half alphaPos = saturate((time - gradient.alphas[a - 1].y) / (0.00001 + (gradient.alphas[a].y - gradient.alphas[a - 1].y)) * step(a, (half)gradient.alphasLength - 1));
alpha = lerp(alpha, gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), gradient.type));
}
return half4(color, alpha);
}

float3 RotateAroundAxis(float3 center, float3 original, float3 u, float angle)
{
original -= center;
float C = cos(angle);
float S = sin(angle);
float t = 1 - C;
float m00 = t * u.x * u.x + C;
float m01 = t * u.x * u.y - S * u.z;
float m02 = t * u.x * u.z + S * u.y;
float m10 = t * u.x * u.y + S * u.z;
float m11 = t * u.y * u.y + C;
float m12 = t * u.y * u.z - S * u.x;
float m20 = t * u.x * u.z - S * u.y;
float m21 = t * u.y * u.z + S * u.x;
float m22 = t * u.z * u.z + C;
float3x3 finalMatrix = float3x3(m00, m01, m02, m10, m11, m12, m20, m21, m22);
return mul(finalMatrix, original) + center;
}

// Map of where features in AudioLink are.
#define ALPASS_DFT                      uint2(0, 4)  //Size: 128, 2
#define ALPASS_WAVEFORM                 uint2(0, 6)  //Size: 128, 16
#define ALPASS_AUDIOLINK                uint2(0, 0)  //Size: 128, 4
#define ALPASS_AUDIOBASS                uint2(0, 0)  //Size: 128, 1
#define ALPASS_AUDIOLOWMIDS             uint2(0, 1)  //Size: 128, 1
#define ALPASS_AUDIOHIGHMIDS            uint2(0, 2)  //Size: 128, 1
#define ALPASS_AUDIOTREBLE              uint2(0, 3)  //Size: 128, 1
#define ALPASS_AUDIOLINKHISTORY         uint2(1, 0)  //Size: 127, 4
#define ALPASS_GENERALVU                uint2(0, 22) //Size: 12, 1
#define ALPASS_GENERALVU_INSTANCE_TIME  uint2(2, 22)
#define ALPASS_GENERALVU_LOCAL_TIME     uint2(3, 22)
#define ALPASS_GENERALVU_NETWORK_TIME   uint2(4, 22)
#define ALPASS_GENERALVU_PLAYERINFO     uint2(6, 22)
#define ALPASS_THEME_COLOR0             uint2(0, 23)
#define ALPASS_THEME_COLOR1             uint2(1, 23)
#define ALPASS_THEME_COLOR2             uint2(2, 23)
#define ALPASS_THEME_COLOR3             uint2(3, 23)
#define ALPASS_CCINTERNAL               uint2(12, 22) //Size: 12, 2
#define ALPASS_CCCOLORS                 uint2(25, 22) //Size: 12, 1 (Note Color #0 is always black, Colors start at 1)
#define ALPASS_CCSTRIP                  uint2(0, 24)  //Size: 128, 1
#define ALPASS_CCLIGHTS                 uint2(0, 25)  //Size: 128, 2
#define ALPASS_AUTOCORRELATOR           uint2(0, 27)  //Size: 128, 1
#define ALPASS_FILTEREDAUDIOLINK        uint2(0, 28)  //Size: 16, 4
#define ALPASS_CHRONOTENSITY            uint2(16, 28) //Size: 8, 4
#define ALPASS_FILTEREDVU               uint2(24, 28) //Size: 4, 4
#define ALPASS_FILTEREDVU_INTENSITY     uint2(24, 28) //Size: 4, 1
#define ALPASS_FILTEREDVU_MARKER        uint2(24, 29) //Size: 4, 1

// Some basic constants to use (Note, these should be compatible with
// future version of AudioLink, but may change.
#define AUDIOLINK_SAMPHIST              3069        // Internal use for algos, do not change.
#define AUDIOLINK_SAMPLEDATA24          2046
#define AUDIOLINK_EXPBINS               24
#define AUDIOLINK_EXPOCT                10
#define AUDIOLINK_ETOTALBINS (AUDIOLINK_EXPBINS * AUDIOLINK_EXPOCT)
#define AUDIOLINK_WIDTH                 128
#define AUDIOLINK_SPS                   48000       // Samples per second
#define AUDIOLINK_ROOTNOTE              0
#define AUDIOLINK_4BAND_FREQFLOOR       0.123
#define AUDIOLINK_4BAND_FREQCEILING     1
#define AUDIOLINK_BOTTOM_FREQUENCY      13.75
#define AUDIOLINK_BASE_AMPLITUDE        2.5
#define AUDIOLINK_DELAY_COEFFICIENT_MIN 0.3
#define AUDIOLINK_DELAY_COEFFICIENT_MAX 0.9
#define AUDIOLINK_DFT_Q                 4.0
#define AUDIOLINK_TREBLE_CORRECTION     5.0
#define AUDIOLINK_4BAND_TARGET_RATE     90.0

// ColorChord constants
#define COLORCHORD_EMAXBIN              192
#define COLORCHORD_NOTE_CLOSEST         3.0
#define COLORCHORD_NEW_NOTE_GAIN        8.0
#define COLORCHORD_MAX_NOTES            10

// We use glsl_mod for most calculations because it behaves better
// on negative numbers, and in some situations actually outperforms
// HLSL's modf().
#ifndef glsl_mod
#define glsl_mod(x, y) (((x) - (y) * floor((x) / (y))))
#endif

uniform float4               _AudioTexture_TexelSize;

#ifdef SHADER_TARGET_SURFACE_ANALYSIS
#define AUDIOLINK_STANDARD_INDEXING
#endif

// Mechanism to index into texture.
#ifdef AUDIOLINK_STANDARD_INDEXING
sampler2D _AudioTexture;
#define AudioLinkData(xycoord) tex2Dlod(_AudioTexture, float4(uint2(xycoord) * _AudioTexture_TexelSize.xy, 0, 0))
#else
uniform Texture2D<float4> _AudioTexture;
#define AudioLinkData(xycoord) _AudioTexture[uint2(xycoord)]
#endif

// Convenient mechanism to read from the AudioLink texture that handles reading off the end of one line and onto the next above it.
float4 AudioLinkDataMultiline(uint2 xycoord)
{
return AudioLinkData(uint2(xycoord.x % AUDIOLINK_WIDTH, xycoord.y + xycoord.x / AUDIOLINK_WIDTH));
}

// Mechanism to sample between two adjacent pixels and lerp between them, like "linear" supesampling
float4 AudioLinkLerp(float2 xy)
{
return lerp(AudioLinkData(xy), AudioLinkData(xy + int2(1, 0)), frac(xy.x));
}

// Same as AudioLinkLerp but properly handles multiline reading.
float4 AudioLinkLerpMultiline(float2 xy)
{
return lerp(AudioLinkDataMultiline(xy), AudioLinkDataMultiline(xy + float2(1, 0)), frac(xy.x));
}

//Tests to see if Audio Link texture is available
bool AudioLinkIsAvailable()
{
#if !defined(AUDIOLINK_STANDARD_INDEXING)
int width, height;
_AudioTexture.GetDimensions(width, height);
return width > 16;
#else
return _AudioTexture_TexelSize.z > 16;
#endif
}

//Get version of audiolink present in the world, 0 if no audiolink is present
float AudioLinkGetVersion()
{
int2 dims;
#if !defined(AUDIOLINK_STANDARD_INDEXING)
_AudioTexture.GetDimensions(dims.x, dims.y);
#else
dims = _AudioTexture_TexelSize.zw;
#endif

if (dims.x >= 128)
return AudioLinkData(ALPASS_GENERALVU).x;
else if (dims.x > 16)
return 1;
else
return 0;
}

// This pulls data from this texture.
#define AudioLinkGetSelfPixelData(xy) _SelfTexture2D[xy]

// Extra utility functions for time.
uint AudioLinkDecodeDataAsUInt(uint2 indexloc)
{
uint4 rpx = AudioLinkData(indexloc);
return rpx.r + rpx.g * 1024 + rpx.b * 1048576 + rpx.a * 1073741824;
}

//Note: This will truncate time to every 134,217.728 seconds (~1.5 days of an instance being up) to prevent floating point aliasing.
// if your code will alias sooner, you will need to use a different function.  It should be safe to use this on all times.
float AudioLinkDecodeDataAsSeconds(uint2 indexloc)
{
uint time = AudioLinkDecodeDataAsUInt(indexloc) & 0x7ffffff;
//Can't just divide by float.  Bug in Unity's HLSL compiler.
return float(time / 1000) + float(time % 1000) / 1000.;
}

#define ALDecodeDataAsSeconds(x) AudioLinkDecodeDataAsSeconds(x)
#define ALDecodeDataAsUInt(x) AudioLinkDecodeDataAsUInt(x)

float AudioLinkRemap(float t, float a, float b, float u, float v)
{
return ((t - a) / (b - a)) * (v - u) + u;
}

float3 AudioLinkHSVtoRGB(float3 HSV)
{
float3 RGB = 0;
float C = HSV.z * HSV.y;
float H = HSV.x * 6;
float X = C * (1 - abs(fmod(H, 2) - 1));
if (HSV.y != 0)
{
float I = floor(H);
if (I == 0)
{
RGB = float3(C, X, 0);
}
else if (I == 1)
{
RGB = float3(X, C, 0);
}
else if (I == 2)
{
RGB = float3(0, C, X);
}
else if (I == 3)
{
RGB = float3(0, X, C);
}
else if (I == 4)
{
RGB = float3(X, 0, C);
}
else
{
RGB = float3(C, 0, X);
}
}
float M = HSV.z - C;
return RGB + M;
}

float3 AudioLinkCCtoRGB(float bin, float intensity, int rootNote)
{
float note = bin / AUDIOLINK_EXPBINS;

float hue = 0.0;
note *= 12.0;
note = glsl_mod(4. - note + rootNote, 12.0);
{
if (note < 4.0)
{
//Needs to be YELLOW->RED
hue = (note) / 24.0;
}
else if (note < 8.0)
{
//            [4]  [8]
//Needs to be RED->BLUE
hue = (note - 2.0) / 12.0;
}
else
{
//             [8] [12]
//Needs to be BLUE->YELLOW
hue = (note - 4.0) / 8.0;
}
}
float val = intensity - 0.1;
return AudioLinkHSVtoRGB(float3(fmod(hue, 1.0), 1.0, clamp(val, 0.0, 1.0)));
}

// Sample the amplitude of a given frequency in the DFT, supports frequencies in [13.75; 14080].
float4 AudioLinkGetAmplitudeAtFrequency(float hertz)
{
float note = AUDIOLINK_EXPBINS * log2(hertz / AUDIOLINK_BOTTOM_FREQUENCY);
return AudioLinkLerpMultiline(ALPASS_DFT + float2(note, 0));
}

// Sample the amplitude of a given semitone in an octave. Octave is in [0; 9] while note is [0; 11].
float AudioLinkGetAmplitudeAtNote(float octave, float note)
{
float quarter = note * 2.0;
return AudioLinkLerpMultiline(ALPASS_DFT + float2(octave * AUDIOLINK_EXPBINS + quarter, 0));
}

// Get a reasonable drop-in replacement time value for _Time.y with the
// given chronotensity index [0; 7] and AudioLink band [0; 3].
float AudioLinkGetChronoTime(uint index, uint band)
{
return (AudioLinkDecodeDataAsUInt(ALPASS_CHRONOTENSITY + uint2(index, band))) / 100000.0;
}

// Get a chronotensity value in the interval [0; 1], modulated by the speed input,
// with the given chronotensity index [0; 7] and AudioLink band [0; 3].
float AudioLinkGetChronoTimeNormalized(uint index, uint band, float speed)
{
return frac(AudioLinkGetChronoTime(index, band) * speed);
}

// Get a chronotensity value in the interval [0; interval], modulated by the speed input,
// with the given chronotensity index [0; 7] and AudioLink band [0; 3].
float AudioLinkGetChronoTimeInterval(uint index, uint band, float speed, float interval)
{
return AudioLinkGetChronoTimeNormalized(index, band, speed) * interval;
}
half D_GGX(half NoH, half roughness)
{
half a = NoH * roughness;
half k = roughness / (1.0 - NoH * NoH + a * a);
return k * k * (1.0 / UNITY_PI);
}

half D_GGX_Anisotropic(half NoH, const half3 h, const half3 t, const half3 b, half at, half ab)
{
half ToH = dot(t, h);
half BoH = dot(b, h);
half a2 = at * ab;
half3 v = half3(ab * ToH, at * BoH, a2 * NoH);
half v2 = dot(v, v);
half w2 = a2 / v2;
return a2 * w2 * w2 * (1.0 / UNITY_PI);
}

half V_SmithGGXCorrelated(half NoV, half NoL, half roughness)
{
half a2 = roughness * roughness;
half GGXV = NoL * sqrt(NoV * NoV * (1.0 - a2) + a2);
half GGXL = NoV * sqrt(NoL * NoL * (1.0 - a2) + a2);
return 0.5 / (GGXV + GGXL);
}

half3 F_Schlick(half u, half3 f0)
{
return f0 + (1.0 - f0) * pow(1.0 - u, 5.0);
}

half3 F_Schlick(half3 f0, half f90, half VoH)
{
// Schlick 1994, "An Inexpensive BRDF Model for Physically-Based Rendering"
return f0 + (f90 - f0) * pow(1.0 - VoH, 5);
}

half3 fresnel(half3 f0, half LoH)
{
half f90 = saturate(dot(f0, half(50.0 / 3).xxx));
return F_Schlick(f0, f90, LoH);
}

half Fd_Burley(half perceptualRoughness, half NoV, half NoL, half LoH)
{
// Burley 2012, "Physically-Based Shading at Disney"
half f90 = 0.5 + 2.0 * perceptualRoughness * LoH * LoH;
half lightScatter = F_Schlick(1.0, f90, NoL);
half viewScatter = F_Schlick(1.0, f90, NoV);
return lightScatter * viewScatter;
}

half3 getBoxProjection(half3 direction, half3 position, half4 cubemapPosition, half3 boxMin, half3 boxMax)
{
#if defined(UNITY_SPECCUBE_BOX_PROJECTION) && !defined(UNITY_PBS_USE_BRDF2) || defined(FORCE_BOX_PROJECTION)
if (cubemapPosition.w > 0)
{
half3 factors = ((direction > 0 ? boxMax : boxMin) - position) / direction;
half scalar = min(min(factors.x, factors.y), factors.z);
direction = direction * scalar + (position - cubemapPosition.xyz);
}
#endif

return direction;
}

half3 getEnvReflection(half3 worldSpaceViewDir, half3 worldSpacePosition, half3 normal, half smoothness, int mip)
{
half3 env = 0;
half3 reflDir = reflect(worldSpaceViewDir, normal);
half perceptualRoughness = 1 - smoothness;
half rough = perceptualRoughness * perceptualRoughness;
reflDir = lerp(reflDir, normal, rough * rough);

half3 reflectionUV1 = getBoxProjection(reflDir, worldSpacePosition, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin.xyz, unity_SpecCube0_BoxMax.xyz);
half4 probe0 = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectionUV1, mip);
half3 probe0sample = DecodeHDR(probe0, unity_SpecCube0_HDR);

half3 indirectSpecular;
half interpolator = unity_SpecCube0_BoxMin.w;

UNITY_BRANCH
if (interpolator < 0.99999)
{
half3 reflectionUV2 = getBoxProjection(reflDir, worldSpacePosition, unity_SpecCube1_ProbePosition, unity_SpecCube1_BoxMin.xyz, unity_SpecCube1_BoxMax.xyz);
half4 probe1 = UNITY_SAMPLE_TEXCUBE_SAMPLER_LOD(unity_SpecCube1, unity_SpecCube0, reflectionUV2, mip);
half3 probe1sample = DecodeHDR(probe1, unity_SpecCube1_HDR);
indirectSpecular = lerp(probe1sample, probe0sample, interpolator);
}
else
{
indirectSpecular = probe0sample;
}

env = indirectSpecular;
return env;
}

half3 EnvBRDFMultiscatter(half2 dfg, half3 f0)
{
return lerp(dfg.xxx, dfg.yyy, f0);
}

half3 EnvBRDFApprox(half perceptualRoughness, half NoV, half3 f0)
{
half g = 1 - perceptualRoughness;
//https://blog.selfshadow.com/publications/s2013-shading-course/lazarov/s2013_pbs_black_ops_2_notes.pdf
half4 t = half4(1 / 0.96, 0.475, (0.0275 - 0.25 * 0.04) / 0.96, 0.25);
t *= half4(g, g, g, g);
t += half4(0, 0, (0.015 - 0.75 * 0.04) / 0.96, 0.75);
half a0 = t.x * min(t.y, exp2(-9.28 * NoV)) + t.z;
half a1 = t.w;
return saturate(lerp(a0, a1, f0));
}

half GSAA_Filament(half3 worldNormal, half perceptualRoughness, half inputVariance, half threshold)
{
// Kaplanyan 2016, "Stable specular highlights"
// Tokuyoshi 2017, "Error Reduction and Simplification for Shading Anti-Aliasing"
// Tokuyoshi and Kaplanyan 2019, "Improved Geometric Specular Antialiasing"

// This implementation is meant for deferred rendering in the original paper but
// we use it in forward rendering as well (as discussed in Tokuyoshi and Kaplanyan
// 2019). The main reason is that the forward version requires an expensive transform
// of the half vector by the tangent frame for every light. This is therefore an
// approximation but it works well enough for our needs and provides an improvement
// over our original implementation based on Vlachos 2015, "Advanced VR Rendering".

half3 du = ddx(worldNormal);
half3 dv = ddy(worldNormal);

half variance = inputVariance * (dot(du, du) + dot(dv, dv));

half roughness = perceptualRoughness * perceptualRoughness;
half kernelRoughness = min(2.0 * variance, threshold);
half squareRoughness = saturate(roughness * roughness + kernelRoughness);

return sqrt(sqrt(squareRoughness));
}

// w0, w1, w2, and w3 are the four cubic B-spline basis functions
half w0(half a)
{
//    return (1.0f/6.0f)*(-a*a*a + 3.0f*a*a - 3.0f*a + 1.0f);
return (1.0f / 6.0f) * (a * (a * (-a + 3.0f) - 3.0f) + 1.0f);   // optimized

}

half w1(half a)
{
//    return (1.0f/6.0f)*(3.0f*a*a*a - 6.0f*a*a + 4.0f);
return (1.0f / 6.0f) * (a * a * (3.0f * a - 6.0f) + 4.0f);
}

half w2(half a)
{
//    return (1.0f/6.0f)*(-3.0f*a*a*a + 3.0f*a*a + 3.0f*a + 1.0f);
return (1.0f / 6.0f) * (a * (a * (-3.0f * a + 3.0f) + 3.0f) + 1.0f);
}

half w3(half a)
{
return (1.0f / 6.0f) * (a * a * a);
}

// g0 and g1 are the two amplitude functions
half g0(half a)
{
return w0(a) + w1(a);
}

half g1(half a)
{
return w2(a) + w3(a);
}

// h0 and h1 are the two offset functions
half h0(half a)
{
// note +0.5 offset to compensate for CUDA linear filtering convention
return -1.0f + w1(a) / (w0(a) + w1(a)) + 0.5f;
}

half h1(half a)
{
return 1.0f + w3(a) / (w2(a) + w3(a)) + 0.5f;
}

//https://ndotl.wordpress.com/2018/08/29/baking-artifact-free-lightmaps
half3 tex2DFastBicubicLightmap(half2 uv, inout half4 bakedColorTex)
{
#if !defined(PLAT_QUEST) && defined(BICUBIC_LIGHTMAP)
half width;
half height;
unity_Lightmap.GetDimensions(width, height);
half x = uv.x * width;
half y = uv.y * height;

x -= 0.5f;
y -= 0.5f;
half px = floor(x);
half py = floor(y);
half fx = x - px;
half fy = y - py;

// note: we could store these functions in a lookup table texture, but maths is cheap
half g0x = g0(fx);
half g1x = g1(fx);
half h0x = h0(fx);
half h1x = h1(fx);
half h0y = h0(fy);
half h1y = h1(fy);

half4 r = g0(fy) * (g0x * UNITY_SAMPLE_TEX2D(unity_Lightmap, (half2(px + h0x, py + h0y) * 1.0f / width)) +
g1x * UNITY_SAMPLE_TEX2D(unity_Lightmap, (half2(px + h1x, py + h0y) * 1.0f / width))) +
g1(fy) * (g0x * UNITY_SAMPLE_TEX2D(unity_Lightmap, (half2(px + h0x, py + h1y) * 1.0f / width)) +
g1x * UNITY_SAMPLE_TEX2D(unity_Lightmap, (half2(px + h1x, py + h1y) * 1.0f / width)));
bakedColorTex = r;
return DecodeLightmap(r);
#else
bakedColorTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, uv);
return DecodeLightmap(bakedColorTex);
#endif
}

half3 GetSpecularHighlights(half3 worldNormal, half3 lightColor, half3 lightDirection, half3 f0, half3 viewDir, half clampedRoughness, half NoV, half3 energyCompensation)
{
half3 halfVector = Unity_SafeNormalize(lightDirection + viewDir);

half NoH = saturate(dot(worldNormal, halfVector));
half NoL = saturate(dot(worldNormal, lightDirection));
half LoH = saturate(dot(lightDirection, halfVector));

half3 F = F_Schlick(LoH, f0);
half D = D_GGX(NoH, clampedRoughness);
half V = V_SmithGGXCorrelated(NoV, NoL, clampedRoughness);

#ifndef UNITY_PBS_USE_BRDF2
F *= energyCompensation;
#endif

return max(0, (D * V) * F) * lightColor * NoL * UNITY_PI;
}

#ifdef DYNAMICLIGHTMAP_ON
half3 getRealtimeLightmap(half2 uv, half3 worldNormal)
{
half2 realtimeUV = uv;
half4 bakedCol = UNITY_SAMPLE_TEX2D(unity_DynamicLightmap, realtimeUV);
half3 realtimeLightmap = DecodeRealtimeLightmap(bakedCol);

#ifdef DIRLIGHTMAP_COMBINED
half4 realtimeDirTex = UNITY_SAMPLE_TEX2D_SAMPLER(unity_DynamicDirectionality, unity_DynamicLightmap, realtimeUV);
realtimeLightmap += DecodeDirectionalLightmap(realtimeLightmap, realtimeDirTex, worldNormal);
#endif

return realtimeLightmap;
}
#endif

half computeSpecularAO(half NoV, half ao, half roughness)
{
return clamp(pow(NoV + ao, exp2(-16.0 * roughness - 1.0)) - 1.0 + ao, 0.0, 1.0);
}

half shEvaluateDiffuseL1Geomerics_local(half L0, half3 L1, half3 n)
{
// average energy
half R0 = L0;

// avg direction of incoming light
half3 R1 = 0.5f * L1;

// directional brightness
half lenR1 = length(R1);

// linear angle between normal and direction 0-1
//half q = 0.5f * (1.0f + dot(R1 / lenR1, n));
//half q = dot(R1 / lenR1, n) * 0.5 + 0.5;
half q = dot(normalize(R1), n) * 0.5 + 0.5;
q = saturate(q); // Thanks to ScruffyRuffles for the bug identity.

// power for q
// lerps from 1 (linear) to 3 (cubic) based on directionality
half p = 1.0f + 2.0f * lenR1 / R0;

// dynamic range constant
// should vary between 4 (highly directional) and 0 (ambient)
half a = (1.0f - lenR1 / R0) / (1.0f + lenR1 / R0);

return R0 * (a + (1.0f - a) * (p + 1.0f) * pow(q, p));
}

TEXTURE2D(_Ramp);
SAMPLER(sampler_Ramp);
TEXTURECUBE(_BakedCubemap);
SAMPLER(sampler_BakedCubemap);

half3 getReflectionUV(half3 direction, half3 position, half4 cubemapPosition, half3 boxMin, half3 boxMax)
{
#if UNITY_SPECCUBE_BOX_PROJECTION
if (cubemapPosition.w > 0) {
half3 factors = ((direction > 0 ? boxMax : boxMin) - position) / direction;
half scalar = min(min(factors.x, factors.y), factors.z);
direction = direction * scalar + (position - cubemapPosition);
}
#endif
return direction;
}

half3 calcReflView(half3 viewDir, half3 normal)
{
return reflect(-viewDir, normal);
}

half3 calcStereoViewDir(half3 worldPos)
{
#if UNITY_SINGLE_PASS_STEREO
half3 cameraPos = half3((unity_StereoWorldSpaceCameraPos[0]+ unity_StereoWorldSpaceCameraPos[1])*.5);
#else
half3 cameraPos = _WorldSpaceCameraPos;
#endif
half3 viewDir = cameraPos - worldPos;
return normalize(viewDir);
}

half4 calcRamp(half NdL, half attenuation, half occlusion, int occlusionMode)
{
half remapRamp;
remapRamp = NdL * 0.5 + 0.5;
remapRamp *= lerp(1, occlusion, occlusionMode);
#if defined(UNITY_PASS_FORWARDBASE)
remapRamp *= attenuation;
#endif
half4 ramp = SAMPLE_TEXTURE2D(_Ramp, sampler_Ramp, half2(remapRamp, 0));
return ramp;
}

half4 calcDiffuse(half attenuation, half3 albedo, half3 indirectDiffuse, half3 lightCol, half4 ramp)
{
half4 diffuse;
half4 indirect = indirectDiffuse.xyzz;

half grayIndirect = dot(indirectDiffuse, float3(1,1,1));
half attenFactor = lerp(attenuation, 1, smoothstep(0, 0.2, grayIndirect));

diffuse = ramp * attenFactor * half4(lightCol, 1) + indirect;
diffuse = albedo.xyzz * diffuse;
return diffuse;
}

half2 calcMatcapUV(half3 worldUp, half3 viewDirection, half3 normalDirection)
{
half3 worldViewUp = normalize(worldUp - viewDirection * dot(viewDirection, worldUp));
half3 worldViewRight = normalize(cross(viewDirection, worldViewUp));
half2 matcapUV = half2(dot(worldViewRight, normalDirection), dot(worldViewUp, normalDirection)) * 0.5 + 0.5;
return matcapUV;
}

half3 calcIndirectSpecular(half lightAttenuation, MeshData d, SurfaceData o, half roughness, half3 reflDir, half3 indirectLight, float3 fresnel, half4 ramp)
{//This function handls Unity style reflections, Matcaps, and a baked in fallback cubemap.
half3 spec = half3(0,0,0);

UNITY_BRANCH
if (!o.EnableReflections) {
spec = 0;
} else if(any(o.BakedReflection.rgb)) {
spec = o.BakedReflection;
if(o.ReflectionBlendMode != 1)
{
spec *= (indirectLight + (_LightColor0 * lightAttenuation) * 0.5);
}
} else
{
#if defined(UNITY_PASS_FORWARDBASE) //Indirect PBR specular should only happen in the forward base pass. Otherwise each extra light adds another indirect sample, which could mean you're getting too much light.
half3 reflectionUV1 = getReflectionUV(reflDir, d.worldSpacePosition, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax);
half4 probe0 = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectionUV1, roughness * UNITY_SPECCUBE_LOD_STEPS);
half3 probe0sample = DecodeHDR(probe0, unity_SpecCube0_HDR);

half3 indirectSpecular;
half interpolator = unity_SpecCube0_BoxMin.w;

UNITY_BRANCH
if (interpolator < 0.99999)
{
half3 reflectionUV2 = getReflectionUV(reflDir, d.worldSpacePosition, unity_SpecCube1_ProbePosition, unity_SpecCube1_BoxMin, unity_SpecCube1_BoxMax);
half4 probe1 = UNITY_SAMPLE_TEXCUBE_SAMPLER_LOD(unity_SpecCube1, unity_SpecCube0, reflectionUV2, roughness * UNITY_SPECCUBE_LOD_STEPS);
half3 probe1sample = DecodeHDR(probe1, unity_SpecCube1_HDR);
indirectSpecular = lerp(probe1sample, probe0sample, interpolator);
}
else
{
indirectSpecular = probe0sample;
}

if (!any(indirectSpecular))
{
indirectSpecular = SAMPLE_TEXTURECUBE_LOD(_BakedCubemap, sampler_BakedCubemap, reflDir, roughness * UNITY_SPECCUBE_LOD_STEPS);
indirectSpecular *= indirectLight;
}
spec = indirectSpecular * fresnel;
#endif
}
// else if(_ReflectionMode == 1) //Baked Cubemap
// {
//     half3 indirectSpecular = SAMPLE_TEXTURECUBE_LOD(_BakedCubemap, sampler_BakedCubemap, reflDir, roughness * UNITY_SPECCUBE_LOD_STEPS);
//     spec = indirectSpecular * fresnel;

//     if(_ReflectionBlendMode != 1)
//     {
//         spec *= (indirectLight + (_LightColor0 * lightAttenuation) * 0.5);
//     }
// }
// else if (_ReflectionMode == 2) //Matcap
// {
//     half3 upVector = half3(0,1,0);
//     half2 remapUV = calcMatcapUV(upVector, d.worldSpaceViewDir, o.Normal);
//     spec = SAMPLE_TEXTURE2D_LOD(_Matcap, remapUV, (1-roughness) * UNITY_SPECCUBE_LOD_STEPS) * _MatcapTint;

//     if(_ReflectionBlendMode != 1)
//     {
//         spec *= (indirectLight + (_LightColor0 * lightAttenuation) * 0.5);
//     }

//     spec *= lerp(1, o.Albedo, _MatcapTintToDiffuse);
// }
return spec;
}

half3 calcDirectSpecular(MeshData d, SurfaceData o, float lightNoL, float NoH, float NoV, float lightLoH, half3 lightColor, half3 lightHalfVector, half anisotropy)
{
half specularIntensity = o.SpecularIntensity;
half3 specular = half3(0,0,0);
half smoothness = max(0.01, (o.SpecularArea));
smoothness *= 1.7 - 0.7 * smoothness;

float rough = max(smoothness * smoothness, 0.0045);
float Dn = D_GGX(NoH, rough);
float3 F = 1-F_Schlick(lightLoH, 0);
float V = V_SmithGGXCorrelated(NoV, lightNoL, rough);
float3 directSpecularNonAniso = max(0, (Dn * V) * F);

anisotropy *= saturate(5.0 * smoothness);
float at = max(rough * (1.0 + anisotropy), 0.001);
float ab = max(rough * (1.0 - anisotropy), 0.001);
float D = D_GGX_Anisotropic(NoH, lightHalfVector, d.worldSpaceTangent, d.bitangent, at, ab);
float3 directSpecularAniso = max(0, (D * V) * F);

specular = lerp(directSpecularNonAniso, directSpecularAniso, saturate(abs(anisotropy * 100)));
specular = lerp(specular, smoothstep(0.5, 0.51, specular), o.SpecularSharpness) * 3 * lightColor.xyz * specularIntensity; // Multiply by 3 to bring up to brightness of standard
specular *= lerp(1, o.Albedo, o.SpecularAlbedoTint);
return specular;
}

half4 calcReflectionBlending(SurfaceData o, half reflectivity, half4 col, half3 indirectSpecular)
{
if (o.ReflectionBlendMode == 0) { // Additive
col += indirectSpecular.xyzz * reflectivity;
return col;
} else if (o.ReflectionBlendMode == 1) { //Multiplicitive
col = lerp(col, col * indirectSpecular.xyzz, reflectivity);
return col;
} else if(o.ReflectionBlendMode == 2) { //Subtractive
col -= indirectSpecular.xyzz * reflectivity;
return col;
}
return col;
}

half4 calcEmission(SurfaceData o, half lightAvg)
{
#if defined(UNITY_PASS_FORWARDBASE) // Emission only in Base Pass, and vertex lights
float4 emission = 0;
emission = half4(o.Emission, 1);

float4 scaledEmission = emission * saturate(smoothstep(1 - o.EmissionLightThreshold, 1 + o.EmissionLightThreshold, 1 - lightAvg));
float4 em = lerp(scaledEmission, emission, o.EmissionScaleWithLight);

// em.rgb = rgb2hsv(em.rgb);
// em.x += fmod(_Hue, 360);
// em.y = saturate(em.y * _Saturation);
// em.z *= _Value;
// em.rgb = hsv2rgb(em.rgb);

return em;
#else
return 0;
#endif
}

#if defined(NEED_DEPTH)
UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
#endif

half _ShadowSharpness;
half _OcclusionStrength;
half _BumpScale;
half _DetailNormalScale;
half _FlipDetailNormalY;
half _OutlineAlbedoTint;
half _OutlineWidth;
half _SpecularIntensity;
half _SpecularRoughness;
half _SpecularSharpness;
half _SpecularAnisotropy;
half _SpecularAlbedoTint;
half _Smoothness;
half _Metallic;
half _ReflectionAnisotropy;
half _MatcapBlur;
half _MatcapTintToDiffuse;
half _ReflectivityLevel;
half _EmissionTintToDiffuse;
half _EmissionScaleWithLightSensitivity;
half _RimIntensity;
half _RimAlbedoTint;
half _RimEnvironmentTint;
half _RimAttenuation;
half _RimRange;
half _RimThreshold;
half _RimSharpness;
half _ShadowRimRange;
half _ShadowRimThreshold;
half _ShadowRimSharpness;
half _ShadowRimAlbedoTint;
half2 GLOBAL_uv;
half3 GLOBAL_pixelNormal;
half4 _Color;
half4 _DetailNormalMap_ST;
half4 _OutlineColor;
half4 _MetallicRemap;
half4 _SmoothnessRemap;
half4 _MetallicGlossMap_TexelSize;
half4 _ALEmissionColor;
half4 _ALPackedRedColor;
half4 _ALPackedGreenColor;
half4 _ALPackedBlueColor;
half4 _EmissionColor;
half4 _RimTint;
half4 _ShadowRimTint;
float4 _MainTex_ST;
int _TintByVertexColor;
TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);
int _OcclusionMode;
TEXTURE2D(_OcclusionMap);
int _FlipBumpY;
int _DetailNormalsUVSet;
int _DetailNormalUVSet;
TEXTURE2D(_BumpMap);
SAMPLER(sampler_BumpMap);
TEXTURE2D(_DetailNormalMap);
SAMPLER(sampler_DetailNormalMap);
TEXTURE2D(_DetailNormalsMask);
SAMPLER(sampler_DetailNormalsMask);
int _OutlineLightingMode;
TEXTURE2D(_OutlineMask);
SAMPLER(sampler_OutlineMask);
int _SpecularMapUVSet;
TEXTURE2D(_SpecularMap);
int _ReflectionMode;
int _ReflectionBlendMode;
int _RoughnessMode;
TEXTURE2D(_Matcap);
SAMPLER(sampler_Matcap);
TEXTURE2D(_MetallicGlossMap);
TEXTURE2D(_ReflectivityMask);
int _ALMode;
int _ALBand;
int _ALGradientOnRed;
int _ALGradientOnGreen;
int _ALGradientOnBlue;
int _ALUVWidth;
int _ALMapUVSet;
TEXTURE2D(_ALMap);
SAMPLER(sampler_ALMap);
int _EmissionScaleWithLight;
TEXTURE2D(_EmissionMap);

void ToonOutlineVertex() {
#if defined(PASS_OUTLINE)
half mask = SAMPLE_TEXTURE2D_LOD(_OutlineMask, sampler_OutlineMask, vD.uv0, 0);
half3 width = mask * _OutlineWidth * .01;
width *= min(distance(mul(unity_ObjectToWorld, vD.vertex), _WorldSpaceCameraPos) * 3, 1);
vD.vertex.xyz += vD.normal.xyz * width;
#endif
}

void ToonFragment() {
half2 uv = d.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
GLOBAL_uv = uv;
half3 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, GLOBAL_uv).rgb;
albedo *= _Color;
if (_TintByVertexColor) {
albedo *= d.vertexColor.rgb;
}
o.Albedo = albedo;
o.ShadowSharpness = _ShadowSharpness;
}

void ToonOcclusionFragment() {
half occlusion = SAMPLE_TEXTURE2D(_OcclusionMap, sampler_MainTex, GLOBAL_uv).r;
o.Occlusion = lerp(1, occlusion, _OcclusionStrength);
o.OcclusionMode = _OcclusionMode;
}

void ToonNormalsFragment() {
half4 normalTex = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, GLOBAL_uv);
if (_FlipBumpY)
{
normalTex.y = 1 - normalTex.y;
}
half3 normal = UnpackScaleNormal(normalTex, _BumpScale);

o.Normal = BlendNormals(o.Normal, normal);

half2 detailUV = 0;
switch (_DetailNormalsUVSet) {
case 0: detailUV = d.uv0; break;
case 1: detailUV = d.uv1; break;
case 2: detailUV = d.uv2; break;
case 3: detailUV = d.uv3; break;
}
detailUV = detailUV * _DetailNormalMap_ST.xy + _DetailNormalMap_ST.zw;
half4 detailNormalTex = SAMPLE_TEXTURE2D(_DetailNormalMap, sampler_DetailNormalMap, detailUV);
if (_FlipDetailNormalY)
{
detailNormalTex.y = 1 - detailNormalTex.y;
}

half2 detailMaskUV = 0;
switch (_DetailNormalUVSet) {
case 0: detailMaskUV = d.uv0; break;
case 1: detailMaskUV = d.uv1; break;
case 2: detailMaskUV = d.uv2; break;
case 3: detailMaskUV = d.uv3; break;
}
half detailMask = SAMPLE_TEXTURE2D(_DetailNormalsMask, sampler_MainTex, GLOBAL_uv).r;

half3 detailNormal = UnpackScaleNormal(detailNormalTex, _DetailNormalScale);

o.Normal = lerp(o.Normal, BlendNormals(o.Normal, detailNormal), detailMask);

half3 properNormal = normalize(o.Normal.x * d.worldSpaceTangent.xyz + o.Normal.y * d.bitangent.xyz + o.Normal.z * d.worldNormal.xyz);
d.worldSpaceTangent.xyz = cross(d.bitangent.xyz, properNormal);
d.bitangent.xyz = cross(properNormal, d.worldSpaceTangent.xyz);
d.TBNMatrix = float3x3(normalize(d.worldSpaceTangent.xyz), d.bitangent, d.worldNormal);
GLOBAL_pixelNormal = properNormal;
}

void ToonOutlineFragment() {
o.OutlineColor = lerp(_OutlineColor, _OutlineColor * o.Albedo, _OutlineAlbedoTint);
o.OutlineLightingMode = _OutlineLightingMode;
}

void ToonSpecularFragment() {
half2 maskUV = 0;
switch (_DetailNormalsUVSet) {
case 0: maskUV = d.uv0; break;
case 1: maskUV = d.uv1; break;
case 2: maskUV = d.uv2; break;
case 3: maskUV = d.uv3; break;
}

half3 specMap = SAMPLE_TEXTURE2D(_SpecularMap, sampler_MainTex, maskUV);
o.SpecularIntensity = _SpecularIntensity * specMap.r;
o.SpecularArea = max(0.01, _SpecularRoughness * specMap.b);
o.SpecularAnisotropy = _SpecularAnisotropy;
o.SpecularAlbedoTint = _SpecularAlbedoTint * specMap.g;
o.SpecularSharpness = _SpecularSharpness;
}

void ToonReflectionFragment() {
o.EnableReflections = _ReflectionMode != 3;
o.ReflectionBlendMode = _ReflectionBlendMode;

half mask = SAMPLE_TEXTURE2D(_ReflectivityMask, sampler_MainTex, GLOBAL_uv).r;
mask *= _ReflectivityLevel;

UNITY_BRANCH
if (_ReflectionMode == 0) {
half4 metalSmooth = SAMPLE_TEXTURE2D(_MetallicGlossMap, sampler_MainTex, GLOBAL_uv);
int hasMetallicSmooth = _MetallicGlossMap_TexelSize.z > 8;
half metal = metalSmooth.r;
half smooth = metalSmooth.a;
if (_RoughnessMode)
{
smooth = 1 - smooth;
}
metal = remap(metal, 0, 1, _MetallicRemap.x, _MetallicRemap.y);
smooth = remap(smooth, 0, 1, _SmoothnessRemap.x, _SmoothnessRemap.y);
o.Metallic = lerp(_Metallic, metal, hasMetallicSmooth);
o.Smoothness = lerp(_Smoothness, smooth, hasMetallicSmooth);
o.Anisotropy = _ReflectionAnisotropy;
}
UNITY_BRANCH
if (_ReflectionMode == 2) {
half3 upVector = half3(0,1,0);
half2 remapUV = calcMatcapUV(upVector, d.worldSpaceViewDir, GLOBAL_pixelNormal);
half4 spec = 0;
spec = SAMPLE_TEXTURE2D_LOD(_Matcap, sampler_Matcap, remapUV, _MatcapBlur * UNITY_SPECCUBE_LOD_STEPS);

spec.rgb *= lerp(1, o.Albedo, _MatcapTintToDiffuse);
o.BakedReflection = spec.rgb;
}
o.Reflectivity = mask;
}

void ToonALFragment() {
if(AudioLinkIsAvailable() && _ALMode != 0) {
half2 alUV = 0;
switch (_ALMapUVSet) {
case 0: alUV = GLOBAL_uv; break;
case 1: alUV = d.uv1; break;
case 2: alUV = d.uv2; break;
case 3: alUV = d.uv3; break;
}
half4 alMask = SAMPLE_TEXTURE2D(_ALMap, sampler_ALMap, alUV);
if (_ALMode == 2) {
half audioDataBass = AudioLinkData(ALPASS_AUDIOBASS).x;
half audioDataMids = AudioLinkData(ALPASS_AUDIOLOWMIDS).x;
half audioDataHighs = (AudioLinkData(ALPASS_AUDIOHIGHMIDS).x + AudioLinkData(ALPASS_AUDIOTREBLE).x) * 0.5;

half tLow = smoothstep((1-audioDataBass), (1-audioDataBass) + 0.01, alMask.r) * alMask.a;
half tMid = smoothstep((1-audioDataMids), (1-audioDataMids) + 0.01, alMask.g) * alMask.a;
half tHigh = smoothstep((1-audioDataHighs), (1-audioDataHighs) + 0.01, alMask.b) * alMask.a;

half4 emissionChannelRed = lerp(alMask.r, tLow, _ALGradientOnRed) * _ALPackedRedColor * audioDataBass;
half4 emissionChannelGreen = lerp(alMask.g, tMid, _ALGradientOnGreen) * _ALPackedGreenColor * audioDataMids;
half4 emissionChannelBlue = lerp(alMask.b, tHigh, _ALGradientOnBlue) * _ALPackedBlueColor * audioDataHighs;
o.Emission += emissionChannelRed.rgb + emissionChannelGreen.rgb + emissionChannelBlue.rgb;
} else {
int2 aluv;
if (_ALMode == 1) {
aluv = int2(0, _ALBand);
} else {
aluv = int2(GLOBAL_uv.x * _ALUVWidth, GLOBAL_uv.y);
}
half sampledAL = AudioLinkData(aluv).x;
o.Emission +=  alMask.rgb * _ALEmissionColor.rgb * sampledAL;
}
}
}

void ToonEmissionFragment() {
half3 emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_MainTex, GLOBAL_uv).rgb;
emission *= lerp(emission, emission * o.Albedo, _EmissionTintToDiffuse) * _EmissionColor;
o.Emission += emission;
o.EmissionScaleWithLight = _EmissionScaleWithLight;
o.EmissionLightThreshold = _EmissionScaleWithLightSensitivity;
}

void ToonRimLightFragment() {
#ifndef USING_DIRECTIONAL_LIGHT
fixed3 lightDir = normalize(UnityWorldSpaceLightDir(d.worldSpacePosition));
#else
fixed3 lightDir = _WorldSpaceLightPos0.xyz;
#endif
half lightNoL = saturate(dot(GLOBAL_pixelNormal, lightDir));
half SVDNoN = abs(dot(d.svdn, GLOBAL_pixelNormal));

half rimIntensity = saturate((1 - SVDNoN)) * pow(lightNoL, _RimThreshold);
rimIntensity = smoothstep(_RimRange - _RimSharpness, _RimRange + _RimSharpness, rimIntensity);
half4 rim = rimIntensity * _RimIntensity;

half3 env = 0;
#if defined(UNITY_PASS_FORWARDBASE)
env = getEnvReflection(d.worldSpaceViewDir.xyz, d.worldSpacePosition.xyz, GLOBAL_pixelNormal, o.Smoothness, 5);
#endif

o.RimLight = rim * _RimTint * lerp(1, o.Albedo.rgbb, _RimAlbedoTint) * lerp(1, env.rgbb, _RimEnvironmentTint);
o.RimAttenuation = _RimAttenuation;
}

void ToonShadowRimFragment() {
#ifndef USING_DIRECTIONAL_LIGHT
fixed3 lightDir = normalize(UnityWorldSpaceLightDir(d.worldSpacePosition));
#else
fixed3 lightDir = _WorldSpaceLightPos0.xyz;
#endif
half lightNoL = saturate(dot(GLOBAL_pixelNormal, lightDir));
half SVDNoN = abs(dot(d.svdn, GLOBAL_pixelNormal));
half shadowRimIntensity = saturate((1 - SVDNoN)) * pow(1 - lightNoL, _ShadowRimThreshold * 2);
shadowRimIntensity = smoothstep(_ShadowRimRange - _ShadowRimSharpness, _ShadowRimRange + _ShadowRimSharpness, shadowRimIntensity);

o.RimShadow = lerp(1, (_ShadowRimTint * lerp(1, o.Albedo.rgbb, _ShadowRimAlbedoTint)), shadowRimIntensity);
}

void XSToonLighting()
{
#if !defined(UNITY_PASS_SHADOWCASTER)
half reflectance = o.Reflectivity;
half3 f0 = 0.16 * reflectance * reflectance * (1 - o.Metallic) + o.Albedo * o.Metallic;
half3 indirectDiffuse = 1;
half3 indirectSpecular = 0;
half3 directSpecular = 0;
half occlusion = o.Occlusion;
half perceptualRoughness = 1 - o.Smoothness;
half3 tangentNormal = o.Normal;
o.Normal = normalize(mul(o.Normal, d.TBNMatrix));
half3 reflDir = calcReflView(d.worldSpaceViewDir, o.Normal);

#ifndef USING_DIRECTIONAL_LIGHT
fixed3 lightDir = normalize(UnityWorldSpaceLightDir(d.worldSpacePosition));
#else
fixed3 lightDir = _WorldSpaceLightPos0.xyz;
#endif

// Attenuation
UNITY_LIGHT_ATTENUATION(lightAttenuation, FragData, d.worldSpacePosition);

// fix for rare bug where light atten is 0 when there is no directional light in the scene
#ifdef UNITY_PASS_FORWARDBASE
if(all(_LightColor0.rgb == 0.0))
lightAttenuation = 1.0;
#endif

#if defined(USING_DIRECTIONAL_LIGHT)
half sharp = o.ShadowSharpness * 0.5;
lightAttenuation = smoothstep(sharp, 1 - sharp, lightAttenuation); //Converge at the center line
#endif

half3 lightColor = _LightColor0.rgb;

half3 lightHalfVector = Unity_SafeNormalize(lightDir + d.worldSpaceViewDir);
half lightNoL = saturate(dot(o.Normal, lightDir));
half lightLoH = saturate(dot(lightDir, lightHalfVector));

half NoV = abs(dot(o.Normal, d.worldSpaceViewDir)) + 1e-5;
half NoH = saturate(dot(o.Normal, lightHalfVector));
half3 stereoViewDir = calcStereoViewDir(d.worldSpacePosition);
half NoSVDN = abs(dot(stereoViewDir, o.Normal));

// Aniso Refl
half3 reflViewAniso = 0;

float3 anisotropicDirection = o.Anisotropy >= 0.0 ? d.bitangent : FragData.worldTangent.xyz;
float3 anisotropicTangent = cross(anisotropicDirection, d.worldSpaceViewDir);
float3 anisotropicNormal = cross(anisotropicTangent, anisotropicDirection);
float bendFactor = abs(o.Anisotropy) * saturate(5.0 * perceptualRoughness);
float3 bentNormal = normalize(lerp(o.Normal, anisotropicNormal, bendFactor));
reflViewAniso = reflect(-d.worldSpaceViewDir, bentNormal);

// Indirect diffuse
#if !defined(LIGHTMAP_ON)
indirectDiffuse = ShadeSH9(float4(0,0.5,0,1));
#else
indirectDiffuse = 0;
#endif
indirectDiffuse *= lerp(occlusion, 1, o.OcclusionMode);

bool lightEnv = any(lightDir.xyz);
// if there is no realtime light - we create it from indirect diffuse
if (!lightEnv) {
lightColor = indirectDiffuse.xyz * 0.6;
indirectDiffuse = indirectDiffuse * 0.4;
}

half lightAvg = (dot(indirectDiffuse.rgb, grayscaleVec) + dot(lightColor.rgb, grayscaleVec)) / 2;

// Light Ramp
half4 ramp = 1;
half4 diffuse = 1;
ramp = calcRamp(lightNoL, lightAttenuation, occlusion, _OcclusionMode);
diffuse = calcDiffuse(lightAttenuation, o.Albedo.rgb * perceptualRoughness, indirectDiffuse, lightColor, ramp);

// Rims
half4 rimLight = o.RimLight;
rimLight *= lightColor.xyzz + indirectDiffuse.xyzz;
rimLight *= lerp(1, lightAttenuation + indirectDiffuse.xyzz, o.RimAttenuation);
half4 rimShadow = o.RimShadow;

float3 fresnel = F_Schlick(NoV, f0);
indirectSpecular = calcIndirectSpecular(lightAttenuation, d, o, perceptualRoughness, reflViewAniso, indirectDiffuse, fresnel, ramp) * occlusion;
directSpecular = calcDirectSpecular(d, o, lightNoL, NoH, NoV, lightLoH, lightColor, lightHalfVector, o.SpecularAnisotropy) * lightNoL * occlusion * lightAttenuation;

FinalColor = diffuse * o.RimShadow;
FinalColor = calcReflectionBlending(o, reflectance, FinalColor, indirectSpecular);
FinalColor += max(directSpecular.xyzz, rimLight);
FinalColor.rgb += calcEmission(o, lightAvg);

// Outline
#if defined(PASS_OUTLINE)
half3 outlineColor = 0;
half3 ol = o.OutlineColor;
outlineColor = ol * saturate(lightAttenuation * lightNoL) * lightColor.rgb;
outlineColor += indirectDiffuse * ol;
outlineColor = lerp(outlineColor, ol, o.OutlineLightingMode);
FinalColor.rgb = outlineColor;
#endif

#endif
}

// Shadow Vertex
FragmentData Vertex(VertexData v)
{
UNITY_SETUP_INSTANCE_ID(v);
FragmentData i;
UNITY_INITIALIZE_OUTPUT(FragmentData, i);
UNITY_TRANSFER_INSTANCE_ID(v, i);
UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(i);

vD = v;
FragData = i;
ToonOutlineVertex();

i = FragData;
v = vD;
#if defined(UNITY_PASS_SHADOWCASTER)
i.worldNormal = UnityObjectToWorldNormal(v.normal);
i.worldPos = mul(unity_ObjectToWorld, v.vertex);
i.uv0 = v.uv0;
i.uv1 = v.uv1;
i.uv2 = v.uv2;
i.uv3 = v.uv3;
i.worldTangent.xyz = UnityObjectToWorldDir(v.tangent.xyz);
i.worldTangent.w = v.tangent.w * unity_WorldTransformParams.w;
#else
i.pos = UnityObjectToClipPos(v.vertex);
i.normal = v.normal;
i.worldNormal = UnityObjectToWorldNormal(v.normal);
i.worldPos = mul(unity_ObjectToWorld, v.vertex);
i.uv0 = v.uv0;
i.uv1 = v.uv1;
i.uv2 = v.uv2;
i.uv3 = v.uv3;
i.worldTangent.xyz = UnityObjectToWorldDir(v.tangent.xyz);
i.worldTangent.w = v.tangent.w * unity_WorldTransformParams.w;
i.vertexColor = v.color;

#if defined(NEED_SCREEN_POS)
i.screenPos = ComputeScreenPos(i.pos);
#endif

#if defined(LIGHTMAP_ON)
i.lightmapUv.xy = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
#endif
#if defined(DYNAMICLIGHTMAP_ON)
i.lightmapUv.zw = v.uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
#endif

UNITY_TRANSFER_LIGHTING(i, v.uv1.xy);

#if !defined(UNITY_PASS_FORWARDADD)
// unity does some funky stuff for different platforms with these macros
#ifdef FOG_COMBINED_WITH_TSPACE
UNITY_TRANSFER_FOG_COMBINED_WITH_TSPACE(i, i.pos);
#elif defined(FOG_COMBINED_WITH_WORLD_POS)
UNITY_TRANSFER_FOG_COMBINED_WITH_WORLD_POS(i, i.pos);
#else
UNITY_TRANSFER_FOG(i, i.pos);
#endif
#else
UNITY_TRANSFER_FOG(i, i.pos);
#endif
#endif

TRANSFER_SHADOW_CASTER_NORMALOFFSET(i);

return i;
}

// Shadow Fragment
half4 Fragment(FragmentData i) : SV_TARGET
{
UNITY_SETUP_INSTANCE_ID(i);

#if defined(NEED_FRAGMENT_IN_SHADOW)
FragData = i;
o = (SurfaceData) 0;
d = CreateMeshData(i);
o.Albedo = half3(0.5, 0.5, 0.5);
o.Normal = half3(0, 0, 1);
o.Smoothness = 0;
o.Occlusion = 1;
o.Alpha = 1;
o.RimShadow = 1;
o.RimAttenuation = 1;
FinalColor = half4(o.Albedo, o.Alpha);

ToonFragment();
ToonOcclusionFragment();
ToonNormalsFragment();
ToonOutlineFragment();
ToonSpecularFragment();
ToonReflectionFragment();
ToonALFragment();
ToonEmissionFragment();
ToonRimLightFragment();
ToonShadowRimFragment();

#endif

SHADOW_CASTER_FRAGMENT(i);
}

ENDCG
// Shadow Pass End

}

Pass
{
Name "Outline"
Tags { "LightMode" = "ForwardBase"  }
Cull Front

// Outline Pass Start
CGPROGRAM
#pragma target 4.5
#pragma multi_compile_instancing
#pragma multi_compile_fwdbase
#pragma multi_compile_fog
#pragma vertex Vertex
#pragma fragment Fragment
#pragma shader_feature_local OUTLINE_ENABLED

#define UNITY_INSTANCED_LOD_FADE
#define UNITY_INSTANCED_SH
#define UNITY_INSTANCED_LIGHTMAPSTS

#ifndef PASS_OUTLINE
#define PASS_OUTLINE
#endif

#include "UnityStandardUtils.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

#define FLT_EPSILON     1.192092896e-07

#if defined(UNITY_PBS_USE_BRDF2) || defined(SHADER_API_MOBILE)
#define PLAT_QUEST
#else
#ifdef PLAT_QUEST
#undef PLAT_QUEST
#endif
#endif

#define NEED_SCREEN_POS

#define grayscaleVec float3(0.2125, 0.7154, 0.0721)

// Credit to Jason Booth for digging this all up
// This originally comes from CoreRP, see Jason's comment below

// If your looking in here and thinking WTF, yeah, I know. These are taken from the SRPs, to allow us to use the same
// texturing library they use. However, since they are not included in the standard pipeline by default, there is no
// way to include them in and they have to be inlined, since someone could copy this shader onto another machine without
// Better Shaders installed. Unfortunate, but I'd rather do this and have a nice library for texture sampling instead
// of the patchy one Unity provides being inlined/emulated in HDRP/URP. Strangely, PSSL and XBoxOne libraries are not
// included in the standard SRP code, but they are in tons of Unity own projects on the web, so I grabbed them from there.

#if defined(SHADER_API_XBOXONE)

// Initialize arbitrary structure with zero values.
// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
#define ZERO_INITIALIZE(type, name) name = (type)0;
#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }

// Texture util abstraction

#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) textureName.CalculateLevelOfDetail(samplerName, coord2)

// Texture abstraction

#define TEXTURE2D(textureName)                Texture2D textureName
#define TEXTURE2D_ARRAY(textureName)          Texture2DArray textureName
#define TEXTURECUBE(textureName)              TextureCube textureName
#define TEXTURECUBE_ARRAY(textureName)        TextureCubeArray textureName
#define TEXTURE3D(textureName)                Texture3D textureName

#define TEXTURE2D_FLOAT(textureName)          TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_FLOAT(textureName)    TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_FLOAT(textureName)        TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_FLOAT(textureName)  TEXTURECUBE_ARRAY(textureName)
#define TEXTURE3D_FLOAT(textureName)          TEXTURE3D(textureName)

#define TEXTURE2D_HALF(textureName)           TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_HALF(textureName)     TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_HALF(textureName)         TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_HALF(textureName)   TEXTURECUBE_ARRAY(textureName)
#define TEXTURE3D_HALF(textureName)           TEXTURE3D(textureName)

#define TEXTURE2D_SHADOW(textureName)         TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_SHADOW(textureName)   TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_SHADOW(textureName)       TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_SHADOW(textureName) TEXTURECUBE_ARRAY(textureName)

#define RW_TEXTURE2D(type, textureName)       RWTexture2D<type> textureName
#define RW_TEXTURE2D_ARRAY(type, textureName) RWTexture2DArray<type> textureName
#define RW_TEXTURE3D(type, textureName)       RWTexture3D<type> textureName

#define SAMPLER(samplerName)                  SamplerState samplerName
#define SAMPLER_CMP(samplerName)              SamplerComparisonState samplerName

#define TEXTURE2D_PARAM(textureName, samplerName)                 TEXTURE2D(textureName), SAMPLER(samplerName)
#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)           TEXTURE2D_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_PARAM(textureName, samplerName)               TEXTURECUBE(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)         TEXTURECUBE_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURE3D_PARAM(textureName, samplerName)                 TEXTURE3D(textureName), SAMPLER(samplerName)

#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)          TEXTURE2D(textureName), SAMPLER_CMP(samplerName)
#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)    TEXTURE2D_ARRAY(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)        TEXTURECUBE(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_ARRAY_SHADOW_PARAM(textureName, samplerName)  TEXTURECUBE_ARRAY(textureName), SAMPLER_CMP(samplerName)

#define TEXTURE2D_ARGS(textureName, samplerName)                textureName, samplerName
#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)          textureName, samplerName
#define TEXTURECUBE_ARGS(textureName, samplerName)              textureName, samplerName
#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)        textureName, samplerName
#define TEXTURE3D_ARGS(textureName, samplerName)                textureName, samplerName

#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)         textureName, samplerName
#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)   textureName, samplerName
#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)       textureName, samplerName
#define TEXTURECUBE_ARRAY_SHADOW_ARGS(textureName, samplerName) textureName, samplerName

#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod)                      textureName.SampleLevel(samplerName, coord2, lod)
#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                    textureName.SampleBias(samplerName, coord2, bias)
#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, dpdx, dpdy)              textureName.SampleGrad(samplerName, coord2, dpdx, dpdy)
#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                  textureName.Sample(samplerName, float3(coord2, index))
#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)         textureName.SampleLevel(samplerName, float3(coord2, index), lod)
#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)       textureName.SampleBias(samplerName, float3(coord2, index), bias)
#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy) textureName.SampleGrad(samplerName, float3(coord2, index), dpdx, dpdy)
#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                             textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                    textureName.SampleLevel(samplerName, coord3, lod)
#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                  textureName.SampleBias(samplerName, coord3, bias)
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)                textureName.Sample(samplerName, float4(coord3, index))
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)       textureName.SampleLevel(samplerName, float4(coord3, index), lod)
#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)     textureName.SampleBias(samplerName, float4(coord3, index), bias)
#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                               textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                      textureName.SampleLevel(samplerName, coord3, lod)

#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                    textureName.SampleCmpLevelZero(samplerName, (coord3).xy, (coord3).z)
#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)       textureName.SampleCmpLevelZero(samplerName, float3((coord3).xy, index), (coord3).z)
#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                  textureName.SampleCmpLevelZero(samplerName, (coord4).xyz, (coord4).w)
#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)     textureName.SampleCmpLevelZero(samplerName, float4((coord4).xyz, index), (coord4).w)

#define LOAD_TEXTURE2D(textureName, unCoord2)                                   textureName.Load(int3(unCoord2, 0))
#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)                          textureName.Load(int3(unCoord2, lod))
#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)                 textureName.Load(unCoord2, sampleIndex)
#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)                      textureName.Load(int4(unCoord2, index, 0))
#define LOAD_TEXTURE2D_ARRAY_MSAA(textureName, unCoord2, index, sampleIndex)    textureName.Load(int3(unCoord2, index), sampleIndex)
#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod)             textureName.Load(int4(unCoord2, index, lod))
#define LOAD_TEXTURE3D(textureName, unCoord3)                                   textureName.Load(int4(unCoord3, 0))
#define LOAD_TEXTURE3D_LOD(textureName, unCoord3, lod)                          textureName.Load(int4(unCoord3, lod))

#define PLATFORM_SUPPORT_GATHER
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                textureName.Gather(samplerName, coord2)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)   textureName.Gather(samplerName, float3(coord2, index))
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)              textureName.Gather(samplerName, coord3)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index) textureName.Gather(samplerName, float4(coord3, index))
#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)            textureName.GatherRed(samplerName, coord2)
#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherGreen(samplerName, coord2)
#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)           textureName.GatherBlue(samplerName, coord2)
#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherAlpha(samplerName, coord2)

#elif defined(SHADER_API_PSSL)

// Initialize arbitrary structure with zero values.
// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
#define ZERO_INITIALIZE(type, name) name = (type)0;
#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }

// Texture util abstraction

#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) textureName.GetLOD(samplerName, coord2)

// Texture abstraction

#define TEXTURE2D(textureName)                Texture2D textureName
#define TEXTURE2D_ARRAY(textureName)          Texture2DArray textureName
#define TEXTURECUBE(textureName)              TextureCube textureName
#define TEXTURECUBE_ARRAY(textureName)        TextureCubeArray textureName
#define TEXTURE3D(textureName)                Texture3D textureName

#define TEXTURE2D_FLOAT(textureName)          TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_FLOAT(textureName)    TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_FLOAT(textureName)        TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_FLOAT(textureName)  TEXTURECUBE_ARRAY(textureName)
#define TEXTURE3D_FLOAT(textureName)          TEXTURE3D(textureName)

#define TEXTURE2D_HALF(textureName)           TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_HALF(textureName)     TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_HALF(textureName)         TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_HALF(textureName)   TEXTURECUBE_ARRAY(textureName)
#define TEXTURE3D_HALF(textureName)           TEXTURE3D(textureName)

#define TEXTURE2D_SHADOW(textureName)         TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_SHADOW(textureName)   TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_SHADOW(textureName)       TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_SHADOW(textureName) TEXTURECUBE_ARRAY(textureName)

#define RW_TEXTURE2D(type, textureName)       RW_Texture2D<type> textureName
#define RW_TEXTURE2D_ARRAY(type, textureName) RW_Texture2D_Array<type> textureName
#define RW_TEXTURE3D(type, textureName)       RW_Texture3D<type> textureName

#define SAMPLER(samplerName)                  SamplerState samplerName
#define SAMPLER_CMP(samplerName)              SamplerComparisonState samplerName

#define TEXTURE2D_PARAM(textureName, samplerName)                 TEXTURE2D(textureName), SAMPLER(samplerName)
#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)           TEXTURE2D_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_PARAM(textureName, samplerName)               TEXTURECUBE(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)         TEXTURECUBE_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURE3D_PARAM(textureName, samplerName)                 TEXTURE3D(textureName), SAMPLER(samplerName)

#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)          TEXTURE2D(textureName), SAMPLER_CMP(samplerName)
#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)    TEXTURE2D_ARRAY(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)        TEXTURECUBE(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_ARRAY_SHADOW_PARAM(textureName, samplerName)  TEXTURECUBE_ARRAY(textureName), SAMPLER_CMP(samplerName)

#define TEXTURE2D_ARGS(textureName, samplerName)                textureName, samplerName
#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)          textureName, samplerName
#define TEXTURECUBE_ARGS(textureName, samplerName)              textureName, samplerName
#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)        textureName, samplerName
#define TEXTURE3D_ARGS(textureName, samplerName)                textureName, samplerName

#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)         textureName, samplerName
#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)   textureName, samplerName
#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)       textureName, samplerName
#define TEXTURECUBE_ARRAY_SHADOW_ARGS(textureName, samplerName) textureName, samplerName

#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod)                      textureName.SampleLevel(samplerName, coord2, lod)
#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                    textureName.SampleBias(samplerName, coord2, bias)
#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, dpdx, dpdy)              textureName.SampleGrad(samplerName, coord2, dpdx, dpdy)
#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                  textureName.Sample(samplerName, float3(coord2, index))
#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)         textureName.SampleLevel(samplerName, float3(coord2, index), lod)
#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)       textureName.SampleBias(samplerName, float3(coord2, index), bias)
#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy) textureName.SampleGrad(samplerName, float3(coord2, index), dpdx, dpdy)
#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                             textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                    textureName.SampleLevel(samplerName, coord3, lod)
#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                  textureName.SampleBias(samplerName, coord3, bias)
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)                textureName.Sample(samplerName, float4(coord3, index))
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)       textureName.SampleLevel(samplerName, float4(coord3, index), lod)
#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)     textureName.SampleBias(samplerName, float4(coord3, index), bias)
#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                               textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                      textureName.SampleLevel(samplerName, coord3, lod)

#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                    textureName.SampleCmpLevelZero(samplerName, (coord3).xy, (coord3).z)
#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)       textureName.SampleCmpLevelZero(samplerName, float3((coord3).xy, index), (coord3).z)
#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                  textureName.SampleCmpLevelZero(samplerName, (coord4).xyz, (coord4).w)
#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)     textureName.SampleCmpLevelZero(samplerName, float4((coord4).xyz, index), (coord4).w)

#define LOAD_TEXTURE2D(textureName, unCoord2)                                   textureName.Load(int3(unCoord2, 0))
#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)                          textureName.Load(int3(unCoord2, lod))
#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)                 textureName.Load(unCoord2, sampleIndex)
#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)                      textureName.Load(int4(unCoord2, index, 0))
#define LOAD_TEXTURE2D_ARRAY_MSAA(textureName, unCoord2, index, sampleIndex)    textureName.Load(int3(unCoord2, index), sampleIndex)
#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod)             textureName.Load(int4(unCoord2, index, lod))
#define LOAD_TEXTURE3D(textureName, unCoord3)                                   textureName.Load(int4(unCoord3, 0))
#define LOAD_TEXTURE3D_LOD(textureName, unCoord3, lod)                          textureName.Load(int4(unCoord3, lod))

#define PLATFORM_SUPPORT_GATHER
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                textureName.Gather(samplerName, coord2)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)   textureName.Gather(samplerName, float3(coord2, index))
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)              textureName.Gather(samplerName, coord3)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index) textureName.Gather(samplerName, float4(coord3, index))
#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)            textureName.GatherRed(samplerName, coord2)
#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherGreen(samplerName, coord2)
#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)           textureName.GatherBlue(samplerName, coord2)
#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherAlpha(samplerName, coord2)

#elif defined(SHADER_API_D3D11)

// Initialize arbitrary structure with zero values.
// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
#define ZERO_INITIALIZE(type, name) name = (type)0;
#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }

// Texture util abstraction

#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) textureName.CalculateLevelOfDetail(samplerName, coord2)

// Texture abstraction

#define TEXTURE2D(textureName)                Texture2D textureName
#define TEXTURE2D_ARRAY(textureName)          Texture2DArray textureName
#define TEXTURECUBE(textureName)              TextureCube textureName
#define TEXTURECUBE_ARRAY(textureName)        TextureCubeArray textureName
#define TEXTURE3D(textureName)                Texture3D textureName

#define TEXTURE2D_FLOAT(textureName)          TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_FLOAT(textureName)    TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_FLOAT(textureName)        TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_FLOAT(textureName)  TEXTURECUBE_ARRAY(textureName)
#define TEXTURE3D_FLOAT(textureName)          TEXTURE3D(textureName)

#define TEXTURE2D_HALF(textureName)           TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_HALF(textureName)     TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_HALF(textureName)         TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_HALF(textureName)   TEXTURECUBE_ARRAY(textureName)
#define TEXTURE3D_HALF(textureName)           TEXTURE3D(textureName)

#define TEXTURE2D_SHADOW(textureName)         TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_SHADOW(textureName)   TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_SHADOW(textureName)       TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_SHADOW(textureName) TEXTURECUBE_ARRAY(textureName)

#define RW_TEXTURE2D(type, textureName)       RWTexture2D<type> textureName
#define RW_TEXTURE2D_ARRAY(type, textureName) RWTexture2DArray<type> textureName
#define RW_TEXTURE3D(type, textureName)       RWTexture3D<type> textureName

#define SAMPLER(samplerName)                  SamplerState samplerName
#define SAMPLER_CMP(samplerName)              SamplerComparisonState samplerName

#define TEXTURE2D_PARAM(textureName, samplerName)                 TEXTURE2D(textureName), SAMPLER(samplerName)
#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)           TEXTURE2D_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_PARAM(textureName, samplerName)               TEXTURECUBE(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)         TEXTURECUBE_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURE3D_PARAM(textureName, samplerName)                 TEXTURE3D(textureName), SAMPLER(samplerName)

#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)          TEXTURE2D(textureName), SAMPLER_CMP(samplerName)
#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)    TEXTURE2D_ARRAY(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)        TEXTURECUBE(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_ARRAY_SHADOW_PARAM(textureName, samplerName)  TEXTURECUBE_ARRAY(textureName), SAMPLER_CMP(samplerName)

#define TEXTURE2D_ARGS(textureName, samplerName)                textureName, samplerName
#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)          textureName, samplerName
#define TEXTURECUBE_ARGS(textureName, samplerName)              textureName, samplerName
#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)        textureName, samplerName
#define TEXTURE3D_ARGS(textureName, samplerName)                textureName, samplerName

#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)         textureName, samplerName
#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)   textureName, samplerName
#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)       textureName, samplerName
#define TEXTURECUBE_ARRAY_SHADOW_ARGS(textureName, samplerName) textureName, samplerName

#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod)                      textureName.SampleLevel(samplerName, coord2, lod)
#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                    textureName.SampleBias(samplerName, coord2, bias)
#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, dpdx, dpdy)              textureName.SampleGrad(samplerName, coord2, dpdx, dpdy)
#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                  textureName.Sample(samplerName, float3(coord2, index))
#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)         textureName.SampleLevel(samplerName, float3(coord2, index), lod)
#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)       textureName.SampleBias(samplerName, float3(coord2, index), bias)
#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy) textureName.SampleGrad(samplerName, float3(coord2, index), dpdx, dpdy)
#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                             textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                    textureName.SampleLevel(samplerName, coord3, lod)
#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                  textureName.SampleBias(samplerName, coord3, bias)
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)                textureName.Sample(samplerName, float4(coord3, index))
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)       textureName.SampleLevel(samplerName, float4(coord3, index), lod)
#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)     textureName.SampleBias(samplerName, float4(coord3, index), bias)
#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                               textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                      textureName.SampleLevel(samplerName, coord3, lod)

#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                    textureName.SampleCmpLevelZero(samplerName, (coord3).xy, (coord3).z)
#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)       textureName.SampleCmpLevelZero(samplerName, float3((coord3).xy, index), (coord3).z)
#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                  textureName.SampleCmpLevelZero(samplerName, (coord4).xyz, (coord4).w)
#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)     textureName.SampleCmpLevelZero(samplerName, float4((coord4).xyz, index), (coord4).w)

#define LOAD_TEXTURE2D(textureName, unCoord2)                                   textureName.Load(int3(unCoord2, 0))
#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)                          textureName.Load(int3(unCoord2, lod))
#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)                 textureName.Load(unCoord2, sampleIndex)
#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)                      textureName.Load(int4(unCoord2, index, 0))
#define LOAD_TEXTURE2D_ARRAY_MSAA(textureName, unCoord2, index, sampleIndex)    textureName.Load(int3(unCoord2, index), sampleIndex)
#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod)             textureName.Load(int4(unCoord2, index, lod))
#define LOAD_TEXTURE3D(textureName, unCoord3)                                   textureName.Load(int4(unCoord3, 0))
#define LOAD_TEXTURE3D_LOD(textureName, unCoord3, lod)                          textureName.Load(int4(unCoord3, lod))

#define PLATFORM_SUPPORT_GATHER
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                textureName.Gather(samplerName, coord2)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)   textureName.Gather(samplerName, float3(coord2, index))
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)              textureName.Gather(samplerName, coord3)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index) textureName.Gather(samplerName, float4(coord3, index))
#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)            textureName.GatherRed(samplerName, coord2)
#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherGreen(samplerName, coord2)
#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)           textureName.GatherBlue(samplerName, coord2)
#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherAlpha(samplerName, coord2)

#elif defined(SHADER_API_METAL)

// Initialize arbitrary structure with zero values.
// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
#define ZERO_INITIALIZE(type, name) name = (type)0;
#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }

// Texture util abstraction

#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) textureName.CalculateLevelOfDetail(samplerName, coord2)

// Texture abstraction

#define TEXTURE2D(textureName)                Texture2D textureName
#define TEXTURE2D_ARRAY(textureName)          Texture2DArray textureName
#define TEXTURECUBE(textureName)              TextureCube textureName
#define TEXTURECUBE_ARRAY(textureName)        TextureCubeArray textureName
#define TEXTURE3D(textureName)                Texture3D textureName

#define TEXTURE2D_FLOAT(textureName)          Texture2D_float textureName
#define TEXTURE2D_ARRAY_FLOAT(textureName)    Texture2DArray textureName    // no support to _float on Array, it's being added
#define TEXTURECUBE_FLOAT(textureName)        TextureCube_float textureName
#define TEXTURECUBE_ARRAY_FLOAT(textureName)  TextureCubeArray textureName  // no support to _float on Array, it's being added
#define TEXTURE3D_FLOAT(textureName)          Texture3D_float textureName

#define TEXTURE2D_HALF(textureName)           Texture2D_half textureName
#define TEXTURE2D_ARRAY_HALF(textureName)     Texture2DArray textureName    // no support to _float on Array, it's being added
#define TEXTURECUBE_HALF(textureName)         TextureCube_half textureName
#define TEXTURECUBE_ARRAY_HALF(textureName)   TextureCubeArray textureName  // no support to _float on Array, it's being added
#define TEXTURE3D_HALF(textureName)           Texture3D_half textureName

#define TEXTURE2D_SHADOW(textureName)         TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_SHADOW(textureName)   TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_SHADOW(textureName)       TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_SHADOW(textureName) TEXTURECUBE_ARRAY(textureName)

#define RW_TEXTURE2D(type, textureName)       RWTexture2D<type> textureName
#define RW_TEXTURE2D_ARRAY(type, textureName) RWTexture2DArray<type> textureName
#define RW_TEXTURE3D(type, textureName)       RWTexture3D<type> textureName

#define SAMPLER(samplerName)                  SamplerState samplerName
#define SAMPLER_CMP(samplerName)              SamplerComparisonState samplerName

#define TEXTURE2D_PARAM(textureName, samplerName)                 TEXTURE2D(textureName), SAMPLER(samplerName)
#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)           TEXTURE2D_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_PARAM(textureName, samplerName)               TEXTURECUBE(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)         TEXTURECUBE_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURE3D_PARAM(textureName, samplerName)                 TEXTURE3D(textureName), SAMPLER(samplerName)

#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)          TEXTURE2D(textureName), SAMPLER_CMP(samplerName)
#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)    TEXTURE2D_ARRAY(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)        TEXTURECUBE(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_ARRAY_SHADOW_PARAM(textureName, samplerName)  TEXTURECUBE_ARRAY(textureName), SAMPLER_CMP(samplerName)

#define TEXTURE2D_ARGS(textureName, samplerName)                textureName, samplerName
#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)          textureName, samplerName
#define TEXTURECUBE_ARGS(textureName, samplerName)              textureName, samplerName
#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)        textureName, samplerName
#define TEXTURE3D_ARGS(textureName, samplerName)                textureName, samplerName

#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)         textureName, samplerName
#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)   textureName, samplerName
#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)       textureName, samplerName
#define TEXTURECUBE_ARRAY_SHADOW_ARGS(textureName, samplerName) textureName, samplerName

#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod)                      textureName.SampleLevel(samplerName, coord2, lod)
#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                    textureName.SampleBias(samplerName, coord2, bias)
#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, dpdx, dpdy)              textureName.SampleGrad(samplerName, coord2, dpdx, dpdy)
#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                  textureName.Sample(samplerName, float3(coord2, index))
#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)         textureName.SampleLevel(samplerName, float3(coord2, index), lod)
#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)       textureName.SampleBias(samplerName, float3(coord2, index), bias)
#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy) textureName.SampleGrad(samplerName, float3(coord2, index), dpdx, dpdy)
#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                             textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                    textureName.SampleLevel(samplerName, coord3, lod)
#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                  textureName.SampleBias(samplerName, coord3, bias)
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)                textureName.Sample(samplerName, float4(coord3, index))
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)       textureName.SampleLevel(samplerName, float4(coord3, index), lod)
#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)     textureName.SampleBias(samplerName, float4(coord3, index), bias)
#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                               textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                      textureName.SampleLevel(samplerName, coord3, lod)

#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                    textureName.SampleCmpLevelZero(samplerName, (coord3).xy, (coord3).z)
#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)       textureName.SampleCmpLevelZero(samplerName, float3((coord3).xy, index), (coord3).z)
#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                  textureName.SampleCmpLevelZero(samplerName, (coord4).xyz, (coord4).w)
#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)     textureName.SampleCmpLevelZero(samplerName, float4((coord4).xyz, index), (coord4).w)

#define LOAD_TEXTURE2D(textureName, unCoord2)                                   textureName.Load(int3(unCoord2, 0))
#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)                          textureName.Load(int3(unCoord2, lod))
#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)                 textureName.Load(unCoord2, sampleIndex)
#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)                      textureName.Load(int4(unCoord2, index, 0))
#define LOAD_TEXTURE2D_ARRAY_MSAA(textureName, unCoord2, index, sampleIndex)    textureName.Load(int3(unCoord2, index), sampleIndex)
#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod)             textureName.Load(int4(unCoord2, index, lod))
#define LOAD_TEXTURE3D(textureName, unCoord3)                                   textureName.Load(int4(unCoord3, 0))
#define LOAD_TEXTURE3D_LOD(textureName, unCoord3, lod)                          textureName.Load(int4(unCoord3, lod))

#define PLATFORM_SUPPORT_GATHER
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                textureName.Gather(samplerName, coord2)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)   textureName.Gather(samplerName, float3(coord2, index))
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)              textureName.Gather(samplerName, coord3)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index) textureName.Gather(samplerName, float4(coord3, index))
#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)            textureName.GatherRed(samplerName, coord2)
#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherGreen(samplerName, coord2)
#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)           textureName.GatherBlue(samplerName, coord2)
#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherAlpha(samplerName, coord2)

#elif defined(SHADER_API_VULKAN)
// This file assume SHADER_API_VULKAN is defined
// TODO: This is a straight copy from D3D11.hlsl. Go through all this stuff and adjust where needed.

// Initialize arbitrary structure with zero values.
// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
#define ZERO_INITIALIZE(type, name) name = (type)0;
#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }

// Texture util abstraction

#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) textureName.CalculateLevelOfDetail(samplerName, coord2)

// Texture abstraction

#define TEXTURE2D(textureName)                Texture2D textureName
#define TEXTURE2D_ARRAY(textureName)          Texture2DArray textureName
#define TEXTURECUBE(textureName)              TextureCube textureName
#define TEXTURECUBE_ARRAY(textureName)        TextureCubeArray textureName
#define TEXTURE3D(textureName)                Texture3D textureName

#define TEXTURE2D_FLOAT(textureName)          Texture2D_float textureName
#define TEXTURE2D_ARRAY_FLOAT(textureName)    Texture2DArray textureName    // no support to _float on Array, it's being added
#define TEXTURECUBE_FLOAT(textureName)        TextureCube_float textureName
#define TEXTURECUBE_ARRAY_FLOAT(textureName)  TextureCubeArray textureName  // no support to _float on Array, it's being added
#define TEXTURE3D_FLOAT(textureName)          Texture3D_float textureName

#define TEXTURE2D_HALF(textureName)           Texture2D_half textureName
#define TEXTURE2D_ARRAY_HALF(textureName)     Texture2DArray textureName    // no support to _float on Array, it's being added
#define TEXTURECUBE_HALF(textureName)         TextureCube_half textureName
#define TEXTURECUBE_ARRAY_HALF(textureName)   TextureCubeArray textureName  // no support to _float on Array, it's being added
#define TEXTURE3D_HALF(textureName)           Texture3D_half textureName

#define TEXTURE2D_SHADOW(textureName)         TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_SHADOW(textureName)   TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_SHADOW(textureName)       TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_SHADOW(textureName) TEXTURECUBE_ARRAY(textureName)

#define RW_TEXTURE2D(type, textureName)       RWTexture2D<type> textureName
#define RW_TEXTURE2D_ARRAY(type, textureName) RWTexture2DArray<type> textureName
#define RW_TEXTURE3D(type, textureName)       RWTexture3D<type> textureName

#define SAMPLER(samplerName)                  SamplerState samplerName
#define SAMPLER_CMP(samplerName)              SamplerComparisonState samplerName

#define TEXTURE2D_PARAM(textureName, samplerName)                 TEXTURE2D(textureName), SAMPLER(samplerName)
#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)           TEXTURE2D_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_PARAM(textureName, samplerName)               TEXTURECUBE(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)         TEXTURECUBE_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURE3D_PARAM(textureName, samplerName)                 TEXTURE3D(textureName), SAMPLER(samplerName)

#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)          TEXTURE2D(textureName), SAMPLER_CMP(samplerName)
#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)    TEXTURE2D_ARRAY(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)        TEXTURECUBE(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_ARRAY_SHADOW_PARAM(textureName, samplerName)  TEXTURECUBE_ARRAY(textureName), SAMPLER_CMP(samplerName)

#define TEXTURE2D_ARGS(textureName, samplerName)                textureName, samplerName
#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)          textureName, samplerName
#define TEXTURECUBE_ARGS(textureName, samplerName)              textureName, samplerName
#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)        textureName, samplerName
#define TEXTURE3D_ARGS(textureName, samplerName)                textureName, samplerName

#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)         textureName, samplerName
#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)   textureName, samplerName
#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)       textureName, samplerName
#define TEXTURECUBE_ARRAY_SHADOW_ARGS(textureName, samplerName) textureName, samplerName

#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod)                      textureName.SampleLevel(samplerName, coord2, lod)
#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                    textureName.SampleBias(samplerName, coord2, bias)
#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, dpdx, dpdy)              textureName.SampleGrad(samplerName, coord2, dpdx, dpdy)
#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                  textureName.Sample(samplerName, float3(coord2, index))
#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)         textureName.SampleLevel(samplerName, float3(coord2, index), lod)
#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)       textureName.SampleBias(samplerName, float3(coord2, index), bias)
#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy) textureName.SampleGrad(samplerName, float3(coord2, index), dpdx, dpdy)
#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                             textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                    textureName.SampleLevel(samplerName, coord3, lod)
#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                  textureName.SampleBias(samplerName, coord3, bias)
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)                textureName.Sample(samplerName, float4(coord3, index))
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)       textureName.SampleLevel(samplerName, float4(coord3, index), lod)
#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)     textureName.SampleBias(samplerName, float4(coord3, index), bias)
#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                               textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                      textureName.SampleLevel(samplerName, coord3, lod)

#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                    textureName.SampleCmpLevelZero(samplerName, (coord3).xy, (coord3).z)
#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)       textureName.SampleCmpLevelZero(samplerName, float3((coord3).xy, index), (coord3).z)
#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                  textureName.SampleCmpLevelZero(samplerName, (coord4).xyz, (coord4).w)
#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)     textureName.SampleCmpLevelZero(samplerName, float4((coord4).xyz, index), (coord4).w)

#define LOAD_TEXTURE2D(textureName, unCoord2)                                   textureName.Load(int3(unCoord2, 0))
#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)                          textureName.Load(int3(unCoord2, lod))
#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)                 textureName.Load(unCoord2, sampleIndex)
#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)                      textureName.Load(int4(unCoord2, index, 0))
#define LOAD_TEXTURE2D_ARRAY_MSAA(textureName, unCoord2, index, sampleIndex)    textureName.Load(int3(unCoord2, index), sampleIndex)
#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod)             textureName.Load(int4(unCoord2, index, lod))
#define LOAD_TEXTURE3D(textureName, unCoord3)                                   textureName.Load(int4(unCoord3, 0))
#define LOAD_TEXTURE3D_LOD(textureName, unCoord3, lod)                          textureName.Load(int4(unCoord3, lod))

#define PLATFORM_SUPPORT_GATHER
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                textureName.Gather(samplerName, coord2)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)   textureName.Gather(samplerName, float3(coord2, index))
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)              textureName.Gather(samplerName, coord3)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index) textureName.Gather(samplerName, float4(coord3, index))
#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)            textureName.GatherRed(samplerName, coord2)
#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherGreen(samplerName, coord2)
#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)           textureName.GatherBlue(samplerName, coord2)
#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherAlpha(samplerName, coord2)

#elif defined(SHADER_API_SWITCH)
// This file assume SHADER_API_SWITCH is defined

// Initialize arbitrary structure with zero values.
// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
#define ZERO_INITIALIZE(type, name) name = (type)0;
#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }

// Texture util abstraction

#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) textureName.CalculateLevelOfDetail(samplerName, coord2)

// Texture abstraction

#define TEXTURE2D(textureName)                Texture2D textureName
#define TEXTURE2D_ARRAY(textureName)          Texture2DArray textureName
#define TEXTURECUBE(textureName)              TextureCube textureName
#define TEXTURECUBE_ARRAY(textureName)        TextureCubeArray textureName
#define TEXTURE3D(textureName)                Texture3D textureName

#define TEXTURE2D_FLOAT(textureName)          Texture2D_float textureName
#define TEXTURE2D_ARRAY_FLOAT(textureName)    Texture2DArray textureName    // no support to _float on Array, it's being added
#define TEXTURECUBE_FLOAT(textureName)        TextureCube_float textureName
#define TEXTURECUBE_ARRAY_FLOAT(textureName)  TextureCubeArray textureName  // no support to _float on Array, it's being added
#define TEXTURE3D_FLOAT(textureName)          Texture3D_float textureName

#define TEXTURE2D_HALF(textureName)           Texture2D_half textureName
#define TEXTURE2D_ARRAY_HALF(textureName)     Texture2DArray textureName    // no support to _float on Array, it's being added
#define TEXTURECUBE_HALF(textureName)         TextureCube_half textureName
#define TEXTURECUBE_ARRAY_HALF(textureName)   TextureCubeArray textureName  // no support to _float on Array, it's being added
#define TEXTURE3D_HALF(textureName)           Texture3D_half textureName

#define TEXTURE2D_SHADOW(textureName)         TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_SHADOW(textureName)   TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_SHADOW(textureName)       TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_SHADOW(textureName) TEXTURECUBE_ARRAY(textureName)

#define RW_TEXTURE2D(type, textureName)       RWTexture2D<type> textureName
#define RW_TEXTURE2D_ARRAY(type, textureName) RWTexture2DArray<type> textureName
#define RW_TEXTURE3D(type, textureName)       RWTexture3D<type> textureName

#define SAMPLER(samplerName)                  SamplerState samplerName
#define SAMPLER_CMP(samplerName)              SamplerComparisonState samplerName

#define TEXTURE2D_PARAM(textureName, samplerName)                 TEXTURE2D(textureName), SAMPLER(samplerName)
#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)           TEXTURE2D_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_PARAM(textureName, samplerName)               TEXTURECUBE(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)         TEXTURECUBE_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURE3D_PARAM(textureName, samplerName)                 TEXTURE3D(textureName), SAMPLER(samplerName)

#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)          TEXTURE2D(textureName), SAMPLER_CMP(samplerName)
#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)    TEXTURE2D_ARRAY(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)        TEXTURECUBE(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_ARRAY_SHADOW_PARAM(textureName, samplerName)  TEXTURECUBE_ARRAY(textureName), SAMPLER_CMP(samplerName)

#define TEXTURE2D_ARGS(textureName, samplerName)                textureName, samplerName
#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)          textureName, samplerName
#define TEXTURECUBE_ARGS(textureName, samplerName)              textureName, samplerName
#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)        textureName, samplerName
#define TEXTURE3D_ARGS(textureName, samplerName)                textureName, samplerName

#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)         textureName, samplerName
#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)   textureName, samplerName
#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)       textureName, samplerName
#define TEXTURECUBE_ARRAY_SHADOW_ARGS(textureName, samplerName) textureName, samplerName

#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod)                      textureName.SampleLevel(samplerName, coord2, lod)
#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                    textureName.SampleBias(samplerName, coord2, bias)
#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, dpdx, dpdy)              textureName.SampleGrad(samplerName, coord2, dpdx, dpdy)
#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                  textureName.Sample(samplerName, float3(coord2, index))
#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)         textureName.SampleLevel(samplerName, float3(coord2, index), lod)
#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)       textureName.SampleBias(samplerName, float3(coord2, index), bias)
#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy) textureName.SampleGrad(samplerName, float3(coord2, index), dpdx, dpdy)
#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                             textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                    textureName.SampleLevel(samplerName, coord3, lod)
#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                  textureName.SampleBias(samplerName, coord3, bias)
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)                textureName.Sample(samplerName, float4(coord3, index))
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)       textureName.SampleLevel(samplerName, float4(coord3, index), lod)
#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)     textureName.SampleBias(samplerName, float4(coord3, index), bias)
#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                               textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                      textureName.SampleLevel(samplerName, coord3, lod)

#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                    textureName.SampleCmpLevelZero(samplerName, (coord3).xy, (coord3).z)
#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)       textureName.SampleCmpLevelZero(samplerName, float3((coord3).xy, index), (coord3).z)
#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                  textureName.SampleCmpLevelZero(samplerName, (coord4).xyz, (coord4).w)
#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)     textureName.SampleCmpLevelZero(samplerName, float4((coord4).xyz, index), (coord4).w)

#define LOAD_TEXTURE2D(textureName, unCoord2)                       textureName.Load(int3(unCoord2, 0))
#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)              textureName.Load(int3(unCoord2, lod))
#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)     textureName.Load(unCoord2, sampleIndex)
#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)          textureName.Load(int4(unCoord2, index, 0))
#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod) textureName.Load(int4(unCoord2, index, lod))
#define LOAD_TEXTURE3D(textureName, unCoord3)                       textureName.Load(int4(unCoord3, 0))
#define LOAD_TEXTURE3D_LOD(textureName, unCoord3, lod)              textureName.Load(int4(unCoord3, lod))

#define PLATFORM_SUPPORT_GATHER
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                textureName.Gather(samplerName, coord2)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)   textureName.Gather(samplerName, float3(coord2, index))
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)              textureName.Gather(samplerName, coord3)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index) textureName.Gather(samplerName, float4(coord3, index))
#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)            textureName.GatherRed(samplerName, coord2)
#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherGreen(samplerName, coord2)
#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)           textureName.GatherBlue(samplerName, coord2)
#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)          textureName.GatherAlpha(samplerName, coord2)

#elif defined(SHADER_API_GLCORE)

// OpenGL 4.1 SM 5.0 https://docs.unity3d.com/Manual/SL-ShaderCompileTargets.html
#if (SHADER_TARGET >= 46)
#define OPENGL4_1_SM5 1
#else
#define OPENGL4_1_SM5 0
#endif

// Initialize arbitrary structure with zero values.
// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
#define ZERO_INITIALIZE(type, name) name = (type)0;
#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }

// Texture util abstraction

#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) textureName.CalculateLevelOfDetail(samplerName, coord2)

// Texture abstraction

#define TEXTURE2D(textureName)                  Texture2D textureName
#define TEXTURE2D_ARRAY(textureName)            Texture2DArray textureName
#define TEXTURECUBE(textureName)                TextureCube textureName
#define TEXTURECUBE_ARRAY(textureName)          TextureCubeArray textureName
#define TEXTURE3D(textureName)                  Texture3D textureName

#define TEXTURE2D_FLOAT(textureName)            TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_FLOAT(textureName)      TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_FLOAT(textureName)          TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_FLOAT(textureName)    TEXTURECUBE_ARRAY(textureName)
#define TEXTURE3D_FLOAT(textureName)            TEXTURE3D(textureName)

#define TEXTURE2D_HALF(textureName)             TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_HALF(textureName)       TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_HALF(textureName)           TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_HALF(textureName)     TEXTURECUBE_ARRAY(textureName)
#define TEXTURE3D_HALF(textureName)             TEXTURE3D(textureName)

#define TEXTURE2D_SHADOW(textureName)           TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_SHADOW(textureName)     TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_SHADOW(textureName)         TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_SHADOW(textureName)   TEXTURECUBE_ARRAY(textureName)

#define RW_TEXTURE2D(type, textureName)         RWTexture2D<type> textureName
#define RW_TEXTURE2D_ARRAY(type, textureName)   RWTexture2DArray<type> textureName
#define RW_TEXTURE3D(type, textureName)         RWTexture3D<type> textureName

#define SAMPLER(samplerName)                    SamplerState samplerName
#define SAMPLER_CMP(samplerName)                SamplerComparisonState samplerName

#define TEXTURE2D_PARAM(textureName, samplerName)                 TEXTURE2D(textureName), SAMPLER(samplerName)
#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)           TEXTURE2D_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_PARAM(textureName, samplerName)               TEXTURECUBE(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)         TEXTURECUBE_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURE3D_PARAM(textureName, samplerName)                 TEXTURE3D(textureName), SAMPLER(samplerName)

#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)          TEXTURE2D(textureName), SAMPLER_CMP(samplerName)
#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)    TEXTURE2D_ARRAY(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)        TEXTURECUBE(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_ARRAY_SHADOW_PARAM(textureName, samplerName)  TEXTURECUBE_ARRAY(textureName), SAMPLER_CMP(samplerName)

#define TEXTURE2D_ARGS(textureName, samplerName)                textureName, samplerName
#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)          textureName, samplerName
#define TEXTURECUBE_ARGS(textureName, samplerName)              textureName, samplerName
#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)        textureName, samplerName
#define TEXTURE3D_ARGS(textureName, samplerName)                textureName, samplerName

#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)         textureName, samplerName
#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)   textureName, samplerName
#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)       textureName, samplerName
#define TEXTURECUBE_ARRAY_SHADOW_ARGS(textureName, samplerName) textureName, samplerName

#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod)                      textureName.SampleLevel(samplerName, coord2, lod)
#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                    textureName.SampleBias(samplerName, coord2, bias)
#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, ddx, ddy)                textureName.SampleGrad(samplerName, coord2, ddx, ddy)
#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                  textureName.Sample(samplerName, float3(coord2, index))
#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)         textureName.SampleLevel(samplerName, float3(coord2, index), lod)
#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)       textureName.SampleBias(samplerName, float3(coord2, index), bias)
#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy) textureName.SampleGrad(samplerName, float3(coord2, index), dpdx, dpdy)
#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                             textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                    textureName.SampleLevel(samplerName, coord3, lod)
#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                  textureName.SampleBias(samplerName, coord3, bias)
#ifdef UNITY_NO_CUBEMAP_ARRAY
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)           ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY)
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)  ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY_LOD)
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, bias) ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY_LOD)
#else
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)           textureName.Sample(samplerName, float4(coord3, index))
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)  textureName.SampleLevel(samplerName, float4(coord3, index), lod)
#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)textureName.SampleBias(samplerName, float4(coord3, index), bias)
#endif
#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                          textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                 textureName.SampleLevel(samplerName, coord3, lod)

#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                   textureName.SampleCmpLevelZero(samplerName, (coord3).xy, (coord3).z)
#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)      textureName.SampleCmpLevelZero(samplerName, float3((coord3).xy, index), (coord3).z)
#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                 textureName.SampleCmpLevelZero(samplerName, (coord4).xyz, (coord4).w)
#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)    textureName.SampleCmpLevelZero(samplerName, float4((coord4).xyz, index), (coord4).w)

#define LOAD_TEXTURE2D(textureName, unCoord2)                                   textureName.Load(int3(unCoord2, 0))
#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)                          textureName.Load(int3(unCoord2, lod))
#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)                 textureName.Load(unCoord2, sampleIndex)
#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)                      textureName.Load(int4(unCoord2, index, 0))
#define LOAD_TEXTURE2D_ARRAY_MSAA(textureName, unCoord2, index, sampleIndex)    textureName.Load(int3(unCoord2, index), sampleIndex)
#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod)             textureName.Load(int4(unCoord2, index, lod))

#if OPENGL4_1_SM5
#define PLATFORM_SUPPORT_GATHER
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                  textureName.Gather(samplerName, coord2)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)     textureName.Gather(samplerName, float3(coord2, index))
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)                textureName.Gather(samplerName, coord3)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)   textureName.Gather(samplerName, float4(coord3, index))
#else
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                  ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURE2D)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)     ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURE2D_ARRAY)
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)                ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURECUBE)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)   ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURECUBE_ARRAY)
#endif

#elif defined(SHADER_API_GLES3)

// GLES 3.1 + AEP shader feature https://docs.unity3d.com/Manual/SL-ShaderCompileTargets.html
#if (SHADER_TARGET >= 40)
#define GLES3_1_AEP 1
#else
#define GLES3_1_AEP 0
#endif

// Initialize arbitrary structure with zero values.
// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
#define ZERO_INITIALIZE(type, name) name = (type)0;
#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }

// Texture util abstraction

#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) textureName.CalculateLevelOfDetail(samplerName, coord2)

// Texture abstraction

#define TEXTURE2D(textureName)                  Texture2D textureName
#define TEXTURE2D_ARRAY(textureName)            Texture2DArray textureName
#define TEXTURECUBE(textureName)                TextureCube textureName
#define TEXTURECUBE_ARRAY(textureName)          TextureCubeArray textureName
#define TEXTURE3D(textureName)                  Texture3D textureName

#define TEXTURE2D_FLOAT(textureName)            Texture2D_float textureName
#define TEXTURE2D_ARRAY_FLOAT(textureName)      Texture2DArray textureName    // no support to _float on Array, it's being added
#define TEXTURECUBE_FLOAT(textureName)          TextureCube_float textureName
#define TEXTURECUBE_ARRAY_FLOAT(textureName)    TextureCubeArray textureName  // no support to _float on Array, it's being added
#define TEXTURE3D_FLOAT(textureName)            Texture3D_float textureName

#define TEXTURE2D_HALF(textureName)             Texture2D_half textureName
#define TEXTURE2D_ARRAY_HALF(textureName)       Texture2DArray textureName    // no support to _float on Array, it's being added
#define TEXTURECUBE_HALF(textureName)           TextureCube_half textureName
#define TEXTURECUBE_ARRAY_HALF(textureName)     TextureCubeArray textureName  // no support to _float on Array, it's being added
#define TEXTURE3D_HALF(textureName)             Texture3D_half textureName

#define TEXTURE2D_SHADOW(textureName)           TEXTURE2D(textureName)
#define TEXTURE2D_ARRAY_SHADOW(textureName)     TEXTURE2D_ARRAY(textureName)
#define TEXTURECUBE_SHADOW(textureName)         TEXTURECUBE(textureName)
#define TEXTURECUBE_ARRAY_SHADOW(textureName)   TEXTURECUBE_ARRAY(textureName)

#if GLES3_1_AEP
#define RW_TEXTURE2D(type, textureName)         RWTexture2D<type> textureName
#define RW_TEXTURE2D_ARRAY(type, textureName)   RWTexture2DArray<type> textureName
#define RW_TEXTURE3D(type, textureName)         RWTexture3D<type> textureName
#else
#define RW_TEXTURE2D(type, textureName)         ERROR_ON_UNSUPPORTED_FUNCTION(RWTexture2D)
#define RW_TEXTURE2D_ARRAY(type, textureName)   ERROR_ON_UNSUPPORTED_FUNCTION(RWTexture2DArray)
#define RW_TEXTURE3D(type, textureName)         ERROR_ON_UNSUPPORTED_FUNCTION(RWTexture3D)
#endif

#define SAMPLER(samplerName)                    SamplerState samplerName
#define SAMPLER_CMP(samplerName)                SamplerComparisonState samplerName

#define TEXTURE2D_PARAM(textureName, samplerName)                 TEXTURE2D(textureName), SAMPLER(samplerName)
#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)           TEXTURE2D_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_PARAM(textureName, samplerName)               TEXTURECUBE(textureName), SAMPLER(samplerName)
#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)         TEXTURECUBE_ARRAY(textureName), SAMPLER(samplerName)
#define TEXTURE3D_PARAM(textureName, samplerName)                 TEXTURE3D(textureName), SAMPLER(samplerName)

#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)          TEXTURE2D(textureName), SAMPLER_CMP(samplerName)
#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)    TEXTURE2D_ARRAY(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)        TEXTURECUBE(textureName), SAMPLER_CMP(samplerName)
#define TEXTURECUBE_ARRAY_SHADOW_PARAM(textureName, samplerName)  TEXTURECUBE_ARRAY(textureName), SAMPLER_CMP(samplerName)

#define TEXTURE2D_ARGS(textureName, samplerName)                textureName, samplerName
#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)          textureName, samplerName
#define TEXTURECUBE_ARGS(textureName, samplerName)              textureName, samplerName
#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)        textureName, samplerName
#define TEXTURE3D_ARGS(textureName, samplerName)                textureName, samplerName

#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)         textureName, samplerName
#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)   textureName, samplerName
#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)       textureName, samplerName
#define TEXTURECUBE_ARRAY_SHADOW_ARGS(textureName, samplerName) textureName, samplerName

#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2)                               textureName.Sample(samplerName, coord2)
#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod)                      textureName.SampleLevel(samplerName, coord2, lod)
#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                    textureName.SampleBias(samplerName, coord2, bias)
#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, ddx, ddy)                textureName.SampleGrad(samplerName, coord2, ddx, ddy)
#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                  textureName.Sample(samplerName, float3(coord2, index))
#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)         textureName.SampleLevel(samplerName, float3(coord2, index), lod)
#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)       textureName.SampleBias(samplerName, float3(coord2, index), bias)
#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy) textureName.SampleGrad(samplerName, float3(coord2, index), dpdx, dpdy)
#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                             textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                    textureName.SampleLevel(samplerName, coord3, lod)
#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                  textureName.SampleBias(samplerName, coord3, bias)

#ifdef UNITY_NO_CUBEMAP_ARRAY
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)           ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY)
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)  ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY_LOD)
#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY_BIAS)
#else
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)           textureName.Sample(samplerName, float4(coord3, index))
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)  textureName.SampleLevel(samplerName, float4(coord3, index), lod)
#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)textureName.SampleBias(samplerName, float4(coord3, index), bias)
#endif

#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                          textureName.Sample(samplerName, coord3)
#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                 textureName.SampleLevel(samplerName, coord3, lod)

#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                   textureName.SampleCmpLevelZero(samplerName, (coord3).xy, (coord3).z)
#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)      textureName.SampleCmpLevelZero(samplerName, float3((coord3).xy, index), (coord3).z)
#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                 textureName.SampleCmpLevelZero(samplerName, (coord4).xyz, (coord4).w)
#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)    textureName.SampleCmpLevelZero(samplerName, float4((coord4).xyz, index), (coord4).w)

#define LOAD_TEXTURE2D(textureName, unCoord2)                                       textureName.Load(int3(unCoord2, 0))
#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)                              textureName.Load(int3(unCoord2, lod))
#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)                     textureName.Load(unCoord2, sampleIndex)
#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)                          textureName.Load(int4(unCoord2, index, 0))
#define LOAD_TEXTURE2D_ARRAY_MSAA(textureName, unCoord2, index, sampleIndex)        textureName.Load(int3(unCoord2, index), sampleIndex)
#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod)                 textureName.Load(int4(unCoord2, index, lod))
#define LOAD_TEXTURE3D(textureName, unCoord3)                                       textureName.Load(int4(unCoord3, 0))
#define LOAD_TEXTURE3D_LOD(textureName, unCoord3, lod)                              textureName.Load(int4(unCoord3, lod))

#if GLES3_1_AEP
#define PLATFORM_SUPPORT_GATHER
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                  textureName.Gather(samplerName, coord2)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)     textureName.Gather(samplerName, float3(coord2, index))
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)                textureName.Gather(samplerName, coord3)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)   textureName.Gather(samplerName, float4(coord3, index))
#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)              textureName.GatherRed(samplerName, coord2)
#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)            textureName.GatherGreen(samplerName, coord2)
#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)             textureName.GatherBlue(samplerName, coord2)
#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)            textureName.GatherAlpha(samplerName, coord2)
#else
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                  ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURE2D)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)     ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURE2D_ARRAY)
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)                ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURECUBE)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)   ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURECUBE_ARRAY)
#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)              ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_RED_TEXTURE2D)
#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)            ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_GREEN_TEXTURE2D)
#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)             ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_BLUE_TEXTURE2D)
#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)            ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_ALPHA_TEXTURE2D)
#endif

#elif defined(SHADER_API_GLES)

#define uint int

#define rcp(x) 1.0 / (x)
#define ddx_fine ddx
#define ddy_fine ddy
#define asfloat
#define asuint(x) asint(x)
#define f32tof16
#define f16tof32

#define ERROR_ON_UNSUPPORTED_FUNCTION(funcName) #error #funcName is not supported on GLES 2.0

// Initialize arbitrary structure with zero values.
// Do not exist on some platform, in this case we need to have a standard name that call a function that will initialize all parameters to 0
#define ZERO_INITIALIZE(type, name) name = (type)0;
#define ZERO_INITIALIZE_ARRAY(type, name, arraySize) { for (int arrayIndex = 0; arrayIndex < arraySize; arrayIndex++) { name[arrayIndex] = (type)0; } }

// Texture util abstraction

#define CALCULATE_TEXTURE2D_LOD(textureName, samplerName, coord2) #error calculate Level of Detail not supported in GLES2

// Texture abstraction

#define TEXTURE2D(textureName)                          sampler2D textureName
#define TEXTURE2D_ARRAY(textureName)                    samplerCUBE textureName // No support to texture2DArray
#define TEXTURECUBE(textureName)                        samplerCUBE textureName
#define TEXTURECUBE_ARRAY(textureName)                  samplerCUBE textureName // No supoport to textureCubeArray and can't emulate with texture2DArray
#define TEXTURE3D(textureName)                          sampler3D textureName

#define TEXTURE2D_FLOAT(textureName)                    sampler2D_float textureName
#define TEXTURE2D_ARRAY_FLOAT(textureName)              TEXTURECUBE_FLOAT(textureName) // No support to texture2DArray
#define TEXTURECUBE_FLOAT(textureName)                  samplerCUBE_float textureName
#define TEXTURECUBE_ARRAY_FLOAT(textureName)            TEXTURECUBE_FLOAT(textureName) // No support to textureCubeArray
#define TEXTURE3D_FLOAT(textureName)                    sampler3D_float textureName

#define TEXTURE2D_HALF(textureName)                     sampler2D_half textureName
#define TEXTURE2D_ARRAY_HALF(textureName)               TEXTURECUBE_HALF(textureName) // No support to texture2DArray
#define TEXTURECUBE_HALF(textureName)                   samplerCUBE_half textureName
#define TEXTURECUBE_ARRAY_HALF(textureName)             TEXTURECUBE_HALF(textureName) // No support to textureCubeArray
#define TEXTURE3D_HALF(textureName)                     sampler3D_half textureName

#define TEXTURE2D_SHADOW(textureName)                   SHADOW2D_TEXTURE_AND_SAMPLER textureName
#define TEXTURE2D_ARRAY_SHADOW(textureName)             TEXTURECUBE_SHADOW(textureName) // No support to texture array
#define TEXTURECUBE_SHADOW(textureName)                 SHADOWCUBE_TEXTURE_AND_SAMPLER textureName
#define TEXTURECUBE_ARRAY_SHADOW(textureName)           TEXTURECUBE_SHADOW(textureName) // No support to texture array

#define RW_TEXTURE2D(type, textureNam)                  ERROR_ON_UNSUPPORTED_FUNCTION(RWTexture2D)
#define RW_TEXTURE2D_ARRAY(type, textureName)           ERROR_ON_UNSUPPORTED_FUNCTION(RWTexture2DArray)
#define RW_TEXTURE3D(type, textureNam)                  ERROR_ON_UNSUPPORTED_FUNCTION(RWTexture3D)

#define SAMPLER(samplerName)
#define SAMPLER_CMP(samplerName)

#define TEXTURE2D_PARAM(textureName, samplerName)                sampler2D textureName
#define TEXTURE2D_ARRAY_PARAM(textureName, samplerName)          samplerCUBE textureName
#define TEXTURECUBE_PARAM(textureName, samplerName)              samplerCUBE textureName
#define TEXTURECUBE_ARRAY_PARAM(textureName, samplerName)        samplerCUBE textureName
#define TEXTURE3D_PARAM(textureName, samplerName)                sampler3D textureName
#define TEXTURE2D_SHADOW_PARAM(textureName, samplerName)         SHADOW2D_TEXTURE_AND_SAMPLER textureName
#define TEXTURE2D_ARRAY_SHADOW_PARAM(textureName, samplerName)   SHADOWCUBE_TEXTURE_AND_SAMPLER textureName
#define TEXTURECUBE_SHADOW_PARAM(textureName, samplerName)       SHADOWCUBE_TEXTURE_AND_SAMPLER textureName

#define TEXTURE2D_ARGS(textureName, samplerName)               textureName
#define TEXTURE2D_ARRAY_ARGS(textureName, samplerName)         textureName
#define TEXTURECUBE_ARGS(textureName, samplerName)             textureName
#define TEXTURECUBE_ARRAY_ARGS(textureName, samplerName)       textureName
#define TEXTURE3D_ARGS(textureName, samplerName)               textureName
#define TEXTURE2D_SHADOW_ARGS(textureName, samplerName)        textureName
#define TEXTURE2D_ARRAY_SHADOW_ARGS(textureName, samplerName)  textureName
#define TEXTURECUBE_SHADOW_ARGS(textureName, samplerName)      textureName

#define SAMPLE_TEXTURE2D(textureName, samplerName, coord2) tex2D(textureName, coord2)

#if (SHADER_TARGET >= 30)
#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod) tex2Dlod(textureName, float4(coord2, 0, lod))
#else
// No lod support. Very poor approximation with bias.
#define SAMPLE_TEXTURE2D_LOD(textureName, samplerName, coord2, lod) SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, lod)
#endif

#define SAMPLE_TEXTURE2D_BIAS(textureName, samplerName, coord2, bias)                       tex2Dbias(textureName, float4(coord2, 0, bias))
#define SAMPLE_TEXTURE2D_GRAD(textureName, samplerName, coord2, ddx, ddy)                   SAMPLE_TEXTURE2D(textureName, samplerName, coord2)
#define SAMPLE_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)                     ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURE2D_ARRAY)
#define SAMPLE_TEXTURE2D_ARRAY_LOD(textureName, samplerName, coord2, index, lod)            ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURE2D_ARRAY_LOD)
#define SAMPLE_TEXTURE2D_ARRAY_BIAS(textureName, samplerName, coord2, index, bias)          ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURE2D_ARRAY_BIAS)
#define SAMPLE_TEXTURE2D_ARRAY_GRAD(textureName, samplerName, coord2, index, dpdx, dpdy)    ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURE2D_ARRAY_GRAD)
#define SAMPLE_TEXTURECUBE(textureName, samplerName, coord3)                                texCUBE(textureName, coord3)
// No lod support. Very poor approximation with bias.
#define SAMPLE_TEXTURECUBE_LOD(textureName, samplerName, coord3, lod)                       SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, lod)
#define SAMPLE_TEXTURECUBE_BIAS(textureName, samplerName, coord3, bias)                     texCUBEbias(textureName, float4(coord3, bias))
#define SAMPLE_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)                   ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY)
#define SAMPLE_TEXTURECUBE_ARRAY_LOD(textureName, samplerName, coord3, index, lod)          ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY_LOD)
#define SAMPLE_TEXTURECUBE_ARRAY_BIAS(textureName, samplerName, coord3, index, bias)        ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY_BIAS)
#define SAMPLE_TEXTURE3D(textureName, samplerName, coord3)                                  tex3D(textureName, coord3)
#define SAMPLE_TEXTURE3D_LOD(textureName, samplerName, coord3, lod)                         ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURE3D_LOD)

#define SAMPLE_TEXTURE2D_SHADOW(textureName, samplerName, coord3)                           SHADOW2D_SAMPLE(textureName, samplerName, coord3)
#define SAMPLE_TEXTURE2D_ARRAY_SHADOW(textureName, samplerName, coord3, index)              ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURE2D_ARRAY_SHADOW)
#define SAMPLE_TEXTURECUBE_SHADOW(textureName, samplerName, coord4)                         SHADOWCUBE_SAMPLE(textureName, samplerName, coord4)
#define SAMPLE_TEXTURECUBE_ARRAY_SHADOW(textureName, samplerName, coord4, index)            ERROR_ON_UNSUPPORTED_FUNCTION(SAMPLE_TEXTURECUBE_ARRAY_SHADOW)

// Not supported. Can't define as error because shader library is calling these functions.
#define LOAD_TEXTURE2D(textureName, unCoord2)                                               half4(0, 0, 0, 0)
#define LOAD_TEXTURE2D_LOD(textureName, unCoord2, lod)                                      half4(0, 0, 0, 0)
#define LOAD_TEXTURE2D_MSAA(textureName, unCoord2, sampleIndex)                             half4(0, 0, 0, 0)
#define LOAD_TEXTURE2D_ARRAY(textureName, unCoord2, index)                                  half4(0, 0, 0, 0)
#define LOAD_TEXTURE2D_ARRAY_MSAA(textureName, unCoord2, index, sampleIndex)                half4(0, 0, 0, 0)
#define LOAD_TEXTURE2D_ARRAY_LOD(textureName, unCoord2, index, lod)                         half4(0, 0, 0, 0)
#define LOAD_TEXTURE3D(textureName, unCoord3)                                               ERROR_ON_UNSUPPORTED_FUNCTION(LOAD_TEXTURE3D)
#define LOAD_TEXTURE3D_LOD(textureName, unCoord3, lod)                                      ERROR_ON_UNSUPPORTED_FUNCTION(LOAD_TEXTURE3D_LOD)

// Gather not supported. Fallback to regular texture sampling.
#define GATHER_TEXTURE2D(textureName, samplerName, coord2)                  ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURE2D)
#define GATHER_TEXTURE2D_ARRAY(textureName, samplerName, coord2, index)     ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURE2D_ARRAY)
#define GATHER_TEXTURECUBE(textureName, samplerName, coord3)                ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURECUBE)
#define GATHER_TEXTURECUBE_ARRAY(textureName, samplerName, coord3, index)   ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_TEXTURECUBE_ARRAY)
#define GATHER_RED_TEXTURE2D(textureName, samplerName, coord2)              ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_RED_TEXTURE2D)
#define GATHER_GREEN_TEXTURE2D(textureName, samplerName, coord2)            ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_GREEN_TEXTURE2D)
#define GATHER_BLUE_TEXTURE2D(textureName, samplerName, coord2)             ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_BLUE_TEXTURE2D)
#define GATHER_ALPHA_TEXTURE2D(textureName, samplerName, coord2)            ERROR_ON_UNSUPPORTED_FUNCTION(GATHER_ALPHA_TEXTURE2D)

#else
#error unsupported shader api
#endif

// default flow control attributes
#ifndef UNITY_BRANCH
#   define UNITY_BRANCH
#endif
#ifndef UNITY_FLATTEN
#   define UNITY_FLATTEN
#endif
#ifndef UNITY_UNROLL
#   define UNITY_UNROLL
#endif
#ifndef UNITY_UNROLLX
#   define UNITY_UNROLLX(_x)
#endif
#ifndef UNITY_LOOP
#   define UNITY_LOOP
#endif

struct VertexData
{
float4 vertex : POSITION;
float3 normal : NORMAL;
float4 tangent : TANGENT;
float4 color : COLOR;
float2 uv0 : TEXCOORD0;
float2 uv1 : TEXCOORD1;
float2 uv2 : TEXCOORD2;
float2 uv3 : TEXCOORD3;
UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct FragmentData
{
#if defined(UNITY_PASS_SHADOWCASTER)
V2F_SHADOW_CASTER;
float2 uv0 : TEXCOORD1;
float2 uv1 : TEXCOORD2;
float2 uv2 : TEXCOORD3;
float2 uv3 : TEXCOORD4;
float3 worldPos : TEXCOORD5;
float3 worldNormal : TEXCOORD6;
float4 worldTangent : TEXCOORD7;
#else
float4 pos : SV_POSITION;
float3 normal : NORMAL;
float2 uv0 : TEXCOORD0;
float2 uv1 : TEXCOORD1;
float2 uv2 : TEXCOORD2;
float2 uv3 : TEXCOORD3;
float3 worldPos : TEXCOORD4;
float3 worldNormal : TEXCOORD5;
float4 worldTangent : TEXCOORD6;
float4 lightmapUv : TEXCOORD7;
float4 vertexColor : TEXCOORD8;

#if !defined(UNITY_PASS_META)
UNITY_LIGHTING_COORDS(9, 10)
UNITY_FOG_COORDS(11)
#endif
#endif

#if defined(EDITOR_VISUALIZATION)
float2 vizUV : TEXCOORD9;
float4 lightCoord : TEXCOORD10;
#endif

#if defined(NEED_SCREEN_POS)
float4 screenPos: SCREENPOS;
#endif

#if defined(EXTRA_V2F_0)
#if defined(UNITY_PASS_SHADOWCASTER)
float4 extraV2F0 : TEXCOORD8;
#else
#if !defined(UNITY_PASS_META)
float4 extraV2F0 : TEXCOORD12;
#else
#if defined(EDITOR_VISUALIZATION)
float4 extraV2F0 : TEXCOORD11;
#else
float4 extraV2F0 : TEXCOORD9;
#endif
#endif
#endif
#endif
#if defined(EXTRA_V2F_1)
#if defined(UNITY_PASS_SHADOWCASTER)
float4 extraV2F1 : TEXCOORD9;
#else
#if !defined(UNITY_PASS_META)
float4 extraV2F1 : TEXCOORD13;
#else
#if defined(EDITOR_VISUALIZATION)
float4 extraV2F1 : TEXCOORD14;
#else
float4 extraV2F1 : TEXCOORD15;
#endif
#endif
#endif
#endif
#if defined(EXTRA_V2F_2)
#if defined(UNITY_PASS_SHADOWCASTER)
float4 extraV2F2 : TEXCOORD10;
#else
#if !defined(UNITY_PASS_META)
float4 extraV2F2 : TEXCOORD14;
#else
#if defined(EDITOR_VISUALIZATION)
float4 extraV2F2 : TEXCOORD15
#else
float4 extraV2F2 : TEXCOORD16;
#endif
#endif
#endif
#endif

UNITY_VERTEX_INPUT_INSTANCE_ID
UNITY_VERTEX_OUTPUT_STEREO
};

struct MeshData
{
half2 uv0;
half2 uv1;
half2 uv2;
half2 uv3;
half3 vertexColor;
half3 normal;
half3 worldNormal;
half3 localSpacePosition;
half3 worldSpacePosition;
half3 worldSpaceViewDir;
half3 tangentSpaceViewDir;
half3 worldSpaceTangent;
float3 bitangent;
float3x3 TBNMatrix;
half3 svdn;
float4 extraV2F0;
float4 extraV2F1;
float4 extraV2F2;
float4 screenPos;
};

MeshData CreateMeshData(FragmentData i)
{
MeshData m = (MeshData) 0;
m.uv0 = i.uv0;
m.uv1 = i.uv1;
m.uv2 = i.uv2;
m.uv3 = i.uv3;
m.worldNormal = normalize(i.worldNormal);
m.localSpacePosition = mul(unity_WorldToObject, float4(i.worldPos, 1)).xyz;
m.worldSpacePosition = i.worldPos;
m.worldSpaceViewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

#if !defined(UNITY_PASS_SHADOWCASTER)
m.vertexColor = i.vertexColor;
m.normal = i.normal;
m.bitangent = cross(i.worldTangent.xyz, i.worldNormal) * i.worldTangent.w * - 1;
m.worldSpaceTangent = i.worldTangent.xyz;
m.TBNMatrix = float3x3(normalize(i.worldTangent.xyz), m.bitangent, m.worldNormal);
m.tangentSpaceViewDir = mul(m.TBNMatrix, m.worldSpaceViewDir);
#endif

#if UNITY_SINGLE_PASS_STEREO
half3 stereoCameraPos = half3((unity_StereoWorldSpaceCameraPos[0]+ unity_StereoWorldSpaceCameraPos[1])*.5);
m.svdn = normalize(stereoCameraPos - m.worldSpacePosition);
#else
m.svdn = m.worldSpaceViewDir;
#endif

#if defined(EXTRA_V2F_0)
m.extraV2F0 = i.extraV2F0;
#endif
#if defined(EXTRA_V2F_1)
m.extraV2F1 = i.extraV2F1;
#endif
#if defined(EXTRA_V2F_2)
m.extraV2F2 = i.extraV2F2;
#endif
#if defined(NEED_SCREEN_POS)
m.screenPos = i.screenPos;
#endif

return m;
}

struct SurfaceData
{
half3 Albedo;
half3 Emission;
int EmissionScaleWithLight;
half EmissionLightThreshold;
half Metallic;
half Smoothness;
half Occlusion;
int OcclusionMode;
half3 Normal;
half Alpha;
half Anisotropy;
half ShadowSharpness;
half4 RimLight;
half RimAttenuation;
half4 RimShadow;
half SpecularIntensity;
half SpecularArea;
half SpecularAlbedoTint;
half SpecularAnisotropy;
half SpecularSharpness;
half Reflectivity;
half3 BakedReflection;
int ReflectionBlendMode;
int EnableReflections;
half3 OutlineColor;
int OutlineLightingMode;
};

FragmentData FragData;
SurfaceData o;
MeshData d;
VertexData vD;
float4 FinalColor;

half invLerp(half a, half b, half v)
{
return (v - a) / (b - a);
}

half getBakedNoise(Texture2D noiseTex, SamplerState noiseTexSampler, half3 p)
{
half3 i = floor(p); p -= i; p *= p * (3. - 2. * p);
half2 uv = (p.xy + i.xy + half2(37, 17) * i.z + .5) / 256.;
uv.y *= -1;
p.xy = noiseTex.SampleLevel(noiseTexSampler, uv, 0).yx;
return lerp(p.x, p.y, p.z);
}

half3 TransformObjectToWorld(half3 pos)
{
return mul(unity_ObjectToWorld, half4(pos, 1)).xyz;
};

// mostly taken from the Amplify shader reference
half2 POM(Texture2D heightMap, SamplerState heightSampler, half2 uvs, half2 dx, half2 dy, half3 normalWorld, half3 viewWorld, half3 viewDirTan, int minSamples, int maxSamples, half parallax, half refPlane, half2 tilling, half2 curv, int index, inout half finalHeight)
{
half3 result = 0;
int stepIndex = 0;
int numSteps = (int)lerp((half)maxSamples, (half)minSamples, saturate(dot(normalWorld, viewWorld)));
half layerHeight = 1.0 / numSteps;
half2 plane = parallax * (viewDirTan.xy / viewDirTan.z);
uvs.xy += refPlane * plane;
half2 deltaTex = -plane * layerHeight;
half2 prevTexOffset = 0;
half prevRayZ = 1.0f;
half prevHeight = 0.0f;
half2 currTexOffset = deltaTex;
half currRayZ = 1.0f - layerHeight;
half currHeight = 0.0f;
half intersection = 0;
half2 finalTexOffset = 0;
while (stepIndex < numSteps + 1)
{
currHeight = SAMPLE_TEXTURE2D_GRAD(heightMap, heightSampler, uvs + currTexOffset, dx, dy).r;
if (currHeight > currRayZ)
{
stepIndex = numSteps + 1;
}
else
{
stepIndex++;
prevTexOffset = currTexOffset;
prevRayZ = currRayZ;
prevHeight = currHeight;
currTexOffset += deltaTex;
currRayZ -= layerHeight;
}
}
int sectionSteps = 2;
int sectionIndex = 0;
half newZ = 0;
half newHeight = 0;
while (sectionIndex < sectionSteps)
{
intersection = (prevHeight - prevRayZ) / (prevHeight - currHeight + currRayZ - prevRayZ);
finalTexOffset = prevTexOffset +intersection * deltaTex;
newZ = prevRayZ - intersection * layerHeight;
newHeight = SAMPLE_TEXTURE2D_GRAD(heightMap, heightSampler, uvs + finalTexOffset, dx, dy).r;
if (newHeight > newZ)
{
currTexOffset = finalTexOffset;
currHeight = newHeight;
currRayZ = newZ;
deltaTex = intersection * deltaTex;
layerHeight = intersection * layerHeight;
}
else
{
prevTexOffset = finalTexOffset;
prevHeight = newHeight;
prevRayZ = newZ;
deltaTex = (1 - intersection) * deltaTex;
layerHeight = (1 - intersection) * layerHeight;
}
sectionIndex++;
}
finalHeight = newHeight;
return uvs.xy + finalTexOffset;
}

half remap(half s, half a1, half a2, half b1, half b2)
{
return b1 + (s - a1) * (b2 - b1) / (a2 - a1);
}

half3 ApplyLut2D(Texture2D LUT2D, SamplerState lutSampler, half3 uvw)
{
half3 scaleOffset = half3(1.0 / 1024.0, 1.0 / 32.0, 31.0);
// Strip format where `height = sqrt(width)`
uvw.z *= scaleOffset.z;
half shift = floor(uvw.z);
uvw.xy = uvw.xy * scaleOffset.z * scaleOffset.xy + scaleOffset.xy * 0.5;
uvw.x += shift * scaleOffset.y;
uvw.xyz = lerp(
SAMPLE_TEXTURE2D(LUT2D, lutSampler, uvw.xy).rgb,
SAMPLE_TEXTURE2D(LUT2D, lutSampler, uvw.xy + half2(scaleOffset.y, 0.0)).rgb,
uvw.z - shift
);
return uvw;
}

half3 AdjustContrast(half3 color, half contrast)
{
color = saturate(lerp(half3(0.5, 0.5, 0.5), color, contrast));
return color;
}

half3 AdjustSaturation(half3 color, half saturation)
{
half3 intensity = dot(color.rgb, half3(0.299, 0.587, 0.114));
color = lerp(intensity, color.rgb, saturation);
return color;
}

half3 AdjustBrightness(half3 color, half brightness)
{
color += brightness;
return color;
}

struct ParamsLogC
{
half cut;
half a, b, c, d, e, f;
};

static const ParamsLogC LogC = {
0.011361, // cut
5.555556, // a
0.047996, // b
0.244161, // c
0.386036, // d
5.301883, // e
0.092819  // f

};

half LinearToLogC_Precise(half x)
{
half o;
if (x > LogC.cut)
o = LogC.c * log10(LogC.a * x + LogC.b) + LogC.d;
else
o = LogC.e * x + LogC.f;
return o;
}

half PositivePow(half base, half power)
{
return pow(max(abs(base), half(FLT_EPSILON)), power);
}

half3 LinearToLogC(half3 x)
{
return LogC.c * log10(LogC.a * x + LogC.b) + LogC.d;
}

half3 LinerToSRGB(half3 c)
{
return c * (c * (c * 0.305306011 + 0.682171111) + 0.012522878);
}

half3 SRGBToLiner(half3 c)
{
return max(1.055 * PositivePow(c, 0.416666667) - 0.055, 0.0);
}

half3 LogCToLinear(half3 c)
{
return (pow(10.0, (c - LogC.d) / LogC.c) - LogC.b) / LogC.a;
}

// Specular stuff taken from https://github.com/z3y/shaders/
float pow5(float x)
{
float x2 = x * x;
return x2 * x2 * x;
}

float sq(float x)
{
return x * x;
}

struct Gradient
{
int type;
int colorsLength;
int alphasLength;
half4 colors[8];
half2 alphas[8];
};

Gradient NewGradient(int type, int colorsLength, int alphasLength,
half4 colors0, half4 colors1, half4 colors2, half4 colors3, half4 colors4, half4 colors5, half4 colors6, half4 colors7,
half2 alphas0, half2 alphas1, half2 alphas2, half2 alphas3, half2 alphas4, half2 alphas5, half2 alphas6, half2 alphas7)
{
Gradient g;
g.type = type;
g.colorsLength = colorsLength;
g.alphasLength = alphasLength;
g.colors[ 0 ] = colors0;
g.colors[ 1 ] = colors1;
g.colors[ 2 ] = colors2;
g.colors[ 3 ] = colors3;
g.colors[ 4 ] = colors4;
g.colors[ 5 ] = colors5;
g.colors[ 6 ] = colors6;
g.colors[ 7 ] = colors7;
g.alphas[ 0 ] = alphas0;
g.alphas[ 1 ] = alphas1;
g.alphas[ 2 ] = alphas2;
g.alphas[ 3 ] = alphas3;
g.alphas[ 4 ] = alphas4;
g.alphas[ 5 ] = alphas5;
g.alphas[ 6 ] = alphas6;
g.alphas[ 7 ] = alphas7;
return g;
}

half4 SampleGradient(Gradient gradient, half time)
{
half3 color = gradient.colors[0].rgb;
UNITY_UNROLL
for (int c = 1; c < 8; c++)
{
half colorPos = saturate((time - gradient.colors[c - 1].w) / (0.00001 + (gradient.colors[c].w - gradient.colors[c - 1].w)) * step(c, (half)gradient.colorsLength - 1));
color = lerp(color, gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), gradient.type));
}
#ifndef UNITY_COLORSPACE_GAMMA
color = half3(GammaToLinearSpaceExact(color.r), GammaToLinearSpaceExact(color.g), GammaToLinearSpaceExact(color.b));
#endif
half alpha = gradient.alphas[0].x;
UNITY_UNROLL
for (int a = 1; a < 8; a++)
{
half alphaPos = saturate((time - gradient.alphas[a - 1].y) / (0.00001 + (gradient.alphas[a].y - gradient.alphas[a - 1].y)) * step(a, (half)gradient.alphasLength - 1));
alpha = lerp(alpha, gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), gradient.type));
}
return half4(color, alpha);
}

float3 RotateAroundAxis(float3 center, float3 original, float3 u, float angle)
{
original -= center;
float C = cos(angle);
float S = sin(angle);
float t = 1 - C;
float m00 = t * u.x * u.x + C;
float m01 = t * u.x * u.y - S * u.z;
float m02 = t * u.x * u.z + S * u.y;
float m10 = t * u.x * u.y + S * u.z;
float m11 = t * u.y * u.y + C;
float m12 = t * u.y * u.z - S * u.x;
float m20 = t * u.x * u.z - S * u.y;
float m21 = t * u.y * u.z + S * u.x;
float m22 = t * u.z * u.z + C;
float3x3 finalMatrix = float3x3(m00, m01, m02, m10, m11, m12, m20, m21, m22);
return mul(finalMatrix, original) + center;
}

// Map of where features in AudioLink are.
#define ALPASS_DFT                      uint2(0, 4)  //Size: 128, 2
#define ALPASS_WAVEFORM                 uint2(0, 6)  //Size: 128, 16
#define ALPASS_AUDIOLINK                uint2(0, 0)  //Size: 128, 4
#define ALPASS_AUDIOBASS                uint2(0, 0)  //Size: 128, 1
#define ALPASS_AUDIOLOWMIDS             uint2(0, 1)  //Size: 128, 1
#define ALPASS_AUDIOHIGHMIDS            uint2(0, 2)  //Size: 128, 1
#define ALPASS_AUDIOTREBLE              uint2(0, 3)  //Size: 128, 1
#define ALPASS_AUDIOLINKHISTORY         uint2(1, 0)  //Size: 127, 4
#define ALPASS_GENERALVU                uint2(0, 22) //Size: 12, 1
#define ALPASS_GENERALVU_INSTANCE_TIME  uint2(2, 22)
#define ALPASS_GENERALVU_LOCAL_TIME     uint2(3, 22)
#define ALPASS_GENERALVU_NETWORK_TIME   uint2(4, 22)
#define ALPASS_GENERALVU_PLAYERINFO     uint2(6, 22)
#define ALPASS_THEME_COLOR0             uint2(0, 23)
#define ALPASS_THEME_COLOR1             uint2(1, 23)
#define ALPASS_THEME_COLOR2             uint2(2, 23)
#define ALPASS_THEME_COLOR3             uint2(3, 23)
#define ALPASS_CCINTERNAL               uint2(12, 22) //Size: 12, 2
#define ALPASS_CCCOLORS                 uint2(25, 22) //Size: 12, 1 (Note Color #0 is always black, Colors start at 1)
#define ALPASS_CCSTRIP                  uint2(0, 24)  //Size: 128, 1
#define ALPASS_CCLIGHTS                 uint2(0, 25)  //Size: 128, 2
#define ALPASS_AUTOCORRELATOR           uint2(0, 27)  //Size: 128, 1
#define ALPASS_FILTEREDAUDIOLINK        uint2(0, 28)  //Size: 16, 4
#define ALPASS_CHRONOTENSITY            uint2(16, 28) //Size: 8, 4
#define ALPASS_FILTEREDVU               uint2(24, 28) //Size: 4, 4
#define ALPASS_FILTEREDVU_INTENSITY     uint2(24, 28) //Size: 4, 1
#define ALPASS_FILTEREDVU_MARKER        uint2(24, 29) //Size: 4, 1

// Some basic constants to use (Note, these should be compatible with
// future version of AudioLink, but may change.
#define AUDIOLINK_SAMPHIST              3069        // Internal use for algos, do not change.
#define AUDIOLINK_SAMPLEDATA24          2046
#define AUDIOLINK_EXPBINS               24
#define AUDIOLINK_EXPOCT                10
#define AUDIOLINK_ETOTALBINS (AUDIOLINK_EXPBINS * AUDIOLINK_EXPOCT)
#define AUDIOLINK_WIDTH                 128
#define AUDIOLINK_SPS                   48000       // Samples per second
#define AUDIOLINK_ROOTNOTE              0
#define AUDIOLINK_4BAND_FREQFLOOR       0.123
#define AUDIOLINK_4BAND_FREQCEILING     1
#define AUDIOLINK_BOTTOM_FREQUENCY      13.75
#define AUDIOLINK_BASE_AMPLITUDE        2.5
#define AUDIOLINK_DELAY_COEFFICIENT_MIN 0.3
#define AUDIOLINK_DELAY_COEFFICIENT_MAX 0.9
#define AUDIOLINK_DFT_Q                 4.0
#define AUDIOLINK_TREBLE_CORRECTION     5.0
#define AUDIOLINK_4BAND_TARGET_RATE     90.0

// ColorChord constants
#define COLORCHORD_EMAXBIN              192
#define COLORCHORD_NOTE_CLOSEST         3.0
#define COLORCHORD_NEW_NOTE_GAIN        8.0
#define COLORCHORD_MAX_NOTES            10

// We use glsl_mod for most calculations because it behaves better
// on negative numbers, and in some situations actually outperforms
// HLSL's modf().
#ifndef glsl_mod
#define glsl_mod(x, y) (((x) - (y) * floor((x) / (y))))
#endif

uniform float4               _AudioTexture_TexelSize;

#ifdef SHADER_TARGET_SURFACE_ANALYSIS
#define AUDIOLINK_STANDARD_INDEXING
#endif

// Mechanism to index into texture.
#ifdef AUDIOLINK_STANDARD_INDEXING
sampler2D _AudioTexture;
#define AudioLinkData(xycoord) tex2Dlod(_AudioTexture, float4(uint2(xycoord) * _AudioTexture_TexelSize.xy, 0, 0))
#else
uniform Texture2D<float4> _AudioTexture;
#define AudioLinkData(xycoord) _AudioTexture[uint2(xycoord)]
#endif

// Convenient mechanism to read from the AudioLink texture that handles reading off the end of one line and onto the next above it.
float4 AudioLinkDataMultiline(uint2 xycoord)
{
return AudioLinkData(uint2(xycoord.x % AUDIOLINK_WIDTH, xycoord.y + xycoord.x / AUDIOLINK_WIDTH));
}

// Mechanism to sample between two adjacent pixels and lerp between them, like "linear" supesampling
float4 AudioLinkLerp(float2 xy)
{
return lerp(AudioLinkData(xy), AudioLinkData(xy + int2(1, 0)), frac(xy.x));
}

// Same as AudioLinkLerp but properly handles multiline reading.
float4 AudioLinkLerpMultiline(float2 xy)
{
return lerp(AudioLinkDataMultiline(xy), AudioLinkDataMultiline(xy + float2(1, 0)), frac(xy.x));
}

//Tests to see if Audio Link texture is available
bool AudioLinkIsAvailable()
{
#if !defined(AUDIOLINK_STANDARD_INDEXING)
int width, height;
_AudioTexture.GetDimensions(width, height);
return width > 16;
#else
return _AudioTexture_TexelSize.z > 16;
#endif
}

//Get version of audiolink present in the world, 0 if no audiolink is present
float AudioLinkGetVersion()
{
int2 dims;
#if !defined(AUDIOLINK_STANDARD_INDEXING)
_AudioTexture.GetDimensions(dims.x, dims.y);
#else
dims = _AudioTexture_TexelSize.zw;
#endif

if (dims.x >= 128)
return AudioLinkData(ALPASS_GENERALVU).x;
else if (dims.x > 16)
return 1;
else
return 0;
}

// This pulls data from this texture.
#define AudioLinkGetSelfPixelData(xy) _SelfTexture2D[xy]

// Extra utility functions for time.
uint AudioLinkDecodeDataAsUInt(uint2 indexloc)
{
uint4 rpx = AudioLinkData(indexloc);
return rpx.r + rpx.g * 1024 + rpx.b * 1048576 + rpx.a * 1073741824;
}

//Note: This will truncate time to every 134,217.728 seconds (~1.5 days of an instance being up) to prevent floating point aliasing.
// if your code will alias sooner, you will need to use a different function.  It should be safe to use this on all times.
float AudioLinkDecodeDataAsSeconds(uint2 indexloc)
{
uint time = AudioLinkDecodeDataAsUInt(indexloc) & 0x7ffffff;
//Can't just divide by float.  Bug in Unity's HLSL compiler.
return float(time / 1000) + float(time % 1000) / 1000.;
}

#define ALDecodeDataAsSeconds(x) AudioLinkDecodeDataAsSeconds(x)
#define ALDecodeDataAsUInt(x) AudioLinkDecodeDataAsUInt(x)

float AudioLinkRemap(float t, float a, float b, float u, float v)
{
return ((t - a) / (b - a)) * (v - u) + u;
}

float3 AudioLinkHSVtoRGB(float3 HSV)
{
float3 RGB = 0;
float C = HSV.z * HSV.y;
float H = HSV.x * 6;
float X = C * (1 - abs(fmod(H, 2) - 1));
if (HSV.y != 0)
{
float I = floor(H);
if (I == 0)
{
RGB = float3(C, X, 0);
}
else if (I == 1)
{
RGB = float3(X, C, 0);
}
else if (I == 2)
{
RGB = float3(0, C, X);
}
else if (I == 3)
{
RGB = float3(0, X, C);
}
else if (I == 4)
{
RGB = float3(X, 0, C);
}
else
{
RGB = float3(C, 0, X);
}
}
float M = HSV.z - C;
return RGB + M;
}

float3 AudioLinkCCtoRGB(float bin, float intensity, int rootNote)
{
float note = bin / AUDIOLINK_EXPBINS;

float hue = 0.0;
note *= 12.0;
note = glsl_mod(4. - note + rootNote, 12.0);
{
if (note < 4.0)
{
//Needs to be YELLOW->RED
hue = (note) / 24.0;
}
else if (note < 8.0)
{
//            [4]  [8]
//Needs to be RED->BLUE
hue = (note - 2.0) / 12.0;
}
else
{
//             [8] [12]
//Needs to be BLUE->YELLOW
hue = (note - 4.0) / 8.0;
}
}
float val = intensity - 0.1;
return AudioLinkHSVtoRGB(float3(fmod(hue, 1.0), 1.0, clamp(val, 0.0, 1.0)));
}

// Sample the amplitude of a given frequency in the DFT, supports frequencies in [13.75; 14080].
float4 AudioLinkGetAmplitudeAtFrequency(float hertz)
{
float note = AUDIOLINK_EXPBINS * log2(hertz / AUDIOLINK_BOTTOM_FREQUENCY);
return AudioLinkLerpMultiline(ALPASS_DFT + float2(note, 0));
}

// Sample the amplitude of a given semitone in an octave. Octave is in [0; 9] while note is [0; 11].
float AudioLinkGetAmplitudeAtNote(float octave, float note)
{
float quarter = note * 2.0;
return AudioLinkLerpMultiline(ALPASS_DFT + float2(octave * AUDIOLINK_EXPBINS + quarter, 0));
}

// Get a reasonable drop-in replacement time value for _Time.y with the
// given chronotensity index [0; 7] and AudioLink band [0; 3].
float AudioLinkGetChronoTime(uint index, uint band)
{
return (AudioLinkDecodeDataAsUInt(ALPASS_CHRONOTENSITY + uint2(index, band))) / 100000.0;
}

// Get a chronotensity value in the interval [0; 1], modulated by the speed input,
// with the given chronotensity index [0; 7] and AudioLink band [0; 3].
float AudioLinkGetChronoTimeNormalized(uint index, uint band, float speed)
{
return frac(AudioLinkGetChronoTime(index, band) * speed);
}

// Get a chronotensity value in the interval [0; interval], modulated by the speed input,
// with the given chronotensity index [0; 7] and AudioLink band [0; 3].
float AudioLinkGetChronoTimeInterval(uint index, uint band, float speed, float interval)
{
return AudioLinkGetChronoTimeNormalized(index, band, speed) * interval;
}
half D_GGX(half NoH, half roughness)
{
half a = NoH * roughness;
half k = roughness / (1.0 - NoH * NoH + a * a);
return k * k * (1.0 / UNITY_PI);
}

half D_GGX_Anisotropic(half NoH, const half3 h, const half3 t, const half3 b, half at, half ab)
{
half ToH = dot(t, h);
half BoH = dot(b, h);
half a2 = at * ab;
half3 v = half3(ab * ToH, at * BoH, a2 * NoH);
half v2 = dot(v, v);
half w2 = a2 / v2;
return a2 * w2 * w2 * (1.0 / UNITY_PI);
}

half V_SmithGGXCorrelated(half NoV, half NoL, half roughness)
{
half a2 = roughness * roughness;
half GGXV = NoL * sqrt(NoV * NoV * (1.0 - a2) + a2);
half GGXL = NoV * sqrt(NoL * NoL * (1.0 - a2) + a2);
return 0.5 / (GGXV + GGXL);
}

half3 F_Schlick(half u, half3 f0)
{
return f0 + (1.0 - f0) * pow(1.0 - u, 5.0);
}

half3 F_Schlick(half3 f0, half f90, half VoH)
{
// Schlick 1994, "An Inexpensive BRDF Model for Physically-Based Rendering"
return f0 + (f90 - f0) * pow(1.0 - VoH, 5);
}

half3 fresnel(half3 f0, half LoH)
{
half f90 = saturate(dot(f0, half(50.0 / 3).xxx));
return F_Schlick(f0, f90, LoH);
}

half Fd_Burley(half perceptualRoughness, half NoV, half NoL, half LoH)
{
// Burley 2012, "Physically-Based Shading at Disney"
half f90 = 0.5 + 2.0 * perceptualRoughness * LoH * LoH;
half lightScatter = F_Schlick(1.0, f90, NoL);
half viewScatter = F_Schlick(1.0, f90, NoV);
return lightScatter * viewScatter;
}

half3 getBoxProjection(half3 direction, half3 position, half4 cubemapPosition, half3 boxMin, half3 boxMax)
{
#if defined(UNITY_SPECCUBE_BOX_PROJECTION) && !defined(UNITY_PBS_USE_BRDF2) || defined(FORCE_BOX_PROJECTION)
if (cubemapPosition.w > 0)
{
half3 factors = ((direction > 0 ? boxMax : boxMin) - position) / direction;
half scalar = min(min(factors.x, factors.y), factors.z);
direction = direction * scalar + (position - cubemapPosition.xyz);
}
#endif

return direction;
}

half3 getEnvReflection(half3 worldSpaceViewDir, half3 worldSpacePosition, half3 normal, half smoothness, int mip)
{
half3 env = 0;
half3 reflDir = reflect(worldSpaceViewDir, normal);
half perceptualRoughness = 1 - smoothness;
half rough = perceptualRoughness * perceptualRoughness;
reflDir = lerp(reflDir, normal, rough * rough);

half3 reflectionUV1 = getBoxProjection(reflDir, worldSpacePosition, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin.xyz, unity_SpecCube0_BoxMax.xyz);
half4 probe0 = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectionUV1, mip);
half3 probe0sample = DecodeHDR(probe0, unity_SpecCube0_HDR);

half3 indirectSpecular;
half interpolator = unity_SpecCube0_BoxMin.w;

UNITY_BRANCH
if (interpolator < 0.99999)
{
half3 reflectionUV2 = getBoxProjection(reflDir, worldSpacePosition, unity_SpecCube1_ProbePosition, unity_SpecCube1_BoxMin.xyz, unity_SpecCube1_BoxMax.xyz);
half4 probe1 = UNITY_SAMPLE_TEXCUBE_SAMPLER_LOD(unity_SpecCube1, unity_SpecCube0, reflectionUV2, mip);
half3 probe1sample = DecodeHDR(probe1, unity_SpecCube1_HDR);
indirectSpecular = lerp(probe1sample, probe0sample, interpolator);
}
else
{
indirectSpecular = probe0sample;
}

env = indirectSpecular;
return env;
}

half3 EnvBRDFMultiscatter(half2 dfg, half3 f0)
{
return lerp(dfg.xxx, dfg.yyy, f0);
}

half3 EnvBRDFApprox(half perceptualRoughness, half NoV, half3 f0)
{
half g = 1 - perceptualRoughness;
//https://blog.selfshadow.com/publications/s2013-shading-course/lazarov/s2013_pbs_black_ops_2_notes.pdf
half4 t = half4(1 / 0.96, 0.475, (0.0275 - 0.25 * 0.04) / 0.96, 0.25);
t *= half4(g, g, g, g);
t += half4(0, 0, (0.015 - 0.75 * 0.04) / 0.96, 0.75);
half a0 = t.x * min(t.y, exp2(-9.28 * NoV)) + t.z;
half a1 = t.w;
return saturate(lerp(a0, a1, f0));
}

half GSAA_Filament(half3 worldNormal, half perceptualRoughness, half inputVariance, half threshold)
{
// Kaplanyan 2016, "Stable specular highlights"
// Tokuyoshi 2017, "Error Reduction and Simplification for Shading Anti-Aliasing"
// Tokuyoshi and Kaplanyan 2019, "Improved Geometric Specular Antialiasing"

// This implementation is meant for deferred rendering in the original paper but
// we use it in forward rendering as well (as discussed in Tokuyoshi and Kaplanyan
// 2019). The main reason is that the forward version requires an expensive transform
// of the half vector by the tangent frame for every light. This is therefore an
// approximation but it works well enough for our needs and provides an improvement
// over our original implementation based on Vlachos 2015, "Advanced VR Rendering".

half3 du = ddx(worldNormal);
half3 dv = ddy(worldNormal);

half variance = inputVariance * (dot(du, du) + dot(dv, dv));

half roughness = perceptualRoughness * perceptualRoughness;
half kernelRoughness = min(2.0 * variance, threshold);
half squareRoughness = saturate(roughness * roughness + kernelRoughness);

return sqrt(sqrt(squareRoughness));
}

// w0, w1, w2, and w3 are the four cubic B-spline basis functions
half w0(half a)
{
//    return (1.0f/6.0f)*(-a*a*a + 3.0f*a*a - 3.0f*a + 1.0f);
return (1.0f / 6.0f) * (a * (a * (-a + 3.0f) - 3.0f) + 1.0f);   // optimized

}

half w1(half a)
{
//    return (1.0f/6.0f)*(3.0f*a*a*a - 6.0f*a*a + 4.0f);
return (1.0f / 6.0f) * (a * a * (3.0f * a - 6.0f) + 4.0f);
}

half w2(half a)
{
//    return (1.0f/6.0f)*(-3.0f*a*a*a + 3.0f*a*a + 3.0f*a + 1.0f);
return (1.0f / 6.0f) * (a * (a * (-3.0f * a + 3.0f) + 3.0f) + 1.0f);
}

half w3(half a)
{
return (1.0f / 6.0f) * (a * a * a);
}

// g0 and g1 are the two amplitude functions
half g0(half a)
{
return w0(a) + w1(a);
}

half g1(half a)
{
return w2(a) + w3(a);
}

// h0 and h1 are the two offset functions
half h0(half a)
{
// note +0.5 offset to compensate for CUDA linear filtering convention
return -1.0f + w1(a) / (w0(a) + w1(a)) + 0.5f;
}

half h1(half a)
{
return 1.0f + w3(a) / (w2(a) + w3(a)) + 0.5f;
}

//https://ndotl.wordpress.com/2018/08/29/baking-artifact-free-lightmaps
half3 tex2DFastBicubicLightmap(half2 uv, inout half4 bakedColorTex)
{
#if !defined(PLAT_QUEST) && defined(BICUBIC_LIGHTMAP)
half width;
half height;
unity_Lightmap.GetDimensions(width, height);
half x = uv.x * width;
half y = uv.y * height;

x -= 0.5f;
y -= 0.5f;
half px = floor(x);
half py = floor(y);
half fx = x - px;
half fy = y - py;

// note: we could store these functions in a lookup table texture, but maths is cheap
half g0x = g0(fx);
half g1x = g1(fx);
half h0x = h0(fx);
half h1x = h1(fx);
half h0y = h0(fy);
half h1y = h1(fy);

half4 r = g0(fy) * (g0x * UNITY_SAMPLE_TEX2D(unity_Lightmap, (half2(px + h0x, py + h0y) * 1.0f / width)) +
g1x * UNITY_SAMPLE_TEX2D(unity_Lightmap, (half2(px + h1x, py + h0y) * 1.0f / width))) +
g1(fy) * (g0x * UNITY_SAMPLE_TEX2D(unity_Lightmap, (half2(px + h0x, py + h1y) * 1.0f / width)) +
g1x * UNITY_SAMPLE_TEX2D(unity_Lightmap, (half2(px + h1x, py + h1y) * 1.0f / width)));
bakedColorTex = r;
return DecodeLightmap(r);
#else
bakedColorTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, uv);
return DecodeLightmap(bakedColorTex);
#endif
}

half3 GetSpecularHighlights(half3 worldNormal, half3 lightColor, half3 lightDirection, half3 f0, half3 viewDir, half clampedRoughness, half NoV, half3 energyCompensation)
{
half3 halfVector = Unity_SafeNormalize(lightDirection + viewDir);

half NoH = saturate(dot(worldNormal, halfVector));
half NoL = saturate(dot(worldNormal, lightDirection));
half LoH = saturate(dot(lightDirection, halfVector));

half3 F = F_Schlick(LoH, f0);
half D = D_GGX(NoH, clampedRoughness);
half V = V_SmithGGXCorrelated(NoV, NoL, clampedRoughness);

#ifndef UNITY_PBS_USE_BRDF2
F *= energyCompensation;
#endif

return max(0, (D * V) * F) * lightColor * NoL * UNITY_PI;
}

#ifdef DYNAMICLIGHTMAP_ON
half3 getRealtimeLightmap(half2 uv, half3 worldNormal)
{
half2 realtimeUV = uv;
half4 bakedCol = UNITY_SAMPLE_TEX2D(unity_DynamicLightmap, realtimeUV);
half3 realtimeLightmap = DecodeRealtimeLightmap(bakedCol);

#ifdef DIRLIGHTMAP_COMBINED
half4 realtimeDirTex = UNITY_SAMPLE_TEX2D_SAMPLER(unity_DynamicDirectionality, unity_DynamicLightmap, realtimeUV);
realtimeLightmap += DecodeDirectionalLightmap(realtimeLightmap, realtimeDirTex, worldNormal);
#endif

return realtimeLightmap;
}
#endif

half computeSpecularAO(half NoV, half ao, half roughness)
{
return clamp(pow(NoV + ao, exp2(-16.0 * roughness - 1.0)) - 1.0 + ao, 0.0, 1.0);
}

half shEvaluateDiffuseL1Geomerics_local(half L0, half3 L1, half3 n)
{
// average energy
half R0 = L0;

// avg direction of incoming light
half3 R1 = 0.5f * L1;

// directional brightness
half lenR1 = length(R1);

// linear angle between normal and direction 0-1
//half q = 0.5f * (1.0f + dot(R1 / lenR1, n));
//half q = dot(R1 / lenR1, n) * 0.5 + 0.5;
half q = dot(normalize(R1), n) * 0.5 + 0.5;
q = saturate(q); // Thanks to ScruffyRuffles for the bug identity.

// power for q
// lerps from 1 (linear) to 3 (cubic) based on directionality
half p = 1.0f + 2.0f * lenR1 / R0;

// dynamic range constant
// should vary between 4 (highly directional) and 0 (ambient)
half a = (1.0f - lenR1 / R0) / (1.0f + lenR1 / R0);

return R0 * (a + (1.0f - a) * (p + 1.0f) * pow(q, p));
}

TEXTURE2D(_Ramp);
SAMPLER(sampler_Ramp);
TEXTURECUBE(_BakedCubemap);
SAMPLER(sampler_BakedCubemap);

half3 getReflectionUV(half3 direction, half3 position, half4 cubemapPosition, half3 boxMin, half3 boxMax)
{
#if UNITY_SPECCUBE_BOX_PROJECTION
if (cubemapPosition.w > 0) {
half3 factors = ((direction > 0 ? boxMax : boxMin) - position) / direction;
half scalar = min(min(factors.x, factors.y), factors.z);
direction = direction * scalar + (position - cubemapPosition);
}
#endif
return direction;
}

half3 calcReflView(half3 viewDir, half3 normal)
{
return reflect(-viewDir, normal);
}

half3 calcStereoViewDir(half3 worldPos)
{
#if UNITY_SINGLE_PASS_STEREO
half3 cameraPos = half3((unity_StereoWorldSpaceCameraPos[0]+ unity_StereoWorldSpaceCameraPos[1])*.5);
#else
half3 cameraPos = _WorldSpaceCameraPos;
#endif
half3 viewDir = cameraPos - worldPos;
return normalize(viewDir);
}

half4 calcRamp(half NdL, half attenuation, half occlusion, int occlusionMode)
{
half remapRamp;
remapRamp = NdL * 0.5 + 0.5;
remapRamp *= lerp(1, occlusion, occlusionMode);
#if defined(UNITY_PASS_FORWARDBASE)
remapRamp *= attenuation;
#endif
half4 ramp = SAMPLE_TEXTURE2D(_Ramp, sampler_Ramp, half2(remapRamp, 0));
return ramp;
}

half4 calcDiffuse(half attenuation, half3 albedo, half3 indirectDiffuse, half3 lightCol, half4 ramp)
{
half4 diffuse;
half4 indirect = indirectDiffuse.xyzz;

half grayIndirect = dot(indirectDiffuse, float3(1,1,1));
half attenFactor = lerp(attenuation, 1, smoothstep(0, 0.2, grayIndirect));

diffuse = ramp * attenFactor * half4(lightCol, 1) + indirect;
diffuse = albedo.xyzz * diffuse;
return diffuse;
}

half2 calcMatcapUV(half3 worldUp, half3 viewDirection, half3 normalDirection)
{
half3 worldViewUp = normalize(worldUp - viewDirection * dot(viewDirection, worldUp));
half3 worldViewRight = normalize(cross(viewDirection, worldViewUp));
half2 matcapUV = half2(dot(worldViewRight, normalDirection), dot(worldViewUp, normalDirection)) * 0.5 + 0.5;
return matcapUV;
}

half3 calcIndirectSpecular(half lightAttenuation, MeshData d, SurfaceData o, half roughness, half3 reflDir, half3 indirectLight, float3 fresnel, half4 ramp)
{//This function handls Unity style reflections, Matcaps, and a baked in fallback cubemap.
half3 spec = half3(0,0,0);

UNITY_BRANCH
if (!o.EnableReflections) {
spec = 0;
} else if(any(o.BakedReflection.rgb)) {
spec = o.BakedReflection;
if(o.ReflectionBlendMode != 1)
{
spec *= (indirectLight + (_LightColor0 * lightAttenuation) * 0.5);
}
} else
{
#if defined(UNITY_PASS_FORWARDBASE) //Indirect PBR specular should only happen in the forward base pass. Otherwise each extra light adds another indirect sample, which could mean you're getting too much light.
half3 reflectionUV1 = getReflectionUV(reflDir, d.worldSpacePosition, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax);
half4 probe0 = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectionUV1, roughness * UNITY_SPECCUBE_LOD_STEPS);
half3 probe0sample = DecodeHDR(probe0, unity_SpecCube0_HDR);

half3 indirectSpecular;
half interpolator = unity_SpecCube0_BoxMin.w;

UNITY_BRANCH
if (interpolator < 0.99999)
{
half3 reflectionUV2 = getReflectionUV(reflDir, d.worldSpacePosition, unity_SpecCube1_ProbePosition, unity_SpecCube1_BoxMin, unity_SpecCube1_BoxMax);
half4 probe1 = UNITY_SAMPLE_TEXCUBE_SAMPLER_LOD(unity_SpecCube1, unity_SpecCube0, reflectionUV2, roughness * UNITY_SPECCUBE_LOD_STEPS);
half3 probe1sample = DecodeHDR(probe1, unity_SpecCube1_HDR);
indirectSpecular = lerp(probe1sample, probe0sample, interpolator);
}
else
{
indirectSpecular = probe0sample;
}

if (!any(indirectSpecular))
{
indirectSpecular = SAMPLE_TEXTURECUBE_LOD(_BakedCubemap, sampler_BakedCubemap, reflDir, roughness * UNITY_SPECCUBE_LOD_STEPS);
indirectSpecular *= indirectLight;
}
spec = indirectSpecular * fresnel;
#endif
}
// else if(_ReflectionMode == 1) //Baked Cubemap
// {
//     half3 indirectSpecular = SAMPLE_TEXTURECUBE_LOD(_BakedCubemap, sampler_BakedCubemap, reflDir, roughness * UNITY_SPECCUBE_LOD_STEPS);
//     spec = indirectSpecular * fresnel;

//     if(_ReflectionBlendMode != 1)
//     {
//         spec *= (indirectLight + (_LightColor0 * lightAttenuation) * 0.5);
//     }
// }
// else if (_ReflectionMode == 2) //Matcap
// {
//     half3 upVector = half3(0,1,0);
//     half2 remapUV = calcMatcapUV(upVector, d.worldSpaceViewDir, o.Normal);
//     spec = SAMPLE_TEXTURE2D_LOD(_Matcap, remapUV, (1-roughness) * UNITY_SPECCUBE_LOD_STEPS) * _MatcapTint;

//     if(_ReflectionBlendMode != 1)
//     {
//         spec *= (indirectLight + (_LightColor0 * lightAttenuation) * 0.5);
//     }

//     spec *= lerp(1, o.Albedo, _MatcapTintToDiffuse);
// }
return spec;
}

half3 calcDirectSpecular(MeshData d, SurfaceData o, float lightNoL, float NoH, float NoV, float lightLoH, half3 lightColor, half3 lightHalfVector, half anisotropy)
{
half specularIntensity = o.SpecularIntensity;
half3 specular = half3(0,0,0);
half smoothness = max(0.01, (o.SpecularArea));
smoothness *= 1.7 - 0.7 * smoothness;

float rough = max(smoothness * smoothness, 0.0045);
float Dn = D_GGX(NoH, rough);
float3 F = 1-F_Schlick(lightLoH, 0);
float V = V_SmithGGXCorrelated(NoV, lightNoL, rough);
float3 directSpecularNonAniso = max(0, (Dn * V) * F);

anisotropy *= saturate(5.0 * smoothness);
float at = max(rough * (1.0 + anisotropy), 0.001);
float ab = max(rough * (1.0 - anisotropy), 0.001);
float D = D_GGX_Anisotropic(NoH, lightHalfVector, d.worldSpaceTangent, d.bitangent, at, ab);
float3 directSpecularAniso = max(0, (D * V) * F);

specular = lerp(directSpecularNonAniso, directSpecularAniso, saturate(abs(anisotropy * 100)));
specular = lerp(specular, smoothstep(0.5, 0.51, specular), o.SpecularSharpness) * 3 * lightColor.xyz * specularIntensity; // Multiply by 3 to bring up to brightness of standard
specular *= lerp(1, o.Albedo, o.SpecularAlbedoTint);
return specular;
}

half4 calcReflectionBlending(SurfaceData o, half reflectivity, half4 col, half3 indirectSpecular)
{
if (o.ReflectionBlendMode == 0) { // Additive
col += indirectSpecular.xyzz * reflectivity;
return col;
} else if (o.ReflectionBlendMode == 1) { //Multiplicitive
col = lerp(col, col * indirectSpecular.xyzz, reflectivity);
return col;
} else if(o.ReflectionBlendMode == 2) { //Subtractive
col -= indirectSpecular.xyzz * reflectivity;
return col;
}
return col;
}

half4 calcEmission(SurfaceData o, half lightAvg)
{
#if defined(UNITY_PASS_FORWARDBASE) // Emission only in Base Pass, and vertex lights
float4 emission = 0;
emission = half4(o.Emission, 1);

float4 scaledEmission = emission * saturate(smoothstep(1 - o.EmissionLightThreshold, 1 + o.EmissionLightThreshold, 1 - lightAvg));
float4 em = lerp(scaledEmission, emission, o.EmissionScaleWithLight);

// em.rgb = rgb2hsv(em.rgb);
// em.x += fmod(_Hue, 360);
// em.y = saturate(em.y * _Saturation);
// em.z *= _Value;
// em.rgb = hsv2rgb(em.rgb);

return em;
#else
return 0;
#endif
}

#if defined(NEED_DEPTH)
UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
#endif

half _ShadowSharpness;
half _OcclusionStrength;
half _BumpScale;
half _DetailNormalScale;
half _FlipDetailNormalY;
half _OutlineAlbedoTint;
half _OutlineWidth;
half _SpecularIntensity;
half _SpecularRoughness;
half _SpecularSharpness;
half _SpecularAnisotropy;
half _SpecularAlbedoTint;
half _Smoothness;
half _Metallic;
half _ReflectionAnisotropy;
half _MatcapBlur;
half _MatcapTintToDiffuse;
half _ReflectivityLevel;
half _EmissionTintToDiffuse;
half _EmissionScaleWithLightSensitivity;
half _RimIntensity;
half _RimAlbedoTint;
half _RimEnvironmentTint;
half _RimAttenuation;
half _RimRange;
half _RimThreshold;
half _RimSharpness;
half _ShadowRimRange;
half _ShadowRimThreshold;
half _ShadowRimSharpness;
half _ShadowRimAlbedoTint;
half2 GLOBAL_uv;
half3 GLOBAL_pixelNormal;
half4 _Color;
half4 _DetailNormalMap_ST;
half4 _OutlineColor;
half4 _MetallicRemap;
half4 _SmoothnessRemap;
half4 _MetallicGlossMap_TexelSize;
half4 _ALEmissionColor;
half4 _ALPackedRedColor;
half4 _ALPackedGreenColor;
half4 _ALPackedBlueColor;
half4 _EmissionColor;
half4 _RimTint;
half4 _ShadowRimTint;
float4 _MainTex_ST;
int _TintByVertexColor;
TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);
int _OcclusionMode;
TEXTURE2D(_OcclusionMap);
int _FlipBumpY;
int _DetailNormalsUVSet;
int _DetailNormalUVSet;
TEXTURE2D(_BumpMap);
SAMPLER(sampler_BumpMap);
TEXTURE2D(_DetailNormalMap);
SAMPLER(sampler_DetailNormalMap);
TEXTURE2D(_DetailNormalsMask);
SAMPLER(sampler_DetailNormalsMask);
int _OutlineLightingMode;
TEXTURE2D(_OutlineMask);
SAMPLER(sampler_OutlineMask);
int _SpecularMapUVSet;
TEXTURE2D(_SpecularMap);
int _ReflectionMode;
int _ReflectionBlendMode;
int _RoughnessMode;
TEXTURE2D(_Matcap);
SAMPLER(sampler_Matcap);
TEXTURE2D(_MetallicGlossMap);
TEXTURE2D(_ReflectivityMask);
int _ALMode;
int _ALBand;
int _ALGradientOnRed;
int _ALGradientOnGreen;
int _ALGradientOnBlue;
int _ALUVWidth;
int _ALMapUVSet;
TEXTURE2D(_ALMap);
SAMPLER(sampler_ALMap);
int _EmissionScaleWithLight;
TEXTURE2D(_EmissionMap);

void ToonOutlineVertex() {
#if defined(PASS_OUTLINE)
half mask = SAMPLE_TEXTURE2D_LOD(_OutlineMask, sampler_OutlineMask, vD.uv0, 0);
half3 width = mask * _OutlineWidth * .01;
width *= min(distance(mul(unity_ObjectToWorld, vD.vertex), _WorldSpaceCameraPos) * 3, 1);
vD.vertex.xyz += vD.normal.xyz * width;
#endif
}

void ToonFragment() {
half2 uv = d.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
GLOBAL_uv = uv;
half3 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, GLOBAL_uv).rgb;
albedo *= _Color;
if (_TintByVertexColor) {
albedo *= d.vertexColor.rgb;
}
o.Albedo = albedo;
o.ShadowSharpness = _ShadowSharpness;
}

void ToonOcclusionFragment() {
half occlusion = SAMPLE_TEXTURE2D(_OcclusionMap, sampler_MainTex, GLOBAL_uv).r;
o.Occlusion = lerp(1, occlusion, _OcclusionStrength);
o.OcclusionMode = _OcclusionMode;
}

void ToonNormalsFragment() {
half4 normalTex = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, GLOBAL_uv);
if (_FlipBumpY)
{
normalTex.y = 1 - normalTex.y;
}
half3 normal = UnpackScaleNormal(normalTex, _BumpScale);

o.Normal = BlendNormals(o.Normal, normal);

half2 detailUV = 0;
switch (_DetailNormalsUVSet) {
case 0: detailUV = d.uv0; break;
case 1: detailUV = d.uv1; break;
case 2: detailUV = d.uv2; break;
case 3: detailUV = d.uv3; break;
}
detailUV = detailUV * _DetailNormalMap_ST.xy + _DetailNormalMap_ST.zw;
half4 detailNormalTex = SAMPLE_TEXTURE2D(_DetailNormalMap, sampler_DetailNormalMap, detailUV);
if (_FlipDetailNormalY)
{
detailNormalTex.y = 1 - detailNormalTex.y;
}

half2 detailMaskUV = 0;
switch (_DetailNormalUVSet) {
case 0: detailMaskUV = d.uv0; break;
case 1: detailMaskUV = d.uv1; break;
case 2: detailMaskUV = d.uv2; break;
case 3: detailMaskUV = d.uv3; break;
}
half detailMask = SAMPLE_TEXTURE2D(_DetailNormalsMask, sampler_MainTex, GLOBAL_uv).r;

half3 detailNormal = UnpackScaleNormal(detailNormalTex, _DetailNormalScale);

o.Normal = lerp(o.Normal, BlendNormals(o.Normal, detailNormal), detailMask);

half3 properNormal = normalize(o.Normal.x * d.worldSpaceTangent.xyz + o.Normal.y * d.bitangent.xyz + o.Normal.z * d.worldNormal.xyz);
d.worldSpaceTangent.xyz = cross(d.bitangent.xyz, properNormal);
d.bitangent.xyz = cross(properNormal, d.worldSpaceTangent.xyz);
d.TBNMatrix = float3x3(normalize(d.worldSpaceTangent.xyz), d.bitangent, d.worldNormal);
GLOBAL_pixelNormal = properNormal;
}

void ToonOutlineFragment() {
o.OutlineColor = lerp(_OutlineColor, _OutlineColor * o.Albedo, _OutlineAlbedoTint);
o.OutlineLightingMode = _OutlineLightingMode;
}

void ToonSpecularFragment() {
half2 maskUV = 0;
switch (_DetailNormalsUVSet) {
case 0: maskUV = d.uv0; break;
case 1: maskUV = d.uv1; break;
case 2: maskUV = d.uv2; break;
case 3: maskUV = d.uv3; break;
}

half3 specMap = SAMPLE_TEXTURE2D(_SpecularMap, sampler_MainTex, maskUV);
o.SpecularIntensity = _SpecularIntensity * specMap.r;
o.SpecularArea = max(0.01, _SpecularRoughness * specMap.b);
o.SpecularAnisotropy = _SpecularAnisotropy;
o.SpecularAlbedoTint = _SpecularAlbedoTint * specMap.g;
o.SpecularSharpness = _SpecularSharpness;
}

void ToonReflectionFragment() {
o.EnableReflections = _ReflectionMode != 3;
o.ReflectionBlendMode = _ReflectionBlendMode;

half mask = SAMPLE_TEXTURE2D(_ReflectivityMask, sampler_MainTex, GLOBAL_uv).r;
mask *= _ReflectivityLevel;

UNITY_BRANCH
if (_ReflectionMode == 0) {
half4 metalSmooth = SAMPLE_TEXTURE2D(_MetallicGlossMap, sampler_MainTex, GLOBAL_uv);
int hasMetallicSmooth = _MetallicGlossMap_TexelSize.z > 8;
half metal = metalSmooth.r;
half smooth = metalSmooth.a;
if (_RoughnessMode)
{
smooth = 1 - smooth;
}
metal = remap(metal, 0, 1, _MetallicRemap.x, _MetallicRemap.y);
smooth = remap(smooth, 0, 1, _SmoothnessRemap.x, _SmoothnessRemap.y);
o.Metallic = lerp(_Metallic, metal, hasMetallicSmooth);
o.Smoothness = lerp(_Smoothness, smooth, hasMetallicSmooth);
o.Anisotropy = _ReflectionAnisotropy;
}
UNITY_BRANCH
if (_ReflectionMode == 2) {
half3 upVector = half3(0,1,0);
half2 remapUV = calcMatcapUV(upVector, d.worldSpaceViewDir, GLOBAL_pixelNormal);
half4 spec = 0;
spec = SAMPLE_TEXTURE2D_LOD(_Matcap, sampler_Matcap, remapUV, _MatcapBlur * UNITY_SPECCUBE_LOD_STEPS);

spec.rgb *= lerp(1, o.Albedo, _MatcapTintToDiffuse);
o.BakedReflection = spec.rgb;
}
o.Reflectivity = mask;
}

void ToonALFragment() {
if(AudioLinkIsAvailable() && _ALMode != 0) {
half2 alUV = 0;
switch (_ALMapUVSet) {
case 0: alUV = GLOBAL_uv; break;
case 1: alUV = d.uv1; break;
case 2: alUV = d.uv2; break;
case 3: alUV = d.uv3; break;
}
half4 alMask = SAMPLE_TEXTURE2D(_ALMap, sampler_ALMap, alUV);
if (_ALMode == 2) {
half audioDataBass = AudioLinkData(ALPASS_AUDIOBASS).x;
half audioDataMids = AudioLinkData(ALPASS_AUDIOLOWMIDS).x;
half audioDataHighs = (AudioLinkData(ALPASS_AUDIOHIGHMIDS).x + AudioLinkData(ALPASS_AUDIOTREBLE).x) * 0.5;

half tLow = smoothstep((1-audioDataBass), (1-audioDataBass) + 0.01, alMask.r) * alMask.a;
half tMid = smoothstep((1-audioDataMids), (1-audioDataMids) + 0.01, alMask.g) * alMask.a;
half tHigh = smoothstep((1-audioDataHighs), (1-audioDataHighs) + 0.01, alMask.b) * alMask.a;

half4 emissionChannelRed = lerp(alMask.r, tLow, _ALGradientOnRed) * _ALPackedRedColor * audioDataBass;
half4 emissionChannelGreen = lerp(alMask.g, tMid, _ALGradientOnGreen) * _ALPackedGreenColor * audioDataMids;
half4 emissionChannelBlue = lerp(alMask.b, tHigh, _ALGradientOnBlue) * _ALPackedBlueColor * audioDataHighs;
o.Emission += emissionChannelRed.rgb + emissionChannelGreen.rgb + emissionChannelBlue.rgb;
} else {
int2 aluv;
if (_ALMode == 1) {
aluv = int2(0, _ALBand);
} else {
aluv = int2(GLOBAL_uv.x * _ALUVWidth, GLOBAL_uv.y);
}
half sampledAL = AudioLinkData(aluv).x;
o.Emission +=  alMask.rgb * _ALEmissionColor.rgb * sampledAL;
}
}
}

void ToonEmissionFragment() {
half3 emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_MainTex, GLOBAL_uv).rgb;
emission *= lerp(emission, emission * o.Albedo, _EmissionTintToDiffuse) * _EmissionColor;
o.Emission += emission;
o.EmissionScaleWithLight = _EmissionScaleWithLight;
o.EmissionLightThreshold = _EmissionScaleWithLightSensitivity;
}

void ToonRimLightFragment() {
#ifndef USING_DIRECTIONAL_LIGHT
fixed3 lightDir = normalize(UnityWorldSpaceLightDir(d.worldSpacePosition));
#else
fixed3 lightDir = _WorldSpaceLightPos0.xyz;
#endif
half lightNoL = saturate(dot(GLOBAL_pixelNormal, lightDir));
half SVDNoN = abs(dot(d.svdn, GLOBAL_pixelNormal));

half rimIntensity = saturate((1 - SVDNoN)) * pow(lightNoL, _RimThreshold);
rimIntensity = smoothstep(_RimRange - _RimSharpness, _RimRange + _RimSharpness, rimIntensity);
half4 rim = rimIntensity * _RimIntensity;

half3 env = 0;
#if defined(UNITY_PASS_FORWARDBASE)
env = getEnvReflection(d.worldSpaceViewDir.xyz, d.worldSpacePosition.xyz, GLOBAL_pixelNormal, o.Smoothness, 5);
#endif

o.RimLight = rim * _RimTint * lerp(1, o.Albedo.rgbb, _RimAlbedoTint) * lerp(1, env.rgbb, _RimEnvironmentTint);
o.RimAttenuation = _RimAttenuation;
}

void ToonShadowRimFragment() {
#ifndef USING_DIRECTIONAL_LIGHT
fixed3 lightDir = normalize(UnityWorldSpaceLightDir(d.worldSpacePosition));
#else
fixed3 lightDir = _WorldSpaceLightPos0.xyz;
#endif
half lightNoL = saturate(dot(GLOBAL_pixelNormal, lightDir));
half SVDNoN = abs(dot(d.svdn, GLOBAL_pixelNormal));
half shadowRimIntensity = saturate((1 - SVDNoN)) * pow(1 - lightNoL, _ShadowRimThreshold * 2);
shadowRimIntensity = smoothstep(_ShadowRimRange - _ShadowRimSharpness, _ShadowRimRange + _ShadowRimSharpness, shadowRimIntensity);

o.RimShadow = lerp(1, (_ShadowRimTint * lerp(1, o.Albedo.rgbb, _ShadowRimAlbedoTint)), shadowRimIntensity);
}

void XSToonLighting()
{
#if !defined(UNITY_PASS_SHADOWCASTER)
half reflectance = o.Reflectivity;
half3 f0 = 0.16 * reflectance * reflectance * (1 - o.Metallic) + o.Albedo * o.Metallic;
half3 indirectDiffuse = 1;
half3 indirectSpecular = 0;
half3 directSpecular = 0;
half occlusion = o.Occlusion;
half perceptualRoughness = 1 - o.Smoothness;
half3 tangentNormal = o.Normal;
o.Normal = normalize(mul(o.Normal, d.TBNMatrix));
half3 reflDir = calcReflView(d.worldSpaceViewDir, o.Normal);

#ifndef USING_DIRECTIONAL_LIGHT
fixed3 lightDir = normalize(UnityWorldSpaceLightDir(d.worldSpacePosition));
#else
fixed3 lightDir = _WorldSpaceLightPos0.xyz;
#endif

// Attenuation
UNITY_LIGHT_ATTENUATION(lightAttenuation, FragData, d.worldSpacePosition);

// fix for rare bug where light atten is 0 when there is no directional light in the scene
#ifdef UNITY_PASS_FORWARDBASE
if(all(_LightColor0.rgb == 0.0))
lightAttenuation = 1.0;
#endif

#if defined(USING_DIRECTIONAL_LIGHT)
half sharp = o.ShadowSharpness * 0.5;
lightAttenuation = smoothstep(sharp, 1 - sharp, lightAttenuation); //Converge at the center line
#endif

half3 lightColor = _LightColor0.rgb;

half3 lightHalfVector = Unity_SafeNormalize(lightDir + d.worldSpaceViewDir);
half lightNoL = saturate(dot(o.Normal, lightDir));
half lightLoH = saturate(dot(lightDir, lightHalfVector));

half NoV = abs(dot(o.Normal, d.worldSpaceViewDir)) + 1e-5;
half NoH = saturate(dot(o.Normal, lightHalfVector));
half3 stereoViewDir = calcStereoViewDir(d.worldSpacePosition);
half NoSVDN = abs(dot(stereoViewDir, o.Normal));

// Aniso Refl
half3 reflViewAniso = 0;

float3 anisotropicDirection = o.Anisotropy >= 0.0 ? d.bitangent : FragData.worldTangent.xyz;
float3 anisotropicTangent = cross(anisotropicDirection, d.worldSpaceViewDir);
float3 anisotropicNormal = cross(anisotropicTangent, anisotropicDirection);
float bendFactor = abs(o.Anisotropy) * saturate(5.0 * perceptualRoughness);
float3 bentNormal = normalize(lerp(o.Normal, anisotropicNormal, bendFactor));
reflViewAniso = reflect(-d.worldSpaceViewDir, bentNormal);

// Indirect diffuse
#if !defined(LIGHTMAP_ON)
indirectDiffuse = ShadeSH9(float4(0,0.5,0,1));
#else
indirectDiffuse = 0;
#endif
indirectDiffuse *= lerp(occlusion, 1, o.OcclusionMode);

bool lightEnv = any(lightDir.xyz);
// if there is no realtime light - we create it from indirect diffuse
if (!lightEnv) {
lightColor = indirectDiffuse.xyz * 0.6;
indirectDiffuse = indirectDiffuse * 0.4;
}

half lightAvg = (dot(indirectDiffuse.rgb, grayscaleVec) + dot(lightColor.rgb, grayscaleVec)) / 2;

// Light Ramp
half4 ramp = 1;
half4 diffuse = 1;
ramp = calcRamp(lightNoL, lightAttenuation, occlusion, _OcclusionMode);
diffuse = calcDiffuse(lightAttenuation, o.Albedo.rgb * perceptualRoughness, indirectDiffuse, lightColor, ramp);

// Rims
half4 rimLight = o.RimLight;
rimLight *= lightColor.xyzz + indirectDiffuse.xyzz;
rimLight *= lerp(1, lightAttenuation + indirectDiffuse.xyzz, o.RimAttenuation);
half4 rimShadow = o.RimShadow;

float3 fresnel = F_Schlick(NoV, f0);
indirectSpecular = calcIndirectSpecular(lightAttenuation, d, o, perceptualRoughness, reflViewAniso, indirectDiffuse, fresnel, ramp) * occlusion;
directSpecular = calcDirectSpecular(d, o, lightNoL, NoH, NoV, lightLoH, lightColor, lightHalfVector, o.SpecularAnisotropy) * lightNoL * occlusion * lightAttenuation;

FinalColor = diffuse * o.RimShadow;
FinalColor = calcReflectionBlending(o, reflectance, FinalColor, indirectSpecular);
FinalColor += max(directSpecular.xyzz, rimLight);
FinalColor.rgb += calcEmission(o, lightAvg);

// Outline
#if defined(PASS_OUTLINE)
half3 outlineColor = 0;
half3 ol = o.OutlineColor;
outlineColor = ol * saturate(lightAttenuation * lightNoL) * lightColor.rgb;
outlineColor += indirectDiffuse * ol;
outlineColor = lerp(outlineColor, ol, o.OutlineLightingMode);
FinalColor.rgb = outlineColor;
#endif

#endif
}

// Outline Vertex
FragmentData Vertex(VertexData v)
{
#if defined(OUTLINE_ENABLED)
UNITY_SETUP_INSTANCE_ID(v);
FragmentData i;
UNITY_INITIALIZE_OUTPUT(FragmentData, i);
UNITY_TRANSFER_INSTANCE_ID(v, i);
UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(i);

vD = v;
FragData = i;
ToonOutlineVertex();

i = FragData;
v = vD;
#if defined(UNITY_PASS_SHADOWCASTER)
i.worldNormal = UnityObjectToWorldNormal(v.normal);
i.worldPos = mul(unity_ObjectToWorld, v.vertex);
i.uv0 = v.uv0;
i.uv1 = v.uv1;
i.uv2 = v.uv2;
i.uv3 = v.uv3;
i.worldTangent.xyz = UnityObjectToWorldDir(v.tangent.xyz);
i.worldTangent.w = v.tangent.w * unity_WorldTransformParams.w;
#else
i.pos = UnityObjectToClipPos(v.vertex);
i.normal = v.normal;
i.worldNormal = UnityObjectToWorldNormal(v.normal);
i.worldPos = mul(unity_ObjectToWorld, v.vertex);
i.uv0 = v.uv0;
i.uv1 = v.uv1;
i.uv2 = v.uv2;
i.uv3 = v.uv3;
i.worldTangent.xyz = UnityObjectToWorldDir(v.tangent.xyz);
i.worldTangent.w = v.tangent.w * unity_WorldTransformParams.w;
i.vertexColor = v.color;

#if defined(NEED_SCREEN_POS)
i.screenPos = ComputeScreenPos(i.pos);
#endif

#if defined(LIGHTMAP_ON)
i.lightmapUv.xy = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
#endif
#if defined(DYNAMICLIGHTMAP_ON)
i.lightmapUv.zw = v.uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
#endif

UNITY_TRANSFER_LIGHTING(i, v.uv1.xy);

#if !defined(UNITY_PASS_FORWARDADD)
// unity does some funky stuff for different platforms with these macros
#ifdef FOG_COMBINED_WITH_TSPACE
UNITY_TRANSFER_FOG_COMBINED_WITH_TSPACE(i, i.pos);
#elif defined(FOG_COMBINED_WITH_WORLD_POS)
UNITY_TRANSFER_FOG_COMBINED_WITH_WORLD_POS(i, i.pos);
#else
UNITY_TRANSFER_FOG(i, i.pos);
#endif
#else
UNITY_TRANSFER_FOG(i, i.pos);
#endif
#endif

return i;
#else
FragmentData i;
i.pos = 0.0/0.0;
return i;
#endif
}

// Outline Fragment
half4 Fragment(FragmentData i) : SV_TARGET
{
#if defined(OUTLINE_ENABLED)
UNITY_SETUP_INSTANCE_ID(i);
#ifdef FOG_COMBINED_WITH_TSPACE
UNITY_EXTRACT_FOG_FROM_TSPACE(i);
#elif defined(FOG_COMBINED_WITH_WORLD_POS)
UNITY_EXTRACT_FOG_FROM_WORLD_POS(i);
#else
UNITY_EXTRACT_FOG(i);
#endif

FragData = i;
o = (SurfaceData) 0;
d = CreateMeshData(i);
o.Albedo = half3(0.5, 0.5, 0.5);
o.Normal = half3(0, 0, 1);
o.Smoothness = 0;
o.Occlusion = 1;
o.Alpha = 1;
o.RimShadow = 1;
o.RimAttenuation = 1;
FinalColor = half4(o.Albedo, o.Alpha);

ToonFragment();
ToonOcclusionFragment();
ToonNormalsFragment();
ToonOutlineFragment();
ToonSpecularFragment();
ToonReflectionFragment();
ToonALFragment();
ToonEmissionFragment();
ToonRimLightFragment();
ToonShadowRimFragment();

XSToonLighting();

UNITY_APPLY_FOG(_unity_fogCoord, FinalColor);

return FinalColor;
#else
return half4(0.2,0.2,0.2,0);
#endif
}

ENDCG
// Outline Pass End

}

}
CustomEditor "Needle.MarkdownShaderGUI"
}
