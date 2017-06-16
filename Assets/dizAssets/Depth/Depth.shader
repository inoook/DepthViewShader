// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Depth" {
	Properties {
	   _MainTex ("", 2D) = "white" {}
	}

	SubShader {
		Tags { "RenderType"="Opaque" }

		Pass{
			CGPROGRAM
// Upgrade NOTE: excluded shader from DX11 and Xbox360; has structs without semantics (struct v2f members uv)
#pragma exclude_renderers d3d11 xbox360
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			uniform sampler2D _CameraDepthTexture;
			uniform sampler2D _MainTex; 
			
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};
			
			//Our Vertex Shader
			v2f vert(appdata_img v)
			{
				v2f o;
			    o.pos = UnityObjectToClipPos (v.vertex);
			    o.uv =  v.texcoord.xy;
			    return o;
			}
			
			float4 frag(v2f IN) : COLOR
			{
				float4 depth = Linear01Depth(tex2D(_CameraDepthTexture, IN.uv).r);
				return depth;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}