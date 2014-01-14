//
//  AchievementProgress.h
//  Eve of Impact
//
//  Created by Rik Schennink on 2/8/12.
//  Copyright (c) 2012 Rik Schennink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AchievementProgress : NSObject {
	NSString* uid;
	float progress;
}

@property (nonatomic,retain,readonly) NSString* uid;
@property (readonly) float progress;

-(id)initWithUID:(NSString*)achievementUID andProgress:(float)achievementProgress;

@end
