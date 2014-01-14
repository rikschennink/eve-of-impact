//
//  ResourceManager.h
//  Eve of Impact
//
//  Created by Rik Schennink on 3/31/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Resource;

@interface ResourceManager : NSObject {
	
	NSMutableArray* resources;
	
}

@property (nonatomic,readonly) NSMutableArray* resources;

+(ResourceManager*)sharedResourceManager;

-(void)addResource:(Resource*)resource;
-(void)addResources:(NSMutableArray*)suppliedResources;
-(Resource*)getResourceByIdentifier:(NSString*)identifier;

@end
