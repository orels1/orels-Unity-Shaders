Shader "orels1/Toon/Main"
{
	Properties
	{
		[ToggleUI] UI_MainHeader("# Main Settings", Int) =  0
		_Color("Main Color", Color) =  (1, 1, 1, 1)
		_MainTex("Albedo", 2D) =  "white" { }
		[ToggleUI] UI_RampRef("!REF _Ramp", Int) =  0
		_ShadowSharpness("Shadow Sharpness", Range(0,1)) =  0.5
		_OcclusionMap("Occlusion &&", 2D) =  "white" {}
		_OcclusionStrength("Occlusion Strength", Range(0,1)) =  0
		[NoScaleOffset] _BumpMap("Normal Map &&", 2D) =  "bump" {}
		_BumpScale("Normal Map Scale", Float) = 0.0
		[ToggleUI][_BumpMap] _FlipBumpY("Flip Y (UE Mode) [_BumpMap]", Int) =  0
		[ToggleUI] UI_SpecularHeader("# Specular Settings", Int) =  0
		_SpecularIntensity("Intensity", Float) =  0
		_SpecularRoughness("Roughness", Range(0, 1)) =  0
		_SpecularSharpness("Sharpness", Range(0, 1)) =  0
		_SpecularAnisotropy("Anisotropy", Float) = 0.0
		_SpecularAlbedoTint("Albedo Tint", Range(0, 1)) =  1
		[ToggleUI] UI_ReflectionsHeader("# Reflection Settings", Int) =  0
		[Enum(PBR(Unity Metallic Standard),0,Baked Cubemap,1,Matcap,2,Off,3)] _ReflectionMode("Reflection Mode", Int) =  3
		[Enum(Additive,0,Multiply,1,Subtract,2)] _ReflectionBlendMode("Reflection Blend Mode", Int) =  0
		_BakedCubemap("Baked Cubemap & [_ReflectionMode != 3]", CUBE) =  "black" {}
		[ToggleUI] UI_FallbackNote("!NOTE Will be used if world has no reflections [_ReflectionMode == 0]", Int) =  0
		_MetallicGlossMap("Metallic Smoothness & [_ReflectionMode == 0]", 2D) =  "white" {}
		[ToggleUI] UI_MetallicNote("!NOTE R - Metallic, A - Smoothness [_ReflectionMode == 0]", Int) =  0
		_Smoothness("Smoothness [!_MetallicGlossMap && _ReflectionMode == 0]", Range(0, 1)) =  0.5
		[ToggleUI] _RoughnessMode("Roughness Mode [_MetallicGlossMap && _ReflectionMode == 0]", Int) =  0
		[ToggleUI] UI_SmoothnessRemap("!DRAWER MinMax _SmoothnessRemap.x _SmoothnessRemap.y [_MetallicGlossMap && _ReflectionMode == 0]", Float) =  0
		_Metallic("Metallic [!_MetallicGlossMap && _ReflectionMode == 0]", Range(0, 1)) =  0
		[ToggleUI] UI_MetallicRemap("!DRAWER MinMax _MetallicRemap.x _MetallicRemap.y [_MetallicGlossMap && _ReflectionMode == 0]", Float) =  0
		[HideInInspector] _MetallicRemap("Metallic Remap", Vector) =  (0, 1, 0, 1)
		[HideInInspector] _SmoothnessRemap("Smoothness Remap", Vector) =  (0, 1, 0, 1)
		_ReflectionAnisotropy("Anisotropy [_ReflectionMode == 0]", Float) = 0.0
		[ToggleUI] UI_EmissionHeader("# Emission Settings", Int) =  0
		[NoScaleOffset] _EmissionMap("Emission Map &&", 2D) =  "white" {}
		[HDR] _EmissionColor("Emission Color", Color) =  (0,0,0,1)
		_EmissionTintToDiffuse("Emission Tint To Diffuse", Range(0,1)) =  0
		[Enum(Yes,0, No,1)] _EmissionScaleWithLight("Emission Scale w/ Light", Int) =  1
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
				half3 BakedReflection;
				int ReflectionBlendMode;
				int EnableReflections;
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
			
			half4 calcRamp(half NdL, half attenuation)
			{
				half remapRamp;
				remapRamp = NdL * 0.5 + 0.5;
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
			
			half3 calcIndirectSpecular(half lightAttentuation, MeshData d, SurfaceData o, half roughness, half3 reflDir, half3 indirectLight, float3 fresnel, half4 ramp)
			{//This function handls Unity style reflections, Matcaps, and a baked in fallback cubemap.
				half3 spec = half3(0,0,0);
				
				UNITY_BRANCH
				if (!o.EnableReflections) {
					spec = 0;
				} else if(any(o.BakedReflection.rgb)) {
					spec = o.BakedReflection;
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
						indirectSpecular = o.BakedReflection;
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
half _SpecularIntensity;
half _SpecularRoughness;
half _SpecularSharpness;
half _SpecularAnisotropy;
half _SpecularAlbedoTint;
half _Smoothness;
half _Metallic;
half _ReflectionAnisotropy;
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
half _SpecOcclusion;
half _SpecularRoughnessMod;
half2 GLOBAL_uv;
half4 _Color;
half4 _MetallicRemap;
half4 _SmoothnessRemap;
half4 _MetallicGlossMap_TexelSize;
half4 _EmissionColor;
half4 _RimTint;
half4 _ShadowRimTint;
float _GSAAVariance;
float _GSAAThreshold;
float4 _MainTex_ST;
int _FlipBumpY;
int _ReflectionMode;
int _ReflectionBlendMode;
int _RoughnessMode;
int _EmissionScaleWithLight;
TEXTURE2D(_MainTex);;
SAMPLER(sampler_MainTex);;
TEXTURE2D(_OcclusionMap);;
TEXTURE2D(_BumpMap);;
SAMPLER(sampler_BumpMap);;
TEXTURECUBE(_BakedCubemap);;
SAMPLER(sampler_BakedCubemap);;
TEXTURE2D(_MetallicGlossMap);;
TEXTURE2D(_EmissionMap);;
TEXTURE2D(_DFG);
SAMPLER(sampler_DFG);

void ToonFragment() {
	half2 uv = d.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
	GLOBAL_uv = uv;
	half3 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, GLOBAL_uv).rgb;
	albedo *= _Color;
	half occlusion = SAMPLE_TEXTURE2D(_OcclusionMap, sampler_MainTex, GLOBAL_uv).r;
	
	o.Albedo = albedo;
	o.ShadowSharpness = _ShadowSharpness;
	o.Occlusion = lerp(1, occlusion, _OcclusionStrength);
	
	half4 normalTex = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, GLOBAL_uv);
	if (_FlipBumpY)
	{
		normalTex.y = 1 - normalTex.y;
	}
	half3 normal = UnpackScaleNormal(normalTex, _BumpScale);
	
	o.Normal = normal;
	
	o.SpecularIntensity = _SpecularIntensity;
	o.SpecularArea = _SpecularRoughness;
	o.SpecularAnisotropy = _SpecularAnisotropy;
	o.SpecularAlbedoTint = _SpecularAlbedoTint;
	o.SpecularSharpness = _SpecularSharpness;
	
	o.EnableReflections = _ReflectionMode != 3;
	o.ReflectionBlendMode = _ReflectionBlendMode;
	
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
	
	half3 emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_MainTex, GLOBAL_uv).rgb;
	emission *= lerp(emission, emission * o.Albedo, _EmissionTintToDiffuse) * _EmissionColor;
	o.Emission = emission;
	o.EmissionScaleWithLight = _EmissionScaleWithLight;
	o.EmissionLightThreshold = _EmissionScaleWithLightSensitivity;
	
	#ifndef USING_DIRECTIONAL_LIGHT
	fixed3 lightDir = normalize(UnityWorldSpaceLightDir(d.worldSpacePosition));
	#else
	fixed3 lightDir = _WorldSpaceLightPos0.xyz;
	#endif
	half3 properNormal = normalize(mul(o.Normal, d.TBNMatrix));
	half lightNoL = saturate(dot(properNormal, lightDir));
	half SVDNoN = abs(dot(d.svdn, properNormal));
	
	half rimIntensity = saturate((1 - SVDNoN)) * pow(lightNoL, _RimThreshold);
	rimIntensity = smoothstep(_RimRange - _RimSharpness, _RimRange + _RimSharpness, rimIntensity);
	half4 rim = rimIntensity * _RimIntensity;
	
	half3 env = 0;
	
	#if defined(UNITY_PASS_FORWARDBASE)
	half3 reflDir = reflect(-d.worldSpaceViewDir, properNormal);
	half perceptualRoughness = 1 - o.Smoothness;
	half rough = perceptualRoughness * perceptualRoughness;
	reflDir = lerp(reflDir, properNormal, rough * rough);
	
	half3 reflectionUV1 = getBoxProjection(reflDir, d.worldSpacePosition.xyz, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin.xyz, unity_SpecCube0_BoxMax.xyz);
	half4 probe0 = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectionUV1, 5);
	half3 probe0sample = DecodeHDR(probe0, unity_SpecCube0_HDR);
	
	half3 indirectSpecular;
	half interpolator = unity_SpecCube0_BoxMin.w;
	
	UNITY_BRANCH
	if (interpolator < 0.99999)
	{
		half3 reflectionUV2 = getBoxProjection(reflDir, d.worldSpacePosition.xyz, unity_SpecCube1_ProbePosition, unity_SpecCube1_BoxMin.xyz, unity_SpecCube1_BoxMax.xyz);
		half4 probe1 = UNITY_SAMPLE_TEXCUBE_SAMPLER_LOD(unity_SpecCube1, unity_SpecCube0, reflectionUV2, 5);
		half3 probe1sample = DecodeHDR(probe1, unity_SpecCube1_HDR);
		indirectSpecular = lerp(probe1sample, probe0sample, interpolator);
	}
	else
	{
		indirectSpecular = probe0sample;
	}
	
	env = indirectSpecular;
	#endif
	
	o.RimLight = rim * _RimTint * lerp(1, o.Albedo.rgbb, _RimAlbedoTint) * lerp(1, env.rgbb, _RimEnvironmentTint);
	o.RimAttenuation = _RimAttenuation;
	
	half shadowRimIntensity = saturate((1 - SVDNoN)) * pow(1 - lightNoL, _ShadowRimThreshold * 2);
	shadowRimIntensity = smoothstep(_ShadowRimRange - _ShadowRimSharpness, _ShadowRimRange + _ShadowRimSharpness, shadowRimIntensity);
	
	o.RimShadow = lerp(1, (_ShadowRimTint * lerp(1, o.Albedo.rgbb, _ShadowRimAlbedoTint)), shadowRimIntensity);
}

void XSToonLighting()
{
	#if !defined(UNITY_PASS_SHADOWCASTER)
	half reflectance = 0.5;
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
	
	half3 lightColor =  _LightColor0.rgb;
	
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
	indirectDiffuse *= occlusion;
	
	bool lightEnv = any(lightDir.xyz);
	// if there is no realtime light - we create it from indirect diffuse
	if (!lightEnv) {
		lightColor = indirectDiffuse.xyz * 0.6;
		indirectDiffuse = indirectDiffuse * 0.4;
	}
	
	half lightAvg = (dot(indirectDiffuse.rgb, grayscaleVec) + dot(lightColor.rgb, grayscaleVec)) / 2;
	
	// // Indirect Specular
	// #if defined(UNITY_PASS_FORWARDBASE) //Indirect PBR specular should only happen in the forward base pass. Otherwise each extra light adds another indirect sample, which could mean you're getting too much light.
	//   half3 reflectionUV1 = getReflectionUV(reflDir, d.worldSpacePosition, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax);
	//   half4 probe0 = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectionUV1, 5);
	//   half3 probe0sample = DecodeHDR(probe0, unity_SpecCube0_HDR);
	
	//   half3 indirectSpecular;
	//   half interpolator = unity_SpecCube0_BoxMin.w;
	
	//   UNITY_BRANCH
	//   if (interpolator < 0.99999)
	//   {
	//       half3 reflectionUV2 = getReflectionUV(reflDir, d.worldSpacePosition, unity_SpecCube1_ProbePosition, unity_SpecCube1_BoxMin, unity_SpecCube1_BoxMax);
	//   #endif
	//       half4 probe1 = UNITY_SAMPLE_TEXCUBE_SAMPLER_LOD(unity_SpecCube1, unity_SpecCube0, reflectionUV2, 5);
	//       half3 probe1sample = DecodeHDR(probe1, unity_SpecCube1_HDR);
	//       indirectSpecular = lerp(probe1sample, probe0sample, interpolator);
	//   }
	//   else
	//   {
	//       indirectSpecular = probe0sample;
	//   }
	// #endif
	
	// Light Ramp
	half4 ramp = 1;
	half4 diffuse = 1;
	ramp = calcRamp(lightNoL, lightAttenuation);
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
	FinalColor = calcReflectionBlending(o, 1, FinalColor, indirectSpecular);
	FinalColor += max(directSpecular.xyzz, rimLight);
	FinalColor.rgb += calcEmission(o, lightAvg);
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
	half3 BakedReflection;
	int ReflectionBlendMode;
	int EnableReflections;
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

half4 calcRamp(half NdL, half attenuation)
{
	half remapRamp;
	remapRamp = NdL * 0.5 + 0.5;
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

half3 calcIndirectSpecular(half lightAttentuation, MeshData d, SurfaceData o, half roughness, half3 reflDir, half3 indirectLight, float3 fresnel, half4 ramp)
{//This function handls Unity style reflections, Matcaps, and a baked in fallback cubemap.
	half3 spec = half3(0,0,0);
	
	UNITY_BRANCH
	if (!o.EnableReflections) {
		spec = 0;
	} else if(any(o.BakedReflection.rgb)) {
		spec = o.BakedReflection;
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
			indirectSpecular = o.BakedReflection;
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
half _SpecularIntensity;
half _SpecularRoughness;
half _SpecularSharpness;
half _SpecularAnisotropy;
half _SpecularAlbedoTint;
half _Smoothness;
half _Metallic;
half _ReflectionAnisotropy;
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
half _SpecOcclusion;
half _SpecularRoughnessMod;
half2 GLOBAL_uv;
half4 _Color;
half4 _MetallicRemap;
half4 _SmoothnessRemap;
half4 _MetallicGlossMap_TexelSize;
half4 _EmissionColor;
half4 _RimTint;
half4 _ShadowRimTint;
float _GSAAVariance;
float _GSAAThreshold;
float4 _MainTex_ST;
int _FlipBumpY;
int _ReflectionMode;
int _ReflectionBlendMode;
int _RoughnessMode;
int _EmissionScaleWithLight;
TEXTURE2D(_MainTex);;
SAMPLER(sampler_MainTex);;
TEXTURE2D(_OcclusionMap);;
TEXTURE2D(_BumpMap);;
SAMPLER(sampler_BumpMap);;
TEXTURECUBE(_BakedCubemap);;
SAMPLER(sampler_BakedCubemap);;
TEXTURE2D(_MetallicGlossMap);;
TEXTURE2D(_EmissionMap);;
TEXTURE2D(_DFG);
SAMPLER(sampler_DFG);

void ToonFragment() {
half2 uv = d.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
GLOBAL_uv = uv;
half3 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, GLOBAL_uv).rgb;
albedo *= _Color;
half occlusion = SAMPLE_TEXTURE2D(_OcclusionMap, sampler_MainTex, GLOBAL_uv).r;

o.Albedo = albedo;
o.ShadowSharpness = _ShadowSharpness;
o.Occlusion = lerp(1, occlusion, _OcclusionStrength);

half4 normalTex = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, GLOBAL_uv);
if (_FlipBumpY)
{
normalTex.y = 1 - normalTex.y;
}
half3 normal = UnpackScaleNormal(normalTex, _BumpScale);

o.Normal = normal;

o.SpecularIntensity = _SpecularIntensity;
o.SpecularArea = _SpecularRoughness;
o.SpecularAnisotropy = _SpecularAnisotropy;
o.SpecularAlbedoTint = _SpecularAlbedoTint;
o.SpecularSharpness = _SpecularSharpness;

o.EnableReflections = _ReflectionMode != 3;
o.ReflectionBlendMode = _ReflectionBlendMode;

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

half3 emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_MainTex, GLOBAL_uv).rgb;
emission *= lerp(emission, emission * o.Albedo, _EmissionTintToDiffuse) * _EmissionColor;
o.Emission = emission;
o.EmissionScaleWithLight = _EmissionScaleWithLight;
o.EmissionLightThreshold = _EmissionScaleWithLightSensitivity;

#ifndef USING_DIRECTIONAL_LIGHT
fixed3 lightDir = normalize(UnityWorldSpaceLightDir(d.worldSpacePosition));
#else
fixed3 lightDir = _WorldSpaceLightPos0.xyz;
#endif
half3 properNormal = normalize(mul(o.Normal, d.TBNMatrix));
half lightNoL = saturate(dot(properNormal, lightDir));
half SVDNoN = abs(dot(d.svdn, properNormal));

half rimIntensity = saturate((1 - SVDNoN)) * pow(lightNoL, _RimThreshold);
rimIntensity = smoothstep(_RimRange - _RimSharpness, _RimRange + _RimSharpness, rimIntensity);
half4 rim = rimIntensity * _RimIntensity;

half3 env = 0;

#if defined(UNITY_PASS_FORWARDBASE)
half3 reflDir = reflect(-d.worldSpaceViewDir, properNormal);
half perceptualRoughness = 1 - o.Smoothness;
half rough = perceptualRoughness * perceptualRoughness;
reflDir = lerp(reflDir, properNormal, rough * rough);

half3 reflectionUV1 = getBoxProjection(reflDir, d.worldSpacePosition.xyz, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin.xyz, unity_SpecCube0_BoxMax.xyz);
half4 probe0 = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectionUV1, 5);
half3 probe0sample = DecodeHDR(probe0, unity_SpecCube0_HDR);

half3 indirectSpecular;
half interpolator = unity_SpecCube0_BoxMin.w;

UNITY_BRANCH
if (interpolator < 0.99999)
{
half3 reflectionUV2 = getBoxProjection(reflDir, d.worldSpacePosition.xyz, unity_SpecCube1_ProbePosition, unity_SpecCube1_BoxMin.xyz, unity_SpecCube1_BoxMax.xyz);
half4 probe1 = UNITY_SAMPLE_TEXCUBE_SAMPLER_LOD(unity_SpecCube1, unity_SpecCube0, reflectionUV2, 5);
half3 probe1sample = DecodeHDR(probe1, unity_SpecCube1_HDR);
indirectSpecular = lerp(probe1sample, probe0sample, interpolator);
}
else
{
indirectSpecular = probe0sample;
}

env = indirectSpecular;
#endif

o.RimLight = rim * _RimTint * lerp(1, o.Albedo.rgbb, _RimAlbedoTint) * lerp(1, env.rgbb, _RimEnvironmentTint);
o.RimAttenuation = _RimAttenuation;

half shadowRimIntensity = saturate((1 - SVDNoN)) * pow(1 - lightNoL, _ShadowRimThreshold * 2);
shadowRimIntensity = smoothstep(_ShadowRimRange - _ShadowRimSharpness, _ShadowRimRange + _ShadowRimSharpness, shadowRimIntensity);

o.RimShadow = lerp(1, (_ShadowRimTint * lerp(1, o.Albedo.rgbb, _ShadowRimAlbedoTint)), shadowRimIntensity);
}

void XSToonLighting()
{
#if !defined(UNITY_PASS_SHADOWCASTER)
half reflectance = 0.5;
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

half3 lightColor =  _LightColor0.rgb;

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
indirectDiffuse *= occlusion;

bool lightEnv = any(lightDir.xyz);
// if there is no realtime light - we create it from indirect diffuse
if (!lightEnv) {
lightColor = indirectDiffuse.xyz * 0.6;
indirectDiffuse = indirectDiffuse * 0.4;
}

half lightAvg = (dot(indirectDiffuse.rgb, grayscaleVec) + dot(lightColor.rgb, grayscaleVec)) / 2;

// // Indirect Specular
// #if defined(UNITY_PASS_FORWARDBASE) //Indirect PBR specular should only happen in the forward base pass. Otherwise each extra light adds another indirect sample, which could mean you're getting too much light.
//   half3 reflectionUV1 = getReflectionUV(reflDir, d.worldSpacePosition, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax);
//   half4 probe0 = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectionUV1, 5);
//   half3 probe0sample = DecodeHDR(probe0, unity_SpecCube0_HDR);

//   half3 indirectSpecular;
//   half interpolator = unity_SpecCube0_BoxMin.w;

//   UNITY_BRANCH
//   if (interpolator < 0.99999)
//   {
//       half3 reflectionUV2 = getReflectionUV(reflDir, d.worldSpacePosition, unity_SpecCube1_ProbePosition, unity_SpecCube1_BoxMin, unity_SpecCube1_BoxMax);
//   #endif
//       half4 probe1 = UNITY_SAMPLE_TEXCUBE_SAMPLER_LOD(unity_SpecCube1, unity_SpecCube0, reflectionUV2, 5);
//       half3 probe1sample = DecodeHDR(probe1, unity_SpecCube1_HDR);
//       indirectSpecular = lerp(probe1sample, probe0sample, interpolator);
//   }
//   else
//   {
//       indirectSpecular = probe0sample;
//   }
// #endif

// Light Ramp
half4 ramp = 1;
half4 diffuse = 1;
ramp = calcRamp(lightNoL, lightAttenuation);
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
FinalColor = calcReflectionBlending(o, 1, FinalColor, indirectSpecular);
FinalColor += max(directSpecular.xyzz, rimLight);
FinalColor.rgb += calcEmission(o, lightAvg);
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
half3 BakedReflection;
int ReflectionBlendMode;
int EnableReflections;
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

half4 calcRamp(half NdL, half attenuation)
{
half remapRamp;
remapRamp = NdL * 0.5 + 0.5;
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

half3 calcIndirectSpecular(half lightAttentuation, MeshData d, SurfaceData o, half roughness, half3 reflDir, half3 indirectLight, float3 fresnel, half4 ramp)
{//This function handls Unity style reflections, Matcaps, and a baked in fallback cubemap.
half3 spec = half3(0,0,0);

UNITY_BRANCH
if (!o.EnableReflections) {
spec = 0;
} else if(any(o.BakedReflection.rgb)) {
spec = o.BakedReflection;
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
indirectSpecular = o.BakedReflection;
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
half _SpecularIntensity;
half _SpecularRoughness;
half _SpecularSharpness;
half _SpecularAnisotropy;
half _SpecularAlbedoTint;
half _Smoothness;
half _Metallic;
half _ReflectionAnisotropy;
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
half _SpecOcclusion;
half _SpecularRoughnessMod;
half2 GLOBAL_uv;
half4 _Color;
half4 _MetallicRemap;
half4 _SmoothnessRemap;
half4 _MetallicGlossMap_TexelSize;
half4 _EmissionColor;
half4 _RimTint;
half4 _ShadowRimTint;
float _GSAAVariance;
float _GSAAThreshold;
float4 _MainTex_ST;
int _FlipBumpY;
int _ReflectionMode;
int _ReflectionBlendMode;
int _RoughnessMode;
int _EmissionScaleWithLight;
TEXTURE2D(_MainTex);;
SAMPLER(sampler_MainTex);;
TEXTURE2D(_OcclusionMap);;
TEXTURE2D(_BumpMap);;
SAMPLER(sampler_BumpMap);;
TEXTURECUBE(_BakedCubemap);;
SAMPLER(sampler_BakedCubemap);;
TEXTURE2D(_MetallicGlossMap);;
TEXTURE2D(_EmissionMap);;
TEXTURE2D(_DFG);
SAMPLER(sampler_DFG);

void ToonFragment() {
half2 uv = d.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
GLOBAL_uv = uv;
half3 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, GLOBAL_uv).rgb;
albedo *= _Color;
half occlusion = SAMPLE_TEXTURE2D(_OcclusionMap, sampler_MainTex, GLOBAL_uv).r;

o.Albedo = albedo;
o.ShadowSharpness = _ShadowSharpness;
o.Occlusion = lerp(1, occlusion, _OcclusionStrength);

half4 normalTex = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, GLOBAL_uv);
if (_FlipBumpY)
{
normalTex.y = 1 - normalTex.y;
}
half3 normal = UnpackScaleNormal(normalTex, _BumpScale);

o.Normal = normal;

o.SpecularIntensity = _SpecularIntensity;
o.SpecularArea = _SpecularRoughness;
o.SpecularAnisotropy = _SpecularAnisotropy;
o.SpecularAlbedoTint = _SpecularAlbedoTint;
o.SpecularSharpness = _SpecularSharpness;

o.EnableReflections = _ReflectionMode != 3;
o.ReflectionBlendMode = _ReflectionBlendMode;

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

half3 emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_MainTex, GLOBAL_uv).rgb;
emission *= lerp(emission, emission * o.Albedo, _EmissionTintToDiffuse) * _EmissionColor;
o.Emission = emission;
o.EmissionScaleWithLight = _EmissionScaleWithLight;
o.EmissionLightThreshold = _EmissionScaleWithLightSensitivity;

#ifndef USING_DIRECTIONAL_LIGHT
fixed3 lightDir = normalize(UnityWorldSpaceLightDir(d.worldSpacePosition));
#else
fixed3 lightDir = _WorldSpaceLightPos0.xyz;
#endif
half3 properNormal = normalize(mul(o.Normal, d.TBNMatrix));
half lightNoL = saturate(dot(properNormal, lightDir));
half SVDNoN = abs(dot(d.svdn, properNormal));

half rimIntensity = saturate((1 - SVDNoN)) * pow(lightNoL, _RimThreshold);
rimIntensity = smoothstep(_RimRange - _RimSharpness, _RimRange + _RimSharpness, rimIntensity);
half4 rim = rimIntensity * _RimIntensity;

half3 env = 0;

#if defined(UNITY_PASS_FORWARDBASE)
half3 reflDir = reflect(-d.worldSpaceViewDir, properNormal);
half perceptualRoughness = 1 - o.Smoothness;
half rough = perceptualRoughness * perceptualRoughness;
reflDir = lerp(reflDir, properNormal, rough * rough);

half3 reflectionUV1 = getBoxProjection(reflDir, d.worldSpacePosition.xyz, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin.xyz, unity_SpecCube0_BoxMax.xyz);
half4 probe0 = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectionUV1, 5);
half3 probe0sample = DecodeHDR(probe0, unity_SpecCube0_HDR);

half3 indirectSpecular;
half interpolator = unity_SpecCube0_BoxMin.w;

UNITY_BRANCH
if (interpolator < 0.99999)
{
half3 reflectionUV2 = getBoxProjection(reflDir, d.worldSpacePosition.xyz, unity_SpecCube1_ProbePosition, unity_SpecCube1_BoxMin.xyz, unity_SpecCube1_BoxMax.xyz);
half4 probe1 = UNITY_SAMPLE_TEXCUBE_SAMPLER_LOD(unity_SpecCube1, unity_SpecCube0, reflectionUV2, 5);
half3 probe1sample = DecodeHDR(probe1, unity_SpecCube1_HDR);
indirectSpecular = lerp(probe1sample, probe0sample, interpolator);
}
else
{
indirectSpecular = probe0sample;
}

env = indirectSpecular;
#endif

o.RimLight = rim * _RimTint * lerp(1, o.Albedo.rgbb, _RimAlbedoTint) * lerp(1, env.rgbb, _RimEnvironmentTint);
o.RimAttenuation = _RimAttenuation;

half shadowRimIntensity = saturate((1 - SVDNoN)) * pow(1 - lightNoL, _ShadowRimThreshold * 2);
shadowRimIntensity = smoothstep(_ShadowRimRange - _ShadowRimSharpness, _ShadowRimRange + _ShadowRimSharpness, shadowRimIntensity);

o.RimShadow = lerp(1, (_ShadowRimTint * lerp(1, o.Albedo.rgbb, _ShadowRimAlbedoTint)), shadowRimIntensity);
}

void XSToonLighting()
{
#if !defined(UNITY_PASS_SHADOWCASTER)
half reflectance = 0.5;
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

half3 lightColor =  _LightColor0.rgb;

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
indirectDiffuse *= occlusion;

bool lightEnv = any(lightDir.xyz);
// if there is no realtime light - we create it from indirect diffuse
if (!lightEnv) {
lightColor = indirectDiffuse.xyz * 0.6;
indirectDiffuse = indirectDiffuse * 0.4;
}

half lightAvg = (dot(indirectDiffuse.rgb, grayscaleVec) + dot(lightColor.rgb, grayscaleVec)) / 2;

// // Indirect Specular
// #if defined(UNITY_PASS_FORWARDBASE) //Indirect PBR specular should only happen in the forward base pass. Otherwise each extra light adds another indirect sample, which could mean you're getting too much light.
//   half3 reflectionUV1 = getReflectionUV(reflDir, d.worldSpacePosition, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax);
//   half4 probe0 = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectionUV1, 5);
//   half3 probe0sample = DecodeHDR(probe0, unity_SpecCube0_HDR);

//   half3 indirectSpecular;
//   half interpolator = unity_SpecCube0_BoxMin.w;

//   UNITY_BRANCH
//   if (interpolator < 0.99999)
//   {
//       half3 reflectionUV2 = getReflectionUV(reflDir, d.worldSpacePosition, unity_SpecCube1_ProbePosition, unity_SpecCube1_BoxMin, unity_SpecCube1_BoxMax);
//   #endif
//       half4 probe1 = UNITY_SAMPLE_TEXCUBE_SAMPLER_LOD(unity_SpecCube1, unity_SpecCube0, reflectionUV2, 5);
//       half3 probe1sample = DecodeHDR(probe1, unity_SpecCube1_HDR);
//       indirectSpecular = lerp(probe1sample, probe0sample, interpolator);
//   }
//   else
//   {
//       indirectSpecular = probe0sample;
//   }
// #endif

// Light Ramp
half4 ramp = 1;
half4 diffuse = 1;
ramp = calcRamp(lightNoL, lightAttenuation);
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
FinalColor = calcReflectionBlending(o, 1, FinalColor, indirectSpecular);
FinalColor += max(directSpecular.xyzz, rimLight);
FinalColor.rgb += calcEmission(o, lightAvg);
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

#endif

SHADOW_CASTER_FRAGMENT(i);
}

ENDCG
// Shadow Pass End

}

}
CustomEditor "Needle.MarkdownShaderGUI"
}
