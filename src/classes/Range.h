//
//  Range.h
//  Eve of Impact
//
//  Created by Rik Schennink on 3/31/11.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

// Range object
typedef struct {
	float min;
	float max;
} Range;

// Range vector
static inline Range RangeMake(float min,float max) {
	Range r;
	r.min = max;
	r.max = max;
	return r;
}

