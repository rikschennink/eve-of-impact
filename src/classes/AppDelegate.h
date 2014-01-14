//
//  AppDelegate.h
//  Eve of Impact
//
//  Created by Rik Schennink on 2/12/10.
//  Copyright Rik Schennink 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

#if defined(DEBUG)
//#import "TestFlight.h"
#endif

@class ApplicationModel;
@class ApplicationView;
@class ApplicationController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {

	ApplicationModel* model;
	ApplicationController* controller;
    
	IBOutlet UIWindow* window;
    IBOutlet ApplicationView* view;
}

@property (nonatomic, retain) IBOutlet UIWindow* window;
@property (nonatomic, retain) IBOutlet ApplicationView* view;

@end

