// 
//  MissileActor.m
//  Eve of Impact
//
//  Created by Rik Schennink on 4/6/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "MissileActor.h"
#import "MathAdditional.h"
#import "Vector.h"
#import "MissileMoveBehaviour.h"
#import "MissileStateBehaviour.h"
#import "PlanetActor.h"

#import "Explodable.h"
#import "MoonActor.h"
#import "ShieldActor.h"
#import "ShipActorBase.h"
#import "AsteroidActor.h"

@implementation MissileActor

@synthesize payload,target,debree;


-(id)initWithOrigin:(Vector)myOrigin 
			 target:(Vector)myTarget 
			  speed:(float)speed 
		  andRecoil:(CGFloat)myRecoil {
	
	Vector start,end,diff;
	
	start.x = myOrigin.x;
	start.y = myOrigin.y;
	
	end.x = myTarget.x;
	end.y = myTarget.y;
	
	float offset = 0.0;
	
	if (myRecoil > 0.0) {
		
		diff.x = end.x - start.x;
		diff.y = end.y - start.y;
		
		float distance = vectorGetMagnitude(&diff);
		float bend = 4.0 - (2*myRecoil);
		offset = -(distance/bend) + (mathRandom() * (distance / (bend/2)));
		
	}
	
	
	self = [super initWithRadius:2.5
							state:(StateBehaviourBase<StateBehaviour>*)[[MissileStateBehaviour alloc] init]
						 movement:[[MissileMoveBehaviour alloc] initWithStart:start 
																		  end:end
																 anchorOffset:offset 
																	 andSpeed:speed]];
	
	if (self) {
		
		[self setHistoryKeeper:[[HistoryBehaviourBase alloc] initWithMaxCoordinates:50]];
		
		position.x = myOrigin.x;
		position.y = myOrigin.y;
								
		target = myTarget;
		
	}
	
	return self;
}

-(BOOL)canCollideWith:(ActorBase*)actor {
	
	if ([state contains:STATE_DYING]) { 
		return false;
	}
	
	if ([actor isKindOfClass:[MoonActor class]]) {
		return true;
	}
	
	return false;
}

-(void)collideWith:(ActorBase*)actor afterTime:(float)time {
	
	position.x += self.velocity.x * time;
	position.y += self.velocity.y * time;
	
	[self readyToExplode];
	
}

-(void)readyToExplode {
	
	if (![state contains:STATE_DYING]) {
		
		velocity.x = 0;
		velocity.y = 0;
		
		[self.state replace:STATE_ALIVE with:STATE_DYING];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"MissileExplosion" object:self];
		
		[movement release];
		movement = nil;
		
		[state setNewLifespan:20];
	}
}

-(void)dealloc {
	
	[super dealloc];
}

@end
