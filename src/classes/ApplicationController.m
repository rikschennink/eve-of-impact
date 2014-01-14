//
//  ApplicationController.m
//  Eve of Impact
//
//  Created by Rik Schennink on 2/12/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "ApplicationController.h"
#import "AIAction.h"
#import "ApplicationModel.h"
#import "ApplicationView.h"
#import "AsteroidActor.h"
#import "HighScoreBoard.h"
#import "InterfaceLayer.h"
#import "MissileActor.h"
#import "Prefs.h"
#import "ShipActorBase.h"
#import "ShieldShockwaveActor.h"
#import "GameCenterManager.h"
#import "HighScore.h"
#import "UserContext.h"
#import "AchievementDispenser.h"
#import "AchievementProgress.h"

@implementation ApplicationController

@synthesize running,gameCenterManager;


-(id)initWithModel:(ApplicationModel*)applicationModel andView:(ApplicationView*)applicationView {
	
	self = [super init];
	
	if (self) {
		
		// set model
		model = applicationModel;
		
		// set view
		view = applicationView;
		
		// set multitouch
		[self.view setMultipleTouchEnabled:YES];
		touchCount = 0;
		
		// init
		running = NO;
		achievementDispenser = [[AchievementDispenser alloc]init];
		
		
		// listen to notifications from view
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePlayCommand:) 			name:@"Play" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleExitCommand:) 			name:@"Exit" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePauseCommand:) 			name:@"Pause" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleResumeCommand:) 		name:@"Resume" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRetryCommand:) 			name:@"Retry" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScoresCommand:) 		name:@"Scores" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTutorialCommand:) 		name:@"Tutorial" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNextTutorialCommand:) 	name:@"NextTutorial" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUsernameEntered:) 		name:@"UsernameEntered" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUsernameEdit:) 			name:@"UsernameEdit" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleButtonTouched:) 		name:@"ButtonTouched" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleButtonFlicker:) 		name:@"ButtonFlicker" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOpenLeaderboards:) 		name:@"ScoresLeaderboards" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOpenAchievements:) 		name:@"ScoresAchievements" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShareScore:)		 	name:@"ShareScore" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScreenCaptured:) 		name:@"ScreenCaptured" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCaptureScreen:) 		name:@"CaptureScreen" object:nil];
		
		// input and highscore events
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEnterUsername:) 		name:@"EnterUsername" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUsernameChanged:)		name:@"UsernameChanged" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSessionLoaded:) 		name:@"SessionLoaded" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUpdateHighScores:) 		name:@"HighScoresUpdated" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleHighScoreSet:)	 		name:@"HighScoreSet" object:nil];
		
		
		// title and intro events
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTitleStarted:) 			name:@"TitleStarted" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleIntroStarted:) 			name:@"IntroStarted" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleIntroCompletedCommand:) name:@"IntroCompleted" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGameStarted:) 			name:@"GameStarted" object:nil];
		
		
		// listen to events from AI
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAIAction:) 				name:@"AIAction" object:nil];
		
		
		// listen to actor events
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMissileLaunch:) 		name:@"MissileLaunch" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMissileExplosion:) 		name:@"MissileExplosion" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShuttleExplosion:) 		name:@"ShuttleExplosion" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAsteroidWarn:) 			name:@"AsteroidWarn" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleImpactWarn:) 			name:@"ImpactWarn" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAsteroidShattered:) 	name:@"AsteroidShattered" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAsteroidImpact:) 		name:@"AsteroidImpact" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEarthImpact:) 			name:@"EarthImpacted" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMoonImpact:) 			name:@"MoonImpacted" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShuttleLaunch:) 		name:@"ShipLaunch" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShockwaveReleased:) 	name:@"ShieldShockwaveReleased" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMoonShattered:) 		name:@"MoonShattered" object:nil];
		
		
		
		// GC
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAchievementUnlocked:)	name:@"AchievementUnlocked" object:nil];
		
		
	}
	
    return self;
}




