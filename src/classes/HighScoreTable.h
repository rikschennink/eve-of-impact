//
//  HighScoreTable.h
//  Eve of Impact
//
//  Created by Rik Schennink on 10/2/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "Control.h"
#import "HighScoreBoard.h"
#import "Button.h"

@interface HighScoreTable : Control {
	
}

-(void)updateHighScores:(HighScoreBoard*)board;

@end
