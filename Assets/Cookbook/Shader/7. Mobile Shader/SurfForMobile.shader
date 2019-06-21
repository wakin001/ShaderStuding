Shader "MyShaders/SurfForMobile"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
		_SpecIntensity("Specular Width", Range(0.01, 1)) = 0.5
		_NormalMap("Normal Map", 2D) = "bump" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf MobileBlinnPhong exclude_path:prepass nolightmap noforwardadd halfasview


        sampler2D _MainTex;
		sampler2D _NormalMap;
		fixed _SpecIntensity;

        struct Input
        {
            half2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);

            o.Albedo = c.rgb;
			o.Gloss = c.a;
            o.Alpha = 0.0;
			o.Specular = _SpecIntensity;
			o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_MainTex));
        }

		inline fixed4 LightingMobileBlinnPhong(SurfaceOutput s, fixed3 lightDir, fixed3 halfDir, fixed atten)
		{
			fixed diff = max(0, dot(s.Normal, lightDir));
			fixed nh = max(0, dot(s.Normal, halfDir));
			fixed spec = pow(nh, s.Specular * 128) * s.Gloss;

			fixed4 c;
			c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec) * atten * 2;
			c.a = 0.0;
			return c;
		}
        ENDCG
    }
    FallBack "Diffuse"
}
