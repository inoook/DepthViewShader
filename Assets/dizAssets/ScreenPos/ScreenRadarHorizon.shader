
Shader "Custom/ScreenRadarHorizon" {
	Properties {
	   _MainTex ("", 2D) = "white" {}
	   _Gradient ("Gradient (RGBA)", 2D) = "white" {}
	}

	SubShader {
		Tags { "RenderType"="Opaque" }

		Pass{
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			float4 _CameraDepthTexture_ST;
			uniform sampler2D _CameraDepthTexture;
			uniform sampler2D _MainTex;
			uniform sampler2D _Gradient; 
			
			float4 _MainTex_TexelSize;
			
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 scrPos : TEXCOORD1;
			};

			v2f vert( appdata_base v ) 
			{
				v2f o;
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.uv.xy = v.texcoord.xy;
				o.scrPos.xy = ComputeScreenPos (o.pos);
				
//				#if UNITY_UV_STARTS_AT_TOP
//					o.uv.y = 1.0-o.uv.y;
//				#endif	
				
				return o;
			} 
			
			// ScreenSpaceAmbientObscurance.shader
			float4x4 _ViewProjectInverse;
			
			float3 ReconstructCSPosition(float2 S, float z) 
			{
//				float linEyeZ = LinearEyeDepth(z);
//				return float3(( ( S.xy * _MainTex_TexelSize.zw) * _ProjInfo.xy + _ProjInfo.zw) * linEyeZ, linEyeZ);
				
				// for reference
				float4 clipPos = float4(S*2.0-1.0, (z*2-1), 1);
				float4 viewPos;
//				viewPos.x = dot((float4)_ViewProjectInverse[0], clipPos);
//				viewPos.y = dot((float4)_ViewProjectInverse[1], clipPos);
//				viewPos.w = dot((float4)_ViewProjectInverse[3], clipPos);
//				viewPos.z = z;
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
				
//				float depthValueX = (tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos)).r);
//   				//float depthValue = ( tex2D(_CameraDepthTexture, uv) );
//   				float depthValue = SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, uv);
				
				float4 color = tex2D(_MainTex, i.uv);
				
				float3 pos = GetPosition(uv);
				float camDist = length(_WorldSpaceCameraPos - pos);
				if(camDist > _ProjectionParams.z * 0.9) {
					return color;
				}
					
				//color = float4( (sin(pos.x*50.0) + 1.0) / 2.0 , (sin(pos.y*50.0) + 1.0) / 2.0,  (sin(pos.z*50.0) + 1.0) / 2.0, 1.0); // debug
				
				float vx = (sin(pos.x*50.0) + 1.0) / 2.0;
				float vy = (sin(pos.y*50.0 - _Time.w * 5) + 1.0) / 2.0;
				//color = float4(vx,0,0,1);
				
				//
				float l = pos.y;
				float t = -_Time.w*0.9 + l ;
				float aa = 5.5;
				float d = 0.5;
				float sawtoothV = 2.0*(t/aa - floor(t/aa+1.0/2.0));// sawtooth wave
				float pattern = clamp((sawtoothV - d) * 1./(1.-d), 0, 1);
				//float4 colOffset = lerp(float4(0,0,0,0), float4(0,0,1,1), pattern);
				//color += colOffset
				
				float2 cPos = float2(pattern, 0);
				float4 colOffset = tex2D(_Gradient, cPos);
				color += colOffset * colOffset.a;
				
				return color;
			}
			
			
			ENDCG
		}
	}
	FallBack "Diffuse"
}