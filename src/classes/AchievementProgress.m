//
//  AchievementProgress.m
//  Eve of Impact
//
//  Created by Rik Schennink on 2/8/12.
//  Copyright (c) 2012 Rik Schennink. All rights reserved.
//

#import "AchievementProgress.h"

@implementation AchievementProgress

@synthesize uid,progress;

-(id)initWithUID:(NSString*)achievementUID andProgress:(float)achievementProgress {
	
	self = [super init];
	
	if (self) {
		
		uid = achievementUID;
		progress = achievementProgress;
		
	}
	
	return self;
}


@end
