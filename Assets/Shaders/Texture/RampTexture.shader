// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//
// 渐变纹理。
// 常见的用法是：控制漫反射光照的结果。可以保证物体的轮廓线相比与之前使用的漫反射光照更加明显，而且能提供多种色调变化。
//
Shader "Custom/RampTexture" 
{
	Properties 
	{
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_RampTex ("Ramp Tex", 2D) = "white" {}
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

			sampler2D _RampTex;
			float4 _RampTex_ST;

			fixed4 _Color;
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;			// 注意：这里类型是NORMAL
				float4 texcoord: TEXCOORD0;
			};

			struct v2f
			{
				float4 pos: SV_POSITION;			// pos是在裁剪空间下，
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.uv = TRANSFORM_TEX(v.texcoord, _RampTex);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				// specular part
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				// 在切线空间下计算光照的各个分量
				fixed3 halfDir = normalize(worldLightDir + viewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

				// diffuse part
				// Use the texture to sample the diffuse color
				fixed halfLambert = 0.5 * dot(worldNormal, worldLightDir) + 0.5;
				fixed diffuseColor = tex2D(_RampTex, fixed2(halfLambert, halfLambert)).rgb * _Color.rgb;
				fixed3 diffuse = _LightColor0.rgb * diffuseColor;

				// ambient part
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				return fixed4(specular + diffuse + ambient, 1.0);
			}


			ENDCG
		}

	}
	FallBack "Specular"
}
