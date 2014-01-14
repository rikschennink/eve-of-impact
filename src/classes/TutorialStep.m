//
//  TutorialStep.m
//  Eve of Impact
//
//  Created by Rik Schennink on 9/28/11.
//  Copyright Rik Schennink. All rights reserved.
//

#import "TutorialStep.h"
#import "Prefs.h"
#import "RenderEngine.h"

@implementation TutorialStep

@synthesize decoration,decorationFixed,title,group;

-(id)initWithGroupIndex:(uint)index {
	
	self = [super init];
	
	if (self) {
		
		group = index;
		
		
		CGSize screenSize = [[RenderEngine singleton]getScreenSize];
		
		
		header = QuadTemplateMake(0, 0, 0, 72.0 * scale, 16.0 * scale, COLOR_INTERFACE, UVMapMake(152, 344, 72, 16));
		header.x = 0;//screenSize.width * .5;
		header.y = 0;//213.0 * scale;
		
		header.x = (screenSize.width * .5) - header.width - (16.0 * scale);
		header.y = (screenSize.height * .5) - header.height - (16.0 * scale);
		
		
		decoration = [[Clip alloc] init];
		
		decorationFixed = [[Clip alloc] init];
		decorationFixed.position = CGPointMake(0,0);
		
		title = [[Clip alloc] init];
		title.position = CGPointMake(screenSize.width - (238.0 * scale), screenSize.height - (60.0 * scale));
		
		[self addChild:decoration];
		[self addChild:decorationFixed];
		[self addChild:title];
	}
	
	return self;
}

-(void)setEnabled:(BOOL)state {
	
	decoration.enabled = state;
	decorationFixed.enabled = state;
	
	if (!state) {
		[title disable];
	}
	
	[super setEnabled:state];
}

-(void)setTitleAttention {
	title.enabled = YES;
}

-(void)showTitle {
	[title enable];
}

-(void)draw:(CGRect)frame {
	
	if (!self.shouldDraw) {
		return;
	}
	
	// get camera offset
	Vector cameraOffset = [[RenderEngine singleton] getCameraOffset];
	
	decoration.position = CGPointMake((frame.size.width * .5) + cameraOffset.x, 
									  (frame.size.height * .5) + cameraOffset.y);
	
	if (title.enabled) {
		header.color = COLOR_INTERFACE;
		header.color.a *= title.flicker < 1.0 ? flicker : 1.0;
		[[RenderEngine singleton] addQuad:&header];
	}
	
	[super draw:frame];	
}

-(void)dealloc {
	
	[decoration release];
	[decorationFixed release];
	[title release];
	
	[super dealloc];
}

@end
