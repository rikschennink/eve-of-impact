//
//  HighScore.m
//  Eve of Impact
//
//  Created by Rik Schennink on 7/1/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "HighScore.h"


@implementation HighScore

@synthesize name,points,index;

-(id)initWithName:(NSString*)playerName andScore:(uint)playerPoints {
	
	if ((self = [super init])) {
		
		name = playerName;
		points = playerPoints;
		index = -1;
		
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	
	if ((self = [super init])) {
		
		name = [[coder decodeObjectForKey:@"name"] retain];
		points = [coder decodeIntForKey:@"points"];
		
	}
	
	return self;
	
}

- (void)encodeWithCoder:(NSCoder *)coder {
	
	[coder encodeObject:name forKey:@"name"];
	[coder encodeInt:points forKey:@"points"];

}

- (void)dealloc {
	
	[name release];
	
	[super dealloc];
	
}

@end
