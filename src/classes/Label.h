//
//  Label.h
//  Eve of Impact
//
//  Created by Rik Schennink on 9/25/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "Control.h"

@class Font;

@interface Label : Control {
	
	Font* font;
	NSString* text;
	QuadBuffer buffer;
	
}

@property (nonatomic,retain) NSString* text; 

-(id)initWithFont:(Font*)fontFamily;

@end
