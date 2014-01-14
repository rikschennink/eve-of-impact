//
//  AchievementDispenser.h
//  Eve of Impact
//
//  Created by Rik Schennink on 11/24/11.
//  Copyright (c) 2011 Rik Schennink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AchievementDispenser : NSObject {
	
	uint currentAsteroidsDestroyed;
	uint totalAsteroidsDestroyed;
	
	uint currentAsteroidsDestroyedSuccession;
	uint currentHumanCasualties;
	uint currentMissilesExploded;
	uint currentAsteroidsExited;
	
	NSMutableDictionary* descriptions;
	
	BOOL waitingForAsteroidDestruction;
	
}

-(void)reset;
-(void)save;
-(void)dispense:(NSString*)uid;
-(void)dispense:(NSString*)uid withProgress:(float)progress;
-(NSString*)getDescriptionForAchievement:(NSString*)uid;


@end
