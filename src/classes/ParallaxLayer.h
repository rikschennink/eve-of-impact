//
//  ParallaxLayer.h
//  Eve of Impact
//
//  Created by Rik Schennink on 4/12/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ApplicationModel;

@interface ParallaxLayer : NSObject {
	
	ApplicationModel* model;
	float scale;
	
}

-(id)initWithModel:(ApplicationModel*)applicationModel;
-(void)redraw:(float)interpolation;

@end
