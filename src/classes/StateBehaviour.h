//
//  StateBehaviour.h
//  Eve of Impact
//
//  Created by Rik Schennink on 7/6/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Behaviour.h"
#import "State.h"

@protocol StateBehaviour <Behaviour>

-(id)initWithLifespan:(uint)span;

-(void)setNewLifespan:(uint)span;

-(void)update:(ActorBase*)actor;

-(void)reset;

-(BOOL)add:(uint)stateToAdd;
-(void)remove:(uint)stateToRemove;
-(void)replace:(uint)stateToReplace with:(uint)stateReplacement;
-(BOOL)contains:(uint)stateToMatch;
-(uint)getLifeInState:(uint)stateToMatch;

@end
