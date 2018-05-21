Shader "MyShaders/Diffuse_vert_frag"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "LightMode" = "ForwardBase" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				half3 normal: NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				half3 worldLightDir : TEXCOORD1;
				half3 worldNormal : TEXCOORD2;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				o.worldLightDir = WorldSpaceLightDir(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				//o.worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

				//UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// ambient
				//fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);

				//fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				half NdotL = saturate(dot(i.worldNormal, i.worldLightDir));
				fixed3 diffuse = col.rgb * _LightColor0.rgb * NdotL;
				fixed4 color;
				color.rgb = UNITY_LIGHTMODEL_AMBIENT.xyz + diffuse;
				color.a = 1.0;
				// apply fog
				//UNITY_APPLY_FOG(i.fogCoord, color);
				return color;
			}
			ENDCG
		}
	}
}
