Shader "MyShaders/Anisotropic"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_AnisoDirTex("AnisoDir", 2D) = "white" {}
		_SpecPower("Specular Power", Range(0,1)) = 0.5
		_Specular("Specular Amount", Range(0,1)) = 0.5
		_SpecColor ("SpecColor", color) = (1, 1, 1 ,1)
		_AnisoOffset ("AnisoOffset", Range(-1, 1)) = -0.2
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
				float2 uv_AnisoDir : TEXCOORD5;
				half3 worldLightDir : TEXCOORD1;
				half3 worldNormal : TEXCOORD2;
				half3 worldViewDir : TEXCOORD3;
				fixed3 worldPos : TEXCOORD4;
				UNITY_FOG_COORDS(1)
				float4 clipPos : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _AnisoDirTex;
			float4 _AnisoDirTex_ST;
			half _SpecPower;
			half _Specular;
			float _AnisoOffset;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.clipPos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv_AnisoDir = TRANSFORM_TEX(v.uv, _AnisoDirTex);

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
				// normal direction
				float3 anisoTex = UnpackNormal(tex2D(_AnisoDirTex, i.uv_AnisoDir));

				// ambient
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfVector = normalize(normalize(i.worldLightDir) + normalize(viewDir));

				half NdotL = dot(i.worldNormal, i.worldLightDir);
				fixed HdotA = dot(normalize(i.worldNormal + anisoTex), halfVector);
				float aniso = max(0, sin(radians(HdotA + _AnisoOffset) * 180));

				float3 reflect = normalize(2 * i.worldNormal * NdotL - i.worldLightDir);
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed3 diffuse = col.rgb * _LightColor0.rgb * NdotL;
				fixed3 specular = col.rgb *_LightColor0.rgb * saturate(pow(aniso, _SpecPower * 128)) * _Specular;
				col.rgb = ambient + diffuse + specular;

				return col;
			}
			ENDCG
		}
	}
}
