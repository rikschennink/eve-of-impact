//
//  GUIView.m
//  Eve of Impact
//
//  Created by Rik Schennink on 2/22/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "InterfaceLayer.h"
#import "ApplicationModel.h"
#import "RenderEngine.h"
#import "SatelliteActor.h"
#import "Control.h"
#import "Clock.h"
#import "Menu.h"
#import "Collision.h"
#import "Prefs.h"
#import "AsteroidActor.h"
#import "ScoreCounter.h"
#import "Label.h"
#import "Advent.h"
#import "HighScore.h"
#import "HighScoreBoard.h"
#import "HighScoreTable.h"
#import "Rank.h"
#import "ShieldIndicator.h"
#import "Easing.h"
#import "Tutorial.h"
#import "Alert.h"
#import "Prompter.h"
#import "UserContext.h"


@implementation InterfaceLayer

@synthesize touching;


-(id)initWithModel:(ApplicationModel*)applicationModel {
	
	if ((self = [super init])) {
		
		touching = NO;
		lastModelTick = 0;
		
		model = applicationModel;
		
		scale = IS_IPAD ? 2.0 : 1.0;
		
		projected = VectorMake(0, 0);
		uint i;
		
		for (i=0; i<10; i++) {
			digitUVMaps[i] =  UVMapMake(184 + i * 16, 192, 16, 16);
		}
		
		for (i=0;i<5;i++) {
			indicatorSizeMap[i] =  UVMapMake(232 + i * 16, 344, 16, 16);
		}
		
		// warning sign
		warningSign = QuadTemplateMake(0, 0, 0, 56 * scale, 16 * scale, COLOR_INTERFACE,  UVMapMake(208, 472, 56, 16));
		
		// set gui holder control
		gui = [[Control alloc]init];
		gui.enabled = YES;
		gui.touchable = NO;
		
		// define shield strength indicator control
		shieldIndicator = [[ShieldIndicator alloc] initWithModel:model];
		[gui addChild:shieldIndicator];
		
		// define score control
		score = [[ScoreCounter alloc] initWithModel:model];
		[gui addChild:score];
		
		// popup menu
		menu = [[Menu alloc] initWithModel:model];
		[gui addChild:menu];
		
		// rank
		rank = [[Rank alloc] init];
		[gui addChild:rank];
		
		// highscores
		highScoreTable = [[HighScoreTable alloc]init];
		[gui addChild:highScoreTable];
		
		// tutorial
		tutorial = [[Tutorial alloc] initWithModel:model];
		[gui addChild:tutorial];
		
		// alert
		alert = [[Alert alloc] init];
		[gui addChild:alert];
		
		// digit for indicators
		
		digit = QuadTemplateMakeFast(0, 0, 16.0 * scale, 1.0, UVMapMake(0, 0, 0, 0));
		digit.color = COLOR_INTERFACE;
		dot = QuadTemplateMake(0, 0, 0, 16.0 * scale, 16.0 * scale, COLOR_INTERFACE,  UVMapMake(344, 192, 16.0, 16.0));
		
		// size indicator
		sizeIndicator = QuadTemplateMake(0, 0, 0, 16.0 * scale, 16.0 * scale, COLOR_INTERFACE, indicatorSizeMap[0]);
		
        
        CGSize screenSize = [[RenderEngine singleton] getScreenSize];
        
        
		// scanlines
		scanlines = QuadTemplateMake(-screenSize.width * .5, -screenSize.height * .5, 0, screenSize.width, screenSize.height, ColorMake(255, 255, 255, .125), UVMapMakeSize(0, 0, screenSize.width, screenSize.height, 2.0));
		
		if (IS_RETINA) {
			scanlines.color = ColorMake(255, 255, 255, .25);
		}
		
		if (IS_IPAD) {
			scanlines.color = ColorMake(255, 255, 255, .2);
			//scanlines = QuadTemplateMake(-384.0, -512.0, 0, 768.0, 1024.0, ColorMake(255, 255, 255, .125), UVMapMakeSize(0, 0, 768.0, 1024.0, 2.0));
			
		}
		
		// interface
		//interface = QuadTemplateMake(-256.0, -256.0, 0, 512.0, 512.0, ColorMakeFast(),  UVMapMake(0, 0, 512.0, 512.0));
		interface = QuadTemplateMake(-screenSize.height * .5, -screenSize.height * .5, 0, screenSize.height, screenSize.height, ColorMakeFast(), UVMapMake(0, 0, screenSize.height, screenSize.height));
        
		// bigger interface layer
		if (IS_IPAD) {
			interface = QuadTemplateMake(-512.0, -512.0, 0, 2048.0, 2048.0, ColorMakeFast(),  UVMapMake(0, 0, 1024.0, 1024.0));
		}
		
	}
	
	return self;
}

