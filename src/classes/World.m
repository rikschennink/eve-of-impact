//
//  World.m
//  Eve of Impact
//
//  Created by Rik Schennink on 2/12/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "ActorBase.h"
#import "AsteroidActor.h"
#import "NukeExplosionActor.h"
#import "Puller.h"
#import "Collidable.h"
#import "Collision.h"
#import "Easing.h"
#import "ImpactActor.h"
#import "Prefs.h"
#import "Pusher.h"
#import "Puller.h"
#import "World.h"

@implementation World

@synthesize actors,asteroids,impacts,pushers;

-(id)init {
	
	if (self = [super init]) {
		
		actorQueue = [[NSMutableArray alloc] init];
		actorTransfers = [[NSMutableArray alloc] init];
		
		actors = [[NSMutableArray alloc] init];
		pullables = [[NSMutableArray alloc] init];
		asteroids = [[NSMutableArray alloc] init];
		collidables = [[NSMutableArray alloc] init];
		pullers = [[NSMutableArray alloc] init];
		pushers = [[NSMutableArray alloc] init];
		impacts = [[NSMutableArray alloc] init];
		pushables = [[NSMutableArray alloc] init];
		
		actorCollections = [[NSMutableArray alloc] init];
		[actorCollections addObject:actors];
		[actorCollections addObject:pullables];
		[actorCollections addObject:asteroids];
		[actorCollections addObject:collidables];
		[actorCollections addObject:pullers];
		[actorCollections addObject:pushers];
		[actorCollections addObject:impacts];
		[actorCollections addObject:pushables];
		
		
		worldCenter = VectorMake(0,0);
		gravityForce = VectorMake(0,0);
		gravityTotalForce = VectorMake(0,0);
		gravityProjection = VectorMake(0,0);
		
	}
	return self;
	
}


-(void)addActorToQueue:(ActorBase*)actor {
	
	[actorQueue addObject:actor];
	
}

-(void)transferActor:(ActorBase*)actor {
	
	// add actor to default actor array
	[actors addObject:actor];
	
	// put actor in specific arrays
	if ([actor conformsToProtocol:@protocol(Collidable)]) {
		[collidables addObject:actor];
	}
	
	if ([actor conformsToProtocol:@protocol(Puller)]) {
		[pullers addObject:actor];
	}
	
	if ([actor conformsToProtocol:@protocol(Pullable)]) {
		[pullables addObject:actor];
	}
	
	if ([actor conformsToProtocol:@protocol(Pusher)]) {
		[pushers addObject:actor];
	}
	
	if ([actor conformsToProtocol:@protocol(Pushable)]) {
		[pushables addObject:actor];
	}
	
	if ([actor isKindOfClass:[AsteroidActor class]]) {
		[asteroids addObject:actor];
	}
	
	if ([actor isKindOfClass:[ImpactActor class]]) {
		[impacts addObject:actor];
	}
}

-(void)update {
	
	// manage actor collections
	[self manageActors];
	
	// do collision handling
	[self handleCollisions];
	
	// apply physics to actors
	[self applyPhysics];
	
	// start the real acting
	[self act];
}

-(void)act {
	for (ActorBase* actor in actors) {
		[actor act];
	}
}

-(void)manageActors {
	
	if ([actorQueue count]>0) {
		
		// copy queue
		[actorTransfers removeAllObjects];
		[actorTransfers addObjectsFromArray:actorQueue];
		
		// clear queue
		[actorQueue removeAllObjects];
		
		// add actors to be transfered to actual actor array
		[self transfer];
		
	}
	
	// filter asteroids that have gone out of view
	[self filter];
	
	// clean actors that are waiting to be disposed of
	[self clean];
}

-(void)clean {
	for (NSMutableArray* collection in actorCollections) {
		for (ActorBase* actor in [collection reverseObjectEnumerator]) {
			if ([actor inLimbo]) {
				[collection removeObject:actor];
			}
		}
	}
}

-(void)transfer {
	for (ActorBase* actor in actorTransfers) {
		[self transferActor:actor];
	}
}

-(void)filter {
	for (ActorBase* actor in collidables) {
		if ([actor.state contains:STATE_LEFT]) {
			[actor kill];
		}
	}
}

-(void)handleCollisions {
	
	uint i,j,count = [collidables count];
	ActorBase<Collidable>* a;
	ActorBase<Collidable>* b;
	float t = 0;
	
	SEL objectAtIndexSelector = @selector(objectAtIndex:);
	IMP objectAtIndexIMP = [collidables methodForSelector:objectAtIndexSelector];
	
	for (i=0; i<count; i++) {
		for (j=i+1; j<count; j++) {
			
			a = (*objectAtIndexIMP)(collidables,objectAtIndexSelector,i);
			b = (*objectAtIndexIMP)(collidables,objectAtIndexSelector,j);
			
			// check if objects CAN collide with each other
			if ([a canCollideWith:b] || [b canCollideWith:a]) {
				
				// get time till possible collision
				t = getCollisionTimeBetween(a.position.x, a.position.y, a.velocity.x, a.velocity.y, a.radius, 
											b.position.x, b.position.y, b.velocity.x, b.velocity.y, b.radius);
				
				// collision is occuring or will occur so let's handle it
				if (t >=0 && t<=1) {
					
					[a collideWith:b afterTime:t];
					[b collideWith:a afterTime:t];
					
				}
			}
		}
	}
}

