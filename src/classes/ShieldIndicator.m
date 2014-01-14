//
//  ShieldIndicator.m
//  Eve of Impact
//
//  Created by Rik Schennink on 2/22/11.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "ShieldIndicator.h"
#import "Prefs.h"
#import "ApplicationModel.h"
#import "RenderEngine.h"
#import "Prefs.h"
#import "ShieldActor.h"


@implementation ShieldIndicator

-(id)initWithModel:(ApplicationModel*)applicationModel {
	
	if (self = [super init]) {
		
		uint i =0;
		touchable = NO;
		model = applicationModel;
		scale = IS_IPAD ? 2.0 : 1.0;
		
		CGSize letterbox = CGSizeMake(16, 16);
		for (i=0; i<10; i++) {
			digits[i] =  UVMapMake(184 + i * letterbox.width, 192, letterbox.width, letterbox.height);
		}
		
		shieldIcon = QuadTemplateMake(0, 0, 0, 64.0 * scale, 16.0 * scale, COLOR_INTERFACE, UVMapMake(232, 320, 64, 16));
		
		dot = QuadTemplateMake(0, 0, 0, letterbox.width * scale, letterbox.height * scale, COLOR_INTERFACE,  UVMapMake(344, 192, letterbox.width, letterbox.width));
		digit = QuadTemplateMakeFast(0, 0, letterbox.width * scale, 1.0, UVMapMake(0, 0, 0, 0));
		digit.color = COLOR_INTERFACE;
		
		for (i=0;i<10;i++) {
			charges[i] = QuadTemplateMake(0, 0, 0, 72.0 * scale, 72.0 * scale, COLOR_INTERFACE, UVMapMake(8 + (i * 72), 512, 72, 72));
		}
	}
	
	return self;
}

-(void)setState:(uint)state withTicks:(uint)modelTicks {
	
	self.enabled = (state == STATE_PLAYING || state == STATE_MENU_PAUSE);
	
}


-(void)draw:(CGRect)frame {
	
	if (!self.shouldDraw || !model.shield.enabled) {
		return;
	}
		
	uint strength = model.shield.energy * 10000;
	
	Vector cameraOffset = [[RenderEngine singleton] getCameraOffset];
	
	position = CGPointMake(cameraOffset.x + (110.0 * scale),cameraOffset.y - (12.0 * scale));
	
	uint lengthCounter=0;
	uint strengthDigit;
	BOOL dotSet = NO;
	float offset = 14.0 * scale;
	
	digit.y = position.y;
	digit.color = COLOR_INTERFACE;
	digit.color.a *= flicker;
	dot.y = position.y;
	dot.color = digit.color;
	
	shieldIcon.x = position.x - (169.0 * scale);
	shieldIcon.y = position.y - (56.0 * scale);
	shieldIcon.color.a = model.shield.energy < .95 ? .25 * flicker : digit.color.a;
	[[RenderEngine singleton] addQuad:&shieldIcon];
	
	if (strength < 100) {
		
		// render leading zero
		digit.x = position.x - digit.width - (44.0 * scale);
		digit.uv = digits[0];
		[[RenderEngine singleton] addQuad:&digit];
		
		if (strength > 0) {
			
			// set dot
			dot.x = digit.x + (6.0 * scale);
			[[RenderEngine singleton] addQuad:&dot];
			
			if (strength < 10) {
				// add another zero
				digit.x = dot.x + (5.0 * scale);
				[[RenderEngine singleton] addQuad:&digit];
				
			}
		}
		
		position.x -= 12.0 * scale;
	}	
	else if (strength < 1000) {
		position.x -= 12.0 * scale;
	}
	else if (strength < 10000) {
		position.x -= 6.0 * scale;
	}
	
	while (strength) {
		
		strengthDigit = strength % 10;
		digit.x = position.x - offset - digit.width;
		digit.uv = digits[strengthDigit];
		[[RenderEngine singleton] addQuad:&digit];
		strength*=.1;
		offset += digit.width - (10.0 * scale);
		
		if (strength && !dotSet) {
			lengthCounter++;
			if (lengthCounter%2==0) {
				dotSet = YES;
				dot.x = position.x - offset - dot.width;
				[[RenderEngine singleton] addQuad:&dot];
				offset+=dot.width - (10.0 * scale);
			}
		}
	}
	
	uint chargeIndex = 9 - round(model.shield.energy * 9);
	QuadTemplate charge = charges[chargeIndex];
	charge.x = cameraOffset.x - (6.5 * scale);
	charge.y = cameraOffset.y - (76 * scale);
	charge.color = digit.color;
	[[RenderEngine singleton] addQuad:&charge];
}


@end
