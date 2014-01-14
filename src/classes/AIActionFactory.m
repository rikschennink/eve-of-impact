//
//  AIActionFactory.m
//  Eve of Impact
//
//  Created by Rik Schennink on 7/8/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "AIActionFactory.h"
#import "Prefs.h"
#import "MathAdditional.h"
#import "Vector.h"
#import "Range.h"
#import "AI.h"

@implementation AIActionFactory

-(id)init {
	
	self = [super init];
	
	if (self) {
		
		[self reset];
		
	}
	
	return self;
}

-(void)reset {
	originTimer = 4;
	originRange = RangeMake(330, 360);
	asteroidVelocityMax = ASTEROID_VELOCITY;
}

-(AIAction*)getAIActionForDifficulty:(uint)difficulty {
	
	// define action
	AIAction* action = [[[AIAction alloc]init] autorelease];
	
	// if origin timer reaches 0 pick new origin range
	if (originTimer > 0) {
		originTimer--;
	}
	
	// fill action object
	if (difficulty==INTRO) {
		asteroidVelocityMax = ASTEROID_VELOCITY;
		[self setIntroAction:action];
		
	}
	else if (difficulty==EASY) {
		asteroidVelocityMax = ASTEROID_VELOCITY;
		
		if (originTimer == 0) {
			originRange.max = randomBetween(30,360);
			originRange.min = originRange.max - 30;
			originTimer = randomBetween(5, 7);
		}
		[self setEasyAction:action];		
	}
	else if (difficulty==MEDIUM) {
		
		asteroidVelocityMax = ASTEROID_VELOCITY + .025;
		
		if (originTimer == 0) {
			originRange.max = randomBetween(70, 360);
			originRange.min = originRange.max - 70;
			originTimer = randomBetween(3, 6);
		}
		
		[self setMediumAction:action];
		
	}
	else if (difficulty==HARD) {
		
		asteroidVelocityMax = ASTEROID_VELOCITY + .065;
		
		if (originTimer == 0) {
			originRange.max = randomBetween(160, 360);
			originRange.min = originRange.max - 160;
			originTimer = randomBetween(4, 7);
		}
		
		[self setHardAction:action];
		
	}
	else if (difficulty>=INSANE) {
		
		asteroidVelocityMax = ASTEROID_VELOCITY + .095;
		
		originTimer = 0;
		originRange.max = 360.0;
		originRange.min = 0.0;
		
		[self setInsaneAction:action];
	}
		
	return action;
}

-(void)setIntroAction:(AIAction*)action {
	
	AICommand command = [self getDefaultAsteroidCommand];
	
	command.mass = 2.15;
	command.position.y = 400;
	command.velocityMax = ASTEROID_VELOCITY;
	command.velocity.x = 0;
	
	[action addCommand:command];
}

-(void)setEasyAction:(AIAction*)action {
	
	[self addSmallAsteroidTo:action];
	
}

-(void)setMediumAction:(AIAction*)action {
	
	uint chance = round(randomBetween(0, 4));
	
	switch (chance) {
		case 0:
			[self addMediumAsteroidTo:action];
			break;
		case 1:
			[self addMediumAsteroidTo:action];
			[self addSmallAsteroidTo:action];
			break;
		case 2:
			[self addMediumAsteroidTo:action];
			[self addMediumAsteroidTo:action];
			break;
		case 3:
			[self addGroupOf:3 AsteroidsTo:action];
			break;
		default:
			[self addSmallAsteroidTo:action];
			[self addSmallAsteroidTo:action];
			break;
	}
	
}

-(void)setHardAction:(AIAction*)action {
	
	uint chance = round(randomBetween(0, 4));
	
	switch (chance) {
		case 0:
			[self addGroupOf:3 AsteroidsTo:action];
			break;
		case 1:
			[self addMediumAsteroidTo:action];
			[self addBigAsteroidTo:action];
			break;
		case 2:
			[self addSmallAsteroidTo:action];
			[self addSmallAsteroidTo:action];
			[self addBigAsteroidTo:action];
			break;
		case 3:
			[self addSmallAsteroidTo:action];
			[self addOpposingAsteroidsTo:action];
			break;
		default:
			[self addGroupOf:2 AsteroidsTo:action];
			[self addBigAsteroidTo:action];
			break;
	}
}

