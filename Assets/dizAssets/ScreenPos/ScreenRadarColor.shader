// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/ScreenRadarColor" {
	Properties {
	   _MainTex ("", 2D) = "white" {}
	   _Gradient ("Gradient (RGBA)", 2D) = "white" {}
	   centerScreenPos ("centerScreenPos", Vector) = (0,0, 0,0)
	   _fade("fade", Float) = 20.0
	   _waveOffset("waveOffset", Float) = 0.6

	   _Color ("Color", COLOR) = (1,1,1,1)
	}

	SubShader {
		Tags { "RenderType"="Opaque" }

		Pass{
	 		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			uniform sampler2D _CameraDepthNormalsTexture;
			uniform sampler2D _CameraDepthTexture;
			
			uniform sampler2D _MainTex; 
			uniform sampler2D _Gradient;

			uniform float4 _Color;
			
			
			uniform float4 centerScreenPos;
			float _fade;
			float _waveOffset;

			#define PI 3.14159
			
			uniform float4 _MainTex_TexelSize;
			
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float4 scrPos : TEXCOORD2;
			};

//			v2f vert( appdata_base v ) 
//			{
//				v2f o;
//				o.pos = UnityObjectToClipPos (v.vertex);
//				o.uv1.xy = v.texcoord.xy;
//				o.uv.xy = v.texcoord.xy;
//				
//				#if UNITY_UV_STARTS_AT_TOP
//				if (_MainTex_TexelSize.y < 0)
//					o.uv.y = 1-o.uv.y;
//				#endif	
//				
//				o.scrPos.xy = ComputeScreenPos (o.pos);
//				
//				return o;
//			}

			v2f vert( appdata_base v ) 
			{
				v2f o;
				o.pos = UnityObjectToClipPos (v.vertex);
				o.uv.xy = v.texcoord.xy;
				o.scrPos.xy = ComputeScreenPos (o.pos);
				
				return o;
			}
			
			// ScreenSpaceAmbientObscurance.shader
			float4x4 _ViewProjectInverse;
			
			float3 ReconstructCSPosition(float2 S, float z) 
			{
				// for reference
				float4 clipPos = float4(S*2.0-1.0, (z*2-1), 1);
				float4 viewPos;
				viewPos = mul(_ViewProjectInverse, clipPos);
				viewPos = viewPos/viewPos.w;
				return viewPos.xyz;
			}

			/** Read the camera-space position of the point at screen-space pixel ssP */
			float3 GetPosition(float2 ssP) {
				float3 P;

				P.z = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, ssP.xy);

				// Offset to pixel center
				P = ReconstructCSPosition(float2(ssP) /*+ float2(0.5, 0.5)*/, P.z);
				return P;
			}
			
			float4 frag (v2f i) : SV_Target 
			{	
				float2 uv = i.scrPos.xy;
				
				float4 color = tex2D(_MainTex, i.uv);
				
				float3 pos = GetPosition(uv);
//				if(pos.z >= _ProjectionParams.z * 0.09) {
//					return color;
//				}

				float4 tPos = centerScreenPos;
				float l = length(pos - tPos);
//				color = lerp(color, _Color, clamp(l/_waveOffset, 0, 1));

//				color = lerp(color, _Color, clamp((l-_waveOffset)/_fade, 0, 1)); // color only

				//
				float pattern = clamp((l-_waveOffset)/_fade, 0, 1);
				color = lerp(color, _Color, pattern);

				// add texture
				float3 dir = (pos - tPos);
				dir.y = 0.0;
				dir = normalize(dir);		
				float p = (atan(dir.z / dir.x)/(PI*0.5));
//				if(p < 0.0){
//					p = 1.0 + p;
//				}
				p = abs(1+p);
				float num = 4.0; // リピートの数
				p = fmod(p*num, 1.0);

				float2 cPos = float2(pattern, p);
				float4 colOffset = tex2D(_Gradient, cPos);
				fixed fadeEndDist = 160;
				color += colOffset * clamp(1-l/fadeEndDist, 0, 1) * colOffset.a;			

				
				return color;
			}
			
			
			ENDCG
		}
	}
	FallBack "Diffuse"
}