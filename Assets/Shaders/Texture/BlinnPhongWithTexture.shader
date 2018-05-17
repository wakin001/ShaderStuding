// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

//
// diffuse光照公式：C_Diffuse = (C_light * M_diffuse) * max(0, N * I);
// M_diffuse 是材质的漫反射颜色
// 
// specular光照公式：C_Specular = (C_light * M_specular) * exp(max(0, N * H), M_Gloss).
// H = (V + I) / |V + I|
// I: 光照方向， V：视角方向，N：法线方向
//
Shader "Custom/BlinnPhongWithTexture" 
{
	Properties 
	{
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Main Tex", 2D) = "white" {}
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
			float4 _MainTex_ST;

			fixed4 _Color;
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				float3 normal : NORMAL;			// 注意：这里类型是NORMAL
			};

			struct v2f
			{
				float4 pos: SV_POSITION;			// pos是在裁剪空间下，用于渲染
				float3 worldNormal : TEXCOORD0;
				// worldPos是在世界空间下。注意类型！
				// 为什么同时要pos和worldPos？
				// worldPos：各种计算一般都在世界坐标下，比如计算光照方向和视角方向等
				// pos: 传递给下一个流水线，用于渲染
				float3 worldPos : TEXCOORD1;		
				float2 uv : TEXCOORD2;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				// o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfDir = normalize(worldLightDir + viewDir);

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);

				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				return fixed4(specular + diffuse + ambient, 1.0);
			}


			ENDCG
		}

	}
	FallBack "Specular"
}
