//
//  Clock.h
//  EarthDefense
//
//  Created by Rik & Wendy on 4/13/10.
//  Copyright 2010 Pico Pigeon. All rights reserved.
//

#import "Control.h"

@class ApplicationModel;
@class Button;

@interface Clock : Control {
	
	ApplicationModel* model;
	
	UVMap digits[10];
	float digitWidth;
	
	uint years[3];
	uint days[3];
	
	QuadTemplate digit;
	QuadTemplate labelDays;
	QuadTemplate labelYears;
	
}

-(id)initWithModel:(ApplicationModel*)applicationModel;

@end
