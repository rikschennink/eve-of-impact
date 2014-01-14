//
//  OpenGLCommon.h
//  Eve of Impact
//
//  Created by Rik Schennink on 4/15/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "MathAdditional.h"

#define BLEND_MODE_DEFAULT		0
#define BLEND_MODE_SCREEN		1
#define BLEND_MODE_MULTIPLY		2
#define BLEND_MODE_DODGE		3
#define BLEND_MODE_MASK			4
#define BLEND_MODE_MASK_ALT		5

#define TEXTURE_ATLAS_DEFAULT_SIZE		1024

#define LEFT_BOTTOM				0
#define LEFT_TOP				1
#define RIGHT_TOP				2
#define RIGHT_BOTTOM			3

#define TRANSFORM_TRANSLATE		0
#define TRANSFORM_ROTATE		1
#define TRANSFORM_SCALE			2

#define TRANSFORM_MODE_FRAME		0
#define TRANSFORM_MODE_DIRECT		1

#define LINE_MODE_DEFAULT		0
#define LINE_MODE_FADE_OUT		1

#define RING_MODE_CENTER		0
#define RING_MODE_INSIDE		1
#define RING_MODE_OUTSIDE		2

#define FRUSTUM_FOV					(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 100.0 : 60.0


typedef struct {
	float top;
	float right;
	float bottom;
	float left;
} ScreenBorders;

static inline bool isVisible(float x,float y, ScreenBorders *borders) {
	return (
			x > borders->left && 
			x < borders->right && 
			y > borders->bottom && 
			y < borders->top
	);
}

static inline ScreenBorders ScreenBordersMake(float cameraX,float cameraY, CGSize screenSize, float gutter) {
	ScreenBorders borders;
	borders.left	=  -cameraX - (screenSize.width * .5) - (gutter * .5);
	borders.right	=  borders.left + screenSize.width + gutter;
	borders.bottom	=  -cameraY - (screenSize.height * .5) - (gutter * .5);;
	borders.top		=  borders.bottom + screenSize.height + gutter;
	return borders;
}

typedef struct {
	GLfloat	x;
	GLfloat	y;
} Transform2D;

static inline Transform2D Transform2DMake(GLfloat x,GLfloat y) {
	Transform2D t;
	t.x = x;
	t.y = y;
	return t;
}

typedef struct {
	GLfloat	x;
	GLfloat	y;
	GLfloat	z;
} Transform3D;

static inline Transform3D Transform3DMake(GLfloat x,GLfloat y,GLfloat z) {
	Transform3D t;
	t.x = x;
	t.y = y;
	t.z = z;
	return t;
}

typedef struct {
	GLfloat	u;
	GLfloat	v;
} UV;

static inline UV UVMake(GLfloat u,GLfloat v) {
	UV uv;
	uv.u = u;
	uv.v = v;
	return uv;
}

typedef struct {
	GLfloat u;
	GLfloat v;
	GLfloat width;
	GLfloat height;
} UVMap;

static inline UVMap UVMapMake(uint u,uint v, uint w, uint h) {
	UVMap map;
	map.u = u / (float)TEXTURE_ATLAS_DEFAULT_SIZE;
	map.v = v / (float)TEXTURE_ATLAS_DEFAULT_SIZE;
	map.width = w / (float)TEXTURE_ATLAS_DEFAULT_SIZE;
	map.height = h / (float)TEXTURE_ATLAS_DEFAULT_SIZE;
	return map;
}

static inline UVMap UVMapMakeSize(uint u,uint v,uint w,uint h,uint size) {
	UVMap map;
	map.u = u / (float)size;
	map.v = v / (float)size;
	map.width = w / (float)size;
	map.height = h / (float)size;
	return map;
}


typedef struct {
	Transform3D transform;
	float amount;
	uint type;
} Transform;

