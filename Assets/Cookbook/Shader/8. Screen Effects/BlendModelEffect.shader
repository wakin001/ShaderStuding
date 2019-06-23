Shader "MyShaders/BlendModelEffect"
{
    Properties
    {
        _MainTex ("Base Texture", 2D) = "white" {}
        _BlendTex ("Blend Texture", 2D) = "white" {}
		_Opacity("Blend Opacity", Range(0, 1)) = 1
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
            sampler2D _BlendTex;
            fixed _Opacity;
            
            fixed OverlayBlendMode(fixed basePixel, fixed blendPixel)
            {
                if (basePixel < 0.5)
                {
                    return (2.0 * basePixel * blendPixel);
                }
                else
                {
                    return (1.0 - 2.0 * (1.0 - basePixel) * (1.0 - blendPixel)); 
                }
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
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 blendCol = tex2D(_BlendTex, i.uv);
                
                //// perform a multiply blend mode
                //fixed4 blendedMultiply = col * blendCol;
                //// adjust amount of blend mode with a lerp
                //col = lerp(col, blendedMultiply, _Opacity);
                
                ////////// Start OverlayBlendMode ///////////////////////
                
                fixed4 blendedImage = col;
                blendedImage.r = OverlayBlendMode(col.r, blendCol.r);
                blendedImage.g = OverlayBlendMode(col.g, blendCol.g);
                blendedImage.b = OverlayBlendMode(col.b, blendCol.b);
                
                col = lerp(col, blendedImage, _Opacity);
                
                
                ////////// End OverlayBlendMode ///////////////////////
                
                return col;
            }
            
            
            
            ENDCG
        }
    }
}
