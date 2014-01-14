//
//  ApplicationModel.m
//  Eve of Impact
//
//  Created by Rik Schennink on 2/12/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "ApplicationModel.h"
#import "World.h"
#import "MoonActor.h"
#import "PlanetActor.h"
#import "SatelliteActor.h"
#import "AsteroidActor.h"
#import "NukeExplosionActor.h"
#import "MissileActor.h"
#import "ImpactActor.h"
#import "AI.h"
#import "Camera.h"
#import "HighScore.h"
#import "HighScoreBoard.h"
#import "MathAdditional.h"
#import "Prefs.h"
#import "Vector.h"
#import "AICommand.h"
#import "AIAction.h"
#import "ParticleManager.h"
#import "UserContext.h"
#import "ShieldActor.h"
#import "ShieldShockwaveActor.h"
#import "ShipActorBase.h"
#import "ShipActor.h"
#import "EscapePodShipActor.h"
#import "ShuttleExplosionActor.h"
#import "Score.h"
#import "Prompter.h"
#import "LaunchPlatform.h"

@implementation ApplicationModel

@synthesize camera,world,planet,shield,satellites,ticks,highScoreBoard,particleManager,userContext,action,state,score,tutorialStep,prompter,activeAsteroidCount;

-(id)init {
	
	if ((self = [super init])) {
		
		
		action = ACTION_NONE;
		state = STATE_TITLE;
		tutorialStep = 0;
		lastWarningScale = 0.0;
		
		score = [[Score alloc] init];
		
		launchPlatform = [[LaunchPlatform alloc] init];
		
		particleManager = [[ParticleManager alloc]init];
		
		camera = [[Camera alloc]init];
		
		highScoreBoard = [[HighScoreBoard alloc] init];
		
		satellites = [[NSMutableArray alloc]init];
		
		ai = [[AI alloc]initWithModel:self];
		
		prompter = [[Prompter alloc] initWithModel:self];
		
		// set world model
		world = [[World alloc] init];
		
		// define planet actor
		planet = [[PlanetActor alloc] initWithRadius:PLANET_RADIUS andMass:PLANET_MASS];
		[world addActorToQueue:planet];
		
		[self addMoon];
		
		// define shield
		shield = [[ShieldActor alloc] init];
		[world addActorToQueue:shield];
		[particleManager bindAsEmitter:shield];
		
		// set satellites
		[self addSatellites:3];
		
		
	}
	
	return self;
}


/*
 * Session related
 */
-(void)startSession {
	
	// setup session
	userContext = [[UserContext alloc]init];
	
	// load scores
	[highScoreBoard load];
}

-(void)prefillUsername:(NSString*)username {
	
	[userContext updateUsername:username];

}

-(void)setUsername:(NSString*)username {
	
	[userContext updateUsername:username];
	
	if (userContext.firstGameInitiated) {
		[self doStartTutorial];
	}
}

-(void)setHighScore {
	
	HighScore* highScore = [[HighScore alloc] initWithName:userContext.username andScore:score.points];
	
	// store this last score in session
	userContext.lastScorePoints = highScore.points;
	userContext.lastScoreRank = [highScoreBoard addHighScore:highScore];
	
	// highscores have been added, notify!
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HighScoreSet" object:highScore];
	
	// release
	[highScore release];
}




/*
 * Game state adjustments
 */
-(void)doShowTitle {
	
	// set to camera to left side of screen
	camera.offset = VectorMake(400, 80);
	ticks = 0;
	
	// wait for user input to start intro or start after x amount of milliseconds on it's own	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doStartDelayedIntro) object:nil];
	[self performSelector:@selector(doStartDelayedIntro) withObject:nil afterDelay:5.0];
	
	// notify controller of title view
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TitleStarted" object:self];
}

-(void)doStartDelayedIntro {
	[self doStartIntro];
}
	
-(void)doStartIntro {
	
	// we are now starting the intro
	state = STATE_INTRO;
	ticks = 0;
	
	// clear intro timer
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doStartDelayedIntro) object:nil];
	
	// notify controller of intro start
	[[NSNotificationCenter defaultCenter] postNotificationName:@"IntroStarted" object:self];
	
	// slowly move camera to show planet earth
	[camera moveTo:VectorMake(40, -80) withSpeed:1.0 notifyCompletionWith:@"IntroCompleted" notificationTreshold:48.0];
}

