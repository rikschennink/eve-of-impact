//
//  PlanetDebreeActor.m
//  Eve of Impact
//
//  Created by Rik Schennink on 5/24/11.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "PlanetDebreeActor.h"


@implementation PlanetDebreeActor

-(BOOL)canCollideWith:(ActorBase*)actor {
	return false;
}

-(uint)addEmissionsTo:(Particle*)collection atIndex:(uint)index {
	
	uint i,max = 2;
	
	for (i=0; i<max; i++) {
		
		// get reference to particle
		Particle* p = &collection[index];
		
		// get random position within radius of asteroid
		p->position.x = self->position.x + randomBetween(-.5,.5);
		p->position.y = self->position.y + randomBetween(-.5,.5);
		p->radius = (fmax(1.0,mathRandom() * 2.5) + temperature * 1.25) * .5,
		p->life = PLANET_DEBREE_PARTICLE_LIFESPAN;
		p->temperature = temperature;
		p->plasma = FALSE;
		VectorRandomize(&p->velocity, .25);
		
		index = index + 1 < PARTICLE_LIMIT ? index + 1 : 0;
	}
	
	return index;
}

@end
