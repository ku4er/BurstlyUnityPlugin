using UnityEngine;
using UnityEditor;
using UnityEditor.Callbacks;

public class TestFlightPluginUI : AssetPostprocessor {

	// Runs the Burstly PostProcessBuildPlayer script - this is needed because existing projects may have a script already defined
	[PostProcessBuild]
	public static void OnPostProcessBuild(BuildTarget target, string pathToBuiltProject) {	
		string deploymentPlatform = "";
		if (target == BuildTarget.Android) deploymentPlatform = "android";
		if (target == BuildTarget.iPhone) deploymentPlatform = "iPhone";
		
		if (deploymentPlatform == "") return;
		
		System.Diagnostics.Process p = new System.Diagnostics.Process();
		p.StartInfo.UseShellExecute = false;
		p.StartInfo.RedirectStandardOutput = true;
		p.StartInfo.FileName = Application.dataPath + "/Editor/PostProcessBuildPlayer-TestFlight";
		// This following line is commented because the keystore arguments are passed automatically by the player
		//p.StartInfo.Arguments = "'" + pathToBuiltProject + "' '" + deploymentPlatform + "' '" + EditorPrefs.GetString("AndroidSdkRoot") + "' '" + PlayerSettings.Android.keystoreName + "' '" + PlayerSettings.Android.keystorePassword + "' '" + PlayerSettings.Android.keyaliasName + "' '" + PlayerSettings.Android.keyaliasPassword + "'";
		p.StartInfo.Arguments = "'" + pathToBuiltProject + "' '" + deploymentPlatform + "' '" + EditorPrefs.GetString("AndroidSdkRoot") + "'";
		p.Start();
		string output = p.StandardOutput.ReadToEnd();
		p.WaitForExit();
		Debug.Log(output);
	}
}
