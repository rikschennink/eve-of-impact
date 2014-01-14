//
//  Control.m
//  Eve of Impact
//
//  Created by Rik Schennink on 2/23/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "Control.h"
#import "Prefs.h"

@implementation Control

@synthesize position;
@synthesize size;
@synthesize parent;
@synthesize children;
@synthesize touchEvent;
@synthesize touchable;
@synthesize flicker;
@synthesize ticks;

-(id)init {
	
	if ((self = [super init])) {
		
		parent = nil;
		enabled = NO;
		children = [[NSMutableArray alloc]init];
		position = CGPointMake(0.0,0.0);
		size = CGSizeMake(0.0,0.0);
		color = COLOR_INTERFACE;
		scale = IS_IPAD ? 1.5 : 1.0;
		
		touchEvent = nil;
		touchOrigin = NO;
		touchEnd = NO;
		touchable = YES;
		
		ticks = 0;
		
		flicker = 0.0;
		flickerDuration = 0;
		flickerDelay = 0;
	}
	
	return self;
}

-(BOOL)shouldDraw {
	return enabled || flickerDuration > 0;
}

-(BOOL)enabled {
	return enabled;
}

-(void)setEnabled:(BOOL)state {
	
	// is disabled and will be enabled
	if (!enabled && state) {
		
		// starts invisible
		ticks = 0;
		flicker = 0.0;
		
		// long neon light flicker
		flickerDelay = randomBetween(0, 20);
		flickerDuration = randomBetween(8, 16);
		
	}
	
	// is enabled and will be disabled
	else if (enabled && !state) {
		
		// starts opaque
		flicker = 1.0;
		
		// short last flicker
		flickerDelay = randomBetween(0, 5);
		flickerDuration = randomBetween(4, 8);
		
	}
	
	// set new state
	enabled = state;
}

-(void)disable {
	enabled = NO;
	flickerDuration = 0;
	flickerDelay = 0;
}

-(void)enable {
	enabled = YES;
	flickerDuration = 0;
	flickerDelay = 0;
}

-(void)tick {
	
	for (Control* child in children) {
		[child tick];
	}
	
	// delay till start of flickering
	if (flickerDelay > 0) {
		flickerDelay--;
		return;
	}
	
	ticks++;
	
	// flickering
	if (flickerDuration > 0) {
		flickerDuration--;
		flicker = flickerDuration & 1 ? .15 : 1.0;
	}
	
	// no flickering
	else {
		flicker = 1.0;
	}
}

-(void)setState:(uint)state withTicks:(uint)modelTicks {
	for (Control* control in children) {
		[control setState:state withTicks:modelTicks];
	}
}

-(void)setAlert:(uint)alert {
	for (Control* control in children) {
		[control setAlert:alert];
	}
}

-(void)setColor:(Color)c {
	color = c;
}

-(void)addChild:(Control *)control {
	
	// set parent reference
	control.parent = self;
	
	// add as child
	[children addObject:control];
}

-(BOOL)onTouchesBeginAt:(Vector)location {
	
	if (!enabled) {
		return NO;
	}
	
	// reset touch state
	[self resetTouchStates];
	
	// pass through to childnodes
	BOOL childNodesTouched = NO;
	for (Control* control in children) {
		if ([control onTouchesBeginAt:location]) {
			childNodesTouched = YES;
		}
	}

	// check if location is in self
	if ([self occupiesAreaContaining:location]) {
		touchOrigin = YES;
		[self handleBeginTouch];
	}
	else {
		[self handleBeginTouchAnywhere];
	}
	
	// origin state;
	return touchOrigin || childNodesTouched;
}

-(BOOL)onTouchesEndAt:(Vector)location {
	
	if (!enabled) {
		return NO;
	}
	
	// pass through to childnodes and check if any childnodes were touched
	BOOL childNodesTouched = NO;
	for (Control* control in children) {
		childNodesTouched = [control onTouchesEndAt:location];
	}
	
	BOOL tempTouchEnd = NO;
	
	// check if location is in self
	if ([self occupiesAreaContaining:location]) {
		touchEnd = YES;
		tempTouchEnd = YES;
		
		if (touchOrigin && touchEnd) {
			[self handleTouch];
		}
		else {
			[self handleEndTouch];
		}
	}
	else {
		[self handleEndTouchAnywhere];
	}
	
	// reset touch state
	[self resetTouchStates];
	
	// return end state
	return tempTouchEnd;
}

-(void)resetTouchStates {
	touchOrigin = NO;
	touchEnd = NO;
}

-(BOOL)occupiesAreaContaining:(Vector)location {
	
	if (touchable) {
		
		// get global position of control
		CGPoint globalPosition = [self localToGlobal];
		
		// check if touchposition is within globalposition and size params
		return (
				(location.x <= globalPosition.x + size.width) && 
				(location.x >= globalPosition.x) && 
				(location.y <= globalPosition.y + size.height) && 
				(location.y >= globalPosition.y)  
				);
	}
	
	return NO;
}

-(void)handleBeginTouch {
	touching = YES;
}

-(void)handleBeginTouchAnywhere {
	touching = NO;
}

-(void)handleEndTouch {
	touching = NO;
}

-(void)handleEndTouchAnywhere {
	touching = NO;
}

-(void)handleTouch {
	
	touching = NO;
	
	// handle touch event
	if (touchEvent != nil) {
		[[NSNotificationCenter defaultCenter] postNotificationName:touchEvent object:nil];
	}
}

-(CGPoint)localToGlobal {
	
	CGPoint globalPosition = CGPointMake(self.position.x,self.position.y);
	
	Control* control = self;
	while ((control = control.parent)) {
		globalPosition.x += control.position.x;
		globalPosition.y += control.position.y;
	}
	
	return globalPosition;
}

-(void)draw:(CGRect)frame {
	
	for (Control* child in children) {
		[child draw:frame];
	}
	
}

-(void)dealloc {
	
	[children release];
	
	if (touchEvent) {
		[touchEvent release];
	}
	
	[super dealloc];
}

@end

