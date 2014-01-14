//
//  SatelliteActor.m
//  Eve of Impact
//
//  Created by Rik Schennink on 2/15/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "SatelliteActor.h"
#import "RotationalMoveBehaviour.h"
#import "Prefs.h"

@implementation SatelliteActor

@synthesize lastFiredMissile;
@synthesize recoil;

-(id)initWithOffset:(float)offset {
	
	
	if ((self = [super initWithRadius:0.0
							   state:(StateBehaviourBase<StateBehaviour>*)[[StateBehaviourBase alloc] init]
							movement:[[RotationalMoveBehaviour alloc] initAndRotateAtDistance:SATELLITE_DISTANCE 
																				   withOffset:offset
																					  atSpeed:-0.1]])) {
		lastFiredMissile = [[NSDate date] timeIntervalSince1970];
	}
	return self;
	
}

-(void)act {
	
	[super act];
	
}

-(void)increaseRecoil {
	recoil = MIN(recoil + .1,1.0);
}

-(void)fireMissile {
	lastFiredMissile = [[NSDate date] timeIntervalSince1970];
}

-(void)resetRecoil {
	recoil = 0.0;
}

-(void)dealloc {
	
	[super dealloc];
}

-(void)flush {
	// do nothing
}

@end
