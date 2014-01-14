//
//  TutorialStep.h
//  Eve of Impact
//
//  Created by Rik Schennink on 9/28/11.
//  Copyright Rik Schennink. All rights reserved.
//

#import "Control.h"
#import "Clip.h"
#import "Label.h"

@interface TutorialStep : Control {
    
	uint group;
	
	Clip* decoration;
	Clip* decorationFixed;
	Clip* title;
	
	QuadTemplate header;
}

@property (readonly) Clip* decoration;
@property (readonly) Clip* decorationFixed;
@property (readonly) Clip* title;
@property (readonly) uint group;

-(id)initWithGroupIndex:(uint)index;
-(void)setTitleAttention;
-(void)showTitle;

@end
