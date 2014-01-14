//
//  GUIView.h
//  Eve of Impact
//
//  Created by Rik Schennink on 2/22/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Common.h"
#import "Vector.h"


@class Control;
@class World;
@class ApplicationModel;
@class Tutorial;
@class ScoreCounter;
@class Menu;
@class Button;
@class Label;
@class HighScoreTable;
@class HighScoreBoard;
@class Rank;
@class SatelliteActor;
@class ShieldIndicator;
@class CountdownIndicator;
@class Alert;

@interface InterfaceLayer : NSObject {
	
	Control* gui;
	ApplicationModel* model;
	
	SatelliteActor* currentTargetOrigin;
	BOOL targetting;
	
	ScoreCounter* score;
	Menu* menu;
	HighScoreTable* highScoreTable;
	Rank* rank;
	ShieldIndicator* shieldIndicator;
    CountdownIndicator* countdown;
    Tutorial* tutorial;
	Alert* alert;
	
	UVMap digitUVMaps[10];
	UVMap indicatorSizeMap[5];
	
	Vector center;
	Vector projected;
	
	QuadTemplate dot;
	QuadTemplate scanlines;
	QuadTemplate interface;
	QuadTemplate digit;
	QuadTemplate sizeIndicator;
	QuadTemplate warningSign;
	
	uint lastModelTick;
	BOOL touching;
	float scale;
}

@property(readonly) BOOL touching;

-(id)initWithModel:(ApplicationModel*)applicationModel;

-(void)updateUsername:(NSString*)username;
-(void)updateHighScores;
-(void)updateLocalRank;
-(void)updateGlobalRank:(uint)globalRank;
-(void)setAchievementUnlockedDescription:(NSString*)description;
-(void)resetAchievementUnlockedDescription;

-(void)onTouchesBeginAt:(CGPoint)touch;
-(void)onTouchesMoveAt:(CGPoint)touch;
-(void)onTouchesEndAt:(CGPoint)touch;

-(void)redraw:(float)interpolation;

@end
