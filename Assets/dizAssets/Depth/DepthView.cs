// http://willychyr.com/2013/11/unity-shaders-depth-and-normal-textures-part-3/
using UnityEngine;
using System.Collections;

public class DepthView : MonoBehaviour {
	
	public Material mat;
	
	void Start () {
		//camera.depthTextureMode = DepthTextureMode.DepthNormals;
		GetComponent<Camera>().depthTextureMode = DepthTextureMode.Depth;
	}
	
	// Update is called once per frame
	void Update () {

	}

	public float endClip = 30;

	// Called by the camera to apply the image effect
	void OnRenderImage (RenderTexture source, RenderTexture destination){
		endClip = Mathf.Clamp(endClip, 0, GetComponent<Camera>().farClipPlane);

		mat.SetFloat("endClip", endClip);
		//mat is the material containing your shader
		Graphics.Blit(source,destination,mat);

	}
}