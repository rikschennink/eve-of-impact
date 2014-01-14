//
//  AchievementDispenser.m
//  Eve of Impact
//
//  Created by Rik Schennink on 11/24/11.
//  Copyright Rik Schennink. All rights reserved.
//

#import "AchievementDispenser.h"
#import "AchievementProgress.h"
#import "ShipActor.h"


#define ACHIEVEMENT_TWITTER_SHARE							@"3"	// Bad News Everyone!
#define ACHIEVEMENT_MOON_DESTROYED							@"1"	// Oops, My Bad!

#define ACHIEVEMENT_DESTROYED_SUCCESSION_BRONZE				@"5"	// Locked and Loaded!
#define ACHIEVEMENT_DESTROYED_SUCCESSION_SILVER				@"20"	// Ready? Aim!
#define ACHIEVEMENT_DESTROYED_SUCCESSION_GOLD				@"21"	// Smoke me a Kipper!
#define ACHIEVEMENT_DESTROYED_SUCCESSION_BRONZE_AMOUNT		10
#define ACHIEVEMENT_DESTROYED_SUCCESSION_SILVER_AMOUNT		25
#define ACHIEVEMENT_DESTROYED_SUCCESSION_GOLD_AMOUNT		50

#define ACHIEVEMENT_CASUALTIES_BRONZE						@"7"	// Red Alert!
#define ACHIEVEMENT_CASUALTIES_SILVER						@"8"	// Abandon Ship!
#define ACHIEVEMENT_CASUALTIES_GOLD							@"9"	// The Horror!
#define ACHIEVEMENT_CASUALTIES_BRONZE_AMOUNT				50000
#define ACHIEVEMENT_CASUALTIES_SILVER_AMOUNT				60000
#define ACHIEVEMENT_CASUALTIES_GOLD_AMOUNT					70000

#define ACHIEVEMENT_ALL_DESTROYED_BRONZE					@"10"	// Space Junk
#define ACHIEVEMENT_ALL_DESTROYED_SILVER					@"11"	// Collision Cascade
#define ACHIEVEMENT_ALL_DESTROYED_GOLD						@"12"	// Kessler Syndrome
#define ACHIEVEMENT_ALL_DESTROYED_BRONZE_SURVIVORS			40000
#define ACHIEVEMENT_ALL_DESTROYED_SILVER_SURVIVORS			50000
#define ACHIEVEMENT_ALL_DESTROYED_GOLD_SURVIVORS			60000

#define ACHIEVEMENT_NONE_DESTROYED_BRONZE					@"13"	// Push it!
#define ACHIEVEMENT_NONE_DESTROYED_SILVER					@"14"	// Deflector Array!
#define ACHIEVEMENT_NONE_DESTROYED_GOLD						@"15"	// Shock and Awe!
#define ACHIEVEMENT_NONE_DESTROYED_BRONZE_SURVIVORS			60000
#define ACHIEVEMENT_NONE_DESTROYED_SILVER_SURVIVORS			70000
#define ACHIEVEMENT_NONE_DESTROYED_GOLD_SURVIVORS			80000

#define ACHIEVEMENT_TOTAL_DESTROYED_BRONZE					@"17"	// Always on Guard!
#define ACHIEVEMENT_TOTAL_DESTROYED_SILVER					@"18"	// Earth Command!
#define ACHIEVEMENT_TOTAL_DESTROYED_GOLD					@"19"	// More Rocks Please!
#define ACHIEVEMENT_TOTAL_DESTROYED_BRONZE_AMOUNT			500
#define ACHIEVEMENT_TOTAL_DESTROYED_SILVER_AMOUNT			2500
#define ACHIEVEMENT_TOTAL_DESTROYED_GOLD_AMOUNT				5000



@implementation AchievementDispenser



