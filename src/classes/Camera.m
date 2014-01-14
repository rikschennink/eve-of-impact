//
//  cameraView.m
//  Eve of Impact
//
//  Created by Rik Schennink on 3/9/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "Camera.h"
#import "Prefs.h"
#import "MathAdditional.h"
#import "Vector.h"
#import "Easing.h"

@implementation Camera

@synthesize offset;
@synthesize velocity;
@synthesize rotation;

@synthesize dragging;

@synthesize dragVelocity;
@synthesize dragPosition;
@synthesize dragDistance;

@synthesize mergedOffset;


-(id)init {
	
	if ((self = [super init])) {
		
		ticker = 0;
		
		rangePull = IS_IPAD ? .75 : .2;
		rangeMultiplier = IS_IPAD ? 1.5 : 1.0;
		
		// offset when user starts transforms
		initOffset = VectorMake(0, 0);
		initOrientation = 0.0;
		
		// end transforms are initially the same as start transforms
		offset = VectorMake(0,0);
		rotation = 0.0;
		previousOffset.x = 0;
		previousOffset.y = 0;
		velocity.x = 0;
		velocity.y = 0;
		orientation = 0.0;
		
		// set seeking stuff
		seeking = NO;
		seekTreshold = 1.0;
		
		// dragging
		dragging = NO;
		dragPosition = VectorMake(0, 0);
		dragVelocity = VectorMake(0, 0);
		frictionApplied = YES;
		
		// history
		dragHistoryMax = 10;
		dragHistoryIndex = 0;
		dragHistoryCount = 0;
		dragDistance = 0;
		
		// wobble modifier init
		wobbleOffset = VectorMake(0,0);
		
		// shake modifier init
		shakeTarget = VectorMake(0,0);
		shakeVelocity = VectorMake(0,0);
		shakeOffset = VectorMake(0,0);
		shakeDuration = 0;
		shakeCountdown = 0;
		shakeTickerStamp = 0;
		
		// merged
		mergedOffset = VectorMake(0,0);
		
		limited = NO;
	}
	
	return self;
}

-(void)updateShake {
	
	if (shakeDuration > 0) {
		shakeDuration--;
	}
	else {
		return;
	}
	
	shakeVelocity.x += (shakeTarget.x - shakeOffset.x) * .01;
	shakeVelocity.y += (shakeTarget.y - shakeOffset.y) * .01;
	
	shakeOffset.x += shakeVelocity.x;
	shakeOffset.y += shakeVelocity.y;
	
	shakeVelocity.x *= .95;
	shakeVelocity.y *= .95;
	
	if (shakeCountdown>0) {
		shakeCountdown--;
	}
	else {
		shakeTarget = VectorMakeRandom(5.0);
	}
		
}

-(void)shake {
	
	if (ticker - shakeTickerStamp < 20) {
		
		shakeTarget.x += 3 * (-.5 + mathRandom());
		shakeTarget.y += 3 * (-.5 + mathRandom());
		
		shakeDuration += 5;
		
	}
	else {
		
		shakeTickerStamp = ticker;
		shakeTarget = VectorMakeRandom(4.0);
		
		shakeCountdown = 10 + mathRandom() * 10;
		shakeDuration += 30;
	}
}

-(void)updateRotation {
	rotation = sinHash(ticker) * 2.0;
}

-(void)updateWobble {
	
	wobbleOffset.x = CAMERA_WOBBLE_MAX_H * sin(((float)ticker) * CAMERA_WOBBLE_SPEED);
	wobbleOffset.y = CAMERA_WOBBLE_MAX_V * cos(((float)ticker) * CAMERA_WOBBLE_SPEED);
		
}

+(CGPoint)locationToCameraSpace:(CGPoint)location {
	return CGPointMake(location.x - 160, -location.y + 240);
}



