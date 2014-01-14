//
//  ExplosionActorBase.h
//  Eve of Impact
//
//  Created by Rik Schennink on 12/1/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "ActorBase.h"
#import "Collidable.h"
#import "Pusher.h"
#import "Explodable.h"
#import "Easing.h"
#import "Destructable.h"
#import "Emitter.h"

@interface ExplosionActorBase : ActorBase <Collidable,Pusher,Explodable,Emitter> {
	
	float radiusMax;
	float shockwaveRadius;
	float shockwaveRadiusMax;
	
	float pushForce;
	float pushRadius;
}


@property (readonly) float radiusMax;
@property (readonly) float shockwaveRadiusMax;
@property (readonly) float shockwaveRadius;

-(id)initWithFragmentationRadius:(float)fr shockwaveRadius:(float)sr andBehaviour:(StateBehaviourBase<StateBehaviour>*)b;

-(void)expand;


@end
