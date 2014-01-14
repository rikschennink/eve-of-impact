//
//  Graphic.h
//  EarthZero
//
//  Created by Rik & Wendy on 2/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Visual.h"

@class Vector3D;

@interface Graphic : Visual {
	
	Vector3D* center;
	Vector3D* position;
	Vector3D* rotation;
	NSString* texture;
	
}

@property (nonatomic,retain) Vector3D*	center;
@property (nonatomic,retain) Vector3D*	position;
@property (nonatomic,retain) Vector3D*	rotation;
@property (nonatomic,retain) NSString*	texture;

-(void)glMove;
-(void)glRotate;
-(void)glTexture;

@end
