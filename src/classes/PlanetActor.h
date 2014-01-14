//
//  PlanetActor.h
//  Eve of Impact
//
//  Created by Rik Schennink on 2/15/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "ActorBase.h"
#import "Puller.h"
#import "Collidable.h"
#import "Impactable.h"

@interface PlanetActor : ActorBase <Puller,Collidable,Impactable> {

@private
	
	NSMutableArray* impacts;
	
}

-(id)initWithRadius:(float)r andMass:(float)m;

@property (nonatomic,retain,readonly) NSMutableArray* impacts;

@end
