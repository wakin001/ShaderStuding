Shader "MyShaders/ImageEffect"
{
    Properties
    {
        _MainTex ("Base Texture", 2D) = "white" {}
		_LuminosityAmount("GrayScale Amount", Range(0, 1)) = 1.0
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
			#pragma fragmentoption ARB_precision_hint_fastest

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			fixed _LuminosityAmount;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 renderTexCol = tex2D(_MainTex, i.uv);

				// apply th eluminosity values to our render texture.
				float luminosity = 0.299 * renderTexCol.r + 0.587 * renderTexCol.g + 0.114 * renderTexCol.b;
				fixed4 col = lerp(renderTexCol, luminosity, _LuminosityAmount);

                return col;
            }
            ENDCG
        }
    }
}
