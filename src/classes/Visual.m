//
//  Visual.m
//  Earth's Defense
//
//  Created by Rik & Wendy on 4/2/10.
//  Copyright 2010 Italic Pigeon. All rights reserved.
//

#import "Visual.h"
#import "RenderEngine.h"

@implementation Visual

@synthesize blendMode;
@synthesize opacity;

-(id)init {
	
	if (self = [super init]) {
		
		blendMode = BLEND_MODE_DEFAULT;
		
		opacity = 1.0;
		
		defaultColor[0] = 1.0;
		defaultColor[1] = 1.0;
		defaultColor[2] = 1.0;
		defaultColor[3] = 1.0;
		
		color = CGColorCreate(CGColorSpaceCreateDeviceRGB(),defaultColor);
		
	}
	
	return self;
}

-(void)render {
	
}

-(void)resetColor {
	[self setColor:CGColorCreate(CGColorSpaceCreateDeviceRGB(),defaultColor)];
}

-(void)setColor:(CGColorRef)newColor {
	if (color) {
		CGColorRelease(color);
	}
	color = newColor;
}

-(void)glColor {
	const CGFloat *components = CGColorGetComponents(color);
	glColor4f(components[0],components[1],components[2],components[3]);
}

-(void)glBlend {
	
	switch (blendMode) {
		case BLEND_MODE_DEFAULT:
			glBlendFunc(GL_ONE,GL_ONE_MINUS_SRC_ALPHA);
			break;
		case BLEND_MODE_MULTIPLY:
			glBlendFunc(GL_DST_COLOR, GL_ONE_MINUS_SRC_ALPHA);
			break;
		case BLEND_MODE_SCREEN:
			glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_COLOR);
			break;
		case BLEND_MODE_DODGE:
			glBlendFunc(GL_DST_COLOR, GL_ONE);
			break;
		default:
			glBlendFunc(GL_ONE,GL_ONE_MINUS_SRC_ALPHA);
			break;
	}
	
}

-(void)dealloc {
	
	CGColorRelease(color);
	
	[super dealloc];
}

@end
