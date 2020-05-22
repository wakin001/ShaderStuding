// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//
// 在切线空间下进行光照计算。
// 效率高。但是通用性不如在世界坐标下进行光照计算。
// Use Point Light
//
Shader "Custom/bumpMapping In TangentSpace With Point Light" 
{
	Properties 
	{
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_Specular ("Specular", Color) = (1, 1, 1, 1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20

		_BumpMap ("Bump Map", 2D) = "bump" {}		// 注意默认值是 "bump"{}
		_BumpScale ("Bump Scale", Float) = 1.0

	}
	SubShader 
	{
		Pass
		{
			Tags { "LightMode" = "ForwardAdd" }

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON

			#include "Lighting.cginc"
			#include "Autolight.cginc" 
			#include "UnityPBSLighting.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;

			fixed4 _Color;
			fixed4 _Specular;
			float _Gloss;

			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;

			struct a2v
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				float3 normal : NORMAL;			// 注意：这里类型是NORMAL
				float4 tangent : TANGENT;		// 切线

				float2 texcoord1 : TEXCOORD1;
			};

			struct v2f
			{
				float4 pos: SV_POSITION;			// pos是在裁剪空间下，
				float4 uv : TEXCOORD0;				// 注意我们用float4，zw用来存bump的uv
				float3 lightDir : TEXCOORD1;		// 在裁剪空间下
				float3 viewDir : TEXCOORD2;			// 在裁剪空间下
				float3 worldPos : TEXCOORD3;
#ifndef LIGHTMAP_OFF
				half2 uvLM : TEXCOORD5;
#endif
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				// o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

				// construct a matrix to transform vectors from object space to tangent space
				// v.tangent.w is direction.
				float3 binormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;
				float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);
				// Or just use build-in macro
//				TANGENT_SPACE_ROTATION;

				// transform to tangent space
				o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
				o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;

				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

#ifndef LIGHTMAP_OFF
				o.uvLM = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
#endif

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				UNITY_LIGHT_ATTENUATION(attenuation, 0, i.worldPos);

				fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);

				// get the texel in normal map.
				fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);

				// 如果texture被设成 “Normal Map”，则可以用UnpackNormal函数，否则需要
				// tangentNormal.xy = (packedNormal.xy * 2 - 1);
				fixed3 tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));


				// 在切线空间下计算光照的各个分量
				fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss);

				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				fixed4 finalColor = fixed4(specular + diffuse + ambient, 1.0) * attenuation;
				// lightmap
#ifndef LIGHTMAP_OFF
				fixed3 lm = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uvLM.xy));
				finalColor *= lm;
#endif
				return finalColor;

			}


			ENDCG
		}

	}
	FallBack "Specular"
}
