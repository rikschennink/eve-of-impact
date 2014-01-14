//
//  PulseManager.h
//  Eve of Impact
//
//  Created by Rik Schennink on 3/19/11.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ActorBase;
@class Pulse;

@interface PulseManager : NSObject {
    
	NSMutableArray* pulses;
	uint count;
	
}
-(id)initWithAmount:(uint)amount;
-(void)update;
-(Pulse*)getPulseByActor:(ActorBase*)actor;

@end
