Shader "MyShaders/NormalExtrusion"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_ExtrusionTex("Texture", 2D) = "white" {}
		_Amount ("Extrusion Amount", Range(-1, 1)) = 0
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

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				//float2 uvExtrusion : TEXCOORD1;
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
				float2 uvExtrusion : TEXCOORD1;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
				float3 worldNormal : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			sampler2D _ExtrusionTex;
			float4 _ExtrusionTex_ST;
			float _Amount;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uvExtrusion = TRANSFORM_TEX(v.uv, _ExtrusionTex);

				float4 tex = tex2Dlod(_ExtrusionTex, float4(v.uv, 0, 0));
				float extrusion = tex.r * 2 - 1;

				o.worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

				o.vertex.xyz += o.worldNormal * _Amount * extrusion;
				//o.vertex.xyz += _Amount * extrusion;

                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 colExtrusion = tex2D(_ExtrusionTex, i.uvExtrusion);
				//col *= colExtrusion;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
