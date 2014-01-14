//
//  Character.h
//  Eve of Impact
//
//  Created by Rik Schennink on 9/25/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Common.h"

@interface Character : NSObject {
	
	NSString* character;
	UVMap map;
	float width;
	float height;
	CGSize size;
	
}

@property (retain,readonly) NSString* character;
@property (readonly) UVMap map;
@property (readonly) float width;
@property (readonly) float height;
@property (readonly) CGSize size;

-(id)initWithCharacter:(NSString *)c width:(float)w height:(float)h size:(CGSize)s andMap:(UVMap)m;

@end
