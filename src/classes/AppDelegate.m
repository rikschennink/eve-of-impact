//
//  AppDelegate.m
//  Eve of Impact
//
//  Created by Rik Schennink on 2/12/10.
//  Copyright Rik Schennink 2010. All rights reserved.
//

#import "AppDelegate.h"
#import "ApplicationView.h"
#import "ApplicationModel.h"
#import "ApplicationController.h"

@implementation AppDelegate

@synthesize window;
@synthesize view;



- (void) applicationDidFinishLaunching:(UIApplication *)application {
	
	#if defined(DEBUG)
	
	NSLog(@"did finish launching");
	NSLog(@"start testflight");
	
	
	#endif

	// get the filename for "default defaults"
	NSString *defaultsFilename = [[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"];
	
	// initialize a dictionary with contents of it
	NSDictionary *defaults = [NSDictionary dictionaryWithContentsOfFile:defaultsFilename];
	
	// register defaults
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
	
	// set model
	model = [[ApplicationModel alloc] init];
	
	// define window
	window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	
	// define view
	view = [[ApplicationView alloc] initWithFrame:window.bounds andModelReference:model];
	
	// add view to window
	[window addSubview:view];
	[window makeKeyAndVisible];
	
	// initialize controller
	controller = [[ApplicationController alloc] initWithModel:model andView:view];
	
	// set controller as root view controller
	window.rootViewController = controller;
}

- (void) applicationDidBecomeActive:(UIApplication *)application {
	
#if defined(DEBUG)	
	NSLog(@"did become active");
#endif
	
	[controller start]; // starts or resumes app
}

- (void) applicationWillResignActive:(UIApplication *)application {
	
#if defined(DEBUG)	
	NSLog(@"will resign active"); // pause the app
#endif
	
	[controller pause];
}

- (void) applicationWillTerminate:(UIApplication *)application {
	
#if defined(DEBUG)	
	NSLog(@"will terminate"); // time to stop controller and store model
#endif
	
	[controller stop];
}

- (void) applicationDidEnterBackground:(UIApplication *)application {
	
#if defined(DEBUG)	
	NSLog(@"enter background"); // app should have been paused by will resign active
#endif
	
}

- (void) applicationWillEnterForeground:(UIApplication *)application {
#if defined(DEBUG)	
	NSLog(@"enter foreground"); // next call will be to did become active
#endif
}

- (void) applicationDidReceiveMemoryWarning:(UIApplication *)application {
#if defined(DEBUG)
	NSLog(@"memory warning");
#endif
}

- (void) dealloc {
	
	[window release];
	[view release];
	[model release];
	[controller release];
	
	[super dealloc];
}

@end