-(id)init {
	
	self = [super init];
	
	if (self) {
		
		[self reset];
		
		descriptions = [[NSMutableDictionary alloc]init];
		
		[descriptions setValue:@"Bad News Everyone!"	forKey:ACHIEVEMENT_TWITTER_SHARE];
		[descriptions setValue:@"Oops, My Bad!" 		forKey:ACHIEVEMENT_MOON_DESTROYED];
		
		[descriptions setValue:@"Locked and Loaded!" 	forKey:ACHIEVEMENT_DESTROYED_SUCCESSION_BRONZE];
		[descriptions setValue:@"Ready? Aim!" 			forKey:ACHIEVEMENT_DESTROYED_SUCCESSION_SILVER];
		[descriptions setValue:@"Smoke me a Kipper!" 	forKey:ACHIEVEMENT_DESTROYED_SUCCESSION_GOLD];
		
		[descriptions setValue:@"Red Alert!" 			forKey:ACHIEVEMENT_CASUALTIES_BRONZE];
		[descriptions setValue:@"Abandon Ship!" 		forKey:ACHIEVEMENT_CASUALTIES_SILVER];
		[descriptions setValue:@"The Horror!" 			forKey:ACHIEVEMENT_CASUALTIES_GOLD];
		
		[descriptions setValue:@"Space Junk" 			forKey:ACHIEVEMENT_ALL_DESTROYED_BRONZE];
		[descriptions setValue:@"Collision Cascade" 	forKey:ACHIEVEMENT_ALL_DESTROYED_SILVER];
		[descriptions setValue:@"Kessler Syndrome" 		forKey:ACHIEVEMENT_ALL_DESTROYED_GOLD];
		
		[descriptions setValue:@"Push it!" 				forKey:ACHIEVEMENT_NONE_DESTROYED_BRONZE];
		[descriptions setValue:@"Deflector Array!" 		forKey:ACHIEVEMENT_NONE_DESTROYED_SILVER];
		[descriptions setValue:@"Shock and Awe!" 		forKey:ACHIEVEMENT_NONE_DESTROYED_GOLD];
		
		[descriptions setValue:@"Always on Guard!" 		forKey:ACHIEVEMENT_TOTAL_DESTROYED_BRONZE];
		[descriptions setValue:@"Earth Command!" 		forKey:ACHIEVEMENT_TOTAL_DESTROYED_SILVER];
		[descriptions setValue:@"More Rocks Please!"	forKey:ACHIEVEMENT_TOTAL_DESTROYED_GOLD];
		
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(handleSharedScore:) 		
													 name:@"SharedScore" 
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(handleMissileExplosion:) 		
													 name:@"MissileExplosion" 
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(handleAsteroidExit:) 		
													 name:@"AsteroidExit" 
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(handleAsteroidDestroyed:) 	
													 name:@"AsteroidDestroyed" 
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(handleShuttleDestroyed:) 		
													 name:@"ShuttleExplosion" 
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(handleMoonDestroyed:)	
													 name:@"MoonShattered" 
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handleGameOver:) 			
													 name:@"GameOver" 
												   object:nil];
		
		
	}
	
	return self;
}

-(void)reset {
	
#if defined(DEBUG)	
	NSLog(@"Reset achievement dispenser");	
#endif
	
	waitingForAsteroidDestruction = NO;
	
	currentHumanCasualties = 0;
	currentAsteroidsExited = 0;
	currentAsteroidsDestroyed = 0;
	currentMissilesExploded = 0;
	currentAsteroidsDestroyedSuccession = 0;
	totalAsteroidsDestroyed = [[NSUserDefaults standardUserDefaults] integerForKey:@"TotalAsteroidsDestroyed"];
	
}

