//
//  ActorBase.m
//  Eve of Impact
//
//  Created by Rik Schennink on 2/12/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "ActorBase.h"
#import "Vector.h"

@implementation ActorBase

@synthesize uid,position,velocity,radius,mass,history,movement,state,dead;

-(id)init {
	
	return [self initWithRadius:0 
						  state:(StateBehaviourBase<StateBehaviour>*)[[StateBehaviourBase alloc] init]
					   movement:[[MoveBehaviourBase alloc] init]];
}

-(id)initWithRadius:(float)r 
			  state:(StateBehaviourBase<StateBehaviour>*)s
		   movement:(MoveBehaviourBase<Behaviour>*)m {
	
	self = [super init];
	
	if (self) {
		
		uid = getUniqueId();
		
		position = VectorMake(0,0);
		velocity = VectorMake(0,0);	
		
		radius = r;
		state = s;
		movement = m;
		mass = 0.0;
		history = nil;
		
	}
	
	return self;
	
}

-(void)setHistoryKeeper:(HistoryBehaviourBase<HistoryBehaviour>*)behaviour {
	history = behaviour;
}

-(void)act {
	if (state != nil) {
		[state update:self];
	}
	if (movement != nil) {
		[movement update:self];
	}
	if (history != nil) {
		[history update:self];
	}
}

-(void)kill {
	dead = YES;
}

-(BOOL)inLimbo {
	return dead;
}

-(void)flush {
	[self kill];
}

-(void)send:(uint)message {
	if (state != nil) {
		[state receive:message];
	}
	if (movement) {
		[movement receive:message];
	}
}

-(void)dealloc {
	
	if (state != nil) {
		[state release];
	}
	
	if (movement != nil) {
		[movement release];
	}
	
	if (history != nil) {
		[history release];
	}
	
	[super dealloc];
	
}

@end
