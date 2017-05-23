﻿//
// Mask纹理。
// 允许我们保护某些区域，使他们免于修改。
//  常见用法：
//  1. 希望模型某些区域反光强烈一些，有些区域弱一些
//  2. 制作地形材质时需要混合多张图片，例如表现草地的纹理，表现石子的纹理，表现裸露土地的纹理
//
Shader "Custom/MaskTexture" 
{
	Properties 
	{
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_BumpTex ("Normal Tex", 2D) = "bump" {}
		_BumpScale ("Bump Scale", Float) = 1.0
		_SpecularMask ("SpecularMask", 2D) = "white" {}
		_SpecularScale ("Specular Scale", Float) = 1.0
		_Specular ("Specular", Color) = (1, 1, 1, 1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20
	}
	SubShader 
	{
		Pass
		{
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;  // _MaskTex, _BumpTex, _SpecularMask使用同一个_MainTex_ST

			sampler2D _BumpTex;
			float _BumpScale;

			sampler2D _SpecularMask;
			float _SpecularScale;

			fixed4 _Color;
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;			// 注意：这里类型是NORMAL
				float4 tangent : TANGENT;
				float4 texcoord: TEXCOORD0;
			};

			struct v2f
			{
				float4 pos: SV_POSITION;			// pos是在裁剪空间下，
				float3 lightDir : TEXCOORD0;
				float3 viewDir : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex).xy;
//				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

				TANGENT_SPACE_ROTATION;
				o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
				o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);

				fixed3 tangentNormal = UnpackNormal(tex2D(_BumpTex, i.uv));
				tangentNormal.xy += _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;

				// diffuse part
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));

				// ambient part
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				// specular part
				fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
				// get the mask value
				// 这里每个纹素的rgb都是一样的，所以我们用r来计算mask value
				fixed specularMask = tex2D(_SpecularMask, i.uv).r * _SpecularScale;
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss) * specularMask;


				return fixed4(specular + diffuse + ambient, 1.0);
			}


			ENDCG
		}

	}
	FallBack "Specular"
}
