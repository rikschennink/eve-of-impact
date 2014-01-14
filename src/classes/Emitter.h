//
//  Emitter.h
//  Eve of Impact
//
//  Created by Rik Schennink on 12/11/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Particle.h"

@protocol Emitter

-(uint)addEmissionsTo:(Particle*)collection atIndex:(uint)index;

@end
