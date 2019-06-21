Shader "MyShaders/SurfNotRefined"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
		_NormalMap("Normal Map", 2D) = "bump" {}
		//_BlendTex("Blend texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard SimpleLambert


        sampler2D _MainTex;
		sampler2D _NormalMap;
		//sampler2D _BlendTex;

        struct Input
        {
            float2 uv_MainTex;
			float2 uv_NormalMap;
        };

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            float4 c = tex2D (_MainTex, IN.uv_MainTex);
			//float4 blendTex = tex2D(_BlendTex, IN.uv_MainTex);

			//c = lerp(c, blendTex, blendTex.r);

            o.Albedo = c.rgb;
            o.Alpha = c.a;
			o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_NormalMap));
        }

		inline fixed4 LightingSimpleLambert(SurfaceOutput s, float3 lightDir, float atten)
		{
			float diff = max(0, dot(s.Normal, lightDir));

			float4 c;
			c.rgb = s.Albedo * _LightColor0.rgb * (diff * atten * 2);
			c.a = s.Alpha;
			return c;
		}
        ENDCG
    }
    FallBack "Diffuse"
}
