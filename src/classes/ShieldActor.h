//
//  ShieldActor.h
//  Eve of Impact
//
//  Created by Rik Schennink on 10/28/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "ActorBase.h"
#import "Collidable.h"
#import "Impactable.h"
#import "Emitter.h"

@interface ShieldActor : ActorBase <Collidable,Impactable,Emitter> {
	
	NSMutableArray* impacts;
	float energy;
	float power;
	BOOL enabled;
	BOOL overloading;
}

@property (readonly) float energy;
@property (readonly) float power;
@property (readonly) BOOL enabled;
@property (nonatomic,retain,readonly) NSMutableArray* impacts;

-(void)charge:(float)amount;
-(void)drain:(float)amount;
-(void)blow;
-(void)overloadStart;
-(void)overload;
-(void)overloadCancel;
-(BOOL)isOverloading;
-(void)disable;

-(float)getEnergyToDeflectObjectWith:(float)objectMass;
-(BOOL)willDeflectObjectWith:(float)objectMass;
	
@end
