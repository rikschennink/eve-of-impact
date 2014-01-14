//
//  ShieldActor.m
//  Eve of Impact
//
//  Created by Rik Schennink on 10/28/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "AsteroidActor.h"
#import "Prefs.h"
#import "ShieldActor.h"
#import "ShieldImpactActor.h"
#import "ShieldShockwaveActor.h"
#import "Particle.h"

@implementation ShieldActor

@synthesize impacts,energy,enabled,power;

-(id)init {
	
	if ((self = [super init])) {
		
		energy = SHIELD_INITIAL_ENERGY;
		impacts = [[NSMutableArray alloc]init];
		self.radius = SHIELD_RANGE;
		power = 0;
		enabled = YES;
		overloading = NO;
	}
	
	return self;
}

-(void)act {
	
	[super act];
	
	if (overloading) {
		[self overload];
		return;
	}
	
	if (power > 0.0) {
		power = fmax(0.0,power-.1);
		[self charge:.1];
		return;
	}
	
	if (enabled) {
		[self charge:SHIELD_CHARGE_STEP];
	}
}

-(void)charge:(float)amount {
	energy = energy + amount < 1.0 ? energy + amount : 1.0;
}

-(void)drain:(float)amount {
	energy = energy - amount > 0.0 ? energy - amount : 0.0;
}

-(void)blow {
	
	overloading = NO;
	
	// reset power
	power = 0.0;
	
	// set shockwave actor
	ShieldShockwaveActor* shockwave = [[ShieldShockwaveActor alloc] initWithRange:SHIELD_SHOCKWAVE_RANGE];
	
	// blow away shield, force and distance depends on shield charge
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ShieldShockwaveReleased" object:shockwave];
	
	[shockwave release];
}

-(void)overloadStart {
	if (enabled && power == 0.0 && energy > SHIELD_OVERLOAD_ENERGY) {
		overloading = YES;
	}
}

-(void)overloadCancel {
	overloading = NO;
}

-(BOOL)isOverloading {
	return overloading;
}

-(void)overload {
	
	float cost = fmin(energy,1.0 / SHIELD_OVERLOAD_DURATION);
	
	if (power + cost > SHIELD_OVERLOAD_ENERGY) {
		
		cost = (power + cost) - SHIELD_OVERLOAD_ENERGY;
		
		[self drain:cost];
		
		power = SHIELD_OVERLOAD_ENERGY;
		
		[self blow];
	}
	else {
		power += cost;
		
		[self drain:cost];
	}
}

-(BOOL)canCollideWith:(ActorBase*)actor {
	return false;
}

-(void)collideWith:(ActorBase *)actor afterTime:(float)time {
	
	if([actor conformsToProtocol:@protocol(Collidable)] && enabled) {
		
		ActorBase<Collidable>* collidable = (ActorBase<Collidable>*)actor;
		
		// check if impact for this actor has already been added
		BOOL found = NO;
		for (ShieldImpactActor* impact in impacts) {
			if (collidable.uid == impact.relatedActorUID) {
				found = YES;
			}
		}
		
		if (!found) {
			
			// drain energy required to absorb asteroid
			float energyImpact = [self getEnergyToDeflectObjectWith:collidable.mass];
			
			// take energy from shield
			[self drain:energyImpact];
			
			// if energy of shield is still above 0.0 kill the actor
			if (energy > 0.0) {
				[actor kill];
			}

			// define impact actor
			ShieldImpactActor* impact = [[ShieldImpactActor alloc] initWithMass:collidable.mass andRelatedActorUID:collidable.uid];
			impact.angle = (vectorGetAngleBetween(&collidable->position, &self->position) + 180.0) * TRIG_PI_D_180;
			impact->position.x = self.position.x + (cos(impact.angle) * (self.radius-.25));
			impact->position.y = self.position.y + (sin(impact.angle) * (self.radius-.25));
			[impacts addObject:impact];
			
			// notify of this impact and pass impact along
			[[NSNotificationCenter defaultCenter] postNotificationName:@"AsteroidImpact" object:impact];
			[impact release];
		}
	}
}

-(float)getEnergyToDeflectObjectWith:(float)objectMass {
	return fmaxf(.05,objectMass * .15);
}

-(BOOL)willDeflectObjectWith:(float)objectMass {
	return energy > [self getEnergyToDeflectObjectWith:objectMass];
}

-(void)disable {
	enabled = NO;
}

-(void)bindImpact:(ImpactActor*)impact {}

-(void)clearImpacts {
	[impacts removeAllObjects];
}

-(void)flush {
	enabled = YES;
	energy = SHIELD_INITIAL_ENERGY;
	[self clearImpacts];
}

-(uint)addEmissionsTo:(Particle*)collection atIndex:(uint)index {
	
	if (overloading) {
		
		uint i,max = 3;
		Vector pos;
		
		for (i=0; i<max; i++) {
			
			// get reference to particle
			Particle* p = &collection[index];
			
			pos = getRandomPositionAtDistanceFromCenter(SHIELD_RANGE + randomBetween(1.0, 3.0));
			p->position.x = pos.x + self.position.x;
			p->position.y = pos.y + self.position.y;
			
			// get random position within radius of asteroid
			p->radius = fmax(1.5,mathRandom() * 2.5);
			p->life = 30;
			p->plasma = TRUE;
			p->temperature = .5;
			p->velocity.x = -pos.x * .01 * mathRandom();
			p->velocity.y = -pos.y * .01 * mathRandom();
			
			index = index + 1 < PARTICLE_LIMIT ? index + 1 : 0;
		}
	}
	
    return index;
}


-(void)dealloc {
	
	[impacts release];
	
	[super dealloc];
}

@end