/*
 * input events
 */
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	
	touchCount -= [touches count];
	
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event	{
	
	touchCount += [touches count];
		
	if (touchCount==1) {
		[view touchesBegan:touches withEvent:event];
	}
	else if (model.state == STATE_PLAYING) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"Pause" object:nil];
	}
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[view touchesMoved:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	// touching stopped
	touchCount -= [touches count];
		
	// pass 
	[view touchesEnded:touches withEvent:event];
}






/*
 * state changes
 */
-(void)start {
	
#if defined(DEBUG)
	NSLog(@"start/resume game loop");
#endif
	
	// start running if not running already
	if (!running) {
		
		// login to gamecenter
		[self connectToGameCenter];
		
		// restore screenshot if available
		if (model.state == STATE_GAMEOVER || model.state == STATE_MENU_GAMEOVER) {
			[self restoreScreenshot];
		}
		
		// resume or start a new session
		if (!model.userContext) {
			[model startSession];
		}
		else {
			[model.userContext load];
		}
		
		// if fresh boot start from title screen
		if (model.state == STATE_TITLE) {
			[model doShowTitle];
		}
		
		// running!
		running = YES;
		
		// start loop
		[self performSelectorOnMainThread:@selector(loop) withObject:nil waitUntilDone:NO];
		
		[view doResume];
	}
}

-(void)pause {
	
#if defined(DEBUG)
	NSLog(@"pause game loop");
#endif
	
	// save data
	[model.userContext save];
	
	// save achievement progress
	[achievementDispenser save];
	
	// save screenshot if available
	if (model.state == STATE_GAMEOVER || model.state == STATE_MENU_GAMEOVER) {
		[self cacheScreenshot];
	}
	
	// stop running
	running = NO;
	[view doHalt];
	
	if (model.state == STATE_PLAYING) {
		[model doPause];
	}
}

-(void)stop {
		
#if defined(DEBUG)
	NSLog(@"stop game loop");
#endif
	
	[self pause];
	
	// store model
	
}

-(void)loop {
	
	const int TICKS_PER_SECOND = 25;
	const int MAX_FRAMESKIP = 5;
	const float SKIP_TICKS = 1.0 / TICKS_PER_SECOND;
	
	uint loops;
	float interpolation = 1.0;
	CFTimeInterval nextModelUpdate = CFAbsoluteTimeGetCurrent();
	
	while(running) {
		
		loops = 0;
		
		// catch events
		while(CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.002, TRUE) == kCFRunLoopRunHandledSource);
		
		// check if model should be updated
		while (CFAbsoluteTimeGetCurrent() > nextModelUpdate && loops < MAX_FRAMESKIP) {
			
			// update the model
			[model update];
			 
			nextModelUpdate += SKIP_TICKS;
			loops++;
		}
		
		// interpolate a new position only if not paused (in pause mode this will cause some jittering)
		if (model.state != STATE_MENU_PAUSE) {
			interpolation = (CFAbsoluteTimeGetCurrent() + SKIP_TICKS - nextModelUpdate) / SKIP_TICKS;
		}
		
		// draw the scene
		[view draw:interpolation];
	}
}




/*
 * game center
 */
-(void)connectToGameCenter {
		
	// check if gamecenter supported
	if ([GameCenterManager isGameCenterAvailable]) {
	
#if defined(DEBUG)
		NSLog(@"connected to game center");
#endif
		
		self.gameCenterManager = [[[GameCenterManager alloc] init] autorelease];
        [self.gameCenterManager setDelegate:self];
        [self.gameCenterManager authenticateLocalUser];
	}
	else {
		
#if defined(DEBUG)
		NSLog(@"no game center support");
#endif
		
	}
}

-(void)processGameCenterAuth:(NSError*)error {
	
#if defined(DEBUG)
	NSLog(@"game center auth result");
	
	if (error == nil) {
		
		//[TestFlight passCheckpoint:@"Using game center"];
		
		NSLog(@"authenticated: %@",[self.gameCenterManager authenticatedAlias]);
		
		//[self.gameCenterManager populateAchievementDescriptions];

	}
	else {
		
		NSLog(@"error");
	}
#endif

}

