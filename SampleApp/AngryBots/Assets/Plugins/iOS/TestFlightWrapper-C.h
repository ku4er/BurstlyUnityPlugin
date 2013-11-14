#ifndef __Burstly__TestFlightWrapper_C__
#define __Burstly__TestFlightWrapper_C__

#import <Foundation/Foundation.h>

#import "BurstlyPluginUtils.h"

extern "C" {
    
	void TestFlightWrapper_addCustomEnvironmentInformation(const char *information, const char *key);
	void TestFlightWrapper_takeOff(const char *applicationToken);
	void TestFlightWrapper_passCheckpoint(const char *checkpointName);
	void TestFlightWrapper_submitFeedback(const char *feedback);

}

#endif /* defined(__Burstly__TestFlightWrapper_C__) */