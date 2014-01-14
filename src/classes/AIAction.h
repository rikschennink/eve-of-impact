//
//  AIAction.h
//  Eve of Impact
//
//  Created by Rik Schennink on 7/8/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AICommand.h"
#import "Prefs.h"

@interface AIAction : NSObject {
	
	AICommand commands[10];
	uint count;
	
}

@property (readonly) AICommand* commands;
@property (readonly) uint count;

-(void)addCommand:(AICommand)command;

@end