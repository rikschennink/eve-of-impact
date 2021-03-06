//
//  ShieldShockwaveActor.h
//  Eve of Impact
//
//  Created by Rik Schennink on 5/17/11.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "ExplosionActorBase.h"
#import "Emitter.h"

@interface ShieldShockwaveActor : ExplosionActorBase <Emitter> {
    
}

-(id)initWithRange:(float)range;
	
@end
