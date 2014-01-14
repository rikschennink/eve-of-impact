//
//  Visual.h
//  Earth's Defense
//
//  Created by Rik & Wendy on 4/2/10.
//  Copyright 2010 Italic Pigeon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "Common.h"


@interface Visual : NSObject {
	
	CGColorRef color;
	float defaultColor[4];
	float opacity;
	uint blendMode;
	
}

@property (assign) float opacity;
@property (assign) uint blendMode;

-(void)render;

-(void)glBlend;
-(void)glColor;
-(void)setColor:(CGColorRef)newColor;
-(void)resetColor;

@end
