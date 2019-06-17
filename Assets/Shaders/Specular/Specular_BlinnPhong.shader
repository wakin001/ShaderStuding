// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// C_specular = (C_light * M_specular) * max(0, v * r) ** M_gloss;
Shader "MyShaders/Specular_BlinnPhong"
{
	Properties
	{
		_Specular ("Specular", color) = (1, 1, 1, 1)
		_Diffuse ("Diffuse", color) = (1, 1, 1, 1)
		_Gloss ("Gloss", float) = 1
	}
	SubShader
	{
		// No culling or depth
//		Cull Off ZWrite Off ZTest Always

		Pass
		{
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			fixed4 _Specular;
			fixed4 _Diffuse;
			float _Gloss;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};

			v2f vert (a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				// transform the normal from object space to world space.
				o.worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
//				o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				// ambient
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				// diffuse
				// C_diffuse = (C_light * M_diffuse) * max(0, n * I);
				// get the light direction in world space
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				// compute diffuse
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(i.worldNormal, worldLight));

				// specular
				// view direction in world space.
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
//				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfDir = normalize(viewDir + worldLight);
				// compute specular
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(i.worldNormal, halfDir)), _Gloss);

				return fixed4(ambient + diffuse + specular, 1.0);
			}

			ENDCG
		}
	}
	Fallback "Diffuse"
}
