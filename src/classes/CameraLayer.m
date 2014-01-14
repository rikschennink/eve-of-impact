//
//  CameraLayer.m
//  Eve of Impact
//
//  Created by Rik Schennink on 11/6/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "CameraLayer.h"
#import "ApplicationModel.h"
#import "Prefs.h"
#import "Easing.h"
#import "RenderEngine.h"
#import "Camera.h"
#import "MissileActor.h"
#import "ShipActorBase.h"
#import "ShipActor.h"
#import "NukeExplosionActor.h"
#import "ShuttleExplosionActor.h"
#import "ImpactActor.h"
#import "PulseManager.h"
#import "Pulse.h"
#import "ShieldShockwaveActor.h"

@implementation CameraLayer

static const float lensFlareLayout[14][3] = {
    {.55,8,.5},
    {.5,4,.8},
    {.375,45,1.3},
    {.25,6.5,1.6},
    {.225,27,.5},
    {.1,5.5,1.0},
    {.05,35,1.2},
    {.025,3,.7},
    {-.025,7.0,1.0},
    {-.045,80,1.4},
    {-.216,9.0,1.2},
    {-.225,305,2.05},
    {-.375,4.0,1.4},
    {-.45,5.5,1.3}
};

-(id)initWithModel:(ApplicationModel*)applicationModel {
	
	if (self = [super init]) {
		
		model = applicationModel;
		
		scale = IS_IPAD ? 2.0 : 1.0;
		
		projected = VectorMake(0,0);
		
		// create camera effect glimmer 
		sunGlimmer = [[Pulse alloc]initWithPeriod:RangeMake(2, 8)];
		actorGlimmers = [[PulseManager alloc] initWithAmount:3];
		
		// compression artifacts
		for (uint i =0;i<10;i++) {
			artifacts[i] = UVMapMake(525 + (i*3), 0, 1, 480);
		}
		
		artifactCountdown = 0;
		artifactDirection = 0;
		artifactOffset = 0;
		
		// set shading quads
		shadingLeft = QuadTemplateMake(0, 0, 0, 28 * scale, 0, ColorMakeFast(), UVMapMake(34,282,28,13));
		shadingRight = QuadTemplateMake(0, 0, 0, 28 * scale, 0, ColorMakeFast(), UVMapMake(34,297,28,13));
		shadingTop = QuadTemplateMake(0, 0, 0, 0, 28 * scale, ColorMakeFast(), UVMapMake(66,282,13,28));
		shadingBottom = QuadTemplateMake(0, 0, 0, 0, 28 * scale, ColorMakeFast(), UVMapMake(81,282,13,28));
		
		// set sun glow quad
		sunGlow = QuadTemplateMake(0, 0, 0, 154 * scale, 1024 * scale, ColorMakeFast(), UVMapMake(407,1,114,277));
		
		// set sun star quad
		sunStar = QuadTemplateMake(0, 0, 0, 90 * scale, 90 * scale, ColorMake(255, 227, 105, 1.0), UVMapMake(344,361,70,70));
		
		// set lensstreak quad
		lensStreak = QuadTemplateMake(0, 0, 0, 196 * scale, 14 * scale, ColorMakeFast(), UVMapMake(121, 297, 196, 14));
		
		// set lensflare colors
		lensFlareColorWarm = ColorMake(255, 227, 105, 1.0);
		
		// set lensflare quad
		lensFlareRing = UVMapMake(318, 257, 55, 55);
        lensFlareBlob = UVMapMake(110, 276, 10, 10);
        lensFlare = QuadTemplateMake(0, 0, 0, 3 * scale, 3 * scale, lensFlareColorWarm, lensFlareBlob);
		
		// set lens spec quad
		lensSpec = QuadTemplateMake(0, 0, 0, 24 * scale, 24 * scale, ColorMakeFast(), UVMapMake(122, 273, 24, 24));
		lensSpecSmall = UVMapMake(146, 290, 6, 6);
		lensSpecBig = UVMapMake(122, 273, 24, 24);
		
		// flare uv
		lensStar = QuadTemplateMake(0, 0, 0, 0, 0, ColorMakeFast(), UVMapMake(1,272,108,7));
		lensGlare = QuadTemplateMake(0, 0, 0, 0, 0, ColorMakeFast(), UVMapMake(344,361,70,70));
		lensGlow = QuadTemplateMake(0, 0, 0, 0, 0, ColorMakeFast(),UVMapMake(1,489,22,22));
		lensCircle = QuadTemplateMake(0, 0, 0, 0, 0, ColorMakeFast(),UVMapMake(65,449,13,13));
		
		// flash
		flash = QuadTemplateMake(0, 0, 0, 0, 0, ColorMakeFast(), UVMapMake(20, 452, 8, 8));
		
		
		
		/*
		randomizer = 0;
		
		// random count
		NSString* temp = @"";
		
		for (uint i =0; i<20; i++) {
			
			Vector p = VectorMakeRandom(240.0);
			p.x = round(p.x);
			p.y = round(p.y);
			
			float width = 16.0 + mathRandom() * 5.0;
			
			temp = [temp stringByAppendingFormat:@"{%f,%f,%f,%f,%f},",p.x,p.y,.2 + mathRandom() * .1,width,width * (.75 + mathRandom() * .5)];
			
			
		}
		
		//smallSpecs = [[NSMutableArray alloc] init];
		*/
	}
	
	return self;
}