-(void)startDrag:(Vector)location {
	
	// when dragging range is limited
	limited = YES;
	
	// halt any seeking
	seeking = NO;
	
	// dragging started, collect positions
	dragging = YES;
	
	// set initial offset
	initOffset.x = location.x - offset.x;
	initOffset.y = location.y - offset.y;
	
	// reset seek
	[self resetSeek];
	
	// drag
	[self drag:location];
}

-(void)drag:(Vector)location {
	
	dragPosition.x = location.x;
	dragPosition.y = location.y;
	
	offset.x = dragPosition.x - initOffset.x;
	offset.y = dragPosition.y - initOffset.y;
	
	[self calculateActualPosition];
}

-(void)stopDrag {
	
	// dragging stopped, stop collecting drag positions
	dragging = NO;
}



-(void)resetSeek {
	
	seekVelocity.x = 0;
	seekVelocity.y = 0;
	
}

-(void)moveTo:(Vector)target withSpeed:(float)speed notifyCompletionWith:(NSString*)notification notificationTreshold:(float)treshold {
	
	// set seeking specs
	seekSpeed = speed;
	seekDoneNotification = notification;
	seekTarget.x = target.x;
	seekTarget.y = target.y;
	seekTreshold = treshold;
	
	
	// check if movement is required
	Vector desired = vectorSubtractFromVector(&seekTarget, &offset);
	float d = vectorGetMagnitude(&desired);
	
	if (d > .25) {
		
		// release camera range
		limited = NO;
		
		// enable seeking
		seeking = YES;
	}
	
}

-(void)moveTo:(Vector)target withSpeed:(float)speed notifyCompletionWith:(NSString*)notification {
	[self moveTo:target withSpeed:3.0 notifyCompletionWith:notification notificationTreshold:1.0];
}

-(void)moveTo:(Vector)target notifyCompletionWith:(NSString*)notification {
	[self moveTo:target withSpeed:3.0 notifyCompletionWith:notification notificationTreshold:1.0];
}

-(void)moveTo:(Vector)target withSpeed:(float)speed {
	[self moveTo:target withSpeed:speed notifyCompletionWith:nil notificationTreshold:1.0];
}

-(void)moveTo:(Vector)target {
	[self moveTo:target withSpeed:3.0 notifyCompletionWith:nil notificationTreshold:1.0];
}

-(void)moveToCenter {
	[self moveTo:VectorMake(0,0) withSpeed:3.0 notifyCompletionWith:nil notificationTreshold:1.0];
}