-(void)reportScore:(uint)points {
	
#if defined(DEBUG)
	
	int rounded = points / 10000.0;
		rounded*=10000;
	
	//[TestFlight passCheckpoint:[NSString stringWithFormat:@"Report score: %i",rounded]];
	
#endif
	
	[self.gameCenterManager getLeaderBoardRankingForScore:points withRange:GLOBAL_HIGH_SCORE_MAX];
	
	[self.gameCenterManager reportScore:points forCategory:LEADER_BOARD_UID];	
	
}

-(void)scoreReported:(NSError*)error {
	
#if defined(DEBUG)
	NSLog(@"score reported");
#endif
	
}

-(void)rankDetermined:(NSNumber *)rank error: (NSError*) error {
		
#if defined(DEBUG)
	NSLog(@"ranking: %i",rank.unsignedIntValue);
#endif
	
	[view.interface updateGlobalRank:rank.unsignedIntValue];
}

-(void)handleOpenLeaderboards:(NSNotification*)notification {
	
	GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
	
	if (leaderboardController != NULL) {
		leaderboardController.category = LEADER_BOARD_UID;
		leaderboardController.timeScope = GKLeaderboardTimeScopeWeek;
		leaderboardController.leaderboardDelegate = self;
		[self presentModalViewController:leaderboardController animated:YES];
	}

}

-(void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController*)viewController {
	
	[self dismissModalViewControllerAnimated: YES];
	[viewController release];
}

-(void)achievementSubmitted:(GKAchievement *)ach error:(NSError *)error {
	
#if defined(DEBUG)
	NSLog(@"achievement submitted");
#endif
	
	if((error == NULL) && (ach != NULL))
    {
#if defined(DEBUG)
		NSLog(@"achievement percentage complete: %f",ach.percentComplete);
		NSLog(@"achievement description: %@",[achievementDispenser getDescriptionForAchievement:ach.identifier]);	
#endif
		
        if (ach.percentComplete >= 100.0) {	
			
#if defined(DEBUG)
		NSLog(@"achievement unlocked");
#endif
						
			// update achievement description
			[view.interface setAchievementUnlockedDescription:[achievementDispenser getDescriptionForAchievement:ach.identifier]];
		
		}
	}
	else {
		
#if defined(DEBUG)
		NSLog(@"error");
#endif
		
	}
}

-(void)handleOpenAchievements:(NSNotification*)notification {
	
	GKAchievementViewController *achievements = [[GKAchievementViewController alloc] init];
	if (achievements != NULL)
	{
		achievements.achievementDelegate = self;
		[self presentModalViewController: achievements animated: YES];
	}
}

-(void)achievementViewControllerDidFinish:(GKAchievementViewController*)viewController {
	
	[self dismissModalViewControllerAnimated: YES];
	[viewController release];
}

-(void)handleAchievementUnlocked:(NSNotification*)notification {
	
	AchievementProgress* achievementProgress = (AchievementProgress*)[notification object];
	
#if defined(DEBUG)
	NSLog(@"gamecenter go try unlock achievement! (not sure if unlocked already) %@",achievementProgress.uid);
#endif
	
	[self.gameCenterManager submitAchievement:achievementProgress.uid percentComplete:achievementProgress.progress * 100.0];	
}






/*
 * twitter
 */
-(void)handleCaptureScreen:(NSNotification*)notification {
	
	[view captureScreenshot];
	
}

-(void)handleScreenCaptured:(NSNotification*)notification {
	
#if defined(DEBUG)
	NSLog(@"capture screen");
#endif
	
	screenshot = (UIImage*)[notification object];
	
	
#if defined(DEBUG)
	NSLog(@"screen captured");
#endif
	
}

-(void)restoreScreenshot {
	
#if defined(DEBUG)
	NSLog(@"restore screen");
#endif
	
	// load from disk
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* documentsDirectory = [paths objectAtIndex:0];
	NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:TWITTER_PIC];
	screenshot = [UIImage imageWithContentsOfFile:fullPathToFile];
	[screenshot retain];
	
#if defined(DEBUG)
	NSLog(@"screen restored");
#endif
	
}

-(void)cacheScreenshot {
	
	
#if defined(DEBUG)
	NSLog(@"cache screenshot");
#endif
	
	// save to disk
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* documentsDirectory = [paths objectAtIndex:0];
	NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:TWITTER_PIC];
	[UIImagePNGRepresentation(screenshot) writeToFile:fullPathToFile atomically:YES];
	
	