-(void)updateUsername:(NSString*)username {
	menu.user.text = username;
}

-(void)updateHighScores {
	
	[highScoreTable updateHighScores:model.highScoreBoard];
	
}

-(void)updateLocalRank {
	
	[rank setLocal:model.userContext.lastScoreRank];
	[rank setScore:model.userContext.lastScorePoints];
	
}

-(void)updateGlobalRank:(uint)globalRank {
	
	[rank setGlobal:globalRank];
	
}

-(void)setAchievementUnlockedDescription:(NSString*)description {
	
	[rank setAchievementUnlockedDescription:description];
	
}

-(void)resetAchievementUnlockedDescription {
	[rank resetAchievementUnlockedDescription];
}

-(void)redraw:(float)interpolation {
	
	CGSize screenSize = [[RenderEngine singleton] getScreenSize];
	
	float left,right,top,bottom;
	left = -screenSize.width * .5;
	right = screenSize.width * .5;
	bottom = -screenSize.height * .5;
	top = screenSize.height * .5;
	
	float hl,hr,vt,vb;
	hl = left + (16.0* scale);
	hr = right - (16.0* scale);
	vt = top - (16.0* scale);
	vb = bottom + (16.0* scale);
	
	float digitSpacer,opacity,indicatorMargin;
	
	indicatorMargin = 8.0 * scale;
	opacity = 1.0;
	digitSpacer = 7.0 * scale;
	uint indicatorAlignment;
	uint lengthCounter = 0;
	BOOL attention = NO;
	BOOL detected = NO;
	BOOL warning = NO;
	float distance;
	float pulse;
	int fakeDistance;
	int digits;
	Vector distanceIndicator = VectorMake(0, 0);
	Vector scaledPosition;
	
	if (model.state == STATE_PLAYING || model.state == STATE_MENU_PAUSE) {
		
		for (ActorBase* actor in model.world.asteroids) {
					
			// if not leaving
			if (![actor.state contains:STATE_LEAVING]) {
				
				pulse = 1.0;
				warning = [actor.state contains:STATE_WARNING];
				attention = [actor.state contains:STATE_ATTENTION];
				detected = [actor.state contains:STATE_DETECTED];
				
				// if not detected or 
				if (!(detected || attention)) {
					continue;
				}
				
				
				scaledPosition = vectorMultiplyWithAmount(&actor->position, scale);
				
				
				[[RenderEngine singleton] projectLocationVector:&scaledPosition ToScreenVector:&projected];
				
				if ((projected.x <= left || projected.x >= right) ||
					(projected.y <= bottom || projected.y >= top)) {
					
					// reset offsets
					vectorReset(&distanceIndicator);
					
					indicatorAlignment = 0;
					
					if (projected.x <= left + indicatorMargin) {
						
						indicatorAlignment = INDICATOR_LEFT;
						
						if (projected.y <= bottom + indicatorMargin) {			// left bottom
							sizeIndicator.y = bottom;
						}
						else if (projected.y >= top - indicatorMargin) {		// left top
							sizeIndicator.y = top - (16.0 * scale);
						}
						else {
							sizeIndicator.y = projected.y - (8.0 * scale);
						}
						
						sizeIndicator.x = left;
						distanceIndicator.x = left + indicatorMargin + (2.0 * scale);
						distanceIndicator.y = projected.y - (8.0 * scale);
						
					}
					else if (projected.x >= right - indicatorMargin) {
						
						indicatorAlignment = INDICATOR_RIGHT;
						
						if (projected.y <= bottom + indicatorMargin) {			// right bottom
							sizeIndicator.y = bottom;
						}
						else if (projected.y >= top - indicatorMargin) {		// right top
							sizeIndicator.y = top - (16.0 * scale);
						}
						else {
							sizeIndicator.y = projected.y - (8.0 * scale);
							
						}
						
						// set position and digit stuff
						sizeIndicator.x = right - (16.0 * scale);
						distanceIndicator.x = right - indicatorMargin;
						distanceIndicator.y = projected.y - (8.0 * scale);
						
					}
					else { // horizontal center
						
						if (projected.y <= bottom + indicatorMargin) {
							
							indicatorAlignment = INDICATOR_BOTTOM;
							
							sizeIndicator.x = projected.x - (8.0 * scale);
							sizeIndicator.y = bottom;
							distanceIndicator.x = projected.x - (4.0 * scale);
							distanceIndicator.y = bottom + indicatorMargin + (2.0 * scale);
							
						}
						else if (projected.y >= top - indicatorMargin) {
							
							indicatorAlignment = INDICATOR_TOP;
							
							sizeIndicator.x = projected.x - (8.0 * scale);
							sizeIndicator.y = top - (16.0 * scale);
							distanceIndicator.x = projected.x - (4.0 * scale);
							distanceIndicator.y = top - indicatorMargin - (18.0 * scale);
							
						}
					}
					
					
					// flickr actor
					if (attention) {
						opacity = actor.state.life % 2 == 0 ? .25 : 1.0;
					}
					
					
					if (warning) {
						
						warningSign.x = distanceIndicator.x;
						warningSign.y = distanceIndicator.y;
						
						// add total width of digits to digit offset
						switch (indicatorAlignment) {
							case INDICATOR_TOP:
							case INDICATOR_BOTTOM:
								warningSign.x -= warningSign.width * .45;
								break;
							case INDICATOR_RIGHT:
								warningSign.x -= warningSign.width;
								break;
							default:
								break;
						}
						
						// cap distanceindicator x offset
						if (warningSign.x > hr - warningSign.width + (4.0 * scale)) {
							warningSign.x = hr - warningSign.width + (4.0 * scale);
						}
						else if (warningSign.x < hl - indicatorMargin + (5.0 * scale)) {
							warningSign.x = hl - indicatorMargin + (5.0 * scale);
						}
						
						// cap distanceindicator y offset
						if (warningSign.y > vt - indicatorMargin - (5.0 * scale)) {
							warningSign.y = vt - indicatorMargin - (5.0 * scale);
						}
						else if (warningSign.y < vb - indicatorMargin + (5.0 * scale)) {
							warningSign.y = vb - indicatorMargin + (5.0 * scale);
						}
						
						pulse = (sinHash((model.ticks * 10) % 360) + 1) * .5;
						warningSign.color.a = pulse;
						
						[[RenderEngine singleton] addQuad:&warningSign];
						
					}
					else {
						
						// get distance
						distance = easeLinear(getDistanceSquaredToPlanet(actor->position.x,actor->position.y),ASTEROID_DETECTION_DISTANCE_SQUARED);
						
						// cast to unsigned int to make calculation a little easier
						fakeDistance = (int)(distance * 200000);
						
						// get digits in distance
						digits = (fakeDistance==0) ? 1 : log10(fakeDistance) + 1;
						
						// get width
						float labelWidth = (digits + floor((digits-1)/3)) * digitSpacer;
						float labelCenter = labelWidth * .5;
						
						// add total width of digits to digit offset
						switch (indicatorAlignment) {
							case INDICATOR_TOP:
							case INDICATOR_BOTTOM:
								distanceIndicator.x += labelCenter;
								break;
							case INDICATOR_LEFT:
								distanceIndicator.x += labelWidth;
								break;
							default:
								break;
						}
						
						// cap distanceindicator x offset
						float correction = 2.0 * scale;
						if (distanceIndicator.x > hr - correction) {
							distanceIndicator.x = hr - correction;
						}
						else if (distanceIndicator.x < hl + labelWidth - indicatorMargin + correction) {
							distanceIndicator.x = hl + labelWidth - indicatorMargin + correction;
						}
						
						// cap distanceindicator y offset
						if (distanceIndicator.y > vt - indicatorMargin - correction) {
							distanceIndicator.y = vt - indicatorMargin - correction;
						}
						else if (distanceIndicator.y < vb - indicatorMargin + correction) {
							distanceIndicator.y = vb - indicatorMargin + correction;
						}
						
						lengthCounter = 0;
						digit.color.a = opacity;
						
						// render distance label
						while(fakeDistance) {
							
							distanceIndicator.x -= digitSpacer;
							digit.x = distanceIndicator.x;
							digit.y = distanceIndicator.y;
							digit.uv = digitUVMaps[fakeDistance % 10];
							[[RenderEngine singleton] addQuad:&digit];
							fakeDistance/=10;
							
							if (fakeDistance) {
								lengthCounter++;
								if (lengthCounter%3==0) {
									distanceIndicator.x -= digitSpacer;
									dot.x = distanceIndicator.x;
									dot.y = digit.y;
									[[RenderEngine singleton] addQuad:&dot];
								}
							}
						}
					}
									
					uint sizeIndex = fmax(0.0,round(actor.mass) - 1.0);
					sizeIndicator.color.a = opacity;
					sizeIndicator.color.a *= pulse;
					sizeIndicator.uv = indicatorSizeMap[sizeIndex];
					[[RenderEngine singleton] addQuad:&sizeIndicator];
									
				}
			}
		}
	}
	
	if (model.ticks != lastModelTick) {
		lastModelTick = model.ticks;
	
		// tick tack on gui
		[gui tick];
		
		// pass alerts to gui
		[alert setAlert:model.prompter.current];
		
		// pass game state to gui
		[gui setState:model.state withTicks:model.ticks];
	}
	
	// redraw gui and all its child controls
	[gui draw:CGRectMake(0,0,screenSize.width,screenSize.height)];
	
	
	// draw video waiting end animation
	if (model.state == STATE_TITLE && model.ticks < 60) {
		
		float altScale = IS_IPAD ? 1.5 : 1.0;
		
		QuadTemplate waitingStream = QuadTemplateMake(0, 0, 0, 176.0 * altScale, 24.0 * altScale, COLOR_INTERFACE, UVMapMake(352, 480, 176, 24));
		waitingStream.y = bottom + (15.0 * altScale);
		waitingStream.x = right - (189.0 * altScale);
		
		if (model.ticks > 50) {
			waitingStream.color.a = model.ticks&1 ? .15 : 1.0;
		}
		
		[[RenderEngine singleton] addQuad:&waitingStream];
	}
	
	
	
	
	// set default interface texture and render
	[[RenderEngine singleton] setActiveTexture:TEXTURE_INTERFACE];
	[[RenderEngine singleton] renderActiveVertexBuffer];
	[[RenderEngine singleton] flushActiveVertexBuffer];
	
	
	// render scanlines over interface
	[[RenderEngine singleton] setActiveBlendMode:BLEND_MODE_DEFAULT];
	[[RenderEngine singleton] setActiveTexture:TEXTURE_SCANLINES];
	[[RenderEngine singleton] addQuad:&scanlines];
	[[RenderEngine singleton] renderActiveVertexBuffer];
	[[RenderEngine singleton] flushActiveVertexBuffer];
	
		
	// bind default framebuffer and reset projection
	[[RenderEngine singleton] setActiveFrameBuffer:FBO_DEFAULT];
	[[RenderEngine singleton] set2DProjection];
	
	// render interface sprite
	[[RenderEngine singleton] setActiveBlendMode:BLEND_MODE_SCREEN];
	[[RenderEngine singleton] setActiveTexture:TEXTURE_INTERFACE_VISUAL];
	interface.color.a = randomBetween(.95, 1.0);
	[[RenderEngine singleton] addQuad:&interface];
	
	[[RenderEngine singleton] renderActiveVertexBuffer];
	[[RenderEngine singleton] flushActiveVertexBuffer];
}

-(void)onTouchesBeginAt:(CGPoint)touch {
	
	Vector touchLocation = [[RenderEngine singleton] projectTouchToInterface:&touch];
	
	if ([gui onTouchesBeginAt:touchLocation]) {
		touching = YES;
	}
}

-(void)onTouchesMoveAt:(CGPoint)touch {
	
	return;
}

-(void)onTouchesEndAt:(CGPoint)touch {
	
	Vector touchLocation = [[RenderEngine singleton] projectTouchToInterface:&touch];
	
	[gui onTouchesEndAt:touchLocation];
	
	touching = NO;
}

-(void)dealloc {
	
	[shieldIndicator release];
	[score release];
	[menu release];
	[gui release];
	
	[super dealloc];
}



@end
