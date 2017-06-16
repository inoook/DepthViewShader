// Upgrade NOTE: commented out 'float4x4 _CameraToWorld', a built-in variable
// Upgrade NOTE: replaced '_CameraToWorld' with 'unity_CameraToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// https://gist.github.com/pixelmager/b259c6165f67d0039ca3
Shader "Custom/worldReconstruction" {
	Properties {
	   _MainTex ("", 2D) = "white" {}
	}

	SubShader {

		Pass{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			sampler2D _CameraDepthTexture;
			// float4x4 _CameraToWorld;
			float3 _LightAsQuad;
			
			struct v2f {
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float3 ray : TEXCOORD1;
			};
			v2f vert (appdata_base v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = ComputeScreenPos (o.pos);
				o.ray = mul (UNITY_MATRIX_MV, v.vertex).xyz * float3(-1,-1,1);
				
				// v.normal contains a ray pointing from the camera to one of near plane's
				// corners in camera space when we are drawing a full screen quad.
				// Otherwise, when rendering 3D shapes, use the ray calculated here.
				o.ray = lerp(o.ray, v.normal, _LightAsQuad);
				
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target {
				float2 uv = i.uv.xy / i.uv.w;
				float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv);
				depth = Linear01Depth (depth);
				float4 vpos = float4(i.ray * depth,1);
				float3 wpos = mul (unity_CameraToWorld, vpos).xyz;
				
				return vpos;
			}

			ENDCG
		}
	}
}
