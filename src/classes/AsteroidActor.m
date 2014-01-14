//
//  AsteroidActorModel.m
//  Eve of Impact
//
//  Created by Rik Schennink on 2/15/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "AsteroidActor.h"
#import "AsteroidStateBehaviour.h"
#import "Explodable.h"
#import "ImpactActor.h"
#import "LinearMoveBehaviour.h"
#import "OptimizedHistoryBehaviour.h"
#import "MathAdditional.h"
#import "ShipActorBase.h"
#import "MoonActor.h"
#import "MissileActor.h"
#import "PlanetActor.h"
#import "ShieldActor.h"
#import "Easing.h"
#import "NukeExplosionActor.h"
#import "ShuttleExplosionActor.h"
#import "ShieldShockwaveActor.h"
#import "DebreeActor.h"


@implementation AsteroidActor


@synthesize temperature;


-(id)initWithMass:(float)r andMaxVelocity:(float)v {
	
	AsteroidStateBehaviour<StateBehaviour>* stateBehaviour = (AsteroidStateBehaviour <StateBehaviour>*)[[AsteroidStateBehaviour alloc] init];
	LinearMoveBehaviour<MoveBehaviour>* moveBehaviour = [[LinearMoveBehaviour alloc] init];
	
	self = [super initWithRadius:0 state:stateBehaviour movement:moveBehaviour];
	
	if (self) {
		
		temperature = 0.0;
		self.mass = r;
		maxVelocity = v;
		maxWeightVelocity = self.mass * .05;
	}
	
	return self;
}

-(id)initWithMass:(float)r temperature:(float)amount andMaxVelocity:(float)v {
	
	self = [self initWithMass:r andMaxVelocity:v];
	
	if (self) {
		temperature = amount;
	}
	
	return self;
}

-(void)act {
	
	if (getDistanceSquaredToPlanet(self->position.x,self->position.y) < ASTEROID_BURN_DISTANCE_SQUARED) {
		
		temperature = temperature + .025 < 1 ? temperature + .025 : 1;
		
		// if temperature is higher than .5 start burning up
		if (temperature > .5) {
			
			self.mass -= .02;
			
			if (self.mass<.25) {
				[self kill];
			}
		}
	}
	else {
		temperature = temperature - .025 > 0 ? temperature - .025 : 0;
	}
	
	[super act];
	
	// limit speed to my max speed
	vectorLimit(&self->velocity, maxVelocity + maxWeightVelocity);
}

-(void)collideWith:(ActorBase*)actor afterTime:(float)time {
	
	// if hit by shuttle explosion, vaporize asteroid
	if ([actor isKindOfClass:[ShuttleExplosionActor class]] ||
		[actor isKindOfClass:[ShieldShockwaveActor class]]) {
		[self shatter:YES];
	}
	
	// if i'm colliding with a live explosion and i'm not invulnerable
	else if ([actor isKindOfClass:[NukeExplosionActor class]] && ![self.state contains:STATE_INVULNERABLE]) {
		[self shatter:NO];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"AsteroidDestroyed" object:nil];
	}
}