-(void)doShowStartMenu {
	
	// clear intro timer
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doStartDelayedIntro) object:nil];
	
	state = STATE_MENU_MAIN;
	ticks = 0;
	
	[camera moveTo:VectorMake(40, -80) withSpeed:4.0];
}

-(void)doStartTutorial {
	[self doResetTutorial];
	[prompter resetUserDefaults];
	state = STATE_TUTORIAL;
	ticks = 0;
}

-(void)doResetTutorial {
	tutorialStep = 0;
}

-(void)doNextTutorial {
	tutorialStep++;
}

-(void)doShowScores {
	
	state = STATE_HIGHSCORE_BOARD;
	ticks = 0;
	
	[camera moveTo:VectorMake(-90, 140) withSpeed:4.0];
	
}

-(void)doStartPlaying {
	
	// if this is the first time the app is opened show tutorial
	if (userContext.firstGame) {
		
		// set game started state to YES
		userContext.firstGameInitiated = YES;
		
		// request user to enter username
		if (!userContext.usernameSaved) {
			[userContext requestUsername];
			return;
		}
		
		// start tutorial
		[self doStartTutorial];
		return;
	}
	
	// reset ticks
	ticks = 0;

	[[NSNotificationCenter defaultCenter] postNotificationName:@"GameStarted" object:self];
	
	// reset score
	[launchPlatform reset];
	[score reset];
	
	// reset world objects
	[world flush];
	
	// add moon if it was destroyed
	[self addMoon];
	
	// move to center
	[camera moveTo:VectorMake(1, 1)];
		
	[self doResumePlaying];
}

-(void)doPause {
	if (!pregame) {
		state = STATE_MENU_PAUSE;
		[ai sleep];
	}
}

-(void)doResumePlaying {
	
	// set in game mode
	state = STATE_PLAYING;
	
	// start time and wake artificial inteligence
	[ai wake];
}

-(void)doReset {
	
	[self doShowStartMenu];
	
	// reset passed time
	ticks = 0;
	
	// reset score
	[launchPlatform reset];
	[score reset];
	
	// reset prompter system
	[prompter reset];
	
	// ai related
	[ai brainwash];
	[ai sleep];
	
	// reset world objects
	[particleManager clear];
	[world flush];
}

-(void)doResetAndPlay {
	[self doReset];
	[self doStartPlaying];
}

-(void)doShowGameOverMenu {
	
	// check if screen captured, if not, capture one now
	if (captureCountdown>0) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CaptureScreen" object:nil];
	}
	
	// reset ticks so we can count ticks in game over menu	
	state = STATE_MENU_GAMEOVER;
	ticks = 0;

}

-(void)update {
	
	// always update camera
	[camera update];
	
	// as long as the game is not paused
	if (state != STATE_MENU_PAUSE) {
		[world update];
		[particleManager update];
	}
	
	// if we are ingame do all sorts of other stuff
	if (state == STATE_PLAYING) {
		
		// have the AI do some thinking
		[ai think];
		
		// update score counter
		[score update];
		
		// update launchplatform
		[launchPlatform check:score.points];
		
		// update prompter
		[prompter check:ticks];
		
		// check for imminent impacts
		[self checkImpactImminent];
	}
	else if (state == STATE_GAMEOVER && captureCountdown > 0) {
		captureCountdown--;
		if (captureCountdown==0) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"CaptureScreen" object:nil];
		}
	}
	
	// increase game ticks
	ticks++;
}

-(void)evacuate {
	
	// set gameover state
	state = STATE_GAMEOVER;
	
	// set capture timer to random value
	captureCountdown = randomBetween(TICK_RATE * 6, TICK_RATE * 12);
	
	// reset ticks so we can count ticks in outro
	ticks = 0;
	
	// launch the final missile 
	[launchPlatform launchWith:score.points - launchPlatform.saved];
	
	// set highscore
	[self setHighScore];
	
	// disable shield
	[shield disable];
	
	// reset camera velocities
	[camera resetSeek];
	
	// move camera to final location
	[camera moveToCenter];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"GameOver" object:[NSNumber numberWithUnsignedInt:userContext.lastScorePoints]];
}