static inline Transform TransformMake(uint type,float amount,Transform3D transform) {
	Transform t;
	t.transform = transform;
	t.amount = amount;
	t.type = type;
	return t;
}

typedef struct {
	Transform *transforms;
	uint transformCount;
	uint transformSpace;
} TransformSet;

static inline TransformSet TransformSetMake() {
	TransformSet s;
	s.transforms = NULL;
	s.transformCount = 0;
	s.transformSpace = 0;
	return s;
}

static inline uint addTransformToTransformSet(Transform t,TransformSet *s) {
	
	if(s->transformCount == s->transformSpace) {
		
		if (s->transformSpace == 0) {
			s->transformSpace = 4;
		}
		else {
			s->transformSpace *= 2;
		}
		
		void *_tmp = realloc(s->transforms, (s->transformSpace * sizeof(Transform)));
		
		if (!_tmp) {
			return -1;
		}
		
		s->transforms = (Transform*)_tmp;
	}
	
	s->transforms[s->transformCount] = t;
	s->transformCount++;
	
	return s->transformCount;
}



typedef struct {
	GLubyte r;
	GLubyte g;
	GLubyte b;
	float a;
} Color;

static inline Color ColorMake(GLubyte r,GLubyte g,GLubyte b,float a) {
	Color c;
	c.r = r;
	c.g = g;
	c.b = b;
	c.a = a;
	return c;
}

static inline Color ColorMakeByOpacity(float a) {
	return ColorMake(255,255,255,a);
}

static inline Color ColorMakeFast() {
	return ColorMakeByOpacity(1.0);
}

static inline void ColorReset(Color *color) {
	color->r = 255;
	color->g = 255;
	color->b = 255;
	color->a = 1.0;
}

static inline void ColorResetAlpha(Color *color,float a) {
	color->r = 255;
	color->g = 255;
	color->b = 255;
	color->a = a;
}

static inline void ColorApply(Color *color,GLubyte r,GLubyte g,GLubyte b,float a) {
	color->r = r;
	color->g = g;
	color->b = b;
	color->a = a;
}

typedef struct {
	GLubyte	r;
	GLubyte	g;
	GLubyte	b;
	GLubyte a;
} ColorRaw;

static inline ColorRaw ColorRawMake(GLubyte r,GLubyte g,GLubyte b,GLubyte a) {
	ColorRaw c;
	c.r = r;
	c.g = g;
	c.b = b;
	c.a = a;
	return c;
}

static inline ColorRaw ColorRawMakeFast() {
	return ColorRawMake(255, 255, 255, 255);
}

static inline ColorRaw ColorRawMakeByColor(Color *color) {
	return ColorRawMake(color->r * color->a, color->g * color->a, color->b * color->a, color->a * 255);
}

typedef struct {
	Transform3D		coordinate;
	UV				uv;
	ColorRaw			color;
	GLfloat			padding[2];
} VertexData;

static inline VertexData VertexDataMake(GLfloat x,GLfloat y,GLfloat z,GLfloat u,GLfloat v,ColorRaw color) {
	VertexData data;
	data.coordinate = Transform3DMake(x, y, z);
	data.uv = UVMake(u, v);
	data.color = color;
	return data;
}

typedef struct {
	GLfloat x;
	GLfloat y;
	GLfloat z;
	GLfloat radius;
	GLfloat width;
	Color color;
	UVMap uv;
	uint segments;
} RingTemplate;

static inline RingTemplate RingTemplateMake(GLfloat x,GLfloat y,GLfloat z,GLfloat radius,GLfloat width,Color color,UVMap uv,uint segments) {
	RingTemplate t;
	t.x = x;
	t.y = y;
	t.z = z;
	t.radius = radius;
	t.width = width;
	t.color = color;
	t.uv = uv;
	t.segments = segments;
	return t;
}

static inline RingTemplate RingTemplateMakeEmpty() {
	return RingTemplateMake(0, 0, 0, 10, 5, ColorMakeFast(), UVMapMake(0, 0, 0, 0), 8);
}




