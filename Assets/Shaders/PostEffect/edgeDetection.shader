Shader "MyShaders/edgeDetection"
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_EdgeOnly("Edge Only", Float) = 1.0
		_EdgeColor("Edge Color", Color) = (0, 0, 0, 1)
		_BackgroundColor("Background Color", Color) = (1, 1, 1, 1)
	}

		SubShader
		{
			Pass
			{
			ZTest Always
			Cull Off
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

		struct appdata
		{
			float4 vertex : POSITION;
			half2 texcoord : TEXCOORD0;
		};
			struct v2f
			{
				float4 pos : SV_POSITION;
				half2 uvs[9] : TEXCOORD0;
			};

			sampler2D _MainTex;
			// _MainTex_TexelSize: 这个变量的从字面意思是主贴图 _MainTex 的像素尺寸大小，是一个四元数，是 unity 内置的变量，它的值为 Vector4(1 / width, 1 / height, width, height)
			uniform half4 _MainTex_TexelSize;
			fixed _EdgeOnly;
			fixed4 _EdgeColor;
			fixed4 _BackgroundColor;

			fixed luminance(fixed4 color)
			{
				return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
			}

			half Sobel(v2f i)
			{
				const half gy[9] = {
					-1, -2, -1,
					0, 0, 0,
					1, 2, 1
				};

				const half gx[9] = {
					-1, 0, 1,
					-2, 0, 2,
					-1, 0, 1
				};

				half texColor;
				half edgeX = 0;
				half edgeY = 0;
				for (int it = 0; it < 9; ++it)
				{
					texColor = luminance(tex2D(_MainTex, i.uvs[it]));
					edgeX += texColor * gx[it];
					edgeY += texColor * gy[it];
				}
				half edge = 1 - abs(edgeX) - abs(edgeY);
				return edge;
			}

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				half2 uv = v.texcoord;

				o.uvs[0] = uv + _MainTex_TexelSize.xy * half2(-1, -1);
				o.uvs[1] = uv + _MainTex_TexelSize.xy * half2(0, -1);
				o.uvs[2] = uv + _MainTex_TexelSize.xy * half2(1, -1);
				o.uvs[3] = uv + _MainTex_TexelSize.xy * half2(-1, 0);
				o.uvs[4] = uv + _MainTex_TexelSize.xy * half2(0, 0);
				o.uvs[5] = uv + _MainTex_TexelSize.xy * half2(1, 0);
				o.uvs[6] = uv + _MainTex_TexelSize.xy * half2(-1, 1);
				o.uvs[7] = uv + _MainTex_TexelSize.xy * half2(0, 1);
				o.uvs[8] = uv + _MainTex_TexelSize.xy * half2(1, 1);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				half edge = Sobel(i);

				fixed4 withEdgeColor = lerp(_EdgeColor, tex2D(_MainTex, i.uvs[4]), edge);
				fixed4 onlyEdgeColor = lerp(_EdgeColor, _BackgroundColor, edge);

				return lerp(withEdgeColor, onlyEdgeColor, _EdgeOnly);
			}
			ENDCG
		}

		}
			Fallback Off
}
