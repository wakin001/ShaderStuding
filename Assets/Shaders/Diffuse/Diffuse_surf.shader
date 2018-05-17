Shader "Custom/Diffuse_surf" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex("Texture", 2D) = "white"
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf SimpleLambert

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			half2 uv_MainTex;
			float3 worldNormal;
			float3 viewDir;
		};

		fixed4 _Color;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_CBUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END

		void surf (Input IN, inout SurfaceOutput o) {

			/*float factor = dot(IN.viewDir, IN.worldNormal);
			o.Albedo = _Color.rgb * factor;*/
			o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
			// Metallic and smoothness come from slider variables
			
		}

		half4 LightingSimpleLambert(SurfaceOutput s, half3 lightDir, half atten)
		{
			half NdotL = dot(s.Normal, lightDir);
			half4 c;
			c.rgb = s.Albedo * _LightColor0.rgb * (NdotL * atten * 1) * _Color.rgb;
			c.a = s.Alpha;
			return c;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
