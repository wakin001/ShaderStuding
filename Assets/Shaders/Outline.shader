// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//Shader "Custom/Outline" {
//
//	Properties{
//
//		_Color("Color", Color) = (1, 1, 1, 1)
//		_Glossiness("Smoothness", Range(0, 1)) = 0.5
//		_Metallic("Metallic", Range(0, 1)) = 0
//
//		_OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
//		_OutlineWidth("Outline Width", Range(0, 0.1)) = 0.03
//
//	}
//
//	Subshader
//	{
//
//		Tags {
//			"RenderType" = "Opaque"
//		}
//
//		CGPROGRAM
//
//		#pragma surface surf Standard fullforwardshadows
//
//		Input {
//			float4 color : COLOR
//		}
//
//		half4 _Color;
//		half _Glossiness;
//		half _Metallic;
//
//		void surf(Input IN, inout SufaceStandardOutput o) {
//			o.Albedo = _Color.rgb * IN.color.rgb;
//			o.Smoothness = _Glossiness;
//			o.Metallic = _Metallic;
//			o.Alpha = _Color.a * IN.color.a;
//		}
//
//		ENDCG
//
//		Pass {
//
//			Cull Front
//
//			CGPROGRAM
//
//			#pragma vertex VertexProgram
//			#pragma fragment FragmentProgram
//
//			half _OutlineWidth;
//
//			float4 VertexProgram(
//					float4 position : POSITION,
//					float3 normal : NORMAL) : SV_POSITION {
//
//				position.xyz += normal * _OutlineWidth;
//
//				return UnityObjectToClipPos(position);
//
//			}
//
//			half4 _OutlineColor;
//
//			half4 FragmentProgram() : SV_TARGET {
//				return _OutlineColor;
//			}
//
//			ENDCG
//
//		}
//
//	}
//
//}
Shader "Custom/OutlineShader"
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" { }
		_OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
		_OutlineWidth("Outline width", Range(0.0, 10.0)) = .005
	}

	SubShader
	{
		Pass
		{
			Cull front

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : POSITION;
			};

			uniform float _OutlineWidth;
			uniform float4 _OutlineColor;

			v2f vert(appdata v)
			{
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);
				float3 clipNormal = mul((float3x3) UNITY_MATRIX_VP, mul((float3x3) UNITY_MATRIX_M, v.normal));
				// 变换到Clip空间再进行Outline的计算，这使得即使我们scale也不会影响outline的width，因为我们在变换到clip空间之后才进行的outline操作
				float2 offset = normalize(clipNormal.xy) / _ScreenParams.xy * _OutlineWidth * o.pos.w * 2;
				//float2 offset = normalize(clipNormal.xy) * _OutlineWidth * o.pos.w;
				o.pos.xy += offset;

				/*float3 norm = normalize(v.normal);
				v.vertex.xyz += norm * _OutlineWidth;
				o.pos = UnityObjectToClipPos(v.vertex);*/

				return o;
			}

			half4 frag(v2f i) : COLOR
			{
				return _OutlineColor;
			}
			ENDCG
		}

		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			sampler2D _MainTex;
			float4 _MainTex_ST;

			struct a2v
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.position = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 c = tex2D(_MainTex, i.uv);
				return fixed4(c.rgb, 1.0);
			}

			ENDCG
		}
	}
}