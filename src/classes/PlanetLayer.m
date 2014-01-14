//
//  PlanetLayer.m
//  Eve of Impact
//
//  Created by Rik Schennink on 6/1/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "PlanetLayer.h"
#import "ApplicationModel.h"

// renderer
#import "RenderEngine.h"
#import "Texture.h"
#import "ResourceManager.h"
#import "Common.h"
#import "Easing.h"
#import "MathAdditional.h"
#import "PlanetActor.h"
#import "ImpactActor.h"
#import "ShieldActor.h"

@implementation PlanetLayer


-(id)initWithModel:(ApplicationModel*)applicationModel {
	
	if ((self = [super init])) {
		
		model = applicationModel;
		
		scale = IS_IPAD ? 2.0 : 1.0;
		
		// set shockwave shadow
		shockwaveShadow = RingTemplateMakeEmpty();
		shockwaveShadow.uv = UVMapMake(259, 314, 82, 28);
		shockwaveShadow.segments = IS_IPAD ? 28 : 24;
		
		// set shockwave fire
		shockwaveFire = RingTemplateMakeEmpty();
		shockwaveFire.uv = UVMapMake(259, 1, 72, 126);
		shockwaveFire.segments = IS_IPAD ? 28 : 24;
		
		// set shockwave inferno
		shockwaveInferno = RingTemplateMakeEmpty();
		shockwaveInferno.uv = UVMapMake(259, 129, 42, 126);
		shockwaveInferno.segments = IS_IPAD ? 28 : 24;
		
		// set shockwave glow
		shockwaveGlow = QuadTemplateMakeEmpty();
		shockwaveGlow.uv = UVMapMake(81, 449, 15, 15);
		
		// set shockwave mask
		shockwaveMask = RingTemplateMakeEmpty();
		shockwaveMask.uv = UVMapMake(275, 363, 1, 1);
		shockwaveMask.segments = IS_IPAD ? 20 : 16;
		
		// set shockwave sprite
		shockwaveSprite = QuadTemplateMakeFast(0, 0, 64.0 * scale, 1.0,  UVMapMakeSize(0, 0, 64, 64, 64));
				
		// set planet overlay
		planetOverlay = QuadTemplateMakeEmpty();
		planetOverlay.x = 0.5 * scale;
		planetOverlay.y = 0.0;
		planetOverlay.width = 55.5 * scale;
		planetOverlay.height = 55.0 * scale;
		planetOverlay.uv = UVMapMake(2,361,64,64);
		
		// set planet overlay shadow
		planetShadow = QuadTemplateMakeEmpty();
		planetShadow.x = 7.0 * scale;
		planetShadow.width = 62.0 * scale;
		planetShadow.height = 75.0 * scale;
		planetShadow.uv = UVMapMake(1,313,35,46);
		
		// set planet mask
		planetMask = QuadTemplateMakeFast(0.0, 0.0, 70.0 * scale, 1.0, UVMapMake(273,361,70,70));
		
		// set planet sprite
		planetSprite = QuadTemplateMakeFast(0.0, 0.0, 65.0 * scale, 1.0,  UVMapMakeSize(0, 0, 64, 64, 64));
		
		// set buffer
		VertexBuffer planet = VertexBufferMake();
		[[RenderEngine singleton] addVertexBuffer:planet at:VBO_STATIC_PLANET];
		
		// build planet destroyed vertices
		VertexBuffer destroyedPlanet = VertexBufferMake();
		[[RenderEngine singleton] addVertexBuffer:destroyedPlanet at:VBO_STATIC_PLANET_DESTROYED];
		
		// build planet model
		VertexData tl,tr,bl,br;
		uint count,i,j,precision = 16;
		double theta1,theta2,theta3,theta4;
		float radius = PLANET_RADIUS * scale;
		count = 0;
		ColorRaw color = ColorRawMakeFast();
		
		for (j=0;j<precision/2;j++) {
			
			theta1 = j * TRIG_PI_M_2 / precision - TRIG_PI_D_2;
			theta2 = (j + 1) * TRIG_PI_M_2 / precision - TRIG_PI_D_2;
			
			for (i=0;i<precision;i++) {
				
				theta3 = i * TRIG_PI_M_2 / precision;
				theta4 = (i+1) * TRIG_PI_M_2 / precision;
				
				//top left
				tl = VertexDataMake(cos(theta2) * cos(theta3) * radius,
											   sin(theta2) * radius,
											   cos(theta2) * sin(theta3) * radius,
											   1.0/TEXTURE_ATLAS_DEFAULT_SIZE + ((i/(double)precision) * .25),
											   ((2*(j+1)/(double)precision) * .125),
											   color);
				
				// top right
				tr = VertexDataMake(cos(theta2) * cos(theta4) * radius,
											   sin(theta2) * radius,
											   cos(theta2) * sin(theta4) * radius,
											   1.0/TEXTURE_ATLAS_DEFAULT_SIZE + (((i+1)/(double)precision) * .25),
											   ((2*(j+1)/(double)precision) * .125),
											   color);
				
				// bottom left
				bl = VertexDataMake(cos(theta1) * cos(theta4) * radius,
											   sin(theta1) * radius,
											   cos(theta1) * sin(theta4) * radius,
											   1.0/TEXTURE_ATLAS_DEFAULT_SIZE + (((i+1)/(double)precision) * .25),
											   ((2*j/(double)precision) * .125),
											   color);
				
				// bottom right
				br = VertexDataMake(cos(theta1) * cos(theta3) * radius,
											   sin(theta1) * radius,
											   cos(theta1) * sin(theta3) * radius,
											   1.0/TEXTURE_ATLAS_DEFAULT_SIZE + ((i/(double)precision) * .25),
											   ((2*j/(double)precision) * .125),
											   color);
				
				[[RenderEngine singleton] setActiveVertexBuffer:VBO_STATIC_PLANET];
				
				[[RenderEngine singleton] addIndex:count];
				[[RenderEngine singleton] addIndex:count+1];
				[[RenderEngine singleton] addIndex:count+2];
				[[RenderEngine singleton] addIndex:count+1];
				[[RenderEngine singleton] addIndex:count];
				[[RenderEngine singleton] addIndex:count+3];
				
				[[RenderEngine singleton] addVertex:br];
				[[RenderEngine singleton] addVertex:tr];
				[[RenderEngine singleton] addVertex:tl];
				[[RenderEngine singleton] addVertex:bl];
				
				[[RenderEngine singleton] setActiveVertexBuffer:VBO_STATIC_PLANET_DESTROYED];
				
				br.uv.v+=.125;
				tr.uv.v+=.125;
				tl.uv.v+=.125;
				bl.uv.v+=.125;
				
				[[RenderEngine singleton] addIndex:count];
				[[RenderEngine singleton] addIndex:count+1];
				[[RenderEngine singleton] addIndex:count+2];
				[[RenderEngine singleton] addIndex:count+1];
				[[RenderEngine singleton] addIndex:count];
				[[RenderEngine singleton] addIndex:count+3];
				
				[[RenderEngine singleton] addVertex:br];
				[[RenderEngine singleton] addVertex:tr];
				[[RenderEngine singleton] addVertex:tl];
				[[RenderEngine singleton] addVertex:bl];
				
				count+=4;
			}
		}
		
		
	}
	
	return self;
}

