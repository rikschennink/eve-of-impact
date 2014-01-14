//
//  ApplicationModel.h
//  Eve of Impact
//
//  Created by Rik Schennink on 2/12/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "World.h"
#import "AIAction.h"

@class AIActionBase;
@class Camera;
@class AI;
@class SatelliteActor;
@class HighScoreBoard;
@class ParticleManager;
@class UserContext;
@class Score;
@class AsteroidActor;
@class MissileActor;
@class ShipActorBase;
@class ScoreManager;
@class ShieldShockwaveActor;
@class LaunchPlatform;
@class Prompter;

@interface ApplicationModel : NSObject {
	
	BOOL pregame;
	BOOL ingame;
	BOOL paused;
	BOOL postgame;
	
	BOOL playTapped;
	BOOL charingShieldShockwave;
	
	Camera* camera;
	
	AI* ai;
	World* world;
	PlanetActor* planet;
	ShieldActor* shield;
	NSMutableArray* satellites;
	ParticleManager* particleManager;
	LaunchPlatform* launchPlatform;
	Prompter* prompter;
	
	uint captureCountdown;
	uint ticks;
	uint state;
	uint action;
	uint alert;
	uint activeAsteroidCount;
	int alertCounter;
	float lastWarningScale;
	
	Score * score;
	UserContext* userContext;
	HighScoreBoard* highScores;
	//NSTimer* introTimer;
	//NSTimer* introDoneTimer;
}

@property (nonatomic,retain,readonly) Camera* camera;
@property (nonatomic,retain,readonly) World* world;
@property (nonatomic,retain,readonly) PlanetActor* planet;
@property (nonatomic,retain,readonly) ShieldActor* shield;
@property (nonatomic,retain,readonly) NSMutableArray* satellites;
@property (nonatomic,retain,readonly) HighScoreBoard* highScoreBoard;
@property (nonatomic,retain,readonly) ParticleManager* particleManager;
@property (nonatomic,retain,readonly) UserContext* userContext;
@property (nonatomic,retain,readonly) Score* score;
@property (nonatomic,retain,readonly) Prompter* prompter;
@property (readwrite) uint state;
@property (readonly) uint ticks;
@property (readonly) uint action;
@property (readonly) uint tutorialStep;
@property (readonly) uint activeAsteroidCount;

-(void)update;
-(void)checkImpactImminent;


// evacuate earth
-(void)evacuate;

// models
-(void)addPanicFrom:(Vector)position;
-(void)addMoon;
-(void)addSatellites:(int)amount;
-(void)addDebree:(NSArray*)debree;
-(void)addNuclearExplosionAt:(Vector)position;
-(void)addShuttleExplosionOf:(ShipActorBase*)shuttle;
-(void)addMissileAt:(Vector)position withTarget:(Vector)target andRecoil:(float)recoil;
-(void)addShuttle:(ShipActorBase*)shuttle;
-(void)addShieldShockwave:(ShieldShockwaveActor*)shockwave;
-(void)addEscapePods:(uint)pods fromShip:(ShipActorBase*)ship;
-(SatelliteActor*)getSatelliteNearestTo:(Vector)location;

// user input related
-(void)doShowTitle;
-(void)doStartDelayedIntro;//:(NSTimer*)timer;
-(void)doStartIntro;
-(void)doStartPlaying;
-(void)doPause;
-(void)doResumePlaying;
-(void)doReset;
-(void)doResetAndPlay;
-(void)doShowStartMenu;
-(void)doShowGameOverMenu;
-(void)doShowScores;
-(void)doResetTutorial;
-(void)doStartTutorial;
-(void)doNextTutorial;

// AI actions
-(void)doAIAction:(AIAction*)plan;

// event handling
-(void)handle:(uint)type RequestAt:(Vector)actionPosition;

// session related
-(void)prefillUsername:(NSString*)username;
-(void)setUsername:(NSString*)username;
-(void)setHighScore;
-(void)startSession;

@end