-(void)update {
		
	ticker++;
	
	// do rest of stuff
	if (seeking) {
		
		Vector steer;
		Vector desired = vectorSubtractFromVector(&seekTarget, &offset);

		float m = vectorGetMagnitude(&seekVelocity); 
		float d = vectorGetMagnitude(&desired);
		
		//NSLog(@"d: %f, m: %f",d,m);
		
		if (d < seekTreshold && m < .2) {
			
			seekVelocity.x = 0;
			seekVelocity.y = 0;
			seeking = NO;
			seekTreshold = 1.0;
			
			if (seekDoneNotification != nil) {
				[[NSNotificationCenter defaultCenter] postNotificationName:seekDoneNotification object:self];
				seekDoneNotification = nil;
			}
		}
		else {
			
			vectorNormalize(&desired);
			
			if (d < 150.0) {
				desired = vectorMultiplyWithAmount(&desired,seekSpeed * (d / 150.0));
			}
			else {
				desired.x *= seekSpeed;
				desired.y *= seekSpeed;
			}
			
			steer.x = desired.x - seekVelocity.x;
			steer.y = desired.y - seekVelocity.y;
			
			vectorLimit(&steer, .05);
			
			seekVelocity.x += steer.x;
			seekVelocity.y += steer.y;
			
			offset.x += seekVelocity.x;
			offset.y += seekVelocity.y;
		}
	}
	else {
		
		if (dragging) {
			
			// update camera offset
			offset.x = dragPosition.x - initOffset.x;
			offset.y = dragPosition.y - initOffset.y;
			
			dragHistory[dragHistoryIndex] = offset.x;
			dragHistory[dragHistoryIndex+1] = offset.y;
			
			dragHistoryCount = dragHistoryCount < dragHistoryMax	 ? dragHistoryCount + 2 : dragHistoryMax;
			dragHistoryIndex = dragHistoryIndex < dragHistoryMax - 2 ? dragHistoryIndex + 2 : 0;
			
		}
		else if (dragHistoryCount > 1) {
			
			vectorReset(&dragVelocity);
			
			// set index amount				
			uint max = dragHistoryCount == dragHistoryIndex ? dragHistoryCount : dragHistoryMax;
			uint count = 0;
			uint index = dragHistoryIndex <= 0 ? dragHistoryMax : dragHistoryIndex;
			float px,py,x,y;
			
			px = dragHistory[index-2];
			py = dragHistory[index-1];
			
			count+=2;
			index-=2;
			
			while (count < max) {
				
				if (index <= 0) {
					index = dragHistoryMax;
				}
				
				x = dragHistory[index-2];
				y = dragHistory[index-1];
				
				count+=2;
				index-=2;
				
				// do your thing
				dragVelocity.x += x - px;
				dragVelocity.y += y - py;
				
				px = x;
				py = y;
			}
			
			// calculate average
			dragVelocity = vectorDivideByAmount(&dragVelocity, dragHistoryCount);
			
			// reset history
			dragHistoryIndex = 0;
			dragHistoryCount = 0;
			
			// reset friction switch
			frictionApplied = NO;
			
			// slow down
			[self applyFriction];
		}
		else {
			
			// slow down
			[self applyFriction];
		}
	}
	
	[self calculateActualPosition];
	
}

-(void)applyFriction {
	
	if (!frictionApplied) {
		
		float dragMagnitude = vectorGetMagnitude(&dragVelocity);
		
		if (dragMagnitude>.05) {
			
			dragVelocity = vectorDivideByAmount(&dragVelocity, 1.15);
			
			offset = vectorSubtractFromVector(&offset, &dragVelocity);
			
			dragDistance += dragMagnitude;
			
		}
		else {
			frictionApplied = YES;
		}
	}
	else {
		vectorReset(&dragVelocity);
		
		// snap to round pixels, to prevent blurry scene
		vectorRound(&offset);
	}
}

-(void)calculateActualPosition {
	
	// update wobble
	[self updateWobble];
	
	// update rotation
	[self updateRotation];
	
	// update shake
	[self updateShake];
	
	if (offset.x * offset.x + offset.y * offset.y > (CAMERA_RANGE_SQUARED * rangeMultiplier * rangeMultiplier) && limited) {
		
		// get angle to center
		float angle = atan2(offset.x,offset.y);
		float pull = dragging ? rangePull : .1;
		
		// get edge coordinate
		Vector edge = VectorMake(CAMERA_RANGE * sinf(angle) * rangeMultiplier, CAMERA_RANGE * cosf(angle) * rangeMultiplier);
		
		// set new offset with range limit and add lag effect
		offset.x = offset.x - ((offset.x - edge.x) * pull);
		offset.y = offset.y - ((offset.y - edge.y) * pull);
	}
	
	// set actual offset
	mergedOffset.x = offset.x + wobbleOffset.x + shakeOffset.x;
	mergedOffset.y = offset.y + wobbleOffset.y + shakeOffset.y;
	
	if (!dragging) {
		velocity.x = mergedOffset.x - previousOffset.x;
		velocity.y = mergedOffset.y - previousOffset.y;
	}
	else {
		velocity.x = 0;
		velocity.y = 0;
	}
	
	// store as previous offset
	previousOffset.x = mergedOffset.x;
	previousOffset.y = mergedOffset.y;
}

-(void)dealloc {
	
	[super dealloc];
}

@end
