//
//  ActorBase.h
//  Eve of Impact
//
//  Created by Rik Schennink on 2/12/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MathAdditional.h"
#import "Behaviour.h"
#import "StateBehaviour.h"
#import "StateBehaviourBase.h"
#import "MoveBehaviourBase.h"
#import "Vector.h"

@interface ActorBase : NSObject {
	
	uint uid;
	
	float radius;
	float mass;
	
	StateBehaviourBase<StateBehaviour>* state;
	MoveBehaviourBase<Behaviour>* movement;
	HistoryBehaviourBase<HistoryBehaviour>* history;
	
	BOOL dead;
	
	@public
	Vector position;
	Vector velocity;
}

@property (readonly) uint uid;
@property (readonly) BOOL dead;

@property (assign) float mass;
@property (assign) float radius;


@property Vector position;
@property Vector velocity;


@property (nonatomic,retain) StateBehaviourBase<StateBehaviour>* state;
@property (nonatomic,retain) MoveBehaviourBase<Behaviour>* movement;
@property (nonatomic,retain) HistoryBehaviourBase<HistoryBehaviour>* history;


-(id)initWithRadius:(float)r 
			  state:(StateBehaviourBase<StateBehaviour>*)s
		   movement:(MoveBehaviourBase<Behaviour>*)m;

-(void)act;
-(void)kill;
-(BOOL)inLimbo;
-(void)send:(uint)message;

-(void)setHistoryKeeper:(HistoryBehaviourBase <HistoryBehaviour>*)behaviour;
-(void)flush;

@end