//
//  Control.h
//  Eve of Impact
//
//  Created by Rik Schennink on 2/23/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Common.h"
#import "Vector.h"

@interface Control : NSObject {
	
	uint ticks;
	CGPoint position;
	CGSize size;
	Control* parent;
	NSMutableArray* children;
	Color color;
	float scale;
	
	NSString* touchEvent;
	BOOL touchOrigin;
	BOOL touchEnd;
	BOOL touchable;
	BOOL touching;
	
	BOOL enabled;
	
	float flicker;
	BOOL flickerReset;
	uint flickerDuration;
	uint flickerDelay;
}

-(BOOL)shouldDraw;

-(BOOL)enabled;
-(void)setEnabled:(BOOL)state;
-(void)disable;
-(void)enable;

-(void)tick;
-(void)draw:(CGRect)frame;
-(CGPoint)localToGlobal;
-(void)addChild:(Control*)control;

-(void)setState:(uint)state withTicks:(uint)modelTicks;

-(void)handleBeginTouch;
-(void)handleBeginTouchAnywhere;
-(void)handleEndTouch;
-(void)handleEndTouchAnywhere;
-(void)handleTouch;
-(void)resetTouchStates;

-(BOOL)onTouchesBeginAt:(Vector)location;
-(BOOL)onTouchesEndAt:(Vector)location;
-(BOOL)occupiesAreaContaining:(Vector)location;

-(void)setColor:(Color)c;

@property (assign) CGSize size;
@property (assign) CGPoint position;
@property (readonly) float flicker;
@property (readonly) uint ticks;

@property (assign) BOOL touchable;
@property (nonatomic,retain) NSString* touchEvent;
@property (nonatomic,retain) NSMutableArray* children;
@property (nonatomic,assign) Control* parent; // weak reference to parent

@end
