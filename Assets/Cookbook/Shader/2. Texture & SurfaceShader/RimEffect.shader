// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Cookbook/RimEffect"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Texture", 2D) = "white" {}
		_DotProduct("Rim effect", Range(-1, 1)) = 0.25
	}
		SubShader
		{
			Tags
			{
				"Queue" = "Transparent"
				"RenderType" = "True"
				"IgnoreProjection" = "True"
			}
			LOD 100

			// apply alpha
			ZWrite On
			Blend SrcAlpha OneMinusSrcAlpha

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

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
					float4 vertex : SV_POSITION;
					fixed3 worldNormal : TEXCOORD1;
					fixed3 worldViewDir : TEXCOORD2;
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;
				float _DotProduct;
				fixed4 _Color;

				v2f vert(appdata v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					o.worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
					o.worldViewDir = normalize(WorldSpaceViewDir(v.vertex));
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					// sample the texture
					fixed4 col = tex2D(_MainTex, i.uv) * _Color;

					float border = 1 - abs(dot(i.worldViewDir, i.worldNormal));
					// 当_DotProduct是1时，alpha完全等于_DotProduct，即1，完全真实的反应了border的状况
					// 当_DotProduct是-1时，只有border等于1时，alpha才是1，border小于0.5以下时，alpha为0，即0.5以下的像素都被舍弃了。
					float alpha = (border * (1 - _DotProduct) + _DotProduct);

					fixed4 color = fixed4(col.rgb, col.a * border * alpha);

				return color;
			}
			ENDCG
		}
		}
			Fallback "Diffuse"
}