-(void)shatter:(BOOL)vaporize {
	
	NSMutableArray* debree = [[NSMutableArray alloc] init];
	
	int i;
	Vector v;
	Vector s = VectorMake(self->velocity.x, self->velocity.y);
	vectorNormalize(&s);
	
	// if collision with explosion and I have atleast a mass of 2.0 start splitting up
	if (self.mass >= 2.0 && !vaporize) {
		
		float magnitude = vectorGetMagnitude(&self->velocity);
		float magnitudeRandomizer;
		
		// get magnitude and angle of current velocity
		BOOL first = TRUE;
		uint total,share,iteration,multiplier;
		
		total = floor(self.mass);
		share = 0;
		iteration = 0;
		
		while (total > 0) {
			
			// set additional magnitude
			magnitudeRandomizer = randomBetween(-.25, .25);
			
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
			vectorRotateByDegrees(&v,randomBetween(-5, 5));
			v = vectorMultiplyWithAmount(&v, magnitude + magnitudeRandomizer);
			
			// max velocity
			float max = randomBetween(maxVelocity - ASTEROID_VELOCITY_RANGE, maxVelocity + ASTEROID_VELOCITY_RANGE);
			
			// init shard
			AsteroidActor* asteroid = [[AsteroidActor alloc] initWithMass:share + randomBetween(0, .45) 
														     temperature:vaporize ? temperature : 1.0 
														   andMaxVelocity:max];
			asteroid->position.x = self->position.x;
			asteroid->position.y = self->position.y;
			asteroid->velocity.x = v.x;
			asteroid->velocity.y = v.y;
			
			// debree now holds asteroid
			[debree addObject:asteroid];
			
			// release hold on asteroid
			[asteroid release];
			
			// next iteration
			iteration++;
		}
	}
	
	if (vaporize) {
		
		uint amount = self.mass * 4;
		uint span;
		
		for (i=0; i<amount; i++) {
			
			span = randomBetween(10.0, 25.0);
			
			v.x = s.x;
			v.y = s.y;
			vectorRotateByDegrees(&v, randomBetween(-15.0, 15.0));
			v = vectorMultiplyWithAmount(&v, randomBetween(1.0, 3.0));
			
			DebreeActor* rock = [[DebreeActor alloc] initWithTemperature:temperature andLifespan:span];
			rock->position.x = self->position.x + randomBetween(0.0, self.mass);
			rock->position.y = self->position.y + randomBetween(0.0, self.mass);
			rock->velocity.x = v.x;
			rock->velocity.y = v.y;
			
			// debree now holds asteroid
			[debree addObject:rock];
			
			// release hold on asteroid
			[rock release];
		}
	}
	else {
		
		int amount = randomBetween(3.0,7.0);
		float angle = 360 / amount;
		uint span;
		
		for (i=-2; i<amount; i++) {
			
			v.x = self.velocity.x;//s.x;
			v.y = self.velocity.y;//s.y;
			
			if (i < 0) {
				span = randomBetween(35.0, 55.0);
				vectorRotateByDegrees(&v,randomBetween(-15.0, 15.0));
			}
			else {
				span = randomBetween(20.0, 35.0);
				vectorRotateByDegrees(&v, i * (angle * (1.0 + randomBetween(-.2, .2))));
				v = vectorMultiplyWithAmount(&v, randomBetween(1.0, 2.0));
			}
			
			DebreeActor* rock = [[DebreeActor alloc] initWithTemperature:1.0 andLifespan:span];
			rock->position.x = self->position.x;
			rock->position.y = self->position.y;
			rock->velocity.x = v.x;
			rock->velocity.y = v.y;
			
			// debree now holds asteroid
			[debree addObject:rock];
			
			// release hold on asteroid
			[rock release];
		}
	}
	
	// send shards to notification center
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AsteroidShattered" object:debree];
	
	[debree release];
	
	// remove original
	[self kill];
}

-(BOOL)canCollideWith:(ActorBase*)actor {
	
	if ([actor isKindOfClass:[PlanetActor class]] ||
		[actor isKindOfClass:[MoonActor class]] ||
		[actor isKindOfClass:[ShieldActor class]]) {
		return YES;
	}
	
	return NO;
}
 
-(uint)addEmissionsTo:(Particle*)collection atIndex:(uint)index {
	
	float lifespanModifier = self.mass <= ASTEROID_HARMLESS_RADIUS ? .25 : 1.0;
	float spawnRadius = self.mass <= ASTEROID_HARMLESS_RADIUS ? 1.0 : self.mass * .5;
	uint i,max = temperature > 0 ? ceil(self.mass * .5) : 1;
	Vector pos,inArea;
	pos.x = self.position.x;
	pos.y = self.position.y;
	
	for (i=0; i<max; i++) {
		
		// get reference to particle
		Particle* p = &collection[index];
		
		// get random position within radius of asteroid
		VectorRandomize(&inArea, spawnRadius);
		p->position.x = self->position.x + inArea.x;
		p->position.y = self->position.y + inArea.y;
		p->radius = fmax(1.0,mathRandom() * 2.5) + temperature * 1.25,
		p->life = ASTEROID_PARTICLE_LIFESPAN * lifespanModifier;
		p->temperature = temperature;
		p->plasma = FALSE;
		VectorRandomize(&p->velocity, .05);
		
		index = index + 1 < PARTICLE_LIMIT ? index + 1 : 0;
	}
	
	if (self.dead) {
		
		max = fmax(6.0,self.mass * 3.0);
		
		for (i=0; i<max; i++) {
			
			// get reference to particle
			Particle* p = &collection[index];
			
			// get random position within radius of asteroid
			VectorRandomize(&inArea, spawnRadius);
			p->position.x = self->position.x + inArea.x;
			p->position.y = self->position.y + inArea.y;
			p->radius = fmax(.5,mathRandom() * 2.0) + temperature * .25,
			p->life = ASTEROID_PARTICLE_LIFESPAN;
			p->temperature = temperature;
			p->plasma = FALSE;
			VectorRandomize(&p->velocity, .25);
			
			index = index + 1 < PARTICLE_LIMIT ? index + 1 : 0;
		}
	}
		
	return index;
}




-(void)push:(Vector)origin {
	
	//impulse.x = self.position.x - origin.x;
	//impulse.y = self.position.y - origin.y;
	
}



@end
