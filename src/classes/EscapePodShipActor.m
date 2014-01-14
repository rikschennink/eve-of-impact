//
//  EscapePodShipActor.m
//  Eve of Impact
//
//  Created by Rik Schennink on 8/29/11.
//  Copyright Rik Schennink. All rights reserved.
//

#import "EscapePodShipActor.h"
#import "Easing.h"

@implementation EscapePodShipActor

-(id)initWithOrigin:(Vector)myOrigin target:(Vector)myTarget andPassengers:(uint)amount {
	
	self = [super initWithOrigin:myOrigin target:myTarget andPassengers:amount];
	
	if (self) {
		
		maxSpeed = SHUTTLE_MAX_SPEED + randomBetween(.3, .35);
		vectorRandomize(&thrust);
	}
	
	return self;
}

-(uint)addEmissionsTo:(Particle*)collection atIndex:(uint)index {
	
	float liftOff = self.state.life < 30 ? easeLinear(self.state.life, 30) : 1.0;
	
	// get reference to particle
	Particle* p = &collection[index];
	
	// get random position within radius of asteroid
	p->position.x = self.position.x;
	p->position.y = self.position.y;
	p->temperature = .25;
	p->radius = fmax(1.5, mathRandom() * 2.0) * fmax(.5,liftOff);
	p->life	= ESCAPE_POD_PARTICLE_LIFESPAN;
	p->plasma = TRUE;
	p->velocity.x = randomBetween(-.025, .025) * liftOff;
	p->velocity.y = randomBetween(-.025, .025) * liftOff;
	
	index = index + 1 < PARTICLE_LIMIT ? index + 1 : 0;
	
    return index;
}

-(void)push:(Vector)direction {
	if (self.state.life > 50) {
		[super push:direction];
	}
}

@end
