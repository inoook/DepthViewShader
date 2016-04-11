using UnityEngine;
using System.Collections;

public class ScreenRadarViewer : MonoBehaviour {
	
	public Material mat;
	public Transform trans;
	
	void Start () {
		//camera.depthTextureMode = DepthTextureMode.DepthNormals;
		GetComponent<Camera>().depthTextureMode = DepthTextureMode.Depth;
	}
	
	// Update is called once per frame
	void Update () {

	}

	public float waveSpeed = 3.0f;
	public float waveOffset = 0.6f;
	public float cycle = 20.0f;
	public Texture waveTexture;

	// Called by the camera to apply the image effect
	void OnRenderImage (RenderTexture source, RenderTexture destination){
		// http://willychyr.com/2013/11/unity-shaders-depth-and-normal-textures-part-3/
		
		Matrix4x4 viewProjInverse = (GetComponent<Camera>().projectionMatrix * GetComponent<Camera>().worldToCameraMatrix).inverse;
		mat.SetMatrix("_ViewProjectInverse", viewProjInverse);
		mat.SetVector("centerScreenPos", trans.position);
		mat.SetFloat("_waveSpeed", waveSpeed);
		mat.SetFloat("_waveOffset", waveOffset);
		mat.SetFloat("_cycle", cycle);
		mat.SetTexture("_Gradient", waveTexture);

		//Graphics.Blit(source,destination,mat);

//		RenderTexture rt = RenderTexture.GetTemporary(source.width, source.height);
//		Graphics.Blit(source, rt);
//		
//		Material effect = mat;
//		for(int i = 0; i < effect.passCount; i++){
//			RenderTexture rt2 = RenderTexture.GetTemporary(rt.width, rt.height);
//			Graphics.Blit(rt, rt2, effect, i);
//			RenderTexture.ReleaseTemporary(rt);
//			rt = rt2;
//		}
//		
//		Graphics.Blit(rt, destination);
//		RenderTexture.ReleaseTemporary(rt);

		RenderTexture rt = RenderTexture.GetTemporary(source.width, source.height);
		Graphics.Blit(source, rt, mat);
		Graphics.Blit(rt, destination);
		RenderTexture.ReleaseTemporary(rt);
	}

}