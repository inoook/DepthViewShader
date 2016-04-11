// http://willychyr.com/2013/11/unity-shaders-depth-and-normal-textures-part-2/
Shader "Custom/DepthRingPass" {

Properties {
   _MainTex ("", 2D) = "white" {} //this texture will have the rendered image before post-processing
   _RingWidth("ring width", Float) = 0.01
   _RingPassTimeLength("ring pass time", Float) = 2.0
}

SubShader {
Tags { "RenderType"="Opaque" }
Pass{
CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

sampler2D _CameraDepthTexture;
float _StartingTime;
uniform float _RingPassTimeLength; //the length of time it takes the ring to traverse all depth values
uniform float _RingWidth; //width of the ring
float _RunRingPass = 0; //use this as a boolean value, to trigger the ring pass. It is called from the script attached to the camera.

struct v2f {
   float4 pos : SV_POSITION;
   float4 scrPos:TEXCOORD1;
};

//Our Vertex Shader
v2f vert (appdata_base v){
   v2f o;
   o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
   o.scrPos=ComputeScreenPos(o.pos);
   o.scrPos.y = 1 - o.scrPos.y;
   return o;
}

sampler2D _MainTex; //Reference in Pass is necessary to let us use this variable in shaders

//Our Fragment Shader
half4 frag (v2f i) : COLOR{

   //extract the value of depth for each screen position from _CameraDepthExture
   float depthValue = Linear01Depth (tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos)).r);

   fixed4 orgColor = tex2Dproj(_MainTex, i.scrPos); //Get the orginal rendered color
   float4 newColor; //the color after the ring has passed
   half4 lightRing; //the ring of light that will pass through the dpeth

   float t = 1 - ((_Time.y - _StartingTime)/_RingPassTimeLength );

   //the script attached to the camera will set _RunRingPass to 1 and then will start the ring pass
   if (_RunRingPass == 1){
      //this part draws the light ring
      if (depthValue < t && depthValue > t - _RingWidth){
         lightRing.r = 1;
         lightRing.g = 0;
         lightRing.b = 0;
         lightRing.a = 1;
         return lightRing;
      } else {
          if (depthValue < t) {
             //this part the ring hasn't pass through yet
             return orgColor;
          } else {
             //this part the ring has passed through
             //basically taking the original colors and adding a slight red tint to it.
             newColor.r = (orgColor.r + 1)*0.5;
             newColor.g = orgColor.g*0.5;
             newColor.b = orgColor.b*0.5;
             newColor.a = 1;
             return newColor;
         }
      }
    } else {
        return orgColor;
    }
}
ENDCG
}
}
FallBack "Diffuse"
}