//
//  UserContext.h
//  Eve of Impact
//
//  Created by Rik Schennink on 9/4/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UserContext : NSObject {
	
	NSString* username;
	
	BOOL usernameSaved;
	BOOL firstGame;
	BOOL firstGameInitiated;
	
	uint lastScorePoints;
	int lastScoreRank;
}

-(void)load;
-(void)save;

-(BOOL)firstGame;
-(void)setFirstGame:(BOOL)state;

-(void)requestUsername;
-(void)updateUsername:(NSString*)newUsername;

@property (readonly) BOOL usernameSaved;
@property (readwrite) BOOL firstGameInitiated;
@property (readwrite) uint lastScorePoints;
@property (readwrite) int lastScoreRank;
@property (nonatomic,retain) NSString* username;

@end
