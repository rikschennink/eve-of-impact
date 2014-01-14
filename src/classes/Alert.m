//
//  Alert.m
//  Eve of Impact
//
//  Created by Rik Schennink on 6/6/11.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "Alert.h"
#import "Prefs.h"
#import "RenderEngine.h"

@implementation Alert

-(id)init {
	
	if ((self = [super init])) {
		
		cloud = QuadTemplateMake(0, 0, 0, 288.0 * scale, 88.0 * scale, COLOR_INTERFACE, UVMapMake(392, 304, 288, 88));
		previousAlert = PROMPT_NONE;
		
	}
		
	return self;
}

-(void)setAlert:(uint)alert {
	
	switch (alert) {
		case  PROMPT_NONE:
			enabled = false;
			previousAlert =  PROMPT_NONE;
		break;
			/*
		case  PROMPT_SHIP:
			if (previousAlert !=  PROMPT_SHIP) {
				enabled = true;
				previousAlert =  PROMPT_SHIP;
				alertText = QuadTemplateMake(0, 0, 0, 248, 48, COLOR_INTERFACE, UVMapMake(368, 112, 248, 48));
				alertIconAvailable = NO;
			}
			break;
		case  PROMPT_PANIC:
			if (previousAlert !=  PROMPT_PANIC) {
				enabled = true;
				previousAlert =  PROMPT_PANIC;
				alertText = QuadTemplateMake(0, 0, 0, 248, 48, COLOR_INTERFACE, UVMapMake(368, 16, 248, 48));
				alertIconAvailable = NO;
			}
			break;
			 */
		case  PROMPT_PAUSE:
			if (previousAlert !=  PROMPT_PAUSE) {
				enabled = true;
				previousAlert =  PROMPT_PAUSE;
				cloud = QuadTemplateMake(0, 0, 0, 288.0 * scale, 88.0 * scale, COLOR_INTERFACE, UVMapMake(392, 304, 288, 88));
			}
			break;
			/*
		case  PROMPT_SUPERWEAPON:
			if (previousAlert !=  PROMPT_SUPERWEAPON) {
				enabled = true;
				previousAlert =  PROMPT_SUPERWEAPON;
				alertText = QuadTemplateMake(0, 0, 0, 248, 48, COLOR_INTERFACE, UVMapMake(616, 160, 248, 48));
				alertIcon = QuadTemplateMake(0, 0, 0, 56, 72, COLOR_INTERFACE, UVMapMake(504, 304, 56, 72));
				alertIconAvailable = YES;
			}
			break;
			*/
		default:
			break;
	}
	
}

-(void)setState:(uint)state withTicks:(uint)modelTicks {
	
	if (enabled) {
		if (state != STATE_PLAYING) {
			enabled = NO;
		}
	}
	
}

-(void)draw:(CGRect)frame {
	
	if (!self.shouldDraw) {
		return;
	}
	
	// position alert to bottom left
	self.position = CGPointMake(-frame.size.width * .5,-frame.size.height * .5);
	
	cloud.x = self.position.x + (frame.size.width * .5) - (cloud.width * .5);
	cloud.y = self.position.y + (57.0 * scale);
	cloud.color = COLOR_INTERFACE;
	cloud.color.a *= flicker;
	
	[[RenderEngine singleton] addQuad:&cloud];
	
	/*
	alertText.color = cloud.color;
	alertText.x = cloud.x + 17.0;
	alertText.y = cloud.y + 25.0;
	
	[[RenderEngine singleton] addQuad:&alertText];
	
	if (alertIconAvailable) {
		
		alertIcon.color = cloud.color;
		alertIcon.x = cloud.x + cloud.width - alertIcon.width + 4.0;
		alertIcon.y = cloud.y + 6.0;
		
		[[RenderEngine singleton] addQuad:&alertIcon];
	}
	 [super draw:frame];
	 */
}

@end