typedef struct {
	Transform2D		coordinate;
	ColorRaw		color;
	GLfloat			size;
} ParticleData;

static inline ParticleData ParticleDataMake(GLfloat x,GLfloat y,GLfloat size,ColorRaw color) {
	ParticleData data;
	data.coordinate = Transform2DMake(x, y);
	data.color = color;
	data.size = size;
	return data;
}

typedef struct {
	GLfloat x;
	GLfloat y;
	GLfloat size;
	Color color;
} ParticleTemplate;

static inline ParticleTemplate ParticleTemplateMake(GLfloat x,GLfloat y,GLfloat size, Color color) {
	ParticleTemplate t;
	t.x = x;
	t.y = y;
	t.size = size;
	t.color = color;
	return t;	
} 

typedef struct {
	GLfloat x;
	GLfloat y;
	GLfloat z;
	GLfloat width;
	GLfloat height;
	GLfloat rotation;
	Color color;
	UVMap uv;
} QuadTemplate;

static inline QuadTemplate QuadTemplateMake(GLfloat x,GLfloat y,GLfloat z,GLfloat width,GLfloat height,Color color,UVMap uv) {
	QuadTemplate t;
	t.x = x;
	t.y = y;
	t.z = z;
	t.width = width;
	t.height = height;
	t.color = color;
	t.rotation = 0;
	t.uv = uv;
	return t;
}

static inline QuadTemplate QuadTemplateMakeFast(GLfloat x,GLfloat y,GLfloat size,float opacity,UVMap uv) {
	return QuadTemplateMake(x, y, 0.0,size, size, ColorMakeByOpacity(opacity), uv);
}

static inline QuadTemplate QuadTemplateMakeEmpty() {
	return QuadTemplateMake(0, 0, 0, 0, 0, ColorMakeFast(), UVMapMake(0, 0, 0, 0));
}

typedef struct {
	Transform3D* coordinates;
	uint coordinateSpace;
	uint coordinateCount;
	GLfloat width;
	UVMap uv;
	GLshort mode;
	Color color;
} LineTemplate;

static inline LineTemplate LineTemplateMake(GLfloat width,UVMap uv) {
	LineTemplate t;
	t.coordinates = NULL;
	t.coordinateCount = 0;
	t.coordinateSpace = 0;
	t.width = width;
	t.uv = uv;
	t.color = ColorMakeFast();
	t.mode = LINE_MODE_DEFAULT;
	return t;
}

static inline uint addCoordinateToLine(GLfloat x,GLfloat y, GLfloat z, LineTemplate *l) {
	
	if(l->coordinateCount == l->coordinateSpace) {
		
		if (l->coordinateSpace == 0) {
			l->coordinateSpace = 64;
		}
		else {
			l->coordinateSpace *= 2;
		}
		
		void *_tmp = realloc(l->coordinates, (l->coordinateSpace * sizeof(Transform3D)));
		
		if (!_tmp) {
			return -1;
		}
		
		l->coordinates = (Transform3D*)_tmp;
	}
	
	l->coordinates[l->coordinateCount] = Transform3DMake(x, y, z);
	l->coordinateCount++;
	
	return l->coordinateCount;
}



typedef struct {
	QuadTemplate *quads;
	uint quadSpace;
	uint quadCount;
} QuadBuffer;

static inline QuadBuffer QuadBufferMake() {
	QuadBuffer b;
	b.quads = NULL;
	b.quadSpace = 0;
	b.quadCount = 0;
	return b;
}

