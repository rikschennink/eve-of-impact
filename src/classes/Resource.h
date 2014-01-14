//
//  Resource.h
//  Eve of Impact
//
//  Created by Rik Schennink on 3/31/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Resource : NSObject {
	
	NSString* identifier;
	
}

-(id)initWithIdentifier:(NSString*)identifierString;

@property (nonatomic,retain) NSString* identifier;

@end
