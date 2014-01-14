//
//  Clock.m
//  EarthDefense
//
//  Created by Rik & Wendy on 4/13/10.
//  Copyright 2010 Pico Pigeon. All rights reserved.
//

#import "Clock.h"
#import "ApplicationModel.h"
#import "RenderEngine.h"
#import "Prefs.h"

@implementation Clock

-(id)initWithModel:(ApplicationModel*)applicationModel {
	
	if (self = [super init]) {
		
		enabled = NO;
		touchable = NO;
		
		model = applicationModel;
		
		size = CGSizeMake(70, 18);
		
		
		CGSize letterbox = CGSizeMake(24, 32);
		uint offset = 8;
		
		for (uint i=0; i<10; i++) {
			digits[i] = UVMapMakeSize(offset + (i * letterbox.width), 104, letterbox.width, letterbox.height, 512);
		}
		
		digit = QuadTemplateMakeEmpty();
		digit.color = COLOR_INTERFACE;
		digit.width = 24.0;
		digit.height = 32.0;
		
		
		labelDays = QuadTemplateMake(0, 0, 0, 56.0, 16.0, COLOR_INTERFACE, UVMapMakeSize(8, 344, 56.0, 16.0, 512.0));
		labelYears = QuadTemplateMake(0, 0, 0, 56.0, 16.0, COLOR_INTERFACE, UVMapMakeSize(8, 328, 56.0, 16.0, 512.0));
		
	}
	
	return self;
}

-(void)setState:(uint)state {
	
	enabled = (state == STATE_PLAYING ||
			   state == STATE_MENU_PAUSE);
	
}

-(void)draw:(CGRect)frame {
	
	if (!enabled) {
		return;
	}
	
	self.position = CGPointMake((frame.size.width * .5) - 66, (-frame.size.height * .5) + 23.0);
	
	CGPoint global = [self localToGlobal];
	
	
	// calculate time passed
	uint i;
	uint hours = model.ticks * 10;
	
	// digits
	uint d = (hours / 24) % 365;
	uint y = hours * 0.00011415525114155;
	
	years[0] = (y/10) % 10;
	years[1] = y % 10;
	
	days[0] = (d/100) % 10;
	days[1] = (d/10) % 10;
	days[2] = d % 10;
	
	float offset = -18.0;
	labelDays.x = global.x - 34.0;
	labelDays.y = global.y - 10.0;
	[[RenderEngine singleton] addQuad:&labelDays];
	
	// set digit offset
	digit.y = labelDays.y - 3.0;
	
	for (i=0; i<3;i++) {
		
		digit.x = labelDays.x + labelDays.width + offset;
		digit.uv = digits[days[i]];
		
		[[RenderEngine singleton] addQuad:&digit];
		
		offset += 14.0;
	}
	
	// if years are specified
	if (y > 0) {
		
		offset = -12.0;
		labelYears.x = global.x - 110 - (years[1]>0?0:14);
		labelYears.y = labelDays.y;
		[[RenderEngine singleton] addQuad:&labelYears];
		
		for (i=0;i<2;i++) {
			
			if (years[i] > 0) {
				
				digit.x = labelYears.x + labelYears.width + offset;
				digit.uv = digits[years[i]];
				[[RenderEngine singleton] addQuad:&digit];
				
				offset+=14.0;
			}
		}
	}
}

@end
