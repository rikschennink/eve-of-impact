//
//  ShieldShockwaveStateBehaviour.m
//  Eve of Impact
//
//  Created by Rik Schennink on 5/17/11.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "ShieldShockwaveStateBehaviour.h"


@implementation ShieldShockwaveStateBehaviour

-(void)update:(ActorBase *)actor {
	
	[super update:actor];
	
	if (self.progress > .75) {
		[self replace:STATE_ALIVE with:STATE_DYING];
	}
}

@end
