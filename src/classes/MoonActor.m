//
//  MoonActor.m
//  Eve of Impact
//
//  Created by Rik Schennink on 2/15/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "MoonActor.h"
#import "PlanetActor.h"
#import "RotationalMoveBehaviour.h"
#import "ImpactActor.h"
#import "ShipActorBase.h"
#import "ShieldActor.h"
#import "Explodable.h"
#import "MissileActor.h"
#import "DebreeActor.h"
#import "AsteroidActor.h"
#import "StateBehaviour.h"

@implementation MoonActor

-(id)initWithRadius:(float)r andMass:(float)m {
	
	self = [super initWithRadius:r 
						   state:(StateBehaviourBase<StateBehaviour>*)[[StateBehaviourBase alloc] init]
						movement:[[RotationalMoveBehaviour alloc] initAndRotateAtDistance:180.0 
																			   withOffset:120.0 
																				  atSpeed:.075]];
	if (self) {

		mass = m;
		hits = 0;
		impacts = [[NSMutableArray alloc]init];
								
	}
	
	return self;
}

-(BOOL)canCollideWith:(ActorBase*)actor {
	return false;
}

-(void)act {
	
	for (ImpactActor* impact in impacts) {
		
		impact->position.x = self->position.x + (cos(impact.angle) * impact.distance);
		impact->position.y = self->position.y + (sin(impact.angle) * impact.distance);
		
	}
	
	[super act];
}

-(void)collideWith:(ActorBase *)actor afterTime:(float)time {
	
	if ([actor isKindOfClass:[MissileActor class]]) {
		
		hits++;
		
		if (hits == MOON_MAX_HITS) {
			[self shatterBy:actor];
		}
	}
	else if([actor conformsToProtocol:@protocol(Collidable)]) {
		
		ActorBase<Collidable>* collidable = (ActorBase<Collidable>*)actor;
		
		// define impact actor
		ImpactActor* impact = [[ImpactActor alloc]initWithMass:collidable.mass];
		impact.angle = (vectorGetAngleBetween(&collidable->position, &self->position) + 180.0) * TRIG_PI_D_180;
		impact.distance = self.radius - 3.0;
		[impacts addObject:impact];
		
		// notify of this impact and pass impact along
		[[NSNotificationCenter defaultCenter] postNotificationName:@"AsteroidImpact" object:impact];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"MoonImpacted" object:actor];
		[impact release];
		
		// kill asteroid
		[actor kill];
	}
}

-(void)shatterBy:(ActorBase*)actor {
	
	NSMutableArray* debree = [[NSMutableArray alloc] init];
	
	Vector v;
	Vector s = VectorMake(self->position.x - actor->position.x, self->position.y - actor->position.y);
	
	float magnitude = .2;
	float magnitudeRandomizer;
	vectorNormalize(&s);
	
	// get magnitude and angle of current velocity
	BOOL first = TRUE;
	uint total,share,iteration,multiplier;
	
	total = 18;
	share = 0;
	iteration = 0;
	
	while (total > 0) {
		
		// set additional magnitude
		magnitudeRandomizer = randomBetween(0, .4);
		
		// increase multiplier every each iteration
		multiplier = iteration % 2 == 0 ? multiplier+1 : multiplier;
		
		// calculate the size of the current fragment
		share = floor(randomBetween(1, fmin(total,ASTEROID_MAX_RADIUS)));
		
		// if this is the first fragment, it can't be the same as the whole asteroid
		if (first && share==total) {
			share--;
		}
		
		// no longer first loop
		first = FALSE;
		
		// subtract from total
		total-=share;
		
		// set random vector based on asteroid vector
		v.x = s.x;
		v.y = s.y;
		vectorRotateByDegrees(&v,randomBetween(-90, 90));
		v = vectorMultiplyWithAmount(&v, magnitude + magnitudeRandomizer);
		
		// init shard
		AsteroidActor* asteroid = [[AsteroidActor alloc] 
								   initWithMass:share + randomBetween(0, .45) 
									temperature:.5 
								 andMaxVelocity:randomBetween(ASTEROID_VELOCITY - ASTEROID_VELOCITY_RANGE, ASTEROID_VELOCITY + ASTEROID_VELOCITY_RANGE)];
		asteroid->position.x = self->position.x + randomBetween(-4.0, 4.0);
		asteroid->position.y = self->position.y + randomBetween(-4.0, 4.0);
		asteroid->velocity.x = v.x;
		asteroid->velocity.y = v.y;
		
		// debree now holds asteroid
		[debree addObject:asteroid];
		
		// release hold on asteroid
		[asteroid release];
		
		// next iteration
		iteration++;
	}
		
	// send shards to notification center
	[[NSNotificationCenter defaultCenter] postNotificationName:@"MoonShattered" object:debree];
	
	// remove moon
	[self kill];
}

-(void)bindImpact:(ImpactActor*)impact {
	
}

-(void)clearImpacts {
	[impacts removeAllObjects];
}

-(void)flush {
	hits = 0;
	[self clearImpacts];
}

-(void)dealloc {
	
	[impacts release];
	
	[super dealloc];
	
}

@end
