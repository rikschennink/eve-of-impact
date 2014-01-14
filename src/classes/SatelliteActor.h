//
//  SatelliteActor.h
//  Eve of Impact
//
//  Created by Rik Schennink on 2/15/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "ActorBase.h"

@interface SatelliteActor : ActorBase {
	
	NSTimeInterval lastFiredMissile;
	float recoil;
}

@property (readonly) float recoil;
@property (readonly) NSTimeInterval lastFiredMissile;

-(id)initWithOffset:(float)offset;

-(void)fireMissile;
-(void)increaseRecoil;
-(void)resetRecoil;

@end
