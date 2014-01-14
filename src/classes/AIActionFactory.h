//
//  AIActionFactory.h
//  Eve of Impact
//
//  Created by Rik Schennink on 7/8/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AIAction.h"
#import "Range.h"
#import "AI.h"

@interface AIActionFactory : NSObject {
	
	uint originTimer;
	Range originRange;
	float asteroidVelocityMax;
	
}

-(id)init;

-(void)reset;

-(AIAction*)getAIActionForDifficulty:(uint)difficulty;

-(void)setIntroAction:(AIAction*)action;
-(void)setEasyAction:(AIAction*)action;
-(void)setMediumAction:(AIAction*)action;
-(void)setHardAction:(AIAction*)action;
-(void)setInsaneAction:(AIAction*)action;

-(void)addSmallAsteroidTo:(AIAction*)action;
-(void)addMediumAsteroidTo:(AIAction*)action;
-(void)addBigAsteroidTo:(AIAction*)action;
-(void)addGroupOf:(uint)amount AsteroidsTo:(AIAction*)action;
-(void)addOpposingAsteroidsTo:(AIAction*)action;

-(AICommand)getDefaultAsteroidCommand;

@end
