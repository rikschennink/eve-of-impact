//
//  ShuttleExplosionStateBehaviour.m
//  Eve of Impact
//
//  Created by Rik Schennink on 12/1/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "ShuttleExplosionStateBehaviour.h"


@implementation ShuttleExplosionStateBehaviour

-(void)update:(ActorBase *)actor {
	
	[super update:actor];
	
	if (self.progress > .75) {
		[self replace:STATE_ALIVE with:STATE_DYING];
	}
}

@end
