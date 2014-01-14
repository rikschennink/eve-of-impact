//
//  LaunchPlatform.h
//  Eve of Impact
//
//  Created by Rik Schennink on 6/25/11.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LaunchPlatform : NSObject {
	
	uint saved;
	uint next;
	
}

@property (readonly) uint saved;

-(void)reset;
-(void)correct:(uint)people;
-(void)check:(uint)people;
-(void)launchWith:(uint)people;

@end
