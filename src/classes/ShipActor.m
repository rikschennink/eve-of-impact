//
//  ShipActor.m
//  Eve of Impact
//
//  Created by Rik Schennink on 10/1/11.
//  Copyright Rik Schennink. All rights reserved.
//

#import "ShipActor.h"
#import "Easing.h"

@implementation ShipActor

-(id)initWithOrigin:(Vector)myOrigin target:(Vector)myTarget andPassengers:(uint)amount {
	
	self = [super initWithOrigin:myOrigin target:myTarget andPassengers:amount];
	
	if (self) {
		
		maxSpeed = SHUTTLE_MAX_SPEED + .25;
		
	}
	
	return self;
}

-(uint)addEmissionsTo:(Particle*)collection atIndex:(uint)index {
	
	float liftOff = self.state.life < 40 ? easeLinear(self.state.life, 40) : 1.0;
	
	// get reference to particle
	Particle* p = &collection[index];
	
	// get random position within radius of asteroid
	p->position.x = self.position.x;
	p->position.y = self.position.y;
	p->temperature = .5;
	p->radius = fmax(2.0, mathRandom() * 2.5) * fmax(.5,liftOff);
	p->life	= SHUTTLE_PARTICLE_LIFESPAN;
	p->plasma = TRUE;
	p->velocity.x = randomBetween(-.06, .06) * liftOff;
	p->velocity.y = randomBetween(-.06, .06) * liftOff;
	
	index = index + 1 < PARTICLE_LIMIT ? index + 1 : 0;
	
    return index;
}

@end
