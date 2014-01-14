/*
 *  AICommand.h
 *  Eve of Impact
 *
 *  Created by Rik Schennink on 7/8/10.
 *  Copyright 2010 Rik Schennink. All rights reserved.
 *
 */

#import "Vector.h"

// AICommand object
typedef struct {
	Vector position;
	Vector velocity;
	float velocityMax;
	float mass;
} AICommand;

// create AICommand
static inline AICommand AICommandMake(Vector position, Vector velocity, float velocityMax, float mass) {
	AICommand c;
	c.position = position;
	c.velocity = velocity;
	c.velocityMax = velocityMax;
	c.mass = mass;
	return c;
}