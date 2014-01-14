//
//  Board.m
//  Eve of Impact
//
//  Created by Rik Schennink on 7/1/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "HighScoreBoard.h"
#import "HighScore.h"
#import "Prefs.h"

@implementation HighScoreBoard

@synthesize count,lastScore;

-(id)init {
	
	self = [super init];
	
	if (self) {
		
		count = 0;
				
	}
	
	return self;
}

-(void)load {
	
	// load scores
	NSData* savedHighScoresData = [[NSUserDefaults standardUserDefaults] objectForKey:@"highscores"];
	
	if (savedHighScoresData != nil) {
		
		NSArray* savedHighScores = [NSKeyedUnarchiver unarchiveObjectWithData:savedHighScoresData];
		
		if (savedHighScores != nil) {
			
			highScores = [[NSMutableArray alloc] initWithArray:savedHighScores];
			
		}
	}
	
	// if no highscores found, set empty array
	if (highScores == nil) {
		highScores = [[NSMutableArray alloc] init];
	}
	
	// set count
	count = [highScores count];
	
	// update highscore rankings
	[self updateRanking];
	
	// notify of loaded highscores
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HighScoresUpdated" object:nil];
}

-(HighScore*)getHighScoreAt:(uint)index {
	if (index < [highScores count]) {
		return (HighScore*)[highScores objectAtIndex:index];
	}
	return nil;
}

-(int)addHighScore:(HighScore*)highScore {
	
	// set last score reference
	lastScore = [[HighScore alloc] initWithName:highScore.name andScore:highScore.points];
	
	uint i;
	uint amount = [highScores count];
	int index = -1;
	
	// find index of highscore according to score
	for (i=0; i<amount; i++) {
		HighScore* storedHighScore = (HighScore*)[highScores objectAtIndex:i];
		if (highScore.points > storedHighScore.points) {
			index = i;
			break;
		}
	}
	
	// if list is not full yet and current scores have not been beat
	if (index == -1 && amount < LOCAL_HIGH_SCORE_MAX) {
		[highScores addObject:highScore];
		index = i;
	}
	
	// if index has been changed it means the score should be put on the board
	else if (index >= 0) {
		
		[highScores insertObject:highScore atIndex:index];
		
		if ([highScores count] > LOCAL_HIGH_SCORE_MAX) {
			[highScores removeLastObject];
		}
	}
	else {
		index = LOCAL_HIGH_SCORE_MAX;
	}
	
	// get amount of scores in the table
	count = [highScores count];
	
	// update highscore rankings
	[self updateRanking];
	
	// save highscores
	[self saveHighScores];
		
	return index;
}

-(void)saveHighScores {
	
	[highScores count];
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:highScores] forKey:@"highscores"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
}

-(void)updateRanking {
	
	uint amount = [highScores count];
	for (uint i=0; i<amount;i++) {
		((HighScore*)[highScores objectAtIndex:i]).index = i;
	}
	
}

- (void)dealloc {
	
	[highScores release];
	[lastScore release];
	
	[super dealloc];
	
}

@end