//
//  HistoryBehaviour.h
//  Eve of Impact
//
//  Created by Rik Schennink on 7/7/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Behaviour.h"
#import "Vector.h"

@protocol HistoryBehaviour <Behaviour>

@property (readonly) uint max;
@property (readonly) uint index;
@property (readonly) uint count;
@property (readonly) float* coordinates;

-(id)initWithMaxCoordinates:(uint)maximum;
-(void)addCoordinate:(Vector)coordinate;

@end
