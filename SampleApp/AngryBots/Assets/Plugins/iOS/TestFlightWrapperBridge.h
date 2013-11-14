//
//  TestFlightWrapperBridge.h
//  BurstlyC++Plugin
//
//  Created by abishek ashok on 2/12/13.
//  Copyright (c) 2013 abishek ashok. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TestFlightWrapper-C.h"

#import "TestFlight.h"

@interface TestFlightWrapperBridge : NSObject {

}

+ (TestFlightWrapperBridge *)sharedInstance;

- (void)addCustomEnvironmentInformation:(NSString *)information forKey:(NSString*)key;
- (void)takeOff:(NSString *)applicationToken;
- (void)passCheckpoint:(NSString *)checkpointName;
- (void)submitFeedback:(NSString*)feedback;
	
@end
