// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Cookbook/Diffuse"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
		Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
			Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				fixed3 worldNormal : TEXCOORD1;
				fixed3 worldLight : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				o.worldLight = mul((float3x3)unity_ObjectToWorld, ObjSpaceLightDir(v.vertex));

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				// ambient
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);

				// get the light direction in world space
				//fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				// 这里的i.worldLight和worldLight是一样的。
				fixed3 diffuse = _LightColor0.xyz * col.xyz * saturate(dot(i.worldNormal, i.worldLight));
                
				fixed4 color = fixed4(ambient + diffuse, col.a);

                return color;
            }
            ENDCG
        }
    }
	Fallback "Diffuse"
}
