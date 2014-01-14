//
//  Behaviour.h
//  Eve of Impact
//
//  Created by Rik Schennink on 7/6/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ActorBase;

@protocol Behaviour <NSObject>

-(void)update:(ActorBase*)actor;

-(void)receive:(uint)message;

@end
