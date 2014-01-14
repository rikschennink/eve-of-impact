//
//  Clip.h
//  Eve of Impact
//
//  Created by Rik Schennink on 4/28/11.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "Control.h"


@interface Clip : Control {
    
	//QuadTemplate quad;
	QuadBuffer buffer;
	
}

//-(id)initWithQuad:(QuadTemplate)quadTemplate;

-(void)addQuad:(QuadTemplate)quadTemplate;

@end
