//
//  ImpactActor.h
//  Eve of Impact
//
//  Created by Rik Schennink on 2/17/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import	"ActorBase.h"

@interface ImpactActor : ActorBase {
	
	float angle;
	float distance;
	//uint type;
	
}

@property (assign) float angle;
@property (assign) float distance;
//@property (readonly) uint type;

//-(id)initWithMass:(float)m andType:(uint)t;


-(id)initWithMass:(float)m;
-(id)initWithMass:(float)m andLifespan:(uint)s;

@end
