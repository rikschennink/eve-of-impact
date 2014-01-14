//
//  Collidable.h
//  Eve of Impact
//
//  Created by Rik Schennink on 6/30/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol Collidable <NSObject>

-(BOOL)canCollideWith:(ActorBase*)actor;

-(void)collideWith:(ActorBase*)actor afterTime:(float)time;

@end
