//
//  ScoreCounter.m
//  Eve of Impact
//
//  Created by Rik Schennink on 12/11/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "ScoreCounter.h"
#import "Prefs.h"
#import "ApplicationModel.h"
#import "RenderEngine.h"
#import "Prefs.h"
#import "Score.h"
#import "Easing.h"

@implementation ScoreCounter

-(id)initWithModel:(ApplicationModel*)applicationModel {
	
	self = [super init];
	
	if (self) {
		
		model = applicationModel;
		
		touchable = NO;
		
		CGSize letterbox = CGSizeMake(24, 32);
		uint offset = 8;
		
		for (uint i=0; i<10; i++) {
			digits[i] =  UVMapMake(offset + (i * letterbox.width), 104, letterbox.width, letterbox.height);
		}
		
		dot = QuadTemplateMake(0, 0, 0, 16.0 * scale, letterbox.height * scale, COLOR_INTERFACE,  UVMapMake(276, 8, 16.0, letterbox.height));
		
		digit = QuadTemplateMakeEmpty();
		digit.color = COLOR_INTERFACE;
		digit.width = letterbox.width * scale;
		digit.height = letterbox.height * scale;
		
		for (uint i=0; i<3;i++) {
			panic[i] = UVMapMake(352, 408 + (i * 24), 32, 24);
		}
		
		row = QuadTemplateMake(0, 0, 0, 32*scale, 24*scale, COLOR_INTERFACE, panic[0]);
	}
	
	return self;
}

-(void)setState:(uint)state withTicks:(uint)modelTicks {
	
	if (state == STATE_PLAYING || state == STATE_MENU_PAUSE) {
		if (!enabled) {
			self.enabled = YES;
		}
	}
	else {
		if (enabled) {
			self.enabled = NO;
		}
		
	}
}

-(void)draw:(CGRect)frame {
	
	if (!self.shouldDraw) {
		return;
	}
	
	//[super draw:frame];
	
	uint points = model.score.counter;
	uint digitCount = (points==0) ? 1 : log10(points) + 1;
	uint dotCount = (digitCount-1)/3;
	
	// set position
	float initialOffset = (18.0 + (digitCount * 7.0) + (dotCount * 4.0)) * scale;
	self.position = CGPointMake(initialOffset, (-frame.size.height * .5) + (18.0 * scale));
	
	// score
	uint lengthCounter=0;
	uint pointsDigit;
	float offset = 14.0 * scale;
	
	
	digit.color = COLOR_INTERFACE;
	digit.color.a *= flicker;
	dot.color = digit.color;
	
	if (points > 0) {
		while (points) {
			
			pointsDigit = points % 10;
			digit.x = self.position.x - offset - digit.width;
			digit.y = self.position.y;
			digit.uv = digits[pointsDigit];
			[[RenderEngine singleton] addQuad:&digit];
			points*=.1;
			offset+=digit.width - (10.0 * scale);
			
			if (points) {
				lengthCounter++;
				if (lengthCounter%3==0) {
					dot.x = self.position.x - offset - dot.width;
					dot.y = self.position.y;
					[[RenderEngine singleton] addQuad:&dot];
					offset+=dot.width - (10.0 * scale);
				}
			}
		}
	}
	else {
		// render zero
		digit.x = self.position.x - offset - digit.width;
		digit.y = self.position.y;
		digit.uv = digits[0];
		[[RenderEngine singleton] addQuad:&digit];
		
		offset += digit.width - (10.0 * scale);
	}
	
	float panicLevel = easeLinear(model.score.step,SCORE_INCREASE_SPEED);
	float opacity = 1.0;
	uint level;
	if (panicLevel < .2) {
		level = 0;
		opacity = mathRandom();
	}
	else if (panicLevel < .4) {
		level = 0;
	}
	else if (panicLevel < .915) {
		level = 1;
	}
	else {
		level = 2;
	}
	
	row.x = self.position.x - offset - (40.0 * scale);
	row.y = digit.y + (3.5 * scale);
	row.uv = panic[2];
	row.color.a = .25 * flicker;
	[[RenderEngine singleton] addQuad:&row];
	
	row.color = digit.color;
	row.color.a *= opacity;
	row.uv = panic[level]; // level between 0 and 2;
	[[RenderEngine singleton] addQuad:&row];
	
}

@end











