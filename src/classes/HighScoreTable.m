//
//  Chart.m
//  Eve of Impact
//
//  Created by Rik Schennink on 10/2/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "HighScoreTable.h"
#import "HighScoreTableRow.h"
#import "HighScoreBoard.h"
#import "HighScore.h"
#import "Prefs.h"

@implementation HighScoreTable

-(void)updateHighScores:(HighScoreBoard*)board {
	
	[children removeAllObjects];
	
	HighScore* score;
	HighScoreTableRow* row;
	uint i;
	
	// fix problem where 10 items are stored in local highscore
	uint count = [board count] < LOCAL_HIGH_SCORE_MAX ? [board count] : LOCAL_HIGH_SCORE_MAX;
	
	for (i=0; i<count; i++) {
		
		score = [board getHighScoreAt:i];
		row = [[HighScoreTableRow alloc] initWithHighScore:score andIndex:i];
		
		[self addChild:row];
		
		[row release];
	}
	
	if (i < LOCAL_HIGH_SCORE_MAX) {
		
		uint defaultScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"DefaultScore"];
		NSString* defaultUsername = [[NSUserDefaults standardUserDefaults] stringForKey:@"DefaultUsername"];
		score = [[HighScore alloc] initWithName:defaultUsername andScore:defaultScore];
		
		while (i < LOCAL_HIGH_SCORE_MAX) {
			
			row = [[HighScoreTableRow alloc] initWithHighScore:score andIndex:i];
			[self addChild:row];
			[row release];
			
			i++;
		}
	}
}

-(void)setState:(uint)state withTicks:(uint)modelTicks {
	
	[super setState:state withTicks:modelTicks];
	
	enabled = (state == STATE_HIGHSCORE_BOARD);
	
}

-(void)draw:(CGRect)frame {
	
	if (!self.shouldDraw) {
		return;
	}
	
	// align to top right
	self.position = CGPointMake(frame.size.width * .5 - 10,frame.size.height * .5 - 10);
	
	
	[super draw:frame];
}

@end
