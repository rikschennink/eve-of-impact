//
//  ApplicationController.h
//  Eve of Impact
//
//  Created by Rik Schennink on 2/12/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import <Twitter/Twitter.h>
#import "GameCenterManager.h"

#if defined(DEBUG)
//#import "TestFlight.h"
#endif

@class ApplicationModel;
@class ApplicationView;
@class AI;
@class AchievementDispenser;

@interface ApplicationController : UIViewController <GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate, GameCenterManagerDelegate> {
	
@private
	
	ApplicationModel* model;
	ApplicationView* view;
	
	GameCenterManager* gameCenterManager;
	AchievementDispenser* achievementDispenser;
	
	UIImage* screenshot;
	
	int touchCount;
	
	BOOL running;
}

-(id)initWithModel:(ApplicationModel*)applicationModel andView:(ApplicationView*)applicationView;

-(void)start;
-(void)stop;
-(void)pause;
-(void)loop;

-(void)connectToGameCenter;
-(void)reportScore:(uint)points;

-(void)restoreScreenshot;
-(void)cacheScreenshot;
	
@property (nonatomic,retain) GameCenterManager* gameCenterManager;
@property (assign) BOOL running;

@end
