// http://forum.unity3d.com/threads/world-position-of-a-pixel-from-depth-texture.97671/
Shader "Custom/RenderWorldPos"
{
  SubShader
  {
    Pass {
    CGPROGRAM
    #pragma vertex vert
    #pragma fragment frag
 
    #include "UnityCG.cginc"
 
    struct v2f {
      float4 pos : SV_POSITION;
      float4 uv : TEXCOORD0;
    };
 
    float4 _CameraDepthTexture_ST;
    sampler2D _CameraDepthTexture;
 
    float4x4 _ViewProjectInverse;
 
    v2f vert (appdata_img v)
    {
      v2f o;
 
        o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
        o.uv.xy = ComputeScreenPos (o.pos);
 
      return o;
    }
 
    float4 frag (v2f i) : COLOR
    {
        float2 uv = i.uv.xy;
      uv.y = 1 - uv.y;
 
      float z = tex2D (_CameraDepthTexture, uv);
      //if(z > 0.99) discard;
 
      float2 xy = uv * 2 - 1;
      float4 posProjected = float4(xy, z, 1);
      float4 posWS = mul(_ViewProjectInverse, posProjected);
 
      posWS = posWS/posWS.w;
 
      return float4(posWS.xyz, 1.0);
    }
    ENDCG
    }
  }
  Fallback off
}