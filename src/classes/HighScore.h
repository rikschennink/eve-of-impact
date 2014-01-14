//
//  HighScore.h
//  Eve of Impact
//
//  Created by Rik Schennink on 7/1/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HighScore : NSObject {
	
	NSString* name;
	uint points;
	int index;
	
}

@property (nonatomic,retain) NSString* name;
@property (readonly) uint points;
@property (assign) int index;

-(id)initWithName:(NSString*)playerName andScore:(uint)playerPoints;

@end
