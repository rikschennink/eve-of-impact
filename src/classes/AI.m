//
//  AI.m
//  Eve of Impact
//
//  Created by Rik Schennink on 2/18/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "AI.h"
#import "AIAction.h"
#import "AIAction.h"
#import "AIActionFactory.h"
#import "Prefs.h"
#import "ApplicationModel.h"

@implementation AI

@synthesize cycles;

-(id)initWithModel:(ApplicationModel*)applicationModel {
	
	if ((self = [super init])) {
		
		// set model reference
		model = applicationModel;

		// create action factory
		actionFactory = [[AIActionFactory alloc]init];
		
		// AI is brainwashed by default
		[self brainwash];
	}
	
	return self;
	
}

-(void)sleep {
	awake = NO;
}

-(void)wake {
	awake = YES;
}

-(void)brainwash {
	[actionFactory reset];
	awake = NO;
	
	cycles = 0;
	difficulty = INTRO;
	actionCountdown = 0;
	settings = AISettingsMake(difficulty);
	
	[self load:settings];
}

-(void)load:(AISettings)set {
	delay = set.actionDelay;
	actionInterval = set.actionInterval;	
	actionIntervalMin = set.actionIntervalMin;
	actionLimit = set.actionLimit;
}

-(void)think {
	
	// if the AI is awake and kicking!
	if (!awake) {
		return;
	}
	
	// if not to many active asteroids
	if (model.activeAsteroidCount >= settings.asteroidCountMax) {
		return;
	}
	
	// wait for a small moment
	if (delay > 0) {
		delay--;
		return;
	}
	
	
	
	// if the AI has thought long enough
	if (actionCountdown == 0) {
		
		// get appropriate action
		AIAction* action = [actionFactory getAIActionForDifficulty:difficulty];
		
		// tick of action
		actionLimit--;
		
		// switch to next difficulty level
		if (actionLimit == 0) {
			
			difficulty++;
			settings = AISettingsMake(difficulty);
			[self load:settings];
			
		}
		else {
			actionInterval -= settings.actionSteepness;
			if (actionInterval < actionIntervalMin) {
				actionInterval = actionIntervalMin;
			}
			actionCountdown = actionInterval;
		}
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"AIAction" object:action];
		
		
		//NSLog(@"%i: %i -> %i -> %i -> %i -> %i",difficulty,settings.actionInterval,actionLimit,actionInterval,actionCountdown,cycles);
		
	}
	else {
		actionCountdown--;
	}
	
	// think some more
	cycles++;
}

-(void)dealloc {
	
	[actionFactory release];
	
	[super dealloc];
}




@end
