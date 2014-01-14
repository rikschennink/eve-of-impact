//
//  Score.h
//  Eve of Impact
//
//  Created by Rik Schennink on 12/11/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//


#import "Control.h"

@class ApplicationModel;


@interface ScoreCounter : Control {
	
	ApplicationModel* model;
	
	UVMap digits[10];
	UVMap panic[3];
	
	QuadTemplate digit;
	QuadTemplate dot;
	QuadTemplate row;
}

-(id)initWithModel:(ApplicationModel*)applicationModel;

@end
