using System;
using UnityEngine;
using System.Runtime.InteropServices;

public static class TestFlight {


	/***********************************************************/
	/*   Private methods to interface with the native C code   */
	/***********************************************************/
	 
	#if UNITY_IPHONE 
			
		[DllImport ("__Internal")]
		private static extern void TestFlightWrapper_addCustomEnvironmentInformation(string information, string key);
		
		[DllImport ("__Internal")]
		private static extern void TestFlightWrapper_takeOff(string applicationToken);
		
		[DllImport ("__Internal")]
		private static extern void TestFlightWrapper_passCheckpoint(string checkpointName);
		
		[DllImport ("__Internal")]
		private static extern void TestFlightWrapper_submitFeedback(string feedback);
		
		[DllImport ("__Internal")]
		private static extern void TestFlightWrapper_setDeviceIdentifier(string deviceIdentifier);
		
	#endif
	
	#if UNITY_ANDROID
	
		private static IntPtr TestFlightPluginClassLocalReference = AndroidJNI.FindClass("com/burstly/plugins/TestFlightWrapper");
		private static IntPtr TestFlightPluginClass = AndroidJNI.NewGlobalRef(TestFlightPluginClassLocalReference);
	
		private static IntPtr methodID_takeOff = AndroidJNI.GetStaticMethodID(TestFlightPluginClass, "takeOff", "(Ljava/lang/String;)V");
		private static IntPtr methodID_passCheckpoint = AndroidJNI.GetStaticMethodID(TestFlightPluginClass, "passCheckpoint", "(Ljava/lang/String;)V");


		private static void TestFlightWrapper_addCustomEnvironmentInformation(string information, string key) {
			// This method does not exist in the Android TestFlight SDK	
		}
		
		private static void TestFlightWrapper_takeOff(string appToken) {
			jvalue[] args = new jvalue[1];
      		args[0].l = AndroidJNI.NewStringUTF(appToken);
			AndroidJNI.CallStaticVoidMethod(TestFlightPluginClass, methodID_takeOff, args);
		}
		
		private static void TestFlightWrapper_passCheckpoint(string checkpoint) {
			jvalue[] args = new jvalue[1];
      		args[0].l = AndroidJNI.NewStringUTF(checkpoint);
			AndroidJNI.CallStaticVoidMethod(TestFlightPluginClass, methodID_passCheckpoint, args);
		}
		
		private static void TestFlightWrapper_submitFeedback(string feedback) {
			// This method does not exist in the Android TestFlight SDK	
		}
		
		private static void TestFlightWrapper_setDeviceIdentifier(string deviceIdentifier) {
			// This method does not exist in the Android TestFlight SDK	
		}
		
	#endif


	/************************************************************************/
	/*   Public methods to interface with C#/Javascript code within Unity   */
	/************************************************************************/
	
	/*
		addCustomEnvironmentInformation tracks custom information, such as a user name, from your app.
		
		Only available on iOS.
	 */
	public static void addCustomEnvironmentInformation(string information, string key) {
		#if UNITY_IPHONE || UNITY_ANDROID
			TestFlightWrapper_addCustomEnvironmentInformation(information, key);
		#endif
	}
	
	/*
		Starts a TestFlight session using the App Token for this app.
	 */
	public static void takeOff(string appToken) {
		#if UNITY_IPHONE || UNITY_ANDROID
			TestFlightWrapper_takeOff(appToken);
		#endif
	}

	/*
		Tracks when a user has passed a checkpoint after the flight has taken off. For example, passed level 1,
		posted a high score. Checkpoints are sent in the background.
	 */
	public static void passCheckpoint(string checkpoint) {
		#if UNITY_IPHONE || UNITY_ANDROID
			TestFlightWrapper_passCheckpoint(checkpoint);
		#endif
	}
	
	/*
		Submits custom feedback to the site. Sends the data in feedback to the site. This is to be used as the method
		to submit feedback for custom feedback forms.
		
		Only available on iOS.
	 */
	public static void submitFeedback(string feedback) {
		#if UNITY_IPHONE || UNITY_ANDROID
			TestFlightWrapper_submitFeedback(feedback);
		#endif
	}
	
}
