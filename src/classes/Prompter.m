//
//  Prompter.m
//  Eve of Impact
//
//  Created by Rik Schennink on 7/3/11.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "Prompter.h"
#import "Prefs.h"
#import "Camera.h"
#import "Score.h"
#import "ShieldActor.h"
#import "ApplicationModel.h"

@implementation Prompter

@synthesize current;

-(id)initWithModel:(ApplicationModel*)applicationModel {
	
    self = [super init];
	
    if (self) {
        
		model = applicationModel;
				
		[self reset];
    }
    
    return self;
}

-(void)check:(uint)ticks {
	
	// lower alert countdown
	if (timeout>0) {
		timeout--;
		if (timeout==0) {
			current = PROMPT_NONE;
		}
	}
	
	[self checkAllPrompted];
	
	if (allPrompted) {
		return;
	}
	
	// pause game tip
	if (ticks > PAUSE_ALERT_TICKS) {
		if ([[NSUserDefaults standardUserDefaults] integerForKey:@"PromptPause"] > 0 &&
			[self prompt:PROMPT_PAUSE]) {
			[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"PromptPause"];
		}
	}
	
	/*
	// have we notified the user of the shuttle function
	if (model.score.points > SHUTTLE_OMEGA_CAPACITY) {
		if ([[NSUserDefaults standardUserDefaults] integerForKey:@"PromptShip"] > 0 &&
			[self prompt:PROMPT_SHIP]) {
			[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"PromptShip"];
		}
	}
	
	// pause game tip
	if (ticks > PAUSE_ALERT_TICKS) {
		if ([[NSUserDefaults standardUserDefaults] integerForKey:@"PromptPause"] > 0 &&
			[self prompt:PROMPT_PAUSE]) {
			[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"PromptPause"];
		}
	}
	
	// panic tip
	if ([model.score panic] && ticks > PANIC_ALERT_TICKS) {
		if ([[NSUserDefaults standardUserDefaults] integerForKey:@"PromptPanic"] > 0 &&
			[self prompt:PROMPT_PANIC]) {
			uint amountShown = [[NSUserDefaults standardUserDefaults] integerForKey:@"PromptPanic"];
			if (amountShown > 0) {
				amountShown--;
				[[NSUserDefaults standardUserDefaults] setInteger:amountShown forKey:@"PromptPanic"];
			}
		}
	}
	
	// super weapon tip
	if (model.shield.energy > SHIELD_ENERGY_WEAK && ticks > SUPERWEAPON_ALERT_TICKS) {
		if ([[NSUserDefaults standardUserDefaults] integerForKey:@"PromptSuperWeapon"] > 0 &&
			[self prompt:PROMPT_SUPERWEAPON]) {
			[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"PromptSuperWeapon"];
		}
	}
	*/
}

-(BOOL)prompt:(uint)type {
	
	if (current == PROMPT_NONE && type != PROMPT_NONE) {
		
		current = type;
		
		timeout = TICK_RATE * PROMPT_DURATION;
		
		allPrompted = [self checkAllPrompted];
		
		return YES;
	}
	return NO;
}

-(BOOL)checkAllPrompted {
	
	uint test = 0;
	//test += [[NSUserDefaults standardUserDefaults] integerForKey:@"PromptShip"];
	test += [[NSUserDefaults standardUserDefaults] integerForKey:@"PromptPause"];
	//test += [[NSUserDefaults standardUserDefaults] integerForKey:@"PromptPanic"];
	//test += [[NSUserDefaults standardUserDefaults] integerForKey:@"PromptSuperWeapon"];
	return test == 0;

}

-(void)reset {
	
	allPrompted = NO;
	current = PROMPT_NONE;
	timeout = 0;
	
}

-(void)resetUserDefaults {
	
	//[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"PromptSuperWeapon"];
	//[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"PromptShip"];
	[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"PromptPause"];
	//[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"PromptPanic"];
	
}

@end




















