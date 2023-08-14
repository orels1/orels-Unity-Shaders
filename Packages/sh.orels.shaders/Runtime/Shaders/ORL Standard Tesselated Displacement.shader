Shader "orels1/Standard Tesselated Displacement"
{
	Properties
	{
		UI_MainHeader("# Main Settings", Int) = 1
		_Color("Main Color", Color) =  (1, 1, 1, 1)
		_MainTex("Albedo", 2D) =  "white" { }
		[Enum(RGB, 0, R, 1, G, 2, B, 3)][_MainTex] _AlbedoChannel("Albedo Channel %ShowIf(_MainTex)", Int) =  0
		[Enum(UV, 0, Local Space, 1, World Space, 2)] _MappingSpace("Mapping Space", Int) =  0
		[Enum(X, 0, Y, 1, Z, 2)] _PlanarAxisX("X Axis %ShowIf(_MappingSpace > 0) %CombineWith(_PlanarAxisY)", Int) =  0
		[HideInInspector][Enum(X, 0, Y, 1, Z, 2)] _PlanarAxisY("Y Axis %ShowIf(_MappingSpace > 0)", Int) =  2
		[NoScaleOffset] _MaskMap("Masks >", 2D) =  "white" { }
		[Enum(R, 0, G, 1, B, 2, A, 3)] _MetalChannel("Metal %ShowIf(_MaskMap) %CombineWith(_AOChannel, _DetailMaskChannel, _SmoothChannel)", Int) =  0
		[HideInInspector][Enum(R, 0, G, 1, B, 2, A, 3)] _AOChannel("AO", Int) =  1
		[HideInInspector][Enum(R, 0, G, 1, B, 2, A, 3)] _DetailMaskChannel("Detail", Int) =  2
		[HideInInspector][Enum(R, 0, G, 1, B, 2, A, 3)] _SmoothChannel("Smooth", Int) =  3
		_Smoothness("Smoothness %ShowIf(!_MaskMap)", Range(0, 1)) =  0.5
		[ToggleUI][_MaskMap] _RoughnessMode("Roughness Mode %ShowIf(_MaskMap)", Int) =  0
		_Metallic("Metallic %ShowIf(!_MaskMap)", Range(0, 1)) =  0
		_MetallicRemap("Metallic Remap %ShowIf(_MaskMap) %RemapSlider(0,1)", Vector) =  (0, 1, 0, 1)
		_SmoothnessRemap("Smoothness Remap %ShowIf(_MaskMap) %RemapSlider(0,1)", Vector) =  (0, 1, 0, 1)
		_OcclusionStrength("AO Strength %ShowIf(_MaskMap)", Range(0, 1)) =  1
		[ToggleUI]_DetailAsTintMask("Detail as Tint Mask %ShowIf(_MaskMap)", Int) =  0
		[NoScaleOffset] _BumpMap("Normal Map >", 2D) =  "bump" { }
		_BumpScale("Normal Map Scale %ShowIf(_BumpMap)", Range(-1, 1)) =  1
		[ToggleUI]_FlipBumpY("Flip Y (UE Mode) %ShowIf(_BumpMap)", Int) =  0
		[Toggle(_EMISSION)] _EmissionEnabled("Emission", Int) =  0
		_EmissionMap("Emission Map > %ShowIf(_EMISSION)", 2D) =  "white" { }
		[HDR]_EmissionColor("Emission Color %ShowIf(_EMISSION)", Color) =  (0, 0, 0, 1)
		[Enum(RGB, 0, R, 1, G, 2, B, 3)][_EmissionMap] _EmissionChannel("Emission Channel %ShowIf(_EmissionMap)", Int) =  0

		UI_ParallaxHeader("# Parallax", Int) = 0
		UI_ParallaxDocs("[This module has documentation](https://shaders.orels.sh/docs/orl-standard/base-shader#parallax)", Int) = 0
		[Toggle(PARALLAX)]_EnableParallax("Enable Parallax", Int) = 0
		[NoScaleOffset]_Height("Height > %ShowIf(PARALLAX)", 2D) = "black" {}
		_HeightScale("Height Scale %ShowIf(PARALLAX)", Range(0, 0.1)) = 0.006
		_HeightRefPlane("Height Ref Plane %ShowIf(PARALLAX)", Range(-1, 1)) = 0.5
		_HeightStepsMin("Steps Min %ShowIf(PARALLAX)", Range(8, 32)) = 8
		_HeightStepsMax("Steps Max %ShowIf(PARALLAX)", Range(8, 32)) = 16

		UI_DetailsHeader("# Details", Int) = 0
		UI_DetailsDocs("[This module has documentation](https://shaders.orels.sh/docs/orl-standard/base-shader#details)", Int) = 0
		[Toggle(DETAILS_OVERLAY)]_DetailsOverlay("Enable Details", Int) = 0
		[ToggleUI]_DIgnoreMask("Ignore Mask %ShowIf(DETAILS_OVERLAY)", Int) = 0
		UI_IgnoreMaskNote("> Force-draws the detail effects %ShowIf(DETAILS_OVERLAY)", Int) = 0
		[KeywordEnum(Packed, Separated)]DETAILS_MODE("Detail Map Mode %ShowIf(DETAILS_OVERLAY)", Int) = 0
		_DDetailsMap("Details Map %ShowIf(DETAILS_OVERLAY)", 2D) = "gray" { }
		UI_DetailsMapNote("> R: Albedo, G: Normal G, B: Smooth, A: Normal R. Uncheck sRGB! %ShowIf(DETAILS_OVERLAY && DETAILS_MODE_PACKED)", Int) = 0
		UI_DetailsMapNoteSeparate("> RGB: Albedo, A: Smooth. Uncheck sRGB! %ShowIf(DETAILS_OVERLAY && DETAILS_MODE_SEPARATED)", Int) = 0
		[NoScaleOffset]_DDetailsNormal("Details Normal Map > %ShowIf(DETAILS_OVERLAY && DETAILS_MODE_SEPARATED)", 2D) = "bump" { }
		[Enum(UV, 0, Local Space, 1, World Space, 2)]_DMappingSpace("Mapping Space %ShowIf(DETAILS_OVERLAY)", Int) = 0
		[Enum(UV1, 0, UV2, 1, UV3, 2, UV4, 3)]_DUVChannel("UV Set %ShowIf(_DMappingSpace == 0 && DETAILS_OVERLAY)", Int) = 0
		[Enum(X, 0, Y, 1, Z, 2)]_DPlanarAxisX("X Axis %ShowIf(_DMappingSpace > 0 && DETAILS_OVERLAY) %CombineWith(_DPlanarAxisY)", Int) = 0
		[HideInInspector][Enum(X, 0, Y, 1, Z, 2)]_DPlanarAxisY("Y Axis", Int) = 2
		_DAlbedoScale("Albedo Scale %ShowIf(DETAILS_OVERLAY)", Range(0.0, 2.0)) = 1
		UI_DetailAlbedoNote("> Values < 0.5 - darken, > 0.5 - lighten %ShowIf(DETAILS_OVERLAY)", Int) = 0
		_DNormalScale("Normal Scale %ShowIf(DETAILS_OVERLAY)", Range(0.0, 2.0)) = 1
		[ToggleUI]_DNormalFlipY("Flip Y (UE Mode) %ShowIf(DETAILS_OVERLAY)", Int) = 0
		_DSmoothScale("Smooth Scale %ShowIf(DETAILS_OVERLAY)", Range(0.0, 2.0)) = 1
		UI_DetailSmoothNote("> Values < 0.5 - roughen, > 0.5 - smoothen %ShowIf(DETAILS_OVERLAY)", Int) = 0

		UI_TessellationHeader("# Tessellation", Int) =  0
		UI_TessSHNote("> Bakery SH does not show up correctly on tessellated meshes at this point %ShowIf(BAKERY_SH)", Int) =  0
		[KeywordEnum(DistanceBased, EdgeLength)] TESS_MODE("Tessellation Mode", Int) =  0
		[IntRange]_TessFactor("Tessellation Factor %ShowIf(TESS_MODE_DISTANCEBASED)", Range(3, 64)) =  3
		UI_TessFactorNote("> It is recommended to keep this around or below 16 for performance", Int) =  0
		UI_TessNote("> Some AMD GPUs can have issues with tessellation, be weary when using this", Int) =  0
		_TessMinDist("Start Distance %ShowIf(TESS_MODE_DISTANCEBASED)", Float) =  3
		_TessMaxDist("End Distance %ShowIf(TESS_MODE_DISTANCEBASED)", Float) =  20
		_TessEdgeLength("Max Edge Length %ShowIf(TESS_MODE_EDGELENGTH)", Float) =  80
		_TessMaxDisplacement("Max Displacement %ShowIf(TESS_MODE_EDGELENGTH)", Float) =  0.1
		UI_MaxDisplacementNote("> This defines how much you will be displacing the mesh to help with optimisations %ShowIf(TESS_MODE_EDGELENGTH)", Int) =  0
		[Toggle(PHONG)] _TessPhong("Enable Phong", Int) =  0
		UI_PhongNote("> Phong smoothes the mesh along its normals", Int) =  0

		UI_VertexHeightHeader("# Displacement", Int) =  0
		_VertexHeight("Displacement Map", 2D) =  "gray" {}
		_VertexHeightAmount("Displacement Amount", Range(0, 3)) =  0
		_VertexHeightOffset("Displacement Offset", Range(-1, 1)) =  0.5

		UI_AdvancedSettingsHeader("# Advanced Settings", Int) = 1
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("Culling Mode", Int) = 2
		[Enum(Off, 0, On, 1)]_ZWrite("Depth Write", Int) = 1
		[Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("Depth Test", Int) = 4
		UI_GSAAHeader("## GSAA", Float) = 0
		[Toggle(GSAA)]_EnableGSAA("GSAA Enabled", Int) = 1
		UI_GSAANote("> GSAA dramatically reduces specular aliasing", Int) = 0
		_GSAAVariance("GSAA Variance %ShowIf(GSAA)", Range(0, 1)) = 0.05
		_GSAAThreshold("GSAA Threshold %ShowIf(GSAA)", Range(0, 1)) = 0.1
		[Toggle(NONLINEAR_SH)]_NonlinearSH("Non-Linear Lightprobe SH", Int) = 0
		[Toggle(FORCE_BOX_PROJECTION)]_ForceBoxProjection("Force Box Projection", Int) = 0
		UI_LightmappingHeader("# Lightmapping", Int) = 1
		UI_LightmappingDocs("[This module has documentation](https://shaders.orels.sh/docs/orl-standard/base-shader#lightmapping)", Int) = 0
		_SpecOcclusion("Specular Occlusion", Range(0, 1)) = 0.75
		_SpecularRoughnessMod("Specular Roughness Mod", Range(0, 1)) = 1
		[Toggle(BICUBIC_LIGHTMAP)]_Bicubic("Bicubic Sampling", Int) = 0
		[Toggle(BAKED_SPECULAR)]_BakedSpecular("Baked Specular", Int) = 0
		UI_BakeryHeader("## Bakery Features", Int) = 0
		[Toggle(BAKERY_ENABLED)]_BakeryEnabled("Enable Bakery Features", Int) = 0
		[KeywordEnum(None, MONOSH, SH, RNM)]BAKERY("Bakery Mode %ShowIf(BAKERY_ENABLED)", Int) = 0
		[Toggle(BAKERY_SHNONLINEAR)]_BakerySHNonLinear("Bakery Non-Linear SH %ShowIf(BAKERY_ENABLED)", Int) = 1
		UI_InternalHeader("# Internal", Int) = 0
		[NonModifiableTextureData]_DFG("DFG > %RequiredTexture(@/dfg-multiscatter.exr)", 2D) = "white" {}
		_RNM0("RNM0 >", 2D) = "black" {}
		_RNM1("RNM1 >", 2D) = "black" {}
		_RNM2("RNM2 >", 2D) = "black" {}
	}
	SubShader
	{
		Tags {  }
		
		ZTest[_ZTest]
		ZWrite[_ZWrite]
		Cull[_CullMode]
		
		CGINCLUDE
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
		
		ENDCG
		
		Pass
		{
			Tags { "LightMode" = "ForwardBase"  }
			
			// ForwardBase Pass Start
			CGPROGRAM
			#pragma target 4.6
			#pragma require tesshw
			#pragma multi_compile_instancing
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			#pragma vertex Vertex
			#pragma fragment Fragment
			#pragma hull Hull
			#pragma domain Domain
			#pragma shader_feature_local _EMISSION
			
			#pragma shader_feature_local PARALLAX
			
			#pragma shader_feature_local DETAILS_OVERLAY
			#pragma shader_feature_local _ DETAILS_MODE_PACKED DETAILS_MODE_SEPARATED
			
			#pragma shader_feature_local _ TESS_MODE_DISTANCEBASED TESS_MODE_EDGELENGTH
			#pragma shader_feature_local PHONG
			
			#pragma shader_feature_local BICUBIC_LIGHTMAP
			#pragma shader_feature_local BAKED_SPECULAR
			#pragma shader_feature_local GSAA
			#pragma shader_feature_local FORCE_BOX_PROJECTION
			
			// Bakery Stuff
			#pragma shader_feature_local BAKERY_ENABLED
			#pragma shader_feature_local _ BAKERY_RNM BAKERY_SH BAKERY_MONOSH
			#pragma shader_feature_local BAKERY_SHNONLINEAR
			
			#define UNITY_INSTANCED_LOD_FADE
			#define UNITY_INSTANCED_SH
			#define UNITY_INSTANCED_LIGHTMAPSTS
			
			#ifndef UNITY_PASS_FORWARDBASE
			#define UNITY_PASS_FORWARDBASE
			#endif
			
			#if defined(SHADER_API_XBOXONE) || defined(SHADER_API_PSSL)
			#define MAX_TESSELLATION_FACTORS 15.0
			#else
			#define MAX_TESSELLATION_FACTORS 64.0
			#endif
			
			#include "UnityStandardUtils.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#include "Tessellation.cginc"
			
			#define FLT_EPSILON     1.192092896e-07
			
			#define _MASKMAP_SAMPLED
			
			#define _SET_GLOBAL_UVS
			
			#if !defined(DETAILS_MODE_PACKED) && !defined(DETAILS_MODE_SEPARATED)
			#define DETAILS_MODE_PACKED
			#endif
			
			#define TESS_FACTORS_FUNC_DEFINED
			
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
			
			#define NEED_SCREEN_POS
			
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
				half4 vertexColor;
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
				#if defined(NEED_SCREEN_POS)
				m.screenPos = i.screenPos;
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
			
			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};
			
			struct TessVertex
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 color : COLOR;
				float2 uv0 : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float2 uv2 : TEXCOORD2;
				float2 uv3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
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
			
			half3 UnpackNormalAG(half4 packedNormal, half scale = 1.0)
			{
				half3 normal;
				normal.xy = packedNormal.ag * 2.0 - 1.0;
				normal.z = max(1.0e-16, sqrt(1.0 - saturate(dot(normal.xy, normal.xy))));
				
				normal.xy *= scale;
				return normal;
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
			
			// https://assetstore.unity.com/packages/tools/level-design/bakery-gpu-lightmapper-122218
			
			#if defined(BAKERY_ENABLED)
			
			//float2 bakeryLightmapSize;
			#define BAKERYMODE_DEFAULT 0
			#define BAKERYMODE_VERTEXLM 1.0f
			#define BAKERYMODE_RNM 2.0f
			#define BAKERYMODE_SH 3.0f
			
			#define rnmBasis0 float3(0.816496580927726f, 0, 0.5773502691896258f)
			#define rnmBasis1 float3(-0.4082482904638631f, 0.7071067811865475f, 0.5773502691896258f)
			#define rnmBasis2 float3(-0.4082482904638631f, -0.7071067811865475f, 0.5773502691896258f)
			
			#if defined(BAKERY_DOMINANT)
			#undef BAKERY_RNM
			#undef BAKERY_SH
			#undef BAKERY_MONOSH
			#endif
			
			#ifdef BICUBIC_LIGHTMAP
			#define BAKERY_BICUBIC
			#endif
			
			//#define BAKERY_SSBUMP
			
			// can't fit vertexLM SH to sm3_0 interpolators
			#ifndef SHADER_API_D3D11
			#undef BAKERY_VERTEXLMSH
			#endif
			
			// can't do stuff on sm2_0 due to standard shader alrady taking up all instructions
			#if SHADER_TARGET < 30
			#undef BAKERY_BICUBIC
			#undef BAKERY_LMSPEC
			
			#undef BAKERY_RNM
			#undef BAKERY_SH
			#undef BAKERY_MONOSH
			#undef BAKERY_VERTEXLM
			#endif
			
			#if !defined(BAKERY_SH) && !defined(BAKERY_RNM)
			#undef BAKERY_BICUBIC
			#endif
			
			#ifndef UNITY_SHOULD_SAMPLE_SH
			#undef BAKERY_PROBESHNONLINEAR
			#endif
			
			#if defined(BAKERY_RNM) && defined(BAKERY_LMSPEC)
			#define BAKERY_RNMSPEC
			#endif
			
			#ifndef BAKERY_VERTEXLM
			#undef BAKERY_VERTEXLMDIR
			#undef BAKERY_VERTEXLMSH
			#undef BAKERY_VERTEXLMMASK
			#endif
			
			#define lumaConv float3(0.2125f, 0.7154f, 0.0721f)
			
			#if defined(BAKERY_SH) || defined(BAKERY_MONOSH) || defined(BAKERY_VERTEXLMSH) || defined(BAKERY_PROBESHNONLINEAR) || defined(BAKERY_VOLUME)
			float shEvaluateDiffuseL1Geomerics(float L0, float3 L1, float3 n)
			{
				// average energy
				float R0 = L0;
				
				// avg direction of incoming light
				float3 R1 = 0.5f * L1;
				
				// directional brightness
				float lenR1 = length(R1);
				
				// linear angle between normal and direction 0-1
				//float q = 0.5f * (1.0f + dot(R1 / lenR1, n));
				//float q = dot(R1 / lenR1, n) * 0.5 + 0.5;
				float q = dot(normalize(R1), n) * 0.5 + 0.5;
				
				// power for q
				// lerps from 1 (linear) to 3 (cubic) based on directionality
				float p = 1.0f + 2.0f * lenR1 / R0;
				
				// dynamic range constant
				// should vary between 4 (highly directional) and 0 (ambient)
				float a = (1.0f - lenR1 / R0) / (1.0f + lenR1 / R0);
				
				return R0 * (a + (1.0f - a) * (p + 1.0f) * pow(q, p));
			}
			#endif
			
			#ifdef BAKERY_VERTEXLM
			float4 unpack4NFloats(float src) {
				//return fmod(float4(src / 262144.0, src / 4096.0, src / 64.0, src), 64.0)/64.0;
				return frac(float4(src / (262144.0*64), src / (4096.0*64), src / (64.0*64), src));
			}
			float3 unpack3NFloats(float src) {
				float r = frac(src);
				float g = frac(src * 256.0);
				float b = frac(src * 65536.0);
				return float3(r, g, b);
			}
			#if defined(BAKERY_VERTEXLMDIR)
			
			#ifdef BAKERY_MONOSH
			void BakeryVertexLMMonoSH(inout float3 diffuseColor, inout float3 specularColor, float3 nL1, float3 normalWorld, float3 viewDir, float smoothness)
			{
				nL1 = nL1;
				float3 L0 = diffuseColor;
				float3 L1x = nL1.x * L0 * 2;
				float3 L1y = nL1.y * L0 * 2;
				float3 L1z = nL1.z * L0 * 2;
				
				float3 sh;
				#if BAKERY_SHNONLINEAR
				//sh.r = shEvaluateDiffuseL1Geomerics(L0.r, float3(L1x.r, L1y.r, L1z.r), normalWorld);
				//sh.g = shEvaluateDiffuseL1Geomerics(L0.g, float3(L1x.g, L1y.g, L1z.g), normalWorld);
				//sh.b = shEvaluateDiffuseL1Geomerics(L0.b, float3(L1x.b, L1y.b, L1z.b), normalWorld);
				
				float lumaL0 = dot(L0, 1);
				float lumaL1x = dot(L1x, 1);
				float lumaL1y = dot(L1y, 1);
				float lumaL1z = dot(L1z, 1);
				float lumaSH = shEvaluateDiffuseL1Geomerics(lumaL0, float3(lumaL1x, lumaL1y, lumaL1z), normalWorld);
				
				sh = L0 + normalWorld.x * L1x + normalWorld.y * L1y + normalWorld.z * L1z;
				float regularLumaSH = dot(sh, 1);
				//sh *= regularLumaSH < 0.001 ? 1 : (lumaSH / regularLumaSH);
				sh *= lerp(1, lumaSH / regularLumaSH, saturate(regularLumaSH*16));
				
				#else
				sh = L0 + normalWorld.x * L1x + normalWorld.y * L1y + normalWorld.z * L1z;
				#endif
				
				diffuseColor = max(sh, 0.0);
				
				#ifdef BAKERY_LMSPEC
				float3 dominantDir = nL1;
				float focus = saturate(length(dominantDir));
				half3 halfDir = Unity_SafeNormalize(normalize(dominantDir) - viewDir);
				half nh = saturate(dot(normalWorld, halfDir));
				half perceptualRoughness = SmoothnessToPerceptualRoughness(smoothness );//* sqrt(focus));
				half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
				half spec = GGXTerm(nh, roughness);
				specularColor = max(spec * sh, 0.0);
				#endif
			}
			#endif
			
			void BakeryVertexLMDirection(inout float3 diffuseColor, inout float3 specularColor, float3 lightDirection, float3 vertexNormalWorld, float3 normalWorld, float3 viewDir, float smoothness)
			{
				float3 dominantDir = Unity_SafeNormalize(lightDirection);
				half halfLambert = dot(normalWorld, dominantDir) * 0.5 + 0.5;
				half flatNormalHalfLambert = dot(vertexNormalWorld, dominantDir) * 0.5 + 0.5;
				
				#ifdef BAKERY_LMSPEC
				half3 halfDir = Unity_SafeNormalize(normalize(dominantDir) - viewDir);
				half nh = saturate(dot(normalWorld, halfDir));
				half perceptualRoughness = SmoothnessToPerceptualRoughness(smoothness);
				half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
				half spec = GGXTerm(nh, roughness);
				specularColor = spec * diffuseColor;
				#endif
				
				diffuseColor *= halfLambert / max(1e-4h, flatNormalHalfLambert);
			}
			#elif defined(BAKERY_VERTEXLMSH)
			void BakeryVertexLMSH(inout float3 diffuseColor, inout float3 specularColor, float3 shL1x, float3 shL1y, float3 shL1z, float3 normalWorld, float3 viewDir, float smoothness)
			{
				float3 L0 = diffuseColor;
				float3 nL1x = shL1x;
				float3 nL1y = shL1y;
				float3 nL1z = shL1z;
				float3 L1x = nL1x * L0 * 2;
				float3 L1y = nL1y * L0 * 2;
				float3 L1z = nL1z * L0 * 2;
				
				float3 sh;
				#ifdef BAKERY_SHNONLINEAR
				//sh.r = shEvaluateDiffuseL1Geomerics(L0.r, float3(L1x.r, L1y.r, L1z.r), normalWorld);
				//sh.g = shEvaluateDiffuseL1Geomerics(L0.g, float3(L1x.g, L1y.g, L1z.g), normalWorld);
				//sh.b = shEvaluateDiffuseL1Geomerics(L0.b, float3(L1x.b, L1y.b, L1z.b), normalWorld);
				
				float lumaL0 = dot(L0, 1);
				float lumaL1x = dot(L1x, 1);
				float lumaL1y = dot(L1y, 1);
				float lumaL1z = dot(L1z, 1);
				float lumaSH = shEvaluateDiffuseL1Geomerics(lumaL0, float3(lumaL1x, lumaL1y, lumaL1z), normalWorld);
				
				sh = L0 + normalWorld.x * L1x + normalWorld.y * L1y + normalWorld.z * L1z;
				float regularLumaSH = dot(sh, 1);
				//sh *= regularLumaSH < 0.001 ? 1 : (lumaSH / regularLumaSH);
				sh *= lerp(1, lumaSH / regularLumaSH, saturate(regularLumaSH*16));
				
				#else
				sh = L0 + normalWorld.x * L1x + normalWorld.y * L1y + normalWorld.z * L1z;
				#endif
				
				diffuseColor = max(sh, 0.0);
				
				#ifdef BAKERY_LMSPEC
				float3 dominantDir = float3(dot(nL1x, lumaConv), dot(nL1y, lumaConv), dot(nL1z, lumaConv));
				float focus = saturate(length(dominantDir));
				half3 halfDir = Unity_SafeNormalize(normalize(dominantDir) - viewDir);
				half nh = saturate(dot(normalWorld, halfDir));
				half perceptualRoughness = SmoothnessToPerceptualRoughness(smoothness );//* sqrt(focus));
				half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
				half spec = GGXTerm(nh, roughness);
				specularColor = max(spec * sh, 0.0);
				#endif
			}
			#endif
			#endif
			
			#ifdef BAKERY_BICUBIC
			float BakeryBicubic_w0(float a)
			{
				return (1.0f/6.0f)*(a*(a*(-a + 3.0f) - 3.0f) + 1.0f);
			}
			
			float BakeryBicubic_w1(float a)
			{
				return (1.0f/6.0f)*(a*a*(3.0f*a - 6.0f) + 4.0f);
			}
			
			float BakeryBicubic_w2(float a)
			{
				return (1.0f/6.0f)*(a*(a*(-3.0f*a + 3.0f) + 3.0f) + 1.0f);
			}
			
			float BakeryBicubic_w3(float a)
			{
				return (1.0f/6.0f)*(a*a*a);
			}
			
			float BakeryBicubic_g0(float a)
			{
				return BakeryBicubic_w0(a) + BakeryBicubic_w1(a);
			}
			
			float BakeryBicubic_g1(float a)
			{
				return BakeryBicubic_w2(a) + BakeryBicubic_w3(a);
			}
			
			float BakeryBicubic_h0(float a)
			{
				return -1.0f + BakeryBicubic_w1(a) / (BakeryBicubic_w0(a) + BakeryBicubic_w1(a)) + 0.5f;
			}
			
			float BakeryBicubic_h1(float a)
			{
				return 1.0f + BakeryBicubic_w3(a) / (BakeryBicubic_w2(a) + BakeryBicubic_w3(a)) + 0.5f;
			}
			#endif
			
			#if defined(BAKERY_RNM) || defined(BAKERY_SH)
			sampler2D _RNM0, _RNM1, _RNM2;
			float4 _RNM0_TexelSize;
			#endif
			
			#ifdef BAKERY_VOLUME
			Texture3D _Volume0, _Volume1, _Volume2, _VolumeMask;
			SamplerState sampler_Volume0;
			
			#ifndef PROPERTIES_DEFINED
			float3 _VolumeMin, _VolumeInvSize;
			float3 _GlobalVolumeMin, _GlobalVolumeInvSize;
			#endif
			
			#endif
			
			#ifdef BAKERY_BICUBIC
			// Bicubic
			float4 BakeryTex2D(sampler2D tex, float2 uv, float4 texelSize)
			{
				float x = uv.x * texelSize.z;
				float y = uv.y * texelSize.z;
				
				x -= 0.5f;
				y -= 0.5f;
				
				float px = floor(x);
				float py = floor(y);
				
				float fx = x - px;
				float fy = y - py;
				
				float g0x = BakeryBicubic_g0(fx);
				float g1x = BakeryBicubic_g1(fx);
				float h0x = BakeryBicubic_h0(fx);
				float h1x = BakeryBicubic_h1(fx);
				float h0y = BakeryBicubic_h0(fy);
				float h1y = BakeryBicubic_h1(fy);
				
				return     BakeryBicubic_g0(fy) * ( g0x * tex2D(tex, (float2(px + h0x, py + h0y) * texelSize.x))   +
				g1x * tex2D(tex, (float2(px + h1x, py + h0y) * texelSize.x))) +
				
				BakeryBicubic_g1(fy) * ( g0x * tex2D(tex, (float2(px + h0x, py + h1y) * texelSize.x))   +
				g1x * tex2D(tex, (float2(px + h1x, py + h1y) * texelSize.x)));
			}
			float4 BakeryTex2D(Texture2D tex, SamplerState s, float2 uv, float4 texelSize)
			{
				float x = uv.x * texelSize.z;
				float y = uv.y * texelSize.z;
				
				x -= 0.5f;
				y -= 0.5f;
				
				float px = floor(x);
				float py = floor(y);
				
				float fx = x - px;
				float fy = y - py;
				
				float g0x = BakeryBicubic_g0(fx);
				float g1x = BakeryBicubic_g1(fx);
				float h0x = BakeryBicubic_h0(fx);
				float h1x = BakeryBicubic_h1(fx);
				float h0y = BakeryBicubic_h0(fy);
				float h1y = BakeryBicubic_h1(fy);
				
				return     BakeryBicubic_g0(fy) * ( g0x * tex.Sample(s, (float2(px + h0x, py + h0y) * texelSize.x))   +
				g1x * tex.Sample(s, (float2(px + h1x, py + h0y) * texelSize.x))) +
				
				BakeryBicubic_g1(fy) * ( g0x * tex.Sample(s, (float2(px + h0x, py + h1y) * texelSize.x))   +
				g1x * tex.Sample(s, (float2(px + h1x, py + h1y) * texelSize.x)));
			}
			#else
			// Bilinear
			float4 BakeryTex2D(sampler2D tex, float2 uv, float4 texelSize)
			{
				return tex2D(tex, uv);
			}
			float4 BakeryTex2D(Texture2D tex, SamplerState s, float2 uv, float4 texelSize)
			{
				return tex.Sample(s, uv);
			}
			#endif
			
			#ifdef DIRLIGHTMAP_COMBINED
			#ifdef BAKERY_LMSPEC
			float BakeryDirectionalLightmapSpecular(float2 lmUV, float3 normalWorld, float3 viewDir, float smoothness)
			{
				float3 dominantDir = UNITY_SAMPLE_TEX2D_SAMPLER(unity_LightmapInd, unity_Lightmap, lmUV).xyz * 2 - 1;
				half3 halfDir = Unity_SafeNormalize(normalize(dominantDir) - viewDir);
				half nh = saturate(dot(normalWorld, halfDir));
				half perceptualRoughness = SmoothnessToPerceptualRoughness(smoothness);
				half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
				half spec = GGXTerm(nh, roughness);
				return spec;
			}
			#endif
			#endif
			
			#ifdef BAKERY_RNM
			void BakeryRNM(inout float3 diffuseColor, inout float3 specularColor, float2 lmUV, float3 normalMap, float perceptualRoughness, float3 viewDirT)
			{
				normalMap.g *= -1;
				float3 rnm0 = DecodeLightmap(BakeryTex2D(_RNM0, lmUV, _RNM0_TexelSize));
				float3 rnm1 = DecodeLightmap(BakeryTex2D(_RNM1, lmUV, _RNM0_TexelSize));
				float3 rnm2 = DecodeLightmap(BakeryTex2D(_RNM2, lmUV, _RNM0_TexelSize));
				
				#ifdef BAKERY_SSBUMP
				diffuseColor = normalMap.x * rnm0
				+ normalMap.z * rnm1
				+ normalMap.y * rnm2;
				diffuseColor *= 2;
				#else
				diffuseColor = saturate(dot(rnmBasis0, normalMap)) * rnm0
				+ saturate(dot(rnmBasis1, normalMap)) * rnm1
				+ saturate(dot(rnmBasis2, normalMap)) * rnm2;
				#endif
				
				#ifdef BAKERY_LMSPEC
				float3 dominantDirT = rnmBasis0 * dot(rnm0, lumaConv) +
				rnmBasis1 * dot(rnm1, lumaConv) +
				rnmBasis2 * dot(rnm2, lumaConv);
				
				float3 dominantDirTN = normalize(dominantDirT);
				float3 specColor = saturate(dot(rnmBasis0, dominantDirTN)) * rnm0 +
				saturate(dot(rnmBasis1, dominantDirTN)) * rnm1 +
				saturate(dot(rnmBasis2, dominantDirTN)) * rnm2;
				
				half3 halfDir = Unity_SafeNormalize(dominantDirTN - viewDirT);
				half nh = saturate(dot(normalMap, halfDir));
				half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
				half spec = GGXTerm(nh, roughness);
				specularColor = spec * specColor;
				#endif
			}
			#endif
			
			#ifdef BAKERY_SH
			void BakerySH(inout float3 diffuseColor, inout float3 specularColor, float2 lmUV, float3 normalWorld, float3 viewDir, float perceptualRoughness)
			{
				#ifdef SHADER_API_D3D11
				float3 L0 = DecodeLightmap(BakeryTex2D(unity_Lightmap, samplerunity_Lightmap, lmUV, _RNM0_TexelSize));
				#else
				float3 L0 = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, lmUV));
				#endif
				float3 nL1x = BakeryTex2D(_RNM0, lmUV, _RNM0_TexelSize) * 2 - 1;
				float3 nL1y = BakeryTex2D(_RNM1, lmUV, _RNM0_TexelSize) * 2 - 1;
				float3 nL1z = BakeryTex2D(_RNM2, lmUV, _RNM0_TexelSize) * 2 - 1;
				float3 L1x = nL1x * L0 * 2;
				float3 L1y = nL1y * L0 * 2;
				float3 L1z = nL1z * L0 * 2;
				
				float3 sh;
				#ifdef BAKERY_SHNONLINEAR
				float lumaL0 = dot(L0, float(1));
				float lumaL1x = dot(L1x, float(1));
				float lumaL1y = dot(L1y, float(1));
				float lumaL1z = dot(L1z, float(1));
				float lumaSH = shEvaluateDiffuseL1Geomerics(lumaL0, float3(lumaL1x, lumaL1y, lumaL1z), normalWorld);
				
				sh = L0 + normalWorld.x * L1x + normalWorld.y * L1y + normalWorld.z * L1z;
				float regularLumaSH = dot(sh, 1);
				//sh *= regularLumaSH < 0.001 ? 1 : (lumaSH / regularLumaSH);
				sh *= lerp(1, lumaSH / regularLumaSH, saturate(regularLumaSH*16));
				
				//sh.r = shEvaluateDiffuseL1Geomerics(L0.r, float3(L1x.r, L1y.r, L1z.r), normalWorld);
				//sh.g = shEvaluateDiffuseL1Geomerics(L0.g, float3(L1x.g, L1y.g, L1z.g), normalWorld);
				//sh.b = shEvaluateDiffuseL1Geomerics(L0.b, float3(L1x.b, L1y.b, L1z.b), normalWorld);
				
				#else
				sh = L0 + normalWorld.x * L1x + normalWorld.y * L1y + normalWorld.z * L1z;
				#endif
				
				diffuseColor = max(sh, 0.0);
				
				#ifdef BAKERY_LMSPEC
				float3 dominantDir = float3(dot(nL1x, lumaConv), dot(nL1y, lumaConv), dot(nL1z, lumaConv));
				float focus = saturate(length(dominantDir));
				half3 halfDir = Unity_SafeNormalize(normalize(dominantDir) - viewDir);
				half nh = saturate(dot(normalWorld, halfDir));
				half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
				half spec = GGXTerm(nh, roughness);
				
				sh = L0 + dominantDir.x * L1x + dominantDir.y * L1y + dominantDir.z * L1z;
				
				specularColor = max(spec * sh, 0.0);
				#endif
			}
			#endif
			
			#endif
			//BAKERY_ENABLED
			
			#if defined(NEED_DEPTH)
			UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
			#endif
			
			half _Smoothness;
			half _Metallic;
			half _OcclusionStrength;
			half _BumpScale;
			half _HeightScale;
			half _HeightRefPlane;
			half _HeightStepsMin;
			half _HeightStepsMax;
			half _DAlbedoScale;
			half _DNormalScale;
			half _DSmoothScale;
			half _VertexHeightAmount;
			half _VertexHeightOffset;
			half _TessFactor;
			half _TessMinDist;
			half _TessMaxDist;
			half _TessEdgeLength;
			half _TessMaxDisplacement;
			half _SpecOcclusion;
			half _SpecularRoughnessMod;
			half2 GLOBAL_uv;
			half4 _Color;
			half4 _MainTex_ST;
			half4 _MetallicRemap;
			half4 _SmoothnessRemap;
			half4 _MaskMap_TexelSize;
			half4 _EmissionColor;
			half4 GLOBAL_maskMap;
			half4 _DDetailsMap_ST;
			float _GSAAVariance;
			float _GSAAThreshold;
			int _AlbedoChannel;
			int _MappingSpace;
			int _PlanarAxisX;
			int _PlanarAxisY;
			int _MetalChannel;
			int _AOChannel;
			int _DetailMaskChannel;
			int _SmoothChannel;
			int _RoughnessMode;
			int _DetailAsTintMask;
			int _FlipBumpY;
			int _EmissionChannel;
			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);
			TEXTURE2D(_MaskMap);
			SAMPLER(sampler_MaskMap);
			TEXTURE2D(_BumpMap);
			SAMPLER(sampler_BumpMap);
			TEXTURE2D(_EmissionMap);
			SAMPLER(sampler_EmissionMap);
			TEXTURE2D(_Height);
			SAMPLER(sampler_Height);
			int _DIgnoreMask;
			int _DMappingSpace;
			int _DUVChannel;
			int _DPlanarAxisX;
			int _DPlanarAxisY;
			int _DNormalFlipY;
			TEXTURE2D(_DDetailsMap);
			SAMPLER(sampler_DDetailsMap);
			TEXTURE2D(_DDetailsNormal);
			SAMPLER(sampler_DDetailsNormal);
			TEXTURE2D(_VertexHeight);
			SAMPLER(sampler_VertexHeight);
			TEXTURE2D(_DFG);
			SAMPLER(sampler_DFG);
			
			void VHVertex() {
				half2 uv = vD.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				half height = (SAMPLE_TEXTURE2D_LOD(_VertexHeight, sampler_VertexHeight, uv, 0).r * 2 - 1);
				half3 mainOffset = vD.vertex.xyz + vD.normal * (height + _VertexHeightOffset) * _VertexHeightAmount;
				vD.vertex.xyz = mainOffset;
			}
			
			void ParallaxFragment()
			{
				GLOBAL_uv = d.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				#if PARALLAX && !defined(PLAT_QUEST)
				half customHeight = 0;
				GLOBAL_uv = POM(_Height, sampler_Height, GLOBAL_uv, ddx(GLOBAL_uv), ddy(GLOBAL_uv), d.worldNormal, d.worldSpaceViewDir, d.tangentSpaceViewDir, _HeightStepsMin, _HeightStepsMax, _HeightScale, _HeightRefPlane, half2(1, 1), half2(0, 0), 0, customHeight);
				#endif
			}
			
			void BaseFragmentFunction()
			{
				#if !defined(_SET_GLOBAL_UVS)
				GLOBAL_uv = d.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				#endif
				if (_MappingSpace > 0)
				{
					GLOBAL_uv = (_MappingSpace - 1) ? half2(d.worldSpacePosition[_PlanarAxisX], d.worldSpacePosition[_PlanarAxisY]) : half2(d.localSpacePosition[_PlanarAxisX], d.localSpacePosition[_PlanarAxisY]);
					GLOBAL_uv = GLOBAL_uv * _MainTex_ST.xy + _MainTex_ST.zw;
				}
				half4 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, GLOBAL_uv);
				if (_AlbedoChannel > 0)
				{
					albedo.rgb = albedo[_AlbedoChannel].xxx;
				}
				half4 masks = SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap, GLOBAL_uv);
				half4 normalTex = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, GLOBAL_uv);
				if (_FlipBumpY)
				{
					normalTex.y = 1 - normalTex.y;
				}
				half3 normal = UnpackScaleNormal(normalTex, _BumpScale);
				half3 emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, GLOBAL_uv).rgb;
				if (_EmissionChannel > 0)
				{
					emission.rgb = emission[_EmissionChannel].xxx;
				}
				int hasMasks = _MaskMap_TexelSize.z > 8;
				half metal = masks[_MetalChannel];
				half smooth = masks[_SmoothChannel];
				if (_RoughnessMode)
				{
					smooth = 1 - smooth;
				}
				half detailMask = masks[_DetailMaskChannel];
				half occlusion = masks[_AOChannel];
				metal = remap(metal, 0, 1, _MetallicRemap.x, _MetallicRemap.y);
				smooth = remap(smooth, 0, 1, _SmoothnessRemap.x, _SmoothnessRemap.y);
				GLOBAL_maskMap = half4(metal, occlusion, detailMask, smooth);
				o.Metallic = lerp(_Metallic, metal, hasMasks);
				o.Smoothness = lerp(_Smoothness, smooth, hasMasks);
				o.Occlusion = lerp(1, occlusion, _OcclusionStrength);
				o.Normal = normal;
				if (!_DetailAsTintMask)
				{
					o.Albedo = albedo.rgb * _Color.rgb;
				}
				else
				{
					o.Albedo = lerp(albedo, albedo.rgb * _Color.rgb, detailMask);
				}
				o.Alpha = albedo.a * _Color.a;
				#if defined(_EMISSION)
				o.Emission = emission * _EmissionColor;
				#endif
			}
			
			void DetailsFragment()
			{
				#if defined(DETAILS_OVERLAY)
				half masks = 0;
				#if defined(_MASKMAP_SAMPLED)
				masks = GLOBAL_maskMap.b;
				#else
				masks = 1;
				#endif
				half mask = lerp(masks, 1, _DIgnoreMask);
				half2 uv = d.uv0.xy;
				switch(_DUVChannel)
				{
					case 1: uv = d.uv1.xy; break;
					case 2: uv = d.uv2.xy; break;
					case 3: uv = d.uv3.xy; break;
					default: uv = d.uv0.xy; break;
				}
				uv = uv * _DDetailsMap_ST.xy + _DDetailsMap_ST.zw;
				if (_DMappingSpace > 0)
				{
					uv = (_DMappingSpace - 1) ? half2(d.worldSpacePosition[_DPlanarAxisX], d.worldSpacePosition[_DPlanarAxisY]) : half2(d.localSpacePosition[_DPlanarAxisX], d.localSpacePosition[_DPlanarAxisY]);
					uv = uv * _DDetailsMap_ST.xy + _DDetailsMap_ST.zw;
				}
				
				half4 detailsMap = SAMPLE_TEXTURE2D(_DDetailsMap, sampler_DDetailsMap, uv);
				
				#if defined(DETAILS_MODE_PACKED)
				half detailAlbedo = detailsMap.r * 2.0 - 1.0;
				half detailSmooth = detailsMap.b * 2.0 - 1.0;
				half3 detailNormal = 0;
				if (_DNormalFlipY)
				{
					detailsMap.g = 1 - detailsMap.g;
				}
				detailNormal = UnpackNormalAG(detailsMap, _DNormalScale);
				half detailAlbedoSpeed = saturate(abs(detailAlbedo) * _DAlbedoScale);
				#elif defined(DETAILS_MODE_SEPARATED)
				half3 detailAlbedo = detailsMap.rgb * 2.0 - 1.0;
				half detailSmooth = detailsMap.a * 2.0 - 1.0;
				
				half4 packedNormal = SAMPLE_TEXTURE2D(_DDetailsNormal, sampler_DDetailsNormal, uv);
				if (_DNormalFlipY)
				{
					packedNormal.g = 1 - packedNormal.g;
				}
				half3 detailNormal = UnpackScaleNormal(packedNormal, _DNormalScale);
				
				half3 detailAlbedoSpeed = saturate(abs(detailAlbedo) * _DAlbedoScale);
				#endif
				
				half3 albedoOverlay = lerp(sqrt(o.Albedo), (detailAlbedo < 0.0) ? 0.0.xxx : 1.0.xxx, detailAlbedoSpeed * detailAlbedoSpeed);
				albedoOverlay *= albedoOverlay;
				o.Albedo = lerp(o.Albedo, saturate(albedoOverlay), mask);
				
				half detailSmoothSpeed = saturate(abs(detailSmooth) * _DSmoothScale);
				half smoothOverlay = lerp(o.Smoothness, (detailSmooth < 0.0) ? 0.0 : 1.0, detailSmoothSpeed * detailSmoothSpeed);
				o.Smoothness = lerp(o.Smoothness, saturate(smoothOverlay), mask);
				
				o.Normal = lerp(o.Normal, BlendNormals(o.Normal, detailNormal), mask);
				#endif
			}
			
			void ORLLighting()
			{
				#if !defined(UNITY_PASS_SHADOWCASTER)
				half reflectance = 0.5;
				half3 f0 = 0.16 * reflectance * reflectance * (1 - o.Metallic) + o.Albedo * o.Metallic;
				half3 pixelLight = 0;
				half3 indirectDiffuse = 1;
				half3 indirectSpecular = 0;
				half3 directSpecular = 0;
				half occlusion = o.Occlusion;
				half perceptualRoughness = 1 - o.Smoothness;
				half3 tangentNormal = o.Normal;
				o.Normal = normalize(mul(o.Normal, d.TBNMatrix));
				
				#ifndef USING_DIRECTIONAL_LIGHT
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(d.worldSpacePosition));
				#else
				fixed3 lightDir = _WorldSpaceLightPos0.xyz;
				#endif
				
				#if defined(GSAA)
				perceptualRoughness = GSAA_Filament(o.Normal, perceptualRoughness, _GSAAVariance, _GSAAThreshold);
				#endif
				
				UNITY_LIGHT_ATTENUATION(lightAttenuation, FragData, d.worldSpacePosition);
				half3 lightColor = lightAttenuation * _LightColor0.rgb;
				
				half3 lightHalfVector = Unity_SafeNormalize(lightDir + d.worldSpaceViewDir);
				half lightNoL = saturate(dot(o.Normal, lightDir));
				half lightLoH = saturate(dot(lightDir, lightHalfVector));
				
				half NoV = abs(dot(o.Normal, d.worldSpaceViewDir)) + 1e-5;
				pixelLight = lightNoL * lightColor * Fd_Burley(perceptualRoughness, NoV, lightNoL, lightLoH);
				
				// READ THE LIGHTMAP
				#if defined(LIGHTMAP_ON) && !defined(UNITY_PASS_FORWARDADD)
				half3 lightMap = 0;
				half4 bakedColorTex = 0;
				half2 lightmapUV = FragData.lightmapUv.xy;
				
				// UNITY LIGHTMAPPING
				#if !defined(BAKERYLM_ENABLED) || !defined(BAKERY_ENABLED)
				lightMap = tex2DFastBicubicLightmap(lightmapUV, bakedColorTex);
				#endif
				
				// BAKERY RNM MODE (why do we even support it??)
				#if defined(BAKERY_RNM) && defined(BAKERY_ENABLED)
				half3 rnm0 = DecodeLightmap(BakeryTex2D(_RNM0, lightmapUV, _RNM0_TexelSize));
				half3 rnm1 = DecodeLightmap(BakeryTex2D(_RNM1, lightmapUV, _RNM0_TexelSize));
				half3 rnm2 = DecodeLightmap(BakeryTex2D(_RNM2, lightmapUV, _RNM0_TexelSize));
				
				lightMap = saturate(dot(rnmBasis0, tangentNormal)) * rnm0 +
				saturate(dot(rnmBasis1, tangentNormal)) * rnm1 +
				saturate(dot(rnmBasis2, tangentNormal)) * rnm2;
				#endif
				
				// BAKERY SH MODE (these are also used for the specular)
				#if defined(BAKERY_SH) && defined(BAKERY_ENABLED)
				half3 L0 = DecodeLightmap(BakeryTex2D(unity_Lightmap, samplerunity_Lightmap, lightmapUV, _RNM0_TexelSize));
				
				half3 nL1x = BakeryTex2D(_RNM0, lightmapUV, _RNM0_TexelSize) * 2.0 - 1.0;
				half3 nL1y = BakeryTex2D(_RNM1, lightmapUV, _RNM0_TexelSize) * 2.0 - 1.0;
				half3 nL1z = BakeryTex2D(_RNM2, lightmapUV, _RNM0_TexelSize) * 2.0 - 1.0;
				half3 L1x = nL1x * L0 * 2.0;
				half3 L1y = nL1y * L0 * 2.0;
				half3 L1z = nL1z * L0 * 2.0;
				
				// Non-Linear mode
				#if defined(BAKERY_SHNONLINEAR)
				half lumaL0 = dot(L0, half(1));
				half lumaL1x = dot(L1x, half(1));
				half lumaL1y = dot(L1y, half(1));
				half lumaL1z = dot(L1z, half(1));
				half lumaSH = shEvaluateDiffuseL1Geomerics_local(lumaL0, half3(lumaL1x, lumaL1y, lumaL1z), o.Normal);
				
				lightMap = L0 + o.Normal.x * L1x + o.Normal.y * L1y + o.Normal.z * L1z;
				half regularLumaSH = dot(lightMap, 1.0);
				lightMap *= lerp(1.0, lumaSH / regularLumaSH, saturate(regularLumaSH * 16.0));
				#else
				lightMap = L0 + o.Normal.x * L1x + o.Normal.y * L1y + o.Normal.z * L1z;
				#endif
				
				#endif
				
				#if defined(DIRLIGHTMAP_COMBINED)
				half4 lightMapDirection = UNITY_SAMPLE_TEX2D_SAMPLER(unity_LightmapInd, unity_Lightmap, lightmapUV);
				#if !defined(BAKERY_MONOSH)
				lightMap = DecodeDirectionalLightmap(lightMap, lightMapDirection, o.Normal);
				#endif
				#endif
				
				#if defined(BAKERY_MONOSH) && defined(BAKERY_ENABLED) && defined(DIRLIGHTMAP_COMBINED)
				half3 L0 = tex2DFastBicubicLightmap(lightmapUV, bakedColorTex);
				half3 nL1 = lightMapDirection.xyz * 2.0 - 1.0;
				half3 L1x = nL1.x * L0 * 2.0;
				half3 L1y = nL1.y * L0 * 2.0;
				half3 L1z = nL1.z * L0 * 2.0;
				
				#if defined(BAKERY_SHNONLINEAR)
				half lumaL0 = dot(L0, 1);
				half lumaL1x = dot(L1x, 1);
				half lumaL1y = dot(L1y, 1);
				half lumaL1z = dot(L1z, 1);
				half lumaSH = shEvaluateDiffuseL1Geomerics(lumaL0, half3(lumaL1x, lumaL1y, lumaL1z), o.Normal);
				
				lightMap = L0 + o.Normal.x * L1x + o.Normal.y * L1y + o.Normal.z * L1z;
				half regularLumaSH = dot(lightMap, 1);
				lightMap *= lerp(1, lumaSH / regularLumaSH, saturate(regularLumaSH*16));
				#else
				lightMap = L0 + o.Normal.x * L1x + o.Normal.y * L1y + o.Normal.z * L1z;
				#endif
				
				lightMap = max(lightMap, 0.0);
				#endif
				
				#if defined(DYNAMICLIGHTMAP_ON) && !defined(UNITY_PBS_USE_BRDF2)
				half3 realtimeLightMap = getRealtimeLightmap(FragData.lightmapUv.zw, o.Normal);
				lightMap += realtimeLightMap;
				#endif
				
				#if defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN)
				pixelLight = 0;
				lightMap = SubtractMainLightWithRealtimeAttenuationFrowmLightmap(lightMap, lightAttenuation, bakedColorTex, o.Normal);
				#endif
				indirectDiffuse = lightMap;
				#else
				#if UNITY_LIGHT_PROBE_PROXY_VOLUME
				UNITY_BRANCH
				if (unity_ProbeVolumeParams.x == 1)
				{
					indirectDiffuse = SHEvalLinearL0L1_SampleProbeVolume(half4(o.Normal, 1), FragData.worldPos);
				}
				else
				{
					#endif
					indirectDiffuse = max(0, ShadeSH9(half4(o.Normal, 1)));
					#if UNITY_LIGHT_PROBE_PROXY_VOLUME
				}
				#endif
				#endif
				
				#if defined(LIGHTMAP_SHADOW_MIXING) && defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) && defined(LIGHTMAP_ON) && !defined(UNITY_PASS_FORWARDADD)
				pixelLight *= UnityComputeForwardShadows(FragData.lightmapUv.xy, d.worldSpacePosition, d.screenPos);
				#endif
				
				half3 dfguv = half3(NoV, perceptualRoughness, 0);
				half2 dfg = SAMPLE_TEXTURE2D(_DFG, sampler_DFG, dfguv).xy;
				half3 energyCompensation = 1.0 + f0 * (1.0 / dfg.y - 1.0);
				
				half rough = perceptualRoughness * perceptualRoughness;
				half clampedRoughness = max(rough, 0.002);
				
				#if !defined(SPECULAR_HIGHLIGHTS_OFF) && defined(USING_LIGHT_MULTI_COMPILE)
				half NoH = saturate(dot(o.Normal, lightHalfVector));
				half3 F = F_Schlick(lightLoH, f0);
				half D = D_GGX(NoH, clampedRoughness);
				half V = V_SmithGGXCorrelated(NoV, lightNoL, clampedRoughness);
				
				F *= energyCompensation;
				
				directSpecular = max(0, D * V * F) * pixelLight * UNITY_PI;
				#endif
				
				// BAKED SPECULAR
				#if defined(BAKED_SPECULAR) && !defined(BAKERYLM_ENABLED) && !defined(UNITY_PASS_FORWARDADD)
				{
					half3 bakedDominantDirection = 1;
					half3 bakedSpecularColor = 0;
					
					// only do it if we have a directional lightmap
					#if defined(DIRLIGHTMAP_COMBINED) && defined(LIGHTMAP_ON)
					bakedDominantDirection = (lightMapDirection.xyz) * 2 - 1;
					half directionality = max(0.001, length(bakedDominantDirection));
					bakedDominantDirection /= directionality;
					bakedSpecularColor = indirectDiffuse;
					#endif
					
					// if we do not have lightmap - derive the specular from probes
					//#ifndef LIGHTMAP_ON
					//bakedSpecularColor = half3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);
					//bakedDominantDirection = unity_SHAr.xyz + unity_SHAg.xyz + unity_SHAb.xyz;
					// #endif
					
					bakedDominantDirection = normalize(bakedDominantDirection);
					directSpecular += GetSpecularHighlights(o.Normal, bakedSpecularColor, bakedDominantDirection, f0, d.worldSpaceViewDir, lerp(1, clampedRoughness, _SpecularRoughnessMod), NoV, energyCompensation);
				}
				#endif
				
				half3 fresnel = F_Schlick(NoV, f0);
				
				// BAKERY DIRECT SPECULAR
				#if defined(BAKERY_LMSPEC) && defined(BAKERY_ENABLED) && !defined(UNITY_PASS_FORWARDADD)
				#if defined(BAKERY_RNM)
				{
					half3 viewDirTangent = -normalize(d.tangentSpaceViewDir);
					half3 dominantDirTangent = rnmBasis0 * dot(rnm0, lumaConv) +
					rnmBasis1 * dot(rnm1, lumaConv) +
					rnmBasis2 * dot(rnm2, lumaConv);
					
					half3 dominantDirTangentNormalized = normalize(dominantDirTangent);
					half3 specColor = saturate(dot(rnmBasis0, dominantDirTangentNormalized)) * rnm0 +
					saturate(dot(rnmBasis1, dominantDirTangentNormalized)) * rnm1 +
					saturate(dot(rnmBasis2, dominantDirTangentNormalized)) * rnm2;
					half3 halfDir = Unity_SafeNormalize(dominantDirTangentNormalized - viewDirTangent);
					half NoH = saturate(dot(tangentNormal, halfDir));
					half spec = D_GGX(NoH, lerp(1, clampedRoughness, _SpecularRoughnessMod));
					directSpecular += spec * specColor * fresnel;
				}
				#endif
				
				#if defined(BAKERY_SH)
				{
					half3 dominantDir = half3(dot(nL1x, lumaConv), dot(nL1y, lumaConv), dot(L1z, lumaConv));
					half3 halfDir = Unity_SafeNormalize(normalize(dominantDir) + d.worldSpaceViewDir);
					half NoH = saturate(dot(o.Normal, halfDir));
					half spec = D_GGX(NoH, lerp(1, clampedRoughness, _SpecularRoughnessMod));
					half3 sh = L0 + dominantDir.x * L1x + dominantDir.y * L1y + dominantDir.z * L1z;
					dominantDir = normalize(dominantDir);
					directSpecular += max(spec * sh, 0.0) * fresnel;
				}
				#endif
				
				#if defined(BAKERY_MONOSH)
				{
					half3 dominantDir = nL1;
					half focus = saturate(length(dominantDir));
					half3 halfDir = Unity_SafeNormalize(normalize(dominantDir) - d.worldSpaceViewDir);
					half NoH = saturate(dot(o.Normal, halfDir));
					half spec = D_GGX(NoH, lerp(1, clampedRoughness, _SpecularRoughnessMod));
					half3 sh = L0 + dominantDir.x * L1x + dominantDir.y * L1y + dominantDir.z * L1z;
					dominantDir = normalize(dominantDir);
					directSpecular += max(spec * sh, 0.0) * fresnel;
				}
				#endif
				#endif
				
				// REFLECTIONS
				#if !defined(UNITY_PASS_FORWARDADD)
				half3 reflDir = reflect(-d.worldSpaceViewDir, o.Normal);
				reflDir = lerp(reflDir, o.Normal, rough * rough);
				
				Unity_GlossyEnvironmentData envData;
				envData.roughness = perceptualRoughness;
				envData.reflUVW = getBoxProjection(reflDir, d.worldSpacePosition.xyz, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin.xyz, unity_SpecCube0_BoxMax.xyz);
				
				half3 probe0 = Unity_GlossyEnvironment(UNITY_PASS_TEXCUBE(unity_SpecCube0), unity_SpecCube0_HDR, envData);
				indirectSpecular = probe0;
				
				#if defined(UNITY_SPECCUBE_BLENDING)
				UNITY_BRANCH
				if (unity_SpecCube0_BoxMin.w < 0.99999)
				{
					envData.reflUVW = getBoxProjection(reflDir, d.worldSpacePosition.xyz, unity_SpecCube1_ProbePosition, unity_SpecCube1_BoxMin.xyz, unity_SpecCube1_BoxMax.xyz);
					half3 probe1 = Unity_GlossyEnvironment(UNITY_PASS_TEXCUBE_SAMPLER(unity_SpecCube1, unity_SpecCube0), unity_SpecCube1_HDR, envData);
					indirectSpecular = lerp(probe1, probe0, unity_SpecCube0_BoxMin.w);
				}
				#endif
				
				half horizon = min(1 + dot(reflDir, o.Normal), 1);
				dfg.x *= saturate(pow(dot(indirectDiffuse, 1), _SpecOcclusion));
				indirectSpecular = indirectSpecular * horizon * horizon * energyCompensation * EnvBRDFMultiscatter(dfg, f0);
				
				#if defined(_MASKMAP_SAMPLED)
				indirectSpecular *= computeSpecularAO(NoV, o.Occlusion, perceptualRoughness * perceptualRoughness);
				#endif
				#endif
				
				#if defined(_INTEGRATE_CUSTOMGI) && !defined(UNITY_PASS_FORWARDADD)
				IntegrateCustomGI(d, o, indirectSpecular, indirectDiffuse);
				#endif
				
				// FINAL COLOR
				FinalColor = half4(o.Albedo.rgb * (1 - o.Metallic) * (indirectDiffuse * occlusion + (pixelLight)) + indirectSpecular + directSpecular, o.Alpha);
				
				FinalColor.rgb += o.Emission;
				#endif
			}
			
			// ForwardBase Vertex
			TessVertex Vertex(VertexData v)
			{
				UNITY_SETUP_INSTANCE_ID(v);
				TessVertex o = (TessVertex) 0;
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				
				o.vertex = v.vertex;
				o.normal = v.normal;
				o.tangent = v.tangent;
				o.color = v.color;
				o.uv0 = v.uv0;
				o.uv1 = v.uv1;
				o.uv2 = v.uv2;
				o.uv3 = v.uv3;
				
				return o;
			}
			
			// ForwardBase Hull
			[maxtessfactor(MAX_TESSELLATION_FACTORS)]
			[UNITY_domain("tri")]
			[UNITY_outputcontrolpoints(3)]
			[UNITY_outputtopology("triangle_cw")]
			[UNITY_partitioning("integer")]
			[UNITY_patchconstantfunc("TessFactorsFunction")]
			TessVertex Hull(InputPatch<TessVertex, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}
			
			float4 GetTessFactors(InputPatch<TessVertex, 3> patch)
			{
				#if defined(TESS_MODE_DISTANCEBASED)
				float4 tessFactors = UnityDistanceBasedTess(
				patch[0].vertex,
				patch[1].vertex,
				patch[2].vertex,
				_TessMinDist,
				_TessMaxDist,
				_TessFactor
				);
				return tessFactors;
				#elif defined(TESS_MODE_EDGELENGTH)
				float4 tessFactors = UnityEdgeLengthBasedTessCull(
				patch[0].vertex,
				patch[1].vertex,
				patch[2].vertex,
				_TessEdgeLength,
				_TessMaxDisplacement
				);
				return tessFactors;
				#endif
				
				return 1..xxxx;
			}
			
			// ForwardBase TessFactor
			TessellationFactors TessFactorsFunction(InputPatch<TessVertex, 3> patch)
			{
				TessellationFactors f;
				float4 TessFactorsOutput = 0;
				#if defined(TESS_FACTORS_FUNC_DEFINED)
				TessFactorsOutput = GetTessFactors(patch);
				#else
				TessFactorsOutput = 1..xxxx;
				#endif
				f.edge[0] = TessFactorsOutput.x;
				f.edge[1] = TessFactorsOutput.y;
				f.edge[2] = TessFactorsOutput.z;
				f.inside = TessFactorsOutput.w;
				return f;
			}
			
			// ForwardBase Domain
			[UNITY_domain("tri")]
			FragmentData Domain(TessellationFactors factors, OutputPatch<TessVertex, 3> patch, float3 baryCoords : SV_DomainLocation)
			{
				VertexData v = (VertexData) 0;
				UNITY_TRANSFER_INSTANCE_ID(patch[0], v);
				v.vertex = patch[0].vertex * baryCoords.x + patch[1].vertex * baryCoords.y + patch[2].vertex * baryCoords.z;
				
				#if defined(PHONG)
				float3 pp[3];
				for (int index = 0; index < 3; ++index)
				{
					pp[index] = v.vertex.xyz - patch[index].normal * (dot(v.vertex.xyz, patch[index].normal) - dot(patch[index].vertex.xyz, patch[index].normal));
				}
				v.vertex.xyz = 0.5 * (pp[0]*baryCoords.x + pp[1]*baryCoords.y + pp[2]*baryCoords.z) + (0.5) * v.vertex.xyz;
				#endif
				
				v.normal = patch[0].normal * baryCoords.x + patch[1].normal * baryCoords.y + patch[2].normal * baryCoords.z;
				v.tangent = patch[0].tangent * baryCoords.x + patch[1].tangent * baryCoords.y + patch[2].tangent * baryCoords.z;
				v.color = patch[0].color * baryCoords.x + patch[1].color * baryCoords.y + patch[2].color * baryCoords.z;
				v.uv0 = patch[0].uv0 * baryCoords.x + patch[1].uv0 * baryCoords.y + patch[2].uv0 * baryCoords.z;
				v.uv1 = patch[0].uv1 * baryCoords.x + patch[1].uv1 * baryCoords.y + patch[2].uv1 * baryCoords.z;
				v.uv2 = patch[0].uv2 * baryCoords.x + patch[1].uv2 * baryCoords.y + patch[2].uv2 * baryCoords.z;
				v.uv3 = patch[0].uv3 * baryCoords.x + patch[1].uv3 * baryCoords.y + patch[2].uv3 * baryCoords.z;
				
				FragmentData i;
				UNITY_INITIALIZE_OUTPUT(FragmentData, i);
				UNITY_TRANSFER_INSTANCE_ID(patch[0], i);
				
				vD = v;
				FragData = i;
				VHVertex();
				
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
				i.vizUV = 0;
				i.lightCoord = 0;
				if (unity_VisualizationMode == EDITORVIZ_TEXTURE)
				i.vizUV = UnityMetaVizUV(unity_EditorViz_UVIndex, v.uv0.xy, v.uv1.xy, v.uv2.xy, unity_EditorViz_Texture_ST);
				else if (unity_VisualizationMode == EDITORVIZ_SHOWLIGHTMASK)
				{
					i.vizUV = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
					i.lightCoord = mul(unity_EditorViz_WorldToLight, mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1)));
				}
				#endif
				
				#if defined(NEED_SCREEN_POS)
				i.screenPos = ComputeScreenPos(i.pos);
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
				o.Smoothness = 0.5;
				o.Occlusion = 1;
				o.Alpha = 1;
				FinalColor = half4(o.Albedo, o.Alpha);
				
				ParallaxFragment();
				BaseFragmentFunction();
				DetailsFragment();
				
				ORLLighting();
				
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
			#pragma target 4.6
			#pragma require tesshw
			#pragma multi_compile_instancing
			#pragma multi_compile_fog
			#pragma multi_compile_fwdadd_fullshadows
			#pragma vertex Vertex
			#pragma fragment Fragment
			#pragma hull Hull
			#pragma domain Domain
			
			#define UNITY_INSTANCED_LOD_FADE
			#define UNITY_INSTANCED_SH
			#define UNITY_INSTANCED_LIGHTMAPSTS
			
			#ifndef UNITY_PASS_FORWARDADD
			#define UNITY_PASS_FORWARDADD
			#endif
			
			#if defined(SHADER_API_XBOXONE) || defined(SHADER_API_PSSL)
			#define MAX_TESSELLATION_FACTORS 15.0
			#else
			#define MAX_TESSELLATION_FACTORS 64.0
			#endif
			
			#include "UnityStandardUtils.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#include "Tessellation.cginc"
			
			#define FLT_EPSILON     1.192092896e-07
			
			#define _MASKMAP_SAMPLED
			
			#define _SET_GLOBAL_UVS
			
			#if !defined(DETAILS_MODE_PACKED) && !defined(DETAILS_MODE_SEPARATED)
			#define DETAILS_MODE_PACKED
			#endif
			
			#define TESS_FACTORS_FUNC_DEFINED
			
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
			
			#define NEED_SCREEN_POS
			
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
				half4 vertexColor;
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
				#if defined(NEED_SCREEN_POS)
				m.screenPos = i.screenPos;
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
			
			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};
			
			struct TessVertex
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 color : COLOR;
				float2 uv0 : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float2 uv2 : TEXCOORD2;
				float2 uv3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
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
			
			half3 UnpackNormalAG(half4 packedNormal, half scale = 1.0)
			{
				half3 normal;
				normal.xy = packedNormal.ag * 2.0 - 1.0;
				normal.z = max(1.0e-16, sqrt(1.0 - saturate(dot(normal.xy, normal.xy))));
				
				normal.xy *= scale;
				return normal;
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
			
			// https://assetstore.unity.com/packages/tools/level-design/bakery-gpu-lightmapper-122218
			
			#if defined(BAKERY_ENABLED)
			
			//float2 bakeryLightmapSize;
			#define BAKERYMODE_DEFAULT 0
			#define BAKERYMODE_VERTEXLM 1.0f
			#define BAKERYMODE_RNM 2.0f
			#define BAKERYMODE_SH 3.0f
			
			#define rnmBasis0 float3(0.816496580927726f, 0, 0.5773502691896258f)
			#define rnmBasis1 float3(-0.4082482904638631f, 0.7071067811865475f, 0.5773502691896258f)
			#define rnmBasis2 float3(-0.4082482904638631f, -0.7071067811865475f, 0.5773502691896258f)
			
			#if defined(BAKERY_DOMINANT)
			#undef BAKERY_RNM
			#undef BAKERY_SH
			#undef BAKERY_MONOSH
			#endif
			
			#ifdef BICUBIC_LIGHTMAP
			#define BAKERY_BICUBIC
			#endif
			
			//#define BAKERY_SSBUMP
			
			// can't fit vertexLM SH to sm3_0 interpolators
			#ifndef SHADER_API_D3D11
			#undef BAKERY_VERTEXLMSH
			#endif
			
			// can't do stuff on sm2_0 due to standard shader alrady taking up all instructions
			#if SHADER_TARGET < 30
			#undef BAKERY_BICUBIC
			#undef BAKERY_LMSPEC
			
			#undef BAKERY_RNM
			#undef BAKERY_SH
			#undef BAKERY_MONOSH
			#undef BAKERY_VERTEXLM
			#endif
			
			#if !defined(BAKERY_SH) && !defined(BAKERY_RNM)
			#undef BAKERY_BICUBIC
			#endif
			
			#ifndef UNITY_SHOULD_SAMPLE_SH
			#undef BAKERY_PROBESHNONLINEAR
			#endif
			
			#if defined(BAKERY_RNM) && defined(BAKERY_LMSPEC)
			#define BAKERY_RNMSPEC
			#endif
			
			#ifndef BAKERY_VERTEXLM
			#undef BAKERY_VERTEXLMDIR
			#undef BAKERY_VERTEXLMSH
			#undef BAKERY_VERTEXLMMASK
			#endif
			
			#define lumaConv float3(0.2125f, 0.7154f, 0.0721f)
			
			#if defined(BAKERY_SH) || defined(BAKERY_MONOSH) || defined(BAKERY_VERTEXLMSH) || defined(BAKERY_PROBESHNONLINEAR) || defined(BAKERY_VOLUME)
			float shEvaluateDiffuseL1Geomerics(float L0, float3 L1, float3 n)
			{
				// average energy
				float R0 = L0;
				
				// avg direction of incoming light
				float3 R1 = 0.5f * L1;
				
				// directional brightness
				float lenR1 = length(R1);
				
				// linear angle between normal and direction 0-1
				//float q = 0.5f * (1.0f + dot(R1 / lenR1, n));
				//float q = dot(R1 / lenR1, n) * 0.5 + 0.5;
				float q = dot(normalize(R1), n) * 0.5 + 0.5;
				
				// power for q
				// lerps from 1 (linear) to 3 (cubic) based on directionality
				float p = 1.0f + 2.0f * lenR1 / R0;
				
				// dynamic range constant
				// should vary between 4 (highly directional) and 0 (ambient)
				float a = (1.0f - lenR1 / R0) / (1.0f + lenR1 / R0);
				
				return R0 * (a + (1.0f - a) * (p + 1.0f) * pow(q, p));
			}
			#endif
			
			#ifdef BAKERY_VERTEXLM
			float4 unpack4NFloats(float src) {
				//return fmod(float4(src / 262144.0, src / 4096.0, src / 64.0, src), 64.0)/64.0;
				return frac(float4(src / (262144.0*64), src / (4096.0*64), src / (64.0*64), src));
			}
			float3 unpack3NFloats(float src) {
				float r = frac(src);
				float g = frac(src * 256.0);
				float b = frac(src * 65536.0);
				return float3(r, g, b);
			}
			#if defined(BAKERY_VERTEXLMDIR)
			
			#ifdef BAKERY_MONOSH
			void BakeryVertexLMMonoSH(inout float3 diffuseColor, inout float3 specularColor, float3 nL1, float3 normalWorld, float3 viewDir, float smoothness)
			{
				nL1 = nL1;
				float3 L0 = diffuseColor;
				float3 L1x = nL1.x * L0 * 2;
				float3 L1y = nL1.y * L0 * 2;
				float3 L1z = nL1.z * L0 * 2;
				
				float3 sh;
				#if BAKERY_SHNONLINEAR
				//sh.r = shEvaluateDiffuseL1Geomerics(L0.r, float3(L1x.r, L1y.r, L1z.r), normalWorld);
				//sh.g = shEvaluateDiffuseL1Geomerics(L0.g, float3(L1x.g, L1y.g, L1z.g), normalWorld);
				//sh.b = shEvaluateDiffuseL1Geomerics(L0.b, float3(L1x.b, L1y.b, L1z.b), normalWorld);
				
				float lumaL0 = dot(L0, 1);
				float lumaL1x = dot(L1x, 1);
				float lumaL1y = dot(L1y, 1);
				float lumaL1z = dot(L1z, 1);
				float lumaSH = shEvaluateDiffuseL1Geomerics(lumaL0, float3(lumaL1x, lumaL1y, lumaL1z), normalWorld);
				
				sh = L0 + normalWorld.x * L1x + normalWorld.y * L1y + normalWorld.z * L1z;
				float regularLumaSH = dot(sh, 1);
				//sh *= regularLumaSH < 0.001 ? 1 : (lumaSH / regularLumaSH);
				sh *= lerp(1, lumaSH / regularLumaSH, saturate(regularLumaSH*16));
				
				#else
				sh = L0 + normalWorld.x * L1x + normalWorld.y * L1y + normalWorld.z * L1z;
				#endif
				
				diffuseColor = max(sh, 0.0);
				
				#ifdef BAKERY_LMSPEC
				float3 dominantDir = nL1;
				float focus = saturate(length(dominantDir));
				half3 halfDir = Unity_SafeNormalize(normalize(dominantDir) - viewDir);
				half nh = saturate(dot(normalWorld, halfDir));
				half perceptualRoughness = SmoothnessToPerceptualRoughness(smoothness );//* sqrt(focus));
				half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
				half spec = GGXTerm(nh, roughness);
				specularColor = max(spec * sh, 0.0);
				#endif
			}
			#endif
			
			void BakeryVertexLMDirection(inout float3 diffuseColor, inout float3 specularColor, float3 lightDirection, float3 vertexNormalWorld, float3 normalWorld, float3 viewDir, float smoothness)
			{
				float3 dominantDir = Unity_SafeNormalize(lightDirection);
				half halfLambert = dot(normalWorld, dominantDir) * 0.5 + 0.5;
				half flatNormalHalfLambert = dot(vertexNormalWorld, dominantDir) * 0.5 + 0.5;
				
				#ifdef BAKERY_LMSPEC
				half3 halfDir = Unity_SafeNormalize(normalize(dominantDir) - viewDir);
				half nh = saturate(dot(normalWorld, halfDir));
				half perceptualRoughness = SmoothnessToPerceptualRoughness(smoothness);
				half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
				half spec = GGXTerm(nh, roughness);
				specularColor = spec * diffuseColor;
				#endif
				
				diffuseColor *= halfLambert / max(1e-4h, flatNormalHalfLambert);
			}
			#elif defined(BAKERY_VERTEXLMSH)
			void BakeryVertexLMSH(inout float3 diffuseColor, inout float3 specularColor, float3 shL1x, float3 shL1y, float3 shL1z, float3 normalWorld, float3 viewDir, float smoothness)
			{
				float3 L0 = diffuseColor;
				float3 nL1x = shL1x;
				float3 nL1y = shL1y;
				float3 nL1z = shL1z;
				float3 L1x = nL1x * L0 * 2;
				float3 L1y = nL1y * L0 * 2;
				float3 L1z = nL1z * L0 * 2;
				
				float3 sh;
				#ifdef BAKERY_SHNONLINEAR
				//sh.r = shEvaluateDiffuseL1Geomerics(L0.r, float3(L1x.r, L1y.r, L1z.r), normalWorld);
				//sh.g = shEvaluateDiffuseL1Geomerics(L0.g, float3(L1x.g, L1y.g, L1z.g), normalWorld);
				//sh.b = shEvaluateDiffuseL1Geomerics(L0.b, float3(L1x.b, L1y.b, L1z.b), normalWorld);
				
				float lumaL0 = dot(L0, 1);
				float lumaL1x = dot(L1x, 1);
				float lumaL1y = dot(L1y, 1);
				float lumaL1z = dot(L1z, 1);
				float lumaSH = shEvaluateDiffuseL1Geomerics(lumaL0, float3(lumaL1x, lumaL1y, lumaL1z), normalWorld);
				
				sh = L0 + normalWorld.x * L1x + normalWorld.y * L1y + normalWorld.z * L1z;
				float regularLumaSH = dot(sh, 1);
				//sh *= regularLumaSH < 0.001 ? 1 : (lumaSH / regularLumaSH);
				sh *= lerp(1, lumaSH / regularLumaSH, saturate(regularLumaSH*16));
				
				#else
				sh = L0 + normalWorld.x * L1x + normalWorld.y * L1y + normalWorld.z * L1z;
				#endif
				
				diffuseColor = max(sh, 0.0);
				
				#ifdef BAKERY_LMSPEC
				float3 dominantDir = float3(dot(nL1x, lumaConv), dot(nL1y, lumaConv), dot(nL1z, lumaConv));
				float focus = saturate(length(dominantDir));
				half3 halfDir = Unity_SafeNormalize(normalize(dominantDir) - viewDir);
				half nh = saturate(dot(normalWorld, halfDir));
				half perceptualRoughness = SmoothnessToPerceptualRoughness(smoothness );//* sqrt(focus));
				half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
				half spec = GGXTerm(nh, roughness);
				specularColor = max(spec * sh, 0.0);
				#endif
			}
			#endif
			#endif
			
			#ifdef BAKERY_BICUBIC
			float BakeryBicubic_w0(float a)
			{
				return (1.0f/6.0f)*(a*(a*(-a + 3.0f) - 3.0f) + 1.0f);
			}
			
			float BakeryBicubic_w1(float a)
			{
				return (1.0f/6.0f)*(a*a*(3.0f*a - 6.0f) + 4.0f);
			}
			
			float BakeryBicubic_w2(float a)
			{
				return (1.0f/6.0f)*(a*(a*(-3.0f*a + 3.0f) + 3.0f) + 1.0f);
			}
			
			float BakeryBicubic_w3(float a)
			{
				return (1.0f/6.0f)*(a*a*a);
			}
			
			float BakeryBicubic_g0(float a)
			{
				return BakeryBicubic_w0(a) + BakeryBicubic_w1(a);
			}
			
			float BakeryBicubic_g1(float a)
			{
				return BakeryBicubic_w2(a) + BakeryBicubic_w3(a);
			}
			
			float BakeryBicubic_h0(float a)
			{
				return -1.0f + BakeryBicubic_w1(a) / (BakeryBicubic_w0(a) + BakeryBicubic_w1(a)) + 0.5f;
			}
			
			float BakeryBicubic_h1(float a)
			{
				return 1.0f + BakeryBicubic_w3(a) / (BakeryBicubic_w2(a) + BakeryBicubic_w3(a)) + 0.5f;
			}
			#endif
			
			#if defined(BAKERY_RNM) || defined(BAKERY_SH)
			sampler2D _RNM0, _RNM1, _RNM2;
			float4 _RNM0_TexelSize;
			#endif
			
			#ifdef BAKERY_VOLUME
			Texture3D _Volume0, _Volume1, _Volume2, _VolumeMask;
			SamplerState sampler_Volume0;
			
			#ifndef PROPERTIES_DEFINED
			float3 _VolumeMin, _VolumeInvSize;
			float3 _GlobalVolumeMin, _GlobalVolumeInvSize;
			#endif
			
			#endif
			
			#ifdef BAKERY_BICUBIC
			// Bicubic
			float4 BakeryTex2D(sampler2D tex, float2 uv, float4 texelSize)
			{
				float x = uv.x * texelSize.z;
				float y = uv.y * texelSize.z;
				
				x -= 0.5f;
				y -= 0.5f;
				
				float px = floor(x);
				float py = floor(y);
				
				float fx = x - px;
				float fy = y - py;
				
				float g0x = BakeryBicubic_g0(fx);
				float g1x = BakeryBicubic_g1(fx);
				float h0x = BakeryBicubic_h0(fx);
				float h1x = BakeryBicubic_h1(fx);
				float h0y = BakeryBicubic_h0(fy);
				float h1y = BakeryBicubic_h1(fy);
				
				return     BakeryBicubic_g0(fy) * ( g0x * tex2D(tex, (float2(px + h0x, py + h0y) * texelSize.x))   +
				g1x * tex2D(tex, (float2(px + h1x, py + h0y) * texelSize.x))) +
				
				BakeryBicubic_g1(fy) * ( g0x * tex2D(tex, (float2(px + h0x, py + h1y) * texelSize.x))   +
				g1x * tex2D(tex, (float2(px + h1x, py + h1y) * texelSize.x)));
			}
			float4 BakeryTex2D(Texture2D tex, SamplerState s, float2 uv, float4 texelSize)
			{
				float x = uv.x * texelSize.z;
				float y = uv.y * texelSize.z;
				
				x -= 0.5f;
				y -= 0.5f;
				
				float px = floor(x);
				float py = floor(y);
				
				float fx = x - px;
				float fy = y - py;
				
				float g0x = BakeryBicubic_g0(fx);
				float g1x = BakeryBicubic_g1(fx);
				float h0x = BakeryBicubic_h0(fx);
				float h1x = BakeryBicubic_h1(fx);
				float h0y = BakeryBicubic_h0(fy);
				float h1y = BakeryBicubic_h1(fy);
				
				return     BakeryBicubic_g0(fy) * ( g0x * tex.Sample(s, (float2(px + h0x, py + h0y) * texelSize.x))   +
				g1x * tex.Sample(s, (float2(px + h1x, py + h0y) * texelSize.x))) +
				
				BakeryBicubic_g1(fy) * ( g0x * tex.Sample(s, (float2(px + h0x, py + h1y) * texelSize.x))   +
				g1x * tex.Sample(s, (float2(px + h1x, py + h1y) * texelSize.x)));
			}
			#else
			// Bilinear
			float4 BakeryTex2D(sampler2D tex, float2 uv, float4 texelSize)
			{
				return tex2D(tex, uv);
			}
			float4 BakeryTex2D(Texture2D tex, SamplerState s, float2 uv, float4 texelSize)
			{
				return tex.Sample(s, uv);
			}
			#endif
			
			#ifdef DIRLIGHTMAP_COMBINED
			#ifdef BAKERY_LMSPEC
			float BakeryDirectionalLightmapSpecular(float2 lmUV, float3 normalWorld, float3 viewDir, float smoothness)
			{
				float3 dominantDir = UNITY_SAMPLE_TEX2D_SAMPLER(unity_LightmapInd, unity_Lightmap, lmUV).xyz * 2 - 1;
				half3 halfDir = Unity_SafeNormalize(normalize(dominantDir) - viewDir);
				half nh = saturate(dot(normalWorld, halfDir));
				half perceptualRoughness = SmoothnessToPerceptualRoughness(smoothness);
				half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
				half spec = GGXTerm(nh, roughness);
				return spec;
			}
			#endif
			#endif
			
			#ifdef BAKERY_RNM
			void BakeryRNM(inout float3 diffuseColor, inout float3 specularColor, float2 lmUV, float3 normalMap, float perceptualRoughness, float3 viewDirT)
			{
				normalMap.g *= -1;
				float3 rnm0 = DecodeLightmap(BakeryTex2D(_RNM0, lmUV, _RNM0_TexelSize));
				float3 rnm1 = DecodeLightmap(BakeryTex2D(_RNM1, lmUV, _RNM0_TexelSize));
				float3 rnm2 = DecodeLightmap(BakeryTex2D(_RNM2, lmUV, _RNM0_TexelSize));
				
				#ifdef BAKERY_SSBUMP
				diffuseColor = normalMap.x * rnm0
				+ normalMap.z * rnm1
				+ normalMap.y * rnm2;
				diffuseColor *= 2;
				#else
				diffuseColor = saturate(dot(rnmBasis0, normalMap)) * rnm0
				+ saturate(dot(rnmBasis1, normalMap)) * rnm1
				+ saturate(dot(rnmBasis2, normalMap)) * rnm2;
				#endif
				
				#ifdef BAKERY_LMSPEC
				float3 dominantDirT = rnmBasis0 * dot(rnm0, lumaConv) +
				rnmBasis1 * dot(rnm1, lumaConv) +
				rnmBasis2 * dot(rnm2, lumaConv);
				
				float3 dominantDirTN = normalize(dominantDirT);
				float3 specColor = saturate(dot(rnmBasis0, dominantDirTN)) * rnm0 +
				saturate(dot(rnmBasis1, dominantDirTN)) * rnm1 +
				saturate(dot(rnmBasis2, dominantDirTN)) * rnm2;
				
				half3 halfDir = Unity_SafeNormalize(dominantDirTN - viewDirT);
				half nh = saturate(dot(normalMap, halfDir));
				half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
				half spec = GGXTerm(nh, roughness);
				specularColor = spec * specColor;
				#endif
			}
			#endif
			
			#ifdef BAKERY_SH
			void BakerySH(inout float3 diffuseColor, inout float3 specularColor, float2 lmUV, float3 normalWorld, float3 viewDir, float perceptualRoughness)
			{
				#ifdef SHADER_API_D3D11
				float3 L0 = DecodeLightmap(BakeryTex2D(unity_Lightmap, samplerunity_Lightmap, lmUV, _RNM0_TexelSize));
				#else
				float3 L0 = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, lmUV));
				#endif
				float3 nL1x = BakeryTex2D(_RNM0, lmUV, _RNM0_TexelSize) * 2 - 1;
				float3 nL1y = BakeryTex2D(_RNM1, lmUV, _RNM0_TexelSize) * 2 - 1;
				float3 nL1z = BakeryTex2D(_RNM2, lmUV, _RNM0_TexelSize) * 2 - 1;
				float3 L1x = nL1x * L0 * 2;
				float3 L1y = nL1y * L0 * 2;
				float3 L1z = nL1z * L0 * 2;
				
				float3 sh;
				#ifdef BAKERY_SHNONLINEAR
				float lumaL0 = dot(L0, float(1));
				float lumaL1x = dot(L1x, float(1));
				float lumaL1y = dot(L1y, float(1));
				float lumaL1z = dot(L1z, float(1));
				float lumaSH = shEvaluateDiffuseL1Geomerics(lumaL0, float3(lumaL1x, lumaL1y, lumaL1z), normalWorld);
				
				sh = L0 + normalWorld.x * L1x + normalWorld.y * L1y + normalWorld.z * L1z;
				float regularLumaSH = dot(sh, 1);
				//sh *= regularLumaSH < 0.001 ? 1 : (lumaSH / regularLumaSH);
				sh *= lerp(1, lumaSH / regularLumaSH, saturate(regularLumaSH*16));
				
				//sh.r = shEvaluateDiffuseL1Geomerics(L0.r, float3(L1x.r, L1y.r, L1z.r), normalWorld);
				//sh.g = shEvaluateDiffuseL1Geomerics(L0.g, float3(L1x.g, L1y.g, L1z.g), normalWorld);
				//sh.b = shEvaluateDiffuseL1Geomerics(L0.b, float3(L1x.b, L1y.b, L1z.b), normalWorld);
				
				#else
				sh = L0 + normalWorld.x * L1x + normalWorld.y * L1y + normalWorld.z * L1z;
				#endif
				
				diffuseColor = max(sh, 0.0);
				
				#ifdef BAKERY_LMSPEC
				float3 dominantDir = float3(dot(nL1x, lumaConv), dot(nL1y, lumaConv), dot(nL1z, lumaConv));
				float focus = saturate(length(dominantDir));
				half3 halfDir = Unity_SafeNormalize(normalize(dominantDir) - viewDir);
				half nh = saturate(dot(normalWorld, halfDir));
				half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
				half spec = GGXTerm(nh, roughness);
				
				sh = L0 + dominantDir.x * L1x + dominantDir.y * L1y + dominantDir.z * L1z;
				
				specularColor = max(spec * sh, 0.0);
				#endif
			}
			#endif
			
			#endif
			//BAKERY_ENABLED
			
			#if defined(NEED_DEPTH)
			UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
			#endif
			
			half _Smoothness;
			half _Metallic;
			half _OcclusionStrength;
			half _BumpScale;
			half _HeightScale;
			half _HeightRefPlane;
			half _HeightStepsMin;
			half _HeightStepsMax;
			half _DAlbedoScale;
			half _DNormalScale;
			half _DSmoothScale;
			half _VertexHeightAmount;
			half _VertexHeightOffset;
			half _TessFactor;
			half _TessMinDist;
			half _TessMaxDist;
			half _TessEdgeLength;
			half _TessMaxDisplacement;
			half _SpecOcclusion;
			half _SpecularRoughnessMod;
			half2 GLOBAL_uv;
			half4 _Color;
			half4 _MainTex_ST;
			half4 _MetallicRemap;
			half4 _SmoothnessRemap;
			half4 _MaskMap_TexelSize;
			half4 _EmissionColor;
			half4 GLOBAL_maskMap;
			half4 _DDetailsMap_ST;
			float _GSAAVariance;
			float _GSAAThreshold;
			int _AlbedoChannel;
			int _MappingSpace;
			int _PlanarAxisX;
			int _PlanarAxisY;
			int _MetalChannel;
			int _AOChannel;
			int _DetailMaskChannel;
			int _SmoothChannel;
			int _RoughnessMode;
			int _DetailAsTintMask;
			int _FlipBumpY;
			int _EmissionChannel;
			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);
			TEXTURE2D(_MaskMap);
			SAMPLER(sampler_MaskMap);
			TEXTURE2D(_BumpMap);
			SAMPLER(sampler_BumpMap);
			TEXTURE2D(_EmissionMap);
			SAMPLER(sampler_EmissionMap);
			TEXTURE2D(_Height);
			SAMPLER(sampler_Height);
			int _DIgnoreMask;
			int _DMappingSpace;
			int _DUVChannel;
			int _DPlanarAxisX;
			int _DPlanarAxisY;
			int _DNormalFlipY;
			TEXTURE2D(_DDetailsMap);
			SAMPLER(sampler_DDetailsMap);
			TEXTURE2D(_DDetailsNormal);
			SAMPLER(sampler_DDetailsNormal);
			TEXTURE2D(_VertexHeight);
			SAMPLER(sampler_VertexHeight);
			TEXTURE2D(_DFG);
			SAMPLER(sampler_DFG);
			
			void VHVertex() {
				half2 uv = vD.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				half height = (SAMPLE_TEXTURE2D_LOD(_VertexHeight, sampler_VertexHeight, uv, 0).r * 2 - 1);
				half3 mainOffset = vD.vertex.xyz + vD.normal * (height + _VertexHeightOffset) * _VertexHeightAmount;
				vD.vertex.xyz = mainOffset;
			}
			
			void ParallaxFragment()
			{
				GLOBAL_uv = d.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				#if PARALLAX && !defined(PLAT_QUEST)
				half customHeight = 0;
				GLOBAL_uv = POM(_Height, sampler_Height, GLOBAL_uv, ddx(GLOBAL_uv), ddy(GLOBAL_uv), d.worldNormal, d.worldSpaceViewDir, d.tangentSpaceViewDir, _HeightStepsMin, _HeightStepsMax, _HeightScale, _HeightRefPlane, half2(1, 1), half2(0, 0), 0, customHeight);
				#endif
			}
			
			void BaseFragmentFunction()
			{
				#if !defined(_SET_GLOBAL_UVS)
				GLOBAL_uv = d.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				#endif
				if (_MappingSpace > 0)
				{
					GLOBAL_uv = (_MappingSpace - 1) ? half2(d.worldSpacePosition[_PlanarAxisX], d.worldSpacePosition[_PlanarAxisY]) : half2(d.localSpacePosition[_PlanarAxisX], d.localSpacePosition[_PlanarAxisY]);
					GLOBAL_uv = GLOBAL_uv * _MainTex_ST.xy + _MainTex_ST.zw;
				}
				half4 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, GLOBAL_uv);
				if (_AlbedoChannel > 0)
				{
					albedo.rgb = albedo[_AlbedoChannel].xxx;
				}
				half4 masks = SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap, GLOBAL_uv);
				half4 normalTex = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, GLOBAL_uv);
				if (_FlipBumpY)
				{
					normalTex.y = 1 - normalTex.y;
				}
				half3 normal = UnpackScaleNormal(normalTex, _BumpScale);
				half3 emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, GLOBAL_uv).rgb;
				if (_EmissionChannel > 0)
				{
					emission.rgb = emission[_EmissionChannel].xxx;
				}
				int hasMasks = _MaskMap_TexelSize.z > 8;
				half metal = masks[_MetalChannel];
				half smooth = masks[_SmoothChannel];
				if (_RoughnessMode)
				{
					smooth = 1 - smooth;
				}
				half detailMask = masks[_DetailMaskChannel];
				half occlusion = masks[_AOChannel];
				metal = remap(metal, 0, 1, _MetallicRemap.x, _MetallicRemap.y);
				smooth = remap(smooth, 0, 1, _SmoothnessRemap.x, _SmoothnessRemap.y);
				GLOBAL_maskMap = half4(metal, occlusion, detailMask, smooth);
				o.Metallic = lerp(_Metallic, metal, hasMasks);
				o.Smoothness = lerp(_Smoothness, smooth, hasMasks);
				o.Occlusion = lerp(1, occlusion, _OcclusionStrength);
				o.Normal = normal;
				if (!_DetailAsTintMask)
				{
					o.Albedo = albedo.rgb * _Color.rgb;
				}
				else
				{
					o.Albedo = lerp(albedo, albedo.rgb * _Color.rgb, detailMask);
				}
				o.Alpha = albedo.a * _Color.a;
				#if defined(_EMISSION)
				o.Emission = emission * _EmissionColor;
				#endif
			}
			
			void DetailsFragment()
			{
				#if defined(DETAILS_OVERLAY)
				half masks = 0;
				#if defined(_MASKMAP_SAMPLED)
				masks = GLOBAL_maskMap.b;
				#else
				masks = 1;
				#endif
				half mask = lerp(masks, 1, _DIgnoreMask);
				half2 uv = d.uv0.xy;
				switch(_DUVChannel)
				{
					case 1: uv = d.uv1.xy; break;
					case 2: uv = d.uv2.xy; break;
					case 3: uv = d.uv3.xy; break;
					default: uv = d.uv0.xy; break;
				}
				uv = uv * _DDetailsMap_ST.xy + _DDetailsMap_ST.zw;
				if (_DMappingSpace > 0)
				{
					uv = (_DMappingSpace - 1) ? half2(d.worldSpacePosition[_DPlanarAxisX], d.worldSpacePosition[_DPlanarAxisY]) : half2(d.localSpacePosition[_DPlanarAxisX], d.localSpacePosition[_DPlanarAxisY]);
					uv = uv * _DDetailsMap_ST.xy + _DDetailsMap_ST.zw;
				}
				
				half4 detailsMap = SAMPLE_TEXTURE2D(_DDetailsMap, sampler_DDetailsMap, uv);
				
				#if defined(DETAILS_MODE_PACKED)
				half detailAlbedo = detailsMap.r * 2.0 - 1.0;
				half detailSmooth = detailsMap.b * 2.0 - 1.0;
				half3 detailNormal = 0;
				if (_DNormalFlipY)
				{
					detailsMap.g = 1 - detailsMap.g;
				}
				detailNormal = UnpackNormalAG(detailsMap, _DNormalScale);
				half detailAlbedoSpeed = saturate(abs(detailAlbedo) * _DAlbedoScale);
				#elif defined(DETAILS_MODE_SEPARATED)
				half3 detailAlbedo = detailsMap.rgb * 2.0 - 1.0;
				half detailSmooth = detailsMap.a * 2.0 - 1.0;
				
				half4 packedNormal = SAMPLE_TEXTURE2D(_DDetailsNormal, sampler_DDetailsNormal, uv);
				if (_DNormalFlipY)
				{
					packedNormal.g = 1 - packedNormal.g;
				}
				half3 detailNormal = UnpackScaleNormal(packedNormal, _DNormalScale);
				
				half3 detailAlbedoSpeed = saturate(abs(detailAlbedo) * _DAlbedoScale);
				#endif
				
				half3 albedoOverlay = lerp(sqrt(o.Albedo), (detailAlbedo < 0.0) ? 0.0.xxx : 1.0.xxx, detailAlbedoSpeed * detailAlbedoSpeed);
				albedoOverlay *= albedoOverlay;
				o.Albedo = lerp(o.Albedo, saturate(albedoOverlay), mask);
				
				half detailSmoothSpeed = saturate(abs(detailSmooth) * _DSmoothScale);
				half smoothOverlay = lerp(o.Smoothness, (detailSmooth < 0.0) ? 0.0 : 1.0, detailSmoothSpeed * detailSmoothSpeed);
				o.Smoothness = lerp(o.Smoothness, saturate(smoothOverlay), mask);
				
				o.Normal = lerp(o.Normal, BlendNormals(o.Normal, detailNormal), mask);
				#endif
			}
			
			void ORLLighting()
			{
				#if !defined(UNITY_PASS_SHADOWCASTER)
				half reflectance = 0.5;
				half3 f0 = 0.16 * reflectance * reflectance * (1 - o.Metallic) + o.Albedo * o.Metallic;
				half3 pixelLight = 0;
				half3 indirectDiffuse = 1;
				half3 indirectSpecular = 0;
				half3 directSpecular = 0;
				half occlusion = o.Occlusion;
				half perceptualRoughness = 1 - o.Smoothness;
				half3 tangentNormal = o.Normal;
				o.Normal = normalize(mul(o.Normal, d.TBNMatrix));
				
				#ifndef USING_DIRECTIONAL_LIGHT
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(d.worldSpacePosition));
				#else
				fixed3 lightDir = _WorldSpaceLightPos0.xyz;
				#endif
				
				#if defined(GSAA)
				perceptualRoughness = GSAA_Filament(o.Normal, perceptualRoughness, _GSAAVariance, _GSAAThreshold);
				#endif
				
				UNITY_LIGHT_ATTENUATION(lightAttenuation, FragData, d.worldSpacePosition);
				half3 lightColor = lightAttenuation * _LightColor0.rgb;
				
				half3 lightHalfVector = Unity_SafeNormalize(lightDir + d.worldSpaceViewDir);
				half lightNoL = saturate(dot(o.Normal, lightDir));
				half lightLoH = saturate(dot(lightDir, lightHalfVector));
				
				half NoV = abs(dot(o.Normal, d.worldSpaceViewDir)) + 1e-5;
				pixelLight = lightNoL * lightColor * Fd_Burley(perceptualRoughness, NoV, lightNoL, lightLoH);
				
				// READ THE LIGHTMAP
				#if defined(LIGHTMAP_ON) && !defined(UNITY_PASS_FORWARDADD)
				half3 lightMap = 0;
				half4 bakedColorTex = 0;
				half2 lightmapUV = FragData.lightmapUv.xy;
				
				// UNITY LIGHTMAPPING
				#if !defined(BAKERYLM_ENABLED) || !defined(BAKERY_ENABLED)
				lightMap = tex2DFastBicubicLightmap(lightmapUV, bakedColorTex);
				#endif
				
				// BAKERY RNM MODE (why do we even support it??)
				#if defined(BAKERY_RNM) && defined(BAKERY_ENABLED)
				half3 rnm0 = DecodeLightmap(BakeryTex2D(_RNM0, lightmapUV, _RNM0_TexelSize));
				half3 rnm1 = DecodeLightmap(BakeryTex2D(_RNM1, lightmapUV, _RNM0_TexelSize));
				half3 rnm2 = DecodeLightmap(BakeryTex2D(_RNM2, lightmapUV, _RNM0_TexelSize));
				
				lightMap = saturate(dot(rnmBasis0, tangentNormal)) * rnm0 +
				saturate(dot(rnmBasis1, tangentNormal)) * rnm1 +
				saturate(dot(rnmBasis2, tangentNormal)) * rnm2;
				#endif
				
				// BAKERY SH MODE (these are also used for the specular)
				#if defined(BAKERY_SH) && defined(BAKERY_ENABLED)
				half3 L0 = DecodeLightmap(BakeryTex2D(unity_Lightmap, samplerunity_Lightmap, lightmapUV, _RNM0_TexelSize));
				
				half3 nL1x = BakeryTex2D(_RNM0, lightmapUV, _RNM0_TexelSize) * 2.0 - 1.0;
				half3 nL1y = BakeryTex2D(_RNM1, lightmapUV, _RNM0_TexelSize) * 2.0 - 1.0;
				half3 nL1z = BakeryTex2D(_RNM2, lightmapUV, _RNM0_TexelSize) * 2.0 - 1.0;
				half3 L1x = nL1x * L0 * 2.0;
				half3 L1y = nL1y * L0 * 2.0;
				half3 L1z = nL1z * L0 * 2.0;
				
				// Non-Linear mode
				#if defined(BAKERY_SHNONLINEAR)
				half lumaL0 = dot(L0, half(1));
				half lumaL1x = dot(L1x, half(1));
				half lumaL1y = dot(L1y, half(1));
				half lumaL1z = dot(L1z, half(1));
				half lumaSH = shEvaluateDiffuseL1Geomerics_local(lumaL0, half3(lumaL1x, lumaL1y, lumaL1z), o.Normal);
				
				lightMap = L0 + o.Normal.x * L1x + o.Normal.y * L1y + o.Normal.z * L1z;
				half regularLumaSH = dot(lightMap, 1.0);
				lightMap *= lerp(1.0, lumaSH / regularLumaSH, saturate(regularLumaSH * 16.0));
				#else
				lightMap = L0 + o.Normal.x * L1x + o.Normal.y * L1y + o.Normal.z * L1z;
				#endif
				
				#endif
				
				#if defined(DIRLIGHTMAP_COMBINED)
				half4 lightMapDirection = UNITY_SAMPLE_TEX2D_SAMPLER(unity_LightmapInd, unity_Lightmap, lightmapUV);
				#if !defined(BAKERY_MONOSH)
				lightMap = DecodeDirectionalLightmap(lightMap, lightMapDirection, o.Normal);
				#endif
				#endif
				
				#if defined(BAKERY_MONOSH) && defined(BAKERY_ENABLED) && defined(DIRLIGHTMAP_COMBINED)
				half3 L0 = tex2DFastBicubicLightmap(lightmapUV, bakedColorTex);
				half3 nL1 = lightMapDirection.xyz * 2.0 - 1.0;
				half3 L1x = nL1.x * L0 * 2.0;
				half3 L1y = nL1.y * L0 * 2.0;
				half3 L1z = nL1.z * L0 * 2.0;
				
				#if defined(BAKERY_SHNONLINEAR)
				half lumaL0 = dot(L0, 1);
				half lumaL1x = dot(L1x, 1);
				half lumaL1y = dot(L1y, 1);
				half lumaL1z = dot(L1z, 1);
				half lumaSH = shEvaluateDiffuseL1Geomerics(lumaL0, half3(lumaL1x, lumaL1y, lumaL1z), o.Normal);
				
				lightMap = L0 + o.Normal.x * L1x + o.Normal.y * L1y + o.Normal.z * L1z;
				half regularLumaSH = dot(lightMap, 1);
				lightMap *= lerp(1, lumaSH / regularLumaSH, saturate(regularLumaSH*16));
				#else
				lightMap = L0 + o.Normal.x * L1x + o.Normal.y * L1y + o.Normal.z * L1z;
				#endif
				
				lightMap = max(lightMap, 0.0);
				#endif
				
				#if defined(DYNAMICLIGHTMAP_ON) && !defined(UNITY_PBS_USE_BRDF2)
				half3 realtimeLightMap = getRealtimeLightmap(FragData.lightmapUv.zw, o.Normal);
				lightMap += realtimeLightMap;
				#endif
				
				#if defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN)
				pixelLight = 0;
				lightMap = SubtractMainLightWithRealtimeAttenuationFrowmLightmap(lightMap, lightAttenuation, bakedColorTex, o.Normal);
				#endif
				indirectDiffuse = lightMap;
				#else
				#if UNITY_LIGHT_PROBE_PROXY_VOLUME
				UNITY_BRANCH
				if (unity_ProbeVolumeParams.x == 1)
				{
					indirectDiffuse = SHEvalLinearL0L1_SampleProbeVolume(half4(o.Normal, 1), FragData.worldPos);
				}
				else
				{
					#endif
					indirectDiffuse = max(0, ShadeSH9(half4(o.Normal, 1)));
					#if UNITY_LIGHT_PROBE_PROXY_VOLUME
				}
				#endif
				#endif
				
				#if defined(LIGHTMAP_SHADOW_MIXING) && defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) && defined(LIGHTMAP_ON) && !defined(UNITY_PASS_FORWARDADD)
				pixelLight *= UnityComputeForwardShadows(FragData.lightmapUv.xy, d.worldSpacePosition, d.screenPos);
				#endif
				
				half3 dfguv = half3(NoV, perceptualRoughness, 0);
				half2 dfg = SAMPLE_TEXTURE2D(_DFG, sampler_DFG, dfguv).xy;
				half3 energyCompensation = 1.0 + f0 * (1.0 / dfg.y - 1.0);
				
				half rough = perceptualRoughness * perceptualRoughness;
				half clampedRoughness = max(rough, 0.002);
				
				#if !defined(SPECULAR_HIGHLIGHTS_OFF) && defined(USING_LIGHT_MULTI_COMPILE)
				half NoH = saturate(dot(o.Normal, lightHalfVector));
				half3 F = F_Schlick(lightLoH, f0);
				half D = D_GGX(NoH, clampedRoughness);
				half V = V_SmithGGXCorrelated(NoV, lightNoL, clampedRoughness);
				
				F *= energyCompensation;
				
				directSpecular = max(0, D * V * F) * pixelLight * UNITY_PI;
				#endif
				
				// BAKED SPECULAR
				#if defined(BAKED_SPECULAR) && !defined(BAKERYLM_ENABLED) && !defined(UNITY_PASS_FORWARDADD)
				{
					half3 bakedDominantDirection = 1;
					half3 bakedSpecularColor = 0;
					
					// only do it if we have a directional lightmap
					#if defined(DIRLIGHTMAP_COMBINED) && defined(LIGHTMAP_ON)
					bakedDominantDirection = (lightMapDirection.xyz) * 2 - 1;
					half directionality = max(0.001, length(bakedDominantDirection));
					bakedDominantDirection /= directionality;
					bakedSpecularColor = indirectDiffuse;
					#endif
					
					// if we do not have lightmap - derive the specular from probes
					//#ifndef LIGHTMAP_ON
					//bakedSpecularColor = half3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);
					//bakedDominantDirection = unity_SHAr.xyz + unity_SHAg.xyz + unity_SHAb.xyz;
					// #endif
					
					bakedDominantDirection = normalize(bakedDominantDirection);
					directSpecular += GetSpecularHighlights(o.Normal, bakedSpecularColor, bakedDominantDirection, f0, d.worldSpaceViewDir, lerp(1, clampedRoughness, _SpecularRoughnessMod), NoV, energyCompensation);
				}
				#endif
				
				half3 fresnel = F_Schlick(NoV, f0);
				
				// BAKERY DIRECT SPECULAR
				#if defined(BAKERY_LMSPEC) && defined(BAKERY_ENABLED) && !defined(UNITY_PASS_FORWARDADD)
				#if defined(BAKERY_RNM)
				{
					half3 viewDirTangent = -normalize(d.tangentSpaceViewDir);
					half3 dominantDirTangent = rnmBasis0 * dot(rnm0, lumaConv) +
					rnmBasis1 * dot(rnm1, lumaConv) +
					rnmBasis2 * dot(rnm2, lumaConv);
					
					half3 dominantDirTangentNormalized = normalize(dominantDirTangent);
					half3 specColor = saturate(dot(rnmBasis0, dominantDirTangentNormalized)) * rnm0 +
					saturate(dot(rnmBasis1, dominantDirTangentNormalized)) * rnm1 +
					saturate(dot(rnmBasis2, dominantDirTangentNormalized)) * rnm2;
					half3 halfDir = Unity_SafeNormalize(dominantDirTangentNormalized - viewDirTangent);
					half NoH = saturate(dot(tangentNormal, halfDir));
					half spec = D_GGX(NoH, lerp(1, clampedRoughness, _SpecularRoughnessMod));
					directSpecular += spec * specColor * fresnel;
				}
				#endif
				
				#if defined(BAKERY_SH)
				{
					half3 dominantDir = half3(dot(nL1x, lumaConv), dot(nL1y, lumaConv), dot(L1z, lumaConv));
					half3 halfDir = Unity_SafeNormalize(normalize(dominantDir) + d.worldSpaceViewDir);
					half NoH = saturate(dot(o.Normal, halfDir));
					half spec = D_GGX(NoH, lerp(1, clampedRoughness, _SpecularRoughnessMod));
					half3 sh = L0 + dominantDir.x * L1x + dominantDir.y * L1y + dominantDir.z * L1z;
					dominantDir = normalize(dominantDir);
					directSpecular += max(spec * sh, 0.0) * fresnel;
				}
				#endif
				
				#if defined(BAKERY_MONOSH)
				{
					half3 dominantDir = nL1;
					half focus = saturate(length(dominantDir));
					half3 halfDir = Unity_SafeNormalize(normalize(dominantDir) - d.worldSpaceViewDir);
					half NoH = saturate(dot(o.Normal, halfDir));
					half spec = D_GGX(NoH, lerp(1, clampedRoughness, _SpecularRoughnessMod));
					half3 sh = L0 + dominantDir.x * L1x + dominantDir.y * L1y + dominantDir.z * L1z;
					dominantDir = normalize(dominantDir);
					directSpecular += max(spec * sh, 0.0) * fresnel;
				}
				#endif
				#endif
				
				// REFLECTIONS
				#if !defined(UNITY_PASS_FORWARDADD)
				half3 reflDir = reflect(-d.worldSpaceViewDir, o.Normal);
				reflDir = lerp(reflDir, o.Normal, rough * rough);
				
				Unity_GlossyEnvironmentData envData;
				envData.roughness = perceptualRoughness;
				envData.reflUVW = getBoxProjection(reflDir, d.worldSpacePosition.xyz, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin.xyz, unity_SpecCube0_BoxMax.xyz);
				
				half3 probe0 = Unity_GlossyEnvironment(UNITY_PASS_TEXCUBE(unity_SpecCube0), unity_SpecCube0_HDR, envData);
				indirectSpecular = probe0;
				
				#if defined(UNITY_SPECCUBE_BLENDING)
				UNITY_BRANCH
				if (unity_SpecCube0_BoxMin.w < 0.99999)
				{
					envData.reflUVW = getBoxProjection(reflDir, d.worldSpacePosition.xyz, unity_SpecCube1_ProbePosition, unity_SpecCube1_BoxMin.xyz, unity_SpecCube1_BoxMax.xyz);
					half3 probe1 = Unity_GlossyEnvironment(UNITY_PASS_TEXCUBE_SAMPLER(unity_SpecCube1, unity_SpecCube0), unity_SpecCube1_HDR, envData);
					indirectSpecular = lerp(probe1, probe0, unity_SpecCube0_BoxMin.w);
				}
				#endif
				
				half horizon = min(1 + dot(reflDir, o.Normal), 1);
				dfg.x *= saturate(pow(dot(indirectDiffuse, 1), _SpecOcclusion));
				indirectSpecular = indirectSpecular * horizon * horizon * energyCompensation * EnvBRDFMultiscatter(dfg, f0);
				
				#if defined(_MASKMAP_SAMPLED)
				indirectSpecular *= computeSpecularAO(NoV, o.Occlusion, perceptualRoughness * perceptualRoughness);
				#endif
				#endif
				
				#if defined(_INTEGRATE_CUSTOMGI) && !defined(UNITY_PASS_FORWARDADD)
				IntegrateCustomGI(d, o, indirectSpecular, indirectDiffuse);
				#endif
				
				// FINAL COLOR
				FinalColor = half4(o.Albedo.rgb * (1 - o.Metallic) * (indirectDiffuse * occlusion + (pixelLight)) + indirectSpecular + directSpecular, o.Alpha);
				
				FinalColor.rgb += o.Emission;
				#endif
			}
			
			// ForwardAdd Vertex
			TessVertex Vertex(VertexData v)
			{
				UNITY_SETUP_INSTANCE_ID(v);
				TessVertex o = (TessVertex) 0;
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				
				o.vertex = v.vertex;
				o.normal = v.normal;
				o.tangent = v.tangent;
				o.color = v.color;
				o.uv0 = v.uv0;
				o.uv1 = v.uv1;
				o.uv2 = v.uv2;
				o.uv3 = v.uv3;
				
				return o;
			}
			
			// ForwardAdd Hull
			[maxtessfactor(MAX_TESSELLATION_FACTORS)]
			[UNITY_domain("tri")]
			[UNITY_outputcontrolpoints(3)]
			[UNITY_outputtopology("triangle_cw")]
			[UNITY_partitioning("integer")]
			[UNITY_patchconstantfunc("TessFactorsFunction")]
			TessVertex Hull(InputPatch<TessVertex, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}
			
			float4 GetTessFactors(InputPatch<TessVertex, 3> patch)
			{
				#if defined(TESS_MODE_DISTANCEBASED)
				float4 tessFactors = UnityDistanceBasedTess(
				patch[0].vertex,
				patch[1].vertex,
				patch[2].vertex,
				_TessMinDist,
				_TessMaxDist,
				_TessFactor
				);
				return tessFactors;
				#elif defined(TESS_MODE_EDGELENGTH)
				float4 tessFactors = UnityEdgeLengthBasedTessCull(
				patch[0].vertex,
				patch[1].vertex,
				patch[2].vertex,
				_TessEdgeLength,
				_TessMaxDisplacement
				);
				return tessFactors;
				#endif
				
				return 1..xxxx;
			}
			
			// ForwardAdd TessFactor
			TessellationFactors TessFactorsFunction(InputPatch<TessVertex, 3> patch)
			{
				TessellationFactors f;
				float4 TessFactorsOutput = 0;
				#if defined(TESS_FACTORS_FUNC_DEFINED)
				TessFactorsOutput = GetTessFactors(patch);
				#else
				TessFactorsOutput = 1..xxxx;
				#endif
				f.edge[0] = TessFactorsOutput.x;
				f.edge[1] = TessFactorsOutput.y;
				f.edge[2] = TessFactorsOutput.z;
				f.inside = TessFactorsOutput.w;
				return f;
			}
			
			// ForwardAdd Domain
			[UNITY_domain("tri")]
			FragmentData Domain(TessellationFactors factors, OutputPatch<TessVertex, 3> patch, float3 baryCoords : SV_DomainLocation)
			{
				VertexData v = (VertexData) 0;
				UNITY_TRANSFER_INSTANCE_ID(patch[0], v);
				v.vertex = patch[0].vertex * baryCoords.x + patch[1].vertex * baryCoords.y + patch[2].vertex * baryCoords.z;
				
				#if defined(PHONG)
				float3 pp[3];
				for (int index = 0; index < 3; ++index)
				{
					pp[index] = v.vertex.xyz - patch[index].normal * (dot(v.vertex.xyz, patch[index].normal) - dot(patch[index].vertex.xyz, patch[index].normal));
				}
				v.vertex.xyz = 0.5 * (pp[0]*baryCoords.x + pp[1]*baryCoords.y + pp[2]*baryCoords.z) + (0.5) * v.vertex.xyz;
				#endif
				
				v.normal = patch[0].normal * baryCoords.x + patch[1].normal * baryCoords.y + patch[2].normal * baryCoords.z;
				v.tangent = patch[0].tangent * baryCoords.x + patch[1].tangent * baryCoords.y + patch[2].tangent * baryCoords.z;
				v.color = patch[0].color * baryCoords.x + patch[1].color * baryCoords.y + patch[2].color * baryCoords.z;
				v.uv0 = patch[0].uv0 * baryCoords.x + patch[1].uv0 * baryCoords.y + patch[2].uv0 * baryCoords.z;
				v.uv1 = patch[0].uv1 * baryCoords.x + patch[1].uv1 * baryCoords.y + patch[2].uv1 * baryCoords.z;
				v.uv2 = patch[0].uv2 * baryCoords.x + patch[1].uv2 * baryCoords.y + patch[2].uv2 * baryCoords.z;
				v.uv3 = patch[0].uv3 * baryCoords.x + patch[1].uv3 * baryCoords.y + patch[2].uv3 * baryCoords.z;
				
				FragmentData i;
				UNITY_INITIALIZE_OUTPUT(FragmentData, i);
				UNITY_TRANSFER_INSTANCE_ID(patch[0], i);
				
				vD = v;
				FragData = i;
				VHVertex();
				
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
				i.vizUV = 0;
				i.lightCoord = 0;
				if (unity_VisualizationMode == EDITORVIZ_TEXTURE)
				i.vizUV = UnityMetaVizUV(unity_EditorViz_UVIndex, v.uv0.xy, v.uv1.xy, v.uv2.xy, unity_EditorViz_Texture_ST);
				else if (unity_VisualizationMode == EDITORVIZ_SHOWLIGHTMASK)
				{
					i.vizUV = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
					i.lightCoord = mul(unity_EditorViz_WorldToLight, mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1)));
				}
				#endif
				
				#if defined(NEED_SCREEN_POS)
				i.screenPos = ComputeScreenPos(i.pos);
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
				o.Smoothness = 0.5;
				o.Occlusion = 1;
				o.Alpha = 1;
				FinalColor = half4(o.Albedo, o.Alpha);
				
				ParallaxFragment();
				BaseFragmentFunction();
				DetailsFragment();
				
				ORLLighting();
				
				UNITY_APPLY_FOG(_unity_fogCoord, FinalColor);
				
				return FinalColor;
			}
			
			ENDCG
			// ForwardAdd Pass End
			
		}
		
		Pass
		{
			Name "META"
			Tags { "LightMode" = "Meta" }
			Cull Off
			
			// Meta Pass Start
			CGPROGRAM
			#pragma target 4.6
			#pragma require tesshw
			#pragma multi_compile_instancing
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#pragma shader_feature EDITOR_VISUALISATION
			#pragma vertex Vertex
			#pragma fragment Fragment
			#pragma hull Hull
			#pragma domain Domain
			
			#define UNITY_INSTANCED_LOD_FADE
			#define UNITY_INSTANCED_SH
			#define UNITY_INSTANCED_LIGHTMAPSTS
			
			#ifndef UNITY_PASS_META
			#define UNITY_PASS_META
			#endif
			
			#if defined(SHADER_API_XBOXONE) || defined(SHADER_API_PSSL)
			#define MAX_TESSELLATION_FACTORS 15.0
			#else
			#define MAX_TESSELLATION_FACTORS 64.0
			#endif
			
			#include "UnityStandardUtils.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#include "Tessellation.cginc"
			#include "UnityPBSLighting.cginc"
			#include "UnityMetaPass.cginc"
			
			#define FLT_EPSILON     1.192092896e-07
			
			#define _MASKMAP_SAMPLED
			
			#define _SET_GLOBAL_UVS
			
			#if !defined(DETAILS_MODE_PACKED) && !defined(DETAILS_MODE_SEPARATED)
			#define DETAILS_MODE_PACKED
			#endif
			
			#define TESS_FACTORS_FUNC_DEFINED
			
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
			
			#define NEED_SCREEN_POS
			
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
				half4 vertexColor;
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
				#if defined(NEED_SCREEN_POS)
				m.screenPos = i.screenPos;
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
			
			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};
			
			struct TessVertex
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 color : COLOR;
				float2 uv0 : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float2 uv2 : TEXCOORD2;
				float2 uv3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
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
			
			half3 UnpackNormalAG(half4 packedNormal, half scale = 1.0)
			{
				half3 normal;
				normal.xy = packedNormal.ag * 2.0 - 1.0;
				normal.z = max(1.0e-16, sqrt(1.0 - saturate(dot(normal.xy, normal.xy))));
				
				normal.xy *= scale;
				return normal;
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
			
			// https://assetstore.unity.com/packages/tools/level-design/bakery-gpu-lightmapper-122218
			
			#if defined(BAKERY_ENABLED)
			
			//float2 bakeryLightmapSize;
			#define BAKERYMODE_DEFAULT 0
			#define BAKERYMODE_VERTEXLM 1.0f
			#define BAKERYMODE_RNM 2.0f
			#define BAKERYMODE_SH 3.0f
			
			#define rnmBasis0 float3(0.816496580927726f, 0, 0.5773502691896258f)
			#define rnmBasis1 float3(-0.4082482904638631f, 0.7071067811865475f, 0.5773502691896258f)
			#define rnmBasis2 float3(-0.4082482904638631f, -0.7071067811865475f, 0.5773502691896258f)
			
			#if defined(BAKERY_DOMINANT)
			#undef BAKERY_RNM
			#undef BAKERY_SH
			#undef BAKERY_MONOSH
			#endif
			
			#ifdef BICUBIC_LIGHTMAP
			#define BAKERY_BICUBIC
			#endif
			
			//#define BAKERY_SSBUMP
			
			// can't fit vertexLM SH to sm3_0 interpolators
			#ifndef SHADER_API_D3D11
			#undef BAKERY_VERTEXLMSH
			#endif
			
			// can't do stuff on sm2_0 due to standard shader alrady taking up all instructions
			#if SHADER_TARGET < 30
			#undef BAKERY_BICUBIC
			#undef BAKERY_LMSPEC
			
			#undef BAKERY_RNM
			#undef BAKERY_SH
			#undef BAKERY_MONOSH
			#undef BAKERY_VERTEXLM
			#endif
			
			#if !defined(BAKERY_SH) && !defined(BAKERY_RNM)
			#undef BAKERY_BICUBIC
			#endif
			
			#ifndef UNITY_SHOULD_SAMPLE_SH
			#undef BAKERY_PROBESHNONLINEAR
			#endif
			
			#if defined(BAKERY_RNM) && defined(BAKERY_LMSPEC)
			#define BAKERY_RNMSPEC
			#endif
			
			#ifndef BAKERY_VERTEXLM
			#undef BAKERY_VERTEXLMDIR
			#undef BAKERY_VERTEXLMSH
			#undef BAKERY_VERTEXLMMASK
			#endif
			
			#define lumaConv float3(0.2125f, 0.7154f, 0.0721f)
			
			#if defined(BAKERY_SH) || defined(BAKERY_MONOSH) || defined(BAKERY_VERTEXLMSH) || defined(BAKERY_PROBESHNONLINEAR) || defined(BAKERY_VOLUME)
			float shEvaluateDiffuseL1Geomerics(float L0, float3 L1, float3 n)
			{
				// average energy
				float R0 = L0;
				
				// avg direction of incoming light
				float3 R1 = 0.5f * L1;
				
				// directional brightness
				float lenR1 = length(R1);
				
				// linear angle between normal and direction 0-1
				//float q = 0.5f * (1.0f + dot(R1 / lenR1, n));
				//float q = dot(R1 / lenR1, n) * 0.5 + 0.5;
				float q = dot(normalize(R1), n) * 0.5 + 0.5;
				
				// power for q
				// lerps from 1 (linear) to 3 (cubic) based on directionality
				float p = 1.0f + 2.0f * lenR1 / R0;
				
				// dynamic range constant
				// should vary between 4 (highly directional) and 0 (ambient)
				float a = (1.0f - lenR1 / R0) / (1.0f + lenR1 / R0);
				
				return R0 * (a + (1.0f - a) * (p + 1.0f) * pow(q, p));
			}
			#endif
			
			#ifdef BAKERY_VERTEXLM
			float4 unpack4NFloats(float src) {
				//return fmod(float4(src / 262144.0, src / 4096.0, src / 64.0, src), 64.0)/64.0;
				return frac(float4(src / (262144.0*64), src / (4096.0*64), src / (64.0*64), src));
			}
			float3 unpack3NFloats(float src) {
				float r = frac(src);
				float g = frac(src * 256.0);
				float b = frac(src * 65536.0);
				return float3(r, g, b);
			}
			#if defined(BAKERY_VERTEXLMDIR)
			
			#ifdef BAKERY_MONOSH
			void BakeryVertexLMMonoSH(inout float3 diffuseColor, inout float3 specularColor, float3 nL1, float3 normalWorld, float3 viewDir, float smoothness)
			{
				nL1 = nL1;
				float3 L0 = diffuseColor;
				float3 L1x = nL1.x * L0 * 2;
				float3 L1y = nL1.y * L0 * 2;
				float3 L1z = nL1.z * L0 * 2;
				
				float3 sh;
				#if BAKERY_SHNONLINEAR
				//sh.r = shEvaluateDiffuseL1Geomerics(L0.r, float3(L1x.r, L1y.r, L1z.r), normalWorld);
				//sh.g = shEvaluateDiffuseL1Geomerics(L0.g, float3(L1x.g, L1y.g, L1z.g), normalWorld);
				//sh.b = shEvaluateDiffuseL1Geomerics(L0.b, float3(L1x.b, L1y.b, L1z.b), normalWorld);
				
				float lumaL0 = dot(L0, 1);
				float lumaL1x = dot(L1x, 1);
				float lumaL1y = dot(L1y, 1);
				float lumaL1z = dot(L1z, 1);
				float lumaSH = shEvaluateDiffuseL1Geomerics(lumaL0, float3(lumaL1x, lumaL1y, lumaL1z), normalWorld);
				
				sh = L0 + normalWorld.x * L1x + normalWorld.y * L1y + normalWorld.z * L1z;
				float regularLumaSH = dot(sh, 1);
				//sh *= regularLumaSH < 0.001 ? 1 : (lumaSH / regularLumaSH);
				sh *= lerp(1, lumaSH / regularLumaSH, saturate(regularLumaSH*16));
				
				#else
				sh = L0 + normalWorld.x * L1x + normalWorld.y * L1y + normalWorld.z * L1z;
				#endif
				
				diffuseColor = max(sh, 0.0);
				
				#ifdef BAKERY_LMSPEC
				float3 dominantDir = nL1;
				float focus = saturate(length(dominantDir));
				half3 halfDir = Unity_SafeNormalize(normalize(dominantDir) - viewDir);
				half nh = saturate(dot(normalWorld, halfDir));
				half perceptualRoughness = SmoothnessToPerceptualRoughness(smoothness );//* sqrt(focus));
				half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
				half spec = GGXTerm(nh, roughness);
				specularColor = max(spec * sh, 0.0);
				#endif
			}
			#endif
			
			void BakeryVertexLMDirection(inout float3 diffuseColor, inout float3 specularColor, float3 lightDirection, float3 vertexNormalWorld, float3 normalWorld, float3 viewDir, float smoothness)
			{
				float3 dominantDir = Unity_SafeNormalize(lightDirection);
				half halfLambert = dot(normalWorld, dominantDir) * 0.5 + 0.5;
				half flatNormalHalfLambert = dot(vertexNormalWorld, dominantDir) * 0.5 + 0.5;
				
				#ifdef BAKERY_LMSPEC
				half3 halfDir = Unity_SafeNormalize(normalize(dominantDir) - viewDir);
				half nh = saturate(dot(normalWorld, halfDir));
				half perceptualRoughness = SmoothnessToPerceptualRoughness(smoothness);
				half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
				half spec = GGXTerm(nh, roughness);
				specularColor = spec * diffuseColor;
				#endif
				
				diffuseColor *= halfLambert / max(1e-4h, flatNormalHalfLambert);
			}
			#elif defined(BAKERY_VERTEXLMSH)
			void BakeryVertexLMSH(inout float3 diffuseColor, inout float3 specularColor, float3 shL1x, float3 shL1y, float3 shL1z, float3 normalWorld, float3 viewDir, float smoothness)
			{
				float3 L0 = diffuseColor;
				float3 nL1x = shL1x;
				float3 nL1y = shL1y;
				float3 nL1z = shL1z;
				float3 L1x = nL1x * L0 * 2;
				float3 L1y = nL1y * L0 * 2;
				float3 L1z = nL1z * L0 * 2;
				
				float3 sh;
				#ifdef BAKERY_SHNONLINEAR
				//sh.r = shEvaluateDiffuseL1Geomerics(L0.r, float3(L1x.r, L1y.r, L1z.r), normalWorld);
				//sh.g = shEvaluateDiffuseL1Geomerics(L0.g, float3(L1x.g, L1y.g, L1z.g), normalWorld);
				//sh.b = shEvaluateDiffuseL1Geomerics(L0.b, float3(L1x.b, L1y.b, L1z.b), normalWorld);
				
				float lumaL0 = dot(L0, 1);
				float lumaL1x = dot(L1x, 1);
				float lumaL1y = dot(L1y, 1);
				float lumaL1z = dot(L1z, 1);
				float lumaSH = shEvaluateDiffuseL1Geomerics(lumaL0, float3(lumaL1x, lumaL1y, lumaL1z), normalWorld);
				
				sh = L0 + normalWorld.x * L1x + normalWorld.y * L1y + normalWorld.z * L1z;
				float regularLumaSH = dot(sh, 1);
				//sh *= regularLumaSH < 0.001 ? 1 : (lumaSH / regularLumaSH);
				sh *= lerp(1, lumaSH / regularLumaSH, saturate(regularLumaSH*16));
				
				#else
				sh = L0 + normalWorld.x * L1x + normalWorld.y * L1y + normalWorld.z * L1z;
				#endif
				
				diffuseColor = max(sh, 0.0);
				
				#ifdef BAKERY_LMSPEC
				float3 dominantDir = float3(dot(nL1x, lumaConv), dot(nL1y, lumaConv), dot(nL1z, lumaConv));
				float focus = saturate(length(dominantDir));
				half3 halfDir = Unity_SafeNormalize(normalize(dominantDir) - viewDir);
				half nh = saturate(dot(normalWorld, halfDir));
				half perceptualRoughness = SmoothnessToPerceptualRoughness(smoothness );//* sqrt(focus));
				half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
				half spec = GGXTerm(nh, roughness);
				specularColor = max(spec * sh, 0.0);
				#endif
			}
			#endif
			#endif
			
			#ifdef BAKERY_BICUBIC
			float BakeryBicubic_w0(float a)
			{
				return (1.0f/6.0f)*(a*(a*(-a + 3.0f) - 3.0f) + 1.0f);
			}
			
			float BakeryBicubic_w1(float a)
			{
				return (1.0f/6.0f)*(a*a*(3.0f*a - 6.0f) + 4.0f);
			}
			
			float BakeryBicubic_w2(float a)
			{
				return (1.0f/6.0f)*(a*(a*(-3.0f*a + 3.0f) + 3.0f) + 1.0f);
			}
			
			float BakeryBicubic_w3(float a)
			{
				return (1.0f/6.0f)*(a*a*a);
			}
			
			float BakeryBicubic_g0(float a)
			{
				return BakeryBicubic_w0(a) + BakeryBicubic_w1(a);
			}
			
			float BakeryBicubic_g1(float a)
			{
				return BakeryBicubic_w2(a) + BakeryBicubic_w3(a);
			}
			
			float BakeryBicubic_h0(float a)
			{
				return -1.0f + BakeryBicubic_w1(a) / (BakeryBicubic_w0(a) + BakeryBicubic_w1(a)) + 0.5f;
			}
			
			float BakeryBicubic_h1(float a)
			{
				return 1.0f + BakeryBicubic_w3(a) / (BakeryBicubic_w2(a) + BakeryBicubic_w3(a)) + 0.5f;
			}
			#endif
			
			#if defined(BAKERY_RNM) || defined(BAKERY_SH)
			sampler2D _RNM0, _RNM1, _RNM2;
			float4 _RNM0_TexelSize;
			#endif
			
			#ifdef BAKERY_VOLUME
			Texture3D _Volume0, _Volume1, _Volume2, _VolumeMask;
			SamplerState sampler_Volume0;
			
			#ifndef PROPERTIES_DEFINED
			float3 _VolumeMin, _VolumeInvSize;
			float3 _GlobalVolumeMin, _GlobalVolumeInvSize;
			#endif
			
			#endif
			
			#ifdef BAKERY_BICUBIC
			// Bicubic
			float4 BakeryTex2D(sampler2D tex, float2 uv, float4 texelSize)
			{
				float x = uv.x * texelSize.z;
				float y = uv.y * texelSize.z;
				
				x -= 0.5f;
				y -= 0.5f;
				
				float px = floor(x);
				float py = floor(y);
				
				float fx = x - px;
				float fy = y - py;
				
				float g0x = BakeryBicubic_g0(fx);
				float g1x = BakeryBicubic_g1(fx);
				float h0x = BakeryBicubic_h0(fx);
				float h1x = BakeryBicubic_h1(fx);
				float h0y = BakeryBicubic_h0(fy);
				float h1y = BakeryBicubic_h1(fy);
				
				return     BakeryBicubic_g0(fy) * ( g0x * tex2D(tex, (float2(px + h0x, py + h0y) * texelSize.x))   +
				g1x * tex2D(tex, (float2(px + h1x, py + h0y) * texelSize.x))) +
				
				BakeryBicubic_g1(fy) * ( g0x * tex2D(tex, (float2(px + h0x, py + h1y) * texelSize.x))   +
				g1x * tex2D(tex, (float2(px + h1x, py + h1y) * texelSize.x)));
			}
			float4 BakeryTex2D(Texture2D tex, SamplerState s, float2 uv, float4 texelSize)
			{
				float x = uv.x * texelSize.z;
				float y = uv.y * texelSize.z;
				
				x -= 0.5f;
				y -= 0.5f;
				
				float px = floor(x);
				float py = floor(y);
				
				float fx = x - px;
				float fy = y - py;
				
				float g0x = BakeryBicubic_g0(fx);
				float g1x = BakeryBicubic_g1(fx);
				float h0x = BakeryBicubic_h0(fx);
				float h1x = BakeryBicubic_h1(fx);
				float h0y = BakeryBicubic_h0(fy);
				float h1y = BakeryBicubic_h1(fy);
				
				return     BakeryBicubic_g0(fy) * ( g0x * tex.Sample(s, (float2(px + h0x, py + h0y) * texelSize.x))   +
				g1x * tex.Sample(s, (float2(px + h1x, py + h0y) * texelSize.x))) +
				
				BakeryBicubic_g1(fy) * ( g0x * tex.Sample(s, (float2(px + h0x, py + h1y) * texelSize.x))   +
				g1x * tex.Sample(s, (float2(px + h1x, py + h1y) * texelSize.x)));
			}
			#else
			// Bilinear
			float4 BakeryTex2D(sampler2D tex, float2 uv, float4 texelSize)
			{
				return tex2D(tex, uv);
			}
			float4 BakeryTex2D(Texture2D tex, SamplerState s, float2 uv, float4 texelSize)
			{
				return tex.Sample(s, uv);
			}
			#endif
			
			#ifdef DIRLIGHTMAP_COMBINED
			#ifdef BAKERY_LMSPEC
			float BakeryDirectionalLightmapSpecular(float2 lmUV, float3 normalWorld, float3 viewDir, float smoothness)
			{
				float3 dominantDir = UNITY_SAMPLE_TEX2D_SAMPLER(unity_LightmapInd, unity_Lightmap, lmUV).xyz * 2 - 1;
				half3 halfDir = Unity_SafeNormalize(normalize(dominantDir) - viewDir);
				half nh = saturate(dot(normalWorld, halfDir));
				half perceptualRoughness = SmoothnessToPerceptualRoughness(smoothness);
				half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
				half spec = GGXTerm(nh, roughness);
				return spec;
			}
			#endif
			#endif
			
			#ifdef BAKERY_RNM
			void BakeryRNM(inout float3 diffuseColor, inout float3 specularColor, float2 lmUV, float3 normalMap, float perceptualRoughness, float3 viewDirT)
			{
				normalMap.g *= -1;
				float3 rnm0 = DecodeLightmap(BakeryTex2D(_RNM0, lmUV, _RNM0_TexelSize));
				float3 rnm1 = DecodeLightmap(BakeryTex2D(_RNM1, lmUV, _RNM0_TexelSize));
				float3 rnm2 = DecodeLightmap(BakeryTex2D(_RNM2, lmUV, _RNM0_TexelSize));
				
				#ifdef BAKERY_SSBUMP
				diffuseColor = normalMap.x * rnm0
				+ normalMap.z * rnm1
				+ normalMap.y * rnm2;
				diffuseColor *= 2;
				#else
				diffuseColor = saturate(dot(rnmBasis0, normalMap)) * rnm0
				+ saturate(dot(rnmBasis1, normalMap)) * rnm1
				+ saturate(dot(rnmBasis2, normalMap)) * rnm2;
				#endif
				
				#ifdef BAKERY_LMSPEC
				float3 dominantDirT = rnmBasis0 * dot(rnm0, lumaConv) +
				rnmBasis1 * dot(rnm1, lumaConv) +
				rnmBasis2 * dot(rnm2, lumaConv);
				
				float3 dominantDirTN = normalize(dominantDirT);
				float3 specColor = saturate(dot(rnmBasis0, dominantDirTN)) * rnm0 +
				saturate(dot(rnmBasis1, dominantDirTN)) * rnm1 +
				saturate(dot(rnmBasis2, dominantDirTN)) * rnm2;
				
				half3 halfDir = Unity_SafeNormalize(dominantDirTN - viewDirT);
				half nh = saturate(dot(normalMap, halfDir));
				half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
				half spec = GGXTerm(nh, roughness);
				specularColor = spec * specColor;
				#endif
			}
			#endif
			
			#ifdef BAKERY_SH
			void BakerySH(inout float3 diffuseColor, inout float3 specularColor, float2 lmUV, float3 normalWorld, float3 viewDir, float perceptualRoughness)
			{
				#ifdef SHADER_API_D3D11
				float3 L0 = DecodeLightmap(BakeryTex2D(unity_Lightmap, samplerunity_Lightmap, lmUV, _RNM0_TexelSize));
				#else
				float3 L0 = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, lmUV));
				#endif
				float3 nL1x = BakeryTex2D(_RNM0, lmUV, _RNM0_TexelSize) * 2 - 1;
				float3 nL1y = BakeryTex2D(_RNM1, lmUV, _RNM0_TexelSize) * 2 - 1;
				float3 nL1z = BakeryTex2D(_RNM2, lmUV, _RNM0_TexelSize) * 2 - 1;
				float3 L1x = nL1x * L0 * 2;
				float3 L1y = nL1y * L0 * 2;
				float3 L1z = nL1z * L0 * 2;
				
				float3 sh;
				#ifdef BAKERY_SHNONLINEAR
				float lumaL0 = dot(L0, float(1));
				float lumaL1x = dot(L1x, float(1));
				float lumaL1y = dot(L1y, float(1));
				float lumaL1z = dot(L1z, float(1));
				float lumaSH = shEvaluateDiffuseL1Geomerics(lumaL0, float3(lumaL1x, lumaL1y, lumaL1z), normalWorld);
				
				sh = L0 + normalWorld.x * L1x + normalWorld.y * L1y + normalWorld.z * L1z;
				float regularLumaSH = dot(sh, 1);
				//sh *= regularLumaSH < 0.001 ? 1 : (lumaSH / regularLumaSH);
				sh *= lerp(1, lumaSH / regularLumaSH, saturate(regularLumaSH*16));
				
				//sh.r = shEvaluateDiffuseL1Geomerics(L0.r, float3(L1x.r, L1y.r, L1z.r), normalWorld);
				//sh.g = shEvaluateDiffuseL1Geomerics(L0.g, float3(L1x.g, L1y.g, L1z.g), normalWorld);
				//sh.b = shEvaluateDiffuseL1Geomerics(L0.b, float3(L1x.b, L1y.b, L1z.b), normalWorld);
				
				#else
				sh = L0 + normalWorld.x * L1x + normalWorld.y * L1y + normalWorld.z * L1z;
				#endif
				
				diffuseColor = max(sh, 0.0);
				
				#ifdef BAKERY_LMSPEC
				float3 dominantDir = float3(dot(nL1x, lumaConv), dot(nL1y, lumaConv), dot(nL1z, lumaConv));
				float focus = saturate(length(dominantDir));
				half3 halfDir = Unity_SafeNormalize(normalize(dominantDir) - viewDir);
				half nh = saturate(dot(normalWorld, halfDir));
				half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
				half spec = GGXTerm(nh, roughness);
				
				sh = L0 + dominantDir.x * L1x + dominantDir.y * L1y + dominantDir.z * L1z;
				
				specularColor = max(spec * sh, 0.0);
				#endif
			}
			#endif
			
			#endif
			//BAKERY_ENABLED
			
			#if defined(NEED_DEPTH)
			UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
			#endif
			
			half _Smoothness;
			half _Metallic;
			half _OcclusionStrength;
			half _BumpScale;
			half _HeightScale;
			half _HeightRefPlane;
			half _HeightStepsMin;
			half _HeightStepsMax;
			half _DAlbedoScale;
			half _DNormalScale;
			half _DSmoothScale;
			half _VertexHeightAmount;
			half _VertexHeightOffset;
			half _TessFactor;
			half _TessMinDist;
			half _TessMaxDist;
			half _TessEdgeLength;
			half _TessMaxDisplacement;
			half _SpecOcclusion;
			half _SpecularRoughnessMod;
			half2 GLOBAL_uv;
			half4 _Color;
			half4 _MainTex_ST;
			half4 _MetallicRemap;
			half4 _SmoothnessRemap;
			half4 _MaskMap_TexelSize;
			half4 _EmissionColor;
			half4 GLOBAL_maskMap;
			half4 _DDetailsMap_ST;
			float _GSAAVariance;
			float _GSAAThreshold;
			int _AlbedoChannel;
			int _MappingSpace;
			int _PlanarAxisX;
			int _PlanarAxisY;
			int _MetalChannel;
			int _AOChannel;
			int _DetailMaskChannel;
			int _SmoothChannel;
			int _RoughnessMode;
			int _DetailAsTintMask;
			int _FlipBumpY;
			int _EmissionChannel;
			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);
			TEXTURE2D(_MaskMap);
			SAMPLER(sampler_MaskMap);
			TEXTURE2D(_BumpMap);
			SAMPLER(sampler_BumpMap);
			TEXTURE2D(_EmissionMap);
			SAMPLER(sampler_EmissionMap);
			TEXTURE2D(_Height);
			SAMPLER(sampler_Height);
			int _DIgnoreMask;
			int _DMappingSpace;
			int _DUVChannel;
			int _DPlanarAxisX;
			int _DPlanarAxisY;
			int _DNormalFlipY;
			TEXTURE2D(_DDetailsMap);
			SAMPLER(sampler_DDetailsMap);
			TEXTURE2D(_DDetailsNormal);
			SAMPLER(sampler_DDetailsNormal);
			TEXTURE2D(_VertexHeight);
			SAMPLER(sampler_VertexHeight);
			TEXTURE2D(_DFG);
			SAMPLER(sampler_DFG);
			
			void VHVertex() {
				half2 uv = vD.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				half height = (SAMPLE_TEXTURE2D_LOD(_VertexHeight, sampler_VertexHeight, uv, 0).r * 2 - 1);
				half3 mainOffset = vD.vertex.xyz + vD.normal * (height + _VertexHeightOffset) * _VertexHeightAmount;
				vD.vertex.xyz = mainOffset;
			}
			
			void ParallaxFragment()
			{
				GLOBAL_uv = d.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				#if PARALLAX && !defined(PLAT_QUEST)
				half customHeight = 0;
				GLOBAL_uv = POM(_Height, sampler_Height, GLOBAL_uv, ddx(GLOBAL_uv), ddy(GLOBAL_uv), d.worldNormal, d.worldSpaceViewDir, d.tangentSpaceViewDir, _HeightStepsMin, _HeightStepsMax, _HeightScale, _HeightRefPlane, half2(1, 1), half2(0, 0), 0, customHeight);
				#endif
			}
			
			void BaseFragmentFunction()
			{
				#if !defined(_SET_GLOBAL_UVS)
				GLOBAL_uv = d.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				#endif
				if (_MappingSpace > 0)
				{
					GLOBAL_uv = (_MappingSpace - 1) ? half2(d.worldSpacePosition[_PlanarAxisX], d.worldSpacePosition[_PlanarAxisY]) : half2(d.localSpacePosition[_PlanarAxisX], d.localSpacePosition[_PlanarAxisY]);
					GLOBAL_uv = GLOBAL_uv * _MainTex_ST.xy + _MainTex_ST.zw;
				}
				half4 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, GLOBAL_uv);
				if (_AlbedoChannel > 0)
				{
					albedo.rgb = albedo[_AlbedoChannel].xxx;
				}
				half4 masks = SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap, GLOBAL_uv);
				half4 normalTex = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, GLOBAL_uv);
				if (_FlipBumpY)
				{
					normalTex.y = 1 - normalTex.y;
				}
				half3 normal = UnpackScaleNormal(normalTex, _BumpScale);
				half3 emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, GLOBAL_uv).rgb;
				if (_EmissionChannel > 0)
				{
					emission.rgb = emission[_EmissionChannel].xxx;
				}
				int hasMasks = _MaskMap_TexelSize.z > 8;
				half metal = masks[_MetalChannel];
				half smooth = masks[_SmoothChannel];
				if (_RoughnessMode)
				{
					smooth = 1 - smooth;
				}
				half detailMask = masks[_DetailMaskChannel];
				half occlusion = masks[_AOChannel];
				metal = remap(metal, 0, 1, _MetallicRemap.x, _MetallicRemap.y);
				smooth = remap(smooth, 0, 1, _SmoothnessRemap.x, _SmoothnessRemap.y);
				GLOBAL_maskMap = half4(metal, occlusion, detailMask, smooth);
				o.Metallic = lerp(_Metallic, metal, hasMasks);
				o.Smoothness = lerp(_Smoothness, smooth, hasMasks);
				o.Occlusion = lerp(1, occlusion, _OcclusionStrength);
				o.Normal = normal;
				if (!_DetailAsTintMask)
				{
					o.Albedo = albedo.rgb * _Color.rgb;
				}
				else
				{
					o.Albedo = lerp(albedo, albedo.rgb * _Color.rgb, detailMask);
				}
				o.Alpha = albedo.a * _Color.a;
				#if defined(_EMISSION)
				o.Emission = emission * _EmissionColor;
				#endif
			}
			
			void DetailsFragment()
			{
				#if defined(DETAILS_OVERLAY)
				half masks = 0;
				#if defined(_MASKMAP_SAMPLED)
				masks = GLOBAL_maskMap.b;
				#else
				masks = 1;
				#endif
				half mask = lerp(masks, 1, _DIgnoreMask);
				half2 uv = d.uv0.xy;
				switch(_DUVChannel)
				{
					case 1: uv = d.uv1.xy; break;
					case 2: uv = d.uv2.xy; break;
					case 3: uv = d.uv3.xy; break;
					default: uv = d.uv0.xy; break;
				}
				uv = uv * _DDetailsMap_ST.xy + _DDetailsMap_ST.zw;
				if (_DMappingSpace > 0)
				{
					uv = (_DMappingSpace - 1) ? half2(d.worldSpacePosition[_DPlanarAxisX], d.worldSpacePosition[_DPlanarAxisY]) : half2(d.localSpacePosition[_DPlanarAxisX], d.localSpacePosition[_DPlanarAxisY]);
					uv = uv * _DDetailsMap_ST.xy + _DDetailsMap_ST.zw;
				}
				
				half4 detailsMap = SAMPLE_TEXTURE2D(_DDetailsMap, sampler_DDetailsMap, uv);
				
				#if defined(DETAILS_MODE_PACKED)
				half detailAlbedo = detailsMap.r * 2.0 - 1.0;
				half detailSmooth = detailsMap.b * 2.0 - 1.0;
				half3 detailNormal = 0;
				if (_DNormalFlipY)
				{
					detailsMap.g = 1 - detailsMap.g;
				}
				detailNormal = UnpackNormalAG(detailsMap, _DNormalScale);
				half detailAlbedoSpeed = saturate(abs(detailAlbedo) * _DAlbedoScale);
				#elif defined(DETAILS_MODE_SEPARATED)
				half3 detailAlbedo = detailsMap.rgb * 2.0 - 1.0;
				half detailSmooth = detailsMap.a * 2.0 - 1.0;
				
				half4 packedNormal = SAMPLE_TEXTURE2D(_DDetailsNormal, sampler_DDetailsNormal, uv);
				if (_DNormalFlipY)
				{
					packedNormal.g = 1 - packedNormal.g;
				}
				half3 detailNormal = UnpackScaleNormal(packedNormal, _DNormalScale);
				
				half3 detailAlbedoSpeed = saturate(abs(detailAlbedo) * _DAlbedoScale);
				#endif
				
				half3 albedoOverlay = lerp(sqrt(o.Albedo), (detailAlbedo < 0.0) ? 0.0.xxx : 1.0.xxx, detailAlbedoSpeed * detailAlbedoSpeed);
				albedoOverlay *= albedoOverlay;
				o.Albedo = lerp(o.Albedo, saturate(albedoOverlay), mask);
				
				half detailSmoothSpeed = saturate(abs(detailSmooth) * _DSmoothScale);
				half smoothOverlay = lerp(o.Smoothness, (detailSmooth < 0.0) ? 0.0 : 1.0, detailSmoothSpeed * detailSmoothSpeed);
				o.Smoothness = lerp(o.Smoothness, saturate(smoothOverlay), mask);
				
				o.Normal = lerp(o.Normal, BlendNormals(o.Normal, detailNormal), mask);
				#endif
			}
			
			void ORLLighting()
			{
				#if !defined(UNITY_PASS_SHADOWCASTER)
				half reflectance = 0.5;
				half3 f0 = 0.16 * reflectance * reflectance * (1 - o.Metallic) + o.Albedo * o.Metallic;
				half3 pixelLight = 0;
				half3 indirectDiffuse = 1;
				half3 indirectSpecular = 0;
				half3 directSpecular = 0;
				half occlusion = o.Occlusion;
				half perceptualRoughness = 1 - o.Smoothness;
				half3 tangentNormal = o.Normal;
				o.Normal = normalize(mul(o.Normal, d.TBNMatrix));
				
				#ifndef USING_DIRECTIONAL_LIGHT
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(d.worldSpacePosition));
				#else
				fixed3 lightDir = _WorldSpaceLightPos0.xyz;
				#endif
				
				#if defined(GSAA)
				perceptualRoughness = GSAA_Filament(o.Normal, perceptualRoughness, _GSAAVariance, _GSAAThreshold);
				#endif
				
				UNITY_LIGHT_ATTENUATION(lightAttenuation, FragData, d.worldSpacePosition);
				half3 lightColor = lightAttenuation * _LightColor0.rgb;
				
				half3 lightHalfVector = Unity_SafeNormalize(lightDir + d.worldSpaceViewDir);
				half lightNoL = saturate(dot(o.Normal, lightDir));
				half lightLoH = saturate(dot(lightDir, lightHalfVector));
				
				half NoV = abs(dot(o.Normal, d.worldSpaceViewDir)) + 1e-5;
				pixelLight = lightNoL * lightColor * Fd_Burley(perceptualRoughness, NoV, lightNoL, lightLoH);
				
				// READ THE LIGHTMAP
				#if defined(LIGHTMAP_ON) && !defined(UNITY_PASS_FORWARDADD)
				half3 lightMap = 0;
				half4 bakedColorTex = 0;
				half2 lightmapUV = FragData.lightmapUv.xy;
				
				// UNITY LIGHTMAPPING
				#if !defined(BAKERYLM_ENABLED) || !defined(BAKERY_ENABLED)
				lightMap = tex2DFastBicubicLightmap(lightmapUV, bakedColorTex);
				#endif
				
				// BAKERY RNM MODE (why do we even support it??)
				#if defined(BAKERY_RNM) && defined(BAKERY_ENABLED)
				half3 rnm0 = DecodeLightmap(BakeryTex2D(_RNM0, lightmapUV, _RNM0_TexelSize));
				half3 rnm1 = DecodeLightmap(BakeryTex2D(_RNM1, lightmapUV, _RNM0_TexelSize));
				half3 rnm2 = DecodeLightmap(BakeryTex2D(_RNM2, lightmapUV, _RNM0_TexelSize));
				
				lightMap = saturate(dot(rnmBasis0, tangentNormal)) * rnm0 +
				saturate(dot(rnmBasis1, tangentNormal)) * rnm1 +
				saturate(dot(rnmBasis2, tangentNormal)) * rnm2;
				#endif
				
				// BAKERY SH MODE (these are also used for the specular)
				#if defined(BAKERY_SH) && defined(BAKERY_ENABLED)
				half3 L0 = DecodeLightmap(BakeryTex2D(unity_Lightmap, samplerunity_Lightmap, lightmapUV, _RNM0_TexelSize));
				
				half3 nL1x = BakeryTex2D(_RNM0, lightmapUV, _RNM0_TexelSize) * 2.0 - 1.0;
				half3 nL1y = BakeryTex2D(_RNM1, lightmapUV, _RNM0_TexelSize) * 2.0 - 1.0;
				half3 nL1z = BakeryTex2D(_RNM2, lightmapUV, _RNM0_TexelSize) * 2.0 - 1.0;
				half3 L1x = nL1x * L0 * 2.0;
				half3 L1y = nL1y * L0 * 2.0;
				half3 L1z = nL1z * L0 * 2.0;
				
				// Non-Linear mode
				#if defined(BAKERY_SHNONLINEAR)
				half lumaL0 = dot(L0, half(1));
				half lumaL1x = dot(L1x, half(1));
				half lumaL1y = dot(L1y, half(1));
				half lumaL1z = dot(L1z, half(1));
				half lumaSH = shEvaluateDiffuseL1Geomerics_local(lumaL0, half3(lumaL1x, lumaL1y, lumaL1z), o.Normal);
				
				lightMap = L0 + o.Normal.x * L1x + o.Normal.y * L1y + o.Normal.z * L1z;
				half regularLumaSH = dot(lightMap, 1.0);
				lightMap *= lerp(1.0, lumaSH / regularLumaSH, saturate(regularLumaSH * 16.0));
				#else
				lightMap = L0 + o.Normal.x * L1x + o.Normal.y * L1y + o.Normal.z * L1z;
				#endif
				
				#endif
				
				#if defined(DIRLIGHTMAP_COMBINED)
				half4 lightMapDirection = UNITY_SAMPLE_TEX2D_SAMPLER(unity_LightmapInd, unity_Lightmap, lightmapUV);
				#if !defined(BAKERY_MONOSH)
				lightMap = DecodeDirectionalLightmap(lightMap, lightMapDirection, o.Normal);
				#endif
				#endif
				
				#if defined(BAKERY_MONOSH) && defined(BAKERY_ENABLED) && defined(DIRLIGHTMAP_COMBINED)
				half3 L0 = tex2DFastBicubicLightmap(lightmapUV, bakedColorTex);
				half3 nL1 = lightMapDirection.xyz * 2.0 - 1.0;
				half3 L1x = nL1.x * L0 * 2.0;
				half3 L1y = nL1.y * L0 * 2.0;
				half3 L1z = nL1.z * L0 * 2.0;
				
				#if defined(BAKERY_SHNONLINEAR)
				half lumaL0 = dot(L0, 1);
				half lumaL1x = dot(L1x, 1);
				half lumaL1y = dot(L1y, 1);
				half lumaL1z = dot(L1z, 1);
				half lumaSH = shEvaluateDiffuseL1Geomerics(lumaL0, half3(lumaL1x, lumaL1y, lumaL1z), o.Normal);
				
				lightMap = L0 + o.Normal.x * L1x + o.Normal.y * L1y + o.Normal.z * L1z;
				half regularLumaSH = dot(lightMap, 1);
				lightMap *= lerp(1, lumaSH / regularLumaSH, saturate(regularLumaSH*16));
				#else
				lightMap = L0 + o.Normal.x * L1x + o.Normal.y * L1y + o.Normal.z * L1z;
				#endif
				
				lightMap = max(lightMap, 0.0);
				#endif
				
				#if defined(DYNAMICLIGHTMAP_ON) && !defined(UNITY_PBS_USE_BRDF2)
				half3 realtimeLightMap = getRealtimeLightmap(FragData.lightmapUv.zw, o.Normal);
				lightMap += realtimeLightMap;
				#endif
				
				#if defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN)
				pixelLight = 0;
				lightMap = SubtractMainLightWithRealtimeAttenuationFrowmLightmap(lightMap, lightAttenuation, bakedColorTex, o.Normal);
				#endif
				indirectDiffuse = lightMap;
				#else
				#if UNITY_LIGHT_PROBE_PROXY_VOLUME
				UNITY_BRANCH
				if (unity_ProbeVolumeParams.x == 1)
				{
					indirectDiffuse = SHEvalLinearL0L1_SampleProbeVolume(half4(o.Normal, 1), FragData.worldPos);
				}
				else
				{
					#endif
					indirectDiffuse = max(0, ShadeSH9(half4(o.Normal, 1)));
					#if UNITY_LIGHT_PROBE_PROXY_VOLUME
				}
				#endif
				#endif
				
				#if defined(LIGHTMAP_SHADOW_MIXING) && defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) && defined(LIGHTMAP_ON) && !defined(UNITY_PASS_FORWARDADD)
				pixelLight *= UnityComputeForwardShadows(FragData.lightmapUv.xy, d.worldSpacePosition, d.screenPos);
				#endif
				
				half3 dfguv = half3(NoV, perceptualRoughness, 0);
				half2 dfg = SAMPLE_TEXTURE2D(_DFG, sampler_DFG, dfguv).xy;
				half3 energyCompensation = 1.0 + f0 * (1.0 / dfg.y - 1.0);
				
				half rough = perceptualRoughness * perceptualRoughness;
				half clampedRoughness = max(rough, 0.002);
				
				#if !defined(SPECULAR_HIGHLIGHTS_OFF) && defined(USING_LIGHT_MULTI_COMPILE)
				half NoH = saturate(dot(o.Normal, lightHalfVector));
				half3 F = F_Schlick(lightLoH, f0);
				half D = D_GGX(NoH, clampedRoughness);
				half V = V_SmithGGXCorrelated(NoV, lightNoL, clampedRoughness);
				
				F *= energyCompensation;
				
				directSpecular = max(0, D * V * F) * pixelLight * UNITY_PI;
				#endif
				
				// BAKED SPECULAR
				#if defined(BAKED_SPECULAR) && !defined(BAKERYLM_ENABLED) && !defined(UNITY_PASS_FORWARDADD)
				{
					half3 bakedDominantDirection = 1;
					half3 bakedSpecularColor = 0;
					
					// only do it if we have a directional lightmap
					#if defined(DIRLIGHTMAP_COMBINED) && defined(LIGHTMAP_ON)
					bakedDominantDirection = (lightMapDirection.xyz) * 2 - 1;
					half directionality = max(0.001, length(bakedDominantDirection));
					bakedDominantDirection /= directionality;
					bakedSpecularColor = indirectDiffuse;
					#endif
					
					// if we do not have lightmap - derive the specular from probes
					//#ifndef LIGHTMAP_ON
					//bakedSpecularColor = half3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);
					//bakedDominantDirection = unity_SHAr.xyz + unity_SHAg.xyz + unity_SHAb.xyz;
					// #endif
					
					bakedDominantDirection = normalize(bakedDominantDirection);
					directSpecular += GetSpecularHighlights(o.Normal, bakedSpecularColor, bakedDominantDirection, f0, d.worldSpaceViewDir, lerp(1, clampedRoughness, _SpecularRoughnessMod), NoV, energyCompensation);
				}
				#endif
				
				half3 fresnel = F_Schlick(NoV, f0);
				
				// BAKERY DIRECT SPECULAR
				#if defined(BAKERY_LMSPEC) && defined(BAKERY_ENABLED) && !defined(UNITY_PASS_FORWARDADD)
				#if defined(BAKERY_RNM)
				{
					half3 viewDirTangent = -normalize(d.tangentSpaceViewDir);
					half3 dominantDirTangent = rnmBasis0 * dot(rnm0, lumaConv) +
					rnmBasis1 * dot(rnm1, lumaConv) +
					rnmBasis2 * dot(rnm2, lumaConv);
					
					half3 dominantDirTangentNormalized = normalize(dominantDirTangent);
					half3 specColor = saturate(dot(rnmBasis0, dominantDirTangentNormalized)) * rnm0 +
					saturate(dot(rnmBasis1, dominantDirTangentNormalized)) * rnm1 +
					saturate(dot(rnmBasis2, dominantDirTangentNormalized)) * rnm2;
					half3 halfDir = Unity_SafeNormalize(dominantDirTangentNormalized - viewDirTangent);
					half NoH = saturate(dot(tangentNormal, halfDir));
					half spec = D_GGX(NoH, lerp(1, clampedRoughness, _SpecularRoughnessMod));
					directSpecular += spec * specColor * fresnel;
				}
				#endif
				
				#if defined(BAKERY_SH)
				{
					half3 dominantDir = half3(dot(nL1x, lumaConv), dot(nL1y, lumaConv), dot(L1z, lumaConv));
					half3 halfDir = Unity_SafeNormalize(normalize(dominantDir) + d.worldSpaceViewDir);
					half NoH = saturate(dot(o.Normal, halfDir));
					half spec = D_GGX(NoH, lerp(1, clampedRoughness, _SpecularRoughnessMod));
					half3 sh = L0 + dominantDir.x * L1x + dominantDir.y * L1y + dominantDir.z * L1z;
					dominantDir = normalize(dominantDir);
					directSpecular += max(spec * sh, 0.0) * fresnel;
				}
				#endif
				
				#if defined(BAKERY_MONOSH)
				{
					half3 dominantDir = nL1;
					half focus = saturate(length(dominantDir));
					half3 halfDir = Unity_SafeNormalize(normalize(dominantDir) - d.worldSpaceViewDir);
					half NoH = saturate(dot(o.Normal, halfDir));
					half spec = D_GGX(NoH, lerp(1, clampedRoughness, _SpecularRoughnessMod));
					half3 sh = L0 + dominantDir.x * L1x + dominantDir.y * L1y + dominantDir.z * L1z;
					dominantDir = normalize(dominantDir);
					directSpecular += max(spec * sh, 0.0) * fresnel;
				}
				#endif
				#endif
				
				// REFLECTIONS
				#if !defined(UNITY_PASS_FORWARDADD)
				half3 reflDir = reflect(-d.worldSpaceViewDir, o.Normal);
				reflDir = lerp(reflDir, o.Normal, rough * rough);
				
				Unity_GlossyEnvironmentData envData;
				envData.roughness = perceptualRoughness;
				envData.reflUVW = getBoxProjection(reflDir, d.worldSpacePosition.xyz, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin.xyz, unity_SpecCube0_BoxMax.xyz);
				
				half3 probe0 = Unity_GlossyEnvironment(UNITY_PASS_TEXCUBE(unity_SpecCube0), unity_SpecCube0_HDR, envData);
				indirectSpecular = probe0;
				
				#if defined(UNITY_SPECCUBE_BLENDING)
				UNITY_BRANCH
				if (unity_SpecCube0_BoxMin.w < 0.99999)
				{
					envData.reflUVW = getBoxProjection(reflDir, d.worldSpacePosition.xyz, unity_SpecCube1_ProbePosition, unity_SpecCube1_BoxMin.xyz, unity_SpecCube1_BoxMax.xyz);
					half3 probe1 = Unity_GlossyEnvironment(UNITY_PASS_TEXCUBE_SAMPLER(unity_SpecCube1, unity_SpecCube0), unity_SpecCube1_HDR, envData);
					indirectSpecular = lerp(probe1, probe0, unity_SpecCube0_BoxMin.w);
				}
				#endif
				
				half horizon = min(1 + dot(reflDir, o.Normal), 1);
				dfg.x *= saturate(pow(dot(indirectDiffuse, 1), _SpecOcclusion));
				indirectSpecular = indirectSpecular * horizon * horizon * energyCompensation * EnvBRDFMultiscatter(dfg, f0);
				
				#if defined(_MASKMAP_SAMPLED)
				indirectSpecular *= computeSpecularAO(NoV, o.Occlusion, perceptualRoughness * perceptualRoughness);
				#endif
				#endif
				
				#if defined(_INTEGRATE_CUSTOMGI) && !defined(UNITY_PASS_FORWARDADD)
				IntegrateCustomGI(d, o, indirectSpecular, indirectDiffuse);
				#endif
				
				// FINAL COLOR
				FinalColor = half4(o.Albedo.rgb * (1 - o.Metallic) * (indirectDiffuse * occlusion + (pixelLight)) + indirectSpecular + directSpecular, o.Alpha);
				
				FinalColor.rgb += o.Emission;
				#endif
			}
			
			// Meta Vertex
			TessVertex Vertex(VertexData v)
			{
				UNITY_SETUP_INSTANCE_ID(v);
				TessVertex o = (TessVertex) 0;
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				
				o.vertex = v.vertex;
				o.normal = v.normal;
				o.tangent = v.tangent;
				o.color = v.color;
				o.uv0 = v.uv0;
				o.uv1 = v.uv1;
				o.uv2 = v.uv2;
				o.uv3 = v.uv3;
				
				return o;
			}
			
			// Meta Hull
			[maxtessfactor(MAX_TESSELLATION_FACTORS)]
			[UNITY_domain("tri")]
			[UNITY_outputcontrolpoints(3)]
			[UNITY_outputtopology("triangle_cw")]
			[UNITY_partitioning("integer")]
			[UNITY_patchconstantfunc("TessFactorsFunction")]
			TessVertex Hull(InputPatch<TessVertex, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}
			
			float4 GetTessFactors(InputPatch<TessVertex, 3> patch)
			{
				#if defined(TESS_MODE_DISTANCEBASED)
				float4 tessFactors = UnityDistanceBasedTess(
				patch[0].vertex,
				patch[1].vertex,
				patch[2].vertex,
				_TessMinDist,
				_TessMaxDist,
				_TessFactor
				);
				return tessFactors;
				#elif defined(TESS_MODE_EDGELENGTH)
				float4 tessFactors = UnityEdgeLengthBasedTessCull(
				patch[0].vertex,
				patch[1].vertex,
				patch[2].vertex,
				_TessEdgeLength,
				_TessMaxDisplacement
				);
				return tessFactors;
				#endif
				
				return 1..xxxx;
			}
			
			// Meta TessFactor
			TessellationFactors TessFactorsFunction(InputPatch<TessVertex, 3> patch)
			{
				TessellationFactors f;
				float4 TessFactorsOutput = 0;
				#if defined(TESS_FACTORS_FUNC_DEFINED)
				TessFactorsOutput = GetTessFactors(patch);
				#else
				TessFactorsOutput = 1..xxxx;
				#endif
				f.edge[0] = TessFactorsOutput.x;
				f.edge[1] = TessFactorsOutput.y;
				f.edge[2] = TessFactorsOutput.z;
				f.inside = TessFactorsOutput.w;
				return f;
			}
			
			// Meta Domain
			[UNITY_domain("tri")]
			FragmentData Domain(TessellationFactors factors, OutputPatch<TessVertex, 3> patch, float3 baryCoords : SV_DomainLocation)
			{
				VertexData v = (VertexData) 0;
				UNITY_TRANSFER_INSTANCE_ID(patch[0], v);
				v.vertex = patch[0].vertex * baryCoords.x + patch[1].vertex * baryCoords.y + patch[2].vertex * baryCoords.z;
				
				#if defined(PHONG)
				float3 pp[3];
				for (int index = 0; index < 3; ++index)
				{
					pp[index] = v.vertex.xyz - patch[index].normal * (dot(v.vertex.xyz, patch[index].normal) - dot(patch[index].vertex.xyz, patch[index].normal));
				}
				v.vertex.xyz = 0.5 * (pp[0]*baryCoords.x + pp[1]*baryCoords.y + pp[2]*baryCoords.z) + (0.5) * v.vertex.xyz;
				#endif
				
				v.normal = patch[0].normal * baryCoords.x + patch[1].normal * baryCoords.y + patch[2].normal * baryCoords.z;
				v.tangent = patch[0].tangent * baryCoords.x + patch[1].tangent * baryCoords.y + patch[2].tangent * baryCoords.z;
				v.color = patch[0].color * baryCoords.x + patch[1].color * baryCoords.y + patch[2].color * baryCoords.z;
				v.uv0 = patch[0].uv0 * baryCoords.x + patch[1].uv0 * baryCoords.y + patch[2].uv0 * baryCoords.z;
				v.uv1 = patch[0].uv1 * baryCoords.x + patch[1].uv1 * baryCoords.y + patch[2].uv1 * baryCoords.z;
				v.uv2 = patch[0].uv2 * baryCoords.x + patch[1].uv2 * baryCoords.y + patch[2].uv2 * baryCoords.z;
				v.uv3 = patch[0].uv3 * baryCoords.x + patch[1].uv3 * baryCoords.y + patch[2].uv3 * baryCoords.z;
				
				FragmentData i;
				UNITY_INITIALIZE_OUTPUT(FragmentData, i);
				UNITY_TRANSFER_INSTANCE_ID(patch[0], i);
				
				vD = v;
				FragData = i;
				VHVertex();
				
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
				i.vizUV = 0;
				i.lightCoord = 0;
				if (unity_VisualizationMode == EDITORVIZ_TEXTURE)
				i.vizUV = UnityMetaVizUV(unity_EditorViz_UVIndex, v.uv0.xy, v.uv1.xy, v.uv2.xy, unity_EditorViz_Texture_ST);
				else if (unity_VisualizationMode == EDITORVIZ_SHOWLIGHTMASK)
				{
					i.vizUV = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
					i.lightCoord = mul(unity_EditorViz_WorldToLight, mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1)));
				}
				#endif
				
				#if defined(NEED_SCREEN_POS)
				i.screenPos = ComputeScreenPos(i.pos);
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
			
			// Meta Fragment
			half4 Fragment(FragmentData i) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(i);
				
				FragData = i;
				o = (SurfaceData) 0;
				d = CreateMeshData(i);
				o.Albedo = half3(0.5, 0.5, 0.5);
				o.Normal = half3(0, 0, 1);
				o.Smoothness = 0.5;
				o.Occlusion = 1;
				o.Alpha = 1;
				
				ParallaxFragment();
				BaseFragmentFunction();
				DetailsFragment();
				
				FinalColor = half4(o.Albedo, o.Alpha);
				
				UnityMetaInput metaIN;
				UNITY_INITIALIZE_OUTPUT(UnityMetaInput, metaIN);
				
				metaIN.Albedo = FinalColor;
				metaIN.Emission = o.Emission;
				
				#if defined(EDITOR_VISUALISATION)
				metaIN.VizUV = i.vizUV;
				metaIN.LightCoord = i.lightCoord;
				#endif
				
				return UnityMetaFragment(metaIN);
			}
			
			ENDCG
			// Meta Pass End
			
		}
		
		Pass
		{
			Tags { "LightMode" = "ShadowCaster"  }
			
			// Shadow Pass Start
			CGPROGRAM
			#pragma target 4.6
			#pragma require tesshw
			#pragma multi_compile_instancing
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#pragma multi_compile_shadowcaster
			#pragma vertex Vertex
			#pragma fragment Fragment
			#pragma hull Hull
			#pragma domain Domain
			#pragma shader_feature_local _EMISSION
			
			#pragma shader_feature_local PARALLAX
			
			#pragma shader_feature_local DETAILS_OVERLAY
			#pragma shader_feature_local _ DETAILS_MODE_PACKED DETAILS_MODE_SEPARATED
			
			#pragma shader_feature_local _ TESS_MODE_DISTANCEBASED TESS_MODE_EDGELENGTH
			#pragma shader_feature_local PHONG
			
			#pragma shader_feature_local BICUBIC_LIGHTMAP
			#pragma shader_feature_local BAKED_SPECULAR
			#pragma shader_feature_local GSAA
			#pragma shader_feature_local FORCE_BOX_PROJECTION
			
			// Bakery Stuff
			#pragma shader_feature_local BAKERY_ENABLED
			#pragma shader_feature_local _ BAKERY_RNM BAKERY_SH BAKERY_MONOSH
			#pragma shader_feature_local BAKERY_SHNONLINEAR
			
			#define UNITY_INSTANCED_LOD_FADE
			#define UNITY_INSTANCED_SH
			#define UNITY_INSTANCED_LIGHTMAPSTS
			
			#ifndef UNITY_PASS_SHADOWCASTER
			#define UNITY_PASS_SHADOWCASTER
			#endif
			
			#if defined(SHADER_API_XBOXONE) || defined(SHADER_API_PSSL)
			#define MAX_TESSELLATION_FACTORS 15.0
			#else
			#define MAX_TESSELLATION_FACTORS 64.0
			#endif
			
			#include "UnityStandardUtils.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			#include "Tessellation.cginc"
			
			#define FLT_EPSILON     1.192092896e-07
			
			#define _MASKMAP_SAMPLED
			
			#define _SET_GLOBAL_UVS
			
			#if !defined(DETAILS_MODE_PACKED) && !defined(DETAILS_MODE_SEPARATED)
			#define DETAILS_MODE_PACKED
			#endif
			
			#define TESS_FACTORS_FUNC_DEFINED
			
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
			
			#define NEED_SCREEN_POS
			
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
				half4 vertexColor;
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
				#if defined(NEED_SCREEN_POS)
				m.screenPos = i.screenPos;
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
			
			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};
			
			struct TessVertex
			{
				float4 vertex : INTERNALTESSPOS;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 color : COLOR;
				float2 uv0 : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float2 uv2 : TEXCOORD2;
				float2 uv3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
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
			
			half3 UnpackNormalAG(half4 packedNormal, half scale = 1.0)
			{
				half3 normal;
				normal.xy = packedNormal.ag * 2.0 - 1.0;
				normal.z = max(1.0e-16, sqrt(1.0 - saturate(dot(normal.xy, normal.xy))));
				
				normal.xy *= scale;
				return normal;
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
			
			// https://assetstore.unity.com/packages/tools/level-design/bakery-gpu-lightmapper-122218
			
			#if defined(BAKERY_ENABLED)
			
			//float2 bakeryLightmapSize;
			#define BAKERYMODE_DEFAULT 0
			#define BAKERYMODE_VERTEXLM 1.0f
			#define BAKERYMODE_RNM 2.0f
			#define BAKERYMODE_SH 3.0f
			
			#define rnmBasis0 float3(0.816496580927726f, 0, 0.5773502691896258f)
			#define rnmBasis1 float3(-0.4082482904638631f, 0.7071067811865475f, 0.5773502691896258f)
			#define rnmBasis2 float3(-0.4082482904638631f, -0.7071067811865475f, 0.5773502691896258f)
			
			#if defined(BAKERY_DOMINANT)
			#undef BAKERY_RNM
			#undef BAKERY_SH
			#undef BAKERY_MONOSH
			#endif
			
			#ifdef BICUBIC_LIGHTMAP
			#define BAKERY_BICUBIC
			#endif
			
			//#define BAKERY_SSBUMP
			
			// can't fit vertexLM SH to sm3_0 interpolators
			#ifndef SHADER_API_D3D11
			#undef BAKERY_VERTEXLMSH
			#endif
			
			// can't do stuff on sm2_0 due to standard shader alrady taking up all instructions
			#if SHADER_TARGET < 30
			#undef BAKERY_BICUBIC
			#undef BAKERY_LMSPEC
			
			#undef BAKERY_RNM
			#undef BAKERY_SH
			#undef BAKERY_MONOSH
			#undef BAKERY_VERTEXLM
			#endif
			
			#if !defined(BAKERY_SH) && !defined(BAKERY_RNM)
			#undef BAKERY_BICUBIC
			#endif
			
			#ifndef UNITY_SHOULD_SAMPLE_SH
			#undef BAKERY_PROBESHNONLINEAR
			#endif
			
			#if defined(BAKERY_RNM) && defined(BAKERY_LMSPEC)
			#define BAKERY_RNMSPEC
			#endif
			
			#ifndef BAKERY_VERTEXLM
			#undef BAKERY_VERTEXLMDIR
			#undef BAKERY_VERTEXLMSH
			#undef BAKERY_VERTEXLMMASK
			#endif
			
			#define lumaConv float3(0.2125f, 0.7154f, 0.0721f)
			
			#if defined(BAKERY_SH) || defined(BAKERY_MONOSH) || defined(BAKERY_VERTEXLMSH) || defined(BAKERY_PROBESHNONLINEAR) || defined(BAKERY_VOLUME)
			float shEvaluateDiffuseL1Geomerics(float L0, float3 L1, float3 n)
			{
				// average energy
				float R0 = L0;
				
				// avg direction of incoming light
				float3 R1 = 0.5f * L1;
				
				// directional brightness
				float lenR1 = length(R1);
				
				// linear angle between normal and direction 0-1
				//float q = 0.5f * (1.0f + dot(R1 / lenR1, n));
				//float q = dot(R1 / lenR1, n) * 0.5 + 0.5;
				float q = dot(normalize(R1), n) * 0.5 + 0.5;
				
				// power for q
				// lerps from 1 (linear) to 3 (cubic) based on directionality
				float p = 1.0f + 2.0f * lenR1 / R0;
				
				// dynamic range constant
				// should vary between 4 (highly directional) and 0 (ambient)
				float a = (1.0f - lenR1 / R0) / (1.0f + lenR1 / R0);
				
				return R0 * (a + (1.0f - a) * (p + 1.0f) * pow(q, p));
			}
			#endif
			
			#ifdef BAKERY_VERTEXLM
			float4 unpack4NFloats(float src) {
				//return fmod(float4(src / 262144.0, src / 4096.0, src / 64.0, src), 64.0)/64.0;
				return frac(float4(src / (262144.0*64), src / (4096.0*64), src / (64.0*64), src));
			}
			float3 unpack3NFloats(float src) {
				float r = frac(src);
				float g = frac(src * 256.0);
				float b = frac(src * 65536.0);
				return float3(r, g, b);
			}
			#if defined(BAKERY_VERTEXLMDIR)
			
			#ifdef BAKERY_MONOSH
			void BakeryVertexLMMonoSH(inout float3 diffuseColor, inout float3 specularColor, float3 nL1, float3 normalWorld, float3 viewDir, float smoothness)
			{
				nL1 = nL1;
				float3 L0 = diffuseColor;
				float3 L1x = nL1.x * L0 * 2;
				float3 L1y = nL1.y * L0 * 2;
				float3 L1z = nL1.z * L0 * 2;
				
				float3 sh;
				#if BAKERY_SHNONLINEAR
				//sh.r = shEvaluateDiffuseL1Geomerics(L0.r, float3(L1x.r, L1y.r, L1z.r), normalWorld);
				//sh.g = shEvaluateDiffuseL1Geomerics(L0.g, float3(L1x.g, L1y.g, L1z.g), normalWorld);
				//sh.b = shEvaluateDiffuseL1Geomerics(L0.b, float3(L1x.b, L1y.b, L1z.b), normalWorld);
				
				float lumaL0 = dot(L0, 1);
				float lumaL1x = dot(L1x, 1);
				float lumaL1y = dot(L1y, 1);
				float lumaL1z = dot(L1z, 1);
				float lumaSH = shEvaluateDiffuseL1Geomerics(lumaL0, float3(lumaL1x, lumaL1y, lumaL1z), normalWorld);
				
				sh = L0 + normalWorld.x * L1x + normalWorld.y * L1y + normalWorld.z * L1z;
				float regularLumaSH = dot(sh, 1);
				//sh *= regularLumaSH < 0.001 ? 1 : (lumaSH / regularLumaSH);
				sh *= lerp(1, lumaSH / regularLumaSH, saturate(regularLumaSH*16));
				
				#else
				sh = L0 + normalWorld.x * L1x + normalWorld.y * L1y + normalWorld.z * L1z;
				#endif
				
				diffuseColor = max(sh, 0.0);
				
				#ifdef BAKERY_LMSPEC
				float3 dominantDir = nL1;
				float focus = saturate(length(dominantDir));
				half3 halfDir = Unity_SafeNormalize(normalize(dominantDir) - viewDir);
				half nh = saturate(dot(normalWorld, halfDir));
				half perceptualRoughness = SmoothnessToPerceptualRoughness(smoothness );//* sqrt(focus));
				half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
				half spec = GGXTerm(nh, roughness);
				specularColor = max(spec * sh, 0.0);
				#endif
			}
			#endif
			
			void BakeryVertexLMDirection(inout float3 diffuseColor, inout float3 specularColor, float3 lightDirection, float3 vertexNormalWorld, float3 normalWorld, float3 viewDir, float smoothness)
			{
				float3 dominantDir = Unity_SafeNormalize(lightDirection);
				half halfLambert = dot(normalWorld, dominantDir) * 0.5 + 0.5;
				half flatNormalHalfLambert = dot(vertexNormalWorld, dominantDir) * 0.5 + 0.5;
				
				#ifdef BAKERY_LMSPEC
				half3 halfDir = Unity_SafeNormalize(normalize(dominantDir) - viewDir);
				half nh = saturate(dot(normalWorld, halfDir));
				half perceptualRoughness = SmoothnessToPerceptualRoughness(smoothness);
				half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
				half spec = GGXTerm(nh, roughness);
				specularColor = spec * diffuseColor;
				#endif
				
				diffuseColor *= halfLambert / max(1e-4h, flatNormalHalfLambert);
			}
			#elif defined(BAKERY_VERTEXLMSH)
			void BakeryVertexLMSH(inout float3 diffuseColor, inout float3 specularColor, float3 shL1x, float3 shL1y, float3 shL1z, float3 normalWorld, float3 viewDir, float smoothness)
			{
				float3 L0 = diffuseColor;
				float3 nL1x = shL1x;
				float3 nL1y = shL1y;
				float3 nL1z = shL1z;
				float3 L1x = nL1x * L0 * 2;
				float3 L1y = nL1y * L0 * 2;
				float3 L1z = nL1z * L0 * 2;
				
				float3 sh;
				#ifdef BAKERY_SHNONLINEAR
				//sh.r = shEvaluateDiffuseL1Geomerics(L0.r, float3(L1x.r, L1y.r, L1z.r), normalWorld);
				//sh.g = shEvaluateDiffuseL1Geomerics(L0.g, float3(L1x.g, L1y.g, L1z.g), normalWorld);
				//sh.b = shEvaluateDiffuseL1Geomerics(L0.b, float3(L1x.b, L1y.b, L1z.b), normalWorld);
				
				float lumaL0 = dot(L0, 1);
				float lumaL1x = dot(L1x, 1);
				float lumaL1y = dot(L1y, 1);
				float lumaL1z = dot(L1z, 1);
				float lumaSH = shEvaluateDiffuseL1Geomerics(lumaL0, float3(lumaL1x, lumaL1y, lumaL1z), normalWorld);
				
				sh = L0 + normalWorld.x * L1x + normalWorld.y * L1y + normalWorld.z * L1z;
				float regularLumaSH = dot(sh, 1);
				//sh *= regularLumaSH < 0.001 ? 1 : (lumaSH / regularLumaSH);
				sh *= lerp(1, lumaSH / regularLumaSH, saturate(regularLumaSH*16));
				
				#else
				sh = L0 + normalWorld.x * L1x + normalWorld.y * L1y + normalWorld.z * L1z;
				#endif
				
				diffuseColor = max(sh, 0.0);
				
				#ifdef BAKERY_LMSPEC
				float3 dominantDir = float3(dot(nL1x, lumaConv), dot(nL1y, lumaConv), dot(nL1z, lumaConv));
				float focus = saturate(length(dominantDir));
				half3 halfDir = Unity_SafeNormalize(normalize(dominantDir) - viewDir);
				half nh = saturate(dot(normalWorld, halfDir));
				half perceptualRoughness = SmoothnessToPerceptualRoughness(smoothness );//* sqrt(focus));
				half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
				half spec = GGXTerm(nh, roughness);
				specularColor = max(spec * sh, 0.0);
				#endif
			}
			#endif
			#endif
			
			#ifdef BAKERY_BICUBIC
			float BakeryBicubic_w0(float a)
			{
				return (1.0f/6.0f)*(a*(a*(-a + 3.0f) - 3.0f) + 1.0f);
			}
			
			float BakeryBicubic_w1(float a)
			{
				return (1.0f/6.0f)*(a*a*(3.0f*a - 6.0f) + 4.0f);
			}
			
			float BakeryBicubic_w2(float a)
			{
				return (1.0f/6.0f)*(a*(a*(-3.0f*a + 3.0f) + 3.0f) + 1.0f);
			}
			
			float BakeryBicubic_w3(float a)
			{
				return (1.0f/6.0f)*(a*a*a);
			}
			
			float BakeryBicubic_g0(float a)
			{
				return BakeryBicubic_w0(a) + BakeryBicubic_w1(a);
			}
			
			float BakeryBicubic_g1(float a)
			{
				return BakeryBicubic_w2(a) + BakeryBicubic_w3(a);
			}
			
			float BakeryBicubic_h0(float a)
			{
				return -1.0f + BakeryBicubic_w1(a) / (BakeryBicubic_w0(a) + BakeryBicubic_w1(a)) + 0.5f;
			}
			
			float BakeryBicubic_h1(float a)
			{
				return 1.0f + BakeryBicubic_w3(a) / (BakeryBicubic_w2(a) + BakeryBicubic_w3(a)) + 0.5f;
			}
			#endif
			
			#if defined(BAKERY_RNM) || defined(BAKERY_SH)
			sampler2D _RNM0, _RNM1, _RNM2;
			float4 _RNM0_TexelSize;
			#endif
			
			#ifdef BAKERY_VOLUME
			Texture3D _Volume0, _Volume1, _Volume2, _VolumeMask;
			SamplerState sampler_Volume0;
			
			#ifndef PROPERTIES_DEFINED
			float3 _VolumeMin, _VolumeInvSize;
			float3 _GlobalVolumeMin, _GlobalVolumeInvSize;
			#endif
			
			#endif
			
			#ifdef BAKERY_BICUBIC
			// Bicubic
			float4 BakeryTex2D(sampler2D tex, float2 uv, float4 texelSize)
			{
				float x = uv.x * texelSize.z;
				float y = uv.y * texelSize.z;
				
				x -= 0.5f;
				y -= 0.5f;
				
				float px = floor(x);
				float py = floor(y);
				
				float fx = x - px;
				float fy = y - py;
				
				float g0x = BakeryBicubic_g0(fx);
				float g1x = BakeryBicubic_g1(fx);
				float h0x = BakeryBicubic_h0(fx);
				float h1x = BakeryBicubic_h1(fx);
				float h0y = BakeryBicubic_h0(fy);
				float h1y = BakeryBicubic_h1(fy);
				
				return     BakeryBicubic_g0(fy) * ( g0x * tex2D(tex, (float2(px + h0x, py + h0y) * texelSize.x))   +
				g1x * tex2D(tex, (float2(px + h1x, py + h0y) * texelSize.x))) +
				
				BakeryBicubic_g1(fy) * ( g0x * tex2D(tex, (float2(px + h0x, py + h1y) * texelSize.x))   +
				g1x * tex2D(tex, (float2(px + h1x, py + h1y) * texelSize.x)));
			}
			float4 BakeryTex2D(Texture2D tex, SamplerState s, float2 uv, float4 texelSize)
			{
				float x = uv.x * texelSize.z;
				float y = uv.y * texelSize.z;
				
				x -= 0.5f;
				y -= 0.5f;
				
				float px = floor(x);
				float py = floor(y);
				
				float fx = x - px;
				float fy = y - py;
				
				float g0x = BakeryBicubic_g0(fx);
				float g1x = BakeryBicubic_g1(fx);
				float h0x = BakeryBicubic_h0(fx);
				float h1x = BakeryBicubic_h1(fx);
				float h0y = BakeryBicubic_h0(fy);
				float h1y = BakeryBicubic_h1(fy);
				
				return     BakeryBicubic_g0(fy) * ( g0x * tex.Sample(s, (float2(px + h0x, py + h0y) * texelSize.x))   +
				g1x * tex.Sample(s, (float2(px + h1x, py + h0y) * texelSize.x))) +
				
				BakeryBicubic_g1(fy) * ( g0x * tex.Sample(s, (float2(px + h0x, py + h1y) * texelSize.x))   +
				g1x * tex.Sample(s, (float2(px + h1x, py + h1y) * texelSize.x)));
			}
			#else
			// Bilinear
			float4 BakeryTex2D(sampler2D tex, float2 uv, float4 texelSize)
			{
				return tex2D(tex, uv);
			}
			float4 BakeryTex2D(Texture2D tex, SamplerState s, float2 uv, float4 texelSize)
			{
				return tex.Sample(s, uv);
			}
			#endif
			
			#ifdef DIRLIGHTMAP_COMBINED
			#ifdef BAKERY_LMSPEC
			float BakeryDirectionalLightmapSpecular(float2 lmUV, float3 normalWorld, float3 viewDir, float smoothness)
			{
				float3 dominantDir = UNITY_SAMPLE_TEX2D_SAMPLER(unity_LightmapInd, unity_Lightmap, lmUV).xyz * 2 - 1;
				half3 halfDir = Unity_SafeNormalize(normalize(dominantDir) - viewDir);
				half nh = saturate(dot(normalWorld, halfDir));
				half perceptualRoughness = SmoothnessToPerceptualRoughness(smoothness);
				half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
				half spec = GGXTerm(nh, roughness);
				return spec;
			}
			#endif
			#endif
			
			#ifdef BAKERY_RNM
			void BakeryRNM(inout float3 diffuseColor, inout float3 specularColor, float2 lmUV, float3 normalMap, float perceptualRoughness, float3 viewDirT)
			{
				normalMap.g *= -1;
				float3 rnm0 = DecodeLightmap(BakeryTex2D(_RNM0, lmUV, _RNM0_TexelSize));
				float3 rnm1 = DecodeLightmap(BakeryTex2D(_RNM1, lmUV, _RNM0_TexelSize));
				float3 rnm2 = DecodeLightmap(BakeryTex2D(_RNM2, lmUV, _RNM0_TexelSize));
				
				#ifdef BAKERY_SSBUMP
				diffuseColor = normalMap.x * rnm0
				+ normalMap.z * rnm1
				+ normalMap.y * rnm2;
				diffuseColor *= 2;
				#else
				diffuseColor = saturate(dot(rnmBasis0, normalMap)) * rnm0
				+ saturate(dot(rnmBasis1, normalMap)) * rnm1
				+ saturate(dot(rnmBasis2, normalMap)) * rnm2;
				#endif
				
				#ifdef BAKERY_LMSPEC
				float3 dominantDirT = rnmBasis0 * dot(rnm0, lumaConv) +
				rnmBasis1 * dot(rnm1, lumaConv) +
				rnmBasis2 * dot(rnm2, lumaConv);
				
				float3 dominantDirTN = normalize(dominantDirT);
				float3 specColor = saturate(dot(rnmBasis0, dominantDirTN)) * rnm0 +
				saturate(dot(rnmBasis1, dominantDirTN)) * rnm1 +
				saturate(dot(rnmBasis2, dominantDirTN)) * rnm2;
				
				half3 halfDir = Unity_SafeNormalize(dominantDirTN - viewDirT);
				half nh = saturate(dot(normalMap, halfDir));
				half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
				half spec = GGXTerm(nh, roughness);
				specularColor = spec * specColor;
				#endif
			}
			#endif
			
			#ifdef BAKERY_SH
			void BakerySH(inout float3 diffuseColor, inout float3 specularColor, float2 lmUV, float3 normalWorld, float3 viewDir, float perceptualRoughness)
			{
				#ifdef SHADER_API_D3D11
				float3 L0 = DecodeLightmap(BakeryTex2D(unity_Lightmap, samplerunity_Lightmap, lmUV, _RNM0_TexelSize));
				#else
				float3 L0 = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, lmUV));
				#endif
				float3 nL1x = BakeryTex2D(_RNM0, lmUV, _RNM0_TexelSize) * 2 - 1;
				float3 nL1y = BakeryTex2D(_RNM1, lmUV, _RNM0_TexelSize) * 2 - 1;
				float3 nL1z = BakeryTex2D(_RNM2, lmUV, _RNM0_TexelSize) * 2 - 1;
				float3 L1x = nL1x * L0 * 2;
				float3 L1y = nL1y * L0 * 2;
				float3 L1z = nL1z * L0 * 2;
				
				float3 sh;
				#ifdef BAKERY_SHNONLINEAR
				float lumaL0 = dot(L0, float(1));
				float lumaL1x = dot(L1x, float(1));
				float lumaL1y = dot(L1y, float(1));
				float lumaL1z = dot(L1z, float(1));
				float lumaSH = shEvaluateDiffuseL1Geomerics(lumaL0, float3(lumaL1x, lumaL1y, lumaL1z), normalWorld);
				
				sh = L0 + normalWorld.x * L1x + normalWorld.y * L1y + normalWorld.z * L1z;
				float regularLumaSH = dot(sh, 1);
				//sh *= regularLumaSH < 0.001 ? 1 : (lumaSH / regularLumaSH);
				sh *= lerp(1, lumaSH / regularLumaSH, saturate(regularLumaSH*16));
				
				//sh.r = shEvaluateDiffuseL1Geomerics(L0.r, float3(L1x.r, L1y.r, L1z.r), normalWorld);
				//sh.g = shEvaluateDiffuseL1Geomerics(L0.g, float3(L1x.g, L1y.g, L1z.g), normalWorld);
				//sh.b = shEvaluateDiffuseL1Geomerics(L0.b, float3(L1x.b, L1y.b, L1z.b), normalWorld);
				
				#else
				sh = L0 + normalWorld.x * L1x + normalWorld.y * L1y + normalWorld.z * L1z;
				#endif
				
				diffuseColor = max(sh, 0.0);
				
				#ifdef BAKERY_LMSPEC
				float3 dominantDir = float3(dot(nL1x, lumaConv), dot(nL1y, lumaConv), dot(nL1z, lumaConv));
				float focus = saturate(length(dominantDir));
				half3 halfDir = Unity_SafeNormalize(normalize(dominantDir) - viewDir);
				half nh = saturate(dot(normalWorld, halfDir));
				half roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
				half spec = GGXTerm(nh, roughness);
				
				sh = L0 + dominantDir.x * L1x + dominantDir.y * L1y + dominantDir.z * L1z;
				
				specularColor = max(spec * sh, 0.0);
				#endif
			}
			#endif
			
			#endif
			//BAKERY_ENABLED
			
			#if defined(NEED_DEPTH)
			UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
			#endif
			
			half _Smoothness;
			half _Metallic;
			half _OcclusionStrength;
			half _BumpScale;
			half _HeightScale;
			half _HeightRefPlane;
			half _HeightStepsMin;
			half _HeightStepsMax;
			half _DAlbedoScale;
			half _DNormalScale;
			half _DSmoothScale;
			half _VertexHeightAmount;
			half _VertexHeightOffset;
			half _TessFactor;
			half _TessMinDist;
			half _TessMaxDist;
			half _TessEdgeLength;
			half _TessMaxDisplacement;
			half _SpecOcclusion;
			half _SpecularRoughnessMod;
			half2 GLOBAL_uv;
			half4 _Color;
			half4 _MainTex_ST;
			half4 _MetallicRemap;
			half4 _SmoothnessRemap;
			half4 _MaskMap_TexelSize;
			half4 _EmissionColor;
			half4 GLOBAL_maskMap;
			half4 _DDetailsMap_ST;
			float _GSAAVariance;
			float _GSAAThreshold;
			int _AlbedoChannel;
			int _MappingSpace;
			int _PlanarAxisX;
			int _PlanarAxisY;
			int _MetalChannel;
			int _AOChannel;
			int _DetailMaskChannel;
			int _SmoothChannel;
			int _RoughnessMode;
			int _DetailAsTintMask;
			int _FlipBumpY;
			int _EmissionChannel;
			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);
			TEXTURE2D(_MaskMap);
			SAMPLER(sampler_MaskMap);
			TEXTURE2D(_BumpMap);
			SAMPLER(sampler_BumpMap);
			TEXTURE2D(_EmissionMap);
			SAMPLER(sampler_EmissionMap);
			TEXTURE2D(_Height);
			SAMPLER(sampler_Height);
			int _DIgnoreMask;
			int _DMappingSpace;
			int _DUVChannel;
			int _DPlanarAxisX;
			int _DPlanarAxisY;
			int _DNormalFlipY;
			TEXTURE2D(_DDetailsMap);
			SAMPLER(sampler_DDetailsMap);
			TEXTURE2D(_DDetailsNormal);
			SAMPLER(sampler_DDetailsNormal);
			TEXTURE2D(_VertexHeight);
			SAMPLER(sampler_VertexHeight);
			TEXTURE2D(_DFG);
			SAMPLER(sampler_DFG);
			
			void VHVertex() {
				half2 uv = vD.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				half height = (SAMPLE_TEXTURE2D_LOD(_VertexHeight, sampler_VertexHeight, uv, 0).r * 2 - 1);
				half3 mainOffset = vD.vertex.xyz + vD.normal * (height + _VertexHeightOffset) * _VertexHeightAmount;
				vD.vertex.xyz = mainOffset;
			}
			
			void ParallaxFragment()
			{
				GLOBAL_uv = d.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				#if PARALLAX && !defined(PLAT_QUEST)
				half customHeight = 0;
				GLOBAL_uv = POM(_Height, sampler_Height, GLOBAL_uv, ddx(GLOBAL_uv), ddy(GLOBAL_uv), d.worldNormal, d.worldSpaceViewDir, d.tangentSpaceViewDir, _HeightStepsMin, _HeightStepsMax, _HeightScale, _HeightRefPlane, half2(1, 1), half2(0, 0), 0, customHeight);
				#endif
			}
			
			void BaseFragmentFunction()
			{
				#if !defined(_SET_GLOBAL_UVS)
				GLOBAL_uv = d.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				#endif
				if (_MappingSpace > 0)
				{
					GLOBAL_uv = (_MappingSpace - 1) ? half2(d.worldSpacePosition[_PlanarAxisX], d.worldSpacePosition[_PlanarAxisY]) : half2(d.localSpacePosition[_PlanarAxisX], d.localSpacePosition[_PlanarAxisY]);
					GLOBAL_uv = GLOBAL_uv * _MainTex_ST.xy + _MainTex_ST.zw;
				}
				half4 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, GLOBAL_uv);
				if (_AlbedoChannel > 0)
				{
					albedo.rgb = albedo[_AlbedoChannel].xxx;
				}
				half4 masks = SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap, GLOBAL_uv);
				half4 normalTex = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, GLOBAL_uv);
				if (_FlipBumpY)
				{
					normalTex.y = 1 - normalTex.y;
				}
				half3 normal = UnpackScaleNormal(normalTex, _BumpScale);
				half3 emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, GLOBAL_uv).rgb;
				if (_EmissionChannel > 0)
				{
					emission.rgb = emission[_EmissionChannel].xxx;
				}
				int hasMasks = _MaskMap_TexelSize.z > 8;
				half metal = masks[_MetalChannel];
				half smooth = masks[_SmoothChannel];
				if (_RoughnessMode)
				{
					smooth = 1 - smooth;
				}
				half detailMask = masks[_DetailMaskChannel];
				half occlusion = masks[_AOChannel];
				metal = remap(metal, 0, 1, _MetallicRemap.x, _MetallicRemap.y);
				smooth = remap(smooth, 0, 1, _SmoothnessRemap.x, _SmoothnessRemap.y);
				GLOBAL_maskMap = half4(metal, occlusion, detailMask, smooth);
				o.Metallic = lerp(_Metallic, metal, hasMasks);
				o.Smoothness = lerp(_Smoothness, smooth, hasMasks);
				o.Occlusion = lerp(1, occlusion, _OcclusionStrength);
				o.Normal = normal;
				if (!_DetailAsTintMask)
				{
					o.Albedo = albedo.rgb * _Color.rgb;
				}
				else
				{
					o.Albedo = lerp(albedo, albedo.rgb * _Color.rgb, detailMask);
				}
				o.Alpha = albedo.a * _Color.a;
				#if defined(_EMISSION)
				o.Emission = emission * _EmissionColor;
				#endif
			}
			
			void DetailsFragment()
			{
				#if defined(DETAILS_OVERLAY)
				half masks = 0;
				#if defined(_MASKMAP_SAMPLED)
				masks = GLOBAL_maskMap.b;
				#else
				masks = 1;
				#endif
				half mask = lerp(masks, 1, _DIgnoreMask);
				half2 uv = d.uv0.xy;
				switch(_DUVChannel)
				{
					case 1: uv = d.uv1.xy; break;
					case 2: uv = d.uv2.xy; break;
					case 3: uv = d.uv3.xy; break;
					default: uv = d.uv0.xy; break;
				}
				uv = uv * _DDetailsMap_ST.xy + _DDetailsMap_ST.zw;
				if (_DMappingSpace > 0)
				{
					uv = (_DMappingSpace - 1) ? half2(d.worldSpacePosition[_DPlanarAxisX], d.worldSpacePosition[_DPlanarAxisY]) : half2(d.localSpacePosition[_DPlanarAxisX], d.localSpacePosition[_DPlanarAxisY]);
					uv = uv * _DDetailsMap_ST.xy + _DDetailsMap_ST.zw;
				}
				
				half4 detailsMap = SAMPLE_TEXTURE2D(_DDetailsMap, sampler_DDetailsMap, uv);
				
				#if defined(DETAILS_MODE_PACKED)
				half detailAlbedo = detailsMap.r * 2.0 - 1.0;
				half detailSmooth = detailsMap.b * 2.0 - 1.0;
				half3 detailNormal = 0;
				if (_DNormalFlipY)
				{
					detailsMap.g = 1 - detailsMap.g;
				}
				detailNormal = UnpackNormalAG(detailsMap, _DNormalScale);
				half detailAlbedoSpeed = saturate(abs(detailAlbedo) * _DAlbedoScale);
				#elif defined(DETAILS_MODE_SEPARATED)
				half3 detailAlbedo = detailsMap.rgb * 2.0 - 1.0;
				half detailSmooth = detailsMap.a * 2.0 - 1.0;
				
				half4 packedNormal = SAMPLE_TEXTURE2D(_DDetailsNormal, sampler_DDetailsNormal, uv);
				if (_DNormalFlipY)
				{
					packedNormal.g = 1 - packedNormal.g;
				}
				half3 detailNormal = UnpackScaleNormal(packedNormal, _DNormalScale);
				
				half3 detailAlbedoSpeed = saturate(abs(detailAlbedo) * _DAlbedoScale);
				#endif
				
				half3 albedoOverlay = lerp(sqrt(o.Albedo), (detailAlbedo < 0.0) ? 0.0.xxx : 1.0.xxx, detailAlbedoSpeed * detailAlbedoSpeed);
				albedoOverlay *= albedoOverlay;
				o.Albedo = lerp(o.Albedo, saturate(albedoOverlay), mask);
				
				half detailSmoothSpeed = saturate(abs(detailSmooth) * _DSmoothScale);
				half smoothOverlay = lerp(o.Smoothness, (detailSmooth < 0.0) ? 0.0 : 1.0, detailSmoothSpeed * detailSmoothSpeed);
				o.Smoothness = lerp(o.Smoothness, saturate(smoothOverlay), mask);
				
				o.Normal = lerp(o.Normal, BlendNormals(o.Normal, detailNormal), mask);
				#endif
			}
			
			void ORLLighting()
			{
				#if !defined(UNITY_PASS_SHADOWCASTER)
				half reflectance = 0.5;
				half3 f0 = 0.16 * reflectance * reflectance * (1 - o.Metallic) + o.Albedo * o.Metallic;
				half3 pixelLight = 0;
				half3 indirectDiffuse = 1;
				half3 indirectSpecular = 0;
				half3 directSpecular = 0;
				half occlusion = o.Occlusion;
				half perceptualRoughness = 1 - o.Smoothness;
				half3 tangentNormal = o.Normal;
				o.Normal = normalize(mul(o.Normal, d.TBNMatrix));
				
				#ifndef USING_DIRECTIONAL_LIGHT
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(d.worldSpacePosition));
				#else
				fixed3 lightDir = _WorldSpaceLightPos0.xyz;
				#endif
				
				#if defined(GSAA)
				perceptualRoughness = GSAA_Filament(o.Normal, perceptualRoughness, _GSAAVariance, _GSAAThreshold);
				#endif
				
				UNITY_LIGHT_ATTENUATION(lightAttenuation, FragData, d.worldSpacePosition);
				half3 lightColor = lightAttenuation * _LightColor0.rgb;
				
				half3 lightHalfVector = Unity_SafeNormalize(lightDir + d.worldSpaceViewDir);
				half lightNoL = saturate(dot(o.Normal, lightDir));
				half lightLoH = saturate(dot(lightDir, lightHalfVector));
				
				half NoV = abs(dot(o.Normal, d.worldSpaceViewDir)) + 1e-5;
				pixelLight = lightNoL * lightColor * Fd_Burley(perceptualRoughness, NoV, lightNoL, lightLoH);
				
				// READ THE LIGHTMAP
				#if defined(LIGHTMAP_ON) && !defined(UNITY_PASS_FORWARDADD)
				half3 lightMap = 0;
				half4 bakedColorTex = 0;
				half2 lightmapUV = FragData.lightmapUv.xy;
				
				// UNITY LIGHTMAPPING
				#if !defined(BAKERYLM_ENABLED) || !defined(BAKERY_ENABLED)
				lightMap = tex2DFastBicubicLightmap(lightmapUV, bakedColorTex);
				#endif
				
				// BAKERY RNM MODE (why do we even support it??)
				#if defined(BAKERY_RNM) && defined(BAKERY_ENABLED)
				half3 rnm0 = DecodeLightmap(BakeryTex2D(_RNM0, lightmapUV, _RNM0_TexelSize));
				half3 rnm1 = DecodeLightmap(BakeryTex2D(_RNM1, lightmapUV, _RNM0_TexelSize));
				half3 rnm2 = DecodeLightmap(BakeryTex2D(_RNM2, lightmapUV, _RNM0_TexelSize));
				
				lightMap = saturate(dot(rnmBasis0, tangentNormal)) * rnm0 +
				saturate(dot(rnmBasis1, tangentNormal)) * rnm1 +
				saturate(dot(rnmBasis2, tangentNormal)) * rnm2;
				#endif
				
				// BAKERY SH MODE (these are also used for the specular)
				#if defined(BAKERY_SH) && defined(BAKERY_ENABLED)
				half3 L0 = DecodeLightmap(BakeryTex2D(unity_Lightmap, samplerunity_Lightmap, lightmapUV, _RNM0_TexelSize));
				
				half3 nL1x = BakeryTex2D(_RNM0, lightmapUV, _RNM0_TexelSize) * 2.0 - 1.0;
				half3 nL1y = BakeryTex2D(_RNM1, lightmapUV, _RNM0_TexelSize) * 2.0 - 1.0;
				half3 nL1z = BakeryTex2D(_RNM2, lightmapUV, _RNM0_TexelSize) * 2.0 - 1.0;
				half3 L1x = nL1x * L0 * 2.0;
				half3 L1y = nL1y * L0 * 2.0;
				half3 L1z = nL1z * L0 * 2.0;
				
				// Non-Linear mode
				#if defined(BAKERY_SHNONLINEAR)
				half lumaL0 = dot(L0, half(1));
				half lumaL1x = dot(L1x, half(1));
				half lumaL1y = dot(L1y, half(1));
				half lumaL1z = dot(L1z, half(1));
				half lumaSH = shEvaluateDiffuseL1Geomerics_local(lumaL0, half3(lumaL1x, lumaL1y, lumaL1z), o.Normal);
				
				lightMap = L0 + o.Normal.x * L1x + o.Normal.y * L1y + o.Normal.z * L1z;
				half regularLumaSH = dot(lightMap, 1.0);
				lightMap *= lerp(1.0, lumaSH / regularLumaSH, saturate(regularLumaSH * 16.0));
				#else
				lightMap = L0 + o.Normal.x * L1x + o.Normal.y * L1y + o.Normal.z * L1z;
				#endif
				
				#endif
				
				#if defined(DIRLIGHTMAP_COMBINED)
				half4 lightMapDirection = UNITY_SAMPLE_TEX2D_SAMPLER(unity_LightmapInd, unity_Lightmap, lightmapUV);
				#if !defined(BAKERY_MONOSH)
				lightMap = DecodeDirectionalLightmap(lightMap, lightMapDirection, o.Normal);
				#endif
				#endif
				
				#if defined(BAKERY_MONOSH) && defined(BAKERY_ENABLED) && defined(DIRLIGHTMAP_COMBINED)
				half3 L0 = tex2DFastBicubicLightmap(lightmapUV, bakedColorTex);
				half3 nL1 = lightMapDirection.xyz * 2.0 - 1.0;
				half3 L1x = nL1.x * L0 * 2.0;
				half3 L1y = nL1.y * L0 * 2.0;
				half3 L1z = nL1.z * L0 * 2.0;
				
				#if defined(BAKERY_SHNONLINEAR)
				half lumaL0 = dot(L0, 1);
				half lumaL1x = dot(L1x, 1);
				half lumaL1y = dot(L1y, 1);
				half lumaL1z = dot(L1z, 1);
				half lumaSH = shEvaluateDiffuseL1Geomerics(lumaL0, half3(lumaL1x, lumaL1y, lumaL1z), o.Normal);
				
				lightMap = L0 + o.Normal.x * L1x + o.Normal.y * L1y + o.Normal.z * L1z;
				half regularLumaSH = dot(lightMap, 1);
				lightMap *= lerp(1, lumaSH / regularLumaSH, saturate(regularLumaSH*16));
				#else
				lightMap = L0 + o.Normal.x * L1x + o.Normal.y * L1y + o.Normal.z * L1z;
				#endif
				
				lightMap = max(lightMap, 0.0);
				#endif
				
				#if defined(DYNAMICLIGHTMAP_ON) && !defined(UNITY_PBS_USE_BRDF2)
				half3 realtimeLightMap = getRealtimeLightmap(FragData.lightmapUv.zw, o.Normal);
				lightMap += realtimeLightMap;
				#endif
				
				#if defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN)
				pixelLight = 0;
				lightMap = SubtractMainLightWithRealtimeAttenuationFrowmLightmap(lightMap, lightAttenuation, bakedColorTex, o.Normal);
				#endif
				indirectDiffuse = lightMap;
				#else
				#if UNITY_LIGHT_PROBE_PROXY_VOLUME
				UNITY_BRANCH
				if (unity_ProbeVolumeParams.x == 1)
				{
					indirectDiffuse = SHEvalLinearL0L1_SampleProbeVolume(half4(o.Normal, 1), FragData.worldPos);
				}
				else
				{
					#endif
					indirectDiffuse = max(0, ShadeSH9(half4(o.Normal, 1)));
					#if UNITY_LIGHT_PROBE_PROXY_VOLUME
				}
				#endif
				#endif
				
				#if defined(LIGHTMAP_SHADOW_MIXING) && defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) && defined(LIGHTMAP_ON) && !defined(UNITY_PASS_FORWARDADD)
				pixelLight *= UnityComputeForwardShadows(FragData.lightmapUv.xy, d.worldSpacePosition, d.screenPos);
				#endif
				
				half3 dfguv = half3(NoV, perceptualRoughness, 0);
				half2 dfg = SAMPLE_TEXTURE2D(_DFG, sampler_DFG, dfguv).xy;
				half3 energyCompensation = 1.0 + f0 * (1.0 / dfg.y - 1.0);
				
				half rough = perceptualRoughness * perceptualRoughness;
				half clampedRoughness = max(rough, 0.002);
				
				#if !defined(SPECULAR_HIGHLIGHTS_OFF) && defined(USING_LIGHT_MULTI_COMPILE)
				half NoH = saturate(dot(o.Normal, lightHalfVector));
				half3 F = F_Schlick(lightLoH, f0);
				half D = D_GGX(NoH, clampedRoughness);
				half V = V_SmithGGXCorrelated(NoV, lightNoL, clampedRoughness);
				
				F *= energyCompensation;
				
				directSpecular = max(0, D * V * F) * pixelLight * UNITY_PI;
				#endif
				
				// BAKED SPECULAR
				#if defined(BAKED_SPECULAR) && !defined(BAKERYLM_ENABLED) && !defined(UNITY_PASS_FORWARDADD)
				{
					half3 bakedDominantDirection = 1;
					half3 bakedSpecularColor = 0;
					
					// only do it if we have a directional lightmap
					#if defined(DIRLIGHTMAP_COMBINED) && defined(LIGHTMAP_ON)
					bakedDominantDirection = (lightMapDirection.xyz) * 2 - 1;
					half directionality = max(0.001, length(bakedDominantDirection));
					bakedDominantDirection /= directionality;
					bakedSpecularColor = indirectDiffuse;
					#endif
					
					// if we do not have lightmap - derive the specular from probes
					//#ifndef LIGHTMAP_ON
					//bakedSpecularColor = half3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);
					//bakedDominantDirection = unity_SHAr.xyz + unity_SHAg.xyz + unity_SHAb.xyz;
					// #endif
					
					bakedDominantDirection = normalize(bakedDominantDirection);
					directSpecular += GetSpecularHighlights(o.Normal, bakedSpecularColor, bakedDominantDirection, f0, d.worldSpaceViewDir, lerp(1, clampedRoughness, _SpecularRoughnessMod), NoV, energyCompensation);
				}
				#endif
				
				half3 fresnel = F_Schlick(NoV, f0);
				
				// BAKERY DIRECT SPECULAR
				#if defined(BAKERY_LMSPEC) && defined(BAKERY_ENABLED) && !defined(UNITY_PASS_FORWARDADD)
				#if defined(BAKERY_RNM)
				{
					half3 viewDirTangent = -normalize(d.tangentSpaceViewDir);
					half3 dominantDirTangent = rnmBasis0 * dot(rnm0, lumaConv) +
					rnmBasis1 * dot(rnm1, lumaConv) +
					rnmBasis2 * dot(rnm2, lumaConv);
					
					half3 dominantDirTangentNormalized = normalize(dominantDirTangent);
					half3 specColor = saturate(dot(rnmBasis0, dominantDirTangentNormalized)) * rnm0 +
					saturate(dot(rnmBasis1, dominantDirTangentNormalized)) * rnm1 +
					saturate(dot(rnmBasis2, dominantDirTangentNormalized)) * rnm2;
					half3 halfDir = Unity_SafeNormalize(dominantDirTangentNormalized - viewDirTangent);
					half NoH = saturate(dot(tangentNormal, halfDir));
					half spec = D_GGX(NoH, lerp(1, clampedRoughness, _SpecularRoughnessMod));
					directSpecular += spec * specColor * fresnel;
				}
				#endif
				
				#if defined(BAKERY_SH)
				{
					half3 dominantDir = half3(dot(nL1x, lumaConv), dot(nL1y, lumaConv), dot(L1z, lumaConv));
					half3 halfDir = Unity_SafeNormalize(normalize(dominantDir) + d.worldSpaceViewDir);
					half NoH = saturate(dot(o.Normal, halfDir));
					half spec = D_GGX(NoH, lerp(1, clampedRoughness, _SpecularRoughnessMod));
					half3 sh = L0 + dominantDir.x * L1x + dominantDir.y * L1y + dominantDir.z * L1z;
					dominantDir = normalize(dominantDir);
					directSpecular += max(spec * sh, 0.0) * fresnel;
				}
				#endif
				
				#if defined(BAKERY_MONOSH)
				{
					half3 dominantDir = nL1;
					half focus = saturate(length(dominantDir));
					half3 halfDir = Unity_SafeNormalize(normalize(dominantDir) - d.worldSpaceViewDir);
					half NoH = saturate(dot(o.Normal, halfDir));
					half spec = D_GGX(NoH, lerp(1, clampedRoughness, _SpecularRoughnessMod));
					half3 sh = L0 + dominantDir.x * L1x + dominantDir.y * L1y + dominantDir.z * L1z;
					dominantDir = normalize(dominantDir);
					directSpecular += max(spec * sh, 0.0) * fresnel;
				}
				#endif
				#endif
				
				// REFLECTIONS
				#if !defined(UNITY_PASS_FORWARDADD)
				half3 reflDir = reflect(-d.worldSpaceViewDir, o.Normal);
				reflDir = lerp(reflDir, o.Normal, rough * rough);
				
				Unity_GlossyEnvironmentData envData;
				envData.roughness = perceptualRoughness;
				envData.reflUVW = getBoxProjection(reflDir, d.worldSpacePosition.xyz, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin.xyz, unity_SpecCube0_BoxMax.xyz);
				
				half3 probe0 = Unity_GlossyEnvironment(UNITY_PASS_TEXCUBE(unity_SpecCube0), unity_SpecCube0_HDR, envData);
				indirectSpecular = probe0;
				
				#if defined(UNITY_SPECCUBE_BLENDING)
				UNITY_BRANCH
				if (unity_SpecCube0_BoxMin.w < 0.99999)
				{
					envData.reflUVW = getBoxProjection(reflDir, d.worldSpacePosition.xyz, unity_SpecCube1_ProbePosition, unity_SpecCube1_BoxMin.xyz, unity_SpecCube1_BoxMax.xyz);
					half3 probe1 = Unity_GlossyEnvironment(UNITY_PASS_TEXCUBE_SAMPLER(unity_SpecCube1, unity_SpecCube0), unity_SpecCube1_HDR, envData);
					indirectSpecular = lerp(probe1, probe0, unity_SpecCube0_BoxMin.w);
				}
				#endif
				
				half horizon = min(1 + dot(reflDir, o.Normal), 1);
				dfg.x *= saturate(pow(dot(indirectDiffuse, 1), _SpecOcclusion));
				indirectSpecular = indirectSpecular * horizon * horizon * energyCompensation * EnvBRDFMultiscatter(dfg, f0);
				
				#if defined(_MASKMAP_SAMPLED)
				indirectSpecular *= computeSpecularAO(NoV, o.Occlusion, perceptualRoughness * perceptualRoughness);
				#endif
				#endif
				
				#if defined(_INTEGRATE_CUSTOMGI) && !defined(UNITY_PASS_FORWARDADD)
				IntegrateCustomGI(d, o, indirectSpecular, indirectDiffuse);
				#endif
				
				// FINAL COLOR
				FinalColor = half4(o.Albedo.rgb * (1 - o.Metallic) * (indirectDiffuse * occlusion + (pixelLight)) + indirectSpecular + directSpecular, o.Alpha);
				
				FinalColor.rgb += o.Emission;
				#endif
			}
			
			// Shadow Vertex
			TessVertex Vertex(VertexData v)
			{
				UNITY_SETUP_INSTANCE_ID(v);
				TessVertex o = (TessVertex) 0;
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				
				o.vertex = v.vertex;
				o.normal = v.normal;
				o.tangent = v.tangent;
				o.color = v.color;
				o.uv0 = v.uv0;
				o.uv1 = v.uv1;
				o.uv2 = v.uv2;
				o.uv3 = v.uv3;
				
				return o;
			}
			
			// Shadow Hull
			[maxtessfactor(MAX_TESSELLATION_FACTORS)]
			[UNITY_domain("tri")]
			[UNITY_outputcontrolpoints(3)]
			[UNITY_outputtopology("triangle_cw")]
			[UNITY_partitioning("integer")]
			[UNITY_patchconstantfunc("TessFactorsFunction")]
			TessVertex Hull(InputPatch<TessVertex, 3> patch, uint id : SV_OutputControlPointID)
			{
				return patch[id];
			}
			
			float4 GetTessFactors(InputPatch<TessVertex, 3> patch)
			{
				#if defined(TESS_MODE_DISTANCEBASED)
				float4 tessFactors = UnityDistanceBasedTess(
				patch[0].vertex,
				patch[1].vertex,
				patch[2].vertex,
				_TessMinDist,
				_TessMaxDist,
				_TessFactor
				);
				return tessFactors;
				#elif defined(TESS_MODE_EDGELENGTH)
				float4 tessFactors = UnityEdgeLengthBasedTessCull(
				patch[0].vertex,
				patch[1].vertex,
				patch[2].vertex,
				_TessEdgeLength,
				_TessMaxDisplacement
				);
				return tessFactors;
				#endif
				
				return 1..xxxx;
			}
			
			// Shadow TessFactor
			TessellationFactors TessFactorsFunction(InputPatch<TessVertex, 3> patch)
			{
				TessellationFactors f;
				float4 TessFactorsOutput = 0;
				#if defined(TESS_FACTORS_FUNC_DEFINED)
				TessFactorsOutput = GetTessFactors(patch);
				#else
				TessFactorsOutput = 1..xxxx;
				#endif
				f.edge[0] = TessFactorsOutput.x;
				f.edge[1] = TessFactorsOutput.y;
				f.edge[2] = TessFactorsOutput.z;
				f.inside = TessFactorsOutput.w;
				return f;
			}
			
			// Shadow Domain
			[UNITY_domain("tri")]
			FragmentData Domain(TessellationFactors factors, OutputPatch<TessVertex, 3> patch, float3 baryCoords : SV_DomainLocation)
			{
				VertexData v = (VertexData) 0;
				UNITY_TRANSFER_INSTANCE_ID(patch[0], v);
				v.vertex = patch[0].vertex * baryCoords.x + patch[1].vertex * baryCoords.y + patch[2].vertex * baryCoords.z;
				
				#if defined(PHONG)
				float3 pp[3];
				for (int index = 0; index < 3; ++index)
				{
					pp[index] = v.vertex.xyz - patch[index].normal * (dot(v.vertex.xyz, patch[index].normal) - dot(patch[index].vertex.xyz, patch[index].normal));
				}
				v.vertex.xyz = 0.5 * (pp[0]*baryCoords.x + pp[1]*baryCoords.y + pp[2]*baryCoords.z) + (0.5) * v.vertex.xyz;
				#endif
				
				v.normal = patch[0].normal * baryCoords.x + patch[1].normal * baryCoords.y + patch[2].normal * baryCoords.z;
				v.tangent = patch[0].tangent * baryCoords.x + patch[1].tangent * baryCoords.y + patch[2].tangent * baryCoords.z;
				v.color = patch[0].color * baryCoords.x + patch[1].color * baryCoords.y + patch[2].color * baryCoords.z;
				v.uv0 = patch[0].uv0 * baryCoords.x + patch[1].uv0 * baryCoords.y + patch[2].uv0 * baryCoords.z;
				v.uv1 = patch[0].uv1 * baryCoords.x + patch[1].uv1 * baryCoords.y + patch[2].uv1 * baryCoords.z;
				v.uv2 = patch[0].uv2 * baryCoords.x + patch[1].uv2 * baryCoords.y + patch[2].uv2 * baryCoords.z;
				v.uv3 = patch[0].uv3 * baryCoords.x + patch[1].uv3 * baryCoords.y + patch[2].uv3 * baryCoords.z;
				
				FragmentData i;
				UNITY_INITIALIZE_OUTPUT(FragmentData, i);
				UNITY_TRANSFER_INSTANCE_ID(patch[0], i);
				
				vD = v;
				FragData = i;
				VHVertex();
				
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
				i.vizUV = 0;
				i.lightCoord = 0;
				if (unity_VisualizationMode == EDITORVIZ_TEXTURE)
				i.vizUV = UnityMetaVizUV(unity_EditorViz_UVIndex, v.uv0.xy, v.uv1.xy, v.uv2.xy, unity_EditorViz_Texture_ST);
				else if (unity_VisualizationMode == EDITORVIZ_SHOWLIGHTMASK)
				{
					i.vizUV = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
					i.lightCoord = mul(unity_EditorViz_WorldToLight, mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1)));
				}
				#endif
				
				#if defined(NEED_SCREEN_POS)
				i.screenPos = ComputeScreenPos(i.pos);
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
				o.Smoothness = 0.5;
				o.Occlusion = 1;
				o.Alpha = 1;
				FinalColor = half4(o.Albedo, o.Alpha);
				
				ParallaxFragment();
				BaseFragmentFunction();
				DetailsFragment();
				
				#endif
				
				SHADOW_CASTER_FRAGMENT(i);
			}
			
			ENDCG
			// Shadow Pass End
			
		}
		
	}
	CustomEditor "ORL.ShaderInspector.InspectorGUI"
}
