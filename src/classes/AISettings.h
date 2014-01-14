/*
 *  AISettings.h
 *  Eve of Impact
 *
 *  Created by Rik Schennink on 7/8/10.
 *  Copyright 2011 Rik Schennink. All rights reserved.
 *
 */

#import "Prefs.h"


typedef struct {
	
	uint asteroidCountMax;
	uint actionInterval;
	uint actionIntervalMin;
	uint actionDelay;
	uint actionSteepness;
	uint actionLimit;
	
} AISettings;

static inline AISettings AISettingsMake(uint difficulty) {
	AISettings s;
	switch (difficulty) {
		case INTRO:
			s.asteroidCountMax = 	6;
			s.actionInterval = 		0;
			s.actionIntervalMin = 	125;
			s.actionDelay = 		0;
			s.actionSteepness = 	0;
			s.actionLimit = 		1;
			break;
		case EASY:
			s.asteroidCountMax = 	6;
			s.actionInterval = 		195;
			s.actionIntervalMin = 	0;
			s.actionDelay = 		50;
			s.actionSteepness = 	0;
			s.actionLimit = 		8;
			break;
		case MEDIUM:
			s.asteroidCountMax = 	9;
			s.actionInterval = 		185;
			s.actionIntervalMin = 	0;
			s.actionDelay = 		200;
			s.actionSteepness = 	0;
			s.actionLimit = 		11;
			break;
		case HARD:
			s.asteroidCountMax = 	10;
			s.actionInterval = 		200;
			s.actionIntervalMin = 	160;
			s.actionDelay = 		350;
			s.actionSteepness = 	2;
			s.actionLimit = 		15;
			break;			
		case INSANE:
		default:
			s.asteroidCountMax = 	15;
			s.actionInterval = 		200;
			s.actionIntervalMin = 	140;
			s.actionDelay = 		450;
			s.actionSteepness = 	2;
			s.actionLimit = 		INT_MAX;
			break;
	}
	
	return s;
}
