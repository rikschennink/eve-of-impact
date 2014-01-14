//
//  Font.m
//  Eve of Impact
//
//  Created by Rik Schennink on 9/25/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "Font.h"
#import "Character.h"

@implementation Font

@synthesize space;

-(id)init {
	
	if ((self = [super init])) {
		
		characters = [[NSMutableDictionary alloc] init];
		space = 0;
		
	}
	
	return self;
	
}

-(void)addCharacter:(Character*)character {
	
	[characters setObject:character forKey:character.character];
	
}

-(Character*)characterAt:(NSString*)key {
	
	return [characters objectForKey:key];
	
}

-(void)dealloc {
	
	[characters release];
	
	[super dealloc];
}

@end
