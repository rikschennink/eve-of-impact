//
//  MissileActor.h
//  Eve of Impact
//
//  Created by Rik Schennink on 4/6/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "ActorBase.h"
#import "Collidable.h"

@class HistoryManager;

@interface MissileActor : ActorBase <Collidable> {
	
	Vector target;
	
	uint payload;
	
	NSMutableArray* debree;
	
}

@property Vector target;
@property (assign) uint payload;
@property (nonatomic,retain,readonly) NSMutableArray* debree;

-(id)initWithOrigin:(Vector)myOrigin target:(Vector)myTarget speed:(float)speed andRecoil:(CGFloat)myRecoil;

-(void)readyToExplode;

@end
