//
//  BurstlyAdWrapperBridge.m
//  BurstlyC++Plugin
//
//  Created by abishek ashok on 2/12/13.
//  Copyright (c) 2013 abishek ashok. All rights reserved.
//

#import "BurstlyAdWrapperBridge.h"


@implementation BurstlyAdWrapperBridge

static BurstlyAdWrapperBridge *_sharedInstance;


#pragma mark Singleton Implementation

+ (id)allocWithZone:(NSZone*)zone {
	@synchronized(self) {
		if (_sharedInstance == nil) {
			_sharedInstance = [super allocWithZone:zone];
			return _sharedInstance; // assignment and return on first allocation
		}
	}
	return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone { return self; }

- (id)retain { return self; }

- (unsigned)retainCount {
	return UINT_MAX; //denotes an object that cannot be released
}

- (oneway void)release {
	//do nothing
}

- (id)autorelease { return self; }

- (id)init {
    self = [super init];
    if (self) {
    	
    	/*
    		This following code is required to make sure that interstitial ads and banner canvases are displayed
    		properly in GL/Unity games. This is due to the GL UIViewController being oriented in a different 
    		orientation than the actual game content. Two UIViewControllers (one to display ads on the screen
    		and another to present ads modally) are required due to orientation weirdness when presenting another
    		UIViewController modally from the UIViewController (this happens on banner canvas presentation). The
    		UIViewController is rotated when the modal UIVIewController is presented, and is then cut off. Having
    		two UIViewControllers fixes this, although it does add additional processing overhead in passing through
    		touches.
    		
    		NOTE: Using UnityGetGLViewController() will display ads correctly but will have modally-presented
    			  UIViewControllers _NOT_ oriented correctly.
    	 */
    	
        _rootViewController = [[BurstlyAdViewViewController alloc] init];
        [[[UIApplication sharedApplication] keyWindow].rootViewController addChildViewController:_rootViewController];
        [[[UIApplication sharedApplication] keyWindow].rootViewController.view addSubview:_rootViewController.view];

        _viewControllerForModalPresentation = [[UIViewController alloc] init];
        _viewControllerForModalPresentation.view = [[BurstlyAdViewView alloc] initWithFrame:_rootViewController.view.frame];
        [[[UIApplication sharedApplication] keyWindow] addSubview:_viewControllerForModalPresentation.view];

        _placementDictionary = [[NSMutableDictionary alloc] init];
        
        [self setLoggingEnabled:YES];
    }
    return self;
}

+ (BurstlyAdWrapperBridge *)sharedInstance {
	@synchronized(self) {
		if (_sharedInstance == nil) {
			[[self alloc] init]; // assignment not done here
		}
	}
	return _sharedInstance;
}

#pragma mark Class Implementation

- (void)trackDownload {
	[BurstlyDownloadTracker track];
}

- (void)createBurstlyBannerAdWithPlacement:(NSString *)placement appId:(NSString*)appId andZoneId:(NSString*)zoneId andFrame:(CGRect)bannerFrame {
    // NOTE: this means nothing happens if the placement has already been created
    if (!placement || [_placementDictionary objectForKey:placement]) {
        NSLog(@"Placement already exists");
        return;
    }
    
    BurstlyBanner *banner = [[BurstlyBanner alloc] initWithAppId:appId zoneId:zoneId frame:bannerFrame anchor:BurstlyAnchorTop rootViewController:_viewControllerForModalPresentation delegate:self];
    banner.adRequest = [BurstlyAdRequest request];
	banner.adRequest.targetingParameters = @"";
	banner.adRequest.adParameters = @"";
    [_placementDictionary setObject:banner forKey:placement];
}

- (void)createBurstlyInterstitialWithPlacement:(NSString *)placement appId:(NSString*)appId andZoneId:(NSString*)zoneId {
    // NOTE: this means nothing happens if the placement has already been created
    if (!placement || [_placementDictionary objectForKey:placement]) {
        NSLog(@"Placement already exists");
        return;
    }
    
    BurstlyInterstitial *interstitial = [[BurstlyInterstitial alloc] initAppId:appId zoneId:zoneId delegate:self];
    interstitial.adRequest = [BurstlyAdRequest request];
	interstitial.adRequest.targetingParameters = @"";
	interstitial.adRequest.adParameters = @"";
    [_placementDictionary setObject:interstitial forKey:placement];
}

- (void)destroyBurstlyAdWithPlacement:(NSString *)placement {
    id adPlacement = [_placementDictionary objectForKey:placement];
    if (adPlacement) {
        if ([adPlacement isKindOfClass:[BurstlyBanner class]]) {
            [(BurstlyBanner *)adPlacement removeFromSuperview];
            ((BurstlyBanner *)adPlacement).delegate = nil;
        }
        [adPlacement release];
        adPlacement = nil;
        [_placementDictionary removeObjectForKey:placement];
    } else {
        NSLog(@"Placement does not exist.");
    }
}

- (void)showAdForPlacement:(NSString*)placement {
    id adPlacement = [_placementDictionary objectForKey:placement];
    if (adPlacement) {
        [adPlacement showAd];
    } else {
        NSLog(@"Placement does not exist.");
    }
}

- (void)cacheAdForPlacement:(NSString*)placement {
    id adPlacement = [_placementDictionary objectForKey:placement];
    if (adPlacement && [adPlacement isKindOfClass:[BurstlyInterstitial class]]) {
        [adPlacement cacheAd];
    } else {
        NSLog(@"Incorrect placement type for value. Expected type: BurstlyInterstitial");
    }
}

- (void)pauseBannerForPlacement:(NSString *)placement{
    id view = [_placementDictionary objectForKey:placement];
    if (view && [view isKindOfClass:[BurstlyBanner class]]) {
        ((BurstlyBanner *)view).adPaused = YES;
    } else {
        NSLog(@"Incorrect placement type for value. Expected type: BurstlyBanner");
    }
}

- (void)unpauseBannerForPlacement:(NSString *)placement{
    id view = [_placementDictionary objectForKey:placement];
    if (view && [view isKindOfClass:[BurstlyBanner class]]) {
        ((BurstlyBanner *)view).adPaused = NO;
    } else {
        NSLog(@"Incorrect placement type for value. Expected type: BurstlyBanner");
    }
}

- (void)addBannerToViewForPlacement:(NSString *)placement{
    id view = [_placementDictionary objectForKey:placement];
    if (view && [view isKindOfClass:[BurstlyBanner class]]) {
        [_rootViewController.view addSubview:(BurstlyBanner *)view];
    } else {
        NSLog(@"Incorrect placement type for value. Expected type: BurstlyBanner");
    }
}

- (void)removeBannerFromViewForPlacement:(NSString *)placement{
    id view = [_placementDictionary objectForKey:placement];
    if (view && [view isKindOfClass:[BurstlyBanner class]]) {
        [(BurstlyBanner *)view removeFromSuperview];
    } else {
        NSLog(@"Incorrect placement type for value. Expected type: BurstlyBanner");
    }
}

- (BOOL)isAdCachedForPlacement:(NSString*)placement {
    id adPlacement = [_placementDictionary objectForKey:placement];
    if (adPlacement && [adPlacement isKindOfClass:[BurstlyInterstitial class]]) {
        return ((BurstlyInterstitial *)adPlacement).state == BurstlyInterstitialStateCached;
    } else {
        NSLog(@"Incorrect placement type for value. Expected type: BurstlyInterstitial");
    }
    return NO;
}

- (void)setBannerOrigin:(CGPoint)origin forPlacement:(NSString *)placement{
    id view = [_placementDictionary objectForKey:placement];
    if (view && [view isKindOfClass:[BurstlyBanner class]]) {
        CGRect frame = [view frame];
        frame.origin.x = origin.x;
        frame.origin.y = origin.y;
        ((BurstlyBanner *)view).frame = frame;
    } else {
        NSLog(@"Incorrect placement type for value. Expected type: BurstlyBanner");
    }
}

- (void)setBannerRefreshRate:(CGFloat)refreshRate forPlacement:(NSString *)placement {
    id view = [_placementDictionary objectForKey:placement];
    if (view && [view isKindOfClass:[BurstlyBanner class]]) {
        ((BurstlyBanner *)view).defaultRefreshInterval = refreshRate;
    } else {
        NSLog(@"Incorrect placement type for value. Expected type: BurstlyBanner");
    }
}

- (void)setTargettingParameters:(NSString *)targettingParameters forPlacement:(NSString *)placement {
	id adPlacement = [_placementDictionary objectForKey:placement];
    if (adPlacement) {
        if ([adPlacement isKindOfClass:[BurstlyInterstitial class]])
            ((BurstlyInterstitial *)adPlacement).adRequest.targetingParameters = targettingParameters;
        else if ([adPlacement isKindOfClass:[BurstlyBanner class]])
            ((BurstlyBanner *)adPlacement).adRequest.targetingParameters = targettingParameters;
    } else {
        NSLog(@"Placement does not exist.");
    }
}

- (void)setAdParameters:(NSString *)adParameters forPlacement:(NSString *)placement {
	id adPlacement = [_placementDictionary objectForKey:placement];
    if (adPlacement) {
        if ([adPlacement isKindOfClass:[BurstlyInterstitial class]])
            ((BurstlyInterstitial *)adPlacement).adRequest.adParameters = adParameters;
        else if ([adPlacement isKindOfClass:[BurstlyBanner class]])
            ((BurstlyBanner *)adPlacement).adRequest.adParameters = adParameters;
    } else {
        NSLog(@"Placement does not exist.");
    }	
}

- (void)setLoggingEnabled:(BOOL)enabled {
	if (enabled)
		[BurstlyAdUtils setLogLevel:BurstlyLogLevelDebug];
	else
		[BurstlyAdUtils setLogLevel:BurstlyLogLevelFatal];
}

#pragma mark - BurstlyBannerViewDelegate Protocol

- (void)burstlyBanner:(BurstlyBanner *)view willTakeOverFullScreen:(NSDictionary *)info {
    NSArray *validKeys = [_placementDictionary allKeysForObject:view];
    if (validKeys && [validKeys count] > 0) {
        BurstlyAdWrapper_callback([(NSString *)[validKeys objectAtIndex:0] UTF8String], BurstlyEventTakeoverFullscreen);
    }
}

- (void)burstlyBanner:(BurstlyBanner *)view willDismissFullScreen:(NSDictionary *)info {
    NSArray *validKeys = [_placementDictionary allKeysForObject:view];
    if (validKeys && [validKeys count] > 0) {
        BurstlyAdWrapper_callback([(NSString *)[validKeys objectAtIndex:0] UTF8String], BurstlyEventDismissFullscreen);
    }
}

- (void)burstlyBanner:(BurstlyBanner *)view didHide:(NSDictionary *)info {
    NSArray *validKeys = [_placementDictionary allKeysForObject:view];
    if (validKeys && [validKeys count] > 0) {
        BurstlyAdWrapper_callback([(NSString *)[validKeys objectAtIndex:0] UTF8String], BurstlyEventHidden);
    }
}

- (void)burstlyBanner:(BurstlyBanner *)view didShow:(NSDictionary *)info {
    NSArray *validKeys = [_placementDictionary allKeysForObject:view];
    if (validKeys && [validKeys count] > 0) {
        BurstlyAdWrapper_callback([(NSString *)[validKeys objectAtIndex:0] UTF8String], BurstlyEventShown);
    }
}

- (void)burstlyBanner:(BurstlyBanner *)view didCache:(NSDictionary *)info {
    NSArray *validKeys = [_placementDictionary allKeysForObject:view];
    if (validKeys && [validKeys count] > 0) {
        BurstlyAdWrapper_callback([(NSString *)[validKeys objectAtIndex:0] UTF8String], BurstlyEventCached);
    }
}

- (void)burstlyBanner:(BurstlyBanner *)view wasClicked:(NSDictionary *)info {
    NSArray *validKeys = [_placementDictionary allKeysForObject:view];
    if (validKeys && [validKeys count] > 0) {
        BurstlyAdWrapper_callback([(NSString *)[validKeys objectAtIndex:0] UTF8String], BurstlyEventClicked);
    }
}

- (void)burstlyBanner:(BurstlyBanner *)view didFail:(NSDictionary *)info {
    NSArray *validKeys = [_placementDictionary allKeysForObject:view];
    if (validKeys && [validKeys count] > 0) {
        BurstlyAdWrapper_callback([(NSString *)[validKeys objectAtIndex:0] UTF8String], BurstlyEventFailed);
    }
}

// Unimplemented BurstlyBannerDelegate Protocol Methods:
// - (BOOL)burstlyBanner:(BurstlyBanner *)view shouldAutorotateInterstitialAdToInterfaceOrientation: (UIInterfaceOrientation)orientation withInfo: (NSDictionary *)info;
// - (UIInterfaceOrientation)burstlyBannerRequiresCurrentInterfaceOrientation: (BurstlyBanner *)view withInfo: (NSDictionary *)info;


#pragma mark - BurstlyInterstitialDelegate Protocol

- (UIViewController*)viewControllerForModalPresentation:(BurstlyInterstitial *)interstitial {
    return _viewControllerForModalPresentation;
}

- (void)burstlyInterstitial:(BurstlyInterstitial *)ad willTakeOverFullScreen:(NSDictionary *)info {
    NSArray *validKeys = [_placementDictionary allKeysForObject:ad];
    if (validKeys && [validKeys count] > 0) {
        BurstlyAdWrapper_callback([(NSString *)[validKeys objectAtIndex:0] UTF8String], BurstlyEventTakeoverFullscreen);
    }
}

- (void)burstlyInterstitial:(BurstlyInterstitial *)ad willDismissFullScreen:(NSDictionary *)info {
    NSArray *validKeys = [_placementDictionary allKeysForObject:ad];
    if (validKeys && [validKeys count] > 0) {
        BurstlyAdWrapper_callback([(NSString *)[validKeys objectAtIndex:0] UTF8String], BurstlyEventDismissFullscreen);
    }
}

- (void)burstlyInterstitial:(BurstlyInterstitial *)ad didHide:(NSDictionary *)info {
    NSArray *validKeys = [_placementDictionary allKeysForObject:ad];
    if (validKeys && [validKeys count] > 0) {
        BurstlyAdWrapper_callback([(NSString *)[validKeys objectAtIndex:0] UTF8String], BurstlyEventHidden);
    }
}

- (void)burstlyInterstitial:(BurstlyInterstitial *)ad didShow:(NSDictionary *)info {
    NSArray *validKeys = [_placementDictionary allKeysForObject:ad];
    if (validKeys && [validKeys count] > 0) {
        BurstlyAdWrapper_callback([(NSString *)[validKeys objectAtIndex:0] UTF8String], BurstlyEventShown);
    }
}

- (void)burstlyInterstitial:(BurstlyInterstitial *)ad didCache:(NSDictionary *)info {
    NSArray *validKeys = [_placementDictionary allKeysForObject:ad];
    if (validKeys && [validKeys count] > 0) {
        BurstlyAdWrapper_callback([(NSString *)[validKeys objectAtIndex:0] UTF8String], BurstlyEventCached);
    }
}

- (void)burstlyInterstitial:(BurstlyInterstitial *)ad wasClicked:(NSDictionary *)info {
    NSArray *validKeys = [_placementDictionary allKeysForObject:ad];
    if (validKeys && [validKeys count] > 0) {
        BurstlyAdWrapper_callback([(NSString *)[validKeys objectAtIndex:0] UTF8String], BurstlyEventClicked);
    }
}

- (void)burstlyInterstitial:(BurstlyInterstitial *)ad didFail:(NSDictionary *)info {
    NSArray *validKeys = [_placementDictionary allKeysForObject:ad];
    if (validKeys && [validKeys count] > 0) {
        BurstlyAdWrapper_callback([(NSString *)[validKeys objectAtIndex:0] UTF8String], BurstlyEventFailed);
    }
}

// Unimplemented BurstlyInterstitialDelegate Protocol Methods:
// - (BOOL)burstlyInterstitial:(BurstlyInterstitial *)ad shouldAutorotateInterstitialAdToInterfaceOrientation: (UIInterfaceOrientation)orientation withInfo: (NSDictionary *)info;
// - (UIInterfaceOrientation)burstlyInterstitialRequiresCurrentInterfaceOrientation: (BurstlyInterstitial *)ad withInfo: (NSDictionary *)info;

@end
