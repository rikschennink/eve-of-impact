//
//  RotationalMoveBehaviour.m
//  Eve of Impact
//
//  Created by Rik Schennink on 2/15/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "RotationalMoveBehaviour.h"
#import "ActorBase.h"
#import "MathAdditional.h"

@implementation RotationalMoveBehaviour


-(id)initAndRotateAtDistance:(float)d 
				  withOffset:(float)o 
					 atSpeed:(float)s {
	
	if (self = [super init]) {
		distance = d;
		offset = o;
		speed = s;
	}
	
	return self;
}

-(void)update:(ActorBase*)actor {
	
	// store position in temp vars
	float tx = actor.position.x;
	float ty = actor.position.y;
	
	// get angle
	float angle = offset * TRIG_PI_D_180;
	
	// update offset
	offset += speed;
	
	// set position
	actor->position.x = distance * cosf(angle);
	actor->position.y = distance * sinf(angle);
	
	// update 'fake' velocity (required for collision detection etc.)
	actor->velocity.x = actor->position.x - tx;
	actor->velocity.y = actor->position.y - ty;
	
	[super update:actor];
}

-(void)dealloc {
	
	[super dealloc];
}

@end