-(void)redraw:(float)interpolation {
	
	
	
	ScreenBorders borders = [[RenderEngine singleton] getScreenBordersByGutter:40.0 * scale];
	if (!isVisible(0,0,&borders)) {
		return;
	}
	
	PlanetActor* planet = model.planet;
	
	Vector camera = [[RenderEngine singleton] getCameraOffset];
	
	float rotation = -((planet.state.life + interpolation) * .15) -80.0; // -80 planet offset to have it start @ europe
	
	Transform cameraOffset = TransformMake(TRANSFORM_TRANSLATE, 0.0, Transform3DMake(camera.x,camera.y,0.0f));
	Transform transformScale = TransformMake(TRANSFORM_SCALE, 0.0, Transform3DMake(1.02f, 1.0f, 1.0f));
	Transform rotationX = TransformMake(TRANSFORM_ROTATE, -12.5 - ((-camera.y * 0.125f) / (scale * scale)), Transform3DMake(1.0f,0.0f,0.0f));
	Transform rotationY = TransformMake(TRANSFORM_ROTATE, rotation, Transform3DMake(0.0f,1.0f,0.0f));
	
	// render planet
	[[RenderEngine singleton] setActiveVertexBuffer:VBO_STATIC_PLANET];
	[[RenderEngine singleton] resetTransformsOfActiveVertexBuffer];
	[[RenderEngine singleton] addTransformToActiveVertexBuffer:cameraOffset];
	[[RenderEngine singleton] addTransformToActiveVertexBuffer:transformScale];
	[[RenderEngine singleton] addTransformToActiveVertexBuffer:rotationX];
	[[RenderEngine singleton] addTransformToActiveVertexBuffer:rotationY];
	[[RenderEngine singleton] enableCulling];
	[[RenderEngine singleton] renderActiveVertexBuffer];
	[[RenderEngine singleton] disableCulling];
	
	
	// set current planet state
	BOOL isDying = [planet.state contains:STATE_DYING];
	BOOL isDead = [planet.state contains:STATE_DEAD];
	uint impactCount = [planet.impacts count];
	float ratio;
	
	
	
	
	
	
	
	// if earth is being destroyed do all the stuff below
	if (isDying || isDead) {
		
		// DRAW DESTROYED PLANET FBO
		
		// bind new framebuffer to render destroyed planet to
		[[RenderEngine singleton] setActiveFrameBuffer:FBO_PLANET_DESTROYED];
		[[RenderEngine singleton] clearActiveFrameBuffer];
		[[RenderEngine singleton] set2DProjection];
		
		if (impactCount > 0) {
			
			// render masks to fbo
			[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
			
			for (ImpactActor* impact in planet.impacts) {
				shockwaveMask.x = impact.position.x * scale;
				shockwaveMask.y = impact.position.y * scale;
				shockwaveMask.radius = impact.state.life * SHOCKWAVE_RADIUS_LIFE_RATIO * scale;
				shockwaveMask.width = shockwaveMask.radius;
				[[RenderEngine singleton] addRing:&shockwaveMask withMode:RING_MODE_INSIDE];
			}
			
			[[RenderEngine singleton] renderActiveVertexBuffer];
			[[RenderEngine singleton] flushActiveVertexBuffer];
			
			if (!isDead) {
				[[RenderEngine singleton] setActiveBlendMode:BLEND_MODE_MASK];
			}
		}
		
		// render planet
		[[RenderEngine singleton] setActiveVertexBuffer:VBO_STATIC_PLANET_DESTROYED];
		[[RenderEngine singleton] resetTransformsOfActiveVertexBuffer];
		[[RenderEngine singleton] addTransformToActiveVertexBuffer:transformScale];
		[[RenderEngine singleton] addTransformToActiveVertexBuffer:rotationX];
		[[RenderEngine singleton] addTransformToActiveVertexBuffer:rotationY];
		[[RenderEngine singleton] enableCulling];
		[[RenderEngine singleton] renderActiveVertexBuffer];
		[[RenderEngine singleton] disableCulling];
		
		// add shockwave shadows
		if (impactCount > 0) {
			
			[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
			
			for (ImpactActor* impact in planet.impacts) {
				
				ratio = easeLinear(impact.state.life, 100);
				ratio = fmin(ratio, 1.0);
				
				shockwaveShadow.width = 20.0 * ratio * scale;
				shockwaveShadow.x = impact.position.x * scale;
				shockwaveShadow.y = impact.position.y * scale;
				shockwaveShadow.radius = impact.state.life * SHOCKWAVE_RADIUS_LIFE_RATIO * scale;
				
				[[RenderEngine singleton] addRing:&shockwaveShadow];
			}
			
			[[RenderEngine singleton] setActiveBlendMode:BLEND_MODE_DEFAULT];
			[[RenderEngine singleton] renderActiveVertexBuffer];
			[[RenderEngine singleton] flushActiveVertexBuffer];
		}
		
		 
		// render additional mask to cut of overdrawing
		[[RenderEngine singleton] setActiveBlendMode:BLEND_MODE_MASK_ALT];
		[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
		[[RenderEngine singleton] addCenteredQuad:&planetMask];
		[[RenderEngine singleton] renderActiveVertexBuffer];
		[[RenderEngine singleton] flushActiveVertexBuffer];
		
		if (impactCount > 0) {
			
			// DRAW SHOCKWAVE FBO
			
			// bind new framebuffer to render destroyed planet to
			[[RenderEngine singleton] setActiveFrameBuffer:FBO_PLANET_SHOCKWAVE];
			[[RenderEngine singleton] clearActiveFrameBuffer];
			[[RenderEngine singleton] set2DProjection];
			[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
			
			// add shockwave fire effects
			for (ImpactActor* impact in planet.impacts) {
				
				ratio = easeLinear(impact.state.life, 100);
				ratio = fmin(ratio, 1.0);
				
				// reset width
				shockwaveFire.width = 16.0 * ratio * scale;
				
				// set origin
				shockwaveFire.x = impact.position.x * scale;
				shockwaveFire.y = impact.position.y * scale;
				
				// set current radius
				shockwaveFire.radius = -1.0 * ratio * scale; // offset
				shockwaveFire.radius += impact.state.life * SHOCKWAVE_RADIUS_LIFE_RATIO * scale;
				
				// scale down shockwave when it reaches other side of planet
				if (impact.state.life > 300) {
					
					ratio = easeLinear(impact.state.life - 300, 100);
					
					shockwaveFire.width = (16.0 - (ratio * 8.0)) * scale;
				}
				
				[[RenderEngine singleton] addRing:&shockwaveFire];
			}
			
			// add shockwave inferno effects
			for (ImpactActor* impact in planet.impacts) {
				
				ratio = easeLinear(impact.state.life, 100);
				ratio = fmin(ratio, 1.0);
				
				// reset width
				shockwaveInferno.width = 8.0 * ratio * scale;
				
				// set origin
				shockwaveInferno.x = impact.position.x * scale;
				shockwaveInferno.y = impact.position.y * scale;
				
				// set current radius
				shockwaveInferno.radius = 2.0 * ratio * scale; // offset
				shockwaveInferno.radius += impact.state.life * SHOCKWAVE_RADIUS_LIFE_RATIO * scale;
				
				// scale down shockwave when it reaches other side of planet
				if (impact.state.life > 300) {
					
					ratio = easeLinear(impact.state.life - 300, 100);
					shockwaveInferno.width = (8.0 - (ratio * 4.0)) * scale;
				}
				
				
				[[RenderEngine singleton] addRing:&shockwaveInferno];
			}
			
			// render everything
			[[RenderEngine singleton] setActiveBlendMode:BLEND_MODE_DEFAULT];
			[[RenderEngine singleton] renderActiveVertexBuffer];
			[[RenderEngine singleton] flushActiveVertexBuffer];
			
			// render additional mask to cut of overdrawing
			[[RenderEngine singleton] setActiveBlendMode:BLEND_MODE_MASK_ALT];
			[[RenderEngine singleton] addCenteredQuad:&planetMask];
			[[RenderEngine singleton] renderActiveVertexBuffer];
			[[RenderEngine singleton] flushActiveVertexBuffer];
		}
		
		
		// bind default framebuffer and reset projection
		[[RenderEngine singleton] setActiveFrameBuffer:FBO_DEFAULT];
		[[RenderEngine singleton] set2DProjection];
		
		// render destroyed planet sprite
		[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
		[[RenderEngine singleton] resetTransformsOfActiveVertexBuffer];
		[[RenderEngine singleton] addTransformToActiveVertexBuffer:cameraOffset];
		[[RenderEngine singleton] setActiveTexture:TEXTURE_PLANET_VISUAL];
		planetSprite.x = planet.position.x;
		planetSprite.y = planet.position.y;
		[[RenderEngine singleton] addCenteredQuad:&planetSprite];
		[[RenderEngine singleton] setActiveBlendMode:BLEND_MODE_DEFAULT];
		[[RenderEngine singleton] renderActiveVertexBuffer];
		[[RenderEngine singleton] flushActiveVertexBuffer];
		
		// rebind texture atlas
		[[RenderEngine singleton] setActiveTexture:TEXTURE_DEFAULT];
		
	}
	
	
	// render planet overlay, does some fake shadows and antialiasing on edges of planet
	[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
	[[RenderEngine singleton] resetTransformsOfActiveVertexBuffer];
	[[RenderEngine singleton] addTransformToActiveVertexBuffer:cameraOffset];
	[[RenderEngine singleton] addCenteredQuad:&planetOverlay];
	[[RenderEngine singleton] addCenteredQuad:&planetShadow];
	[[RenderEngine singleton] setActiveBlendMode:BLEND_MODE_DEFAULT];
	[[RenderEngine singleton] renderActiveVertexBuffer];
	[[RenderEngine singleton] flushActiveVertexBuffer];
	
	
	// render shockwave effects now
	if (impactCount > 0) {
		
		// add shockwave fire edge effects
		float angle,offset,distance,ratio;
		float opacity;
		for (ImpactActor* impact in planet.impacts) {
			
			ratio = 0.0;
			opacity = 1.0;
			
			if (impact.state.life < 175) {
			
				ratio = easeLinear(impact.state.life, 175);
				
				offset = impact.state.life * SHOCKWAVE_RADIUS_LIFE_RATIO * ((.05 * (1.0 - ratio)) + (.047 * ratio));
				
			}
			else if (impact.state.life < 300) {
				
				offset = impact.state.life * SHOCKWAVE_RADIUS_LIFE_RATIO * .047;
				
			}
			else if (impact.state.life < 400) {
				
				ratio = easeLinear(impact.state.life - 300, 100);
				
				offset = impact.state.life * SHOCKWAVE_RADIUS_LIFE_RATIO * (.047 + (.008 * ratio));
				
				opacity = 1.0 - ratio;
				
			}
			else {
				continue;
			}

			distance = planet.radius - .5;
			angle = ((atan2(-impact.position.y,-impact.position.x) * TRIG_180_D_PI) + 180.0) * TRIG_PI_D_180;
			
			shockwaveGlow.color = ColorMakeByOpacity(opacity);
			shockwaveGlow.x = cos(angle - offset) * distance * scale;
			shockwaveGlow.y = sin(angle - offset) * distance * scale;
			shockwaveGlow.width = 8.0 * scale;
			shockwaveGlow.height = shockwaveGlow.width;
			[[RenderEngine singleton] addCenteredQuad:&shockwaveGlow];
			
			shockwaveGlow.x = cos(angle + offset) * distance * scale;
			shockwaveGlow.y = sin(angle + offset) * distance * scale;
			[[RenderEngine singleton] addCenteredQuad:&shockwaveGlow];
			
		}
		
		[[RenderEngine singleton] renderActiveVertexBuffer];
		[[RenderEngine singleton] flushActiveVertexBuffer];
		
		
		// render destroyed planet sprite
		[[RenderEngine singleton] setActiveTexture:TEXTURE_SHOCKWAVE_VISUAL];
		shockwaveSprite.x = planet.position.x;
		shockwaveSprite.y = planet.position.y;
		[[RenderEngine singleton] addCenteredQuad:&shockwaveSprite];
		[[RenderEngine singleton] renderActiveVertexBuffer];
		[[RenderEngine singleton] flushActiveVertexBuffer];
		
		// rebind texture atlas
		[[RenderEngine singleton] setActiveBlendMode:BLEND_MODE_DEFAULT];
		[[RenderEngine singleton] setActiveTexture:TEXTURE_DEFAULT];
		
		
	}
	
}


@end
