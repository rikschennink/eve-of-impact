//
//  Prompter.h
//  Eve of Impact
//
//  Created by Rik Schennink on 7/3/11.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prefs.h"
#import "ApplicationModel.h"

@interface Prompter : NSObject {
	
	uint current;
	uint timeout;
	
	BOOL allPrompted;
	
	ApplicationModel* model;
	
}

@property (readonly) uint current;

-(id)initWithModel:(ApplicationModel*)applicationModel;

-(void)reset;
-(void)check:(uint)ticks;
-(BOOL)prompt:(uint)type;
-(BOOL)checkAllPrompted;
-(void)resetUserDefaults;

@end
