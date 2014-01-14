/*
 *  Easing.h
 *  Eve of Impact
 *
 *  Created by Rik Schennink on 7/8/10.
 *  Copyright 2010 Rik Schennink. All rights reserved.
 *
 */

#import "MathAdditional.h"


static inline float easeFastSlowFast(float e,float d) {
	float ts = (e/=d)*e;
	float tc = ts*e;
	return 0.999999999999998*tc*ts + 1.77635683940025e-15*tc + -2*ts + 2 * e; 
}

static inline float easeInCubic(float e,float d) {
	return (e/=d)*e*e;
}

static inline float easeOutCubic(float e,float d) {
	return -1 * ((e=e/d-1)*e*e-1);
}

static inline float easeInQuartic(float e,float d) {
	return (e/=d)*e*e*e;
}

static inline float easeOutQuartic(float e,float d) {
	return -1 * ((e=e/d-1)*e*e*e-1);
}

static inline float easeOutQuintic(float e,float d) {
	return (e=e/d-1)*e*e*e*e+1;
}

static inline float easeInQuintic(float e,float d) {
	return (e/=d)*e*e*e*e;
}

static inline float easeInExponential(float e,float d) {
	return (e==0) ? 0 : pow(2.0, 10 * (e/d-1));
}

static inline float easeOutExponential(float e,float d) {
	return (e==d) ? 1 : (-pow(e, -10  * e/d) + 1);
}

static inline float easeLinear(float e,float d) {
	return e/d;
}

static inline float easeInCircular(float e,float d) {
	return -1 * (sqrtf(1.0 - (e/=d)*e)-1.0);
}

static inline float easeInOutCircular(float e,float d) {
	if ((e/=d/2.0) < 1.0) {
		return -.5 * (sqrtf(1.0 - e*e) - 1.0);
	}
	return .5 * (sqrtf(1.0 - (e-=2.0)*e) + 1.0);
}

static inline float easeInSine(float e,float d) {
	return -1 * cos(e / d * TRIG_PI_D_2) + 1.0;
}

static inline float easeOutSine(float e,float d) {
	return sin(e/d * TRIG_PI_D_2);
}

static inline float easeInOutSine(float e,float d) {
	return -.5 * (cos(TRIG_PI*e/d)-1.0);
}

static inline float easeInElastic(float e,float d,float amp,float period) {
	if (e<=0) {
		return 0;
	}
	if ((e/=d) >= 1) {
		return 1;
	}
	if (period==0) {
		period = d * .3;
	}
	float decay;
	if (amp < 1) {
		amp = 1;
		decay = period * .25;
	}
	else {
		decay = period / TRIG_PI_M_2 * asin(1/amp);
	}
	return -(amp*pow(2, 10*(e-=1)) * sin((e*d-decay)*TRIG_PI_M_2/period));
}

static inline float easeOutElastic(float e,float d,float amp,float period) {
	if (e<=0) {
		return 0;
	}
	if ((e/=d) >= 1) {
		return 1;
	}
	if (period==0) {
		period = d * .3;
	}
	float decay;
	if (amp < 1) {
		amp = 1;
		decay = period * .25;
	}
	else {
		decay = period / TRIG_PI_M_2 * asin(1/amp);
	}
	return (amp*pow(2, -10*e) * sin((e*d-decay)*TRIG_PI_M_2/period) + 1);
}

static inline float easeOutInElastic(float e,float d,float amp,float period) {
	if (e<d*.5) {
		return easeOutElastic(e*2, d, amp, period)*.5;
	}
	return easeInElastic((e*2)-d, d, amp, period)*.5 + .5;
	
}











