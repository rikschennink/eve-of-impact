//
//  EffectsLayer.h
//  Eve of Impact
//
//  Created by Rik Schennink on 4/12/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Common.h"
#import "PulseManager.h"

@class ApplicationModel;

@interface EffectsLayer : NSObject {
	
	ApplicationModel* model;
	
	UVMap explosionGlareUV;
	UVMap explosionCoreUV;
	UVMap explosionGlowUV;
	UVMap explosionRingUV;
	UVMap explosionDotsUV;
	UVMap explosionDebreeUV;
	UVMap missileGlowUV;
	UVMap missileTrailEndUV;
	UVMap planetGlareUV;
	UVMap impactGlareUV;
	UVMap impactCoreUV;
	UVMap impactRingUV;
	UVMap moonGlareUV;
	UVMap flareUV;
	UVMap WMDUV;
	UVMap satGlowUV;
	UVMap planetDestroyedGlareUV;
	UVMap asteroidBurnUV;
	UVMap debreeBurnUV;
	UVMap debreeGlowUV;
	UVMap shuttleCoreUV;
	UVMap shieldShimmerUV;
	UVMap shieldShockUV;
	UVMap shieldImpactGlowUV;
	UVMap shieldChargeUV;
	UVMap planetGlareLeftUV;
	UVMap planetGlareRightUV;
	UVMap planetGlareBurnUV;
	UVMap planetGlareRightBurnUV;
	
	UVMap shardUV;
	
	QuadTemplate impactSpot;
	QuadTemplate impactGlow;
	
	Pulse* shieldGlimmer;
	PulseManager* impactGlimmers;
	
	float scale;
}

-(id)initWithModel:(ApplicationModel*)applicationModel;

-(void)redraw:(float)interpolation;

@end