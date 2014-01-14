//
//  Light.h
//  Eve of Impact
//
//  Created by Rik Schennink on 3/19/11.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Range.h"

@interface Pulse : NSObject {
    
	float intensity;
	
	uint progress;
	uint timer;
	uint period;
	float amplitude;
	
	Range periodRange;
	
}

@property (readonly) float intensity;

-(id)initWithPeriod:(Range)p;
-(void)update;

@end
