//
//  DebreeActor.m
//  Eve of Impact
//
//  Created by Rik Schennink on 2/26/11.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "DebreeActor.h"
#import "LinearMoveBehaviour.h"
#import "DebreeStateBehaviour.h"
#import "MoonActor.h"
#import "ShieldActor.h"
#import "Explodable.h"
#import "NukeExplosionActor.h"

@implementation DebreeActor

@synthesize temperature;

-(id)initWithTemperature:(float)amount andLifespan:(uint)span {
	
	DebreeStateBehaviour<StateBehaviour>* stateBehaviour = (DebreeStateBehaviour<StateBehaviour>*)[[DebreeStateBehaviour alloc] initWithLifespan:span];
	LinearMoveBehaviour<MoveBehaviour>* moveBehaviour = [[LinearMoveBehaviour alloc] init];
	
	if ((self = [super initWithRadius:0 state:stateBehaviour movement:moveBehaviour])) {
		
		temperature = amount;
		self.mass = ASTEROID_HARMLESS_RADIUS;
		
	}
	
	return self;
}

-(void)act {
	
	if (getDistanceSquaredToPlanet(self->position.x,self->position.y) < ASTEROID_BURN_DISTANCE_SQUARED) {
		temperature = temperature + .05 < 1 ? temperature + .05 : 1;
	}
	else {
		temperature = temperature - .025 > 0 ? temperature - .025 : 0;
	}
	
	[super act];
	
	// limit speed
	vectorLimit(&self->velocity, ASTEROID_VELOCITY);
	
}

-(void)collideWith:(ActorBase*)actor afterTime:(float)time {
	
}

-(BOOL)canCollideWith:(ActorBase*)actor {
	
	if ([actor isKindOfClass:[MoonActor class]] ||
		[actor isKindOfClass:[ShieldActor class]]) {
		return true;
	}
	
	return false;
}

-(void)push:(Vector)origin {
	
}

-(uint)addEmissionsTo:(Particle*)collection atIndex:(uint)index {
	
	uint i,max = 2;
	
	for (i=0; i<max; i++) {
		
		// get reference to particle
		Particle* p = &collection[index];
		
		// get random position within radius of asteroid
		p->position.x = self->position.x + randomBetween(-.5,.5);
		p->position.y = self->position.y + randomBetween(-.5,.5);
		p->radius = fmax(1.0,mathRandom() * 2.5) + temperature * 1.25,
		p->life = DEBREE_PARTICLE_LIFESPAN;
		p->temperature = temperature;
		p->plasma = FALSE;
		VectorRandomize(&p->velocity, .1);
		
		index = index + 1 < PARTICLE_LIMIT ? index + 1 : 0;
	}
	
	if (self.dead) {
		
		max = 3 + (mathRandom() * 3);
		
		for (i=0; i<max; i++) {
			
			// get reference to particle
			Particle* p = &collection[index];
			
			// get random position within radius of asteroid
			p->position.x = self->position.x + randomBetween(-.5,.5);
			p->position.y = self->position.y + randomBetween(-.5,.5);
			p->radius = fmax(.5,mathRandom() * 1.5) + temperature * .25,
			p->life = DEBREE_PARTICLE_LIFESPAN;
			p->temperature = temperature;
			p->plasma = FALSE;
			VectorRandomize(&p->velocity, .25);
			
			index = index + 1 < PARTICLE_LIMIT ? index + 1 : 0;
		}
	}
	
	return index;
}


@end