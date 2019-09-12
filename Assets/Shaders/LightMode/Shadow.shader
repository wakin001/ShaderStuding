// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

Shader "MyShaders/Shadow"
{
	Properties
	{
		_Specular("Specular", color) = (1, 1, 1, 1)
		_Diffuse("Diffuse", color) = (1, 1, 1, 1)
		_Gloss("Gloss", float) = 1
	}
	SubShader
	{
		Pass
		{
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM
			#pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			fixed4 _Specular;
			fixed4 _Diffuse;
			float _Gloss;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				// transform the normal from object space to world space.
				o.worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
//				o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				// ambient 场景环绕光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				// diffuse
				// get the light direction in world space （场景中最亮的平行光会在base pass中进行逐像素处理）
				// _WorldSpaceLightPos0是平行光的方向，_LightColor0是平行光的（其实是颜色和强度相乘后的结果）
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				// compute diffuse
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(i.worldNormal, worldLight));

				// specular
				// view direction in world space.
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
//				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfDir = normalize(viewDir + worldLight);
				// compute specular
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(i.worldNormal, halfDir)), _Gloss);

				return fixed4(ambient + diffuse + specular, 1.0);
			}
			ENDCG
		}

		Pass
		{
			// Pass for other pixel lights
			Tags {"LightMode" = "ForwardAdd"}
			// 开启了混合模式，与帧缓存中的之前的光照结果进行叠加
			Blend One One

			CGPROGRAM

			#pragma multi_compile_fwdadd

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			fixed4 _Specular;
			fixed4 _Diffuse;
			float _Gloss;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				// transform the normal from object space to world space.
				o.worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
//				o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				// ambient 场景环绕光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				// diffuse
				// the direction of light
#ifdef USING_DIRECTIONAL_LIGHT

				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
#else
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
#endif
				// 计算光的衰减

#ifdef USING_DIRECTIONAL_LIGHT

				fixed atten = 1.0;
#else
				// Unity使用了一张纹理作为查找表，得到光源的衰减
				// 首先，计算光源空间下的坐标，然后使用该坐标对衰减纹理进行采样得到衰减值
				float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
				fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
#endif

				// compute diffuse
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(i.worldNormal, worldLight));

				// specular
				// view direction in world space.
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
	//				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfDir = normalize(viewDir + worldLight);
				// compute specular
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(i.worldNormal, halfDir)), _Gloss);

				return fixed4(ambient + (diffuse + specular) * atten, 1.0);
			}
			ENDCG
		}
		Pass
		{
			Name "ShadowCaster"
			// Pass for Shadow
			Tags {"LightMode" = "ShadowCaster"}
			Offset 1, 1
				
			CGPROGRAM

			#pragma multi_compile_shadowcaster

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct v2f
			{
				// 声明一个阴影纹理坐标，需要下一个插值寄存器的索引值
				V2F_SHADOW_CASTER;
			};

			v2f vert(appdata_base v)
			{
				v2f o;
				// 在vert中计算上一步中声明的阴影纹理坐标
				TRANSFER_SHADOW_CASTER(o);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				// 计算阴影值
				SHADOW_CASTER_FRAGMENT(i);
			}
			ENDCG
		}
	}
	//Fallback "Diffuse"
}