-(void)save {
	
	[[NSUserDefaults standardUserDefaults] setInteger:totalAsteroidsDestroyed forKey:@"TotalAsteroidsDestroyed"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
}

-(void)handleMissileExplosion:(NSNotification*)notification {
	
	currentMissilesExploded++;
		
	if (waitingForAsteroidDestruction) {
		currentAsteroidsDestroyedSuccession = 0;
	}
	
	waitingForAsteroidDestruction = YES;
}

-(void)handleAsteroidExit:(NSNotification*)notification {
	
	currentAsteroidsExited++;
	
}

-(void)handleAsteroidDestroyed:(NSNotification*)notification {
	
	if (waitingForAsteroidDestruction) {
		waitingForAsteroidDestruction = NO;
	}
	
	currentAsteroidsDestroyedSuccession++;
	currentAsteroidsDestroyed++;
	totalAsteroidsDestroyed++;
	
#if defined(DEBUG)	
	NSLog(@"Asteroids destroyed in succession: %i",currentAsteroidsDestroyedSuccession);	
#endif
	
	// check for asteroid destroyed in succession achievement
	if (currentAsteroidsDestroyedSuccession < ACHIEVEMENT_DESTROYED_SUCCESSION_BRONZE_AMOUNT) {
		return;
	}
	else if (currentAsteroidsDestroyedSuccession == ACHIEVEMENT_DESTROYED_SUCCESSION_BRONZE_AMOUNT) {
		[self dispense:ACHIEVEMENT_DESTROYED_SUCCESSION_BRONZE];
	}
	else if (currentAsteroidsDestroyedSuccession == ACHIEVEMENT_DESTROYED_SUCCESSION_SILVER_AMOUNT) {
		[self dispense:ACHIEVEMENT_DESTROYED_SUCCESSION_SILVER];
	}
	else if (currentAsteroidsDestroyedSuccession == ACHIEVEMENT_DESTROYED_SUCCESSION_GOLD_AMOUNT) {
		[self dispense:ACHIEVEMENT_DESTROYED_SUCCESSION_GOLD];
	}
}

-(void)handleShuttleDestroyed:(NSNotification*)notification {
	
	ShipActorBase* actor = (ShipActorBase*)[notification object];
	
	currentHumanCasualties += actor.passengers;
	
#if defined(DEBUG)	
	NSLog(@"Human casualties: %i",currentHumanCasualties);	
#endif
	
	if (currentHumanCasualties < ACHIEVEMENT_CASUALTIES_BRONZE_AMOUNT) {
		return;
	}
	else if((currentHumanCasualties >= ACHIEVEMENT_CASUALTIES_BRONZE_AMOUNT) && 
		    (currentHumanCasualties <  ACHIEVEMENT_CASUALTIES_SILVER_AMOUNT)){
		[self dispense:ACHIEVEMENT_CASUALTIES_BRONZE];
	}
	else if((currentHumanCasualties >= ACHIEVEMENT_CASUALTIES_SILVER_AMOUNT) && 
		    (currentHumanCasualties <  ACHIEVEMENT_CASUALTIES_GOLD_AMOUNT)){
		[self dispense:ACHIEVEMENT_CASUALTIES_SILVER];
	}
	else if (currentHumanCasualties >= ACHIEVEMENT_CASUALTIES_GOLD_AMOUNT) {
		[self dispense:ACHIEVEMENT_CASUALTIES_GOLD];
	}
}

-(void)handleMoonDestroyed:(NSNotification*)notification {
	[self dispense:ACHIEVEMENT_MOON_DESTROYED];
}

-(void)handleSharedScore:(NSNotification*)notification {
	[self dispense:ACHIEVEMENT_TWITTER_SHARE];
}

-(void)handleGameOver:(NSNotification*)notification {
	
	NSNumber* score = (NSNumber*)[notification object];
	uint survivors = score.unsignedIntValue;
	
	// if none destroyed, check for none destroyed achievement
	if (currentAsteroidsDestroyed==0) {
		if ((survivors >= ACHIEVEMENT_NONE_DESTROYED_BRONZE_SURVIVORS) && 
			(survivors < ACHIEVEMENT_NONE_DESTROYED_SILVER_SURVIVORS))  {
			[self dispense:ACHIEVEMENT_NONE_DESTROYED_BRONZE];		
		}
		else if ((survivors >= ACHIEVEMENT_NONE_DESTROYED_SILVER_SURVIVORS) && 
				(survivors < ACHIEVEMENT_NONE_DESTROYED_GOLD_SURVIVORS)) {
			[self dispense:ACHIEVEMENT_NONE_DESTROYED_SILVER];		
		}
		else if (survivors >= ACHIEVEMENT_NONE_DESTROYED_GOLD_SURVIVORS) {
			[self dispense:ACHIEVEMENT_NONE_DESTROYED_GOLD];		
		}
	}
	
	// check if no asteroids have left the scene, which means all asteroids have been destroyed
	if (currentAsteroidsExited==0) {
		if ((survivors >= ACHIEVEMENT_ALL_DESTROYED_BRONZE_SURVIVORS) && 
			(survivors < ACHIEVEMENT_ALL_DESTROYED_SILVER_SURVIVORS))  {
			[self dispense:ACHIEVEMENT_ALL_DESTROYED_BRONZE];		
		}
		else if ((survivors >= ACHIEVEMENT_ALL_DESTROYED_SILVER_SURVIVORS) && 
				 (survivors < ACHIEVEMENT_ALL_DESTROYED_GOLD_SURVIVORS)) {
			[self dispense:ACHIEVEMENT_ALL_DESTROYED_SILVER];		
		}
		else if (survivors >= ACHIEVEMENT_ALL_DESTROYED_GOLD_SURVIVORS) {
			[self dispense:ACHIEVEMENT_ALL_DESTROYED_GOLD];		
		}
	}
	
	// check if total of destroyed asteroids is enough
	float totalBronzePercentage = fminf(1.0, totalAsteroidsDestroyed / (float)ACHIEVEMENT_TOTAL_DESTROYED_BRONZE_AMOUNT);
	float totalSilverPercentage = fminf(1.0, totalAsteroidsDestroyed / (float)ACHIEVEMENT_TOTAL_DESTROYED_SILVER_AMOUNT);
	float totalGoldPercentage   = fminf(1.0, totalAsteroidsDestroyed / (float)ACHIEVEMENT_TOTAL_DESTROYED_GOLD_AMOUNT);
	
	
	[self dispense:ACHIEVEMENT_TOTAL_DESTROYED_BRONZE withProgress:totalBronzePercentage];		
	[self dispense:ACHIEVEMENT_TOTAL_DESTROYED_SILVER withProgress:totalSilverPercentage];		
	[self dispense:ACHIEVEMENT_TOTAL_DESTROYED_GOLD withProgress:totalGoldPercentage];
	
#if defined(DEBUG)
	NSLog(@"----------------------");
	NSLog(@"Total destroyed: %i",totalAsteroidsDestroyed);
	NSLog(@"Total exited: %i",currentAsteroidsExited);
	NSLog(@"Casualties this session: %i",currentHumanCasualties);
	NSLog(@"Destroyed this session: %i",currentAsteroidsDestroyed);
	NSLog(@"Survivors this session: %i",survivors);	
	NSLog(@"Total destroyed percentages: %f - %f -%f",totalBronzePercentage,totalSilverPercentage,totalGoldPercentage);
	NSLog(@"----------------------");
#endif
	
}

-(void)dispense:(NSString*)uid {
	[self dispense:uid withProgress:1.0];
}

-(void)dispense:(NSString*)uid withProgress:(float)progress {
	AchievementProgress* achievementProgress = [[AchievementProgress alloc] initWithUID:uid andProgress:progress];	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AchievementUnlocked" object:achievementProgress];
}

-(NSString*)getDescriptionForAchievement:(NSString *)uid {
	return [descriptions valueForKey:uid];
}


/*
 * Memory
 */
-(void)dealloc {
	
	[descriptions release];
	
	[super dealloc];
}



@end
