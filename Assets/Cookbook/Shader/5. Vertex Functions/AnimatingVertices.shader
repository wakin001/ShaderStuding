Shader "MyShaders/AnimatingVertices"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_TintAmount ("Tint Amount", Range(0, 1)) = 0.5
		_ColorA ("Color A", Color) = (1, 1, 1, 1)
		_ColorB ("Color B", Color) = (1, 1, 1, 1)
		_Speed ("Wave Speed", Range(0.1, 80)) = 5
		_Frequency ("Wave Frequency", Range(0, 5)) = 2
		_Amplitude ("Wave Amplitude", Range(-1, 1)) = 1
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
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
				float3 vertColor : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float4 _ColorA;
			float4 _ColorB;
			float _TintAmount;
			float _Speed;
			float _Frequency;
			float _Amplitude;
			float _OffsetVal;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				float time = _Time * _Speed;
				float waveValueA = sin(time + o.vertex.x * _Frequency) * _Amplitude;

				o.vertex.xyz = float3(o.vertex.x, o.vertex.y + waveValueA, o.vertex.z);
				//v.normal = normalize(float3(v.normal.x + waveValueA, v.normal.y, v.normal.z));
				o.vertColor = float3(waveValueA, waveValueA, waveValueA);


                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

				float3 tintColor = lerp(_ColorA, _ColorB, i.vertColor).rgb;

				col.rgb = col.rgb * tintColor * _TintAmount;

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
