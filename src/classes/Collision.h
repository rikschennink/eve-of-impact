
#import "Vector.h"


static inline float getCollisionTimeBetween(float x1,float y1,float vx1,float vy1, float r1,float x2,float y2,float vx2,float vy2, float r2) {
	
	// get distance squared and decide if collision detection should take place
	float dx,dy,ddot,c,t;
	dx = x2 - x1;
	dy = y2 - y1;
	ddot = dx * dx + dy * dy;
	
	//if the sum of the circles' radii squared > the distance between them squared they are overlapping
	c = ddot - (r1 + r2) * (r1 + r2);
	
	if (c < 0) {
		// the actors are already overlapping
		return 0;
	}
	
	// difference between actors' velocities
	float vx,vy,vdot,a;
	vx = vx2 - vx1;
	vy = vy2 - vy1;
	vdot = vx * vx + vy * vy;
	
	a = vdot;
	if (a < .000000001) { // .000000001 == minimum collision distance
		return -1; // actors are not moving relative to each other
	}
	
	float b = vx * dx + vy * dy;
	if (b >= 0) {
		return -1; // actors are moving away from each other
	}
	
	float d = b * b - a * c;
	if (d < 0) {
		return -1; // no solution to quadratic equation circles don't intersect
	}
	
	// get time of collision
	t = (-b - sqrtf(d)) / a;
	
	// return time till collision
	return t;
}

static inline bool doesRayIntersectWithCenterArea(Vector *origin,Vector *heading,float radius) {
	Vector towards;
	towards.x = -origin->x;
	towards.y = -origin->y;
	float length = vectorGetMagnitudeSquared(&towards);
	float v = vectorDotWithVector(&towards,heading);
	float d = radius * radius - (length * length - v * v);
	return d<0;
}


