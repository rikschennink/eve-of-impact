//
//  Clip.m
//  Eve of Impact
//
//  Created by Rik Schennink on 4/28/11.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "Clip.h"
#import "Prefs.h"
#import "Visual.h"
#import "Common.h"
#import "RenderEngine.h"

@implementation Clip

-(id)init {
	
	if ((self = [super init])) {
		
		buffer = QuadBufferMake();
		
	}
		
	return self;
}

-(void)addQuad:(QuadTemplate)quadTemplate {
	
	addQuadToQuadBuffer(quadTemplate, &buffer);
	
}

-(void)draw:(CGRect)frame {
	
	if (!self.shouldDraw) {
		return;
	}
	
	CGPoint global = [self localToGlobal];
	
	for (uint i=0;i<buffer.quadCount;i++) {
		
		QuadTemplate q = buffer.quads[i];
		q.x += global.x;
		q.y += global.y;
		q.color.a *= flicker;
		
		if (q.rotation!=0) {
			[[RenderEngine singleton] addQuad:&q andRotateBy:q.rotation];
		}
		else {
			[[RenderEngine singleton] addQuad:&q];
		}
		
	}
	
	[super draw:frame];
}


@end
