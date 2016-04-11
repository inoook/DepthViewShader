using UnityEngine;
using System.Collections;

public class ScreenRaderViewerAnim : MonoBehaviour {

	public ScreenRadarViewer screenRadarViewer;

	// Use this for initialization
	void Start () {
	
	}

	public float amp = 10;
	public float t = 0;
	
	// Update is called once per frame
	void Update () {

	}

	void OnGUI()
	{
//		GUILayout.BeginArea(new Rect(10,10,200,200));
//		GUILayout.Label("orbit: rightMouse");
//		GUILayout.Label("speed: "+amp.ToString("0.00"));
//		amp = GUILayout.HorizontalSlider(amp, -40, 40);
//		GUILayout.Label("range: "+screenRadarViewer.areaRange.ToString("0.00"));
//		screenRadarViewer.areaRange = GUILayout.HorizontalSlider(screenRadarViewer.areaRange, 0.2f, 4);
//		GUILayout.EndArea();
	}
}
