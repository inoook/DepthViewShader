
Shader "Custom/ScreenPosRadar" {
	Properties {
	   _MainTex ("", 2D) = "white" {}
	   //centerScreenPos ("centerScreenPos", Vector) = (0,0, 0,0)
	   _Color ("Radar Color", COLOR) = (1,1,1,1)
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
			
			uniform float4 centerScreenPos;
			uniform float depth = 10;
			
			uniform float4 _Color;
			uniform float4 _ColorB;
			
			
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
				
				float4 tPos = centerScreenPos;
				float l = pos.y - tPos.y + (depth * 0.5);
				float4 colorOffset = _Color * clamp(l/depth, 0, 1);
				
//				float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv.xy);
//				depth = Linear01Depth(depth);
//				float4 colorOffset = EncodeFloatRGBA(depth);
				
				//colorOffset += _ColorB * ( clamp(1 - abs(1.0 - l/0.5), 0, 1) );
				//color += colorOffset;
				
//				float w = 1.5;
//				float grid = sign(sin(l*w));
//				colorOffset *= grid * 0.5;
				
				color = colorOffset;
				return color;
			}
			
			
			ENDCG
		}
	}
	FallBack "Diffuse"
}