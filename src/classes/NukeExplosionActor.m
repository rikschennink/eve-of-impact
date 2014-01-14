//
//  ExplosionActor.m
//  Eve of Impact
//
//  Created by Rik Schennink on 4/2/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "NukeExplosionActor.h"
#import "ExplosionStateBehaviour.h"

@implementation NukeExplosionActor


-(id)init {
	
	if (self = [super initWithFragmentationRadius:NUKE_FRAGMENT_RADIUS 
								  shockwaveRadius:NUKE_PUSH_RADIUS 
									 andBehaviour:(StateBehaviourBase<StateBehaviour>*)[[ExplosionStateBehaviour alloc] initWithLifespan:NUKE_LIFE_SPAN]]) {
		
		radius = radiusMax;
		pushForce = NUKE_PUSH_FORCE;
	}
	
	return self;
}

-(void)expand {
	shockwaveRadius = shockwaveRadiusMax * self.state.progress;
}

-(uint)addEmissionsTo:(Particle*)collection atIndex:(uint)index {
	
	float progress = [self.state progress];
	
	if (progress > .25 && progress < .35) {
		
		uint i,max = 12;
		
		Vector pos;
		
		for (i=0; i<max; i++) {
			
			// get reference to particle
			Particle* p = &collection[index];
			
			pos = getRandomPositionAtDistanceFromCenter(13.0);
			p->position.x = pos.x + self.position.x;
			p->position.y = pos.y + self.position.y;
			
			// get random position within radius of asteroid
			p->radius = fmax(1.0,mathRandom() * 2.5);
			p->life = EXPLOSION_PARTICLE_LIFESPAN;
			p->temperature = 1.0;
			p->plasma = FALSE;
			p->velocity.x = pos.x * .07 * mathRandom();
			p->velocity.y = pos.y * .07 * mathRandom();
			
			index = index + 1 < PARTICLE_LIMIT ? index + 1 : 0;
		}
	}
	else if (progress > .7 && progress < .8) {
		
		uint i,max = 6;
		
		Vector pos;
		
		for (i=0; i<max; i++) {
			
			// get reference to particle
			Particle* p = &collection[index];
			
			pos = getRandomPositionAtDistanceFromCenter(16.0);
			p->position.x = pos.x + self.position.x;
			p->position.y = pos.y + self.position.y;
			
			// get random position within radius of asteroid
			p->radius = fmax(1.0,mathRandom() * 2.5);
			p->life = EXPLOSION_PARTICLE_LIFESPAN - 10;
			p->temperature = 0.0;
			p->plasma = FALSE;
			p->velocity.x = -pos.x * .045 * mathRandom();
			p->velocity.y = -pos.y * .045 * mathRandom();
			
			index = index + 1 < PARTICLE_LIMIT ? index + 1 : 0;
		}
	}
	
	if (progress > .85 && progress < .95) {
		
		uint i,max = 8;
		Vector pos;
		
		for (i=0; i<max; i++) {
			
			// get reference to particle
			Particle* p = &collection[index];
			
			pos = VectorMakeRandom(4.0);
			p->position.x = pos.x + self.position.x;
			p->position.y = pos.y + self.position.y;
			
			// get random position within radius of asteroid
			p->radius = fmax(1.0,mathRandom() * 3.5);
			p->life = EXPLOSION_PARTICLE_LIFESPAN - 20;
			p->temperature = 1.0;
			p->plasma = FALSE;
			p->velocity.x = -pos.x * .01 * mathRandom();
			p->velocity.y = -pos.y * .01 * mathRandom();
			
			index = index + 1 < PARTICLE_LIMIT ? index + 1 : 0;
		}
	}

	
	return index;
}

@end
