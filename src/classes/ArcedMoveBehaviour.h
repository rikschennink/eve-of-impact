//
//  LinearArcedMoveBehaviour.h
//  Eve of Impact
//
//  Created by Rik Schennink on 7/7/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MoveBehaviourBase.h"
#import "Vector.h"

@interface ArcedMoveBehaviour : MoveBehaviourBase {
	
	Vector start;
	Vector end;
	Vector anchor;
	Vector startToAnchorHeading;
	Vector anchorToEndHeading;
	
	float speed;
	float progress;
	float distance;
	
}

-(id)initWithStart:(Vector)myStartCoordinate 
			   end:(Vector)myEndCoordinate 
	  anchorOffset:(float)myOffset 
		  andSpeed:(float)mySpeed;

@end
