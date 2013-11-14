# Burstly Unity Plugin (includes SkyRocket and TestFlight functionality)

## Adding to Unity

In order to add the Burstly Unity plugin into your Unity project, take the drag and drop the contents of Unity/BurstlyPlugin/DragIntoUnity/Editor into your Unity project's Assets/Editor/ folder and drag and drop the contents of Unity/BurstlyPlugin/DragIntoUnity/Plugins into your Unity project's Assets/Plugins folder. Once that's done, you can add SkyRocket ad placements and TestFlight into your Unity project.

**Note**: The Burstly Unity plugin is currently supported on Windows only if Python is installed.


## Deploying

Deploying to Android and iOS is seamless - just Build and Run. Our plugin takes care of adding the appropriate frameworks and linking the required libraries for default builds containing all officially-supported networks. In order to support Adaptors, add the appropriate .jar files into the Plugins/Android directory for Android. For iOS Adaptors, add the appropriate .a files into Plugins/iOS/BurstlySDK and ensure that the Editor/PostProcessBuildPlayer-Burstly script has the appropriate linker flags to link in the adaptor .a files in the "linkerFlags" array.


## SkyRocket

The Burstly Unity plugin manifests itself as a static class called BurstlyAds for ad (banner/interstitial) functionality and BurstlyCurrency for currency functionality. Static methods within these classes are used to interact with the native Burstly SDK from managed code. You can find inline documentation for these methods in BurstlyAds.cs and BurstlyCurrency.cs. Note that the coordinate system used to position and size ads is based on the Unity GUI coordinate system and not the in-game coordinate system.

**Note**: The Burstly plugin requires overriding the default UnityActivity on Android and including specific calls in the Activity lifecycle overrides. See https://github.com/burstly/BurstlyUnityPlugin/blob/master/Source/AndroidJarProject/BurstlyPlugin/src/com/burstly/plugins/BurstlyPluginActivity.java for more information as to which calls need to be called where. If you are using a custom Activity that overrides the default UnityActivity you will not see ads unless these calls are included.

**Callbacks**: To enable callbacks, you must call the following for ads and currency, respectively:

	BurstlyAds.setCallbackGameObjectName("GameObjectName");
	BurstlyCurrency.setCallbackGameObjectName("GameObjectName");

The parameter passed must be the name of the GameObject you wish to receive callbacks. That GameObject must have a method called BurstlyCallback(message:String). The string passed in will be a pipe-delimited string of the placement name and the callback event as an int. Note that you can replace the callback at any time by calling the above method and that the currency class callback is independent of the ads class callback (i.e., you can have separate callbacks for currency and ads). Unfortunately, we currently do not support multiple callbacks.
	
**Integrated SDK Versions**:

* iOS: 2.5.0.46949 (includes TestFlight 1.2.6)
* Android: 1.34.0.46238 (includes TestFlight 1.2)
	
	
## TestFlight

This plugin includes TestFlight functionality for iOS and Android via TestFlight.cs. This class proxies all TestFlight methods directly from managed Unity code to unmanaged native (iOS and Android) code.

For Android integration, your manifest *MUST* include the following:

* A meta-data tag with android:name "testflight-app-token" within the &lt;application&gt; tag of your manifest with android:value equal to your app's TestFlight App Token. Sample: &lt;meta-data android:name="testflight-app-token" android:value="2cb80607-50c0-4f00-819a-e8f1851909b4" /&gt;
* An android:name attribute in your &lt;application&gt; tag with the value "com.burstly.plugins.TestFlightApplication". Sample: &lt;application android:name="com.burstly.plugins.TestFlightApplication"&gt;

Note that in Android no data will show in the TestFlight SDK Debugger console if the app is launched from a Unity build + run. The app must be killed and run via the phone launcher to show data in the TestFlight SDK Debugger.
	
You can find inline documentation in the repo: https://github.com/burstly/BurstlyUnityPlugin/blob/master/Source/UnityFiles/Plugins/TestFlight.cs	
	

## Known Issues

**Android**:

* Sample app positions ads based on actual display pixels and does not include logic to position ads based on differing screen sizes.

**iOS**:

* Adaptor support requires editing the Burstly post process build player script (https://github.com/burstly/BurstlyUnityPlugin/blob/master/Source/UnityFiles/Editor/PostProcessBuildPlayer-Burstly) and adding the appropriate linker flags for the adaptor (e.g., -ladmob and -lBurstly_admob_Adaptor).
	

## Sample Code

**Creating and showing a banner ad**

	BurstlyAds.createBannerPlacement("banner", "5fWofmS3902gWbwSZhXa1w", "0659117979169244027", 0, 0 , 320, 50);
	BurstlyAds.showAd("banner");
	BurstlyAds.addBannerToView("banner");

**Creating and showing an interstitial ad**

	BurstlyAds.createInterstitialPlacement("interstitial", "5fWofmS3902gWbwSZhXa1w", "0759117979169244027");
	BurstlyAds.showAd("interstitial");
	
**Initialising the currency manager**

	BurstlyCurrency.initialize("5fWofmS3902gWbwSZhXa1w", "");
	
**Adding 100 coins to the user's currency balance (e.g. after an MTX buying coins)**
	
	BurstlyCurrency.increaseBalance("coins", 100);

**Getting the number of coins a user has**
	
	coins = BurstlyCurrency.getBalance("coins");


## Reference

See inline documentation in the repo:

	Ads: https://github.com/burstly/BurstlyUnityPlugin/blob/master/Source/UnityFiles/Plugins/BurstlyAds.cs
	Currency: https://github.com/burstly/BurstlyUnityPlugin/blob/master/Source/UnityFiles/Plugins/BurstlyCurrency.cs
	TestFlight: https://github.com/burstly/BurstlyUnityPlugin/blob/master/Source/UnityFiles/Plugins/TestFlight.cs
	