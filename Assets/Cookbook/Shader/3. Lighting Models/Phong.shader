Shader "MyShaders/Phong"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_SpecPower ("SpecPower", Range(0, 5)) = 1
		_SpecColor ("SpecColor", color) = (1, 1, 1 ,1)
	}
	SubShader
	{
		Tags {	"Queue" = "Transparent" 
				"RenderType" = "True" 
				"IgnoreProjection" = "True" }
		LOD 100

		// apply alpha
		ZWrite On
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				half3 normal: NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				half3 worldLightDir : TEXCOORD1;
				half3 worldNormal : TEXCOORD2;
				half3 worldViewDir : TEXCOORD3;
				fixed3 worldPos : TEXCOORD4;
				UNITY_FOG_COORDS(1)
				float4 clipPos : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			half _SpecPower;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.clipPos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				o.worldLightDir = normalize(WorldSpaceLightDir(v.vertex));
				o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
				o.worldViewDir = normalize(WorldSpaceViewDir(v.vertex));
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				return o;
			}
			
			// I = N . L + (R . V)^p
			// R = 2N . (N.L) - L
			fixed4 frag (v2f i) : SV_Target
			{
				// ambient
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				half NdotL = dot(i.worldNormal, i.worldLightDir);
				float3 reflect = normalize(2 * i.worldNormal * NdotL - i.worldLightDir);
				fixed3 specular = pow(max(0, dot(reflect, viewDir)), _SpecPower) * _SpecColor;

				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed3 diffuse = col.rgb * _LightColor0.rgb * NdotL;
				specular = col.rgb * _LightColor0.rgb * specular;

				col.rgb = ambient + diffuse + specular;

				return col;
			}
			ENDCG
		}
	}
}
