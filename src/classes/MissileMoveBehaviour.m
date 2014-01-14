//
//  MissileMoveBehaviour.m
//  Eve of Impact
//
//  Created by Rik Schennink on 7/7/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "MissileMoveBehaviour.h"
#import "MissileActor.h"

@implementation MissileMoveBehaviour


-(void)update:(MissileActor*)actor {
	
	[super update:actor];
	
	if (progress >= 1.0) {
		[actor readyToExplode];
	}
	
}

@end