-(void)checkImpactImminent {
	
	activeAsteroidCount = 0;
	float tempWarningScale = 0.0;
	float warningScale = 0.0;
	float distanceSquared = 0.0;
	
	for (AsteroidActor* asteroid in world.asteroids) {
		
		if (![asteroid.state contains:STATE_LEAVING]) {
			activeAsteroidCount++;
		}
		
		if ([asteroid.state contains:STATE_WARNING] && ![shield willDeflectObjectWith:asteroid.mass]) {
			
			// get distance to center
			distanceSquared = getDistanceSquaredToPlanet(asteroid.position.x, asteroid.position.y) - ASTEROID_IMPACT_RANGE_SQUARED;
			
			if (distanceSquared < ASTEROID_IMPACT_DISTANCE_SQUARED) {
				tempWarningScale = 1.0 - easeLinear(distanceSquared, ASTEROID_IMPACT_DISTANCE_SQUARED);
			}
			
			if (tempWarningScale > warningScale) {
				warningScale = fmin(1.0,tempWarningScale);
			}
		}
	}
	
	if (warningScale > 0.0) {
		lastWarningScale = warningScale;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ImpactWarn" object:[NSNumber numberWithFloat:warningScale]];
	}
	else if (lastWarningScale > warningScale) {
		lastWarningScale = warningScale;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ImpactWarn" object:[NSNumber numberWithFloat:warningScale]];
	}
}


-(void)addMoon {
	
	for (ActorBase* actor in world.actors) {
		if ([actor isKindOfClass:[MoonActor class]]) {
			return;
		}
	}
	
#if defined(DEBUG)
	NSLog(@"Add moon!");
#endif
	
	MoonActor* moon = [[MoonActor alloc] initWithRadius:MOON_RADIUS andMass:MOON_MASS];
	[world addActorToQueue:moon];
	[moon release];	
}


-(void)addSatellites:(int)amount {
	
	float offset = 360.0 / amount;
	
	for (int i=0; i<amount; i++) {
		
		SatelliteActor* actor = [[SatelliteActor alloc] initWithOffset:i * offset];
		
		// add to world
		[world addActorToQueue:actor];
		
		// add to satellites reference array
		[satellites addObject:actor];
		
		// release
		[actor release];
	}
}

-(void)addPanicFrom:(Vector)position {
	
	[score slow:position];
}

-(void)doAIAction:(AIAction*)plan {
	
	for (uint i = 0; i<plan.count; i++) {
		
		AICommand command = plan.commands[i];
		
		AsteroidActor* asteroid = [[AsteroidActor alloc]initWithMass:command.mass andMaxVelocity:command.velocityMax];
		asteroid->position.x = command.position.x;
		asteroid->position.y = command.position.y;
		asteroid->velocity.x = command.velocity.x;
		asteroid->velocity.y = command.velocity.y;
		
		[particleManager bindAsEmitter:asteroid];
		
		[world addActorToQueue:asteroid];
		
		[asteroid release];
	}
	
}

-(void)addShuttle:(ShipActorBase*)shuttle {
	
	[particleManager bindAsEmitter:shuttle];
	
	[world addActorToQueue:shuttle];
	
}

-(void)addDebree:(NSArray*)debree {
	for (ActorBase<Emitter>* actor in debree) {
		[particleManager bindAsEmitter:actor];
		[world addActorToQueue:actor];
	}
}

-(void)addMissileAt:(Vector)position withTarget:(Vector)target andRecoil:(float)recoil {
	
	MissileActor* missile = [[MissileActor alloc] initWithOrigin:position target:target speed:MISSILE_VELOCITY andRecoil:recoil];
	
	[world addActorToQueue:missile];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"MissileLaunch" object:missile];
	
	[missile release];
}

-(void)addShuttleExplosionOf:(ShipActorBase*)shuttle {
	
	uint passengers = shuttle.passengers;
	
	// shake camera
	[camera shake];
	
	// scale of explosion
	float scale;
	uint pods;
	BOOL flash = YES;
	
	if ([shuttle isKindOfClass:[ShipActor class]]) {
		scale = 3.5;
		pods = randomBetween(3,7);
	}
	else {
		// escape pod
		pods = 0;
		scale = .75;
		flash = NO;
	}
	// launch escape pods
	if (pods > 0 && pods < passengers) {
		passengers-=pods;
		[self addEscapePods:pods fromShip:shuttle];
	}
	
	// explosion time
	ShuttleExplosionActor* explosion = [[ShuttleExplosionActor alloc] initWithScale:scale];
	explosion.flash = flash;
	explosion->position.x = shuttle.position.x;
	explosion->position.y = shuttle.position.y;
	
	[self addPanicFrom:explosion->position];
	
	[particleManager bindAsEmitter:explosion];
	[world addActorToQueue:explosion];
	[explosion release];
	
	// decrease score and correct launch platform
	[score decrease:shuttle.passengers];
	[launchPlatform correct:shuttle.passengers];
	
}

