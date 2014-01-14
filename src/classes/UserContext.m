//
//  UserContext.m
//  Eve of Impact
//
//  Created by Rik Schennink on 9/4/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "UserContext.h"

@implementation UserContext

@synthesize username,usernameSaved,lastScorePoints,lastScoreRank,firstGameInitiated;

-(id)init {
	
	if (self = [super init]) {
		
		firstGameInitiated = NO;
		
		[self load];
	}
	
	return self;
}

-(void)load {
	
	firstGame = [[NSUserDefaults standardUserDefaults] boolForKey:@"FirstGame"];
	usernameSaved = [[NSUserDefaults standardUserDefaults] boolForKey:@"UsernameSaved"];
	username = [[NSUserDefaults standardUserDefaults] stringForKey:@"Username"];
	lastScorePoints = [[NSUserDefaults standardUserDefaults] integerForKey:@"LastScorePoints"];
	lastScoreRank = [[NSUserDefaults standardUserDefaults] integerForKey:@"LastScoreRank"];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SessionLoaded" object:self];
}

-(void)save {
	[[NSUserDefaults standardUserDefaults] setBool:firstGame forKey:@"FirstGame"];
	[[NSUserDefaults standardUserDefaults] setObject:username forKey:@"Username"];
	[[NSUserDefaults standardUserDefaults] setBool:usernameSaved forKey:@"UsernameSaved"];	
	[[NSUserDefaults standardUserDefaults] setInteger:lastScorePoints forKey:@"LastScorePoints"];
	[[NSUserDefaults standardUserDefaults] setInteger:lastScoreRank forKey:@"LastScoreRank"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL)firstGame {
	return firstGame;
}

-(void)setFirstGame:(BOOL)state {
	firstGame = state;
}

-(void)requestUsername {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"EnterUsername" object:nil];
}

-(void)updateUsername:(NSString*)newUsername {
	
	usernameSaved = YES;
	username = [[NSString alloc] initWithString:[newUsername uppercaseString]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"UsernameChanged" object:username];
}

-(void)dealloc {
	
	[username release];
	
	[super dealloc];
	
}
@end
