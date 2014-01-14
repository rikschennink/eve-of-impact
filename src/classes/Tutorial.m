//
//  Tutorial.m
//  Eve of Impact
//
//  Created by Rik Schennink on 4/28/11.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "Tutorial.h"
#import "Prefs.h"
#import "Camera.h"
#import "ApplicationModel.h"
#import "RenderEngine.h"
#import "UserContext.h"
#import "TutorialStep.h"

@implementation Tutorial

-(id)initWithModel:(ApplicationModel*)applicationModel {
	
	if ((self = [super init])) {
		
		model = applicationModel;
		
		altScale = IS_IPAD ? 2.0 : 1.0;
		
		CGSize screenSize = [[RenderEngine singleton]getScreenSize];
		
		touchable = NO;
		
		next = [[Button alloc] initWithLabel: UVMapMake(136,368,64,16)];
		next.touchEvent = @"NextTutorial";
		next.orientation = BUTTON_ORIENTATION_RIGHT;
		[self addChild:next];
		
		exit = [[Button alloc] initWithLabel: UVMapMake(136,384,64,16)];
		exit.touchEvent = @"Exit";
		exit.orientation = BUTTON_ORIENTATION_LEFT;
		[self addChild:exit];
		
		play = [[Button alloc] initWithLabel: UVMapMake(8,368,64,16)];
		play.touchEvent = @"Play";
		play.orientation = BUTTON_ORIENTATION_LEFT;
		[self addChild:play];
		
		
		/* steps array */
		steps = [[NSMutableArray alloc] init];
		
		TutorialStep* stepScoreIntroduction = [[TutorialStep alloc] initWithGroupIndex:1];
		TutorialStep* stepScore = [[TutorialStep alloc] initWithGroupIndex:1];
		TutorialStep* stepStrategyIntroduction = [[TutorialStep alloc] initWithGroupIndex:2];
		TutorialStep* stepCollision = [[TutorialStep alloc] initWithGroupIndex:2];
		TutorialStep* stepTakeAction = [[TutorialStep alloc] initWithGroupIndex:2];
		TutorialStep* stepExplosion = [[TutorialStep alloc] initWithGroupIndex:2];
		TutorialStep* stepDeflected = [[TutorialStep alloc] initWithGroupIndex:2];
		TutorialStep* stepBalanceIntroduction = [[TutorialStep alloc] initWithGroupIndex:3];
		TutorialStep* stepBalance = [[TutorialStep alloc] initWithGroupIndex:3];
		TutorialStep* stepShieldIntroduction = [[TutorialStep alloc] initWithGroupIndex:4];
		TutorialStep* stepShield = [[TutorialStep alloc] initWithGroupIndex:4];
		TutorialStep* stepReady = [[TutorialStep alloc] initWithGroupIndex:5];
		
		
		/* offset helper */
		Vector offset,target;
		
		/* generic buidling blocks */	
		QuadTemplate labelPointer = QuadTemplateMake(0, 0, 0, 24.0 * scale, 24.0 * scale, COLOR_INTERFACE,  UVMapMake(296, 312, 24, 24));
		QuadTemplate conclusionFrame = QuadTemplateMake(screenSize.width - (304.0 * scale), screenSize.height - (150.0 * scale), 0, 288.0 * scale, 88.0 * scale, COLOR_INTERFACE,  UVMapMake(328, 216, 288, 88));
		QuadTemplate explosion = QuadTemplateMake(0, 0, 0, 32.0 * scale, 32.0 * scale, COLOR_INTERFACE,  UVMapMake(352, 368, 32, 32));
		
		
		/* score buidling blocks */	
		QuadTemplate scoreTitle = QuadTemplateMake(0, 0, 0, 224.0 * scale, 32.0 * scale, COLOR_INTERFACE,  UVMapMake(8, 984, 224, 32));
		QuadTemplate scoreIntroduction = QuadTemplateMake(0, 0, 0, 264 * scale, 48.0 * scale, COLOR_INTERFACE,  UVMapMake(368, 160, 264, 48));
		QuadTemplate scoreCurrent = QuadTemplateMake(0, 0, 0, 72.0 * scale, 32.0 * scale, COLOR_INTERFACE,  UVMapMake(432, 440, 72, 32));
		QuadTemplate labelScore = QuadTemplateMake(0, 0, 0, 136.0 * scale, 24.0 * scale, COLOR_INTERFACE,  UVMapMake(327, 985, 136, 24));
		QuadTemplate labelShip = QuadTemplateMake(0, 0, 0, 192.0 * scale, 18.0 * scale, COLOR_INTERFACE,  UVMapMake(327, 959, 192, 18));
		QuadTemplate pathShip = QuadTemplateMake(0, 0, 0, 104.0 * scale, 96.0 * scale, COLOR_INTERFACE,  UVMapMake(8, 656, 104, 96));
		
		
		/* strategy buidling blocks */	
		QuadTemplate strategyTitle = QuadTemplateMake(0, 0, 0, 224.0 * scale, 32.0 * scale, COLOR_INTERFACE,  UVMapMake(8, 952, 224, 32));
		QuadTemplate strategyIntroduction = QuadTemplateMake(0, 0, 0, 264.0 * scale, 48.0 * scale, COLOR_INTERFACE,  UVMapMake(368, 112, 264, 48));
		QuadTemplate labelAsteroid = QuadTemplateMake(0, 0, 0, 80.0 * scale, 24.0 * scale, COLOR_INTERFACE,  UVMapMake(8, 264, 80, 24));
		QuadTemplate labelExplosion = QuadTemplateMake(0, 0, 0, 88.0 * scale, 24.0 * scale, COLOR_INTERFACE,  UVMapMake(88, 264, 88, 24));
		QuadTemplate labelCollision = QuadTemplateMake(0, 0, 0, 80.0 * scale, 24.0 * scale, COLOR_INTERFACE,  UVMapMake(176, 264, 80, 24));
		QuadTemplate labelShockwave = QuadTemplateMake(0, 0, 0, 88.0 * scale, 24.0 * scale, COLOR_INTERFACE,  UVMapMake(88, 240, 88, 24));
		QuadTemplate labelTap = QuadTemplateMake(0, 0, 0, 40.0 * scale, 24.0 * scale, COLOR_INTERFACE,  UVMapMake(256, 264, 40, 24));
		QuadTemplate handTap = QuadTemplateMake(0, 0, 0, 56.0 * scale, 96.0 * scale, COLOR_INTERFACE,  UVMapMake(144, 408, 56, 96));
		QuadTemplate line = QuadTemplateMake(0, 0, 0, 8.0 * scale, 93.0 * scale, COLOR_INTERFACE,  UVMapMake(336, 408, 8, 93));
		QuadTemplate collisionPoint = QuadTemplateMake(0, 0, 0, 32.0 * scale, 32.0 * scale, COLOR_INTERFACE,  UVMapMake(296, 408, 32, 32));
		QuadTemplate asteroidPointer = QuadTemplateMake(0, 0, 0, 24.0 * scale, 24.0 * scale, COLOR_INTERFACE,  UVMapMake(320, 344, 24, 24));
		QuadTemplate shockwave = QuadTemplateMake(0, 0, 0, 56.0 * scale, 56.0 * scale, COLOR_INTERFACE,  UVMapMake(208, 408, 56, 56));

		
		/* balance building blocks */
		QuadTemplate balanceTitle = QuadTemplateMake(0, 0, 0, 224.0 * scale, 32.0 * scale, COLOR_INTERFACE,  UVMapMake(8, 888, 224, 32));
		QuadTemplate balanceIntroduction = QuadTemplateMake(0, 0, 0, 264.0 * scale, 48.0 * scale, COLOR_INTERFACE,  UVMapMake(368, 64, 264, 48));
		QuadTemplate panicIndicator = QuadTemplateMake(0, 0, 0, 40.0 * scale, 32.0 * scale, COLOR_INTERFACE,  UVMapMake(392, 440, 40, 32));
		QuadTemplate labelSpeedIndicator = QuadTemplateMake(0, 0, 0, 166.0 * scale, 22.0 * scale, COLOR_INTERFACE,  UVMapMake(327, 891, 166, 22));
		
		
		/* shield building blocks */
		QuadTemplate shieldTitle = QuadTemplateMake(0, 0, 0, 224.0 * scale, 32.0 * scale, COLOR_INTERFACE,  UVMapMake(8, 920, 224, 32));
		QuadTemplate shieldRing = QuadTemplateMake(0, 0, 0, 104.0 * altScale, 104.0 * altScale, COLOR_INTERFACE,  UVMapMake(200, 656, 104, 104));
		QuadTemplate shieldIntroduction = QuadTemplateMake(0, 0, 0, 264.0 * scale, 48.0 * scale, COLOR_INTERFACE,  UVMapMake(368, 16, 264, 48));
		QuadTemplate shieldLabel = QuadTemplateMake(0, 0, 0, 54.0 * scale, 18.0 * scale, COLOR_INTERFACE, UVMapMake(31, 243, 54, 18));
		QuadTemplate shieldLabelCharge = QuadTemplateMake(0, 0, 0, 156.0 * scale, 22.0 * scale, COLOR_INTERFACE, UVMapMake(327, 927, 156, 22));
		QuadTemplate shieldHandCharge = QuadTemplateMake(0,0,0,72.0 * scale,88.0 * scale,COLOR_INTERFACE,UVMapMake(120, 656, 72, 88));
		
		
		/* ready building blocks */
		QuadTemplate readyTitle = QuadTemplateMake(0, 0, 0, 224.0 * scale, 32.0 * scale, COLOR_INTERFACE,  UVMapMake(8, 856, 224, 32));
		
		
		
		/* score tutorial implementation */	
		[stepScore.title addQuad:scoreTitle];
		[stepScoreIntroduction.title addQuad:scoreTitle];
		
		
		
		//scoreCurrent.x = 120.0 * scale;
		scoreCurrent.x = (screenSize.width * .5)  - (40.0 * scale);
		scoreCurrent.y = 20.0 * scale;
		
		labelScore.x = scoreCurrent.x - (30.0 * scale);
		labelScore.y = scoreCurrent.y + (36.0 * scale);
		[stepScore.decorationFixed addQuad:labelScore];
		[stepScore.decorationFixed addQuad:scoreCurrent];
		[stepBalance.decorationFixed addQuad:scoreCurrent];
		
		if (IS_IPAD) {
			pathShip.x = -118.0 * scale;
			pathShip.y = 23.0 * scale;
		}
		else {
			pathShip.x = -114.0 * scale;
			pathShip.y = 16.0 * scale;
		}
		labelShip.x = pathShip.x + (24.0 * scale);
		labelShip.y = pathShip.y + (90.0 * scale);
		
		[stepScore.decoration addQuad:labelShip];
		[stepScore.decoration addQuad:pathShip];
		
		scoreIntroduction.x = conclusionFrame.x + (20.0 * scale);
		scoreIntroduction.y = conclusionFrame.y + (15.0 * scale);
		[stepScoreIntroduction.decorationFixed addQuad:conclusionFrame];
		[stepScoreIntroduction.decorationFixed addQuad:scoreIntroduction];
		
		[self addStep:stepScoreIntroduction];
		[self addStep:stepScore];
		
		
		
		
				
		/* strategy tutorial implementation */	
		//[stepAsteroidAppears.title addQuad:strategyTitle];
		[stepCollision.title addQuad:strategyTitle];
		[stepTakeAction.title addQuad:strategyTitle];
		[stepExplosion.title addQuad:strategyTitle];
		//[stepShockwave.title addQuad:strategyTitle];
		[stepDeflected.title addQuad:strategyTitle];
		[stepStrategyIntroduction.title addQuad:strategyTitle];
		
		offset = VectorMake(7.0 * scale, 40.0 * scale);
		
		if (IS_IPAD) {
			offset = VectorMake(4.0 * scale, 47.0 * scale);			
		}
		
		
		target = VectorMake(offset.x + (-80.0 * scale),offset.y + (128.0 * scale));
		
		
		
		
		// build steps
		asteroidPointer.x = offset.x + (-118.0 * scale);
		asteroidPointer.y = offset.y + (131.0 * scale);
		[stepTakeAction.decoration addQuad:asteroidPointer];
		[stepCollision.decoration addQuad:asteroidPointer];
		labelAsteroid.x = asteroidPointer.x - (74.0 * scale);
		labelAsteroid.y = asteroidPointer.y - (17.0 * scale);
		[stepTakeAction.decoration addQuad:labelAsteroid];
		[stepCollision.decoration addQuad:labelAsteroid];
		line.x = offset.x + (-160.0 * scale);
		line.y = offset.y + (275.0 * scale);
		line.rotation = 335;
		[stepTakeAction.decoration addQuad:line];
		[stepCollision.decoration addQuad:line];
		[stepExplosion.decoration addQuad:line];
		
		if (IS_IPAD) { // insert extra line piece
			line.x -= 38.0 * scale;
			line.y += 81.5 * scale;
			[stepTakeAction.decoration addQuad:line];
			[stepCollision.decoration addQuad:line];
			[stepExplosion.decoration addQuad:line];
			line.x += 38.0 * scale;
			line.y -= 81.5 * scale;
		}
		
		line.x += 38.0 * scale;
		line.y -= 81.5 * scale;
		[stepTakeAction.decoration addQuad:line];
		[stepCollision.decoration addQuad:line];
		[stepExplosion.decoration addQuad:line];
				
		
		line.x += 38.0 * scale;
		line.y -= 81.5 * scale;
		[stepCollision.decoration addQuad:line];
		[stepTakeAction.decoration addQuad:line];
		[stepExplosion.decoration addQuad:line];
		line.color.a = .35;
		[stepDeflected.decoration addQuad:line];
		line.color.a = 1.0;
		line.x += 38.0 * scale;
		line.y -= 81.5 * scale;
		[stepCollision.decoration addQuad:line];
		[stepTakeAction.decoration addQuad:line];
		[stepExplosion.decoration addQuad:line];
		line.color.a = .35;
		[stepDeflected.decoration addQuad:line];
		line.color.a = 1.0;
		collisionPoint.x = offset.x + (-40.0 * scale);
		collisionPoint.y = offset.y + (-31.0 * scale);
		[stepCollision.decoration addQuad:collisionPoint];
		[stepTakeAction.decoration addQuad:collisionPoint];
		[stepExplosion.decoration addQuad:collisionPoint];
		collisionPoint.color.a = .35;
		[stepDeflected.decoration addQuad:collisionPoint];
		collisionPoint.color.a = 1.0;
		labelPointer.x = collisionPoint.x + (13.0 * scale);
		labelPointer.y = collisionPoint.y + (14.0 * scale);
		labelCollision.x = labelPointer.x + (14.0 * scale);
		labelCollision.y = labelPointer.y + (14.0 * scale);
		[stepCollision.decoration addQuad:labelPointer];
		[stepCollision.decoration addQuad:labelCollision];
		
		
		
		
		
		handTap.x = offset.x + (-80.0 * scale);
		handTap.y = offset.y + (55.0 * scale);
		labelPointer.x = handTap.x + (10.0 * scale);
		labelPointer.y = handTap.y + (84.0 * scale);
		labelTap.x = labelPointer.x + (14.0 * scale);
		labelTap.y = labelPointer.y + (14.0 * scale);
		[stepTakeAction.decoration addQuad:handTap];
		[stepTakeAction.decoration addQuad:labelPointer];
		[stepTakeAction.decoration addQuad:labelTap];
		
		
		
		asteroidPointer.x = offset.x + (-111.0 * scale);
		asteroidPointer.y = offset.y + (116.0 * scale);
		[stepExplosion.decoration addQuad:asteroidPointer];
		labelAsteroid.x = asteroidPointer.x - (74.0 * scale);
		labelAsteroid.y = asteroidPointer.y - (17.0 * scale);
		[stepExplosion.decoration addQuad:labelAsteroid];
		explosion.x = target.x - (4.0 * scale);
		explosion.y = target.y - (4.0 * scale);
		[stepExplosion.decoration addQuad:explosion];
		labelPointer.x = offset.x + (-67.0 * scale);
		labelPointer.y = offset.y + (141.0 * scale);
		[stepExplosion.decoration addQuad:labelPointer];
		labelExplosion.x = labelPointer.x + (13.0 * scale);
		labelExplosion.y = labelPointer.y + (14.0 * scale);
		[stepExplosion.decoration addQuad:labelExplosion];
		
		
		
		labelPointer.x = target.x + (46.0 * scale);
		labelPointer.y = target.y + (46.0 * scale);
		[stepDeflected.decoration addQuad:labelPointer];
		labelShockwave.x = labelPointer.x + (14.0 * scale);
		labelShockwave.y = labelPointer.y + (14.0 * scale);
		[stepDeflected.decoration addQuad:labelShockwave];
		shockwave.x = offset.x + target.x + (35.0 * scale);
		shockwave.y = offset.y + target.y - (54.0 * scale);
		shockwave.rotation = 360;
		[stepDeflected.decoration addQuad:shockwave];
		shockwave.x -= (55.0 * scale);
		shockwave.rotation = 90;
		[stepDeflected.decoration addQuad:shockwave];
		shockwave.y += (55.0 * scale);
		shockwave.rotation = 180;
		[stepDeflected.decoration addQuad:shockwave];
		shockwave.x += (55.0 * scale);
		shockwave.rotation = 270;
		[stepDeflected.decoration addQuad:shockwave];
		//asteroidPointer.x = offset.x + -110.0;
		//asteroidPointer.y = offset.y + 117.0;
		//[stepDeflected.decoration addQuad:asteroidPointer];
		//labelAsteroid.x = asteroidPointer.x - 74;
		//labelAsteroid.y = asteroidPointer.y - 17;
		//[stepDeflected.decoration addQuad:labelAsteroid];
		
		
		
		line.x = offset.x + (-151.0 * scale);
		line.y = offset.y + (256.0 * scale);
		line.rotation = 335;
		[stepDeflected.decoration addQuad:line];
		
		if (IS_IPAD) { // insert extra line piece
			line.x -= 38.0 * scale;
			line.y += 81.5 * scale;
			[stepDeflected.decoration addQuad:line];
			line.x += 38.0 * scale;
			line.y -= 81.5 * scale;
		}
		

		line.x += (38.0 * scale);
		line.y -= (81.5 * scale);
		[stepDeflected.decoration addQuad:line];
		line.x = offset.x + (-91.0 * scale);
		line.y = offset.y + (93.0 * scale);
		line.rotation = 355;
		[stepDeflected.decoration addQuad:line];
		line.x += (7.75 * scale);
		line.y -= (89.0 * scale);
		[stepDeflected.decoration addQuad:line];
		line.x += (7.75 * scale);
		line.y -= (89.0 * scale);
		[stepDeflected.decoration addQuad:line];
		line.x += (7.75 * scale);
		line.y -= (89.0 * scale);
		[stepDeflected.decoration addQuad:line];
		line.x += (7.75 * scale);
		line.y -= (89.0 * scale);
		[stepDeflected.decoration addQuad:line];
		
		if (IS_IPAD) { 
			// append extra line piece
			line.x += (7.75 * scale);
			line.y -= (89.0 * scale);
			[stepDeflected.decoration addQuad:line];
		}
		

		asteroidPointer.x = offset.x + (-109.0 * scale);
		asteroidPointer.y = offset.y + (92.0 * scale);
		[stepDeflected.decoration addQuad:asteroidPointer];
		labelAsteroid.x = asteroidPointer.x - (74.0 * scale);
		labelAsteroid.y = asteroidPointer.y - (17.0 * scale);
		[stepDeflected.decoration addQuad:labelAsteroid];
		
		
		strategyIntroduction.x = conclusionFrame.x + (20.0 * scale);
		strategyIntroduction.y = conclusionFrame.y + (15.0 * scale);
		[stepStrategyIntroduction.decorationFixed addQuad:conclusionFrame];
		[stepStrategyIntroduction.decorationFixed addQuad:strategyIntroduction];
		
		
		[self addStep:stepStrategyIntroduction];
		//[self addStep:stepAsteroidAppears];
		[self addStep:stepCollision];
		[self addStep:stepTakeAction];
		[self addStep:stepExplosion];
		//[self addStep:stepShockwave];
		[self addStep:stepDeflected];
		
		
		
		
		
		
		offset = VectorMake(-75.0 * scale, 175.0 * scale);
		
		balanceIntroduction.x = conclusionFrame.x + (20.0 * scale);
		balanceIntroduction.y = conclusionFrame.y + (15.0 * scale);
		[stepBalanceIntroduction.decorationFixed addQuad:conclusionFrame];
		[stepBalanceIntroduction.decorationFixed addQuad:balanceIntroduction];
		
		[stepBalance.title addQuad:balanceTitle];
		[stepBalanceIntroduction.title addQuad:balanceTitle];
		
		panicIndicator.x = (screenSize.width * .5)  - (76.0 * scale);
		panicIndicator.y = scoreCurrent.y;
		[stepBalance.decorationFixed addQuad:panicIndicator];
		panicIndicator.color.a = .25;
		labelSpeedIndicator.x = panicIndicator.x - (58.0 * scale);
		labelSpeedIndicator.y = panicIndicator.y + (36.0 * scale);
		[stepBalance.decorationFixed addQuad:labelSpeedIndicator];
		
		[self addStep:stepBalanceIntroduction];
		[self addStep:stepBalance];

		
		
		
		
		[stepShield.title addQuad:shieldTitle];
		[stepShieldIntroduction.title addQuad:shieldTitle];
		
		shieldRing.x = -53.0 * altScale;
		shieldRing.y = -52.5 * altScale;
		[stepShield.decoration addQuad:shieldRing];
		
		shieldIntroduction.x = conclusionFrame.x + (20.0 * scale);
		shieldIntroduction.y = conclusionFrame.y + (15.0 * scale);
		[stepShieldIntroduction.decorationFixed addQuad:shieldIntroduction];
		[stepShieldIntroduction.decorationFixed addQuad:conclusionFrame];
		
		if (IS_IPAD) {
			labelPointer.x = 28.0 * altScale;
			labelPointer.y = 26.0 * altScale;
		}
		else {
			labelPointer.x = 25.0 * scale;
			labelPointer.y = 24.0 * scale;
		}
		shieldLabel.x = labelPointer.x + (17.0 * scale);
		shieldLabel.y = labelPointer.y + (17.0 * scale);
		[stepShield.decoration addQuad:labelPointer];
		[stepShield.decoration addQuad:shieldLabel];
		
		if (IS_IPAD) {
			shieldHandCharge.x = -94.0 * scale;
			shieldHandCharge.y = -108.0 * scale;
		}
		else {
			shieldHandCharge.x = -90.0 * scale;
			shieldHandCharge.y = -100.0 * scale;
		}
		
		shieldLabelCharge.x = shieldHandCharge.x - (50.0 * scale);
		shieldLabelCharge.y = shieldHandCharge.y - (22.0 * scale);
		[stepShield.decoration addQuad:shieldLabelCharge];
		[stepShield.decoration addQuad:shieldHandCharge];
		
		[self addStep:stepShieldIntroduction];
		[self addStep:stepShield];
		
		
		
		
		
		[stepReady.title addQuad:readyTitle];
		[self addStep:stepReady];
		
		
		
				

		
	}
	
	return self;
}








