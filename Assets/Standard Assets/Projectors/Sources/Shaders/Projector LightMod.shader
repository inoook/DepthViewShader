Shader "Projector/LightMod" { 
	Properties {
		_Color ("Main Color", Color) = (1,1,1,1)
		_ShadowTex ("Cookie", 2D) = "" {}
	}
	 
	Subshader {
		Tags {"Queue"="Transparent"}
		Pass {
			ZWrite Off
			Fog { Color (0, 0, 0) }
			ColorMask RGB
			Blend DstColor One
			Offset -1, -1
	 
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			struct v2f {
				float4 uvShadow : TEXCOORD0;
				float4 pos : SV_POSITION;
			};
			
			float4x4 _Projector;
			
			v2f vert (float4 vertex : POSITION)
			{
				v2f o;
				o.pos = mul (UNITY_MATRIX_MVP, vertex);
				o.uvShadow = mul (_Projector, vertex);
				return o;
			}
			
			fixed4 _Color;
			sampler2D _ShadowTex;
			uniform sampler2D _CameraDepthTexture;
			
			fixed4 frag (v2f i) : SV_Target
			{
				//float depthValue = Linear01Depth( tex2D(_CameraDepthTexture, i.uvShadow.xy) );
				float depthValue =  Linear01Depth(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.uvShadow)).r);
				
				fixed4 texS = tex2D (_ShadowTex, (i.uvShadow.xy));
//				texS.rgb *= _Color.rgb;
//				texS.a = 1.0-texS.a;
	 			
	 			if(depthValue > 0.5){
	 				texS.r = 1.0;
	 			}
				return texS;
			}
			ENDCG
		}
	}
}
