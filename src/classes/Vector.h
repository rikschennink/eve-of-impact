
#import "MathAdditional.h"

// vector object
typedef struct {
	float x;
	float y;
} Vector;

// create vector
static inline Vector VectorMake(float x,float y) {
	Vector v;
	v.x = x;
	v.y = y;
	return v;
}

// reset vector
static inline void vectorReset(Vector *v) {
	v->x = 0.0;
	v->y = 0.0;
}

// create random vector
static inline Vector VectorMakeRandom(float range) {
	Vector v;
	v.x = range * (2*(-.5+mathRandom()));
	v.y = range * (2*(-.5+mathRandom()));
	return v;
}

// apply random values to vector
static inline void VectorRandomize(Vector *v,float range) {
	v->x = range * (2*(-.5+mathRandom()));
	v->y = range * (2*(-.5+mathRandom()));
}

static inline Vector VectorMakeWithPoint(CGPoint p) {
	return VectorMake(p.x,p.y);
}

// clone vector
static inline Vector vectorClone(Vector *v) {
	return VectorMake(v->x,v->y);
}

// add other vector
static inline Vector vectorAddToVector(Vector *a,Vector *b) {
	Vector v;
	v.x = a->x + b->x;
	v.y = a->y + b->y;
	return v;
}

// subtract vector 
static inline Vector vectorSubtractFromVector(Vector *a,Vector *b) {
	Vector v;
	v.x = a->x - b->x;
	v.y = a->y - b->y;
	return v;
}

// multiply vector 
static inline Vector vectorMultiplyWithAmount(Vector *v,float amount) {
	return VectorMake(v->x * amount, v->y * amount);
}

// divide vector 
static inline Vector vectorDivideByAmount(Vector *v,float amount) {
	return VectorMake(v->x / amount, v->y / amount);
}

// get magnitude
static inline float vectorGetMagnitude(Vector *v) {
	return sqrtf(v->x * v->x + v->y * v->y);
}

// get squared magnitude
static inline float vectorGetMagnitudeSquared(Vector *v) {
	return v->x * v->x + v->y * v->y;
}

// rotate vector
static inline void vectorRotateByDegrees(Vector *v,float degrees) {
	float magnitude = vectorGetMagnitude(v);
	float angle = ((atan2(v->y,v->x) * TRIG_180_D_PI) + degrees) * TRIG_PI_D_180;
	v->x = magnitude * cos(angle);
	v->y = magnitude * sin(angle);
}

// invert vector
static inline void vectorInvert(Vector *v) {
	v->x = -v->x;
	v->y = -v->y;
}

// dot product of vector
static inline float vectorDotWithVector(Vector *a,Vector *b) {
	return a->x * b->x + a->y * b->y;
}

// normalize vector
static inline void vectorNormalize(Vector *v) {
	float magnitude = vectorGetMagnitude(v);
	if (magnitude>0) {
		v->x /= magnitude;
		v->y /= magnitude;
	}
}

// limit vector
static inline void vectorLimit(Vector *v,float treshold) {
	if (vectorGetMagnitude(v) > treshold) {
		vectorNormalize(v);
		v->x *= treshold;
		v->y *= treshold;
	}
}

// randomze vector
static inline void vectorRandomize(Vector *v) {
	v->x = 2*(-.5+mathRandom());
	v->y = 2*(-.5+mathRandom());
}

// round vector
static inline void vectorRound(Vector *v) {
	v->x = round(v->x);
	v->y = round(v->y);
}
				 
// flip vector
static inline void vectorFlip(Vector *v) {
	float temp = v->y;
	v->y = v->x;
	v->x = temp;
}

static inline float vectorGetDistanceSquared(Vector *from,Vector *to) {
	float dx,dy;
	dx = to->x - from->x;
	dy = to->y - from->y;
	return dx * dx + dy * dy;
}

// angle between vectors
static inline float vectorGetAngleBetween(Vector *a,Vector *b) {
	return atan2(b->y - a->y, b->x - a->x) * 180 / M_PI;
}

static inline Vector getRandomPositionAtDistanceFromCenter(float distance) {
	float randomAngle = 360 * mathRandom() * TRIG_PI_D_180;
	return VectorMake(distance * cos(randomAngle), distance * sin(randomAngle));
}








