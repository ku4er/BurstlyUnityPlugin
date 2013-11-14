package com.burstly.plugins;

import android.os.Bundle;
import com.unity3d.player.UnityPlayerActivity;

public class BurstlyPluginActivity extends UnityPlayerActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        BurstlyAdWrapper.init(this);
        BurstlyCurrencyWrapper.init(this);
        
//        TestFlightWrapper.init(this.getApplication());
        
    	BurstlyAdWrapper.createViewLayout();
    }
    
    @Override
    public void onResume() {
    	BurstlyCurrencyWrapper.onResumeActivity(this);
    	BurstlyAdWrapper.onResumeActivity(this);
    	
        super.onResume();
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
