//
//  HistoryManagerBase.h
//  Eve of Impact
//
//  Created by Rik Schennink on 7/7/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HistoryBehaviour.h"
#import "Vector.h"

@interface HistoryBehaviourBase : NSObject <HistoryBehaviour> {
	
	uint count;
	uint index;
	uint max;
	float *coordinates;
}

-(id)initWithMaxCoordinates:(uint)maximum;
-(void)addCoordinate:(Vector)coordinate;

@end