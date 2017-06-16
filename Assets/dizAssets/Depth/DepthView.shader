// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// http://willychyr.com/2013/11/unity-shaders-depth-and-normal-textures-part-3/
Shader "Custom/DepthView" {	
	Properties {
	   _MainTex ("", 2D) = "white" {}
	   endClip ("endClip", Float) = 30
	}

	SubShader {
		Tags { "RenderType"="Opaque" }

		Pass{
			
			CGPROGRAM
// Upgrade NOTE: excluded shader from DX11 and Xbox360; has structs without semantics (struct v2f members v)
#pragma exclude_renderers d3d11 xbox360
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			uniform sampler2D _CameraDepthNormalsTexture;
			uniform sampler2D _CameraDepthTexture;
			uniform sampler2D _MainTex; 
			
			uniform float endClip; 
			
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
			};

			v2f vert( appdata_img v ) 
			{
				v2f o;
				o.pos = UnityObjectToClipPos (v.vertex);
				o.uv1.xy = v.texcoord.xy;
				o.uv.xy = v.texcoord.xy;
				
				#if UNITY_UV_STARTS_AT_TOP
				//if (_MainTex_TexelSize.y < 0)
					o.uv.y = 1-o.uv.y;
				#endif			
				
				return o;
			} 
			
			float4 frag (v2f i) : SV_Target 
			{	
				float4 color = float4(0,0,0,0);
				
				float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv1.xy);
				d = Linear01Depth (d);
				//d = LinearEyeDepth (d);
				
				// float farClip = 1000;
				//float dd = (d - 1.0/farClip) / d;
				
				//float dd = (d - _ProjectionParams.w) / d;
				
				float maxClip = endClip;
				float per = maxClip *_ProjectionParams.w;
				
				float dd = d * (1 / per);
//				if(dd > 0.2){
//					color = float4(dd, dd, dd, 1.0);
//				}else{
//					color = tex2D(_MainTex, i.uv);
//				}

				color = float4(dd, dd, dd, 1.0);
				
				return color;
			}
			
			ENDCG
		}
	}
	FallBack "Diffuse"
}