-(void)redraw:(float)interpolation {
		
	[sunGlimmer update];
	[actorGlimmers update];

	// get screen size
	CGSize screenSize = [[RenderEngine singleton] getScreenSize];
	
	// draw frame shadow
	flashCount = 0;
	float left,right,top,bottom;
	left = -screenSize.width * .5;
	right = screenSize.width * .5;
	bottom = -screenSize.height * .5;
	top = screenSize.height * .5;
	
	if (model.state == STATE_MENU_GAMEOVER && model.ticks > CAMERA_ARTIFACT_COUNTDOWN) {
		
		float altScale = IS_IPAD ? 1.5 : 1.0;
		
		// render gameover noise
		QuadTemplate gameover;
		gameover.x = left;
		gameover.y = bottom;
		gameover.width = screenSize.width;
		gameover.height = screenSize.height;
		gameover.color = ColorMakeFast();
		gameover.uv = UVMapMake(244, 543, 320, 480);
		[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
		[[RenderEngine singleton] addQuad:&gameover];
		
		// render disconnected label
		QuadTemplate gameoverLabel;
		gameoverLabel.width = 144 * altScale;
		gameoverLabel.height = 32 * altScale;
		gameoverLabel.x = right - (9.0 * altScale) - gameoverLabel.width;
		gameoverLabel.y = bottom + (10.0 * altScale);
		gameoverLabel.color = ColorMakeFast();
		gameoverLabel.uv = UVMapMake(408, 504, 144, 32);
		[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
		[[RenderEngine singleton] addQuad:&gameoverLabel];
		
		return;
	}
	
	// get current cameraoffset
	Vector cameraOffset = [[RenderEngine singleton] getCameraOffset];
	
	shadingLeft.x = left - 1.0;
	shadingLeft.y = bottom - 1.0 - (32.0 * scale);
	shadingLeft.height = screenSize.height + (64.0 * scale);
	
	shadingRight.x = right + 1.0 - (28.0 * scale);
	shadingRight.y = bottom - 1.0 - (32.0 * scale);
	shadingRight.height = screenSize.height + (64.0 * scale);
	
	shadingTop.x = left - 1.0 - (32.0 * scale);
	shadingTop.y = top + 1.0 - (28.0 * scale);
	shadingTop.width = screenSize.width + (64.0 * scale);
	
	shadingBottom.x = left - 1.0 - (32.0 * scale);
	shadingBottom.y = bottom - 1.0;
	shadingBottom.width = screenSize.width + (64.0 * scale);
	
	[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
	[[RenderEngine singleton] addQuad:&shadingLeft];
	[[RenderEngine singleton] addQuad:&shadingRight];
	[[RenderEngine singleton] addQuad:&shadingTop];
	[[RenderEngine singleton] addQuad:&shadingBottom];
	
	if (cameraOffset.x > -100.0) {
		
		float sunOffset = cameraOffset.y * 1.25 * scale;
		float sunGlimmerModifier = sunGlimmer.intensity * .1;
		
		float sunGlareOpacity = fmin(1.0,easeLinear(cameraOffset.x + 100, 375));
		float lensEffectsOpacity = fmin(1.0,fmax(0.0,easeLinear(cameraOffset.x - 150, 100)));
		float boostOpacity = fmax(0,easeLinear(-250 + cameraOffset.x,250));
		
		// draw sun big glow, screen size
		sunGlow.height = (1024.0 + (boostOpacity * 200.0)) * scale;
		sunGlow.width = (154.0 + (boostOpacity * 100.0)) * scale;
		//sunGlow.x = -85 + (boostOpacity * 50);
		sunGlow.x = left + (75.0 * scale) + (boostOpacity * 50.0 * scale);
		sunGlow.y = sunOffset * .75;
		sunGlow.color = ColorMake(255, 248, 114, .33 * fmax(0.0,sunGlareOpacity - .1));
		[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
		[[RenderEngine singleton] addCenteredQuad:&sunGlow];
		
		// draw sun more concentrated color glow
		[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
		

		sunGlow.x = (left - (90.0 * scale)) + (sunGlareOpacity * 150.0 * scale);
		//sunGlow.x = -250 + (sunGlareOpacity * 150.0);
		sunGlow.y = sunOffset * 1.1;
		sunGlow.width = (200.0 + (boostOpacity * 50)) * scale;
		sunGlow.height = (400.0 + 100.0 * (fabs(cameraOffset.y) * .01) + (boostOpacity * 50.0)) * scale;
		sunGlow.color = ColorMake(247, 114, 26, (sunGlareOpacity * .25));
		[[RenderEngine singleton] addCenteredQuad:&sunGlow];
			
		[[RenderEngine singleton] setActiveVertexBuffer:VBO_ALT];
		sunGlow.width = (200.0 - (50.0 * sunGlareOpacity)) * scale;
		sunGlow.y = sunOffset * .8;
		sunGlow.color = ColorMake(247, 114, 26, fmin(1.0,sunGlareOpacity));
		[[RenderEngine singleton] addCenteredQuad:&sunGlow];
		
		
		[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
		sunGlow.width = 700.0 * scale;
		sunGlow.height = 200.0 * scale;
		sunGlow.x = left;
		sunGlow.y = sunOffset * 1.15;
		sunGlow.color = ColorMake(247, 114, 26, 1.0);
		sunGlow.color.a = lensEffectsOpacity * fmin(1.0,fmax(0.0,4.0 * easeLinear(sunOffset + (175 * scale),-250 * scale)));
		[[RenderEngine singleton] addCenteredQuad:&sunGlow];
		sunGlow.color.a = lensEffectsOpacity * fmin(1.0,fmax(0.0,4.0 * easeLinear(sunOffset - (175 * scale),250 * scale)));
		[[RenderEngine singleton] addCenteredQuad:&sunGlow];
			
		
		lensStreak.x = left + (120.0 * scale);
		lensStreak.y = sunOffset;
		lensStreak.width = 196.0 * scale;
		lensStreak.height = (14.0 + sunGlimmer.intensity) * scale;
		lensStreak.color = ColorMake(255, 227, 105, fmin(1.0,(lensEffectsOpacity * (.3 + sunGlimmerModifier * 1.5) + boostOpacity)));
		[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
		[[RenderEngine singleton] addCenteredQuad:&lensStreak];
		
		lensStreak.x = lensStreak.x - (3.0 * scale);
		lensStreak.height = (7.0 + sunGlimmer.intensity * 10.0) * scale;
		lensStreak.color = ColorMake(255, 255, 255, lensStreak.color.a);
		[[RenderEngine singleton] setActiveVertexBuffer:VBO_ALT];
		[[RenderEngine singleton] addCenteredQuad:&lensStreak];
		
		// draw sun lensstreak motion blur
		sunGlow.x = left + (150.0 * scale);
		sunGlow.y = sunOffset;
		sunGlow.color = ColorMake(255, 250, 158, (lensEffectsOpacity * (.1 + sunGlimmerModifier)));
		sunGlow.width = 640.0 * scale;
		sunGlow.height = 20.0 * scale;
		[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
		[[RenderEngine singleton] addCenteredQuad:&sunGlow];
		
		sunGlow.x = left + (250.0 * lensEffectsOpacity * scale);
		sunGlow.height = 4.0 * scale;
		sunGlow.color.a = lensEffectsOpacity * (.3 + sunGlimmerModifier);
		[[RenderEngine singleton] setActiveVertexBuffer:VBO_ALT];
		[[RenderEngine singleton] addCenteredQuad:&sunGlow];
		
		
		// draw sun little glow
		//sunGlow.x = -200 + ((sunGlareOpacity + sunGlimmerModifier * 2.0) * 50);
		sunGlow.x = (left - (40.0 * scale)) + (((sunGlareOpacity + sunGlimmerModifier * 2.0) * 50.0) * scale);
		sunGlow.y = sunOffset;
		sunGlow.color = ColorMake(255, 248, 114, fmin(1.0,lensEffectsOpacity * 2.0));
		sunGlow.width = 80.0 * scale;
		sunGlow.height = (170.0 + (sunGlimmerModifier * 250)) * scale;
		[[RenderEngine singleton] addCenteredQuad:&sunGlow];
		
		
		sunGlow.x = left + (10.0 * scale) + (sunGlimmerModifier * 15 * scale);
		sunGlow.y = sunOffset;
		sunGlow.color = ColorMake(255, 246, 38, fmin(1.0,lensEffectsOpacity * 2.0));
		sunGlow.width = 40.0 * scale;
		sunGlow.height = (280.0 + (sunGlimmerModifier * 250)) * scale;
		[[RenderEngine singleton] addCenteredQuad:&sunGlow];
		
		if (boostOpacity > 0) {
			
			sunGlow.x = left + (40.0 * scale);
			sunGlow.y = sunOffset;
			sunGlow.color = ColorMake(255, 255, 255, fmin(1.0,boostOpacity));
			sunGlow.width = 80.0 * scale;
			sunGlow.height = 100.0 * scale;
			[[RenderEngine singleton] addCenteredQuad:&sunGlow];
			
			sunStar.x = sunGlow.x - (40.0 * scale);
			sunStar.y = sunGlow.y;
			sunStar.width = 250.0 * boostOpacity * scale;
			sunStar.height = sunStar.width;
			[[RenderEngine singleton] addQuad:&sunStar andRotateBy:boostOpacity * 30];
			
		}
		
		
		if (lensEffectsOpacity > 0) {
			
			[self drawLensFlareFromOrigin:VectorMake(cameraOffset.x - 750.0,cameraOffset.y * 1.75) 
                            withBaseColor:lensFlareColorWarm
                       andOpacityModifier:550.0];
            
		}
	}	
	
	
	for (ActorBase* actor in model.world.actors) {
		
		if ([actor isKindOfClass:[MissileActor class]]) {
			[self drawMissileFlare:actor withInterpolation:interpolation];
		}
		else if ([actor isKindOfClass:[ShipActorBase class]]) {
			[self drawShuttleFlare:actor withInterpolation:interpolation];
		}
		else if ([actor isKindOfClass:[ImpactActor class]]) {
			[self drawImpactFlare:actor withInterpolation:interpolation];
		}
		else if ([actor isKindOfClass:[NukeExplosionActor class]]) {
			[self drawExplosionFlare:actor withInterpolation:interpolation];
		}
		else if ([actor isKindOfClass:[ShuttleExplosionActor class]]) {
			[self drawShuttleExplosionFlare:actor withInterpolation:interpolation];
			
			ShuttleExplosionActor* explosion = (ShuttleExplosionActor*)actor;
			if (explosion.flash) {
				[self drawFlash:actor withInterpolation:interpolation];
			}
		}
		else if ([actor isKindOfClass:[ShieldShockwaveActor class]]) {
			[self drawFlash:actor withInterpolation:interpolation];
		}
	}
	
	[self drawArtifactsWithInterpolation:interpolation];
}

-(void)drawArtifactsWithInterpolation:(float)interpolation {
	
	if (model.state == STATE_PLAYING) {
		artifactDirection = 0;
		return;
	}
	
	if (artifactDirection == 0) {
		
		if (model.state == STATE_TITLE || model.state == STATE_MENU_GAMEOVER) {
			artifactOffset = model.ticks;
			artifactCountdown = model.ticks + CAMERA_ARTIFACT_COUNTDOWN;
			artifactDirection = -1;
			
			if (model.state == STATE_MENU_GAMEOVER) {
				artifactDirection = 1;
			}
			
			return;
		}
	}
	
	if ((model.state == STATE_TITLE || 
		 model.state == STATE_MENU_GAMEOVER) && 
		 model.ticks < artifactCountdown) {
		
		// artifact progress
		float p = easeLinear((model.ticks - artifactOffset), artifactCountdown);
		
		// 1 -> 0
		if (artifactDirection == -1) {
			p = 1.0 - p;
		}
		
		uint index = round(p * 9);
		
		if ((int)model.ticks&1) {
			index = MIN(index+1, 9);
		}
		
		// get screen size
		CGSize screenSize = [[RenderEngine singleton] getScreenSize];
		
		QuadTemplate artifact;
		artifact.x = -screenSize.width * .5;
		artifact.y = -(screenSize.height * .5) * 1.25;
		artifact.width = screenSize.width;
		artifact.height = screenSize.height * 1.25;
		artifact.color = ColorMakeFast();
		artifact.color.a = 1.0 - (.5 * p);
		artifact.uv = artifacts[index];
		[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
		[[RenderEngine singleton] addQuad:&artifact];
		
	}
}


-(void)drawLensFlareFromOrigin:(Vector)origin withBaseColor:(Color)color andOpacityModifier:(float)modifier {
    
    float offset,radius,length,opacity,visibility,intensity;
    
    lensFlare.color = color;
    length = vectorGetMagnitude(&origin);
    vectorNormalize(&origin);
    
    opacity = fmin(1.0,fmax(1.0 - (length / modifier),0.0));
    intensity = 1.0 + (sunGlimmer.intensity * .5);
	
    for (uint i=0; i<14; i++) {
        
        [[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
        
        offset = length * lensFlareLayout[i][0];
        radius = lensFlareLayout[i][1];
        visibility = lensFlareLayout[i][2];
        
        lensFlare.x = origin.x * offset * scale;
        lensFlare.y = origin.y * offset * scale;
        lensFlare.width = (radius + sunGlimmer.intensity) * scale;
        lensFlare.height = lensFlare.width;
        lensFlare.color.a = fmin((opacity * visibility * intensity),1.0);
    	
        if (radius > 10) {
            lensFlare.uv = lensFlareRing;
            lensFlare.color.g -= i * 3;
            lensFlare.color.b -= i;
            [[RenderEngine singleton] setActiveVertexBuffer:VBO_ALT];
        }
        else {
            lensFlare.uv = lensFlareBlob;
        }
        
        [[RenderEngine singleton] addCenteredQuad:&lensFlare];
        
    }    
}











-(void)drawImpactFlare:(ActorBase*)actor withInterpolation:(float)interpolation {
	
	if (actor.radius < .5) {
		return;
	}
	
	Vector scaledPosition = vectorMultiplyWithAmount(&actor->position, scale);
	
	[[RenderEngine singleton] projectLocationVector:&scaledPosition ToScreenVector:&projected];
		
	float offset;
	float progress = 0.0;
	
	if (actor.state.life < 5) {
		progress = fmin(1.0,easeOutSine(actor.state.life + interpolation, 5));
	}
	else if (actor.state.life < 50) {
		progress = (1.0 - fmin(1.0, easeInOutSine(actor.state.life + interpolation - 5, 45)));
	}
		
	float radius = progress * actor.mass;
	
	[[RenderEngine singleton] setActiveVertexBuffer:VBO_ALT];
	lensGlow.width = radius * 25.0 * scale;
	lensGlow.height = lensGlow.width;
	offset = lensGlow.width * .5;
	lensGlow.x = projected.x - offset;
	lensGlow.y = projected.y - offset;
	ColorReset(&lensGlow.color);
	[[RenderEngine singleton] addQuad:&lensGlow];
	
	lensStar.width = radius * 100 * scale;
	lensStar.height = 20 * scale;
	lensStar.x = projected.x - (lensStar.width * .5);
	lensStar.y = projected.y - (10.0 * scale);
	lensStar.color.a = .75;
	[[RenderEngine singleton] addQuad:&lensStar];
	
	lensStar.height = 5 * scale;
	lensStar.y = projected.y - (2.5 * scale);
	[[RenderEngine singleton] addQuad:&lensStar];
	
}

-(void)drawMissileFlare:(ActorBase*)actor withInterpolation:(float)interpolation {
	
	Vector scaledPosition = vectorMultiplyWithAmount(&actor->position, scale);
	
	[[RenderEngine singleton] projectLocationVector:&scaledPosition ToScreenVector:&projected];
	
	float progress = 1.0;
	
	if ([actor.state contains:STATE_DYING]) {
		progress = fmax(0.0,(actor.state.lifespan - (actor.state.life + interpolation))  * .05);
	}
	else {
		projected.x += actor.velocity.x * interpolation * scale;
		projected.y += actor.velocity.y * interpolation * scale;
	}
	
	[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
	lensGlow.width = 65.0 * scale;
	lensGlow.height = lensGlow.width;
	lensGlow.x = projected.x - (32.5 * scale);
	lensGlow.y = projected.y - (32.5 * scale);
	ColorApply(&lensGlow.color, 255, 150, 30, .25);
	[[RenderEngine singleton] addQuad:&lensGlow];
	
	lensGlare.width = 6.0 * scale;
	lensGlare.height = lensGlare.width;
	lensGlare.x = projected.x - (3.0 * scale);
	lensGlare.y = projected.y - (3.0 * scale);
	lensGlare.color.a = 1.0;
	[[RenderEngine singleton] addQuad:&lensGlare];
	
	[[RenderEngine singleton] setActiveVertexBuffer:VBO_ALT];
	lensGlare.width = 40.0 * scale;
	lensGlare.height = lensGlare.width;
	lensGlare.x = projected.x - (20.0 * scale);
	lensGlare.y = projected.y - (20.0 * scale);
	lensGlare.color.a = 1.0;
	[[RenderEngine singleton] addQuad:&lensGlare];
	
	lensStar.x = projected.x;
	lensStar.y = projected.y;
	lensStar.width = 150.0 * progress * scale;
	lensStar.height = 6.0 * scale;
	lensStar.x = projected.x - (lensStar.width * .5);
	lensStar.y = projected.y - (3.0 * scale);
	lensStar.color.a = .5 * progress;
	[[RenderEngine singleton] addQuad:&lensStar];
	
}






-(void)drawShuttleFlare:(ActorBase*)actor withInterpolation:(float)interpolation {
	
	
	Vector scaledPosition = vectorMultiplyWithAmount(&actor->position, scale);
	
	[[RenderEngine singleton] projectLocationVector:&scaledPosition ToScreenVector:&projected];
	
	ShipActorBase* shuttle = (ShipActorBase*)actor;
	
	float lensScale,half;
	
	if ([shuttle isKindOfClass:[ShipActor class]]) {
		lensScale = 2.0;
	}
	else { // escape pod
		lensScale = .75;
	}
	
	Pulse* pulse = [actorGlimmers getPulseByActor:actor];
	
	projected.x += actor.velocity.x * interpolation * scale;
	projected.y += actor.velocity.y * interpolation * scale;
	
	
	[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
	lensGlow.width = lensScale * 12.0 * scale;
	lensGlow.height = lensGlow.width;
	half = lensGlow.width * .5;
	lensGlow.x = projected.x - half;
	lensGlow.y = projected.y - half;
	ColorApply(&lensGlow.color, 30, 100, 255, .25 + (pulse.intensity * .05));
	[[RenderEngine singleton] addQuad:&lensGlow];
	
	
	lensGlare.width = lensScale * scale;
	lensGlare.height = lensGlare.width;
	half = lensScale * .5;
	lensGlare.x = projected.x - half;
	lensGlare.y = projected.y - half;
	lensGlare.color.a = .75 + (pulse.intensity * .25);
	[[RenderEngine singleton] addQuad:&lensGlare];
	
	[[RenderEngine singleton] setActiveVertexBuffer:VBO_ALT];
	
	lensGlare.width = lensScale * 7.0 * scale;
	lensGlare.height = lensGlare.width;
	half = lensGlare.width * .5;
	lensGlare.x = projected.x - half;
	lensGlare.y = projected.y - half;
	[[RenderEngine singleton] addQuad:&lensGlare];
	
	lensStar.width = ((lensScale * 15.0) + (pulse.intensity * 1.5)) * scale;
	lensStar.height = 4.0 * scale;
	lensStar.x = projected.x - (lensStar.width * .5);
	lensStar.y = projected.y - (2.0 * scale);
	lensStar.color.a = (.5 + (pulse.intensity * .25)) * fmin(1.0,easeLinear(actor.state.life + interpolation, 30));
	[[RenderEngine singleton] addQuad:&lensStar];
}





-(void)drawExplosionFlare:(ActorBase*)actor withInterpolation:(float)interpolation {
	
	Vector scaledPosition = vectorMultiplyWithAmount(&actor->position, scale);
	
	[[RenderEngine singleton] projectLocationVector:&scaledPosition ToScreenVector:&projected];
	
	[[RenderEngine singleton] setActiveVertexBuffer:VBO_ALT];
	
	float progress = fmin(1.0,easeLinear(actor.state.life + interpolation, actor.state.lifespan));
	
	lensStar.width = 250.0 * (1.0 - progress) * scale;
	lensStar.height = 20.0 * scale;
	lensStar.x = projected.x - (lensStar.width * .5);
	lensStar.y = projected.y - (10.0 * scale);
	lensStar.color.a = 1.0 - progress;
	[[RenderEngine singleton] addQuad:&lensStar];
	
	lensStar.width = 150.0 * (1.0 - progress) * scale;
	lensStar.height = 8.0 * scale;
	lensStar.x = projected.x - (lensStar.width * .5);
	lensStar.y = projected.y - (4.0 * scale);
	[[RenderEngine singleton] addQuad:&lensStar];
	
}

-(void)drawShuttleExplosionFlare:(ActorBase*)actor withInterpolation:(float)interpolation {
	
	Vector scaledPosition = vectorMultiplyWithAmount(&actor->position, scale);
	
	[[RenderEngine singleton] projectLocationVector:&scaledPosition ToScreenVector:&projected];
	
	[[RenderEngine singleton] setActiveVertexBuffer:VBO_ALT];
	
	float progress = fmin(1.0,easeLinear(actor.state.life + interpolation, actor.state.lifespan));
	
	lensStar.x = projected.x;
	lensStar.y = projected.y;
	lensStar.width = 250.0 * (1.0 - progress) * scale;
	lensStar.height = 15.0 * scale;
	lensStar.x = projected.x - (lensStar.width * .5);
	lensStar.y = projected.y - (7.5 * scale);
	lensStar.color.a = 1.0 - progress;
	[[RenderEngine singleton] addQuad:&lensStar];
	
	lensStar.width = 150.0 * (1.0 - progress) * scale;
	lensStar.height = 8.0 * scale;
	lensStar.x = projected.x - (lensStar.width * .5);
	lensStar.y = projected.y - (4.0 * scale);
	[[RenderEngine singleton] addQuad:&lensStar];
	
}

-(void)drawFlash:(ActorBase*)actor withInterpolation:(float)interpolation {
	
	if (actor.state.life + interpolation < 30.0 && flashCount < 3) {
		
		CGSize screenSize = [[RenderEngine singleton] getScreenSize];
		
		[[RenderEngine singleton] setActiveVertexBuffer:VBO_ALT];
		
		flash.x = -screenSize.width * .5;
		flash.y = -screenSize.height * .5;
		flash.width = screenSize.width;
		flash.height = screenSize.height;
		flash.color.a = 1.0 - easeOutSine(actor.state.life + interpolation, 30);
		
		[[RenderEngine singleton] addQuad:&flash];
	}
}

@end






/*
 
 else if	([actor isKindOfClass:[MissileActor class]]) {
 
 [[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
 
 // get distance missile position
 vx = actor.velocity.x;
 vy = actor.velocity.y;
 d = sqrtf(vx * vx + vy * vy);
 
 // normalize
 vx/=d;
 vy/=d;
 
 effect.x = actor.position.x - (vx * 4.0);
 effect.y = actor.position.y - (vy * 4.0);
 effect.color = ColorMake(255,170,80,actor.state.life % 2 == 0 ? .25 : .30);
 effect.width = 40.0;
 effect.height = effect.width;
 effect.uv = missileGlowUV;
 
 [[RenderEngine singleton] addQuad:effect];
 
 }
 
 
 
 
 
 
 
 
 
 
 
 
 // draw lens speckles
 [[RenderEngine singleton] setActiveVertexBuffer:VBO_ALT];
 lensSpec.uv = lensSpecBig;
 for (uint i=0; i<6;i++) {
 lensSpec.x = bigSpecs[i][0];
 lensSpec.y = bigSpecs[i][1];
 lensSpec.color = ColorMake(255, 227, 105,fmin(1.0,bigSpecs[i][2] + brightness * .15));
 lensSpec.width = bigSpecs[i][3];
 lensSpec.height = lensSpec.width;
 [[RenderEngine singleton] addQuad:lensSpec];
 }
 
 uint u,v;
 lensSpec.uv = lensSpecSmall;
 for (uint i=0; i<20;i++) {
 lensSpec.x = smallSpecs[i][0] + .5;
 lensSpec.y = smallSpecs[i][1] + .5;
 lensSpec.color = ColorMake(255, 255, 255,fmin(1.0,smallSpecs[i][2] + brightness));
 lensSpec.width = smallSpecs[i][3];
 lensSpec.height = smallSpecs[i][4];
 
 u = i%6 * 20;
 v = i%2 * 20;
 lensSpec.uv = UVMapMake(146 + u, 276 - v, 20, 20);
 
 [[RenderEngine singleton] addQuad:lensSpec];
 }
 
 
 */

