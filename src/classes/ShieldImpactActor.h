//
//  MoonImpact.h
//  Eve of Impact
//
//  Created by Rik Schennink on 4/11/11.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "ImpactActor.h"


@interface ShieldImpactActor : ImpactActor {
    
	uint relatedActorUID;
}

@property (readonly) uint relatedActorUID;

-(id)initWithMass:(float)m andRelatedActorUID:(uint)relatedUID;

@end
