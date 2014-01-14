//
//  ShuttleStateBehaviour.m
//  Eve of Impact
//
//  Created by Rik Schennink on 2/19/11.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "ShuttleStateBehaviour.h"
#import "ActorBase.h"


@implementation ShuttleStateBehaviour

-(void)update:(ActorBase*)actor {
	
	[super update:actor];
	
	// check if actor has left the stage
	if (getDistanceSquaredToPlanet(actor.position.x, actor.position.y) > ACTOR_REMOVAL_DISTANCE_SQUARED) {
		if (![self contains:STATE_LEFT]) {
			[self add:STATE_LEFT];
		}
	}
}

@end
