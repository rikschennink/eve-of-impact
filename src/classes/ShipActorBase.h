//
//  ShipActorBase.h
//  Eve of Impact
//
//  Created by Rik Schennink on 11/28/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "ActorBase.h"
#import "Collidable.h"
#import "Destructable.h"
#import "Pushable.h"
#import "Emitter.h"

@interface ShipActorBase : ActorBase <Pushable,Collidable,Destructable,Emitter> {
	
	Vector origin;
	Vector target;
	Vector thrust;
	uint passengers;
	float maxSpeed;
	
}

@property (readonly) Vector origin;
@property (readonly) Vector target;
@property (readonly) uint passengers;

-(id)initWithOrigin:(Vector)myOrigin target:(Vector)myTarget andPassengers:(uint)amount;

@end
