//
//  PointSprite.h
//  EarthZero
//
//  Created by Rik & Wendy on 2/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Graphic.h"


@interface PointSprite : Graphic {
	
	GLfloat radius;
	
}

@property (assign) GLfloat radius;

@end
