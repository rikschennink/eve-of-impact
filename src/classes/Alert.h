//
//  Alert.h
//  Eve of Impact
//
//  Created by Rik Schennink on 6/6/11.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "Control.h"

@interface Alert : Control {
	
    QuadTemplate cloud;
	
	int countdown;
	int previousAlert;
	
}

-(void)setAlert:(uint)alert;

@end
