 Shader "Hidden/Dof/DepthViewer" {
	Properties {
		_MainTex ("-", 2D) = "black" {}
	}

	CGINCLUDE

	#include "UnityCG.cginc"
	
	struct v2f {
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
		float2 uv1 : TEXCOORD1;
	};
	
	uniform sampler2D _MainTex;
	uniform sampler2D_float _CameraDepthTexture;
	uniform float4 _CurveParams;
	uniform float4 _MainTex_TexelSize;
	uniform float4 _Offsets;

	v2f vert( appdata_img v ) 
	{
		v2f o;
		o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
		o.uv1.xy = v.texcoord.xy;
		o.uv.xy = v.texcoord.xy;
		
		#if UNITY_UV_STARTS_AT_TOP
		if (_MainTex_TexelSize.y < 0)
			o.uv.y = 1-o.uv.y;
		#endif			
		
		return o;
	} 
	
	float4 fragVisualize (v2f i) : SV_Target 
	{
		float4 returnValue = tex2D(_MainTex, i.uv1.xy);	
		returnValue.rgb = lerp(float3(0.0,0.0,0.0), float3(1.0,1.0,1.0), saturate(returnValue.a/_CurveParams.x));
		return returnValue;
	}
	
	float4 fragCaptureColorAndSignedCoc (v2f i) : SV_Target 
	{	
		float4 color = tex2D (_MainTex, i.uv1.xy);
		float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv1.xy);
		d = Linear01Depth (d);
		color.a = _CurveParams.z * abs(d - _CurveParams.w) / (d + 1e-5f); 
		color.a = clamp( max(0.0, color.a - _CurveParams.y), 0.0, _CurveParams.x) * sign(d - _CurveParams.w);
		
		return color;
	} 
	
	float4 fragCaptureCoc (v2f i) : SV_Target 
	{	
		float4 color = float4(0,0,0,0); //tex2D (_MainTex, i.uv1.xy);
		float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv1.xy);
		d = Linear01Depth (d);
		color.a = _CurveParams.z * abs(d - _CurveParams.w) / (d + 1e-5f); 
		color.a = clamp( max(0.0, color.a - _CurveParams.y), 0.0, _CurveParams.x);
		
		return color;
	} 
	
	float4 fragCaptureForegroundCoc (v2f i) : SV_Target 
	{	
		float4 color = float4(0,0,0,0); //tex2D (_MainTex, i.uv1.xy);
		float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv1.xy);
		d = Linear01Depth (d);
		color.a = _CurveParams.z * (_CurveParams.w-d) / (d + 1e-5f);
		color.a = clamp(max(0.0, color.a - _CurveParams.y), 0.0, _CurveParams.x);
		
		return color;	
	}	

	float4 fragCaptureForegroundCocMask (v2f i) : SV_Target 
	{	
		float4 color = float4(0,0,0,0);
		float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv1.xy);
		d = Linear01Depth (d);
		color.a = _CurveParams.z * (_CurveParams.w-d) / (d + 1e-5f);
		color.a = clamp(max(0.0, color.a - _CurveParams.y), 0.0, _CurveParams.x);
		
		return color.a > 0;	
	}	
	
	float4 fragBlendInHighRez (v2f i) : SV_Target 
	{
		float4 tapHighRez =  tex2D(_MainTex, i.uv.xy);
		return float4(tapHighRez.rgb, 1.0-saturate(tapHighRez.a*5.0));
	}
	
	float4 fragBlendInLowRezParts (v2f i) : SV_Target 
	{
		float4 from = tex2D(_MainTex, i.uv1.xy);
		from.a = saturate(from.a * _Offsets.w) / (_CurveParams.x + 1e-5f);
		float square = from.a * from.a;
		from.a = square * square * _CurveParams.x;
		return from;
	}
	
	float4 fragUpsampleWithAlphaMask(v2f i) : SV_Target 
	{
		float4 c = tex2D(_MainTex, i.uv1.xy);
		return c;
	}		
	
	float4 fragAlphaMask(v2f i) : SV_Target 
	{
		float4 c = tex2D(_MainTex, i.uv1.xy);
		c.a = saturate(c.a*100.0);
		return c;
	}	
		
	ENDCG
	
Subshader 
{
 
 // pass 0
 
 Pass {
	  ZTest Always Cull Off ZWrite Off
	  ColorMask A
	  Fog { Mode off }      

      CGPROGRAM

      #pragma glsl
      #pragma target 3.0
      #pragma fragmentoption ARB_precision_hint_fastest
      #pragma vertex vert
      #pragma fragment fragCaptureCoc
      #pragma exclude_renderers d3d11_9x flash
      
      ENDCG
  	}

// pass 1
 Pass {
	  ZTest Always Cull Off ZWrite Off
	  Fog { Mode off }      

     	CGPROGRAM

      	#pragma glsl
      	#pragma target 3.0
      	#pragma fragmentoption ARB_precision_hint_fastest
      	#pragma vertex vert
		#pragma fragment fragVisualize
		#pragma exclude_renderers d3d11_9x flash

      	ENDCG
  	}	

	
}
  
Fallback off

}