//
//  ShuttleExplosionActor.h
//  Eve of Impact
//
//  Created by Rik Schennink on 12/1/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "ExplosionActorBase.h"

@interface ShuttleExplosionActor : ExplosionActorBase {
	
	BOOL flash;
	
}

@property (readwrite) BOOL flash;

-(id)initWithScale:(float)scale;

@end
