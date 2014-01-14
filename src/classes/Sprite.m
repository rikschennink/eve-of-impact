//
//  Sprite.m
//  EarthZero
//
//  Created by Rik & Wendy on 2/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Sprite.h"
#import "Vector3D.h"

@implementation Sprite

@synthesize size;
@synthesize slice;

-(id)init {
	
	if (self = [super init]) {
		
		size = CGSizeMake(64.0, 64.0);
		slice = CGRectMake(0.0,0.0,1.0,1.0);
		
	}
	
	return self;
	
}

-(void)render {
	
	// set color
	[super glColor];
	
	// enable functionality
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	
	[super glMove];
	
	[super glRotate];
	
	glEnable(GL_BLEND);
	
	[super glBlend];
	
	// bind texture
	[super glTexture];
	
	SpriteData vertices[4] = {
		{
			{-center.x,	-center.y + size.height},
			{slice.origin.x,slice.origin.y + slice.size.height},
			{opacity, opacity, opacity, opacity}
		},
		{
			{-center.x + size.width,-center.y + size.height},
			{slice.origin.x + slice.size.width,	slice.origin.y + slice.size.height},
			{opacity, opacity, opacity, opacity}
		},
		{
			{-center.x,-center.y},
			{slice.origin.x,slice.origin.y},
			{opacity, opacity, opacity, opacity}
		},
		{
			{-center.x + size.width,-center.y},
			{slice.origin.x + slice.size.width,	slice.origin.y},
			{opacity, opacity, opacity, opacity}
		}
	};
	
	// draw polygon
	glVertexPointer(2, GL_FLOAT, sizeof(SpriteData), &vertices[0].vertex);
	glTexCoordPointer(2, GL_FLOAT, sizeof(SpriteData), &vertices[0].uv);
	glColorPointer(4, GL_FLOAT, sizeof(SpriteData), &vertices[0].color);
	
	// draw polygon
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	// disable blending modes
	glDisable(GL_BLEND);
	
	// disable functionality
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	glLoadIdentity();
	
}



@end
