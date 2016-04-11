
#pragma strict

@script ExecuteInEditMode
@script RequireComponent (Camera)
@script AddComponentMenu ("Image Effects/Camera/DepthViewer") 

class DepthViewer extends PostEffectsBase 
{	
	public var focalLength : float = 10.0f;
	public var focalSize : float = 0.05f; 
	public var aperture : float = 11.5f;
	public var focalTransform : Transform = null;
	
	public var dofHdrShader : Shader;		
	private var dofHdrMaterial : Material = null;
	
	private var focalDistance01 : float = 10.0f;	
	
	function CheckResources () : boolean {
		CheckSupport (true); // only requires depth, not HDR
			
		dofHdrMaterial = CheckShaderAndCreateMaterial (dofHdrShader, dofHdrMaterial); 
		
		if(!isSupported)
			ReportAutoDisable ();

		return isSupported;		  
	}

	function OnEnable () {
		GetComponent.<Camera>().depthTextureMode |= DepthTextureMode.Depth;	
	}	

	function OnDisable()
	{
		if(dofHdrMaterial) DestroyImmediate(dofHdrMaterial);
		dofHdrMaterial = null;
	}
	
	function FocalDistance01 (worldDist : float) : float {
		return GetComponent.<Camera>().WorldToViewportPoint((worldDist-GetComponent.<Camera>().nearClipPlane) * GetComponent.<Camera>().transform.forward + GetComponent.<Camera>().transform.position).z / (GetComponent.<Camera>().farClipPlane-GetComponent.<Camera>().nearClipPlane);	
	}

	private function WriteCoc (fromTo : RenderTexture, fgDilate : boolean) {
		//dofHdrMaterial.SetTexture("_FgOverlap", null); 

		Graphics.Blit (fromTo, fromTo, dofHdrMaterial,  0);
	}
			
	function OnRenderImage (source : RenderTexture, destination : RenderTexture) {
	
		if(!CheckResources ()) {
			//Graphics.Blit (source, destination);
			return; 
		}

		// clamp & prepare values so they make sense
		if (aperture < 0.0f) aperture = 0.0f;
		focalSize = Mathf.Clamp(focalSize, 0.0f, 2.0f);
					
		// focal & coc calculations
		focalDistance01 = (focalTransform) ? (GetComponent.<Camera>().WorldToViewportPoint (focalTransform.position)).z / (GetComponent.<Camera>().farClipPlane) : FocalDistance01 (focalLength);
		dofHdrMaterial.SetVector ("_CurveParams", Vector4 (1.0f, focalSize, aperture/10.0f, focalDistance01));
		

//        // possible render texture helpers
//		var rtLow : RenderTexture = null;		
//		var rtLow2 : RenderTexture = null;
		
		//
		// 2.
		// visualize coc
		//
		//
		WriteCoc (source, true);
		Graphics.Blit (source, destination, dofHdrMaterial, 1);

		//Graphics.Blit (source, destination, dofHdrMaterial, 0);

//		if(rtLow) RenderTexture.ReleaseTemporary(rtLow);
//		if(rtLow2) RenderTexture.ReleaseTemporary(rtLow2);		
	}	
}
