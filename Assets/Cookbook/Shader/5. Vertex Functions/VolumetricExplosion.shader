Shader "MyShaders/VolumetricExplosion"
{
    Properties
    {
        _RampTex ("Ramp Texture", 2D) = "white" {}
		_RampOffset("Ramp Offset", Range(-0.5, 0.5)) = 0

		_NoiseTex("Noise Texture", 2D) = "gray" {}
		_Period("Period", Range(0, 1)) = 0.5

		_Amount("Amount", Range(0, 1)) = 0.1
		_ClipRange("ClipRange", Range(0, 1)) = 1
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

            sampler2D _RampTex;
			
			half _RampOffset;
			
			sampler2D _NoiseTex;
			float4 _NoiseTex_ST;
			float _Period;

			half _Amount;
			half _ClipRange;

			v2f vert (appdata v)
			{
				v2f o;
				float3 disp = tex2Dlod(_NoiseTex, float4(v.uv.xy, 0, 0));
				// _Time: Time (t/20, t, t*2, t*3)
				float time = sin(_Time[3] * _Period + disp.r * 10);
				v.vertex.xyz += v.normal * disp.r * _Amount * time;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _NoiseTex);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 noise = tex2D(_NoiseTex, i.uv);
				float n = saturate(noise.r + _RampOffset);
				// if _ClipRange - n is less than 0, it will be not drawn.
				clip(_ClipRange - n);

				half4 col = tex2D(_RampTex, float2(n, 0.5));
				
				return col;
			}
            ENDCG
        }
    }
}
