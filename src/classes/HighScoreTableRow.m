//
//  HighScoreTableRow.m
//  Eve of Impact
//
//  Created by Rik Schennink on 10/4/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "HighScoreTableRow.h"
#import "RenderEngine.h"
#import "Label.h"
#import "Advent.h"
#import "HighScore.h"
#import "Prefs.h"

@implementation HighScoreTableRow

-(id)initWithHighScore:(HighScore*)score andIndex:(uint)rowIndex {
	
	if ((self = [super init])) {
		
		index = rowIndex;
		
		scale = IS_IPAD ? 2.0 : 1.0;
		
		self.position = CGPointMake(0.0, -52.0 * index * scale);
		
		uint ranking = index+1;
		
		// get rank quad
		rank = QuadTemplateMake(0, 0, 0, 32.0 * scale, 48.0 * scale, COLOR_INTERFACE,  UVMapMake(8 + (ranking * 32.0), 144, 32, 48));
		
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		// set username label
		username = [[Label alloc] initWithFont:[[[Advent alloc] init] autorelease]];
		username.text = [score.name copy];
		[self addChild:username];
		
		[pool release];
		
		// set people label
		labelPeople = QuadTemplateMake(0, 0, 0, 59.0 * scale, 16.0 * scale, COLOR_INTERFACE,  UVMapMake(8, 296, 59.0, 16.0));
		
		// digit quads
		UVMap digits[10];
		CGSize letterbox = CGSizeMake(16, 16);
		for (uint i=0; i<10; i++) {
			digits[i] =  UVMapMake(8 + (i * letterbox.width), 192, letterbox.width, letterbox.height);
		}
		dot = QuadTemplateMake(0, 0, 0, 12.0 * scale, letterbox.height * scale, COLOR_INTERFACE,  UVMapMake(170, 192, 12, letterbox.height));
		
		// score
		// get digits in distance // REVERSED
		uint pointsDigit;
		int points = score.points;
		uint lengthCounter = 0;
		
		while (points) {
			
			pointsDigit = points % 10;
			addQuadToQuadBuffer(QuadTemplateMake(0,0,0, letterbox.width * scale, letterbox.height * scale, COLOR_INTERFACE, digits[pointsDigit]), &peopleBuffer);
			points/=10;
			
			if (points) {
				lengthCounter++;
				if (lengthCounter%3==0) {
					addQuadToQuadBuffer(dot, &peopleBuffer);
				}
			}
		}
	}
	
	return self;
}

-(void)setState:(uint)state withTicks:(uint)modelTicks {
	
	[super setState:state withTicks:modelTicks];
	
	enabled = state == STATE_HIGHSCORE_BOARD;
	
	username.enabled = enabled;
	
}

-(void)draw:(CGRect)frame {
	
	if (!self.shouldDraw) {
		return;
	}
	
	CGPoint global = [self localToGlobal];
	
	username.position = CGPointMake(-username.size.width - (47.0 * scale),
									-username.size.height - (16.0 * scale));
	
	if (IS_IPAD) {
		global.x -= 20.0;
		global.y -= 30.0;
		
		username.position = CGPointMake(username.position.x - 18.0,
										username.position.y - 40.0);
	}
	
	rank.x = global.x - rank.width;
	rank.y = global.y - rank.height;
	rank.color = COLOR_INTERFACE;
	rank.color.a *= username.flicker;
	
	labelPeople.x = rank.x - labelPeople.width;
	labelPeople.y = rank.y + (28.0 * scale);
	labelPeople.color = rank.color;
	[[RenderEngine singleton] addQuad:&labelPeople];
	
	float offset = labelPeople.x - (10.0 * scale);
	for (uint i=0; i<peopleBuffer.quadCount; i++) {
		offset -= peopleBuffer.quads[i].width - (6.0 * scale);
		peopleBuffer.quads[i].x = offset;
		peopleBuffer.quads[i].y = labelPeople.y;
		peopleBuffer.quads[i].color = rank.color;
		[[RenderEngine singleton] addQuad:&peopleBuffer.quads[i]];
	}
	
	[[RenderEngine singleton] addQuad:&rank];
	
	[super draw:frame];
}

-(void)dealloc {
	
	[username release];
	
	[super dealloc];
	
}

@end
