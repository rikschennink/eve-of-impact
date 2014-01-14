//
//  ParticleManager.h
//  Eve of Impact
//
//  Created by Rik Schennink on 7/8/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prefs.h"
#import "Particle.h"
#import "ActorBase.h"
#import "Emitter.h"

@interface ParticleManager : NSObject {
	
	Particle *particles;
	uint index;
	
	NSMutableArray* emitters;
}

@property (readonly) Particle* particles;

-(void)bindAsEmitter:(ActorBase<Emitter>*)emitter;

-(void)update;

-(void)clear;

@end
