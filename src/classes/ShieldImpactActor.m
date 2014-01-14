//
//  MoonImpact.m
//  Eve of Impact
//
//  Created by Rik Schennink on 4/11/11.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "ShieldImpactActor.h"


@implementation ShieldImpactActor

@synthesize relatedActorUID;

-(id)initWithMass:(float)m andRelatedActorUID:(uint)relatedUID {
	
	self = [self initWithMass:m andLifespan:100];
	
	if (self) {
		relatedActorUID = relatedUID;
	}
	
	return self;
	
}

@end
