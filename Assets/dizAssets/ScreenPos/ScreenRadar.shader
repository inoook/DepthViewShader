// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "Custom/ScreenRadar" {
	Properties {
	   _MainTex ("", 2D) = "white" {}
	   _Gradient ("Gradient (RGBA)", 2D) = "white" {}
	   centerScreenPos ("centerScreenPos", Vector) = (0,0, 0,0)
	   _waveSpeed("waveSpeed", Float) = 3.0
	   _cycle("cycle", Float) = 20.0
	   _waveOffset("waveOffset", Float) = 0.6
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
			
			uniform float4 centerScreenPos;
			float _waveSpeed;
			float _cycle;
			float _waveOffset;
			
			uniform float4 _MainTex_TexelSize;
			
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float4 scrPos : TEXCOORD2;
			};

			v2f vert( appdata_base v ) 
			{
				v2f o;
				o.pos = UnityObjectToClipPos (v.vertex);
				o.uv1.xy = v.texcoord.xy;
				o.uv.xy = v.texcoord.xy;
				
				#if UNITY_UV_STARTS_AT_TOP
				if (_MainTex_TexelSize.y < 0)
					o.uv.y = 1-o.uv.y;
				#endif	
				
				o.scrPos.xy = ComputeScreenPos (o.pos);
				
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
				
				float4 color = tex2D(_MainTex, i.uv);
				
				float3 pos = GetPosition(uv);
				if(pos.z >= _ProjectionParams.z * 0.09) {
					return color;
				}
				
				//color = float4( (sin(pos.x*50.0) + 1.0) / 2.0 , (sin(pos.y*50.0) + 1.0) / 2.0 ,  (sin(pos.z*50.0) + 1.0) / 2.0 * 0, 1.0);
				
				float4 tPos = centerScreenPos;
				float l = length(pos - tPos);
				
				float t = -_Time.w *_waveSpeed + l ;
				//float t =  l ;
				float aa = _cycle;//cycle
				//float aa = 1.0;
				float offV = _waveOffset;
				float sawtoothV = 2.0*(t/aa - floor(t/aa+1.0/2.0));// sawtooth wave -1, 1
				float pattern = clamp((sawtoothV - offV) * 1./(1.-offV), 0, 1);
				float2 cPos = float2(pattern, 0);
				float4 colOffset = tex2D(_Gradient, cPos);
				color += colOffset * clamp(1-l/60, 0, 1) * colOffset.a;
				
				return color;
			}
			
			
			ENDCG
		}
	}
	FallBack "Diffuse"
}