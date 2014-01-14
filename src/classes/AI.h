//
//  AI.h
//  Eve of Impact
//
//  Created by Rik Schennink on 2/18/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApplicationModel.h"
#import "AISettings.h"

@class AIActionFactory;

@interface AI : NSObject {
	
	BOOL awake;
	
	uint cycles;
	uint delay;
	uint difficulty;
	uint actionIntervalMin;
	uint actionInterval;
	uint actionLimit;
	uint actionCountdown;
	
	AISettings settings;
	
	//uint cyclesRequiredForResting;
	//uint resting;
	
	uint asteroidMax;
	//uint difficultyCycles;
	
	AIActionFactory* actionFactory;
	
	ApplicationModel* model;
}

@property (readonly) uint cycles;

-(id)initWithModel:(ApplicationModel *)applicationModel;
-(void)sleep;
-(void)wake;
-(void)think;
-(void)brainwash;
-(void)load:(AISettings)set;

@end
