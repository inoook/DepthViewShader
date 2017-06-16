// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// http://wgld.org/d/webgl/w059.html
// http://docs.unity3d.com/Manual/SL-DepthTextures.html
// http://eraser85.wordpress.com/tag/opengl/
Shader "Custom/DepthMapShader" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		depthOffset ("depthOffset", Float) = 0
		near ("near", Float) = 0
		far ("far", Float) = 0
	}
	SubShader {
		Pass
	    {            
	        CGPROGRAM
// Upgrade NOTE: excluded shader from DX11 and Xbox360; has structs without semantics (struct v2f members depth)
#pragma exclude_renderers d3d11 xbox360
            //#pragma vertex vert_img
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "UnityCG.cginc"
            
            struct v2f {
				float4 pos : POSITION0;
				float4 depth;
				vec4 vPosLS;
				float4 color : COLOR;
				float2 uv : TEXCOORD2;
			};
			
			v2f vert( appdata_full v )
			{
				v2f o;
				
				o.depth = UnityObjectToClipPos (v.vertex);
				//UNITY_TRANSFER_DEPTH(o.depth);
				
				o.vPosLS = UnityObjectToClipPos (v.vertex);
				o.vPosLS /= o.vPosLS.z;
				
				o.pos = UnityObjectToClipPos (v.vertex);
				o.uv = v.texcoord.xy;
				o.color = v.color;
				
				return o;
			}
            
            uniform sampler2D _MainTex;
            
            // フラグメントシェーダ
			uniform float depthOffset = 0.0;

			float near = 0.1;
			float far  = 30.0;
			//float linerDepth = 1.0 / (far - near);
			
			vec4 convRGBA(float depth){
			    float r = depth;
			    float g = fract(r * 255.0);
			    float b = fract(g * 255.0);
			    float a = fract(b * 255.0);
			    float coef = 1.0 / 255.0;
			    r -= g * coef;
			    g -= b * coef;
			    b -= a * coef;
			    return vec4(r, g, b, a);
			}

			float convCoord(float depth, float offsetV){
			    float d = clamp(depth + offsetV, 0.0, 1.0);
			    if(d > 0.6){
			        d = 2.5 * (1.0 - d);
			    }else if(d > 0.4){
			        d = 1.0;
			    }else{
			        d *= 2.5;
			    }
			    return d;
			}
			
			//float4 frag(v2f_img i) : COLOR {
			float4 frag(v2f i) : COLOR {
				
//				float4 vPosition = i.depth;
//				
//				float linerDepth = 1.0 / (far - near);
//				float liner = linerDepth * length(vPosition);
//   				vec4  convColor = convRGBA(convCoord(liner, depthOffset));
   				//vec4 convColor = vec4(1,1,1,1) * (length(vPosition));
				
				vec4 vPosLS = i.vPosLS;
				vec4 convColor = vec4(vec3(vPosLS.z*.5+.5), -sign(abs(vPosLS.x)) );
				
				half2 p = i.uv;
				
				vec4 fragColor = tex2D(_MainTex, p);
				return fragColor;
			}
			
			ENDCG
		}
	}
}
