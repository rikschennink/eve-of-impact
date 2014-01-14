/*
 *  Particle.h
 *  Eve of Impact
 *
 *  Created by Rik Schennink on 7/8/10.
 *  Copyright 2010 Rik Schennink. All rights reserved.
 *
 */

#import "Vector.h"

// Particle structure
typedef struct {
	Vector position;
	Vector velocity;
	float radius;
	float temperature;
	int life;
	BOOL plasma;
} Particle;
