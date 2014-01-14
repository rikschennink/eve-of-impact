//
//  Button.m
//  Eve of Impact
//
//  Created by Rik Schennink on 5/1/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "Button.h"
#import "Common.h"
#import "Prefs.h"
#import "RenderEngine.h"

@implementation Button
@synthesize orientation;

-(id)initWithLabel:(UVMap)labelUVMap {
	
	if ((self = [super init])) {
		
		orientation = BUTTON_ORIENTATION_LEFT;
		
		size = CGSizeMake((BUTTON_SIZE + BUTTON_MARGIN + BUTTON_BAR_WIDTH) * scale,BUTTON_SIZE * scale);
		
		label = QuadTemplateMake(0,0,0,64 * scale,16 * scale,color,labelUVMap);
		
		bar = QuadTemplateMake(0, 0, 0, 32 * scale, (BUTTON_SIZE + 24) * scale, color,  UVMapMake(104,408,32,96));
		
		button = QuadTemplateMake(0, 0, 0, (BUTTON_SIZE + 24) * scale, (BUTTON_SIZE + 24) * scale, color,  UVMapMake(8,408,96,96));
		
	}
	
	return self;
}

-(void)setColor:(Color)c {
	
	[super setColor:c];
	
	bar.color = color;
	button.color = color;
	
}

-(void)handleTouch {
	[super handleTouch];
	
	if (touchEvent != nil) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ButtonTouched" object:self];
	}
}

-(void)tick {
	if (enabled) {
		if (ticks==1 || ticks == 7) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"ButtonFlicker" object:self];
		}
	}
	
	[super tick];
}

-(void)draw:(CGRect)frame {
	
	if (!self.shouldDraw) {
		return;
	}
	[super draw:frame];
	
	CGPoint global = [self localToGlobal];
	
	button.y = global.y - (BUTTON_OFFSET * scale);
	button.color.a = touching ? 1.0 : .9;
	button.color.a *= flicker;
	
	bar.y = button.y;
	bar.color = button.color;
	
	label.color = ColorMake(0, 0, 0, 1.0);
	label.color.a = button.color.a;
	label.y = button.y + ((BUTTON_OFFSET + BUTTON_SIZE) * scale) - label.height;
	
	if (orientation == BUTTON_ORIENTATION_LEFT) {
		
		bar.x = global.x - (BUTTON_OFFSET * scale);
		button.x = bar.x + ((BUTTON_BAR_WIDTH + BUTTON_MARGIN) * scale);
		label.x = button.x + ((BUTTON_OFFSET + BUTTON_PADDING + BUTTON_MARGIN) * scale);
	
	}
	else {
		
		button.x = global.x - (BUTTON_OFFSET * scale);
		bar.x = button.x + ((BUTTON_SIZE + BUTTON_MARGIN) * scale);
		label.x = button.x + ((BUTTON_OFFSET + BUTTON_SIZE) * scale) - label.width;
	
	}
	
	if (!touchable) {
		bar.color.a *= .25;
		button.color.a *= .25;
	}
	
	if (!SCREENSHOT_MODE) {
		[[RenderEngine singleton] addQuad:&bar];
		[[RenderEngine singleton] addQuad:&button];
		[[RenderEngine singleton] addQuad:&label];
	}
}

@end
