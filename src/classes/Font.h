//
//  Font.h
//  Eve of Impact
//
//  Created by Rik Schennink on 9/25/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Character;

@interface Font : NSObject {
	
	
	NSMutableDictionary* characters;
	float space;
	
}

@property (readonly) float space;

-(void)addCharacter:(Character*)character;
-(Character*)characterAt:(NSString*)key;

@end
