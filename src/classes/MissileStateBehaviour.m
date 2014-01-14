//
//  MissileStateBehaviour.m
//  Eve of Impact
//
//  Created by Rik Schennink on 7/6/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "MissileStateBehaviour.h"

@implementation MissileStateBehaviour

-(void)update:(ActorBase *)actor {
	
	[super update:actor];
	
	if (lifespan - life <= 20) {
		[self replace:STATE_ALIVE with:STATE_DYING];
	}
	
}

-(void)receive:(uint)message {
	
	
}

@end