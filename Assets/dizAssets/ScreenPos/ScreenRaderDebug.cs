using UnityEngine;
using System.Collections;

public class ScreenRaderDebug : MonoBehaviour {

	public ScreenPosViewer screenPosViewer;
	public ScreenRadarViewer screenRadarViewer;
	public ScreenRadarViewerHorizon screenRadarViewerHorizon;

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {

	}

	void OnGUI()
	{
		GUILayout.BeginArea(new Rect(10,10,300,100));
		screenPosViewer.enabled = GUILayout.Toggle(screenPosViewer.enabled, "positionView: depthTexture > world position");
		screenRadarViewer.enabled = GUILayout.Toggle(screenRadarViewer.enabled, "Spherical");
		screenRadarViewerHorizon.enabled = GUILayout.Toggle(screenRadarViewerHorizon.enabled, "Directional");
		GUILayout.EndArea();
	}
}
