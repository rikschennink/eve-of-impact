//
//  ResourceManager.m
//  Eve of Impact
//
//  Created by Rik Schennink on 3/31/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "ResourceManager.h"
#import "Resource.h"

@implementation ResourceManager

@synthesize resources;

static ResourceManager* _sharedResourceManager = nil;

+(ResourceManager*)sharedResourceManager {
	
	@synchronized([ResourceManager class]) {
		
		if (!_sharedResourceManager) {
			
			[[self alloc]init];
			
		}
		
		return _sharedResourceManager;
	}
	
	return nil;
}

+(id)alloc {
	
	@synchronized([ResourceManager class]) {
		
		NSAssert(_sharedResourceManager == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedResourceManager = [super alloc];
		return _sharedResourceManager;
	}
	
	return nil;
}

-(id)init {
	
	self = [super init];
	
	if (self != nil) {
		
		// set resources storage
		resources = [[NSMutableArray alloc]init];
		
	}
	
	return self;
}

-(void)addResource:(Resource*)resource {
	[resources addObject:resource];
}

-(void)addResources:(NSMutableArray*)suppliedResources {
	NSUInteger i,count = [suppliedResources count];
	for(i = 0;i<count;i++) {
		[self addResource:[suppliedResources objectAtIndex:i]];
	}
}

-(Resource*)getResourceByIdentifier:(NSString*)identifier {
	
	for(Resource* resource in resources) {
		if ([identifier isEqualToString:resource.identifier]) {
			return resource;
		}
	}
	
	return nil;
}


-(void)dealloc {
	
	[resources release];
	
	[super dealloc];
}

@end
