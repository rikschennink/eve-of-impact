//
//  WorldView.m
//  Eve of Impact
//
//  Created by Rik Schennink on 2/22/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "ActorBase.h"
#import "ApplicationModel.h"
#import "AsteroidActor.h"
#import "Common.h"
#import "DebreeActor.h"
#import "MathAdditional.h"
#import "MissileActor.h"
#import "MoonActor.h"
#import "PlanetActor.h"
#import "Prefs.h"
#import "RenderEngine.h"
#import "SatelliteActor.h"
#import "ShieldActor.h"
#import "ShipActorBase.h"
#import "WorldLayer.h"
#import "Easing.h"


@implementation WorldLayer



-(id)initWithModel:(ApplicationModel*)applicationModel {
	
	if ((self = [super init])) {
		
		model = applicationModel;
		
		scale = IS_IPAD ? 2.0 : 1.0;
		
		// predefine uv maps
		for (uint i =0; i<5; i++) {
			asteroidUV[i] = UVMapMake(49 + (i * 14), 433, 14, 14);
		}
		
		satellite = UVMapMake(9,441,6,6);
		moon = UVMapMake(2,465,22,22);
		missileUV = UVMapMake(2,449,5,8);

		missileTrail = LineTemplateMake(2.0 * scale,UVMapMake(34, 449, 10, 11));
		missileTrail.mode = LINE_MODE_FADE_OUT;
		missileTrailEndUV = UVMapMake(97, 449, 14, 14);
		
		actorVisual = QuadTemplateMakeEmpty();
	}
	
	return self;
}

-(void)redraw:(float)interpolation {
	
	ScreenBorders borders = [[RenderEngine singleton] getScreenBordersByGutter:5.0 * scale];
	
	BOOL corrected;
	float x,y,vx,vy,d;
	uint max,count,offset;
	
	// start adding actor sprites
	for (ActorBase* actor in model.world.actors) {
		
		if ([actor isKindOfClass:[DebreeActor class]]) {
			
			// check if debree is visible
			if (!isVisible(actor.position.x,actor.position.y, &borders)) {
				continue;
			}
			
			actorVisual.x = (actor.position.x + (interpolation * actor.velocity.x)) * scale;
			actorVisual.y = (actor.position.y + (interpolation * actor.velocity.y)) * scale;
			actorVisual.width = 1.0 * scale;
			actorVisual.height = actorVisual.width;
			actorVisual.uv = asteroidUV[0];
			ColorReset(&actorVisual.color);
			
			// check if rotation is visible
			[[RenderEngine singleton] addQuad:&actorVisual];
			
		}
		else if ([actor isKindOfClass:[AsteroidActor class]]) {
			
			// check if asteroid is visible
			if (!isVisible(actor.position.x,actor.position.y, &borders)) {
				continue;
			}
			
			AsteroidActor* asteroid = (AsteroidActor*)actor;
			
			uint lastDigit = asteroid.uid%10;
			uint index = round(lastDigit/2);
			
			actorVisual.x = (actor.position.x + (interpolation * actor.velocity.x)) * scale;
			actorVisual.y = (actor.position.y + (interpolation * actor.velocity.y)) * scale;
			actorVisual.width = (asteroid.mass * 2.0) * scale;
			actorVisual.height = actorVisual.width;
			actorVisual.uv = asteroidUV[index];
			ColorReset(&actorVisual.color);
			
			// check if rotation is visible
			if (asteroid.mass >= 2.0) {
				[[RenderEngine singleton] addQuad:&actorVisual andRotateBy:actor.state.life % 360];
			}
			else {
				[[RenderEngine singleton] addCenteredQuad:&actorVisual];
			}
		}
		else if ([actor isKindOfClass:[MissileActor class]]){
			
			MissileActor* missile = (MissileActor*)actor;
			
			HistoryBehaviourBase<HistoryBehaviour>* history = (HistoryBehaviourBase<HistoryBehaviour>*)missile.history;
			
			corrected = NO;
			max = history.count == history.index ? history.count : history.max;
			count = 0;
			offset = history.index;
			
			while (count < max) {
				
				if (offset <= 0) {
					offset = history.max;
				}
				
				x = history.coordinates[offset-2];
				y = history.coordinates[offset-1];
				
				x += sinf(offset * .25);
				y += cosf(offset * .25);
				
				count+=2;
				offset-=2;
				
				if (!corrected) {
					
					// get distance to missile position
					vx = x - actor.position.x + actor.velocity.x;
					vy = y - actor.position.y + actor.velocity.y;
					d = vx * vx + vy * vy;
					
					if (d > 16.0) {
						
						addCoordinateToLine((actor.position.x + (actor.velocity.x * interpolation)) * scale, 
											(actor.position.y + (actor.velocity.y * interpolation)) * scale, 0.0, &missileTrail);
						
						corrected = YES;
					}
					else {
						continue;
					}
				}
				
				addCoordinateToLine(x * scale, y * scale, 0.0, &missileTrail);
			}
			
			if ([actor.state contains:STATE_DYING]) {
				
				ColorResetAlpha(&missileTrail.color, (actor.state.lifespan - actor.state.life)  * .05);
				
				actorVisual.x = (actor.position.x - 11.0) * scale;
				actorVisual.y = (actor.position.y - 11.0) * scale;
				actorVisual.width = 22.0 * scale;
				actorVisual.height = actorVisual.width;
				actorVisual.color = missileTrail.color;
				actorVisual.uv = missileTrailEndUV;
				[[RenderEngine singleton] addQuad:&actorVisual];
				
			}
			else {
				ColorReset(&missileTrail.color);
			}
			
			[[RenderEngine singleton] addLine:&missileTrail];
			
			missileTrail.coordinateCount = 0;
			
		}
		else if ([actor isKindOfClass:[SatelliteActor class]]) {
			
			float a = .5;
			
			if (actor.position.x > 43.5) {
				a = .25;
			}
			
			actorVisual.x = (actor.position.x + (interpolation * actor.velocity.x) - 1.0) * scale;
			actorVisual.y = (actor.position.y + (interpolation * actor.velocity.y) - 1.0) * scale;
			actorVisual.width = 2.0 * scale;
			actorVisual.height = actorVisual.width;
			actorVisual.uv = satellite;
			ColorReset(&actorVisual.color);
			actorVisual.color.a = a;
			[[RenderEngine singleton] addQuad:&actorVisual];
			
		}
		else if ([actor isKindOfClass:[MoonActor class]]){
			
			actorVisual.x = (actor.position.x + (interpolation * actor.velocity.x) - actor.radius) * scale;
			actorVisual.y = (actor.position.y + (interpolation * actor.velocity.y) - actor.radius) * scale;
			actorVisual.width = (actor.radius * 2.0) * scale;
			actorVisual.height = actorVisual.width;
			actorVisual.uv = moon;
			ColorReset(&actorVisual.color);
			[[RenderEngine singleton] addQuad:&actorVisual];
			
		}
		else {
			continue;
		}
	}
}



@end
