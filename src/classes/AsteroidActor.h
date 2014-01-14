//
//  AsteroidActorModel.h
//  Eve of Impact
//
//  Created by Rik Schennink on 2/15/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "ActorBase.h"
#import "Collidable.h"
#import "Pullable.h"
#import "Destructable.h"
#import "Pushable.h"
#import "Emitter.h"
#import "Burnable.h"

@interface AsteroidActor : ActorBase <Pushable,Pullable,Collidable,Destructable,Emitter,Burnable> {
	
	float temperature;
	Vector impulse;
	float maxVelocity;
	float maxWeightVelocity;
}

@property (readonly) float temperature;

-(id)initWithMass:(float)r andMaxVelocity:(float)v;
-(id)initWithMass:(float)r temperature:(float)amount andMaxVelocity:(float)v;
-(void)shatter:(BOOL)vaporize;

@end
