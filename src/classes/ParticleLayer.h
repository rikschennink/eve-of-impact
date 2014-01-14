//
//  ParticleLayer.h
//  Eve of Impact
//
//  Created by Rik Schennink on 11/29/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Common.h"

@class ApplicationModel;
@class ParticleManager;

@interface ParticleLayer : NSObject {
	
	ParticleManager* manager;
	
	QuadTemplate particle;
	UVMap mapDust;
	UVMap mapFire;
	float opacityFraction;
	
	float scale;
	
}

-(id)initWithModel:(ApplicationModel*)applicationModel;
-(void)redraw:(float)interpolation;

@end
