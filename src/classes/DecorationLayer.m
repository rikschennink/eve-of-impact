//
//  InterfaceGenerator.m
//  Eve of Impact
//
//  Created by Rik Schennink on 4/1/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "DecorationLayer.h"
#import "ApplicationModel.h"
#import "RenderEngine.h"
#import "Prefs.h"
#import "MathAdditional.h"

// actors
#import "ActorBase.h"
#import "AsteroidActor.h"
#import "SatelliteActor.h"
#import "ShipActorBase.h"
#import "EscapePodShipActor.h"
#import "PlanetActor.h"
#import "MoonActor.h"
#import "MissileActor.h"
#import "Vector.h"
#import "Easing.h"

#import "MoveBehaviour.h"
#import "MoveBehaviourBase.h"
#import "HistoryBehaviourBase.h"
#import "HistoryBehaviour.h"

@implementation DecorationLayer


-(id)initWithModel:(ApplicationModel*)applicationModel {
	
	if ((self = [super init])) {
		
		model = applicationModel;
		
		scale = IS_IPAD ? 2.0 : 1.0;
		
		for (uint i=0; i<10; i++) {
			digitUVMaps[i] =  UVMapMake(184 + i * 16, 192, 16, 16);
		}
		
		digit = QuadTemplateMakeFast(0, 0, 16 * scale, 1.0, UVMapMake(0, 0, 0, 0));
		digit.color = ColorMake(0, 0, 0, 1.0);
		
		missileTarget = QuadTemplateMakeEmpty();
		missileTarget.uv =  UVMapMake(312,376,24,24);
		missileTarget.color = COLOR_INTERFACE;
		missileTarget.width = 24.0 * scale;
		missileTarget.height = missileTarget.width;
		
		marker = QuadTemplateMakeEmpty();
		marker.width = 32.0 * scale;
		marker.height = marker.width;
		marker.uv =  UVMapMake(272, 368, 32, 32);
		marker.color = COLOR_INTERFACE;
		
		markerCorner = QuadTemplateMakeEmpty();
		markerCorner.width = 11.0 * scale;
		markerCorner.height = markerCorner.width;
		markerCorner.color = COLOR_INTERFACE;
		
		markerCorners[0] =  UVMapMake(272, 389, 11, 11); // tl
		markerCorners[1] =  UVMapMake(293, 389, 11, 11); // tr
		markerCorners[2] =  UVMapMake(272, 368, 11, 11); // bl
		markerCorners[3] =  UVMapMake(293, 368, 11, 11); // br
		
		labelPointer = QuadTemplateMake(0, 0, 0, 24 * scale, 24 * scale, COLOR_INTERFACE,  UVMapMake(296, 312, 24, 24));
		
		shuttleLabel = QuadTemplateMake(0, 0, 0, 56 * scale, 16 * scale, COLOR_INTERFACE, UVMapMake(272, 440, 56, 16));
		shuttleLabelPointer = QuadTemplateMake(0, 0, 0, 14 * scale, 19 * scale, COLOR_INTERFACE, UVMapMake(272, 464, 14, 19));
		shuttleLabelCapacity = QuadTemplateMakeEmpty();
		shuttleLabelCapacity.width = 32 * scale;
		shuttleLabelCapacity.height = 16 * scale;
		shuttleLabelCapacity.color = COLOR_INTERFACE;
		
		podLabel = QuadTemplateMake(0, 0, 0, 24.0 * scale, 16.0 * scale, COLOR_INTERFACE, UVMapMake(264, 304, 24, 16));
		
		lastWarningTick = 0;
	}
	
	return self;
	
}

