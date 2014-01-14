//
//  LightManager.m
//  Eve of Impact
//
//  Created by Rik Schennink on 3/19/11.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "PulseManager.h"
#import "ActorBase.h"
#import "Pulse.h"

@implementation PulseManager


-(id)initWithAmount:(uint)amount {
	
	if (self = [super init]) {
		
		pulses = [[NSMutableArray alloc] init];
		count = amount;
		
		for (uint i=0; i<count; i++) {
			Pulse* light = [[Pulse alloc]initWithPeriod:RangeMake(4, 24)];
			[pulses addObject:light];
		}
		
	}
	
	return self;
}

-(void)update {
	
	for (Pulse* pulse in pulses) {
		[pulse update];
	}
	
}

-(Pulse*)getPulseByActor:(ActorBase*)actor {
	
	//uint index = round(actor.uid%count);
	
	//NSLog(@"%i: %i",actor.uid,actor.uid%10);
	
	return [pulses objectAtIndex:0];
}


@end
