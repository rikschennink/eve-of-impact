//
//  Menu.m
//  Eve of Impact
//
//  Created by Rik Schennink on 5/1/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "Menu.h"
#import "Common.h"
#import "Prefs.h"
#import "RenderEngine.h"
#import "Label.h"
#import "Advent.h"
#import "UserContext.h"

@implementation Menu

@synthesize user;

-(id)initWithModel:(ApplicationModel*)applicationModel {
	
	self = [super init];
	
	if (self) {
		
		model = applicationModel;
		
		// menu itself is not touchable
		touchable = NO;
		
		CGSize screenSize = [[RenderEngine singleton] getScreenSize];
		
		float titleScreenOffset = 20.0;
		
		if (IS_IPAD) {
			titleScreenOffset = 64.0;
		}
		
		// title screen
		QuadTemplate titleScreen = QuadTemplateMake(0, 0, 0, 248.0 * scale, 56.0 * scale, COLOR_INTERFACE, UVMapMake(8, 592, 248, 56));
		title = [[Clip alloc] init];
		[title addQuad:titleScreen];
//		title.position = CGPointMake(32, 260);
		title.position = CGPointMake((screenSize.width - titleScreen.width) * .5,(screenSize.height * .5) + titleScreenOffset);
		
		// 320 - 248 = 72 / 2
		// 768 - 248 = 420 / 2
		
		// author line
		QuadTemplate authorClip = QuadTemplateMake(0, 0, 0, 88.0 * scale, 16.0 * scale, COLOR_INTERFACE, UVMapMake(264, 592, 88, 16));
		author = [[Clip alloc] init];
		[author addQuad:authorClip];
//		author.position = CGPointMake(193, 248);
		author.position = CGPointMake(title.position.x + (161.0 * scale), title.position.y - (12.0 * scale));
		
		// username label
		Advent* advent = [[Advent alloc]init];
		user = [[Label alloc] initWithFont:advent];
		[user setColor:COLOR_INTERFACE];
		if (!SCREENSHOT_MODE) {
			[self addChild:user];
		}
		
		// define label for user name
		labelUsername = QuadTemplateMake(0, 0, 0, 88.0 * scale, 16.0 * scale, COLOR_INTERFACE,  UVMapMake(8, 344, 88, 16));
		
		// instantiate buttons and add the to self
		resume = [[Button alloc] initWithLabel: UVMapMake(72,368,64,16)];
		resume.touchEvent = @"Resume";
		
		exit = [[Button alloc] initWithLabel: UVMapMake(136,384,64,16)];
		exit.touchEvent = @"Exit";
		
		play = [[Button alloc] initWithLabel: UVMapMake(8,368,64,16)];
		play.touchEvent = @"Play";
		
		retry = [[Button alloc] initWithLabel: UVMapMake(72,384,64,16)];
		retry.touchEvent = @"Retry";
		
		scores = [[Button alloc] initWithLabel: UVMapMake(200,384,64,16)];
		scores.touchEvent = @"Scores";
		
		tutorial = [[Button alloc] initWithLabel: UVMapMake(8,384,64,16)];
		tutorial.touchEvent = @"Tutorial";
		
		leaderboards = [[Button alloc] initWithLabel: UVMapMake(72,216,64,16)];
		leaderboards.touchEvent = @"ScoresLeaderboards";
		
		achievements = [[Button alloc] initWithLabel: UVMapMake(136,216,64,16)];
		achievements.touchEvent = @"ScoresAchievements";
		
		share = [[Button alloc] initWithLabel: UVMapMake(200,216,64,16)];
		share.touchEvent = @"ShareScore";
		
		edit = [[Button alloc] initWithLabel: UVMapMake(200,368,64,16)];
		edit.touchEvent = @"UsernameEdit";
		edit.orientation = BUTTON_ORIENTATION_RIGHT;
		
		[self addChild:title];
		[self addChild:author];
		[self addChild:play];
		[self addChild:tutorial];
		[self addChild:resume];
		[self addChild:retry];
		[self addChild:scores];
		[self addChild:exit];
		[self addChild:edit];
		[self addChild:leaderboards];
		[self addChild:achievements];
		[self addChild:share];
		
		
		slotA = 0;
		slotB = resume.size.height + (BUTTON_MARGIN * scale);
		slotC = slotB + resume.size.height + (BUTTON_MARGIN * scale);
		
		// set resume position
		resume.position = CGPointMake(0,slotA);
		
		// set play position
		play.position = CGPointMake(resume.position.x, slotA);
		
		// set exit position
		exit.position = CGPointMake(resume.position.x, slotB);
		
		// set boards position
		leaderboards.position = CGPointMake(resume.position.x, slotB);
		
		// set tutorial position
		tutorial.position = CGPointMake(resume.position.x, slotB);
		
		// set scores position
		scores.position = CGPointMake(resume.position.x, slotC);
		
		// set achievement position
		achievements.position = CGPointMake(resume.position.x, slotC);
		
		// set retry position
		retry.position = CGPointMake(resume.position.x, slotB);
		
		// set edit position
		edit.position = CGPointMake(resume.position.x, slotA);
		
		// set share position
		share.position = CGPointMake(resume.position.x, slotC);
		
		// enable menu
		enabled = YES;
	}
	
	return self;
}

