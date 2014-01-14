//
//  HighScoreTableRow.h
//  Eve of Impact
//
//  Created by Rik Schennink on 10/4/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Control.h"
#import "Label.h"
#import "HighScore.h"

@interface HighScoreTableRow : Control {
	uint index;
	Label* username;
	QuadTemplate rank;
	QuadTemplate labelPeople;
	QuadBuffer peopleBuffer;
	QuadTemplate dot;
}

-(id)initWithHighScore:(HighScore*)score andIndex:(uint)index;

@end
