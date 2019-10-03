Shader "MyShaders/MotionBlur"
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_BlurAmount("Blur Amount", Float) = 1.0
	}

	SubShader
	{
		CGINCLUDE

		#include "UnityCG.cginc"

		sampler2D _MainTex;
		half4 _MainTex_TexelSize;
		float  _BlurAmount;

		struct appdata
		{
			float4 vertex : POSITION;
			half2 texcoord : TEXCOORD0;
		};

		struct v2f
		{
			float4 pos : SV_POSITION;
			half2 uv : TEXCOORD0;
		};

		v2f	vert(appdata v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv = v.texcoord;

			return o;
		}
		// 使得混合时不受透明值的影响
		fixed4 fragRGB(v2f i) : SV_Target
		{
			return fixed4(tex2D(_MainTex, i.uv).rgb, _BlurAmount);
		}

		fixed4 fragA(v2f i) : SV_Target
		{
			return tex2D(_MainTex, i.uv);
		}


		ENDCG

		ZTest Always
		Cull Off
		ZWrite Off

		// pass 0
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMask RGB

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment fragRGB

			ENDCG
		}
		// pass 1
		Pass
		{
			Blend One Zero
			//Blend SrcAlpha OneMinusSrcAlpha
			// ColorMask可以让我们制定渲染结果的输出通道，而不是通常情况下的RGBA这4个通道全部写入。
			// 可选参数是 RGBA 的任意组合以及 0，这将意味着不会写入到任何通道，可以用来单独做一次Z测试，而不将结果写入颜色通道
			ColorMask A

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment fragA

			ENDCG
		}
	}
	Fallback Off
}
