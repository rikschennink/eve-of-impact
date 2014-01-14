//
//  PointSpriteGroup.h
//  Earth's Defense
//
//  Created by Rik & Wendy on 4/8/10.
//  Copyright 2010 Pico Pigeon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Graphic.h"


@interface PointSpriteGroup : Graphic {
	
	NSMutableArray* coordinates;
	
	GLfloat radius;
	
}

@property (nonatomic,retain) NSMutableArray* coordinates;

@property (assign) GLfloat radius;

@end
