//
//  Graphic.m
//  EarthZero
//
//  Created by Rik & Wendy on 2/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Graphic.h"
#import "Vector3D.h"
#import "ResourceManager.h"
#import "Texture.h"

@implementation Graphic

@synthesize center;
@synthesize position;
@synthesize rotation;
@synthesize texture;

-(id)init {
	
	if (self = [super init]) {
		
		position = [[Vector3D alloc] init];
		rotation = [[Vector3D alloc] init];
		center = [[Vector3D alloc] init];
		
	}
	return self;
	
}

-(void)render {
	
}

-(void)glMove {
	glTranslatef(position.x,position.y,position.z);
}

-(void)glRotate {
	if (rotation.x != 0.0f) {
		glRotatef(rotation.x, 1.0f, 0.0f, 0.0f);
	}
	if (rotation.y != 0.0f) {
		glRotatef(rotation.y, 0.0f, 1.0f, 0.0f);
	}
	if (rotation.z != 0.0f) {
		glRotatef(rotation.z, 0.0f, 0.0f, 1.0f);
	}
}

-(void)glTexture {
	glBindTexture(GL_TEXTURE_2D,[(Texture*)[[ResourceManager sharedResourceManager] getResourceByIdentifier:texture] reference]);
}

-(void)dealloc {
	
	[center release];
	[position release];
	[rotation release];
	
	[super dealloc];
}

@end
