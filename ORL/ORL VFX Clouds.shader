Shader "orels1/VFX/Clouds"
{
	Properties
	{
		[NonModifiableTextureData][NoScaleOffset] _BakedNoiseTex("Noise Tex &", 2D) =  "white" { }
		_DepthTransp("Depth Transparency", Float) =  36
		_ColorBottom("Color Bottom", Color) =  (0.5680403, 0.5980207, 0.6509434, 1)
		_ColorTop("Color Top", Color) =  (0.8066038, 0.9495488, 1, 1)
		_HeightBottom("Height Bottom", Float) =  0.12
		_HeightTop("Height Top", Float) =  1
		[Enum(Normal, 0, World Space, 1)] _ExtrusionMode("Extrusion Mode", Int) =  0
		_ExtrusionDirection("Extrusion Direction [_ExtrusionMode > 0]", Vector) =  (0, 1, 0, 1)
		[Toggle(ONLY_TOP)] _OnlyTop("Only Top [_ExtrusionMode > 0]", Int) =  0
		[ToggleUI] UI_Level1Header("## Level 1", Int) =  0
		_L1NoiseScale("Noise Scale", Float) =  1.7
		_L1NoiseStrength("Noise Strength", Float) =  0.67
		_L1NoiseDirection("Noise Direction", Vector) =  (-23.98, 0, 24.37, 0)
		[ToggleUI] UI_Level2Header("## Level 2", Int) =  0
		_L2NoiseScale("Noise Scale", Float) =  3.2
		_L2NoiseStrength("Noise Strength", Float) =  0.7
		_L2NoiseDirection("Noise Direction", Vector) =  (-40, 0, -10, 0)
		[ToggleUI] UI_Level3Header("## Level 3", Int) =  0
		_L3NoiseScale("Noise Scale", Float) =  35.51
		_L3NoiseStrength("Noise Strength", Float) =  0.1
		_L3NoiseDirection("Noise Direction", Vector) =  (80, 0, 0, 0)
		[ToggleUI] UI_AdvancedHeader("# Advanced Features", Float) = 0
		[Enum(UnityEngine.Rendering.CullMode)] _CullMode("Culling Mode", Int) = 2
		[Enum(Off, 0, On, 1)] _ZWrite("Depth Write", Int) = 0
		[Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("Depth Test", Int) = 4
	}
	SubShader
	{
		Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "IgnoreProjector" = "True"
		
	}
	
	ZTest[_ZTest]
	ZWrite[_ZWrite]
	Cull[_CullMode]
	
	Pass
	{
		Tags { "LightMode" = "ForwardBase"  }
		Blend SrcAlpha OneMinusSrcAlpha
		
		// ForwardBase Pass Start
		CGPROGRAM
		#pragma target 4.5
		#pragma multi_compile_instancing
		#pragma multi_compile_fwdbase
		#pragma multi_compile_fog
		#pragma vertex Vertex
		#pragma fragment Fragment
		#pragma shader_feature_local ONLY_TOP
		
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
		
		#define EXTRA_V2F_0
		#define NEED_DEPTH
		
		#if defined(UNITY_PBS_USE_BRDF2) || defined(SHADER_API_MOBILE)
		#define PLAT_QUEST
		#else
		#ifdef PLAT_QUEST
		#undef PLAT_QUEST
		#endif
		#endif
		
		#if !defined(LIGHTMAP_ON) || !defined(UNITY_PASS_FORWARDBASE)
		#undef BAKERY_SH
		#undef BAKERY_RNM
		#endif
		
		#ifdef LIGHTMAP_ON
		#undef BAKERY_VOLUME
		#endif
		
		#ifdef LIGHTMAP_ON
		#if defined(BAKERY_RNM) || defined(BAKERY_SH) || defined(BAKERY_VERTEXLM)
		#define BAKERYLM_ENABLED
		#undef DIRLIGHTMAP_COMBINED
		#endif
		#endif
		
		#if defined(BAKERY_SH) || defined(BAKERY_RNM) || defined(BAKERY_VOLUME)
		#ifdef BAKED_SPECULAR
		#define _BAKERY_LMSPEC
		#define BAKERY_LMSPEC
		#endif
		#endif
		
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
			float3x3 TBNMatrix;
			float4 extraV2F0;
			float4 extraV2F1;
			float4 extraV2F2;
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
			float3 bitangent = cross(i.worldTangent.xyz, i.worldNormal) * i.worldTangent.w * - 1;
			m.TBNMatrix = float3x3(normalize(i.worldTangent.xyz), bitangent, m.worldNormal);
			m.tangentSpaceViewDir = mul(m.TBNMatrix, m.worldSpaceViewDir);
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
			
			return m;
		}
		
		struct SurfaceData
		{
			half3 Albedo;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half3 Normal;
			half Alpha;
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
		
		#if defined(NEED_DEPTH)
		UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
		#endif
		
		half _DepthTransp;
		half _HeightBottom;
		half _HeightTop;
		half _ExtrusionMode;
		half _ExtrusionDirection;
		half _L1NoiseScale;
		half _L1NoiseStrength;
		half _L2NoiseScale;
		half _L2NoiseStrength;
		half _L3NoiseScale;
		half _L3NoiseStrength;
		half4 _ColorBottom;
		half4 _ColorTop;
		half4 _L1NoiseDirection;
		half4 _L2NoiseDirection;
		half4 _L3NoiseDirection;
		TEXTURE2D(_BakedNoiseTex);
		SAMPLER(sampler_BakedNoiseTex);
		
		void CloudsVertex()
		{
			half4 wPos = mul(unity_ObjectToWorld, vD.vertex);
			half3 wNormal = mul(unity_ObjectToWorld, float4(vD.normal, 0.0)).xyz;
			half3 pos = wPos.xyz / 100;
			half3 exDir = _ExtrusionMode == 0 ? vD.normal.xyz : _ExtrusionDirection;
			#if ONLY_TOP
			if (dot(wNormal, half3(0, 1, 0)) > 0)
			{
				vD.vertex.xyz += exDir * (0.7 * getBakedNoise(_BakedNoiseTex, sampler_BakedNoiseTex, pos * _L1NoiseScale + _Time.y * (_L1NoiseDirection / 100)) * _L1NoiseStrength);
				half3 pos2 = pos * _L2NoiseScale;
				pos2.z /= 2;
				vD.vertex.xyz += exDir * (0.3 * getBakedNoise(_BakedNoiseTex, sampler_BakedNoiseTex, pos2 * _L2NoiseScale + _Time.y * (_L2NoiseDirection / 100)) * _L2NoiseStrength);
				
				half3 pos3 = pos * _L3NoiseScale;
				vD.vertex.xyz += exDir * (0.5 * 0.3 * getBakedNoise(_BakedNoiseTex, sampler_BakedNoiseTex, pos3 + _Time.y * (_L3NoiseDirection / 100)) * _L3NoiseStrength);
				pos3 *= 2.01;
				vD.vertex.xyz += exDir * (0.5 * 0.3 * getBakedNoise(_BakedNoiseTex, sampler_BakedNoiseTex, pos3 + _Time.y * (_L3NoiseDirection / 100)) * _L3NoiseStrength);
			}
			#else
			vD.vertex.xyz += exDir * (0.7 * getBakedNoise(_BakedNoiseTex, sampler_BakedNoiseTex, pos * _L1NoiseScale + _Time.y * (_L1NoiseDirection / 100)) * _L1NoiseStrength);
			half3 pos2 = pos * _L2NoiseScale;
			pos2.z /= 2;
			vD.vertex.xyz += exDir * (0.3 * getBakedNoise(_BakedNoiseTex, sampler_BakedNoiseTex, pos2 * _L2NoiseScale + _Time.y * (_L2NoiseDirection / 100)) * _L2NoiseStrength);
			
			half3 pos3 = pos * _L3NoiseScale;
			vD.vertex.xyz += exDir * (0.5 * 0.3 * getBakedNoise(_BakedNoiseTex, sampler_BakedNoiseTex, pos3 + _Time.y * (_L3NoiseDirection / 100)) * _L3NoiseStrength);
			pos3 *= 2.01;
			vD.vertex.xyz += exDir * (0.5 * 0.3 * getBakedNoise(_BakedNoiseTex, sampler_BakedNoiseTex, pos3 + _Time.y * (_L3NoiseDirection / 100)) * _L3NoiseStrength);
			#endif
			FragData.extraV2F0 = ComputeScreenPos(UnityObjectToClipPos(vD.vertex));
			FragData.extraV2F0.z = -UnityObjectToViewPos(vD.vertex).z;
		}
		
		void CloudsFragment()
		{
			float sceneZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(d.extraV2F0)));
			float depth = sceneZ - d.extraV2F0.z;
			
			depth = saturate(invLerp(0, _DepthTransp, depth));
			half heightAlpha = saturate(invLerp(_HeightBottom, _HeightTop, d.localSpacePosition.y));
			half4 color = 0;
			color.rgb = lerp(_ColorBottom, _ColorTop, heightAlpha);
			o.Albedo = lerp(_ColorBottom, _ColorTop, heightAlpha);
			o.Alpha = depth;
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
			CloudsVertex();
			
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
			#if defined(UNITY_PASS_META)
			i.pos = UnityMetaVertexPosition(v.vertex, v.uv1.xy, v.uv2.xy, unity_LightmapST, unity_DynamicLightmapST);
			#else
			i.pos = UnityObjectToClipPos(v.vertex);
			#endif
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
			
			#if defined(EDITOR_VISUALIZATION)
			o.vizUV = 0;
			o.lightCoord = 0;
			if (unity_VisualizationMode == EDITORVIZ_TEXTURE)
			o.vizUV = UnityMetaVizUV(unity_EditorViz_UVIndex, v.uv0.xy, v.uv1.xy, v.uv2.xy, unity_EditorViz_Texture_ST);
			else if (unity_VisualizationMode == EDITORVIZ_SHOWLIGHTMASK)
			{
				o.vizUV = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				o.lightCoord = mul(unity_EditorViz_WorldToLight, mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1)));
			}
			#endif
			
			#if !defined(UNITY_PASS_META)
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
			#endif
			
			return i;
		}
		
		// ForwardBase Fragment
		half4 Fragment(FragmentData i) : SV_TARGET
		{
			UNITY_SETUP_INSTANCE_ID(i);
			#if defined(NEED_FOG)
			#ifdef FOG_COMBINED_WITH_TSPACE
			UNITY_EXTRACT_FOG_FROM_TSPACE(i);
			#elif defined(FOG_COMBINED_WITH_WORLD_POS)
			UNITY_EXTRACT_FOG_FROM_WORLD_POS(i);
			#else
			UNITY_EXTRACT_FOG(i);
			#endif
			#endif
			
			FragData = i;
			o = (SurfaceData) 0;
			d = CreateMeshData(i);
			o.Albedo = half3(0.5, 0.5, 0.5);
			o.Alpha = 1;
			
			CloudsFragment();
			
			FinalColor = half4(o.Albedo, o.Alpha);
			
			// fog is optional for VFX, default is OFF
			#ifdef NEED_FOG
			UNITY_APPLY_FOG(_unity_fogCoord, FinalColor);
			#endif
			
			return FinalColor;
		}
		
		ENDCG
		// ForwardBase Pass End
		
	}
	
}
CustomEditor "Needle.MarkdownShaderGUI"
}
