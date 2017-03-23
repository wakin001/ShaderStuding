// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "MyShaders/Diffuse_harflambert"
{
	Properties
	{
		_Diffuse ("Diffuse", color) = (1, 1, 1, 1)
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

			fixed4 _Diffuse;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed3 color : COLOR;
			};

			v2f vert (a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				// ambient
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				// C_diffuse = (C_light * M_diffuse) * (alpha * (n * I) + belta);  // alpha, belta is 0.5
				// transform the normal from object space to world space.
				fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				// get the light direction in world space
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				// compute diffuse
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * dot(worldNormal, worldLight) * 0.5 + 0.5;

				o.color = ambient + diffuse;

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				return fixed4(i.color, 1.0);
			}

			ENDCG
		}
	}
	Fallback "Diffuse"
}
