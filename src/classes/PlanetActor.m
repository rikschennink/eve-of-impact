//
//  PlanetActor.m
//  Eve of Impact
//
//  Created by Rik Schennink on 2/15/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "AsteroidActor.h"
#import "PlanetImpactActor.h"
#import "MoonActor.h"
#import "PlanetActor.h"
#import "PlanetDebreeActor.h"
#import "ShipActorBase.h"
#import "ShieldActor.h"
#import "Explodable.h"

@implementation PlanetActor

@synthesize impacts;

-(id)initWithRadius:(float)r andMass:(float)m {
	
	self = [super initWithRadius:r
			 state:(StateBehaviourBase<StateBehaviour>*)[[StateBehaviourBase alloc] init]
		  movement:[[MoveBehaviourBase alloc] init]];

	if (self) {
		
		mass = m;
		impacts = [[NSMutableArray alloc]init];
	} 
	
	return self;
	
}

-(void)act {
	
	// do acting
	[super act];
	
	for (ImpactActor* actor in [impacts reverseObjectEnumerator]) {
		if ([actor inLimbo]) {
			
			[self.state replace:STATE_DYING with:STATE_DEAD];
			
			[impacts removeObject:actor];
			
		}
	}
	
}

-(void)bindImpact:(ImpactActor*)impact {
	[impacts addObject:impact];
}

-(void)clearImpacts {
	[impacts removeAllObjects];
}

-(BOOL)canCollideWith:(ActorBase*)actor {
	return false;
}

-(void)collideWith:(ActorBase *)actor afterTime:(float)time {
	
	if([actor isKindOfClass:[AsteroidActor class]] && !actor.mass <= ASTEROID_HARMLESS_RADIUS) {
		
		if (![self.state contains:STATE_DEAD]) {
			[self.state replace:STATE_ALIVE with:STATE_DYING];
		}
		
		ActorBase<Collidable>* collidable = (ActorBase<Collidable>*)actor;
		
		// define impact actor
		PlanetImpactActor* impact = [[PlanetImpactActor alloc]initWithMass:collidable.mass];
		
		// angle of impact
		float angleDegrees = vectorGetAngleBetween(&collidable->position, &self->position);
		float angle = (angleDegrees + 180.0) * TRIG_PI_D_180;
		
		// calculate impact position by angle
		float distance = self.radius - 1.0;
		impact->position.x = cos(angle) * distance;
		impact->position.y = sin(angle) * distance;
		
		// bind this impact to the planet actor
		[self bindImpact:impact];
				
		
		
		
		NSMutableArray* debree = [[NSMutableArray alloc] init];
		
		uint i;
		Vector v;
		Vector s = vectorClone(&collidable->position);
		vectorNormalize(&s);
		
		// launch debree
		float range = 90 + (actor.mass * 10);
		uint amount = 4.0 + (actor.mass * 3);
		angle -= range * .5;
		
		uint life = 0;
		float magnitude;
		float part = range / amount;//;(amount-1);
		float sideBoost = 0;
		sideBoost -= amount * .5;
		
		for (i=0; i<amount; i++) {
			
			magnitude = randomBetween(.3, .7);// = .54
			
			v.x = s.x;
			v.y = s.y;
			
			vectorRotateByDegrees(&v, angle + randomBetween(-5, 5));
			
			v = vectorMultiplyWithAmount(&v, magnitude + (fabs(sideBoost) * .03));
			
			life = magnitude * (125 - (fabs(sideBoost) * 10)) + randomBetween(0, 10);
			
			PlanetDebreeActor* rock = [[PlanetDebreeActor alloc] initWithTemperature:1.0 andLifespan:life];
			rock->position.x = actor.position.x + (-s.x * 2.0);
			rock->position.y = actor.position.y + (-s.y * 2.0);
			rock->velocity.x = v.x;
			rock->velocity.y = v.y;
			
			// debree now holds asteroid
			[debree addObject:rock];
			
			// release hold on asteroid
			[rock release];
			
			sideBoost++;
			angle += part;
		}
		
		// notify of this impact and pass impact along
		[[NSNotificationCenter defaultCenter] postNotificationName:@"AsteroidImpact" object:impact];
		
		// notify of earth asteroid impact
		[[NSNotificationCenter defaultCenter] postNotificationName:@"EarthImpacted" object:actor];
		
		// send debree stuff
		[[NSNotificationCenter defaultCenter] postNotificationName:@"AsteroidShattered" object:debree];
		
		// release debree
		[debree release];
		
		// release impact
		[impact release];
		
		// kill asteroid
		[actor kill];
	}
}

-(void)flush {
	[self.state remove:STATE_DEAD];
	[self.state remove:STATE_DYING];
	[self.state remove:STATE_ALIVE];
	[self.state add:STATE_ALIVE];
	[self clearImpacts];
}

-(void)dealloc {
	
	[impacts release];
	
	[super dealloc];
	
}


@end
