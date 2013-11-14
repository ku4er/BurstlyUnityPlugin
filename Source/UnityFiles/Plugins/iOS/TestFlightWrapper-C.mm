#import <stdio.h>

#import "TestFlightWrapper-C.h"
#import "TestFlightWrapperBridge.h"


extern "C" {
	
	void TestFlightWrapper_addCustomEnvironmentInformation(const char *information, const char *key) {
		[[TestFlightWrapperBridge sharedInstance] addCustomEnvironmentInformation:CreateNSString(information) forKey:CreateNSString(key)];
	}
	
	void TestFlightWrapper_takeOff(const char *applicationToken) {
		[[TestFlightWrapperBridge sharedInstance] takeOff:CreateNSString(applicationToken)];
	}
	
	void TestFlightWrapper_passCheckpoint(const char *checkpointName) {
		[[TestFlightWrapperBridge sharedInstance] passCheckpoint:CreateNSString(checkpointName)];
	}
	
	void TestFlightWrapper_submitFeedback(const char *feedback) {
		[[TestFlightWrapperBridge sharedInstance] submitFeedback:CreateNSString(feedback)];
	}
			
}