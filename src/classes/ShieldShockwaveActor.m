//
//  ShieldShockwaveActor.m
//  Eve of Impact
//
//  Created by Rik Schennink on 5/17/11.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "ShieldShockwaveActor.h"
#import "ShieldShockwaveStateBehaviour.h"
#import "ShipActorBase.h"
#import "Particle.h"

@implementation ShieldShockwaveActor


-(id)initWithRange:(float)range {
	
	self = [super initWithFragmentationRadius:range 
		  	shockwaveRadius:range
			andBehaviour:(StateBehaviourBase<StateBehaviour>*)[[ShieldShockwaveStateBehaviour alloc] initWithLifespan:SHIELD_SHOCKWAVE_LIFESPAN]];

	if (self) {
		pushForce = 0.5;
		pushRadius = 0.0;
	}
	
	return self;
}

-(BOOL)canCollideWith:(ActorBase*)actor {
	return ![actor isKindOfClass:[ShipActorBase class]] && 
			[self.state contains:STATE_ALIVE] && 
			[actor conformsToProtocol:@protocol(Destructable)];
}

-(void)expand {
	float progress = easeOutSine(self.state.life,self.state.lifespan);
	radius = fmax(SHIELD_RANGE,radiusMax * progress);
	shockwaveRadius = fmax(SHIELD_RANGE,shockwaveRadiusMax * progress);
	pushRadius = radius;
}

-(uint)addEmissionsTo:(Particle*)collection atIndex:(uint)index {
	
	float progress = [self.state progress];
	
	uint i,max;
	Vector pos;

	if (progress < .1) {
		
		max = 4;
		
		for (i=0; i<max; i++) {
			
			// get reference to particle
			Particle* p = &collection[index];
			
			pos = getRandomPositionAtDistanceFromCenter(SHIELD_RANGE);
			p->position.x = pos.x + self.position.x;
			p->position.y = pos.y + self.position.y;
			
			// get random position within radius of asteroid
			p->radius = fmax(1.0,mathRandom() * 2.0);
			p->life = 35;
			p->temperature = 0.0;
			p->plasma = FALSE;
			p->velocity.x = pos.x * .025;
			p->velocity.y = pos.y * .025;
			
			index = index + 1 < PARTICLE_LIMIT ? index + 1 : 0;
		}
	}
	
	max = 8;
	
	for (i=0; i<max; i++) {
		
		// get reference to particle
		Particle* p = &collection[index];
		
		pos = getRandomPositionAtDistanceFromCenter(radius);
		p->position.x = pos.x + self.position.x;
		p->position.y = pos.y + self.position.y;
		
		// get random position within radius of asteroid
		p->radius = fmax(1.25,mathRandom() * 2.25);
		p->life = 25;
		p->temperature = 0.0;
		p->plasma = FALSE;
		p->velocity.x = pos.x * .01;
		p->velocity.y = pos.y * .01;
		
		index = index + 1 < PARTICLE_LIMIT ? index + 1 : 0;
	}
	
    return index;
}


@end
