package com.burstly.plugins;

import android.os.Bundle;

public class BurstlyPrime31PluginActivity extends com.prime31.UnityPlayerNativeActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        BurstlyAdWrapper.init(this);
        BurstlyCurrencyWrapper.init(this);
        
    	BurstlyAdWrapper.createViewLayout();
    }
    
    @Override
    public void onResume() {
    	super.onResume();
    	
    	BurstlyCurrencyWrapper.onResumeActivity(this);
    	BurstlyAdWrapper.onResumeActivity(this);
    }

    @Override
    public void onPause() {
    	BurstlyCurrencyWrapper.onPauseActivity(this);
    	BurstlyAdWrapper.onPauseActivity(this);
    	
        super.onPause();
    }

    @Override
    public void onDestroy() {
    	BurstlyCurrencyWrapper.onDestroyActivity(this);
    	BurstlyAdWrapper.onDestroyActivity(this);
    	
        super.onDestroy();
    }

}
