//
//  Rank.h
//  Eve of Impact
//
//  Created by Rik Schennink on 10/9/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "Control.h"
#import "Label.h"

@interface Rank : Control {

	uint rank;
	
	QuadTemplate scoreDescriptionLabel;
	QuadTemplate localDescriptionLabel;
	QuadTemplate globalDescriptionLabel;
	QuadTemplate achievementsLabel;
	
	Label* localRanking;
	Label* globalRanking;
	Label* achievements;
	Label* currentScore;
}

-(void)setLocal:(uint)ranking;
-(void)setGlobal:(uint)ranking;
-(void)setScore:(uint)score;
-(void)setAchievementUnlockedDescription:(NSString*)description;
-(void)resetAchievementUnlockedDescription;


@end
