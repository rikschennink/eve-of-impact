//
//  Rank.m
//  Eve of Impact
//
//  Created by Rik Schennink on 10/9/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "Rank.h"
#import "Prefs.h"
#import "Advent.h"
#import "RenderEngine.h"

@implementation Rank

-(id)init {
	
	if ((self = [super init])) {
		
        rank = 0;
		
		touchable = NO;
        
		localDescriptionLabel = QuadTemplateMake(0, 0, 0, 121.0 * scale, 16.0 * scale, COLOR_INTERFACE,  UVMapMake(8, 328, 121, 16));
		globalDescriptionLabel = QuadTemplateMake(0, 0, 0, 128.0 * scale, 16.0 * scale, COLOR_INTERFACE,  UVMapMake(96, 296, 128, 16));
		scoreDescriptionLabel = QuadTemplateMake(0, 0, 0, 88.0 * scale, 16.0 * scale, COLOR_INTERFACE,  UVMapMake(8, 312, 88, 16));
		achievementsLabel = QuadTemplateMake(0, 0, 0, 80.0 * scale, 16.0 * scale, COLOR_INTERFACE,  UVMapMake(144, 312, 80, 16));
		
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		localRanking = [[Label alloc] initWithFont:[[[Advent alloc] init] autorelease]];
		globalRanking = [[Label alloc] initWithFont:[[[Advent alloc] init] autorelease]];
		achievements = [[Label alloc] initWithFont:[[[Advent alloc] init] autorelease]];
		achievements.text = @"";
		
		currentScore = [[Label alloc] initWithFont:[[[Advent alloc] init] autorelease]];
		currentScore.text = @"";
		
		
		[pool release];
		
		[self addChild:localRanking];
		[self addChild:globalRanking];
		[self addChild:achievements];
		[self addChild:currentScore];
		
	}
	
	return self;
	
}

-(void)setState:(uint)state withTicks:(uint)modelTicks {
	enabled = state == STATE_MENU_GAMEOVER || state == STATE_GAMEOVER;
	
	if (enabled) {
		currentScore.enabled = YES;
	}
}

-(void)setAchievementUnlockedDescription:(NSString*)description {
	
	achievements.enabled = YES;
	achievements.text = [description uppercaseString];
	
}

-(void)resetAchievementUnlockedDescription {
	
	achievements.enabled = NO;
	achievements.text = @"";
}

-(void)setLocal:(uint)ranking {
		
	localRanking.enabled = YES;
	
	if (ranking >= LOCAL_HIGH_SCORE_MAX) {
		localRanking.text = [NSString stringWithFormat:@"#10+"];
	}
	else {
		localRanking.text = [NSString stringWithFormat:@"#%i",ranking+1];
	}
}

-(void)setGlobal:(uint)ranking {
	
	globalRanking.enabled = YES;
	
	if (ranking >= GLOBAL_HIGH_SCORE_MAX) {
		globalRanking.text = [NSString stringWithFormat:@"#100+"];
	}
	else {
		globalRanking.text = [NSString stringWithFormat:@"#%i",ranking+1];
	}
}

-(void)setScore:(uint)score {
	
	// format the points 
	NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
	[formatter setGroupingSeparator:@"."];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	// add people part
	currentScore.text = [[formatter stringFromNumber:[NSNumber numberWithUnsignedInteger:score]] stringByAppendingString:@" PEOPLE"];
	
	// formatter you are dismissed
	[formatter release];
	
}

-(void)draw:(CGRect)frame {
	
	if (!self.shouldDraw) {
		return;
	}
	
	float right = frame.size.width * .5;
	float top = frame.size.height * .5;
	float offset = 64.0 * scale;
	float lineHeight = 52.0 * scale;
	
	scoreDescriptionLabel.x = right - scoreDescriptionLabel.width - (10.0 * scale);
	scoreDescriptionLabel.y = top - offset - (15.0 * scale);
	scoreDescriptionLabel.color = COLOR_INTERFACE;
	scoreDescriptionLabel.color.a *= currentScore.flicker;
	currentScore.position = CGPointMake(right - currentScore.size.width - (23.0 * scale), scoreDescriptionLabel.y - (18.0 * scale));
	[[RenderEngine singleton] addQuad:&scoreDescriptionLabel];
	
	
	if (achievements.enabled) {
		achievementsLabel.x = right - achievementsLabel.width - (10.0 * scale);
		achievementsLabel.y = scoreDescriptionLabel.y - lineHeight;
		achievementsLabel.color = COLOR_INTERFACE;
		achievementsLabel.color.a = achievements.flicker;
		achievements.position = CGPointMake(right - achievements.size.width - (25.0 * scale), achievementsLabel.y - (18.0 * scale));
		[[RenderEngine singleton] addQuad:&achievementsLabel];
		
		localDescriptionLabel.y = achievementsLabel.y - lineHeight;
	}
	else {
		localDescriptionLabel.y = scoreDescriptionLabel.y - lineHeight;
	}
	
	localDescriptionLabel.x = right - localDescriptionLabel.width - (10.0 * scale);
	localDescriptionLabel.color = COLOR_INTERFACE;
	localDescriptionLabel.color.a *= localRanking.flicker;
	localRanking.position = CGPointMake(right - localRanking.size.width - (25.0 * scale), localDescriptionLabel.y - (18.0 * scale));
	[[RenderEngine singleton] addQuad:&localDescriptionLabel];
	
	if (globalRanking.enabled) {
		globalDescriptionLabel.x = right - globalDescriptionLabel.width - (10.0 * scale);
		globalDescriptionLabel.y = localDescriptionLabel.y - lineHeight;
		globalDescriptionLabel.color = COLOR_INTERFACE;
		globalDescriptionLabel.color.a *= globalRanking.flicker;
		globalRanking.position = CGPointMake(right - globalRanking.size.width - (25.0 * scale), globalDescriptionLabel.y - (18.0 * scale));
		[[RenderEngine singleton] addQuad:&globalDescriptionLabel];
	}
	
	[super draw:frame];
}

-(void)dealloc {
	
	[localRanking release];
	[globalRanking release];
	[achievements release];
	[currentScore release];
	
	[super dealloc];
}

@end