static inline uint addQuadToQuadBuffer(QuadTemplate q,QuadBuffer *b) {
	
	// check if array is full
	if(b->quadCount == b->quadSpace) {
		
		if (b->quadSpace == 0) {
			b->quadSpace = 64;
		}
		else {
			b->quadSpace *= 2;
		}
		
		void *_tmp = realloc(b->quads, (b->quadSpace * sizeof(QuadTemplate)));
		
		if (!_tmp) {
			return -1;
		}
		
		b->quads = (QuadTemplate*)_tmp;
	}
	
	// add to array
	b->quads[b->quadCount] = q;
	b->quadCount++;
	
	return b->quadCount;
}


typedef struct {
	VertexData *vertexes;
	GLushort *indexes;
	uint vertexSpace;
	uint vertexCount;
	uint indexSpace;
	uint indexCount;
	TransformSet transforms;
	uint transformMode;
} VertexBuffer;

static inline VertexBuffer VertexBufferMake() {
	VertexBuffer b;
	b.vertexes = NULL;
	b.indexes = NULL;
	b.vertexCount = 0;
	b.vertexSpace = 0;
	b.indexCount = 0;
	b.indexSpace = 0;
	b.transforms = TransformSetMake();
	b.transformMode = TRANSFORM_MODE_FRAME;
	return b;
}

static inline uint addVertexToBuffer(VertexData v,VertexBuffer *b) {
	
	// check if array is full
	if(b->vertexCount == b->vertexSpace) {
		
		if (b->vertexSpace == 0) {
			b->vertexSpace = 64;
		}
		else {
			b->vertexSpace *= 2;
		}
		
		void *_tmp = realloc(b->vertexes, (b->vertexSpace * sizeof(VertexData)));
		
		if (!_tmp) {
			return -1;
		}
		
		b->vertexes = (VertexData*)_tmp;
	}
	
	// add to array
	b->vertexes[b->vertexCount] = v;
	b->vertexCount++;
	
	return b->vertexCount;
}

static inline uint addIndexToBuffer(uint i,VertexBuffer *b) {
	
	if(b->indexCount == b->indexSpace) { 
		
		if (b->indexSpace == 0) {
			b->indexSpace = 96;
		}
		else {
			b->indexSpace *= 2;
		}
		
		void *_tmp = realloc(b->indexes, (b->indexSpace * sizeof(GLushort)));
		
		if (!_tmp) {
			return -1;
		}
		
		b->indexes = (GLushort*)_tmp;
	}
	
	b->indexes[b->indexCount] = i;
	b->indexCount++;
	
	return b->indexCount;
	
}

typedef	 struct {
	float width;
	float height;
} FrameSize;

static inline FrameSize FrameSizeMake(GLfloat width, GLfloat height) {
	FrameSize s;
	s.width = width;
	s.height = height;
	return s;
}

typedef struct {
	GLfloat near;
	GLfloat far;
	GLfloat xmin;
	GLfloat xmax;
	GLfloat ymin;
	GLfloat ymax;
} Frustum;

static inline Frustum FrustumMake(GLfloat fov, GLfloat near, GLfloat far, GLfloat aspectRatio) {
	Frustum f;
	f.near = near;
	f.far = far;
	f.ymax = near * tan(fov * TRIG_PI_M_1_360);
	f.ymin = -f.ymax;
	f.xmin = f.ymin * aspectRatio;
	f.xmax = f.ymax * aspectRatio;
	return f;
}

typedef	 struct {
	GLuint reference;
	FrameSize size;
	FrameSize half;
	float clearColor[4];
	Frustum frustum;
} FrameBuffer;

static inline FrameBuffer FrameBufferMake(uint reference,GLfloat width, GLfloat height) {
	FrameBuffer f;
	f.reference = reference;
	f.size = FrameSizeMake(width,height);
	f.half = FrameSizeMake(width*.5, height*.5);
	f.clearColor[0] = 0;
	f.clearColor[1] = 0;
	f.clearColor[2] = 0;
	f.clearColor[3] = 0;
	f.frustum = FrustumMake(FRUSTUM_FOV, 0.1f, 3000.0f, width/height);
	return f;
}