-(void)redraw:(float)interpolation {
	
	ScreenBorders borders = [[RenderEngine singleton] getScreenBordersByGutter:10.0 * scale];
	
	uint i,stateLife;
	Vector position;
	float offset;
	float pulse;
	bool warning;
	bool warned = NO;
	
	for (ActorBase* actor in model.world.actors) {
		
		if ([actor isKindOfClass:[AsteroidActor class]] && 
			![actor.state contains:STATE_LEAVING] && 
			(model.state == STATE_PLAYING || model.state == STATE_MENU_PAUSE)) {
			
			// get position to render actor
			position.x = actor.position.x + (actor.velocity.x * interpolation);
			position.y = actor.position.y + (actor.velocity.y * interpolation);
			
			// check if asteroid is visible
			if (!isVisible(position.x,position.y, &borders)) {
				continue;
			}
			
			// get warning state of asteroid
			warning = [actor.state contains:STATE_WARNING];
			
			// if warning make blue
			if (warning) {
				pulse = (sinHash((model.ticks * 10) % 360) + 1) * .5;
				warned = YES;
			}
			else {
				pulse = 1.0;
			}
			
			// if attention, zoom in on asteroid with flickering corner brackets
			if ([actor.state contains:STATE_ATTENTION]) {
				
				stateLife = [actor.state getLifeInState:STATE_ATTENTION];
				offset = 10.0 + (1.0 - fmin(1.0,easeLinear(stateLife,25))) * 20.0;
				
				markerCorner.color.a = stateLife & 1 ? .25 : 1.0;
				markerCorner.color.a *= pulse;
				
				for (i=0; i<4; i++) {
					
					markerCorner.x = position.x - 5.5;
					markerCorner.y = position.y - 5.5;
					
					switch (i) {
						case 0:
							markerCorner.x-=offset;
							markerCorner.y+=offset;
							break;
						case 1:
							markerCorner.x+=offset;
							markerCorner.y+=offset;
							break;
						case 2:
							markerCorner.x-=offset;
							markerCorner.y-=offset;
							break;
						case 3:
							markerCorner.x+=offset;
							markerCorner.y-=offset;
							break;
						default:
							break;
					}
					
					markerCorner.x *= scale;
					markerCorner.y *= scale;
					
					markerCorner.uv = markerCorners[i];
					[[RenderEngine singleton] addQuad:&markerCorner];
				}
			}
			else if ([actor.state contains:STATE_DETECTED]) {
				
				marker.x = (position.x - 16.0) * scale;
				marker.y = (position.y - 16.0) * scale;
				marker.color.a = 1.0;
				marker.color.a *= pulse;
				[[RenderEngine singleton] addQuad:&marker];
				
			}
		}
		else if ([actor isKindOfClass:[ShipActorBase class]] && model.state != STATE_MENU_GAMEOVER) {
			
			ShipActorBase* ship = (ShipActorBase*)actor;
			
			if ([ship isKindOfClass:[EscapePodShipActor class]]) {
				continue;
			}
			
			if (actor.state.life < 25) {
				continue;
			}
			else if (actor.state.life >= 25 && actor.state.life < 40) {
				shuttleLabel.color.a = actor.state.life & 1 ? .25 : 1.0;
			}
			else {
				shuttleLabel.color.a = 1.0;
			}
			
			shuttleLabelPointer.x = (actor.position.x + (actor.velocity.x * interpolation)) * scale;
			shuttleLabelPointer.y = (actor.position.y + (actor.velocity.y * interpolation)) * scale;
			shuttleLabelPointer.color = shuttleLabel.color;
			[[RenderEngine singleton] addQuad:&shuttleLabelPointer];
				
			shuttleLabel.x = shuttleLabelPointer.x + (12.0 * scale);
			shuttleLabel.y = shuttleLabelPointer.y + (5.5 * scale);
			[[RenderEngine singleton] addQuad:&shuttleLabel];
			
			shuttleLabelCapacity.x = shuttleLabel.x + (26.0 * scale);
			shuttleLabelCapacity.y = shuttleLabel.y + (.5 * scale);
			shuttleLabelCapacity.color = shuttleLabel.color;
						
			int passengers = ship.passengers;
			int digits = passengers==0 ? 1 : log10(passengers) + 1;
			
			digit.color = shuttleLabel.color;
			digit.x = shuttleLabel.x + ((20.0 + (digits * 7.0))  * scale);
			digit.y = shuttleLabel.y;
			
			while(passengers) {
			
				digit.x -= 6.0 * scale;
				digit.uv = digitUVMaps[passengers % 10];
				[[RenderEngine singleton] addQuad:&digit];
				passengers*=.1;
			}
			
		}
		else if ([actor isKindOfClass:[MissileActor class]]) {
			
			MissileActor* missile = (MissileActor*)actor;
			
			// check if missile target is visible
			if (!isVisible(missile.target.x - 12.0,missile.target.y - 12.0, &borders)) {
				continue;
			}
			
			if (actor.state.life < 15 || (actor.state.lifespan - actor.state.life > 20)) {
				
				missileTarget.x = (missile.target.x - 12.0) * scale;
				missileTarget.y = (missile.target.y - 12.0) * scale;
				missileTarget.color.a = 1.0;
				
				if (actor.state.life < 15) {
					missileTarget.color.a = actor.state.life & 1 ? .25 : 1.0;
				}
				
				[[RenderEngine singleton] addQuad:&missileTarget];
			}
		}
	}
	
	if (warned && model.ticks % 32 == 0 && lastWarningTick != model.ticks) {
		
		lastWarningTick = model.ticks;
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"AsteroidWarn" object:nil];
		
	}
}


@end




