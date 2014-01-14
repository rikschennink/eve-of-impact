//
//  LinearArcedMoveBehaviour.m
//  Eve of Impact
//
//  Created by Rik Schennink on 7/7/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "ArcedMoveBehaviour.h"
#import "ActorBase.h"
#import "Prefs.h"

@implementation ArcedMoveBehaviour

-(id)initWithStart:(Vector)myStartCoordinate 
				 end:(Vector)myEndCoordinate 
		anchorOffset:(float)myOffset
			andSpeed:(float)mySpeed {
	
	if (self = [super init]) {
		
		progress = 0.0;
		start = myStartCoordinate;
		end = myEndCoordinate;
		speed = mySpeed;
		
		Vector heading,anchorOffset;
		
		heading.x = end.x - start.x;
		heading.y = end.y - start.y;
		
		distance = vectorGetMagnitude(&heading);
		
		heading.x*=.5;
		heading.y*=.5;
		
		anchorOffset.x = start.x + heading.x;
		anchorOffset.y = start.y + heading.y;
		
		vectorNormalize(&heading);
		vectorRotateByDegrees(&heading, 90.0);
		
		heading.x*= myOffset;
		heading.y*= myOffset;
		
		anchor.x = anchorOffset.x + heading.x;
		anchor.y = anchorOffset.y + heading.y;
		
		startToAnchorHeading.x = anchor.x - start.x;
		startToAnchorHeading.y = anchor.y - start.y;
		
		anchorToEndHeading.x = end.x - anchor.x;
		anchorToEndHeading.y = end.y - anchor.y;
		
	}
	
	return self;	
}

-(void)update:(ActorBase*)actor {
	
	Vector currentPosition,toAnchorPoint,toDestinationPoint,bezier;
	
	progress += (1.0 / distance) * speed;
	
	currentPosition.x = actor.position.x;
	currentPosition.y = actor.position.y;
	
	if (progress < 1.0) {
		
		toAnchorPoint.x = start.x + (startToAnchorHeading.x * progress);
		toAnchorPoint.y = start.y + (startToAnchorHeading.y * progress);
		
		toDestinationPoint.x = anchor.x + (anchorToEndHeading.x * progress);
		toDestinationPoint.y = anchor.y + (anchorToEndHeading.y * progress);
		
		bezier.x = toDestinationPoint.x - toAnchorPoint.x;
		bezier.y = toDestinationPoint.y - toAnchorPoint.y;
		
		actor->position.x = toAnchorPoint.x + (bezier.x * progress);
		actor->position.y = toAnchorPoint.y + (bezier.y * progress);
	}
	else {
		
		actor->position.x = end.x;
		actor->position.y = end.y;
	}
	
	actor->velocity.x = actor->position.x - currentPosition.x;
	actor->velocity.y = actor->position.y - currentPosition.y;
	
	[super update:actor];
}

-(void)receive:(uint)message {
	
}

@end
