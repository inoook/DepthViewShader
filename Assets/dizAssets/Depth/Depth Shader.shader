// http://stackoverflow.com/questions/16759326/cg-omit-depth-write

Shader "Custom/Depth Shader" {
SubShader { // Unity chooses the subshader that fits the GPU best
  Pass { // some shaders require multiple passes
     ZWrite On
     CGPROGRAM // here begins the part in Unity's Cg

     #pragma vertex vert 
     #pragma fragment frag
     #include "UnityCG.cginc"
     struct v2f
     {
        float4 position : POSITION;
        float4 projPos : TEXCOORD1;
     };

     v2f vert(float4 vertexPos : POSITION)
     {
        v2f OUT;
        OUT.position = mul(UNITY_MATRIX_MVP, vertexPos);
        OUT.projPos = ComputeScreenPos(OUT.position);
        return OUT;
     }

     //camera depth texture here
     uniform sampler2D _CameraDepthTexture; //Depth Texture
     float4 frag(v2f IN) : COLOR// fragment shader
     {
         // use eye depth for actual z...
        //float depth = LinearEyeDepth (tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(IN.projPos)).r); 

        //or this for depth in between [0,1]
        float depth = Linear01Depth (tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(IN.projPos)).r);
        
        return float4(depth, depth, depth, 1.0);
     }

     ENDCG // here ends the part in Cg 
  }
}
}