-(void)setInsaneAction:(AIAction*)action {
	
	uint chance = round(randomBetween(0, 8));
	
	switch (chance) {
		case 1:
			[self addGroupOf:4 + (mathRandom() * 3) AsteroidsTo:action];
			[self addOpposingAsteroidsTo:action];
			break;
		case 2:
			[self addOpposingAsteroidsTo:action];
			[self addOpposingAsteroidsTo:action];
			break;
		case 3:
			[self addSmallAsteroidTo:action];
			[self addMediumAsteroidTo:action];
			break;
		case 4:
			[self addMediumAsteroidTo:action];
			[self addOpposingAsteroidsTo:action];
			break;
		case 5:
			[self addSmallAsteroidTo:action];
			[self addBigAsteroidTo:action];
			[self addGroupOf:3 AsteroidsTo:action];
			break;
		case 6:
			[self addSmallAsteroidTo:action];
			[self addGroupOf:2 + (mathRandom() * 3) AsteroidsTo:action];
			break;
		case 7:
			[self addGroupOf:2 + (mathRandom() * 3) AsteroidsTo:action];
			[self addGroupOf:2 + (mathRandom() * 3) AsteroidsTo:action];
			break;
		default:
			[self addGroupOf:5 AsteroidsTo:action];
			[self addBigAsteroidTo:action];
			break;
	}
}

-(void)addSmallAsteroidTo:(AIAction*)action {
	AICommand command = [self getDefaultAsteroidCommand];	
	command.mass += mathRandom() * .5;
	[action addCommand:command];
}

-(void)addMediumAsteroidTo:(AIAction*)action {
	
	AICommand command = [self getDefaultAsteroidCommand];
	command.mass = 2.5 + mathRandom();
	
	[action addCommand:command];
}

-(void)addBigAsteroidTo:(AIAction*)action {
	
	AICommand command = [self getDefaultAsteroidCommand];
	command.mass = 3.5 + mathRandom();
	
	[action addCommand:command];
}

-(void)addOpposingAsteroidsTo:(AIAction*)action {
	
	AICommand command = [self getDefaultAsteroidCommand];
	command.mass = 1.0 + (2.5 * mathRandom());
	
	AICommand opposite = AICommandMake(command.position, command.velocity, command.velocityMax, command.mass);
	vectorRotateByDegrees(&opposite.position,180);
	vectorRotateByDegrees(&opposite.velocity,180);
	opposite.mass = 1.0 + (2.5 * mathRandom());
	
	[action addCommand:command];
	[action addCommand:opposite];
}

-(void)addGroupOf:(uint)amount AsteroidsTo:(AIAction*)action {
	
	AICommand command = [self getDefaultAsteroidCommand];
	
	for (uint i =0; i<amount; i++) {
		
		command.velocity = vectorMultiplyWithAmount(&command.velocity, mathRandom() * 1.5);
		command.velocity.x += .15 * (-.5 + mathRandom());
		command.velocity.y += .15 * (-.5 + mathRandom());
		command.position = vectorAddToVector(&command.velocity, &command.position);
		command.position.x += 5.0 * (-.5 + mathRandom()) * i;
		command.position.y += 5.0 * (-.5 + mathRandom()) * i;
		command.mass = 0.5 + (2.5 * mathRandom());
		
		[action addCommand:command];
	}
}


/*
 * Returns default asteroid template
 */
-(AICommand)getDefaultAsteroidCommand {
	
	Vector position = VectorMake(0, ASTEROID_SPAWN_DISTANCE);
	
	uint angle = randomBetween(originRange.min, originRange.max);
	vectorRotateByDegrees(&position, angle);
	
	//Vector 
	
	Vector target;
	
	uint missChance = round(randomBetween(0, 10));
	if (missChance > 1) {
		target = getRandomPositionAtDistanceFromCenter(ASTEROID_TARGET_FUZZINESS);
	}
	else {
		target = getRandomPositionAtDistanceFromCenter(ASTEROID_TARGET_FUZZINESS + randomBetween(50.0, 75.0));
	}
		
	float maxVelocity = randomBetween(asteroidVelocityMax - ASTEROID_VELOCITY_RANGE,
									  asteroidVelocityMax + ASTEROID_VELOCITY_RANGE);
	
	Vector velocity = vectorSubtractFromVector(&target, &position);
	vectorNormalize(&velocity);
	velocity = vectorMultiplyWithAmount(&velocity, maxVelocity);
	
	return AICommandMake(position, velocity, maxVelocity, 1.0);
}

@end





















