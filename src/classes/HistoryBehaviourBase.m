//
//  HistoryManagerBase.m
//  Eve of Impact
//
//  Created by Rik Schennink on 7/7/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "HistoryBehaviourBase.h"
#import "ActorBase.h"
#import "Vector.h"

@implementation HistoryBehaviourBase

@synthesize max;
@synthesize count;
@synthesize index;

-(float*)coordinates {
	return coordinates;
}

-(id)initWithMaxCoordinates:(uint)maximum {
	
	if (self = [super init]) {
		
		coordinates = malloc(sizeof(float) * maximum);
		
		index = 0;
		count = 0;
		max = maximum % 2 == 1 ? maximum + 1 : maximum;
		
	}
	
	return self;
	
}

-(void)addCoordinate:(Vector)coordinate {
	
	coordinates[index] = coordinate.x;
	coordinates[index+1] = coordinate.y;
	
	count = count < max ? count + 2 : max;
	index = index + 2 < max ? index + 2 : 0;

}

-(void)update:(ActorBase *)actor {
	
	Vector coordinate = VectorMake(actor.position.x,actor.position.y);
	
	[self addCoordinate:coordinate];
	
}

-(void)receive:(uint)message {
	
}

-(void)dealloc {
	
	free(coordinates);
	
	[super dealloc];
}


@end
