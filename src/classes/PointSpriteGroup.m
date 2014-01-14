//
//  PointSpriteGroup.m
//  Earth's Defense
//
//  Created by Rik & Wendy on 4/8/10.
//  Copyright 2010 Pico Pigeon. All rights reserved.
//

#import "PointSpriteGroup.h"
#import "Vector3D.h"


@implementation PointSpriteGroup

@synthesize coordinates;
@synthesize radius;

-(id)init {
	
	if (self = [super init]) {
		
		coordinates = [NSMutableArray new];
		
	}
	return self;
	
}

-(void)render {
	
	// set color
	[super glColor];
	
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
	// set point sprite stuff
	glEnable(GL_POINT_SPRITE_OES);
	glTexEnvf(GL_POINT_SPRITE_OES, GL_COORD_REPLACE_OES, GL_TRUE);
	
	uint points,count = [coordinates count];
	points = 0;
	
	GLfloat pointCoordinates[count * 3];
	
	for (Vector3D* coordinate in coordinates) {
		pointCoordinates[points * 3] = coordinate.x;
		pointCoordinates[(points * 3) + 1] = coordinate.y;
		pointCoordinates[(points * 3) + 2] = coordinate.z;
		points++;
	}
	
	// set size of point
	glPointSize(radius * 2);
	
	glEnable(GL_BLEND);
	
	[super glBlend];
	
	// bind texture
	[super glTexture];
	
	// define pointer to point coordinates
	glVertexPointer(3, GL_FLOAT, 0, pointCoordinates);
	
	// draw point at point coordinate
	glDrawArrays(GL_POINTS, 0, points);
	
	glDisable(GL_BLEND);
	glDisable(GL_POINT_SPRITE_OES);
	
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_VERTEX_ARRAY);
	
	glLoadIdentity();
}

@end
