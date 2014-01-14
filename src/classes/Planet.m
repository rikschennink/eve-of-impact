//
//  Sphere.m
//  EarthZero
//
//  Created by Rik & Wendy on 2/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Planet.h"
#import "Common.h"

@implementation Planet

@synthesize radius;

-(id)init {
	
	if (self = [super init]) {
		verticesCalculated = FALSE;
		parsedData = [[NSMutableArray alloc] init];
	}
	return self;
	
}

-(void)render {
	
	
}

@end
