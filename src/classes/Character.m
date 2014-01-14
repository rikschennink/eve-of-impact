//
//  Character.m
//  Eve of Impact
//
//  Created by Rik Schennink on 9/25/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "Character.h"


@implementation Character

@synthesize character;
@synthesize map;
@synthesize size;
@synthesize width;
@synthesize height;

-(id)initWithCharacter:(NSString *)c width:(float)w height:(float)h size:(CGSize)s andMap:(UVMap)m {
	
	if ((self = [super init])) {
		
		character = [c copy];
		map = m;
		size = s;
		width = w;
		height = h;
		
	}
	
	return self;
	
}

-(void)dealloc {
	
	[character release];
	
	[super dealloc];
	
}


@end
