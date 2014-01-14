//
//  Button.h
//  Eve of Impact
//
//  Created by Rik Schennink on 5/1/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "Control.h"

@interface Button : Control {
	
	uint orientation;
	QuadTemplate label;
	QuadTemplate bar;
	QuadTemplate button;
}

@property (assign) uint orientation;

-(id)initWithLabel:(UVMap)labelUVMap;

@end
