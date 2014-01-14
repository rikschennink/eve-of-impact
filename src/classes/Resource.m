//
//  Resource.m
//  Eve of Impact
//
//  Created by Rik Schennink on 3/31/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "Resource.h"


@implementation Resource

@synthesize identifier;

-(id)initWithIdentifier:(NSString*)identifierString {
	
	if (self = [super init]) {
		
		identifier = identifierString;
		
	}
	
	return self;
	
}

-(void)dealloc {
	
	[identifier release];
	
	[super dealloc];
}

@end
