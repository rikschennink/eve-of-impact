//
//  LaunchPlatform.m
//  Eve of Impact
//
//  Created by Rik Schennink on 6/25/11.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "LaunchPlatform.h"
#import "Prefs.h"
#import "Vector.h"
#import "ShipActor.h"

@implementation LaunchPlatform

@synthesize saved;

-(id)init {
	
    self = [super init];
	
    if (self) {
		[self reset];
    }
    
    return self;
}

-(void)reset {
	saved = 0;
	next = SHIP_CAPACITY_FIRST;
}

-(void)check:(uint)people {
	
	if (people - saved > next) {
		
		// launch current ship
		[self launchWith:next];
		
		// calculate next ship capacity
		next = round(randomBetween(1, 3)) * SHIP_CAPACITY_STEP;
		
	}
	
}

-(void)correct:(uint)people {
	saved -= people;
}

-(void)launchWith:(uint)passengers {
	if (passengers > 50) {
		
		saved += passengers;
		
		Vector origin,target;
		origin.x = randomBetween(-SHUTTLE_LAUNCH_RANGE, SHUTTLE_LAUNCH_RANGE);
		origin.y = randomBetween(-SHUTTLE_LAUNCH_RANGE, SHUTTLE_LAUNCH_RANGE);
		target = getRandomPositionAtDistanceFromCenter(SHUTTLE_TARGET_DISTANCE);
		
		ShipActor* ship = [[ShipActor alloc] initWithOrigin:origin target:target andPassengers:passengers];
				
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ShipLaunch" object:ship];
		
		[ship release];
	}
}

@end
