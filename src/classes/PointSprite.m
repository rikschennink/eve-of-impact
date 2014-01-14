//
//  PointSprite.m
//  EarthZero
//
//  Created by Rik & Wendy on 2/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PointSprite.h"


@implementation PointSprite


@synthesize radius;


-(id)init {
	
	if (self = [super init]) {
		
		
	}
	return self;
	
}

-(void)render {
	
	// set color
	[super glColor];
	
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	
	// set point sprite stuff
	glEnable(GL_POINT_SPRITE_OES);
	glTexEnvf(GL_POINT_SPRITE_OES, GL_COORD_REPLACE_OES, GL_TRUE);
	
	// move to correct position
	[super glMove];
	
	// set size of point
	glPointSize(radius * 2);
	
	glEnable(GL_BLEND);
	
	[super glBlend];
	
	// bind texture
	[super glTexture];
	
	// set vertice data
	PointSpriteData vertices[1] = {
		{
			{0.0f,0.0f,0.0f},
			{opacity, opacity, opacity, opacity}
		}
	};
	
	// define pointer to point coordinates
	glVertexPointer(3, GL_FLOAT, sizeof(PointSpriteData), &vertices[0].vertex);
	glColorPointer(4, GL_FLOAT, sizeof(PointSpriteData), &vertices[0].color);
	
	// draw point at point coordinate
	glDrawArrays(GL_POINTS, 0, 1);
	
	glDisable(GL_BLEND);
	glDisable(GL_POINT_SPRITE_OES);
	
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_VERTEX_ARRAY);
	
	glLoadIdentity();
}

@end
