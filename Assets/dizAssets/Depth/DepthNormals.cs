// http://willychyr.com/2013/11/unity-shaders-depth-and-normal-textures-part-3/
using UnityEngine;
using System.Collections;

public class DepthNormals : MonoBehaviour {
	
	public Material mat;
	bool showNormalColors = true;
	
	void Start () {
		GetComponent<Camera>().depthTextureMode = DepthTextureMode.DepthNormals;
		//camera.depthTextureMode = DepthTextureMode.Depth;
	}
	
	// Update is called once per frame
	void Update () {
		if (Input.GetKeyDown (KeyCode.E)){
			showNormalColors = !showNormalColors;
		}
		
		if (showNormalColors){
			mat.SetFloat("_showNormalColors", 1.0f);
		} else {
			mat.SetFloat("_showNormalColors", 0.0f);
		}
	}
	
	// Called by the camera to apply the image effect
	void OnRenderImage (RenderTexture source, RenderTexture destination){
		//mat is the material containing your shader
		Graphics.Blit(source,destination,mat);
	}
}