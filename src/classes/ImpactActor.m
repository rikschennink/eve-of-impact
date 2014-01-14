//
//  ImpactActor.m
//  Eve of Impact
//
//  Created by Rik Schennink on 2/17/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "ImpactActor.h"

@implementation ImpactActor


@synthesize angle,distance;


-(id)initWithMass:(float)m {
	
	if (self = [self initWithMass:m andLifespan:100]) {
		
		self.mass = m;
	}
	
	return self;
	
}

-(id)initWithMass:(float)m andLifespan:(uint)s {
	
	self = [super initWithRadius:m
		  state:(StateBehaviourBase<StateBehaviour>*)[[StateBehaviourBase alloc] initWithLifespan:s]
	   movement:[[MoveBehaviourBase alloc] init]];

	
	if (self) {
		
		self.mass = m;
	}
	
	return self;
}

@end
