//
//  OptimizedHistoryManager.m
//  Eve of Impact
//
//  Created by Rik Schennink on 7/7/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "OptimizedHistoryBehaviour.h"
#import "ActorBase.h"

@implementation OptimizedHistoryBehaviour

-(id)initWithMaxCoordinates:(uint)maximum andMinimumCoordinateDistanceSquared:(float)distance {
	
	if (self = [super initWithMaxCoordinates:maximum]) {
		minimumCoordinateDistanceSquared = distance;
	}
	
	return self;
	
}

-(void)update:(ActorBase *)actor {
	
	Vector coordinate = VectorMake(actor.position.x,actor.position.y);
	
	if (count == 0) {
		[super addCoordinate:coordinate];
		return;
	}
	
	Vector previous = VectorMake(coordinates[index == 0 ? max - 2 : index - 2], 
								 coordinates[index == 0 ? max - 1 : index - 1]);
	
	if (getDistanceSquaredBetween(coordinate.x,
								  coordinate.y,
								  previous.x,
								  previous.y) > minimumCoordinateDistanceSquared) {
		
		[super addCoordinate:coordinate];
	}
}

@end