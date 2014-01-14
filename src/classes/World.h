//
//  World.h
//  Eve of Impact
//
//  Created by Rik Schennink on 2/12/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActorBase.h"

@class PlanetActor;
@class ShieldActor;

@interface World : NSObject {
	
	NSMutableArray* actorTransfers;
	NSMutableArray* actorQueue;
	
	NSMutableArray* actors;
	NSMutableArray* pullables;
	NSMutableArray* asteroids;
	NSMutableArray* pullers;
	NSMutableArray* collidables;
	NSMutableArray* pushers;
	NSMutableArray* impacts;
	NSMutableArray* pushables;
	
	NSMutableArray* actorCollections;
	
	Vector worldCenter;
	Vector gravityForce;
	Vector gravityTotalForce;
	Vector gravityProjection;
	
}

-(void)addActorToQueue:(ActorBase*)actor;
-(void)transferActor:(ActorBase*)actor;

-(void)manageActors;

-(void)transfer;
-(void)act;
-(void)update;
-(void)clean;
-(void)filter;

-(void)handleCollisions;

-(void)applyPhysics;
-(void)flush;

@property (nonatomic,retain) NSMutableArray* actors;
@property (nonatomic,retain) NSMutableArray* asteroids;
@property (nonatomic,retain) NSMutableArray* impacts;
@property (nonatomic,retain) NSMutableArray* pushers;

@end