-(void)applyPhysics {
	
	float distance,massDistance,dp,force,planetDistance;
	Vector ap,av;
	
	for (ActorBase<Pullable>* actor in pullables) {
		
		gravityTotalForce.x = 0;
		gravityTotalForce.y = 0;
		
		// apply all puller forces to the actor
		for(ActorBase<Puller>* puller in pullers) {
			
			// start gravity pull calculations
			gravityForce.x = puller.position.x - actor.position.x;
			gravityForce.y = puller.position.y - actor.position.y;
			distance = sqrtf(gravityForce.x * gravityForce.x + gravityForce.y * gravityForce.y);
			
			// normalize
			gravityForce.x/=distance;
			gravityForce.y/=distance;
			
			// calculate added force
			massDistance = puller.mass / distance;
			gravityForce.x *= massDistance;
			gravityForce.y *= massDistance;
			
			if ([actor.state contains:STATE_LEAVING]) { 
				// force on leaving actors is fraction of normal force to allow escape
				gravityForce.x *= .325; //.25
				gravityForce.y *= .325;
			}
			
			// add force for this puller to total force
			gravityTotalForce.x += gravityForce.x;
			gravityTotalForce.y += gravityForce.y;
		}
		
		actor->velocity.x += gravityTotalForce.x;
		actor->velocity.y += gravityTotalForce.y;
	}
	
	for (ActorBase<Pushable>* actor in pushables) {
		
		gravityTotalForce.x = 0;
		gravityTotalForce.y = 0;
		
		// calculate shockwave effect of explosions
		for(ActorBase<Pusher>* pusher in pushers) {
			
			if ([pusher.state contains:STATE_ALIVE]) {
				
				// get squared distance to explosion
				gravityForce.x = actor.position.x - pusher.position.x;
				gravityForce.y = actor.position.y - pusher.position.y;
				distance = gravityForce.x * gravityForce.x + gravityForce.y * gravityForce.y;
				
				// if distance is within explosion shockwave radius range
				if (distance < pusher.pushRadius * pusher.pushRadius) {
					
					// signal actor that he's gonna be pushed from this position
					[actor push:pusher.position];
					
					// only calculate real distance when explosion close enough to asteroid, prevent not needed sqrt calls
					distance = sqrtf(distance);
					
					// project vector "pushable to pusher" on velocity vector of pushable to calculate the force of push
					// a push has more force if it is on the side of a pushable
					if ([pusher isKindOfClass:[NukeExplosionActor class]]) {
						
						// if actor is invulnerable to nothing
						if ([actor.state contains:STATE_INVULNERABLE]) {
							continue;
						}
						
						ap.x = pusher.position.x - actor.position.x;
						ap.y = pusher.position.y - actor.position.y;
						vectorNormalize(&ap);
						
						av.x = actor.velocity.x;
						av.y = actor.velocity.y;
						vectorNormalize(&av);
						
						// dotproduct of ap with av
						dp = ap.x * av.x + ap.y * av.y;
						gravityProjection.x = dp * av.x;
						gravityProjection.y = dp * av.y;

						// invert length of projection results in brute force of explosion
						force = 1.0 - sqrtf(gravityProjection.x * gravityProjection.x + 
											gravityProjection.y * gravityProjection.y);
						
						force = easeOutSine(force,1.0);
						
						// multiplied by push force
						force *= pusher.pushForce;
						force *= 1.0 - easeLinear(distance,pusher.pushRadius);
						
						// multiplied by actor mass
						force *= 1.0 - (actor.mass * .05);
						
						// closer to planet force is decreased
						planetDistance = getDistanceSquaredToPlanet(pusher.position.x, pusher.position.y);
						if (planetDistance < EXPLOSION_WEAKEN_DISTANCE_SQUARED) {
							force *= easeLinear(planetDistance - 500.0, EXPLOSION_WEAKEN_DISTANCE_SQUARED);
						}
					}
					else {
						force = 1.0;
						force *= pusher.pushForce;
					}
					
					// normalize
					gravityForce.x/=distance;
					gravityForce.y/=distance;
					
					gravityForce.x *= force;
					gravityForce.y *= force;
					
					gravityTotalForce.x += gravityForce.x;
					gravityTotalForce.y += gravityForce.y;
					
				}
			}
		}
		
		actor->velocity.x += gravityTotalForce.x;
		actor->velocity.y += gravityTotalForce.y;
	}
}

-(void)flush {
	
	for (NSMutableArray* collection in actorCollections) {
		for (ActorBase* actor in [collection reverseObjectEnumerator]) {
			[actor flush];
		}
	}
	
	[actorTransfers removeAllObjects];
	[actorQueue removeAllObjects];
	
	[self clean];
}

-(void)dealloc {
	
	[actorQueue release];
	[actorTransfers release];
	[asteroids release];
	[pullers release];
	[collidables release];
	[actors release];
	[pushers release];
	[pushables release];
	[actorCollections release];
	
	
	[super dealloc];
}


@end
