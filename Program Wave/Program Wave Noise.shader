// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "orels1/Program Wave Noise"
{
	Properties
	{
		_AlbedoTint("Albedo Tint", Color) = (0.01960784,0.4039216,0.1254902,1)
		_Metallic("Metallic", Range( 0 , 1)) = 1
		_Smooth("Smooth", Range( 0 , 1)) = 0.7058824
		[SingleLineTexture]_MainEmission("Main Emission", 2D) = "white" {}
		[HDR]_EmissionTint("Emission Tint", Color) = (0.06529104,1.344995,0.4178627,0)
		[SingleLineTexture]_MainOpacity("Main Opacity", 2D) = "white" {}
		[HDR]_OverlayEmissionTint("Overlay Emission Tint", Color) = (3.843137,1.631373,0.5333334,0)
		[SingleLineTexture]_OverlayEmission("Overlay Emission", 2D) = "white" {}
		[Header(Shape Controls)]_SweepMask("Sweep Mask", 2D) = "white" {}
		_SweepMaskScale("Sweep Mask Scale", Float) = 0.18
		_MaxWaveHeight("Max Wave Height", Float) = 2.95
		_GlobalMask("Global Mask", 2D) = "white" {}
		_GlobalMaskContrastMin("Global Mask Contrast Min", Range( -1 , 1)) = -0.02
		_GlobalMaskContrastMax("Global Mask Contrast Max", Range( -1 , 1)) = 0.46
		[Header(Sweeping Controls)]_GlobalSweep("Global Sweep", Range( 0 , 1)) = 0
		[Enum(Manual,0,Automatic,1)]_Sweeping("Sweeping Type", Int) = 0
		_AutoSweepSpeed("Auto Sweep Speed", Float) = 1
		_AutoSweepCycleDivison("Auto Sweep Cycle Divison", Float) = 2
		[Header(Noise Controls)]_PositionNoiseScroll("Position Noise Scroll", Vector) = (0.31,0.15,0,0)
		_PositionNoiseScale("Position Noise Scale", Float) = 2.09
		_OpacityNoiseScroll("Opacity Noise Scroll", Vector) = (0.52,0.44,0,0)
		_OpacityNoiseScale("Opacity Noise Scale", Float) = 1.35
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
		[Header(Forward Rendering Options)]
		[ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
		[ToggleOff] _GlossyReflections("Reflections", Float) = 1.0
	}

	SubShader
	{
		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "ForceNoShadowCasting" = "True" "IsEmissive" = "true"  }
		Cull Off
		Blend SrcAlpha OneMinusSrcAlpha , SrcAlpha OneMinusSrcAlpha
		BlendOp Add , Add
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 5.0
		#pragma shader_feature _SPECULARHIGHLIGHTS_OFF
		#pragma shader_feature _GLOSSYREFLECTIONS_OFF
		#pragma only_renderers d3d11_9x d3d11 gles3 
		#pragma surface surf Standard keepalpha noshadow novertexlights nodirlightmap vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
			float2 uv2_texcoord2;
			float3 worldPos;
		};

		uniform float _MaxWaveHeight;
		uniform sampler2D _SweepMask;
		uniform float4 _SweepMask_ST;
		uniform int _Sweeping;
		uniform float _GlobalSweep;
		uniform float _AutoSweepSpeed;
		uniform float _AutoSweepCycleDivison;
		uniform float _SweepMaskScale;
		uniform float2 _PositionNoiseScroll;
		uniform float _PositionNoiseScale;
		uniform float _GlobalMaskContrastMin;
		uniform float _GlobalMaskContrastMax;
		uniform sampler2D _GlobalMask;
		uniform float4 _GlobalMask_ST;
		uniform float4 _AlbedoTint;
		uniform sampler2D _MainEmission;
		uniform float4 _MainEmission_ST;
		uniform float4 _EmissionTint;
		uniform float4 _OverlayEmissionTint;
		uniform sampler2D _OverlayEmission;
		uniform float4 _OverlayEmission_ST;
		uniform float _Metallic;
		uniform float _Smooth;
		uniform float2 _OpacityNoiseScroll;
		uniform float _OpacityNoiseScale;
		uniform sampler2D _MainOpacity;
		uniform float4 _MainOpacity_ST;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float4 ase_vertex4Pos = v.vertex;
			float2 uv2_SweepMask = v.texcoord1.xy * _SweepMask_ST.xy + _SweepMask_ST.zw;
			float mulTime114 = _Time.y * ( 1.0 / _AutoSweepSpeed );
			float sweep60 = (0.27 + (( (float)_Sweeping == 0.0 ? _GlobalSweep : fmod( mulTime114 , _AutoSweepCycleDivison ) ) - 0.0) * (0.853 - 0.27) / (1.0 - 0.0));
			float sweepScale126 = _SweepMaskScale;
			float2 appendResult37 = (float2(uv2_SweepMask.y , ( ( 1.0 - sweep60 ) + ( sweepScale126 * uv2_SweepMask.x ) )));
			float horizontalSweep64 = tex2Dlod( _SweepMask, float4( appendResult37, 0, 0.0) ).r;
			float2 panner88 = ( 1.0 * _Time.y * _PositionNoiseScroll + v.texcoord1.xy);
			float simplePerlin2D89 = snoise( panner88*_PositionNoiseScale );
			simplePerlin2D89 = simplePerlin2D89*0.5 + 0.5;
			float2 uv2_GlobalMask = v.texcoord1 * _GlobalMask_ST.xy + _GlobalMask_ST.zw;
			float smoothstepResult102 = smoothstep( _GlobalMaskContrastMin , _GlobalMaskContrastMax , tex2Dlod( _GlobalMask, float4( uv2_GlobalMask, 0, 0.0) ).r);
			float mask109 = saturate( smoothstepResult102 );
			float vertOffsetve75 = ( ( ( _MaxWaveHeight * horizontalSweep64 * (0.93 + (simplePerlin2D89 - 0.0) * (1.0 - 0.93) / (1.0 - 0.0)) ) * mask109 ) + ( ase_vertex4Pos.y - 3.0 ) );
			float4 appendResult46 = (float4(ase_vertex4Pos.x , vertOffsetve75 , ase_vertex4Pos.z , ase_vertex4Pos.w));
			v.vertex.xyz = appendResult46.xyz;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_MainEmission = i.uv_texcoord * _MainEmission_ST.xy + _MainEmission_ST.zw;
			o.Albedo = ( _AlbedoTint * tex2D( _MainEmission, uv_MainEmission ) ).rgb;
			float sweepScale126 = _SweepMaskScale;
			float2 appendResult34 = (float2(1.0 , sweepScale126));
			float mulTime114 = _Time.y * ( 1.0 / _AutoSweepSpeed );
			float sweep60 = (0.27 + (( (float)_Sweeping == 0.0 ? _GlobalSweep : fmod( mulTime114 , _AutoSweepCycleDivison ) ) - 0.0) * (0.853 - 0.27) / (1.0 - 0.0));
			float2 appendResult31 = (float2(0.0 , ( 1.0 - (0.0 + (sweep60 - 0.25) * (1.0 - 0.0) / (0.92 - 0.25)) )));
			float2 uv_TexCoord29 = i.uv_texcoord * appendResult34 + appendResult31;
			float verticalSweep68 = tex2D( _SweepMask, uv_TexCoord29 ).r;
			float2 uv_OverlayEmission = i.uv_texcoord * _OverlayEmission_ST.xy + _OverlayEmission_ST.zw;
			float4 tex2DNode5 = tex2D( _OverlayEmission, uv_OverlayEmission );
			float2 uv2_SweepMask = i.uv2_texcoord2 * _SweepMask_ST.xy + _SweepMask_ST.zw;
			float2 appendResult37 = (float2(uv2_SweepMask.y , ( ( 1.0 - sweep60 ) + ( sweepScale126 * uv2_SweepMask.x ) )));
			float horizontalSweep64 = tex2D( _SweepMask, appendResult37 ).r;
			o.Emission = max( ( _EmissionTint * tex2D( _MainEmission, uv_MainEmission ) ) , ( ( verticalSweep68 * ( _OverlayEmissionTint * tex2DNode5.r ) ) * horizontalSweep64 ) ).rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Smooth;
			float2 uv2_GlobalMask = i.uv2_texcoord2 * _GlobalMask_ST.xy + _GlobalMask_ST.zw;
			float smoothstepResult102 = smoothstep( _GlobalMaskContrastMin , _GlobalMaskContrastMax , tex2D( _GlobalMask, uv2_GlobalMask ).r);
			float mask109 = saturate( smoothstepResult102 );
			float2 panner86 = ( 1.0 * _Time.y * _OpacityNoiseScroll + i.uv2_texcoord2);
			float simplePerlin2D82 = snoise( panner86*_OpacityNoiseScale );
			simplePerlin2D82 = simplePerlin2D82*0.5 + 0.5;
			float2 uv_MainOpacity = i.uv_texcoord * _MainOpacity_ST.xy + _MainOpacity_ST.zw;
			float4 ase_vertex4Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			o.Alpha = ( mask109 * ( (0.2 + (simplePerlin2D82 - 0.0) * (1.0 - 0.2) / (1.0 - 0.0)) * ( max( tex2D( _MainOpacity, uv_MainOpacity ).r , ( ( tex2DNode5.r * verticalSweep68 ) * horizontalSweep64 ) ) * saturate( ase_vertex4Pos.y ) ) ) );
		}

		ENDCG
	}
	CustomEditor "ORS1MaterialEditor"
}
/*ASEBEGIN
Version=18800
154;25;1910;1290;4161.551;1705.78;2.972812;True;False
Node;AmplifyShaderEditor.CommentaryNode;124;-3511.122,1915.513;Inherit;False;3734.087;590.0343;;19;117;120;114;118;116;40;113;63;60;62;33;32;34;31;29;28;68;112;126;Vertical Sweep;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;117;-3461.122,2233.037;Inherit;False;Property;_AutoSweepSpeed;Auto Sweep Speed;17;0;Create;True;0;0;0;False;0;False;1;4.66;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;120;-3215.308,2170.596;Inherit;False;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;118;-3158.308,2269.296;Inherit;False;Property;_AutoSweepCycleDivison;Auto Sweep Cycle Divison;18;0;Create;True;0;0;0;False;0;False;2;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;114;-3040.122,2182.037;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;112;-2831.023,1965.513;Inherit;False;Property;_Sweeping;Sweeping Type;16;1;[Enum];Create;False;0;2;Manual;0;Automatic;1;0;False;0;False;0;1;False;0;1;INT;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-2902.338,2096.852;Inherit;False;Property;_GlobalSweep;Global Sweep;15;1;[Header];Create;True;1;Sweeping Controls;0;0;False;0;False;0;0.516;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FmodOpNode;116;-2783.122,2187.037;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;113;-2544.123,2145.336;Inherit;False;0;4;0;INT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;63;-2142.332,2271.429;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.27;False;4;FLOAT;0.853;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-1579.449,2124.692;Inherit;False;Property;_SweepMaskScale;Sweep Mask Scale;10;0;Create;True;0;0;0;False;0;False;0.18;0.18;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;60;-1791.072,2298.56;Inherit;False;sweep;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;62;-1538.335,2277.14;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0.25;False;2;FLOAT;0.92;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;126;-1300.075,2103.98;Inherit;False;sweepScale;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;123;-1662.03,2676.838;Inherit;False;1457.985;391.407;;9;38;128;127;64;35;37;39;59;61;Horizontal Sweep;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;61;-1612.03,2743.968;Inherit;False;60;sweep;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;32;-1252.729,2274.165;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;38;-1638.834,2933.822;Inherit;False;1;28;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;127;-1608.075,2847.98;Inherit;False;126;sweepScale;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;59;-1420.421,2726.838;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;128;-1301.075,2868.98;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;31;-964.16,2334.809;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;34;-1045.511,2117.033;Inherit;False;FLOAT2;4;0;FLOAT;1;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;125;-3196.412,2629.658;Inherit;False;1149.742;474.8828;;6;101;122;121;102;107;109;Global Mask;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;39;-1211.821,2751.057;Inherit;False;2;2;0;FLOAT;4.06;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;29;-744.4928,2305.559;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;87;-2133.17,1338.201;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;121;-3088.729,2899.541;Inherit;False;Property;_GlobalMaskContrastMin;Global Mask Contrast Min;13;0;Create;True;0;0;0;False;0;False;-0.02;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;101;-3146.412,2679.658;Inherit;True;Property;_GlobalMask;Global Mask;12;0;Create;True;0;0;0;False;0;False;-1;None;370707c605705a443996b9d141c69aba;True;1;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;28;-402.5467,2275.547;Inherit;True;Property;_SweepMask;Sweep Mask;9;1;[Header];Create;True;1;Shape Controls;0;0;False;0;False;-1;8fe18cba70cd89e4daed06cf83037e2a;8fe18cba70cd89e4daed06cf83037e2a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;122;-3084.729,2989.541;Inherit;False;Property;_GlobalMaskContrastMax;Global Mask Contrast Max;14;0;Create;True;0;0;0;False;0;False;0.46;1;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;37;-1055.054,2871.245;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;129;-2131.894,1477.12;Inherit;False;Property;_PositionNoiseScroll;Position Noise Scroll;19;1;[Header];Create;True;1;Noise Controls;0;0;False;0;False;0.31,0.15;0.31,0.15;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;35;-907.7619,2748.611;Inherit;True;Property;_TextureSample0;Texture Sample 0;9;0;Create;True;0;0;0;False;0;False;-1;8fe18cba70cd89e4daed06cf83037e2a;8fe18cba70cd89e4daed06cf83037e2a;True;0;False;white;Auto;False;Instance;28;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;68;-25.70113,2320.911;Inherit;False;verticalSweep;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;102;-2734.246,2764.228;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.46;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;88;-1797.056,1343.754;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.31,0.15;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;132;-1844.068,1475.845;Inherit;False;Property;_PositionNoiseScale;Position Noise Scale;20;0;Create;True;0;0;0;False;0;False;2.09;2.09;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;-2576.84,579.6987;Inherit;True;Property;_OverlayEmission;Overlay Emission;8;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;fb02dbbc766086c48ad66e024c7104c6;fb02dbbc766086c48ad66e024c7104c6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;64;-465.0446,2781.449;Inherit;False;horizontalSweep;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;107;-2477.852,2790.304;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;70;-2069.572,744.0194;Inherit;False;68;verticalSweep;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;89;-1567.529,1329.185;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;2.09;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;131;-1479.921,239.2646;Inherit;False;Property;_OpacityNoiseScroll;Opacity Noise Scroll;21;0;Create;True;0;0;0;False;0;False;0.52,0.44;0.52,0.44;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-1903.866,586.155;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;-1162.994,1092.92;Inherit;False;64;horizontalSweep;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-1022.043,962.8173;Inherit;False;Property;_MaxWaveHeight;Max Wave Height;11;0;Create;True;0;0;0;False;0;False;2.95;2.91;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;90;-1310.188,1353.598;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.93;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;67;-1744.103,649.2147;Inherit;False;64;horizontalSweep;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;109;-2295.336,2809.249;Inherit;False;mask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;83;-1483.169,108.1925;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-801.606,1075.83;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;74;-2522.266,-13.18046;Inherit;False;Property;_OverlayEmissionTint;Overlay Emission Tint;7;1;[HDR];Create;True;0;0;0;False;0;False;3.843137,1.631373,0.5333334,0;3.441591,0.4865076,1.279335,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;3;-1747.243,383.9804;Inherit;True;Property;_MainOpacity;Main Opacity;6;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;6386003303d8709449798322483d9264;6386003303d8709449798322483d9264;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;133;-1243.068,316.8447;Inherit;False;Property;_OpacityNoiseScale;Opacity Noise Scale;22;0;Create;True;0;0;0;False;0;False;1.35;1.35;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;77;-1114.732,593.3494;Inherit;False;1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;110;-1244.103,1172.82;Inherit;False;109;mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;86;-1221.314,182.6621;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.52,0.44;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PosVertexDataNode;41;-1089.396,1241.635;Inherit;False;1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-1382.726,575.8166;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;104;-633.5345,1117.422;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;82;-996.3094,182.4593;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1.35;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;81;-895.3223,692.677;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;69;-2033.439,-272.2519;Inherit;False;68;verticalSweep;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;22;-1056.017,460.4431;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;56;-778.4201,1216.304;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-1992.247,29.13371;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;94;-2478.408,-673.066;Inherit;False;Property;_EmissionTint;Emission Tint;5;1;[HDR];Create;True;0;0;0;False;0;False;0.06529104,1.344995,0.4178627,0;6.623413,78.81861,126.5072,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;66;-1537.049,-147.2562;Inherit;False;64;horizontalSweep;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-2507.284,-451.0995;Inherit;True;Property;_MainEmission;Main Emission;4;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;cd9044c4df669094f8b2793c08c2e439;cd9044c4df669094f8b2793c08c2e439;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-1762.394,-266.2078;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;-667.4489,561.0413;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;84;-723.5285,225.4525;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.2;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;42;-493.5041,1123.562;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;-368.163,518.644;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-362.133,-504.8217;Inherit;True;Property;_Program_Wave_albedo;Program_Wave_albedo;4;1;[SingleLineTexture];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;2;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;111;-441.7725,420.1574;Inherit;False;109;mask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-2019.567,-548.2258;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;75;-306.2042,1151.367;Inherit;False;vertOffsetve;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-1226.864,-186.9744;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;96;-289.71,-697.2029;Inherit;False;Property;_AlbedoTint;Albedo Tint;1;0;Create;True;0;0;0;False;0;False;0.01960784,0.4039216,0.1254902,1;0.01960784,0.4039215,0.1254901,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;155.6899,-460.2027;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;21;-1017.629,-363.5908;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;71;90.96336,184.5858;Inherit;False;Property;_Metallic;Metallic;2;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;99;-124.759,477.1514;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;72;96.64288,274.1026;Inherit;False;Property;_Smooth;Smooth;3;0;Create;True;0;0;0;False;0;False;0.7058824;0.7058824;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;46;147.3441,1252.113;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;437.4865,112.0926;Float;False;True;-1;7;ORS1MaterialEditor;0;0;Standard;orels1/Program Wave Noise;False;False;False;False;False;True;False;False;True;False;False;False;False;False;True;True;False;False;True;True;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Custom;;Transparent;All;3;d3d11_9x;d3d11;gles3;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;2;5;False;-1;10;False;-1;0;False;-1;1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Absolute;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;120;1;117;0
WireConnection;114;0;120;0
WireConnection;116;0;114;0
WireConnection;116;1;118;0
WireConnection;113;0;112;0
WireConnection;113;2;40;0
WireConnection;113;3;116;0
WireConnection;63;0;113;0
WireConnection;60;0;63;0
WireConnection;62;0;60;0
WireConnection;126;0;33;0
WireConnection;32;0;62;0
WireConnection;59;0;61;0
WireConnection;128;0;127;0
WireConnection;128;1;38;1
WireConnection;31;1;32;0
WireConnection;34;1;126;0
WireConnection;39;0;59;0
WireConnection;39;1;128;0
WireConnection;29;0;34;0
WireConnection;29;1;31;0
WireConnection;28;1;29;0
WireConnection;37;0;38;2
WireConnection;37;1;39;0
WireConnection;35;1;37;0
WireConnection;68;0;28;1
WireConnection;102;0;101;1
WireConnection;102;1;121;0
WireConnection;102;2;122;0
WireConnection;88;0;87;0
WireConnection;88;2;129;0
WireConnection;64;0;35;1
WireConnection;107;0;102;0
WireConnection;89;0;88;0
WireConnection;89;1;132;0
WireConnection;23;0;5;1
WireConnection;23;1;70;0
WireConnection;90;0;89;0
WireConnection;109;0;107;0
WireConnection;43;0;44;0
WireConnection;43;1;65;0
WireConnection;43;2;90;0
WireConnection;86;0;83;0
WireConnection;86;2;131;0
WireConnection;57;0;23;0
WireConnection;57;1;67;0
WireConnection;104;0;43;0
WireConnection;104;1;110;0
WireConnection;82;0;86;0
WireConnection;82;1;133;0
WireConnection;81;0;77;2
WireConnection;22;0;3;1
WireConnection;22;1;57;0
WireConnection;56;0;41;2
WireConnection;25;0;74;0
WireConnection;25;1;5;1
WireConnection;20;0;69;0
WireConnection;20;1;25;0
WireConnection;78;0;22;0
WireConnection;78;1;81;0
WireConnection;84;0;82;0
WireConnection;42;0;104;0
WireConnection;42;1;56;0
WireConnection;85;0;84;0
WireConnection;85;1;78;0
WireConnection;27;0;94;0
WireConnection;27;1;2;0
WireConnection;75;0;42;0
WireConnection;58;0;20;0
WireConnection;58;1;66;0
WireConnection;97;0;96;0
WireConnection;97;1;1;0
WireConnection;21;0;27;0
WireConnection;21;1;58;0
WireConnection;99;0;111;0
WireConnection;99;1;85;0
WireConnection;46;0;41;1
WireConnection;46;1;75;0
WireConnection;46;2;41;3
WireConnection;46;3;41;4
WireConnection;0;0;97;0
WireConnection;0;2;21;0
WireConnection;0;3;71;0
WireConnection;0;4;72;0
WireConnection;0;9;99;0
WireConnection;0;11;46;0
ASEEND*/
//CHKSM=AAC458937E84477BB6485A3E68DED3D8CEE75A77