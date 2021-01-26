// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "orels1/Ceiling Lights"
{
	Properties
	{
		[SingleLineTexture]_MainTex("MainTex", 2D) = "white" {}
		[HDR]_MainTexEmission("MainTex Emission", Color) = (1,1,1,0)
		[IntRange]_TilingCustom("Tiling", Range( 1 , 20)) = 1
		[SingleLineTexture]_NormalMap("NormalMap", 2D) = "bump" {}
		_NormalScale("NormalScale", Range( 0 , 1)) = 1
		[SingleLineTexture]_EmissionMap("EmissionMap", 2D) = "white" {}
		[HDR]_Emission("Emission", Color) = (1,1,1,1)
		_ParallaxScale("Parallax Scale", Range( 0 , 0.2)) = 0.07
		[SingleLineTexture]_EdgeMask("Edge Mask", 2D) = "white" {}
		[SingleLineTexture]_MetalSmooth("Metal Smooth", 2D) = "white" {}
		_SmoothnessScale("Smoothness Scale", Range( 0 , 1)) = 1
		_MetallicScale("Metallic Scale", Range( 0 , 1)) = 1
		[Header(Effects)][Enum(Disabled,0,Enabled,1)]_BrokenLights("Broken Lights", Float) = 0
		[Enum(Smooth,0,On or Off,1)]_BrokenType("Broken Type", Int) = 0
		_MinBrightness("Min Brightness", Range( 0 , 0.9)) = 0
		_RandomModifier("Random Modifier", Range( 1 , 1000)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 5.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 viewDir;
			INTERNAL_DATA
		};

		uniform sampler2D _NormalMap;
		uniform float _TilingCustom;
		uniform float _NormalScale;
		uniform sampler2D _MainTex;
		uniform int _BrokenType;
		uniform float _MinBrightness;
		uniform float4 _MainTex_ST;
		uniform float _RandomModifier;
		uniform float _BrokenLights;
		uniform float4 _MainTexEmission;
		uniform sampler2D _EmissionMap;
		uniform float _ParallaxScale;
		uniform float4 _Emission;
		uniform sampler2D _EdgeMask;
		uniform sampler2D _MetalSmooth;
		uniform float _MetallicScale;
		uniform float _SmoothnessScale;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float tileFactor84 = _TilingCustom;
			float2 appendResult40 = (float2(tileFactor84 , tileFactor84));
			float2 uv_TexCoord24 = i.uv_texcoord * appendResult40;
			float2 realUV42 = uv_TexCoord24;
			o.Normal = UnpackScaleNormal( tex2D( _NormalMap, realUV42 ), _NormalScale );
			float4 tex2DNode1 = tex2D( _MainTex, realUV42 );
			float minBrightness112 = _MinBrightness;
			float4 transform47 = mul(unity_ObjectToWorld,float4( 0,0,0,1 ));
			float2 appendResult49 = (float2(transform47.x , transform47.z));
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float dotResult4_g1 = dot( ( ( appendResult49 + trunc( ( uv_MainTex * tileFactor84 ) ) ) + _RandomModifier ) , float2( 12.9898,78.233 ) );
			float lerpResult10_g1 = lerp( minBrightness112 , 1.0 , frac( ( sin( dotResult4_g1 ) * 43758.55 ) ));
			float temp_output_48_0 = lerpResult10_g1;
			float brokenModifier55 = ( (float)_BrokenType == 0.0 ? temp_output_48_0 : ( temp_output_48_0 > 0.5 ? 1.0 : 0.0 ) );
			float clampResult116 = clamp( ( minBrightness112 + 0.2 ) , 0.0 , 0.9 );
			float brokenLights57 = _BrokenLights;
			float4 lerpResult69 = lerp( tex2DNode1 , ( tex2DNode1 * (clampResult116 + (brokenModifier55 - 0.0) * (1.0 - clampResult116) / (1.0 - 0.0)) ) , brokenLights57);
			o.Albedo = lerpResult69.rgb;
			float4 temp_output_16_0 = ( _MainTexEmission * tex2DNode1 );
			float4 lerpResult58 = lerp( temp_output_16_0 , ( brokenModifier55 * temp_output_16_0 ) , brokenLights57);
			float temp_output_31_0 = ( 1.0 / tileFactor84 );
			float2 temp_cast_2 = (temp_output_31_0).xx;
			float2 temp_cast_3 = (temp_output_31_0).xx;
			float2 tiledUV35 = (float2( 0,0 ) + (( uv_MainTex % temp_cast_2 ) - float2( 0,0 )) * (float2( 1,1 ) - float2( 0,0 )) / (temp_cast_3 - float2( 0,0 )));
			float2 Offset8 = ( ( 0.05 - 1 ) * ( i.viewDir.xy / i.viewDir.z ) * _ParallaxScale ) + tiledUV35;
			float4 tex2DNode3 = tex2D( _EmissionMap, Offset8 );
			float4 lerpResult61 = lerp( tex2DNode3 , ( tex2DNode3 * brokenModifier55 ) , brokenLights57);
			o.Emission = ( lerpResult58 + ( ( lerpResult61 * _Emission ) * tex2D( _EdgeMask, realUV42 ).r ) ).rgb;
			float4 tex2DNode7 = tex2D( _MetalSmooth, realUV42 );
			float lerpResult19 = lerp( 0.0 , tex2DNode7.r , _MetallicScale);
			o.Metallic = lerpResult19;
			float lerpResult21 = lerp( 0.0 , tex2DNode7.a , _SmoothnessScale);
			o.Smoothness = lerpResult21;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 5.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = IN.tSpace0.xyz * worldViewDir.x + IN.tSpace1.xyz * worldViewDir.y + IN.tSpace2.xyz * worldViewDir.z;
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ORS1MaterialEditor"
}
/*ASEBEGIN
Version=18800
11;279;1910;1099;3787.945;1308.687;2.15037;True;False
Node;AmplifyShaderEditor.CommentaryNode;110;-2636.06,-780.6653;Inherit;False;1602.852;564.2971;;11;46;84;29;33;31;32;34;35;40;24;42;Generate Tiled UVs;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-2586.06,-383.1019;Inherit;False;Property;_TilingCustom;Tiling;2;1;[IntRange];Create;False;0;0;0;False;0;False;1;1;1;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;84;-2248.153,-379.2818;Inherit;False;tileFactor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;109;-2110.538,1380.879;Inherit;False;2301.157;621.7666;;18;91;94;47;103;102;49;66;104;81;48;80;78;79;55;52;57;111;112;Broken Lights;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;94;-2035.961,1887.646;Inherit;False;84;tileFactor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;91;-2060.538,1760.937;Inherit;False;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;47;-1859.464,1544.835;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;-1774.085,1774.652;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TruncOpNode;102;-1602.363,1771.419;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;49;-1547.464,1557.435;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-2221.545,-492.2324;Inherit;False;Constant;_Float1;Float 1;12;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-1316.204,1741.096;Inherit;False;Property;_RandomModifier;Random Modifier;15;0;Create;True;0;0;0;False;0;False;1;0;1;1000;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;111;-1306.543,1838.465;Inherit;False;Property;_MinBrightness;Min Brightness;14;0;Create;True;0;0;0;False;0;False;0;0;0;0.9;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;104;-1267.422,1578.251;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;33;-2244.734,-730.6653;Inherit;False;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;31;-2013.867,-456.7319;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;81;-1008.814,1587.036;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleRemainderNode;32;-1918.361,-629.9795;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;112;-991.5432,1843.465;Inherit;False;minBrightness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;34;-1694.569,-636.2748;Inherit;False;5;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;1,0;False;3;FLOAT2;0,0;False;4;FLOAT2;1,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;48;-835.463,1557.935;Inherit;False;Random Range;-1;;1;7b754edb8aebbfb4a9ace907af661cfc;0;3;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;35;-1351.997,-656.7783;Inherit;False;tiledUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.IntNode;80;-464.8136,1538.036;Inherit;False;Property;_BrokenType;Broken Type;13;1;[Enum];Create;True;0;2;Smooth;0;On or Off;1;0;False;0;False;0;0;False;0;1;INT;0
Node;AmplifyShaderEditor.Compare;78;-576.8135,1670.035;Inherit;False;2;4;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-2135.685,283.0597;Inherit;False;Constant;_Float0;Float 0;5;0;Create;True;0;0;0;False;0;False;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;40;-1789.032,-349.5599;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Compare;79;-257.8136,1611.036;Inherit;False;0;4;0;INT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;38;-2164.115,143.6198;Inherit;False;35;tiledUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-2222.688,367.7242;Inherit;False;Property;_ParallaxScale;Parallax Scale;7;0;Create;True;0;0;0;False;0;False;0.07;0.18;0;0.2;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;13;-2146.353,470.3919;Inherit;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;24;-1617.508,-372.3682;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ParallaxMappingNode;8;-1775.19,129.6839;Inherit;False;Planar;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-769.9685,1431.244;Inherit;False;Property;_BrokenLights;Broken Lights;12;2;[Header];[Enum];Create;True;1;Effects;2;Disabled;0;Enabled;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;55;-61.38086,1603.379;Float;False;brokenModifier;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;114;-643.6241,-161.2037;Inherit;False;112;minBrightness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;42;-1276.208,-400.453;Float;False;realUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;57;-545.7808,1430.879;Inherit;False;brokenLights;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-1390.291,131.7536;Inherit;True;Property;_EmissionMap;EmissionMap;5;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;688edf4a1a753e046a8d0d368b314d8c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;62;-1424.399,393.1935;Inherit;False;55;brokenModifier;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;115;-422.6241,-161.2037;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-1044.668,236.8126;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;1;-661.765,-371.5336;Inherit;True;Property;_MainTex;MainTex;0;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;5316eab40e293bd468d85837f232d3a0;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;17;-561.4705,-738.193;Inherit;False;Property;_MainTexEmission;MainTex Emission;1;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;63;-1091.244,351.5794;Inherit;False;57;brokenLights;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-226.2888,-503.3743;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;4;-643.6263,328.5248;Inherit;False;Property;_Emission;Emission;6;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;2.79544,2.79544,2.79544,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;43;-355.0597,367.9183;Inherit;False;42;realUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;61;-831.3569,134.2983;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;116;-261.6241,-159.2037;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.9;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;70;-355.4291,-234.0283;Inherit;False;55;brokenModifier;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;56;-170.5549,-619.4204;Inherit;False;55;brokenModifier;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;14;-157.4013,281.9658;Inherit;True;Property;_EdgeMask;Edge Mask;8;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;2a5df3d1d35aa224fa9bc8ceba32a0d2;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-177,139.5;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;44;-817.4597,636.718;Inherit;False;42;realUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;72;-73.78719,-201.6679;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.2;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;59;-10.6554,-703.9201;Inherit;False;57;brokenLights;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;55.62536,-521.9198;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;73;-31.30365,-290.3931;Inherit;False;57;brokenLights;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-579.3672,530.1331;Inherit;False;Property;_MetallicScale;Metallic Scale;11;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;140.3241,136.3909;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;58;293.7031,-593.393;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;127.9078,-191.6736;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-971.7673,25.8338;Inherit;False;Property;_NormalScale;NormalScale;4;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-576.3672,807.1331;Inherit;False;Property;_SmoothnessScale;Smoothness Scale;10;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;7;-592,607.5;Inherit;True;Property;_MetalSmooth;Metal Smooth;9;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;9e66b54171dacd04a953b3aefe81d3ec;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-633.775,-68.5;Inherit;True;Property;_NormalMap;NormalMap;3;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;80dd485be14f27e46bc948cbe49a8208;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;21;-23.36719,663.1331;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;18;425.0966,85.02731;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;69;271.3913,-322.2557;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;19;-26.36719,536.1331;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1252.445,-103.1684;Float;False;True;-1;7;ORS1MaterialEditor;0;0;Standard;orels1/Ceiling Lights;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;84;0;46;0
WireConnection;103;0;91;0
WireConnection;103;1;94;0
WireConnection;102;0;103;0
WireConnection;49;0;47;1
WireConnection;49;1;47;3
WireConnection;104;0;49;0
WireConnection;104;1;102;0
WireConnection;31;0;29;0
WireConnection;31;1;84;0
WireConnection;81;0;104;0
WireConnection;81;1;66;0
WireConnection;32;0;33;0
WireConnection;32;1;31;0
WireConnection;112;0;111;0
WireConnection;34;0;32;0
WireConnection;34;2;31;0
WireConnection;48;1;81;0
WireConnection;48;2;112;0
WireConnection;35;0;34;0
WireConnection;78;0;48;0
WireConnection;40;0;84;0
WireConnection;40;1;84;0
WireConnection;79;0;80;0
WireConnection;79;2;48;0
WireConnection;79;3;78;0
WireConnection;24;0;40;0
WireConnection;8;0;38;0
WireConnection;8;1;9;0
WireConnection;8;2;10;0
WireConnection;8;3;13;0
WireConnection;55;0;79;0
WireConnection;42;0;24;0
WireConnection;57;0;52;0
WireConnection;3;1;8;0
WireConnection;115;0;114;0
WireConnection;64;0;3;0
WireConnection;64;1;62;0
WireConnection;1;1;42;0
WireConnection;16;0;17;0
WireConnection;16;1;1;0
WireConnection;61;0;3;0
WireConnection;61;1;64;0
WireConnection;61;2;63;0
WireConnection;116;0;115;0
WireConnection;14;1;43;0
WireConnection;6;0;61;0
WireConnection;6;1;4;0
WireConnection;72;0;70;0
WireConnection;72;3;116;0
WireConnection;60;0;56;0
WireConnection;60;1;16;0
WireConnection;15;0;6;0
WireConnection;15;1;14;1
WireConnection;58;0;16;0
WireConnection;58;1;60;0
WireConnection;58;2;59;0
WireConnection;71;0;1;0
WireConnection;71;1;72;0
WireConnection;7;1;44;0
WireConnection;2;1;42;0
WireConnection;2;5;23;0
WireConnection;21;1;7;4
WireConnection;21;2;22;0
WireConnection;18;0;58;0
WireConnection;18;1;15;0
WireConnection;69;0;1;0
WireConnection;69;1;71;0
WireConnection;69;2;73;0
WireConnection;19;1;7;1
WireConnection;19;2;20;0
WireConnection;0;0;69;0
WireConnection;0;1;2;0
WireConnection;0;2;18;0
WireConnection;0;3;19;0
WireConnection;0;4;21;0
ASEEND*/
//CHKSM=53E3D698BF7BE5371D3501A3E10DFF431ADCA46F