-(void)setState:(uint)state withTicks:(uint)modelTicks {
	
	[super setState:state withTicks:modelTicks];
	
	// enable if in tutorial state
	enabled = state == STATE_TUTORIAL;
	
	// check if enabled, than enable correct step and disable other steps
	if (!enabled) {
		return;
	}
	
	uint totalSteps = [steps count];
	
	if (model.tutorialStep <= totalSteps) {
		
		TutorialStep* step;
		
		// get previous step and disable
		uint lastStep;
		uint currentTutorialGroup;
		
		if (model.tutorialStep > 0) {
			lastStep = model.tutorialStep - 1;
			step = (TutorialStep*)[steps objectAtIndex:lastStep];
			currentTutorialGroup = step.group;
			step.enabled = NO;
			
		}
		else {
			lastStep = totalSteps - 1;
			step = (TutorialStep*)[steps objectAtIndex:lastStep];
			currentTutorialGroup = step.group;
			[step disable];
		}
		
		// get current step and enable
		step = (TutorialStep*)[steps objectAtIndex:model.tutorialStep];
		step.enabled = YES;
		
		// check if different group, if so, flicker title
		if (step.group != currentTutorialGroup) {
			currentTutorialGroup = step.group;
			
			// flicker step title
			[step setTitleAttention];
		}
		else {
			// show title immidiately
			[step showTitle];
			
			// hide tutorial label immidiately
		}
		
		// if last step disable next and show exit
		if (model.tutorialStep == totalSteps -1) {
			
			if (model.userContext.firstGame) {
				// user has now seen tutorial, show play button
				model.userContext.firstGame = NO;
				play.enabled = YES;
			}
			else {
				exit.enabled = YES;
			}
			next.enabled = NO;
		}
		else {
			play.enabled = NO;
			exit.enabled = NO;
			next.enabled = YES;
		}
	}

}

-(void)draw:(CGRect)frame {
	
	if (!self.shouldDraw) {
		return;
	}
	
	// position tutorial to bottom left
	self.position = CGPointMake(-frame.size.width * .5,-frame.size.height * .5);
	
	// set button position
	next.position = CGPointMake(frame.size.width - next.size.width - (4.0 * scale), 0);
	
	[super draw:frame];
}

-(void)addStep:(TutorialStep*)step {
	
	[self addChild:step];
	
	[steps addObject:step];
	
}

-(void)dealloc {
	
	[steps release];
	
	[super dealloc];
}

@end



