//
//  Sphere.h
//  EarthZero
//
//  Created by Rik & Wendy on 2/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Graphic.h"

@interface Planet : Graphic {
	float radius;
	NSMutableArray* parsedData;
	BOOL verticesCalculated;
}

@property (assign) float radius;

@end
