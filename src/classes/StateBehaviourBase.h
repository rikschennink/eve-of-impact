//
//  StateBehaviourBase.h
//  Eve of Impact
//
//  Created by Rik Schennink on 7/6/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Behaviour.h"
#import "Prefs.h"
#import "State.h"

@interface StateBehaviourBase : NSObject <Behaviour> {
	
	uint life;
	uint lifespan;
	
	State states[ACTOR_MAX_STATES];
	uint stateIndex;
	uint stateCount;
	
}

@property (readonly) uint life;
@property (readonly) uint lifespan;

-(id)initWithLifespan:(uint)span;
-(void)setNewLifespan:(uint)span;
-(float)progress;
-(void)update:(ActorBase*)actor;
-(void)reset;

-(BOOL)add:(uint)stateToAdd;
-(BOOL)remove:(uint)stateToRemove;
-(BOOL)replace:(uint)stateToReplace with:(uint)stateReplacement;
-(BOOL)contains:(uint)stateToMatch;
-(uint)getLifeInState:(uint)stateToMatch;


@end
