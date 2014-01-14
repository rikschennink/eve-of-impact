//
//  PlanetImpactActor.m
//  Eve of Impact
//
//  Created by Rik Schennink on 4/11/11.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "PlanetImpactActor.h"


@implementation PlanetImpactActor

-(id)initWithMass:(float)m {
	
	if (self = [super initWithMass:m andLifespan:1000]) {
		
		self.mass = m;
	}
	
	return self;
	
}

@end
