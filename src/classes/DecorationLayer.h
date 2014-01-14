//
//  InterfaceGenerator.h
//  Eve of Impact
//
//  Created by Rik Schennink on 4/1/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Common.h"

@class ApplicationModel;
@class SatelliteActor;

@interface DecorationLayer : NSObject {
	
	ApplicationModel* model;
	
	UVMap digitUVMaps[10];
	QuadTemplate digit;
	
	QuadTemplate missileTarget;
	
	QuadTemplate marker;
	QuadTemplate markerCorner;
	UVMap markerCorners[4];
	
	QuadTemplate labelPointer;
	
	QuadTemplate podLabel;
	QuadTemplate shuttleLabel;
	QuadTemplate shuttleLabelPointer;
	QuadTemplate shuttleLabelCapacity;
	
	QuadTemplate satelliteState;
	UVMap loadingStatesMap[9];
	SatelliteActor* shieldOrigin;
	
	uint lastWarningTick;
	
	float scale;
}

-(id)initWithModel:(ApplicationModel*)applicationModel;

-(void)redraw:(float)interpolation;

@end
