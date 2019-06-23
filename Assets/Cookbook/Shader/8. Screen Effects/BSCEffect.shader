Shader "MyShaders/BSCEffect"
{
    Properties
    {
        _MainTex ("Base Texture", 2D) = "white" {}
		_BrightnessAmount("Brightness Amount", Range(0, 1)) = 1
        _satAmount("Saturation Amount", Range(0, 1)) = 1
        _conAmount("Contrast Amount", Range(0, 1)) = 1
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
			fixed _satAmount;
            fixed _conAmount;
            fixed _BrightnessAmount;
            
            float3 ContrastSaturationBrightness(float3 color, float brt, float sat, float con)
            {
                // Inscrease or decrease these value to adjust r, g, b color channels seperately
                float avgLumR = 0.5;
                float avgLumG = 0.5;
                float avgLumB = 0.5;
                
                // Luminance coeffifients for getting lumoinance from the image
                float3 LuminanceCoeff = float3(0.2125, 0.7154, 0.0721);
                
                // operation for brightness
                float avgLumin = float3(avgLumR, avgLumG, avgLumB);
                float3 brtColor = color * brt;
                float intensityf = dot(brtColor, LuminanceCoeff);
                float3 intensity = float3(intensityf, intensityf, intensityf);
                
                // Operation for Saturation
                float3 satColor = lerp(intensity, brtColor, sat);
                
                // Opration for Contrast
                float3 conColor = lerp(avgLumin, satColor, con);
                return conColor;
            }
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
			{
                fixed4 renderTex = tex2D(_MainTex, i.uv);
                renderTex.rgb = ContrastSaturationBrightness(renderTex.rgb, _BrightnessAmount, _satAmount, _conAmount);         
                return renderTex;
            }
            
            
            
            ENDCG
        }
    }
}
