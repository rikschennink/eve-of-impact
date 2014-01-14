//
//  EffectsLayer.m
//  Eve of Impact
//
//  Created by Rik Schennink on 4/12/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "ActorBase.h"
#import "ApplicationModel.h"
#import "DebreeActor.h"
#import "Prefs.h"
#import "EffectsLayer.h"
#import "Easing.h"
#import "NukeExplosionActor.h"
#import "ShuttleExplosionActor.h"
#import "ImpactActor.h"
#import "ShieldImpactActor.h"
#import "PlanetImpactActor.h"
#import "MathAdditional.h"
#import "Easing.h"
#import "MissileActor.h"
#import "SatelliteActor.h"
#import "MoonActor.h"
#import "ParticleManager.h"
#import "PlanetActor.h"
#import "RenderEngine.h"
#import "AsteroidActor.h"
#import "ShieldActor.h"
#import "ShieldShockwaveActor.h"
#import "ShipActorBase.h"
#import "ShipActor.h"
#import "Burnable.h"
#import "Pulse.h"
#import "PlanetDebreeActor.h"

@implementation EffectsLayer

-(id)initWithModel:(ApplicationModel*)applicationModel {
	
	if ((self = [super init])) {
		
		model = applicationModel;
		
		scale = IS_IPAD ? 2.0 : 1.0;
		
		explosionCoreUV = UVMapMake(50,490,20,20);
		explosionGlowUV = UVMapMake(218,362,51,51);
		explosionGlareUV = UVMapMake(193,313,46,46);
		explosionDotsUV = UVMapMake(295, 513, 97, 97);
		explosionRingUV = UVMapMake(315, 137, 20, 110);
		explosionDebreeUV = UVMapMake(73, 361, 70, 70);
		
		debreeGlowUV = UVMapMake(1, 489, 22, 22);
		shuttleCoreUV = UVMapMake(26,490,20,20);
		
		
		impactGlareUV = UVMapMake(98,314,41,41);
		impactCoreUV = UVMapMake(65,449,13,13);
		impactRingUV = UVMapMake(180,445,19,31);
		
		missileGlowUV = UVMapMake(1,489,22,22);
		planetGlareUV = UVMapMake(2,313,46,46);
		
		flareUV = UVMapMake(2,273,71,5);
		WMDUV = UVMapMake(288, 129, 28, 126);
		planetDestroyedGlareUV = UVMapMake(145,313,46,46);
		shardUV = UVMapMake(122,434,5,5); 
		satGlowUV = UVMapMake(114, 451, 11, 11);
		
		moonGlareUV = UVMapMake(75,313,21,34);
		planetGlareLeftUV = UVMapMake(37, 313, 37, 46);
		planetGlareRightUV = UVMapMake(145, 361, 69, 69);
		planetGlareBurnUV = UVMapMake(1, 513, 87, 87);
		planetGlareRightBurnUV = UVMapMake(415, 361, 70, 70);
		
		debreeBurnUV = UVMapMake(121, 433, 7, 7);
		asteroidBurnUV = UVMapMake(97, 287, 23, 24);
		
		shieldShimmerUV = UVMapMake(89, 513, 89, 89);
		shieldShockUV = UVMapMake(1, 603, 94, 94);
		shieldImpactGlowUV = UVMapMake(417, 433, 55, 55);
		shieldChargeUV = UVMapMake(96, 603, 94, 94);
		
		impactSpot = QuadTemplateMake(0, 0, 0, 0, 0, ColorMake(255, 255, 255, 1.0), UVMapMake(200, 432, 57, 57));
		impactGlow = QuadTemplateMake(0, 0, 0, 0, 0, ColorMake(255, 255, 255, 1.0), UVMapMake(258, 432, 57, 57));
		impactGlimmers = [[PulseManager alloc] initWithAmount:3];
		
		shieldGlimmer = [[Pulse alloc]initWithPeriod:RangeMake(1, 5)];
	}
	
	return self;
	
}



