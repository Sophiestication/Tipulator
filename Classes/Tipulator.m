//
//  Tipulator.m
//  Tipulator
//
//  Created by Sophia Teutschler on 14.11.12.
//  Copyright (c) 2012 Sophia Teutschler. All rights reserved.
//

#import "Tipulator.h"
#import "TIPGuestCheckViewController.h"

#import <AVFoundation/AVFoundation.h>
#import "../Vendor/HockeySDK/Classes/HockeySDK.h"

@interface Tipulator()<BITHockeyManagerDelegate, BITUpdateManagerDelegate, BITCrashManagerDelegate>

@property(nonatomic, strong) TIPGuestCheckViewController* guestCheckViewController;

@end

@implementation Tipulator

#pragma mark - Construction & Destruction

+ (void)initialize {
	if(self != [Tipulator class]) { return; }

	NSURL* userDefaultsURL = [[NSBundle mainBundle] URLForResource:@"UserDefaults" withExtension:@"plist"];
	NSDictionary* userDefaults = [NSDictionary dictionaryWithContentsOfURL:userDefaultsURL];
	[[NSUserDefaults standardUserDefaults] registerDefaults:userDefaults];
}

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication*)application willFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
	self.guestCheckViewController = [[TIPGuestCheckViewController alloc] initWithNibName:nil bundle:nil];
	self.guestCheckViewController.restorationIdentifier = [[self class] guestCheckRestorationIdentifier];
	
	return YES;
}

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
	[[BITHockeyManager sharedHockeyManager]
		configureWithBetaIdentifier:@"39f05c82ec9f434d3686c786e14a1448"
		liveIdentifier:@"8641402b9f68736ebfb2fb7fa94fb5de"
        delegate:self];
	[[BITHockeyManager sharedHockeyManager] startManager];

	[[[BITHockeyManager sharedHockeyManager]
		crashManager] setCrashManagerStatus:BITCrashManagerStatusAutoSend];

	UIWindow* window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    window.backgroundColor = [UIColor blackColor];
	window.rootViewController = self.guestCheckViewController;

	self.window = window;
	[self.window makeKeyAndVisible];
    
	return YES;
}

#pragma mark - Restoration

- (UIViewController*)application:(UIApplication*)application viewControllerWithRestorationIdentifierPath:(NSArray*)identifierComponents coder:(NSCoder*)coder {
	NSString* identifier = [identifierComponents objectAtIndex:0];
	if([identifier isEqual:[[self class] guestCheckRestorationIdentifier]]) { return self.guestCheckViewController; }
	
	return nil;
}

- (BOOL)application:(UIApplication*)application shouldSaveApplicationState:(NSCoder*)coder {
	return YES;
}

- (BOOL)application:(UIApplication*)application shouldRestoreApplicationState:(NSCoder*)coder {
	return YES;
}

- (void)application:(UIApplication*)application willEncodeRestorableStateWithCoder:(NSCoder*)coder {
}

- (void)application:(UIApplication*)application didDecodeRestorableStateWithCoder:(NSCoder*)coder {
}

#pragma mark - BITUpdateManagerDelegate
- (NSString*)customDeviceIdentifierForUpdateManager:(BITUpdateManager*)updateManager {
#ifndef CONFIGURATION_Distribution
	if([[UIDevice currentDevice] respondsToSelector:@selector(uniqueIdentifier)]) {
		return [[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)];
	}
#endif
	return nil;
}

#pragma mark - Private

+ (NSString*)guestCheckRestorationIdentifier {
	return @"guestcheck";
}

@end