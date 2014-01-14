//
//  Tutorial.h
//  Eve of Impact
//
//  Created by Rik Schennink on 4/28/11.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "Control.h"
#import "Button.h"
#import "ApplicationModel.h"
#import "TutorialStep.h"

@interface Tutorial : Control {
    
	ApplicationModel* model;
	
	Button* next;
	Button* exit;
	Button* play;
	
	NSMutableArray* steps;
	
	float altScale;
	
}

-(id)initWithModel:(ApplicationModel*)applicationModel;

-(void)addStep:(TutorialStep*)step;


@end
