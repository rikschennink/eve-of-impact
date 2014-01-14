//
//  StateBehaviourBase.m
//  Eve of Impact
//
//  Created by Rik Schennink on 7/6/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "StateBehaviourBase.h"
#import "ActorBase.h"

@implementation StateBehaviourBase

@synthesize life,lifespan;

-(id)initWithLifespan:(uint)span {
	
	if (self = [super init]) {
		
		lifespan = span;
		
		[self reset];
	}
	
	return self;
}

-(id)init {
	
	// initialize with max value of uint
	return [self initWithLifespan:4294967295];
	
}

-(void)setNewLifespan:(uint)span {
	
	lifespan = life + span;
	
}

-(float)progress {
	return (float)life / lifespan;
}

-(void)reset {
	life = 0;
	stateCount = 0;
	stateIndex = 0;
	for (uint i =0; i<ACTOR_MAX_STATES; i++) {
		states[i] = StateMake(STATE_EMPTY);
	}
	[self add:STATE_ALIVE];
}

-(void)update:(ActorBase*)actor {
	if (life<lifespan) {
		
		life++;
		
		for (uint i =0;i<ACTOR_MAX_STATES;i++) {
			states[i].life++;
		}
	}
	else {
		[actor kill];
	}
}

-(void)receive:(uint)message {
	
}



-(BOOL)replace:(uint)stateToReplace with:(uint)stateReplacement {
	for (uint i=0;i<ACTOR_MAX_STATES;i++) {
		if (stateToReplace == states[i].type) {
			states[i] = StateMake(stateReplacement);
			return TRUE;
		}
	}
	return FALSE;
}

-(BOOL)remove:(uint)stateToRemove {
	
	if (stateCount>0) {
		for (uint i=0;i<ACTOR_MAX_STATES;i++) {
			if (stateToRemove == states[i].type) {
				states[i].type = STATE_EMPTY;
				stateIndex--;
				stateCount--;
				return TRUE;
			}
		}
	}
	
	return FALSE;
}

-(BOOL)add:(uint)stateToAdd {
	if (stateCount<ACTOR_MAX_STATES) {
		states[stateIndex] = StateMake(stateToAdd);
		stateIndex++;
		stateCount++;
		return TRUE;
	}
	
	return FALSE;
}

-(BOOL)contains:(uint)stateToMatch {
	for (uint i=0; i<ACTOR_MAX_STATES; i++) {
		if (stateToMatch == states[i].type) {
			return TRUE;
		}
	}
	return FALSE;
}

-(uint)getLifeInState:(uint)stateToMatch {
	for (uint i=0; i<ACTOR_MAX_STATES; i++) {
		if (stateToMatch == states[i].type) {
			return states[i].life;
		}
	}
	return 0;
}

@end
