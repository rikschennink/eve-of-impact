//
//  LinearMoveBehaviour.m
//  Eve of Impact
//
//  Created by Rik Schennink on 2/15/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "LinearMoveBehaviour.h"
#import "ActorBase.h"

@implementation LinearMoveBehaviour

-(void)update:(ActorBase*)actor {
	
	actor->position.x += actor->velocity.x;
	actor->position.y += actor->velocity.y;
	
	[super update:actor];
}

@end
