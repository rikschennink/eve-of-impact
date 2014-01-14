//
//  Board.h
//  Eve of Impact
//
//  Created by Rik Schennink on 7/1/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HighScore;

@interface HighScoreBoard : NSObject {
	
	NSMutableArray* highScores;
	uint count;
	HighScore* lastScore;
	
}

@property (readonly) uint count;
@property (nonatomic,readonly,retain) HighScore* lastScore;

-(HighScore*)getHighScoreAt:(uint)index;

-(void)load;

-(int)addHighScore:(HighScore*)highScore;

-(void)saveHighScores;

-(void)updateRanking;

@end
