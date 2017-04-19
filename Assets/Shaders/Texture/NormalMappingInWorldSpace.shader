//
// 在切线空间下进行光照计算。
// 效率高。
//
Shader "Custom/bumpMapping In World Space" 
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

			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;

			struct a2v
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				float3 normal : NORMAL;			// 注意：这里类型是NORMAL
				float4 tangent : TANGENT;		// 切线
			};

			struct v2f
			{
				float4 pos: SV_POSITION;			// pos是在裁剪空间下，
				float4 uv : TEXCOORD0;				// 注意我们用float4，zw用来存bump的uv
				float4 TtoW0 : TEXCOORD1;			// 从切线空间到世界空间的第一行。w存储了世界空间下的顶点位置
				float4 TtoW1 : TEXCOORD2;			// 从切线空间到世界空间的第二行
				float4 TtoW2 : TEXCOORD3;			// 从切线空间到世界空间的第三行
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				// o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

				float3 worldPos = mul(_Object2World, v.vertex).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

				// compute the matrix that transform direction from tangent space to world space
				// Put the world position in w component for optimization
				o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				// get the position in world space
				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
				// compute the light and view dir in world space
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

				// get the texel in normal map.
				fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);

				// 如果texture被设成 “Normal Map”，则可以用UnpackNormal函数，否则需要
				// tangentNormal.xy = (packedNormal.xy * 2 - 1);
				fixed3 bump = UnpackNormal(packedNormal);
				bump.xy *= _BumpScale;
				bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));

				// transform the normal from tangent space to world space
				bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));


				// 在切线空间下计算光照的各个分量
				fixed3 halfDir = normalize(lightDir + viewDir);

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(bump, halfDir)), _Gloss);

				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(bump, lightDir));

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				return fixed4(specular + diffuse + ambient, 1.0);
			}


			ENDCG
		}

	}
	FallBack "Specular"
}
