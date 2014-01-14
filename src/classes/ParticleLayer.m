//
//  ParticleLayer.m
//  Eve of Impact
//
//  Created by Rik Schennink on 11/29/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "ParticleLayer.h"
#import "ApplicationModel.h"
#import "Prefs.h"
#import "Easing.h"
#import "RenderEngine.h"
#import "Particle.h"
#import "ParticleManager.h"


@implementation ParticleLayer

-(id)initWithModel:(ApplicationModel*)applicationModel {
	
	if (self = [super init]) {
		
		manager = applicationModel.particleManager;
		
		scale = IS_IPAD ? 2.0 : 1.0;
		
		mapDust = UVMapMake(121, 440, 7, 7);
		mapFire = UVMapMake(121, 433, 7, 7);
		
		particle = QuadTemplateMake(0, 0, 0, 0, 0, ColorMakeFast(), mapDust);
		opacityFraction = 1.0 / PARTICLE_DROP;
	}
	
	return self;
}

-(void)redraw:(float)interpolation {
		
	ScreenBorders borders = [[RenderEngine singleton] getScreenBordersByGutter:0];
	
	float o;
	uint i;
	Particle *p;
	[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
	
	for (i=0;i<PARTICLE_LIMIT;i++) {
		
		p = &manager.particles[i];
		
		if (p->life > 0) {
			
			// check if particle is visible
			if (!isVisible(p->position.x, p->position.y, &borders)) {
				continue;
			}
			
			// calculate particle opacity
			o = p->life <= PARTICLE_DROP ? p->life * opacityFraction : 1.0;
			
			// define particle
			particle.x = (p->position.x + (p->velocity.x * interpolation) - p->radius) * scale;
			particle.y = (p->position.y + (p->velocity.y * interpolation) - p->radius) * scale;
			particle.width = (p->radius * 2.0) * scale;
			particle.height = particle.width;
			particle.color.r = 255;
			particle.color.g = 255;
			particle.color.b = 255;
			particle.color.a = PARTICLE_OPACITY_MAX * o;
			particle.uv = mapDust;
			[[RenderEngine singleton] addQuad:&particle];
			
			if (p->temperature > 0.0) {
				
				particle.x = particle.x - (p->radius * scale);
				particle.y = particle.y - (p->radius * scale);
				particle.width = p->radius * 4.0 * scale;
				particle.height = particle.width;
				particle.color.a = MIN(o,p->temperature);
				
				if (p->plasma) {
					particle.color.r = 140;
					particle.color.g = 210;
					particle.color.b = 255;
				}
				else {
					particle.uv = mapFire;
				}
				
				[[RenderEngine singleton] setActiveVertexBuffer:VBO_ALT];
				[[RenderEngine singleton] addQuad:&particle];
				[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
				
			}
		}
	}
}

@end
