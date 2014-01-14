//
//  PlanetLayer.h
//  Eve of Impact
//
//  Created by Rik Schennink on 6/1/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Common.h"

@class ApplicationModel;

@interface PlanetLayer : NSObject {
	
	ApplicationModel* model;
	
	RingTemplate shockwaveShadow;
	RingTemplate shockwaveFire;
	RingTemplate shockwaveInferno;
	RingTemplate shockwaveMask;
	
	QuadTemplate shockwaveGlow;
	QuadTemplate shockwaveSprite;
	
	QuadTemplate planetOverlay;
	QuadTemplate planetMask;
	QuadTemplate planetSprite;
	QuadTemplate planetShadow;
	
	float scale;
	
}

-(id)initWithModel:(ApplicationModel*)applicationModel;

-(void)redraw:(float)interpolation;


@end