-(void)setState:(uint)state withTicks:(uint)modelTicks {
	
	// enable buttons that match current state
	switch (state) {
		case STATE_TITLE:
			
			title.enabled = modelTicks > 60;
			author.enabled = modelTicks > 80;
			user.enabled = NO;
			
			play.enabled = NO;
			resume.enabled = NO;
			exit.enabled = NO;
			scores.enabled = NO;
			retry.enabled = NO;
			edit.enabled = NO;
			tutorial.enabled = NO;
			leaderboards.enabled = NO;
			achievements.enabled = NO;
			share.enabled = NO;
			
			break;
		case STATE_INTRO:
			
			title.enabled = YES;
			author.enabled = YES;
			user.enabled = NO;
			
			play.enabled = NO;
			resume.enabled = NO;
			exit.enabled = NO;
			scores.enabled = NO;
			retry.enabled = NO;
			edit.enabled = NO;
			tutorial.enabled = NO;
			leaderboards.enabled = NO;
			achievements.enabled = NO;
			share.enabled = NO;

			break;
		case STATE_TUTORIAL:
		case STATE_PLAYING:
			
			title.enabled = NO;
			author.enabled = NO;
			user.enabled = NO;
			play.enabled = NO;
			resume.enabled = NO;
			exit.enabled = NO;
			scores.enabled = NO;
			retry.enabled = NO;
			edit.enabled = NO;
			tutorial.enabled = NO;
			leaderboards.enabled = NO;
			achievements.enabled = NO;
			share.enabled = NO;
			
			break;
		case STATE_MENU_PAUSE:
			
			title.enabled = NO;
			author.enabled = NO;
			user.enabled = YES;
			
			play.enabled = NO;
			scores.enabled = NO;
			retry.enabled = NO;
			resume.enabled = YES;
			exit.enabled = YES;
			edit.enabled = YES;
			tutorial.enabled = NO;
			leaderboards.enabled = NO;
			achievements.enabled = NO;
			share.enabled = NO;
			
			exit.position = CGPointMake(resume.position.x, slotB);
			
			break;
		case STATE_MENU_MAIN:
			
			title.enabled = YES;
			author.enabled = modelTicks < 60;
			user.enabled = YES;
			
			play.enabled = YES;
			retry.enabled = NO;
			resume.enabled = NO;
			exit.enabled = NO;
			edit.enabled = YES;
			scores.enabled = YES;
			tutorial.enabled = YES;
			leaderboards.enabled = NO;
			achievements.enabled = NO;
			share.enabled = NO;
			
			scores.position = CGPointMake(resume.position.x, slotC);
			
			if (model.userContext.firstGame) {
				scores.touchable = NO;
				tutorial.touchable = NO;
			}
			else {
				scores.touchable = YES;
				tutorial.touchable = YES;
			}
			
			break;
		case STATE_GAMEOVER:
			
			title.enabled = NO;
			author.enabled = NO;
			user.enabled = YES;
			play.enabled = NO;
			resume.enabled = NO;
			exit.enabled = NO;
			scores.enabled = NO;
			retry.enabled = NO;
			edit.enabled = NO;
			tutorial.enabled = NO;
			leaderboards.enabled = NO;
			achievements.enabled = NO;
			share.enabled = NO;
			
			break;
		case STATE_MENU_GAMEOVER:
			
			title.enabled = NO;
			author.enabled = NO;
			user.enabled = YES;
			
			play.enabled = NO;
			scores.enabled = NO;
			retry.enabled = YES;
			resume.enabled = NO;
			exit.enabled = YES;
			edit.enabled = NO;
			tutorial.enabled = NO;
			
			share.enabled = [TWTweetComposeViewController canSendTweet];
			
			exit.position = CGPointMake(resume.position.x, slotA);
			
			break;
		case STATE_HIGHSCORE_BOARD:
			
			title.enabled = NO;
			author.enabled = NO;
			user.enabled = NO;
			
			play.enabled = NO;
			scores.enabled = NO;
			retry.enabled = NO;
			resume.enabled = NO;
			exit.enabled = YES;
			edit.enabled = NO;
			tutorial.enabled = NO;
			leaderboards.enabled = YES;
			achievements.enabled = YES;
			share.enabled = NO;
			
			exit.position = CGPointMake(resume.position.x, slotA);
			
			break;
		default:
			break;
	}
}

-(void)draw:(CGRect)frame {
	
	if (!self.shouldDraw) {
		return;
	}
		
	// position menu to bottom left
	self.position = CGPointMake(-frame.size.width * .5,-frame.size.height * .5);
	
	if (user.enabled) {
		
		user.position = CGPointMake(frame.size.width - user.size.width - (24.0 * scale),frame.size.height - user.size.height - (26.0 * scale));
		
		labelUsername.x = -self.position.x - labelUsername.width - (5.0 * scale);
		labelUsername.y = -self.position.y - labelUsername.height - (11.0 * scale);
		labelUsername.color = COLOR_INTERFACE;
		labelUsername.color.a *= user.flicker;
		if (!SCREENSHOT_MODE) {
			[[RenderEngine singleton] addQuad:&labelUsername];
		}
		
		if (edit.enabled) { // user has to be enabled for edit to be enabled
			edit.position = CGPointMake(frame.size.width - edit.size.width - (4.0 * scale),frame.size.height - edit.size.height - (64.0 * scale));
		}
	}
	
	[super draw:frame];
}

-(void)dealloc {
	
	[play release];
	[resume release];
	[retry release];
	[exit release];
	[scores release];
	[edit release];
	[tutorial release];
	[user release];
	[title release];
	[author release];
	[share release];
	
	[super dealloc];
}


@end
