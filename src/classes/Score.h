//
//  Score.h
//  Eve of Impact
//
//  Created by Rik Schennink on 2/26/11.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vector.h"

@interface Score : NSObject {
	
	float points;
	float step;
	float stack;
	int counter;
	Vector lastExplosionPosition;
	
}

@property (readonly) float points;
@property (readonly) float step;
@property (readonly) int counter;

-(void)update;
-(void)slow:(Vector)position;
-(void)decrease:(float)amount;
-(void)reset;

@end
