//
//  DebreeActor.h
//  Eve of Impact
//
//  Created by Rik Schennink on 2/26/11.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "ActorBase.h"
#import "Collidable.h"
#import "Emitter.h"
#import "Pushable.h"
#import "Burnable.h"

@interface DebreeActor : ActorBase <Collidable,Emitter,Burnable,Pushable> {
	
	float temperature;
	Vector impulse;
	
}

@property (readonly) float temperature;

-(id)initWithTemperature:(float)amount andLifespan:(uint)span;

@end