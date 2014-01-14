//
//  ExplosionActorBase.m
//  Eve of Impact
//
//  Created by Rik Schennink on 12/1/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "ExplosionActorBase.h"
#import "Particle.h"

@implementation ExplosionActorBase

@synthesize shockwaveRadius,shockwaveRadiusMax,radiusMax,pushForce,pushRadius;

-(id)initWithFragmentationRadius:(float)fr shockwaveRadius:(float)sr andBehaviour:(StateBehaviourBase<StateBehaviour>*)b; {
	
	if (self = [super initWithRadius:0 
							   state:b 
							movement:[[MoveBehaviourBase alloc] init]]) {
		
		radiusMax = fr;
		shockwaveRadius = 0;
		shockwaveRadiusMax = sr;
		pushForce = 1.0;
		pushRadius = sr;
	}
	
	return self;
}

-(void)act {
	
	[self expand];
	
	[super act];
}

-(void)expand {
	
}

-(BOOL)canCollideWith:(ActorBase*)actor {
	return [self.state contains:STATE_ALIVE] && [actor conformsToProtocol:@protocol(Destructable)];
}

-(void)collideWith:(ActorBase *)actor afterTime:(float)time {
	
}

-(uint)addEmissionsTo:(Particle*)collection atIndex:(uint)index {
	return index;
}

@end
