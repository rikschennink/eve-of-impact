//
//  Advent.m
//  Eve of Impact
//
//  Created by Rik Schennink on 9/25/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

// designer of "advent" font Andreas K. inde
// e-mail: inde.graphics@gmail.com

#import "Advent.h"
#import "Font.h"
#import "Character.h"

@implementation Advent

-(id)init {
	
	if ((self = [super init])) {
		
		CGSize defaultSize = CGSizeMake(24.0, 32.0);
		float defaultHeight = 20.0;
		float defaultWidth = 14.0;
		space = 10;
		
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		[super addCharacter:[[[Character alloc] initWithCharacter:@"0" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(8,104,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"1" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(32,104,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"2" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(56,104,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"3" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(80,104,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"4" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(104,104,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"5" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(128,104,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"6" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(152,104,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"7" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(176,104,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"8" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(200,104,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"9" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(224,104,24,32)] autorelease]];
		
		[super addCharacter:[[[Character alloc] initWithCharacter:@"A" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(8,72,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"B" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(32,72,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"C" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(56,72,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"D" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(80,72,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"E" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(104,72,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"F" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(128,72,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"G" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(152,72,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"H" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(176,72,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"I" width:8.0		  height:defaultHeight size:defaultSize andMap: UVMapMake(200,72,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"J" width:8.0		  height:defaultHeight size:defaultSize andMap: UVMapMake(224,72,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"K" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(248,72,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"L" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(272,72,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"M" width:18.0		  height:defaultHeight size:defaultSize andMap: UVMapMake(296,72,24,32)] autorelease]];
		
		[super addCharacter:[[[Character alloc] initWithCharacter:@"N" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(8,40,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"O" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(32,40,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"P" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(56,40,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"Q" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(80,40,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"R" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(104,40,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"S" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(128,40,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"T" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(152,40,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"U" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(176,40,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"V" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(200,40,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"W" width:18.0		  height:defaultHeight size:defaultSize andMap: UVMapMake(224,40,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"X" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(248,40,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"Y" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(272,40,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"Z" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(296,40,24,32)] autorelease]];
		
		[super addCharacter:[[[Character alloc] initWithCharacter:@"!" width:8.0		  height:defaultHeight size:defaultSize andMap: UVMapMake(8,8,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"@" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(32,8,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"#" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(56,8,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"$" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(80,8,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"%" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(104,8,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"&" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(128,8,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"*" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(152,8,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"-" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(176,8,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"+" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(200,8,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"=" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(224,8,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"," width:8.0		  height:defaultHeight size:defaultSize andMap: UVMapMake(248,8,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"." width:8.0		  height:defaultHeight size:defaultSize andMap: UVMapMake(272,8,24,32)] autorelease]];
		[super addCharacter:[[[Character alloc] initWithCharacter:@"?" width:defaultWidth height:defaultHeight size:defaultSize andMap: UVMapMake(296,8,24,32)] autorelease]];
		
		[pool release];
	}
	
	return self;
}

@end
