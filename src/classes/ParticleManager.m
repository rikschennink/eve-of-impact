//
//  ParticleManager.m
//  Eve of Impact
//
//  Created by Rik Schennink on 7/8/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "ParticleManager.h"
#import "Vector.h"
#import "ActorBase.h"

@implementation ParticleManager

-(Particle*)particles {
	return particles;
}

-(id)init {
	
	if (self = [super init]) {
		
		index = 0;
		emitters = [[NSMutableArray alloc] init];
		particles = malloc(sizeof(Particle) * PARTICLE_LIMIT);
		
		// reset
		[self clear];
	}
	
	return self;
	
}

-(void)bindAsEmitter:(ActorBase<Emitter>*)actor {
	[emitters addObject:actor];
}

-(void)update {
	
	// particle pointer
	Particle *p;
	uint i;
	
	// loop through emitters
	for (ActorBase<Emitter>* emitter in [emitters reverseObjectEnumerator]) {
		
		// add particles for this emitter and have the emitter up the index
		index = [emitter addEmissionsTo:particles atIndex:index];
		
		// check for removal
		if ([emitter inLimbo]) {
			[emitters removeObject:emitter];
		}
	}
	
	// update particle position
	for (i=0; i<PARTICLE_LIMIT; i++) {
		
		p = &particles[i];
		
		if (p->life>0) {
			
			p->position.x += p->velocity.x;
			p->position.y += p->velocity.y;
			p->temperature = MAX(p->temperature-.05,0.0);
			
			p->life--;
		}
	}
}

-(void)clear {
	index = 0;
	for (uint i=0; i<PARTICLE_LIMIT; i++) {
		particles[i].life = 0;
	}
	
	[emitters removeAllObjects];
}

-(void)dealloc {
	
	free(particles);
	[emitters release];
	
	[super dealloc];
}

@end