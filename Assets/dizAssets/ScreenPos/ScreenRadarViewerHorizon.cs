using UnityEngine;
using System.Collections;

public class ScreenRadarViewerHorizon : MonoBehaviour {
	
	public Material mat;
	public float area = 10;

	public Texture waveTexture;
	
	void Start () {
		//camera.depthTextureMode = DepthTextureMode.DepthNormals;
		GetComponent<Camera>().depthTextureMode = DepthTextureMode.Depth;
	}
	
	// Update is called once per frame
	void Update () {

	}

	// Called by the camera to apply the image effect
	void OnRenderImage (RenderTexture source, RenderTexture destination){
		//http://forum.unity3d.com/threads/world-position-of-a-pixel-from-depth-texture.97671/

		Matrix4x4 viewProjInverse = (GetComponent<Camera>().projectionMatrix * GetComponent<Camera>().worldToCameraMatrix).inverse;
		mat.SetMatrix("_ViewProjectInverse", viewProjInverse);
		mat.SetTexture("_Gradient", waveTexture);

//		RenderTexture rt = RenderTexture.GetTemporary(source.width, source.height);
//		Graphics.Blit(source, rt, mat);
//		Graphics.Blit(rt, destination);
//		RenderTexture.ReleaseTemporary(rt);

		RenderTexture rt = RenderTexture.GetTemporary(source.width, source.height);
		Graphics.Blit(source, rt);
		
		Material effect = mat;
		for(int i = 0; i < effect.passCount; i++){
			RenderTexture rt2 = RenderTexture.GetTemporary(rt.width, rt.height);
			Graphics.Blit(rt, rt2, effect, i);
			RenderTexture.ReleaseTemporary(rt);
			rt = rt2;
		}
		
		Graphics.Blit(rt, destination);
		RenderTexture.ReleaseTemporary(rt);

		//Graphics.Blit(source,destination,mat);
	}

}