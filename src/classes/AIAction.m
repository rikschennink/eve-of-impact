//
//  AIAction.m
//  Eve of Impact
//
//  Created by Rik Schennink on 7/8/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "AIAction.h"
#import "Prefs.h"

@implementation AIAction

@synthesize count;

-(AICommand*)commands {
	return commands;
}

-(id)init {
	
	self = [super init];
	
	if (self) {
		
		count = 0;
		
	}
	
	return self;
}

-(void)addCommand:(AICommand)command {
	if (count < 10) {
		commands[count] = command;
		count++;
	}
}

@end