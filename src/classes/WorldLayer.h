//
//  WorldView.h
//  Eve of Impact
//
//  Created by Rik Schennink on 2/22/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Common.h"

@class ApplicationModel;
@class ActorBase;

@interface WorldLayer : NSObject {
	
	ApplicationModel* model;
	
	UVMap asteroidUV[5];
	UVMap satellite;
	UVMap moon;
	UVMap missileUV;
	UVMap earthShadow;
	UVMap moonShadow;
	UVMap missileTrailEndUV;
	
	
	Color bodyShadowColor;
	
	LineTemplate missileTrail;
	QuadTemplate actorVisual;
	
	float scale;
}

-(id)initWithModel:(ApplicationModel*)applicationModel;

-(void)redraw:(float)interpolation;


@end