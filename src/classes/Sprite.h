//
//  Sprite.h
//  EarthZero
//
//  Created by Rik & Wendy on 2/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Graphic.h"

@interface Sprite : Graphic {
	
	CGSize  	size;
	CGRect		slice;
	// slice: offset left, offset bottom, width of graphic, height of graphic
	
}

@property (assign) CGSize		size;
@property (assign) CGRect		slice;

@end
