//
//  CameraLayer.h
//  Eve of Impact
//
//  Created by Rik Schennink on 11/6/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Common.h"
#import "Vector.h"

@class ApplicationModel;
@class ActorBase;
@class PulseManager;
@class Pulse;

@interface CameraLayer : NSObject {
	
	ApplicationModel* model;

	Vector projected;
	
	UVMap artifacts[10];
	int artifactCountdown;
	int artifactDirection;
	int artifactOffset;
	
	QuadTemplate shadingLeft;
	QuadTemplate shadingRight;
	QuadTemplate shadingTop;
	QuadTemplate shadingBottom;
	
	QuadTemplate sunGlow;
	QuadTemplate sunStar;
	QuadTemplate lensStreak;
	QuadTemplate lensSpec;
	
	UVMap lensSpecBig;
	UVMap lensSpecSmall;
	
	QuadTemplate lensGlare;
	QuadTemplate lensGlow;
	QuadTemplate lensStar;
	QuadTemplate lensCircle;
	QuadTemplate lensFlare;
	
	QuadTemplate flash;
	
    UVMap lensFlareRing;
    UVMap lensFlareBlob;
    
	Color lensFlareColorWarm;
	Color lensFlareColorCold;
    
	Pulse* sunGlimmer;
	PulseManager* actorGlimmers;
	
	uint flashCount;
	uint randomizer;
	
	float scale;
}


-(id)initWithModel:(ApplicationModel*)applicationModel;
-(void)redraw:(float)interpolation;

-(void)drawLensFlareFromOrigin:(Vector)origin withBaseColor:(Color)color andOpacityModifier:(float)modifier;
-(void)drawShuttleFlare:(ActorBase*)actor withInterpolation:(float)interpolation;
-(void)drawMissileFlare:(ActorBase*)actor withInterpolation:(float)interpolation;
-(void)drawExplosionFlare:(ActorBase*)actor withInterpolation:(float)interpolation;
-(void)drawImpactFlare:(ActorBase*)actor withInterpolation:(float)interpolation;
-(void)drawShuttleExplosionFlare:(ActorBase*)actor withInterpolation:(float)interpolation;
-(void)drawFlash:(ActorBase*)actor withInterpolation:(float)interpolation;
-(void)drawArtifactsWithInterpolation:(float)interpolation;

@end
