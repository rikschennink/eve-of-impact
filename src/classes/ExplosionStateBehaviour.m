//
//  ExplosionStateBehaviour.m
//  Eve of Impact
//
//  Created by Rik Schennink on 7/7/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "ExplosionStateBehaviour.h"


@implementation ExplosionStateBehaviour

-(void)update:(ActorBase *)actor {
	
	[super update:actor];
	
	if (life == 1) {
		[self replace:STATE_ALIVE with:STATE_DYING];
	}
}

@end
