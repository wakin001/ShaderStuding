Shader "MyShaders/Snow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_MainColor("Main Color", Color) = (1.0, 1.0, 1.0, 1.0)

		_Bump("Bump", 2D) = "bump" {}
		_Snow ("Level of snow", Range(1, -1)) = 1
		_SnowColor("Snow Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_SnowDirection("Direction of snow", Vector) = (0, 1, 0)
		_SnowDepth("Depth of snow", Range(0, 1)) = 0
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
            // make fog work
            #pragma multi_compile_fog
			#pragma target 3.0

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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
				float3 worldNormal : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			sampler2D _Bump;
			float _Snow;
			float4 _SnowColor;
			float4 _MainColor;
			float4 _SnowDirection;
			float _SnowDepth;

			v2f vert (appdata v)
			{
				v2f o;
                // convert _SnowDirection from world coordinate to object cooridnate.
				fixed4 sn = mul(UNITY_MATRIX_IT_MV, _SnowDirection);
				if (dot(v.normal, sn.xyz) >= _Snow)
				{
					v.vertex.xyz += (sn.xyz + v.normal) * _SnowDepth * _Snow;
				}

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);

				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				
				// normal vector
				//fixed3 normalMapping = UnpackNormal(tex2D(_Bump, i.uv));

				if (dot(i.worldNormal, _SnowDirection.xyz) > _Snow)
				{
					col.xyz = _SnowColor.rgb;
				}
				else
				{
					col.xyz *= _MainColor;
				}

				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
            ENDCG
        }
    }
}
