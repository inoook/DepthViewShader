using UnityEngine;
using System.Collections;

public class ScreenRadarViewerBlack : MonoBehaviour {
	
	public Material mat;
	public Transform trans;
	
	void Start () {
		GetComponent<Camera>().depthTextureMode = DepthTextureMode.Depth;
	}
	
	// Update is called once per frame
	void Update () {

	}

	public float waveOffset = -20f;
	public float fade = 20.0f;
	public Color color = Color.red;
	public Texture waveTexture;

	// Called by the camera to apply the image effect
	void OnRenderImage (RenderTexture source, RenderTexture destination){
		// http://willychyr.com/2013/11/unity-shaders-depth-and-normal-textures-part-3/
		
		Matrix4x4 viewProjInverse = (GetComponent<Camera>().projectionMatrix * GetComponent<Camera>().worldToCameraMatrix).inverse;
		mat.SetMatrix("_ViewProjectInverse", viewProjInverse);
		mat.SetVector("centerScreenPos", trans.position);
//		mat.SetFloat("_waveSpeed", waveSpeed);
		mat.SetFloat("_waveOffset", waveOffset);
		mat.SetFloat("_fade", fade);
		mat.SetColor("_Color", color);

		mat.SetTexture("_Gradient", waveTexture);

		RenderTexture rt = RenderTexture.GetTemporary(source.width, source.height);
		Graphics.Blit(source, rt, mat);
		Graphics.Blit(rt, destination);
		RenderTexture.ReleaseTemporary(rt);
	}

}