-(void)addEscapePods:(uint)pods fromShip:(ShipActorBase*)ship {
	
	EscapePodShipActor* pod;
	Vector origin;
	Vector target;
	
	for (uint i =0;i<pods;i++) {
		
		origin.x = ship.position.x + randomBetween(-15.0, 15.0);
		origin.y = ship.position.y + randomBetween(-15.0, 15.0);
		
		target.x = ship.target.x;
		target.y = ship.target.y;
		
		vectorRotateByDegrees(&target, randomBetween(-20.0, 20.0));
		
		//target.x = ship.target.x + randomBetween(-20.0, 20.0);
		//target.y = ship.target.y + randomBetween(-20.0, 20.0);
		
		pod = [[EscapePodShipActor alloc] initWithOrigin:origin target:target andPassengers:1];
		
		[particleManager bindAsEmitter:pod];
		[world addActorToQueue:pod];
		
		[pod release];
	}
}

-(void)addNuclearExplosionAt:(Vector)position {
	
	[camera shake];
	
	NukeExplosionActor* explosion = [[NukeExplosionActor alloc] init];
	
	explosion->position.x = position.x;
	explosion->position.y = position.y;
	
	[self addPanicFrom:explosion->position];
	
	[particleManager bindAsEmitter:explosion];
	
	[world addActorToQueue:explosion];
	
	[explosion release];
	
}

-(void)addShieldShockwave:(ShieldShockwaveActor*)shockwave {
	[particleManager bindAsEmitter:shockwave];
	[world addActorToQueue:shockwave];
}

-(void)handleImpact:(NSNotification*)notification {
	
	ImpactActor* actor = (ImpactActor*)[notification object];
	
	[world addActorToQueue:actor];
	
}



/*
 * Handle user tap at a specific position
 */
-(void)handle:(uint)type RequestAt:(Vector)actionPosition {
	
	// don't do anything unless we are IN_GAME
	if (state != STATE_PLAYING) {
		return;
	}
	
	bool touchingShield = getDistanceSquaredToPlanet(actionPosition.x,actionPosition.y) <= SHIELD_RANGE * SHIELD_RANGE;
	
	if (touchingShield && type == ACTION_HOLD) {
		[shield overloadStart];
	}
	else if (type == ACTION_RELEASE && [shield isOverloading]) {
		[shield overloadCancel];
	}
	else if (type == ACTION_TAP && !touchingShield) {
		
		NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
		
		// find near satellite
		SatelliteActor* satellite = [self getSatelliteNearestTo:actionPosition];
		
		// current date
		NSTimeInterval diff = now - satellite.lastFiredMissile;
		
		// set recoil, if to short interval than increase recoil, otherwise no recoil
		if (diff < SATELLITE_COOLDOWN) {
			[satellite increaseRecoil];
		}
		else {
			[satellite resetRecoil];
		}
		
		// fire missile
		[satellite fireMissile];
		
		// add missile model
		[self addMissileAt:satellite.position withTarget:actionPosition andRecoil:satellite.recoil];
		
	}
}

-(SatelliteActor*)getSatelliteNearestTo:(Vector)location {
	
	SatelliteActor* satellite;
	float satelliteDistance = 99999999;
	float distance = 0;
	
	// check if touching a satellite
	for (SatelliteActor* actor in satellites) {
		
		distance = getDistanceSquaredBetween(location.x, location.y, actor->position.x, actor->position.y);
		
		if (distance < satelliteDistance) {
			satelliteDistance = distance;
			satellite = actor;
		}
	}

	return satellite;
}




-(void)dealloc {
	
	[prompter release];	
	[score release];	
	[ai release];	
	[planet release];	
	[camera release];	
	[world release];	
	[particleManager release];
	[launchPlatform release];	
	[userContext release];
	[highScores release];
	
	
	[super dealloc];
}

@end
