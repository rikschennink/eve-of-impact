//
//  cameraView.h
//  Eve of Impact
//
//  Created by Rik Schennink on 3/9/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import "Vector.h"
#import "Prefs.h"
#import "Pulse.h"



@interface Camera : NSObject {
	
	uint ticker;
	
	// offset when user starts transforms
	Vector initOffset;
	float initOrientation;
	
	// transforms
	Vector velocity;
	Vector previousOffset;
	Vector offset;
	float rotation;
	UIDeviceOrientation orientation;
	
	// targets
	BOOL seeking;
	NSTimeInterval seekStart;
	NSTimeInterval seekEnd;
	NSUInteger seekDuration;
	Vector seekVelocity;
	Vector seekTarget;
	float seekSpeed;
	NSString* seekDoneNotification;
	uint seekModifierCounter;
	float seekTreshold;
	
	//Vector locationTarget;
	//BOOL locationTargetSet;
	
	
	// dragging related
	BOOL dragging;
	Vector dragPosition;
	Vector dragVelocity;
	
	// total drag distance
	float dragDistance;
	
	BOOL frictionApplied;
	float dragHistory[10];
	uint dragHistoryMax;
	uint dragHistoryIndex;
	uint dragHistoryCount;
	
	// effect related
	Vector wobbleOffset;
	
	
	Vector shakeVelocity;
	Vector shakeOffset;
	Vector shakeTarget;
	uint shakeCountdown;
	uint shakeTickerStamp;
	uint shakeDuration;
	uint shakeTicker;
	
	float shakeIntensity;
	float shakeStorage;
	float shakeWave;
	
	BOOL limited;
	
	// merged offset
	Vector mergedOffset;
	
	float rangePull;
	float rangeMultiplier;
	
	
}

@property (readonly) Vector velocity;
@property (readonly) Vector mergedOffset;

@property Vector offset;
@property (readonly) float rotation;
//@property (assign) UIDeviceOrientation orientation;

@property Vector dragVelocity;
@property Vector dragPosition;
@property (readonly) float dragDistance;
@property (readonly) BOOL dragging;


+(CGPoint)locationToCameraSpace:(CGPoint)location;

//-(void)setOrientation:(UIDeviceOrientation)deviceOrientation;

-(void)startDrag:(Vector)location;
-(void)drag:(Vector)location;
-(void)stopDrag;

-(void)moveTo:(Vector)target withSpeed:(float)speed notifyCompletionWith:(NSString*)notification notificationTreshold:(float)treshold;
-(void)moveTo:(Vector)target withSpeed:(float)speed notifyCompletionWith:(NSString*)notification;
-(void)moveTo:(Vector)target notifyCompletionWith:(NSString*)notification;
-(void)moveTo:(Vector)target withSpeed:(float)speed;
-(void)moveTo:(Vector)target;
-(void)moveToCenter;

-(void)resetSeek;

-(void)update;
-(void)applyFriction;
-(void)calculateActualPosition;

-(void)updateWobble;
-(void)updateShake;
-(void)shake;


@end
