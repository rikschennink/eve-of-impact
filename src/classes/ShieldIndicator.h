//
//  ShieldIndicator.h
//  Eve of Impact
//
//  Created by Rik Schennink on 2/22/11.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "Control.h"

@class ApplicationModel;

@interface ShieldIndicator : Control {
	
	ApplicationModel* model;
	
	UVMap digits[10];
	QuadTemplate digit;
	QuadTemplate dot;
	QuadTemplate charges[10];
	
	QuadTemplate shieldIcon;
}

-(id)initWithModel:(ApplicationModel*)applicationModel;

@end
