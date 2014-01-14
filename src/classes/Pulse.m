//
//  Light.m
//  Eve of Impact
//
//  Created by Rik Schennink on 3/19/11.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "Pulse.h"
#import "MathAdditional.h"
#import "Range.h"

@implementation Pulse

@synthesize intensity;

-(id)initWithPeriod:(Range)p {
	
	if (self = [super init]) {
		
		intensity = 0.0;
		progress = 0;
		period = 1;
		timer = 0;
		amplitude = 1.0;
		
		periodRange = p;
	}
	
	return self;
}

-(void)update {
	
	if (timer==0) {
		period = randomBetween(periodRange.min, periodRange.max); // 14
		timer = randomBetween(15, 90);
		amplitude = randomBetween(.25, 1.00);
	}
	
	intensity = amplitude * ((sinHash(progress) + 1) * .5);
	
	progress += period;
	timer--;
}

@end