-(void)redraw:(float)interpolation {
	
	[shieldGlimmer update];
	[impactGlimmers update];
	
	float a,progress,temperature;
	QuadTemplate effect = QuadTemplateMakeEmpty();
	RingTemplate ring = RingTemplateMakeEmpty();
	
	for (ActorBase* actor in model.world.actors) {
		
		[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
		
		
		if ([actor isKindOfClass:[PlanetDebreeActor class]]) {
			
			progress = [actor.state progress];
			
			effect.width = 28 * scale;
			effect.height = effect.width;
			effect.x = (actor.position.x + (actor.velocity.x * interpolation) - 14) * scale;
			effect.y = (actor.position.y + (actor.velocity.y * interpolation) - 14) * scale;
			effect.uv = debreeGlowUV;
			effect.color = ColorMake(255, 100, 0, .35);
			
			[[RenderEngine singleton] setActiveVertexBuffer:VBO_ALT];
			[[RenderEngine singleton] addQuad:&effect];
			
			effect.color.a = .15;
			[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
			[[RenderEngine singleton] addQuad:&effect];
						
		}
		
		if ([actor conformsToProtocol:@protocol(Burnable)]) {
			
			temperature = ((ActorBase<Burnable>*)actor).temperature;
			
			if (temperature > 0.0) {
				
				effect.x = (actor.position.x + (actor.velocity.x * interpolation)) * scale;
				effect.y = (actor.position.y + (actor.velocity.y * interpolation)) * scale;
				effect.width = ([actor isKindOfClass:[DebreeActor class]] ? 3.0 : actor.mass + 8.5) * scale;
				effect.height = effect.width;
				effect.uv = asteroidBurnUV;
				ColorResetAlpha(&effect.color,fmin(1.0,temperature * 2.0));
				[[RenderEngine singleton] addQuad:&effect andRotateBy:270 + atan2(actor.velocity.x,actor.velocity.y) * TRIG_180_D_PI];
			
			}
		}
		else if ([actor isKindOfClass:[SatelliteActor class]]) {
			
			if (actor.position.x < 43.5) {
				
				a = 1.0;
				
				if (actor.position.x > 42.0) {
					a = easeLinear(43.5 - actor.position.x, 1.5);
				}
				
				effect.x = (actor.position.x + (actor.velocity.x * interpolation) - 5.5) * scale;
				effect.y = (actor.position.y + (actor.velocity.y * interpolation) - 5.5) * scale;
				effect.width = 11.0 * scale;
				effect.height = effect.width;
				effect.uv = satGlowUV;
				ColorResetAlpha(&effect.color,(a * .2) + (shieldGlimmer.intensity * .1));
				[[RenderEngine singleton] addQuad:&effect];
				
			}
			
		}
		else if ([actor isKindOfClass:[NukeExplosionActor class]]) {
			
			NukeExplosionActor* explosion = (NukeExplosionActor*)actor;
			
			// get explosion state progress
			progress = fmin(1.0,easeLinear(explosion.state.life + interpolation, explosion.state.lifespan));
			
			float offset;
			float shrink = 1.0;
			if (progress > .75) {
				shrink = 1.0 - easeLinear(progress - .75, .25);
			}
			
			// draw explosion glow
			[[RenderEngine singleton] setActiveVertexBuffer:VBO_ALT];
			effect.x = (explosion.position.x - explosion.shockwaveRadius) * scale;
			effect.y = (explosion.position.y - explosion.shockwaveRadius) * scale;
			effect.width = (progress * explosion.shockwaveRadiusMax * 2.0) * scale;
			effect.height = effect.width;
			effect.uv = explosionGlowUV;
			ColorApply(&effect.color, 255, 100, 0, shrink * .5);
			[[RenderEngine singleton] addQuad:&effect];
			
			[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
			effect.uv = explosionGlareUV;
			[[RenderEngine singleton] addQuad:&effect];
			
			[[RenderEngine singleton] setActiveVertexBuffer:VBO_ALT];
			ring.x = explosion.position.x * scale;
			ring.y = explosion.position.y * scale;
			ring.radius = (progress * explosion.shockwaveRadiusMax) * scale;
			ring.width = 5.0 * scale;
			ring.uv	= explosionRingUV;
			ring.segments = IS_IPAD ? 32 : 24;
			ColorResetAlpha(&ring.color,shrink);
			[[RenderEngine singleton] addRing:&ring];
			
			// draw core of explosion
			effect.width = (explosion.radius * shrink * 2.0) * scale;
			effect.height = effect.width;
			offset = effect.width * .5;
			effect.x = (explosion.position.x * scale) - offset;
			effect.y = (explosion.position.y * scale) - offset;
			effect.uv = explosionCoreUV;
			ColorResetAlpha(&effect.color,shrink);
			[[RenderEngine singleton] addQuad:&effect];
			
			[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
			
			effect.width = (explosion.radius * 2.25 * shrink) * scale;
			effect.height = effect.width;
			offset = effect.width * .5;
			effect.x = (explosion.position.x * scale) - offset;
			effect.y = (explosion.position.y * scale) - offset;
			[[RenderEngine singleton] addQuad:&effect];
			
		}
		else if ([actor isKindOfClass:[ShuttleExplosionActor class]]) {
			
			ShuttleExplosionActor* explosion = (ShuttleExplosionActor*)actor;
			
			
			// get explosion state progress
			progress = fmin(1.0,easeLinear(explosion.state.life + interpolation, explosion.state.lifespan));
			
			float offset;
			float shrink = 1.0;
			if (progress > .75) {
				shrink = 1.0 - easeLinear(progress - .75, .25);
			}
			
			// draw explosion glow
			[[RenderEngine singleton] setActiveVertexBuffer:VBO_ALT];
			effect.width = (progress * 256.0 * shrink) * scale;
			effect.height = effect.width;
			offset = effect.width * .5;
			effect.x = (explosion.position.x * scale) - offset;
			effect.y = (explosion.position.y * scale) - offset;
			effect.uv = explosionGlareUV;
			ColorResetAlpha(&effect.color,shrink);
			[[RenderEngine singleton] addQuad:&effect];
			
			[[RenderEngine singleton] setActiveVertexBuffer:VBO_ALT];
			ring.x = actor.position.x * scale;
			ring.y = actor.position.y * scale;
			ring.radius = (progress * explosion.radiusMax) * scale;
			ring.width = (20.0 * shrink) * scale;
			ring.uv	= explosionRingUV;
			ring.segments = IS_IPAD ? 32 : 24;
			ColorResetAlpha(&ring.color,shrink);
			[[RenderEngine singleton] addRing:&ring];
			
			
			// draw core of explosion
			[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
			effect.width = (50.0 * shrink) * scale;
			effect.height = effect.width;
			offset = effect.width * .5;
			effect.x = (explosion.position.x * scale) - offset;
			effect.y = (explosion.position.y * scale) - offset;
			effect.uv = shuttleCoreUV;
			ColorResetAlpha(&effect.color,.65);
			[[RenderEngine singleton] addQuad:&effect];
			
			[[RenderEngine singleton] setActiveVertexBuffer:VBO_ALT];
			effect.width = (60.0 * shrink) * scale;
			effect.height = effect.width;
			offset = effect.width * .5;
			effect.x = (explosion.position.x * scale) - offset;
			effect.y = (explosion.position.y * scale) - offset;
			[[RenderEngine singleton] addQuad:&effect];
			
			
			
			
		}
		else if ([actor isKindOfClass:[PlanetActor class]]) {
			
			float opacity = 1.0;
			float ratio = 0.0;
			
			if ([actor.state contains:STATE_DYING]) {
				ratio = easeLinear([actor.state getLifeInState:STATE_DYING], 400);
				ratio = ratio > 1.0 ? 1.0 : ratio;
				
				opacity = 1.0 - (ratio * 1.0);
			}
			else if ([actor.state contains:STATE_DEAD]) {
				ratio = 1.0;
				opacity = 0.0;
			}
			
			
			// reset opacity and y offset
			[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
			
			
			// fake light left
			effect.x = -38.0 * scale;
			effect.y = -28.5 * scale;
			effect.width = 47.0 * scale;
			effect.height = 57.0 * scale;
			effect.uv = planetGlareLeftUV;
			ColorResetAlpha(&effect.color,.25 + (opacity * .75));
			[[RenderEngine singleton] addQuad:&effect];
			
			[[RenderEngine singleton] setActiveVertexBuffer:VBO_ALT];
			ColorResetAlpha(&effect.color,1.0);
			[[RenderEngine singleton] addQuad:&effect];
			
			
			// fake light right
			[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
			effect.x = -37.0 * scale;
			effect.y = -36.0 * scale;
			effect.width = 70.0 * scale;
			effect.height = effect.width;
			effect.uv = planetGlareRightUV;
			ColorResetAlpha(&effect.color,opacity * .65);
			[[RenderEngine singleton] addQuad:&effect];
			
			[[RenderEngine singleton] setActiveVertexBuffer:VBO_ALT];
			[[RenderEngine singleton] addQuad:&effect];
			
			
			if ([actor.state contains:STATE_DYING] || 
				[actor.state contains:STATE_DEAD]) {
				
				[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
				effect.x = -43.5 * scale;
				effect.y = effect.x;
				effect.width = 87.0 * scale;
				effect.height = effect.width;
				effect.uv = planetGlareBurnUV;
				ColorResetAlpha(&effect.color,ratio);
				[[RenderEngine singleton] addQuad:&effect];
				
				effect.x = -40.0 * scale;
				effect.y = effect.x;
				effect.width = 80.0 * scale;
				effect.height = effect.width;
				effect.uv = planetDestroyedGlareUV;
				ColorResetAlpha(&effect.color,ratio * .2);
				[[RenderEngine singleton] addQuad:&effect];
				
				[[RenderEngine singleton] setActiveVertexBuffer:VBO_ALT];
				ColorResetAlpha(&effect.color,ratio);
				[[RenderEngine singleton] addQuad:&effect];
				
				
				[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
				effect.width = 70.0 * scale;
				effect.height = effect.height;
				effect.x = -36.0 * scale;
				effect.y = -35.0 * scale;
				effect.uv = planetGlareRightBurnUV;
				ColorResetAlpha(&effect.color,ratio * .25);
				[[RenderEngine singleton] addQuad:&effect];
				
				
				[[RenderEngine singleton] setActiveVertexBuffer:VBO_ALT];
				ColorResetAlpha(&effect.color,ratio);
				[[RenderEngine singleton] addQuad:&effect];
				
			}
		}
		else if ([actor isKindOfClass:[ShieldActor class]]) {
		
			if (!(model.state == STATE_PLAYING || model.state == STATE_MENU_PAUSE)) {
				continue;
			}
			
			
			
			
			float introOpacity = 1.0;
			
			if (model.ticks < 25) {
				introOpacity = easeLinear(model.ticks, 25);
			}
			
			
			
			ShieldActor* shield = (ShieldActor*)actor;
			
			if (!shield.enabled) {
				continue;
			}
			
			float offset;
			float weakOpacity = shield.energy < SHIELD_ENERGY_WEAK ? .25 : 1.0;
			
			[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
			effect.width = actor.radius * 2.25 * scale;
			effect.height = effect.width * .9;
			offset = effect.width * .5;
			effect.x = -offset - (20.0 * scale);
			effect.y = -offset + (3.0 * scale);
			effect.uv = planetGlareLeftUV;
			ColorResetAlpha(&effect.color,fmin(1.0,.15 + (shieldGlimmer.intensity * .05 * weakOpacity) + (shield.power * .5)) * introOpacity);
			[[RenderEngine singleton] addQuad:&effect];
			
			// fake light right
			effect.width = actor.radius * 2.5 * scale;
			effect.height = effect.width;
			offset = effect.width * .5;
			effect.x = -offset;
			effect.y = -offset;
			effect.uv = planetGlareRightUV;
			ColorResetAlpha(&effect.color,fmin(1.0,(.35 + (shieldGlimmer.intensity * .1 * weakOpacity) + shield.power)) * introOpacity);
			[[RenderEngine singleton] addQuad:&effect];
			
			[[RenderEngine singleton] setActiveVertexBuffer:VBO_ALT];
			effect.x = 0.0;
			effect.y = 0.0;
			effect.width = actor.radius * 2.0 * scale;
			effect.height = effect.width;
			effect.uv = shieldShimmerUV;
			ColorReset(&effect.color);
			effect.color.a = introOpacity;
			
			float rotation = (shield.state.life + interpolation) * .5;
			[[RenderEngine singleton] addQuad:&effect andRotateBy:rotation];
			
			
			if (shield.energy <= SHIELD_ENERGY_WEAK && shield.state.life%2==0 && mathRandom() < .5) {
				effect.x = 0.0;
				effect.y = 0.0;
				effect.width = 94.0 * scale;
				effect.height = effect.width;
				effect.uv = shieldShockUV;
				effect.color.a = shieldGlimmer.intensity;
				[[RenderEngine singleton] addQuad:&effect andRotateBy:rotation];
			}
			
			
			if (shield.power > 0.0) {
				
				float p = easeInSine(shield.power, SHIELD_OVERLOAD_ENERGY);
				
				rotation = mathRandom() * 360.0;
				effect.x = 0.0;
				effect.y = 0.0;
				effect.width = 94.0 * scale;
				effect.height = effect.width;
				effect.uv = shieldChargeUV;
				effect.color.a = fmin(p,mathRandom());
				[[RenderEngine singleton] addQuad:&effect andRotateBy:rotation];
				
				rotation = mathRandom() * 360.0;
				effect.uv = shieldShockUV;
				[[RenderEngine singleton] addQuad:&effect andRotateBy:rotation];
			}
			
			
						
		}
		else if ([actor isKindOfClass:[ShieldShockwaveActor class]]) {
			
			[[RenderEngine singleton] setActiveVertexBuffer:VBO_ALT];
			ring.x = 0;
			ring.y = 0;
			ring.radius = actor.radius * scale;
			ring.width = 15.0 * scale;
			ring.uv	= explosionRingUV;
			ring.segments = IS_IPAD ? 48 : 32;
			ColorResetAlpha(&ring.color,1.0);
			[[RenderEngine singleton] addRing:&ring];
			
		}
		else if ([actor isKindOfClass:[MoonActor class]]) {
			
			[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
			effect.x = (actor.position.x + (actor.velocity.x * interpolation) - 16.5) * scale;
			effect.y = (actor.position.y + (actor.velocity.x * interpolation) - 17.0) * scale;
			effect.width = 21.0 * scale;
			effect.height = 34.0 * scale;
			effect.uv = moonGlareUV;
			ColorReset(&effect.color);
			[[RenderEngine singleton] addQuad:&effect];
			
		}
		else if ([actor isKindOfClass:[ShipActorBase class]]) {
			
			if (actor.state.life < 40) {
				
				ShipActorBase* ship = (ShipActorBase*)actor;
				
				float shipScale;
				
				if ([ship isKindOfClass:[ShipActor class]]) {
					shipScale = 1.0 * scale;
				}
				else {
					// pod
					shipScale = .75 * scale;
				}
				
				float liftOff = 1.0 - easeInQuintic(actor.state.life,40);
				
				effect.uv = satGlowUV;
				
				effect.width = 20.0 * shipScale;
				effect.height = effect.width;
				float offset = effect.width *.5;
				effect.x = (ship.origin.x * scale) - offset;
				effect.y = (ship.origin.y * scale) - offset;
				
				[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
				effect.color.a = liftOff * .5;
				[[RenderEngine singleton] addQuad:&effect];
				
				
				[[RenderEngine singleton] setActiveVertexBuffer:VBO_ALT];
				effect.width = 10.0 * shipScale;
				effect.height = effect.width;
				offset = effect.width * .5;
				effect.x = (ship.origin.x * scale) - offset;
				effect.y = (ship.origin.y * scale) - offset;
				effect.color.a = liftOff;
				[[RenderEngine singleton] addQuad:&effect];

			}
			
		}
		else if ([actor isKindOfClass:[ImpactActor class]]) {
			
			ImpactActor* impact = (ImpactActor*)actor;
			
			float offset;
			float progress = fmin(1.0,easeLinear(actor.state.life + interpolation, actor.state.lifespan));
			float radius = 0.0;
			
			
			if (actor.state.life < 5) {
				radius = fmax(2,actor.mass) * fmin(1.0,easeOutSine(actor.state.life + interpolation, 5));
			}
			else if (actor.state.life < 50) {
				radius = fmax(2,actor.mass) * (1.0 - fmin(1.0, easeInOutSine(actor.state.life + interpolation - 5, 45)));
			}

			
			if ([actor isKindOfClass:[ShieldImpactActor class]]) {
				
				progress = fmin(1.0,easeOutSine(actor.state.life + interpolation, actor.state.lifespan));
				float impactScale = progress * fmin(20.0,impact.mass * 8.0);
				float falloff = actor.state.life > 50 ? fmin(1.0,easeLinear(actor.state.life + interpolation - 50, 50)): 0.0;
				
				Vector d;
				d.x = -actor.position.x;
				d.y = -actor.position.y;
				vectorNormalize(&d);
				
				[[RenderEngine singleton] setActiveVertexBuffer:VBO_ALT];
				effect.x = (actor.position.x + (2.0 * d.x) + (impactScale * d.x * 1.25)) * scale;
				effect.y = (actor.position.y + (2.0 * d.y) + (impactScale * d.y * 1.25)) * scale;
				effect.width = (5.0 + impactScale * 1.5) * scale;
				effect.height = effect.width * 2.5;
				effect.uv = impactRingUV;
				ColorResetAlpha(&effect.color, 1.0 - falloff);
				
				float rotation = 270 + atan2(-actor.position.x,-actor.position.y) * TRIG_180_D_PI;
				
				[[RenderEngine singleton] addQuad:&effect andRotateBy:rotation];
				[[RenderEngine singleton] addQuad:&effect andRotateBy:rotation];
				
				effect.uv = shieldImpactGlowUV;
				[[RenderEngine singleton] addQuad:&effect andRotateBy:rotation];
				
			}
			else if ([actor isKindOfClass:[PlanetImpactActor class]]) {
				
				uint speed = 1000;
				float offset = 0.0;
				float burnoutScalar = 0.0;
				Vector impactScale;
				
				impactScale.x = fabs(fabs(-1.0 + (easeFastSlowFast(actor.state.life, speed) * 2.0)) - 1.0);
				impactScale.y = 1.0 - (.5 + easeInSine(fabsf(actor.position.y), PLANET_RADIUS) * .5);
				
				if (impactScale.x > impactScale.y) {
					impactScale.x = impactScale.y;
				}
				
				if (actor.position.x < 0) {
					offset = easeLinear(actor.state.life, speed) * fabs(actor.position.x + actor.position.x);
					
					if (actor.state.life >= actor.state.lifespan - 100) {
						burnoutScalar = 1.0 - easeLinear(actor.state.life - (actor.state.lifespan - 100), 100);
					}
					else {
						burnoutScalar = 1.0;
					}
				}
				else {
					offset = 0;
					
					if (actor.state.life < 150) {
						burnoutScalar = 1.0;
						if (actor.state.life > 100) {
							burnoutScalar = 1.0 - easeLinear(actor.state.life - 100, 50);
						}
					}
					else {
						burnoutScalar = 0.0;
					}
				}
				
				float glowScalar = .3;
				if (actor.state.life < 100) {
					glowScalar = 1.0 - (easeInCubic(actor.state.life, 100) * .7);
				}
				
				
				float growScalar = 1.0;
				if (actor.state.life < 100) {
					growScalar = easeInQuartic(actor.state.life,100);
				}
				
				Pulse* pulse = [impactGlimmers getPulseByActor:actor];
				float intensityScalar = 1 + (pulse.intensity * .05);
				
				impactSpot.x = (actor.position.x + offset) * scale;
				impactSpot.y = (actor.position.y) * scale;
				float rotation = 180 - (atan2(impactSpot.y,impactSpot.x) * TRIG_180_D_PI);
				
				impactSpot.width = (fmax(12.0,45.0 * impactScale.x) * intensityScalar) * scale;
				impactSpot.height = (fmax(12.0,45.0 * impactScale.y) * intensityScalar) * scale;
				impactSpot.color.a = burnoutScalar;
				[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
				[[RenderEngine singleton] addQuad:&impactSpot andRotateBy:rotation];
				[[RenderEngine singleton] setActiveVertexBuffer:VBO_ALT];
				[[RenderEngine singleton] addQuad:&impactSpot andRotateBy:rotation];
				
				[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
				impactGlow.x = impactSpot.x;
				impactGlow.y = impactSpot.y;
				impactGlow.width = (impactSpot.width * 1.5 * glowScalar);
				impactGlow.height = (impactSpot.height * 1.5 * glowScalar);
				impactGlow.color.a = glowScalar * burnoutScalar;
				[[RenderEngine singleton] addQuad:&impactGlow andRotateBy:rotation];
				
				impactGlow.x = actor.position.x * scale;
				impactGlow.y = actor.position.y * scale;
				impactGlow.width = 45.0 * glowScalar * scale;
				impactGlow.height = impactGlow.width;
				impactGlow.color.a = glowScalar * burnoutScalar * .25;
				[[RenderEngine singleton] addCenteredQuad:&impactGlow];
				
				impactGlow.x = impactSpot.x;
				impactGlow.y = impactSpot.y;
				impactGlow.width = impactSpot.width * 2.0 * growScalar;
				impactGlow.height = impactSpot.height * 2.0 * growScalar;
				impactGlow.color = ColorMake(255, 100, 0, .35 * burnoutScalar * growScalar);
				[[RenderEngine singleton] addCenteredQuad:&impactGlow];
				
				[[RenderEngine singleton] setActiveVertexBuffer:VBO_ALT];
				impactGlow.color.a = burnoutScalar * growScalar;
				[[RenderEngine singleton] addCenteredQuad:&impactGlow];
				
			}
			
			
			[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
			effect.width = radius * 12.0 * scale;
			effect.height = effect.width;
			offset = effect.width * .5;
			effect.x = (actor.position.x * scale) - offset;
			effect.y = (actor.position.y * scale) - offset;
			effect.uv = explosionGlareUV;
			ColorApply(&effect.color, 255, 96, 0, .5);
			[[RenderEngine singleton] addQuad:&effect];
			
			effect.width = radius * 20.0 * scale;
			effect.height = effect.width;
			offset = effect.width * .5;
			effect.x = (actor.position.x * scale) - offset;
			effect.y = (actor.position.y * scale) - offset;
			ColorResetAlpha(&effect.color, .25);
			[[RenderEngine singleton] addQuad:&effect];
			
			[[RenderEngine singleton] setActiveVertexBuffer:VBO_ALT];
			ColorReset(&effect.color);
			[[RenderEngine singleton] addQuad:&effect];
			
			
			[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
			effect.width = radius * 7.0 * scale;
			effect.height = effect.width;
			offset = effect.width * .5;
			effect.x = (actor.position.x * scale) - offset;
			effect.y = (actor.position.y * scale) - offset;
			effect.uv = impactCoreUV;
			ColorApply(&effect.color, 140, 180, 255, 1.0);
			[[RenderEngine singleton] addQuad:&effect];
			
			[[RenderEngine singleton] setActiveVertexBuffer:VBO_ALT];
			ColorReset(&effect.color);
			[[RenderEngine singleton] addQuad:&effect];
			
		}
	}
}

@end
