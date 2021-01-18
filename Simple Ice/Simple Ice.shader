// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "orels1/Simple Ice"
{
	Properties
	{
		_MainTex("Main Tex", 2D) = "white" {}
		_Color("Color", Color) = (0,0,0,0)
		_EmissionMap("EmissionMap", 2D) = "black" {}
		[HDR]_Emission("Emission", Color) = (0,0,0,0)
		_NormalMap("NormalMap", 2D) = "bump" {}
		_Metalness("Metalness", 2D) = "white" {}
		_MetalnessScale("Metalness Scale", Range( 0 , 1)) = 0
		_RoughnessMap("Roughness Map", 2D) = "black" {}
		_RoughnessScale("Roughness Scale", Range( 0 , 1)) = 0
		[Header(Parallax Controls)][Enum(Off,0,On,1)]_ParallaxEffects("Parallax Effects", Int) = 0
		_ParallaxLayer1("Parallax Layer 1", 2D) = "black" {}
		[HDR]_Layer1Color("Layer 1 Color", Color) = (1,1,1,0)
		_Layer1Strength("Layer 1 Strength", Range( 0 , 1)) = 0
		_Layer1Offset("Layer 1 Offset", Float) = 0
		_ParallaxLayer2("Parallax Layer 2", 2D) = "white" {}
		[HDR]_Layer2Color("Layer 2 Color", Color) = (1,1,1,0)
		_Layer2Strength("Layer 2 Strength", Range( 0 , 1)) = 0
		_Layer2Offset("Layer 2 Offset", Float) = 0
		[Header(Animation Controls)]_MovementMask("Movement Mask", 2D) = "white" {}
		_Layer1MaskMovement("Layer 1 Mask Movement", Vector) = (0,0,0,0)
		_PulseMask("Pulse Mask", 2D) = "white" {}
		_PulseMaskScrollDirection("Pulse Mask Scroll Direction", Vector) = (0.01,0.01,0,0)
		_PulseMaskStrength("Pulse Mask Strength", Float) = 10
		_Layer1Movement("Layer 1 Movement", Vector) = (0.002545739,0.002545739,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
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
		uniform float4 _NormalMap_ST;
		uniform int _ParallaxEffects;
		uniform sampler2D _PulseMask;
		uniform float2 _PulseMaskScrollDirection;
		uniform float4 _PulseMask_ST;
		uniform float _PulseMaskStrength;
		uniform float4 _Layer1Color;
		uniform sampler2D _MovementMask;
		uniform float2 _Layer1MaskMovement;
		uniform sampler2D _ParallaxLayer1;
		uniform float4 _ParallaxLayer1_ST;
		uniform float _Layer1Offset;
		uniform float2 _Layer1Movement;
		uniform float _Layer1Strength;
		uniform sampler2D _ParallaxLayer2;
		uniform float4 _ParallaxLayer2_ST;
		uniform float _Layer2Offset;
		uniform float _Layer2Strength;
		uniform float4 _Layer2Color;
		uniform float4 _Color;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _Emission;
		uniform sampler2D _EmissionMap;
		uniform float4 _EmissionMap_ST;
		uniform sampler2D _Metalness;
		uniform float4 _Metalness_ST;
		uniform float _MetalnessScale;
		uniform sampler2D _RoughnessMap;
		uniform float4 _RoughnessMap_ST;
		uniform float _RoughnessScale;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			o.Normal = UnpackNormal( tex2D( _NormalMap, uv_NormalMap ) );
			float2 uv_PulseMask = i.uv_texcoord * _PulseMask_ST.xy + _PulseMask_ST.zw;
			float2 panner86 = ( 1.0 * _Time.y * _PulseMaskScrollDirection + uv_PulseMask);
			float2 uv_ParallaxLayer1 = i.uv_texcoord * _ParallaxLayer1_ST.xy + _ParallaxLayer1_ST.zw;
			float2 panner80 = ( 1.0 * _Time.y * _Layer1MaskMovement + uv_ParallaxLayer1);
			float2 Offset77 = ( ( 0.1 - 1 ) * ( i.viewDir.xy / i.viewDir.z ) * _Layer1Offset ) + panner80;
			float2 panner66 = ( 1.0 * _Time.y * _Layer1Movement + uv_ParallaxLayer1);
			float2 Offset12 = ( ( 0.1 - 1 ) * ( i.viewDir.xy / i.viewDir.z ) * _Layer1Offset ) + panner66;
			float2 uv_ParallaxLayer2 = i.uv_texcoord * _ParallaxLayer2_ST.xy + _ParallaxLayer2_ST.zw;
			float2 Offset19 = ( ( 0.1 - 1 ) * ( i.viewDir.xy / i.viewDir.z ) * _Layer2Offset ) + uv_ParallaxLayer2;
			float4 parallaxOutput63 = ( _ParallaxEffects * ( ( ( tex2D( _PulseMask, panner86 ).r * _PulseMaskStrength ) * ( _Layer1Color * saturate( ( ( tex2D( _MovementMask, Offset77 ).r * tex2D( _ParallaxLayer1, Offset12 ).r ) * _Layer1Strength ) ) ) ) + ( saturate( ( tex2D( _ParallaxLayer2, Offset19 ).r * _Layer2Strength ) ) * _Layer2Color ) ) );
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			o.Albedo = ( parallaxOutput63 + ( _Color * tex2D( _MainTex, uv_MainTex ) ) ).rgb;
			float2 uv_EmissionMap = i.uv_texcoord * _EmissionMap_ST.xy + _EmissionMap_ST.zw;
			o.Emission = ( _Emission * tex2D( _EmissionMap, uv_EmissionMap ) ).rgb;
			float2 uv_Metalness = i.uv_texcoord * _Metalness_ST.xy + _Metalness_ST.zw;
			float lerpResult60 = lerp( 0.0 , tex2D( _Metalness, uv_Metalness ).r , _MetalnessScale);
			o.Metallic = lerpResult60;
			float2 uv_RoughnessMap = i.uv_texcoord * _RoughnessMap_ST.xy + _RoughnessMap_ST.zw;
			float lerpResult57 = lerp( 0.0 , ( 1.0 - tex2D( _RoughnessMap, uv_RoughnessMap ).r ) , _RoughnessScale);
			o.Smoothness = lerpResult57;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows exclude_path:deferred 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
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
117;180;1910;1208;965.0503;2540.645;1.271849;True;False
Node;AmplifyShaderEditor.CommentaryNode;65;-2194.532,-2000.073;Inherit;False;3912.386;1478.357;;38;29;28;30;26;24;25;22;23;18;33;32;35;10;20;36;19;12;63;31;38;9;16;37;66;73;77;78;79;80;84;85;86;87;88;89;90;91;92;Parallax;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;79;-1745.473,-1837.334;Inherit;False;0;10;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;16;-2077.564,-1579.24;Inherit;False;0;10;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;92;-2092.762,-1764.352;Inherit;False;Property;_Layer1Movement;Layer 1 Movement;24;0;Create;True;0;0;0;False;0;False;0.002545739,0.002545739;0.002545739,0.002545739;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;91;-2114.966,-1957.727;Inherit;False;Property;_Layer1MaskMovement;Layer 1 Mask Movement;19;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.PannerNode;80;-1308.674,-1848.534;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-2028.631,-1453.392;Inherit;False;Property;_Layer1Offset;Layer 1 Offset;13;0;Create;True;0;0;0;False;0;False;0;0.03;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;9;-2068.671,-1331.622;Inherit;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PannerNode;66;-1320.704,-1587.552;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ParallaxMappingNode;12;-691.5323,-1514.913;Inherit;False;Planar;4;0;FLOAT2;0,0;False;1;FLOAT;0.1;False;2;FLOAT;0.11;False;3;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ParallaxMappingNode;77;-670.9066,-1681.799;Inherit;False;Planar;4;0;FLOAT2;0,0;False;1;FLOAT;0.1;False;2;FLOAT;0.11;False;3;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;31;-2063.849,-1142.673;Inherit;False;0;20;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;10;-207.9044,-1524.985;Inherit;True;Property;_ParallaxLayer1;Parallax Layer 1;10;0;Create;True;0;0;0;True;0;False;-1;4177054a6a2fc65489900ec19111a5c5;02806d1ac32ad15438298bd87b7d9dc9;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;73;-405.1371,-1751.704;Inherit;True;Property;_MovementMask;Movement Mask;18;1;[Header];Create;True;1;Animation Controls;0;0;False;0;False;-1;27127545775166246b527ab88b7e5669;27127545775166246b527ab88b7e5669;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;38;-2038.585,-997.7231;Inherit;False;Property;_Layer2Offset;Layer 2 Offset;17;0;Create;True;0;0;0;False;0;False;0;0.15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ParallaxMappingNode;19;-473.9817,-1167.694;Inherit;False;Planar;4;0;FLOAT2;0,0;False;1;FLOAT;0.1;False;2;FLOAT;0.26;False;3;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;87;-505.1964,-1943.287;Inherit;False;0;84;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;8.126835,-1662.933;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;90;-263.2375,-1886.439;Inherit;False;Property;_PulseMaskScrollDirection;Pulse Mask Scroll Direction;22;0;Create;True;0;0;0;False;0;False;0.01,0.01;0.01,0.01;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;35;-180.3017,-1320.136;Inherit;False;Property;_Layer1Strength;Layer 1 Strength;12;0;Create;True;0;0;0;False;0;False;0;0.071;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;86;47.38506,-1926.48;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.001,0.001;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;20;-172.3127,-1185.997;Inherit;True;Property;_ParallaxLayer2;Parallax Layer 2;14;0;Create;True;0;0;0;False;0;False;-1;8280ae6037505f54ba58e2dc66ab3c60;467208d0cd234924e942e1257213d0bb;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;36;-169.1042,-989.1845;Inherit;False;Property;_Layer2Strength;Layer 2 Strength;16;0;Create;True;0;0;0;False;0;False;0;0.802;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;204.1483,-1537.867;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;23;167.2154,-1711.505;Inherit;False;Property;_Layer1Color;Layer 1 Color;11;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;0.1502126,1.365569,2.895007,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;18;401.2241,-1483.055;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;89;505.7625,-1731.439;Inherit;False;Property;_PulseMaskStrength;Pulse Mask Strength;23;0;Create;True;0;0;0;False;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;84;247.4742,-1941.385;Inherit;True;Property;_PulseMask;Pulse Mask;21;0;Create;True;0;0;0;False;0;False;-1;3c32269171a000d4f9904193192e8630;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;227.7877,-1213.138;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;22;404.618,-1154.424;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;25;195.196,-978.0605;Inherit;False;Property;_Layer2Color;Layer 2 Color;15;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;0,0.5598835,2.048354,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;739.9336,-1859.767;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;628.269,-1501.829;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;627.2948,-1171.297;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;779.1603,-1664.277;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;30;917.3401,-1285.378;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.IntNode;28;1020.289,-1481.259;Inherit;False;Property;_ParallaxEffects;Parallax Effects;9;2;[Header];[Enum];Create;True;1;Parallax Controls;2;Off;0;On;1;0;False;0;False;0;1;False;0;1;INT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;1217.527,-1238.507;Inherit;False;2;2;0;INT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;39;-615.8839,-158.8522;Inherit;False;Property;_Color;Color;1;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;5;-496.3323,577.2507;Inherit;True;Property;_RoughnessMap;Roughness Map;7;0;Create;True;0;0;0;False;0;False;-1;e4e86fe78a8b4b742992c75a9afb3ed8;e4e86fe78a8b4b742992c75a9afb3ed8;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;63;1409.827,-1219.4;Inherit;False;parallaxOutput;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;1;-629.7911,19.15814;Inherit;True;Property;_MainTex;Main Tex;0;0;Create;True;0;0;0;False;0;False;-1;b8e11a440e4c999469fa466e73b2e9f0;4ffdf295a87a27d4ab5947fd970bec2c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-275.9191,-52.58581;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;2;-1140.101,321.1182;Inherit;True;Property;_EmissionMap;EmissionMap;2;0;Create;True;0;0;0;False;0;False;-1;None;7febac0641ed4ce46ab05ed2d6d4536e;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;59;-142.4233,456.7044;Inherit;False;Property;_MetalnessScale;Metalness Scale;6;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;7;-107.998,568.8647;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;64;154.126,-135.8216;Inherit;False;63;parallaxOutput;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-485.1263,797.5696;Inherit;False;Property;_RoughnessScale;Roughness Scale;8;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;61;-1059.311,145.0713;Inherit;False;Property;_Emission;Emission;3;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;3;-145.0502,250.7137;Inherit;True;Property;_Metalness;Metalness;5;0;Create;True;0;0;0;False;0;False;-1;None;d203e2eab4ec995419d35351308da17f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;56;441.2362,-75.65552;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;60;290.7465,275.7513;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;-742.3123,227.7062;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;57;97.34201,587.7457;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;4;0.6353991,34.47344;Inherit;True;Property;_NormalMap;NormalMap;4;0;Create;True;0;0;0;False;0;False;-1;c10b5e35126d7ac429de1336baa58727;c10b5e35126d7ac429de1336baa58727;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;685.479,29.04534;Float;False;True;-1;2;ORS1MaterialEditor;0;0;Standard;orels1/Simple Ice;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;80;0;79;0
WireConnection;80;2;91;0
WireConnection;66;0;16;0
WireConnection;66;2;92;0
WireConnection;12;0;66;0
WireConnection;12;2;37;0
WireConnection;12;3;9;0
WireConnection;77;0;80;0
WireConnection;77;2;37;0
WireConnection;77;3;9;0
WireConnection;10;1;12;0
WireConnection;73;1;77;0
WireConnection;19;0;31;0
WireConnection;19;2;38;0
WireConnection;19;3;9;0
WireConnection;78;0;73;1
WireConnection;78;1;10;1
WireConnection;86;0;87;0
WireConnection;86;2;90;0
WireConnection;20;1;19;0
WireConnection;32;0;78;0
WireConnection;32;1;35;0
WireConnection;18;0;32;0
WireConnection;84;1;86;0
WireConnection;33;0;20;1
WireConnection;33;1;36;0
WireConnection;22;0;33;0
WireConnection;88;0;84;1
WireConnection;88;1;89;0
WireConnection;24;0;23;0
WireConnection;24;1;18;0
WireConnection;26;0;22;0
WireConnection;26;1;25;0
WireConnection;85;0;88;0
WireConnection;85;1;24;0
WireConnection;30;0;85;0
WireConnection;30;1;26;0
WireConnection;29;0;28;0
WireConnection;29;1;30;0
WireConnection;63;0;29;0
WireConnection;40;0;39;0
WireConnection;40;1;1;0
WireConnection;7;0;5;1
WireConnection;56;0;64;0
WireConnection;56;1;40;0
WireConnection;60;1;3;1
WireConnection;60;2;59;0
WireConnection;62;0;61;0
WireConnection;62;1;2;0
WireConnection;57;1;7;0
WireConnection;57;2;58;0
WireConnection;0;0;56;0
WireConnection;0;1;4;0
WireConnection;0;2;62;0
WireConnection;0;3;60;0
WireConnection;0;4;57;0
ASEEND*/
//CHKSM=AFB2D60902F5EFDBCFFD49AE183D4766011EBFA3