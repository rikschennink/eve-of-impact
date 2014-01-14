//
//  ShuttleExplosionActor.m
//  Eve of Impact
//
//  Created by Rik Schennink on 12/1/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "ShuttleExplosionActor.h"
#import "ShuttleExplosionStateBehaviour.h"
#import "ShipActorBase.h"
#import "Easing.h"

@implementation ShuttleExplosionActor

@synthesize flash;

-(id)initWithScale:(float)scale {
	
	uint lifespan = MAX(SHUTTLE_EXPLOSION_LIFE_SPAN,SHUTTLE_EXPLOSION_LIFE_SPAN * scale);
	
	self = [super initWithFragmentationRadius:SHUTTLE_EXPLOSION_FRAGMENT_RADIUS * scale
							  shockwaveRadius:SHUTTLE_EXPLOSION_PUSH_RADIUS * scale
								 andBehaviour:(StateBehaviourBase<StateBehaviour>*)[[ShuttleExplosionStateBehaviour alloc] initWithLifespan:lifespan]];
	
	if (self) {
		pushForce = 0.1;
		flash = NO;
	}
	
	return self;
}

-(void)expand {
	float progress = easeOutSine(self.state.life,self.state.lifespan);
	radius = radiusMax * progress;
	shockwaveRadius = shockwaveRadiusMax * progress;
}

-(BOOL)canCollideWith:(ActorBase*)actor {
	
	bool inside = false;
	
	if ([actor isKindOfClass:[ShipActorBase class]]) {
		inside = actor.state.life <= state.life;
	}
	
	return !inside && [super canCollideWith:actor];
}

-(uint)addEmissionsTo:(Particle*)collection atIndex:(uint)index {
	
	float progress = [self.state progress];
	
	if (progress > .7 && progress < .75) {
		
		uint i,max = 8;
		Vector pos;
		
		for (i=0; i<max; i++) {
			
			// get reference to particle
			Particle* p = &collection[index];
			
			pos = VectorMakeRandom(3.0);
			p->position.x = pos.x + self.position.x;
			p->position.y = pos.y + self.position.y;
			
			// get random position within radius of asteroid
			p->radius = fmax(1.0,mathRandom() * 3.5);
			p->life = SHUTTLE_EXPLOSION_PARTICLE_LIFESPAN;
			p->temperature = 1.0;
			p->plasma = FALSE;
			p->velocity.x = pos.x * .025 * mathRandom();
			p->velocity.y = pos.y * .025 * mathRandom();
			
			index = index + 1 < PARTICLE_LIMIT ? index + 1 : 0;
		}
	}
	else if (progress > .25 && progress < .35) {
		
		uint i,max = 18;
		Vector pos;
		
		for (i=0; i<max; i++) {
			
			// get reference to particle
			Particle* p = &collection[index];
			
			pos = getRandomPositionAtDistanceFromCenter(18.0);
			p->position.x = pos.x + self.position.x;
			p->position.y = pos.y + self.position.y;
			
			// get random position within radius of asteroid
			p->radius = fmax(1.0,mathRandom() * 5.0);
			p->life = SHUTTLE_EXPLOSION_PARTICLE_LIFESPAN;
			p->temperature = 1.0;
			p->plasma = FALSE;
			p->velocity.x = pos.x * .01 * mathRandom();
			p->velocity.y = pos.y * .01 * mathRandom();
			
			index = index + 1 < PARTICLE_LIMIT ? index + 1 : 0;
		}
	}
	
	return index;
}

@end
