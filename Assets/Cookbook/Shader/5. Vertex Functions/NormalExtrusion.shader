﻿Shader "MyShaders/NormalExtrusion"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_ExtrusionTex("Texture", 2D) = "white" {}
		_Amount ("Extrusion Amount", Range(-0.0001, 0.0001)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
			#pragma target 3.0

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			sampler2D _ExtrusionTex;
			float4 _ExtrusionTex_ST;
			float _Amount;


			v2f vert (appdata v)
			{
				v2f o;
                
				float4 tex = tex2Dlod(_ExtrusionTex, float4(v.uv, 0, 0));
				float extrusion = tex.r * 2 - 1;

				v.vertex.xyz += v.normal * _Amount * extrusion;
				
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 colExtrusion = tex2D(_ExtrusionTex, i.uv);
				
				float extrusion = abs(colExtrusion.r * 2 - 1);

				col = lerp(col, fixed4(0, 0, 0, col.a), extrusion * _Amount / 0.0001 * 1.1);

				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
            ENDCG
        }
    }
}
