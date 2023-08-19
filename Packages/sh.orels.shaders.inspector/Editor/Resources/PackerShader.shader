Shader "Hidden/ORL/PackerShader"
{
	Properties
	{
		_RedTex("Red Texture", 2D) = "black" {}
		_RedChannel("Red Channel", Int) = 0
		_RedTexPresent("Red Texture Present", Int) = 0
		_RedFill("Red Fill", Range(0,1)) = 0
		_RedInvert("Red Invert", Int) = 0
		
		_BlueTex("Blue Texture", 2D) = "black" {}
		_BlueChannel("Red Channel", Int) = 1
		_BlueTexPresent("Blue Texture Present", Int) = 0
		_BlueFill("Blue Fill", Range(0,1)) = 0
		_BlueInvert("Blue Invert", Int) = 0
		
		_GreenTex("Green Texture", 2D) = "black" {}
		_GreenChannel("Red Channel", Int) = 2
		_GreenTexPresent("Green Texture Present", Int) = 0
		_GreenFill("Green Fill", Range(0,1)) = 0
		_GreenInvert("Green Invert", Int) = 0
		
		_AlphaTex("Alpha Texture", 2D) = "black" {}
		_AlphaChannel("Red Channel", Int) = 3
		_AlphaTexPresent("Alpha Texture Present", Int) = 0
		_AlphaFill("Alpha Fill", Range(0,1)) = 0
		_AlphaInvert("Red Invert", Int) = 0
		
		_IsLinear("Is Linear", Int) = 0
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			Texture2D<float4> _RedTex;
			SamplerState sampler_RedTex;
			Texture2D<float4> _GreenTex;
			SamplerState sampler_GreenTex;
			Texture2D<float4> _BlueTex;
			SamplerState sampler_BlueTex;
			Texture2D<float4> _AlphaTex;
			SamplerState sampler_AlphaTex;

			int _RedChannel;
			int _RedTexPresent;
			float _RedFill;
			int _RedInvert;

			int _GreenChannel;
			int _GreenTexPresent;
			float _GreenFill;
			int _GreenInvert;

			int _BlueChannel;
			int _BlueTexPresent;
			float _BlueFill;
			int _BlueInvert;

			int _AlphaChannel;
			int _AlphaTexPresent;
			float _AlphaFill;
			int _AlphaInvert;

			int _IsLinear;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			float4 frag (v2f i) : SV_Target
			{
				float redData = _RedTexPresent ? _RedTex.SampleLevel(sampler_RedTex, i.uv, 0)[_RedChannel] : _RedFill;
				if (_RedInvert)
				{
					redData = 1 - redData;
				}
				float greenData = _GreenTexPresent ? _GreenTex.SampleLevel(sampler_GreenTex, i.uv, 0)[_GreenChannel] : _GreenFill;
				if (_GreenInvert)
				{
					greenData = 1 - greenData;
				}
				float blueData = _BlueTexPresent ? _BlueTex.SampleLevel(sampler_BlueTex, i.uv, 0)[_BlueChannel] : _BlueFill;
				if (_BlueInvert)
				{
					blueData = 1 - blueData;
				}
				float alphaData = _AlphaTexPresent ? _AlphaTex.SampleLevel(sampler_AlphaTex, i.uv, 0)[_AlphaChannel] : _AlphaFill;
				if (_AlphaInvert)
				{
					alphaData = 1 - alphaData;
				}

				// if (!_IsLinear)
				// {
				// 	return float4(pow(float3(redData, greenData, blueData),2.2), alphaData);
				// }
				return float4(redData, greenData, blueData, _AlphaTexPresent ? pow(alphaData, 1.0/2.2) : alphaData);
			}
			ENDCG
		}
	}
}