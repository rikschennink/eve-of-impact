/*
 *  State.h
 *  Eve of Impact
 *
 *  Created by Rik Schennink on 8/10/10.
 *  Copyright 2010 Rik Schennink. All rights reserved.
 *
 */


typedef struct {
	uint life;
	uint type;
} State;

static inline State StateMake(uint type) {
	State s;
	s.type = type;
	s.life = 0;
	return s;
}