#if defined(DEBUG)
	NSLog(@"screenshot cached");
#endif
	
	screenshot = nil;
}

-(void)handleShareScore:(NSNotification*)notification {
	
#if defined(DEBUG)
	//[TestFlight passCheckpoint:@"Opened Tweet"];
#endif
	
	// get points
	uint points = model.highScoreBoard.lastScore.points;
	
	// Set up the built-in twitter composition view controller.
    TWTweetComposeViewController *twitter = [[TWTweetComposeViewController alloc] init];
    
	// format the points 
	NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
	[formatter setGroupingSeparator:@"."];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
    // Set the initial tweet text. See the framework for additional properties that can be set.
	
#if defined(DEBUG)
	NSLog(@"shot: %@",screenshot);
#endif
	
	[twitter addImage:screenshot];
	//[twitter addURL:[NSURL URLWithString:[NSString stringWithString:TWITTER_URL]]];
	[twitter setInitialText:
	 		[NSString stringWithFormat:TWITTER_MESSAGE,
		 [formatter stringFromNumber:[NSNumber numberWithUnsignedInteger:points]]]];
    
	// formatter you are dismissed
	[formatter release];
	
    // Present the tweet composition view controller modally.
    [self presentModalViewController:twitter animated:YES];
	
    // Create the completion handler block.
    [twitter setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
        
        switch (result) {
            case TWTweetComposeViewControllerResultCancelled: 
				// The cancel button was tapped.
				
#if defined(DEBUG)
				//[TestFlight passCheckpoint:@"Tweet cancelled"];
#endif
                break;
            case TWTweetComposeViewControllerResultDone: 
				[self performSelectorOnMainThread:@selector(displayTwitterReponse:) withObject:@"Status posted" waitUntilDone:NO];
                break;
            default:
                break;
        }
        
        [self dismissModalViewControllerAnimated:YES];
    }];
    
}

-(void)displayTwitterReponse:(NSString*)text {
	
#if defined(DEBUG)
	//[TestFlight passCheckpoint:@"Tweet send"];
#endif
	
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SharedScore" object:nil];
	
	/*
	//UIAlertView* confirm = [[UIAlertView alloc] initWithTitle:@"Twitter" 
														message:text 
													   delegate:self 
											  cancelButtonTitle:@"Okay" 
											  otherButtonTitles:nil];
	//[confirm show];*/
}




/*
 * commands
 */
-(void)handleTitleStarted:(NSNotification*)notification {
	[view playMusicIntro];
}

-(void)handleIntroStarted:(NSNotification*)notification {}

-(void)handleIntroCompletedCommand:(NSNotification*)notification {
	[model doShowStartMenu];
}

-(void)handleGameStarted:(NSNotification*)notification {
	[view playMusicInGameStart];
}

-(void)handlePlayCommand:(NSNotification*)notification {

#if defined(DEBUG)
	//[TestFlight passCheckpoint:@"Command play"];
#endif
	
	[view.interface resetAchievementUnlockedDescription];
	
	[achievementDispenser reset];
	
	[model doStartPlaying];
}

-(void)handleExitCommand:(NSNotification*)notification {
	
#if defined(DEBUG)
	//[TestFlight passCheckpoint:@"Command exit"];
#endif
	
	[view stopMusic];
	[model doReset];
}

-(void)handlePauseCommand:(NSNotification*)notification {
	
#if defined(DEBUG)
	//[TestFlight passCheckpoint:@"Command pause"];
#endif
	
	
	[model doPause];
}

-(void)handleResumeCommand:(NSNotification*)notification {
	[model doResumePlaying];
}

-(void)handleRetryCommand:(NSNotification*)notification {
	
#if defined(DEBUG)
	//[TestFlight passCheckpoint:@"Command retry"];
#endif
	[view.interface resetAchievementUnlockedDescription];
	
	[achievementDispenser reset];
	
	[model doResetAndPlay];
}

-(void)handleTutorialCommand:(NSNotification*)notification {
	[model doStartTutorial];
}

