//
//  Score.m
//  Eve of Impact
//
//  Created by Rik Schennink on 2/26/11.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "Score.h"
#import "Prefs.h"
#import "Vector.h"
#import "Easing.h"
#import "MathAdditional.h"

@implementation Score

@synthesize points,counter,step;

-(id)init {
	
	if ((self = [super init])) {
		[self reset];
		lastExplosionPosition = VectorMake(0, 0);
	}
	
	return self;
}

-(void)reset {
	step = SCORE_INITIAL_SPEED;
	points = 0;
	counter = 0;
	stack = 0.0;
}

-(void)update {
	
	// increase step
	step = fmin(SCORE_INCREASE_SPEED,step + SCORE_RECOVERY_SPEED);
	
	// update points by increasing with point step
	points += step;
		
	// panic stack recovery
	if (stack > 0.0) {
		stack -= SCORE_STACK_RECOVERY_SPEED;
		if (stack<0.0) {
			stack=0.0;
			lastExplosionPosition.x = 0.0;
			lastExplosionPosition.y = 0.0;
		}
	}
	
	
	// make counter follow points
	if (counter > points) {
		counter = counter - SCORE_FALLBACK_SPEED < points ? points : counter - SCORE_FALLBACK_SPEED;
	}
	else {
		counter = points;
	}
}

-(void)slow:(Vector)newExplosionPosition {
	
	float distance = getDistanceSquaredBetween(lastExplosionPosition.x, lastExplosionPosition.y, newExplosionPosition.x, newExplosionPosition.y);
	if (distance < SCORE_SPAM_DISTANCE) { 

		// get amount of score penalty by distance to previous explosion location
		float amount = 1.0 - easeLinear(distance,SCORE_SPAM_DISTANCE);
		
		// increase penalty stack
		stack += SCORE_SLOW_PENALTY * amount;
	}
	
	// default increase stack
	stack = fmin(stack + SCORE_SLOW_PENALTY,SCORE_STACK_MAX);
	
	// slow down score increase step
	step = fmax(SCORE_INCREASE_SPEED_MIN,step - stack);
	
	// store explosion position
	lastExplosionPosition.x = newExplosionPosition.x;
	lastExplosionPosition.y = newExplosionPosition.y;
}

-(void)decrease:(float)amount {
	points = points - amount > 0 ? points - amount : 0;
}



@end
