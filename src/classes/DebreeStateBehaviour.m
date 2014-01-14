//
//  DebreeStateBehaviour.m
//  Eve of Impact
//
//  Created by Rik Schennink on 11/6/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "DebreeStateBehaviour.h"


@implementation DebreeStateBehaviour

-(id)initWithLifespan:(uint)span {
	
	if (self = [super initWithLifespan:span]) {
		
		[self add:STATE_INVULNERABLE];
		
	}
	
	return self;
}

-(void)update:(ActorBase*)actor {
	
	[super update:actor];
	
	if (life == 5) {
		[self remove:STATE_INVULNERABLE];
	}
}

@end
