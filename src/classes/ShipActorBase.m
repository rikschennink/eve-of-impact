//
//  ShipActorBase.m
//  Eve of Impact
//
//  Created by Rik Schennink on 11/28/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "LinearMoveBehaviour.h"
#import "ShipActorBase.h"
#import "Easing.h"
#import "Explodable.h"
#import "MissileActor.h"
#import "ShuttleStateBehaviour.h"
#import "Particle.h"

@implementation ShipActorBase

@synthesize passengers,target,origin;

-(id)initWithOrigin:(Vector)myOrigin target:(Vector)myTarget andPassengers:(uint)amount {
	
	ShuttleStateBehaviour<StateBehaviour>* stateBehaviour = (ShuttleStateBehaviour<StateBehaviour>*)[[ShuttleStateBehaviour alloc] init];
	LinearMoveBehaviour<MoveBehaviour>* moveBehaviour = [[LinearMoveBehaviour alloc] init];
	
	if ((self = [super initWithRadius:10 state:stateBehaviour movement:moveBehaviour])) {
		
		origin.x = myOrigin.x;
		origin.y = myOrigin.y;
		
		self->position.x = origin.x;
		self->position.y = origin.y;
		
		thrust = VectorMake(myOrigin.x * .01,myOrigin.y * .01);
		target = VectorMake(myTarget.x,myTarget.y);
		
		passengers = amount;
		
	}
	
	return self;
}

-(void)act {
	
	// lift of 
	if (self.state.life <= 30) {
		
		float progress = 1.0 - easeLinear(self.state.life, 30);
		Vector t;
		t.x = thrust.x * progress;
		t.y = thrust.y * progress;
		self->velocity.x += t.x;
		self->velocity.y += t.y;
		
	}
	// turn towards target
	else {
		
		Vector d;
		d.x = target.x - self.position.x;
		d.y = target.y - self.position.y;
		
		vectorNormalize(&d);
		vectorLimit(&d, .1); // limit steering impact
		
		self->velocity.x += d.x;
		self->velocity.y += d.y;
		
	}
	
	// limit speed
	vectorLimit(&self->velocity, maxSpeed);
	
	// call super act method
	[super act];
}

-(BOOL)canCollideWith:(ActorBase*)actor {
	return false;
}

-(void)collideWith:(ActorBase *)actor afterTime:(float)time {
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ShuttleExplosion" object:self];
	
	[self kill];
	
}

-(uint)addEmissionsTo:(Particle*)collection atIndex:(uint)index {
	return index;
}

-(void)push:(Vector)direction {
	
	// set new target away from pusher
	Vector newTarget;
	newTarget.x = self.position.x - direction.x;
	newTarget.y = self.position.y - direction.y;
	vectorNormalize(&newTarget);
	
	target = vectorMultiplyWithAmount(&newTarget, SHUTTLE_TARGET_DISTANCE);
	target.x += self.position.x;
	target.y += self.position.y;
}

@end