-(void)handleNextTutorialCommand:(NSNotification*)notification {
	[model doNextTutorial];
}

-(void)handleScoresCommand:(NSNotification*)notification {
	[model doShowScores];
}

-(void)handleEnterUsername:(NSNotification*)notification {
	
	[view requestUsername];
	
}

-(void)handleUsernameEntered:(NSNotification*)notification {
	
	NSString* username = (NSString*)[notification object];
	
	[model setUsername:username];
	
}

-(void)handleUsernameEdit:(NSNotification*)notification {
	
	[view requestUsername];
	
}

-(void)handleUsernameChanged:(NSNotification*)notification {

	NSString* username = (NSString*)[notification object];
	
	[view.interface updateUsername:username];
}

-(void)handleSessionLoaded:(NSNotification*)notifcation {
	
	UserContext* userContext = (UserContext*)[notifcation object];
	
	[view.interface updateUsername:userContext.username];
}


/* button events */
-(void)handleHighScoreSet:(NSNotification*)notification {
	
	[view.interface updateHighScores];
	[view.interface updateLocalRank];
	
	HighScore* score = (HighScore*)[notification object];
	
	[self reportScore:score.points];
}

-(void)handleUpdateHighScores:(NSNotification*)notification {
	
	[view.interface updateHighScores];
}




/* button events */
-(void)handleButtonTouched:(NSNotification*)notification {
	Button* btn = (Button*)[notification object];
	[view playButtonPress:btn];
}

-(void)handleButtonFlicker:(NSNotification*)notification {
	Button* btn = (Button*)[notification object];
	[view playButtonFlicker:btn];
}


/*
 * AI
 */
-(void)handleAIAction:(NSNotification*)notification {
	[model doAIAction:(AIAction*)[notification object]];
}



/*
 * Actors
 */
-(void)handleMissileLaunch:(NSNotification*)notification {
	
	// get data from notification
	MissileActor* missile = (MissileActor*)[notification object];
	CGPoint location = CGPointMake(missile.target.x, missile.target.y);
	
	// play target locked sound at missile target
	[view playTargetLocked:location];
	
}

-(void)handleMissileExplosion:(NSNotification*)notification {
		
	MissileActor* actor = (MissileActor*)[notification object];
	
	[model addNuclearExplosionAt:actor.position];
}

-(void)handleShuttleLaunch:(NSNotification*)notification {
	
	ShipActorBase* actor = (ShipActorBase*)[notification object];
	
	[model addShuttle:actor];
}

-(void)handleShuttleExplosion:(NSNotification*)notification {
	
	ShipActorBase* actor = (ShipActorBase*)[notification object];
	
	[model addShuttleExplosionOf:actor];
}

-(void)handleMoonImpact:(NSNotification*)notification {}

-(void)handleMoonShattered:(NSNotification*)notification {
	
	NSArray* debree = (NSArray*)[notification object];
	[model addDebree:debree];
	
}

-(void)handleAsteroidWarn:(NSNotification*)notification {
	
	[view playWarning];
	
}

-(void)handleImpactWarn:(NSNotification*)notification {
	
	float musicScale = 1.0 - [(NSNumber*)[notification object] floatValue];
	
	[view fadeMusic:musicScale];
}

-(void)handleAsteroidShattered:(NSNotification*)notification {
	
	// collect debree and send to model
	NSArray* debree = (NSArray*)[notification object];
	[model addDebree:debree];
	
}

-(void)handleAsteroidImpact:(NSNotification*)notification {
	ActorBase* impact = (ActorBase*)[notification object];
	[model.world addActorToQueue:impact];
}

-(void)handleShockwaveReleased:(NSNotification*)notification {
	ShieldShockwaveActor* shockwave = (ShieldShockwaveActor*)[notification object];
	[model addShieldShockwave:shockwave];
}

-(void)handleEarthImpact:(NSNotification*)notification {
	if (model.state == STATE_PLAYING) {
				
		// launch final missile and set state to game over
		[model evacuate];
		
		// play engame music
		[view playMusicOutro];
		
	}
}




/*
 * Memory
 */
-(void)dealloc {
	 
	[self stop];
	
    [gameCenterManager release];
	
	[super dealloc];
}

@end
