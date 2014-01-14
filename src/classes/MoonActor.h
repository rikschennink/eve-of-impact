//
//  MoonActor.h
//  Eve of Impact
//
//  Created by Rik Schennink on 2/15/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "ActorBase.h"
#import "Puller.h"
#import "Collidable.h"
#import "Impactable.h"
#import "ActorBase.h"

@interface MoonActor : ActorBase <Puller,Collidable,Impactable> {
	NSMutableArray* impacts;
	uint hits;
}

-(id)initWithRadius:(float)r andMass:(float)m;

-(void)shatterBy:(ActorBase*)actor;

@end
