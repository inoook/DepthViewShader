// http://forum.unity3d.com/threads/world-position-of-a-pixel-from-depth-texture.97671/
using UnityEngine;
using System.Collections;

public class CamScript : MonoBehaviour
{
	private Material m_material;
	private Camera m_cam;
	
	// Use this for initialization
	void Start ()
	{
		m_material = new Material(Shader.Find("Custom/RenderWorldPos"));
		m_cam = gameObject.GetComponent<Camera>();
		m_cam.depthTextureMode = DepthTextureMode.DepthNormals;
	}
	
	void OnRenderImage(RenderTexture src, RenderTexture dst)
	{
		Matrix4x4 viewProjInverse = (m_cam.projectionMatrix * m_cam.worldToCameraMatrix).inverse;
		m_material.SetMatrix("_ViewProjectInverse", viewProjInverse);
		Graphics.Blit(src, dst, m_material);
	}
}