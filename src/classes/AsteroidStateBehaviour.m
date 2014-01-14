//
//  AsteroidStateBehaviour.m
//  Eve of Impact
//
//  Created by Rik Schennink on 7/6/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "AsteroidStateBehaviour.h"
#import "ActorBase.h"
#import "Collision.h"

@implementation AsteroidStateBehaviour

-(id)init {
	
	if (self = [super init]) {
		
		[super add:STATE_INVULNERABLE];
		
	}
	
	return self;
}

-(void)update:(ActorBase*)actor {
		
	[super update:actor];
	
	// get distance to center
	float distanceSquared = getDistanceSquaredToPlanet(actor.position.x, actor.position.y);
	
	
	// check if asteroid is moving away from planet
	BOOL movingAway = (-actor.velocity.x * -actor.position.x) + (-actor.velocity.y * -actor.position.y) >= 0;
	
	// asteroids are invulnerable for the first 5 ticks
	if (life == 5) {
		[self remove:STATE_INVULNERABLE];
	}
	
	// if the asteroid is leaving add matching state
	if (movingAway) {
		
		if (distanceSquared > ACTOR_REMOVAL_DISTANCE_SQUARED) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"AsteroidExit" object:nil];
			[self add:STATE_LEFT];
		}
		else if (![self contains:STATE_LEAVING]) {
			[self add:STATE_LEAVING];
		}
		
		[self remove:STATE_WARNING]; // no warning if moving away
	}
	else {
		
		[self remove:STATE_LEAVING];
		
		// warning if possible impact
		if (distanceSquared < ASTEROID_WARNING_DISTANCE_SQUARED) {
			
			Vector towards = vectorClone(&actor->position);
			vectorInvert(&towards);
			Vector heading = vectorClone(&actor->velocity);
			vectorNormalize(&heading);
			float length = vectorGetMagnitude(&towards);
			float v = vectorDotWithVector(&towards,&heading);
			float d = SHIELD_RANGE * SHIELD_RANGE - (length * length - v * v);
			bool intersects = d>=0;
			
			if (intersects && ![self contains:STATE_WARNING]) {
				[self add:STATE_WARNING];
			}
			else if(!intersects) {
				[self remove:STATE_WARNING];
			}
		}
	}
	
	
	// if asteroid gets within detection distance notify user
	if (!movingAway && distanceSquared < ASTEROID_DETECTION_DISTANCE_SQUARED) {
		
		// if asteroid has been around for some time than notify immediately, else notify after 10 ticks
		if (life > 10 && ![self contains:STATE_DETECTED] && ![self contains:STATE_ATTENTION]) {
			[self add:STATE_ATTENTION];
		}
	}
	else {
		[self remove:STATE_DETECTED];
	}

	
	// attention state only takes 25 ticks
	if ([self getLifeInState:STATE_ATTENTION] >= 25) {
		[self replace:STATE_ATTENTION with:STATE_DETECTED];
	}
}

@end



