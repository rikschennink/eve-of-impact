//
//  RenderEngine.m
//  Eve of Impact
//
//  Created by Rik Schennink on 2/25/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//


#import "RenderEngine.h"
#import "Visual.h"
#import "Camera.h"
#import "Texture.h"
#import "ResourceManager.h"
#import "MathAdditional.h"
#import "Common.h"
#import "Vector.h"

@interface RenderEngine (private)

-(void)perspective:(double)fovy :(double)aspect :(double)zNear :(double)zFar;

@end

@implementation RenderEngine

static RenderEngine* _singleton = nil;

+(RenderEngine*)singleton {
	
	@synchronized([RenderEngine class]) {
		
		if (!_singleton) {
			
			[[self alloc]init];
			
		}
		
		return _singleton;
	}
	
	return nil;
}

+(id)alloc {
	
	@synchronized([RenderEngine class]) {
		
		NSAssert(_singleton == nil, @"Attempted to allocate a second instance of RenderEngine singleton.");
		_singleton = [super alloc];
		return _singleton;
	}
	
	return nil;
}

-(id)initWithContext:(EAGLContext*)context andLayer:(CAEAGLLayer*)layer {
	
	if (self = [super init]) {
		
		// set props
		activeTexture = 0;
		screenOrientationApplied = NO;
		vertexDataStride = sizeof(VertexData);
		frameOffset = VectorMake(0,0);
		
		// get screen dimensions
		screenBounds = [[UIScreen mainScreen] bounds];
		screenSize = screenBounds.size;
		
		screenDensity = [UIScreen mainScreen].scale;
		screenQuarter = CGSizeMake(screenSize.width*.5,screenSize.height*.5);
		
		
		
		// set context and layer references
		eaglContext = context;
		eaglLayer = layer;
		
		// set current context 
		[EAGLContext setCurrentContext:eaglContext];
		
		// OpenGL initialization
		glGenFramebuffersOES(1, &framebuffer);
		glGenRenderbuffersOES(1, &renderbuffer);
		glBindFramebufferOES(GL_FRAMEBUFFER_OES, framebuffer);
		glBindRenderbufferOES(GL_RENDERBUFFER_OES, renderbuffer);
		[eaglContext renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:eaglLayer];
		glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, renderbuffer);
		
		// define default frame buffer and than activate it
		FrameBuffer defaultFrameBuffer = FrameBufferMake(framebuffer,screenSize.width * screenDensity, screenSize.height * screenDensity);
		//FrameBuffer defaultFrameBuffer = FrameBufferMake(framebuffer,screenSize.width, screenSize.height);
		defaultFrameBuffer.clearColor[0] = 5.0 / 255.0;
		defaultFrameBuffer.clearColor[1] = 9.0 / 255.0;
		defaultFrameBuffer.clearColor[2] = 23.0 / 255.0;
		defaultFrameBuffer.clearColor[3] = 1.0;
		
		[self addFrameBuffer:defaultFrameBuffer at:0];
		activeFBO = &frameBuffers[0];
		
		// set initial modes
		[self resetBlendMode];
		[self disableCulling];
		glDepthMask(GL_FALSE);
	}
	
	return self;
}


-(void)set3DProjection {
	
	glEnable(GL_DEPTH_TEST);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	
	glFrustumf(activeFBO->frustum.xmin, activeFBO->frustum.xmax, activeFBO->frustum.ymin, activeFBO->frustum.ymax, activeFBO->frustum.near, activeFBO->frustum.far);
	/*
	if (screenOrientation == UIDeviceOrientationLandscapeLeft ||
		screenOrientation == UIDeviceOrientationLandscapeRight) {
		glRotatef(screenOrientation == UIDeviceOrientationLandscapeLeft ? -90.0 : 90.0, 0.0, 0.0, 1.0);
	}
	 */
	//NSLog(@"frustum: %f,%f",activeFBO->size.width,activeFBO->size.height);
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
}

-(void)set2DProjection {
	
	glDisable(GL_DEPTH_TEST);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	/*
	if (screenOrientation == UIDeviceOrientationLandscapeLeft ||
		screenOrientation == UIDeviceOrientationLandscapeRight) {
		glRotatef(screenOrientation == UIDeviceOrientationLandscapeLeft ? -90.0 : 90.0, 0.0, 0.0, 1.0);
		// set landscape perspective
		glOrthof(-activeFBO->half.height, activeFBO->half.height, -activeFBO->half.width, activeFBO->half.width, -activeFBO->half.width, activeFBO->half.width);
	}
	else {*/
		// set portrait persepective
	
	if (screenDensity > 1) {
		glOrthof(-activeFBO->half.width * .5, activeFBO->half.width * .5, 
				 -activeFBO->half.height * .5, activeFBO->half.height * .5, 
				 -activeFBO->half.width * .5, activeFBO->half.width * .5);
		
	}
	else {
		glOrthof(-activeFBO->half.width, activeFBO->half.width, 
				 -activeFBO->half.height, activeFBO->half.height, 
				 -activeFBO->half.width, activeFBO->half.width);
	}
	
	//}
	
	//NSLog(@"ortho: %f,%f",activeFBO->size.width,activeFBO->size.height);
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
}

-(void)addTexture:(uint)texture at:(uint)index {
	textures[index] = texture;
}

-(void)setActiveTexture:(uint)index {
	if (textures[index]!=activeTexture) {
		activeTexture = textures[index];
		glBindTexture(GL_TEXTURE_2D,activeTexture);
	}
}

-(void)addFrameBuffer:(FrameBuffer)buffer at:(uint)index {
	frameBuffers[index] = buffer;
}

-(void)setActiveFrameBuffer:(uint)index {
	
	// update active FBO
	activeFBO = &frameBuffers[index];
	
	// set framebuffer
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, activeFBO->reference);
	
	// set viewport
	glViewport(0, 0, activeFBO->size.width, activeFBO->size.height);
	
	// enable textures and set environment
	glEnable(GL_TEXTURE_2D);
	glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
	
	// enable default features
	glEnable(GL_BLEND);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
}

-(void)clearActiveFrameBuffer {
	glClearColor(activeFBO->clearColor[0], activeFBO->clearColor[1], activeFBO->clearColor[2], activeFBO->clearColor[3]);
	glClear(GL_COLOR_BUFFER_BIT);
}

-(void)addVertexBuffer:(VertexBuffer)buffer at:(uint)index {
	vertexBuffers[index] = buffer;
}

-(void)setActiveVertexBuffer:(uint)index {
	activeVBO = &vertexBuffers[index];
}

-(void)setActiveBlendMode:(uint)blendMode {
	activeBlendMode = blendMode;
}

-(void)resetBlendMode {
	activeBlendMode = BLEND_MODE_DEFAULT;
}

-(void)enableCulling {
	culling = true;
}

-(void)disableCulling {
	culling = false;
}

-(void)setTransformModeOfActiveVertexBuffer:(uint)mode {
	activeVBO->transformMode = mode;
}

-(void)addTransformToActiveVertexBuffer:(Transform)transform {
	addTransformToTransformSet(transform, &activeVBO->transforms);
}

-(void)resetTransformsOfActiveVertexBuffer {
	activeVBO->transforms.transformCount = 0;
}

-(void)resetTransformsModeOfActiveVertexBuffer {
	activeVBO->transformMode = TRANSFORM_MODE_FRAME;
}

-(void)renderActiveVertexBuffer {
	
	if (activeVBO->transformMode == TRANSFORM_MODE_FRAME && 
		activeVBO->transforms.transformCount > 0) {
		
		for (uint i =0; i<activeVBO->transforms.transformCount; i++) {
			Transform *t = &activeVBO->transforms.transforms[i];
			switch (t->type) {
				case TRANSFORM_TRANSLATE: glTranslatef(t->transform.x,t->transform.y,t->transform.z);
					break;
				case TRANSFORM_ROTATE: glRotatef(t->amount,t->transform.x,t->transform.y,t->transform.z);
					break;
				case TRANSFORM_SCALE: glScalef(t->transform.x,t->transform.y,t->transform.z);
					break;
				default:
					break;
			}
		}
	}
	
	if (culling) {
		glEnable(GL_CULL_FACE);
	}
	
	switch (activeBlendMode) {
		case BLEND_MODE_DEFAULT:
			glBlendFunc(GL_ONE,GL_ONE_MINUS_SRC_ALPHA);
			break;
		case BLEND_MODE_MULTIPLY:
			glBlendFunc(GL_DST_COLOR, GL_ONE_MINUS_SRC_ALPHA);
			break;
		case BLEND_MODE_SCREEN:
			glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_COLOR);
			break;
		case BLEND_MODE_DODGE:
			glBlendFunc(GL_DST_COLOR, GL_ONE);
			break;
		case BLEND_MODE_MASK:
			glBlendFunc(GL_DST_ALPHA,GL_ZERO);
			break;
		case BLEND_MODE_MASK_ALT:
			glBlendFunc(GL_ZERO, GL_ONE_MINUS_SRC_ALPHA);
			break;
		default:
			glBlendFunc(GL_ONE,GL_ONE_MINUS_SRC_ALPHA);
			break;
	}
	
	glVertexPointer(3, GL_FLOAT, vertexDataStride, &activeVBO->vertexes[0].coordinate);
	glColorPointer(4, GL_UNSIGNED_BYTE, vertexDataStride, &activeVBO->vertexes[0].color);
	glTexCoordPointer(2, GL_FLOAT, vertexDataStride, &activeVBO->vertexes[0].uv);
	glDrawElements(GL_TRIANGLES, activeVBO->indexCount, GL_UNSIGNED_SHORT, activeVBO->indexes);
	
	if (culling) {
		glDisable(GL_CULL_FACE);
	}
	
	if (activeVBO->transforms.transformCount > 0) {
		glLoadIdentity();
	}
}

-(void)flushActiveVertexBuffer {
	activeVBO->vertexCount = 0;
	activeVBO->indexCount = 0;
}

-(void)addIndex:(GLushort)index {
	addIndexToBuffer(index,activeVBO);
}

-(void)addVertex:(VertexData)vertex {
	addVertexToBuffer(vertex,activeVBO);
}


-(void)addQuad:(QuadTemplate*)quad {
	
	// set vertex data object
	VertexData vertex;
	
	// setup indexes for corners
	addIndexToBuffer(activeVBO->vertexCount,activeVBO);
	addIndexToBuffer(activeVBO->vertexCount+1,activeVBO);
	addIndexToBuffer(activeVBO->vertexCount+2,activeVBO);
	addIndexToBuffer(activeVBO->vertexCount,activeVBO);
	addIndexToBuffer(activeVBO->vertexCount+2,activeVBO);
	addIndexToBuffer(activeVBO->vertexCount+3,activeVBO);
	
	// get raw color
	vertex.color.r = quad->color.r * quad->color.a;
	vertex.color.g = quad->color.g * quad->color.a;
	vertex.color.b = quad->color.b * quad->color.a;
	vertex.color.a = quad->color.a * 255;
	
	vertex.coordinate.x = quad->x;
	vertex.coordinate.y = quad->y;
	vertex.coordinate.z = quad->z;
	
	// apply possible cpu transforms to quad 
	//#WARNING, NOW ASSUMES IT'S OFFSET TRANSFORMS
	if (activeVBO->transformMode == TRANSFORM_MODE_DIRECT && activeVBO->transforms.transformCount > 0) {
		Transform *t = &activeVBO->transforms.transforms[0];
		vertex.coordinate.x += t->transform.x;
		vertex.coordinate.y += t->transform.y;
		vertex.coordinate.z += t->transform.z;
	}
	
	// left bottom vertex
	vertex.uv.u = quad->uv.u;
	vertex.uv.v = quad->uv.v;
	addVertexToBuffer(vertex,activeVBO);
	
	// left top vertex
	vertex.coordinate.y = vertex.coordinate.y + quad->height;
	vertex.uv.v = quad->uv.v + quad->uv.height;
	addVertexToBuffer(vertex,activeVBO);
	
	// right top
	vertex.coordinate.x = vertex.coordinate.x + quad->width;
	vertex.uv.u = quad->uv.u + quad->uv.width;
	addVertexToBuffer(vertex,activeVBO);
	
	// right bottom
	vertex.coordinate.y = vertex.coordinate.y - quad->height;
	vertex.uv.v = quad->uv.v;
	addVertexToBuffer(vertex,activeVBO);
}


-(void)addCenteredQuad:(QuadTemplate*)quad {
	
	// declare data holders
	float x,y,z,xl,yt,xr,yb;
	
	// get reference to buffer in array
	VertexData vertex;
	
	// setup indexes for corners
	addIndexToBuffer(activeVBO->vertexCount,activeVBO);
	addIndexToBuffer(activeVBO->vertexCount+1,activeVBO);
	addIndexToBuffer(activeVBO->vertexCount+2,activeVBO);
	addIndexToBuffer(activeVBO->vertexCount,activeVBO);
	addIndexToBuffer(activeVBO->vertexCount+2,activeVBO);
	addIndexToBuffer(activeVBO->vertexCount+3,activeVBO);
	
	// get raw color
	vertex.color.r = quad->color.r * quad->color.a;
	vertex.color.g = quad->color.g * quad->color.a;
	vertex.color.b = quad->color.b * quad->color.a;
	vertex.color.a = quad->color.a * 255;
	
	x = quad->x;
	y = quad->y;
	z = quad->z;
	
	// apply possible cpu transforms to quad 
	//#WARNING, NOW ASSUMES IT'S OFFSET TRANSFORMS
	if (activeVBO->transformMode == TRANSFORM_MODE_DIRECT && activeVBO->transforms.transformCount > 0) {
		Transform *t = &activeVBO->transforms.transforms[0];
		x += t->transform.x;
		y += t->transform.y;
		z += t->transform.z;
	}
	
	// calculate corner vertexes and add them to buffer
	xr = quad->width*.5;
	xl = -xr;
	
	yt = quad->height*.5;
	yb = -yt;
	
	// left bottom vertex
	vertex.coordinate.x = x + xl;
	vertex.coordinate.y = y + yb;
	vertex.coordinate.z = z;
	vertex.uv.u = quad->uv.u;
	vertex.uv.v = quad->uv.v;
	addVertexToBuffer(vertex,activeVBO);
	
	// left top vertex
	vertex.coordinate.y = y + yt;
	vertex.uv.v = quad->uv.v + quad->uv.height;
	addVertexToBuffer(vertex,activeVBO);
	
	// right top vertex
	vertex.coordinate.x = x + xr;
	vertex.uv.u = quad->uv.u + quad->uv.width;
	addVertexToBuffer(vertex,activeVBO);
	
	// right bottom
	vertex.coordinate.y = y + yb;
	vertex.uv.v = quad->uv.v;
	addVertexToBuffer(vertex,activeVBO);
}


-(void)addQuad:(QuadTemplate*)quad andRotateBy:(float)rotation {
	
	// get reference to buffer in array
	VertexData vertex;
	
	// setup indexes for corners
	addIndexToBuffer(activeVBO->vertexCount,activeVBO);
	addIndexToBuffer(activeVBO->vertexCount+1,activeVBO);
	addIndexToBuffer(activeVBO->vertexCount+2,activeVBO);
	addIndexToBuffer(activeVBO->vertexCount,activeVBO);
	addIndexToBuffer(activeVBO->vertexCount+2,activeVBO);
	addIndexToBuffer(activeVBO->vertexCount+3,activeVBO);
	
	// get raw color
	vertex.color.r = quad->color.r * quad->color.a;
	vertex.color.g = quad->color.g * quad->color.a;
	vertex.color.b = quad->color.b * quad->color.a;
	vertex.color.a = quad->color.a * 255;
	
	// declare data holder, calculate corner vertexes and add them to buffer
	float x,y,z,tx,ty,c,s,xl,yt,xr,yb;
	
	x = quad->x;
	y = quad->y;
	z = quad->z;
	
	// apply possible cpu transforms to quad 
	//#WARNING, NOW ASSUMES IT'S OFFSET TRANSFORMS
	if (activeVBO->transformMode == TRANSFORM_MODE_DIRECT && activeVBO->transforms.transformCount > 0) {
		Transform *t = &activeVBO->transforms.transforms[0];
		x += t->transform.x;
		y += t->transform.y;
		z += t->transform.z;
	}
	
	xr = quad->width*.5;
	xl = -xr;
	
	yt = quad->height*.5;
	yb = -yt;
	
	c = cosHash(rotation);
	s = sinHash(rotation);

	// left bottom vertex
	tx = xl * c - yb * s; 
	ty = yb * c + xl * s;
	
	vertex.coordinate.x = x + tx;
	vertex.coordinate.y = y + ty;
	vertex.coordinate.z = z;
	vertex.uv.u = quad->uv.u;
	vertex.uv.v = quad->uv.v;
	addVertexToBuffer(vertex,activeVBO);
	
	// left top vertex
	tx = xl * c - yt * s; 
	ty = yt * c + xl * s;
	
	vertex.coordinate.x = x + tx;
	vertex.coordinate.y = y + ty;
	vertex.uv.v = quad->uv.v + quad->uv.height;
	addVertexToBuffer(vertex,activeVBO);
	
	// right top vertex
	tx = xr * c - yt * s;
	ty = yt * c + xr * s;
	
	vertex.coordinate.x = x + tx;
	vertex.coordinate.y = y + ty;
	vertex.uv.u = quad->uv.u + quad->uv.width;
	addVertexToBuffer(vertex,activeVBO);
	
	// right bottom vertex
	tx = xr * c - yb * s; 
	ty = yb * c + xr * s;
	
	vertex.coordinate.x = x + tx;
	vertex.coordinate.y = y + ty;
	vertex.uv.v = quad->uv.v;
	addVertexToBuffer(vertex,activeVBO);
}


-(void)addRing:(RingTemplate*)ring withMode:(uint)mode {
	
	VertexData vertex;
	
	float rx,ry,c,s,theta,vStep,t,xi,yi,xo,yo,u,v,dr,ri,ro,d;
	
	rx = ring->x;
	ry = ring->y;
	
	// apply possible cpu transforms to quad 
	//#WARNING, NOW ASSUMES IT'S OFFSET TRANSFORMS
	if (activeVBO->transformMode == TRANSFORM_MODE_DIRECT && activeVBO->transforms.transformCount > 0) {
		Transform *t = &activeVBO->transforms.transforms[0];
		rx += t->transform.x;
		ry += t->transform.y;
	}
	
	// set z coordinate
	vertex.coordinate.z = 0;
	
	// get raw color
	vertex.color.r = ring->color.r * ring->color.a;
	vertex.color.g = ring->color.g * ring->color.a;
	vertex.color.b = ring->color.b * ring->color.a;
	vertex.color.a = ring->color.a * 255;
	
	theta = TRIG_PI_M_2 / ring->segments;
	vStep = ring->uv.height / ring->segments;
	
	c = cosf(theta);
	s = sinf(theta);
	
	v = ring->uv.v;
	u = ring->uv.u + ring->uv.width;
	yi = 0;
	yo = 0;
	xi = ring->radius;
	xo = ring->radius;
	dr = ring->radius * 2.0;
	ri = .5;
	ro = .5;
	
	if (mode == RING_MODE_CENTER) {
		if (ring->width > dr) {
			d = ring->width - ring->radius;
			ri = ring->radius / ring->width;
			ro = d / ring->width;
		}
		xi -= ring->width * ri;
		xo += ring->width * ro;
	}
	else if (mode == RING_MODE_INSIDE) {
		if (ring->width > ring->radius) {
			ring->width = ring->radius;
		}
		xi -= ring->width;
	}
	else if (mode == RING_MODE_OUTSIDE) {
		xo += ring->width;
	}
	
	for (uint i = 0; i<=ring->segments; i++) {
		
		if (i<ring->segments) {
			
			addIndexToBuffer(activeVBO->vertexCount,activeVBO);
			addIndexToBuffer(activeVBO->vertexCount+1,activeVBO);
			addIndexToBuffer(activeVBO->vertexCount+2,activeVBO);
			addIndexToBuffer(activeVBO->vertexCount+1,activeVBO);
			addIndexToBuffer(activeVBO->vertexCount+3,activeVBO);
			addIndexToBuffer(activeVBO->vertexCount+2,activeVBO);
			
		}
		
		vertex.coordinate.x = rx + xi;
		vertex.coordinate.y = ry + yi;
		vertex.uv.u = ring->uv.u;
		vertex.uv.v = v;
		addVertexToBuffer(vertex,activeVBO);
		
		vertex.coordinate.x = rx + xo;
		vertex.coordinate.y = ry + yo;
		vertex.uv.u = u;
		addVertexToBuffer(vertex,activeVBO);
		
		// update uvmap offset
		v += vStep;
		
		// calculate inner vertex
		t = xi;
		xi = c * xi - s * yi;
		yi = s * t + c * yi;
		
		// calculate outer vertex
		t = xo;
		xo = c * xo - s * yo;
		yo = s * t + c * yo;
	}	
}

-(void)addRing:(RingTemplate*)ring {
	
	[self addRing:ring withMode:RING_MODE_CENTER];
	
}

-(void)addLine:(LineTemplate*)line {
	
	if (line->coordinateCount<=1) {
		return;
	}
	
	VertexData v0,v1,v2,v3;
	
	v0.coordinate.z = 0;
	v1.coordinate.z = 0;
	v2.coordinate.z = 0;
	v3.coordinate.z = 0;
	
	
	Transform3D *begin, *end;
	
	float ox,oy,tx,ty,step;
	float distance;
	float defaultAlpha = line->color.a;
	float currentAlpha = line->mode == LINE_MODE_FADE_OUT ? 0.0 : defaultAlpha;
	float previousAlpha = currentAlpha;
	
	ColorRaw color;
	color.r = line->color.r * line->color.a;
	color.g = line->color.g * line->color.a;
	color.b = line->color.b * line->color.a;
	color.a = line->color.a * 255;
	
	
	ox = 0.0;
	oy = 0.0;
	
	// apply possible cpu transforms to quad 
	//#WARNING, NOW ASSUMES IT'S OFFSET TRANSFORMS
	if (activeVBO->transformMode == TRANSFORM_MODE_DIRECT && activeVBO->transforms.transformCount > 0) {
		Transform *t = &activeVBO->transforms.transforms[0];
		ox = t->transform.x;
		oy = t->transform.y;
	}
	
	if (line->mode == LINE_MODE_FADE_OUT) {
		step = defaultAlpha / line->coordinateCount;
	}
	
	for (uint i=line->coordinateCount-1; i>0; i--) {
		
		if (line->mode == LINE_MODE_FADE_OUT) {
			previousAlpha = currentAlpha;
			currentAlpha = currentAlpha + step < defaultAlpha ? currentAlpha + step : defaultAlpha;
		}
		
		begin = &line->coordinates[i];
		end = &line->coordinates[i-1];
		
		tx = end->x - begin->x;
		ty = end->y - begin->y;
		distance = sqrtf(tx * tx + ty * ty);
		tx/=distance;
		ty/=distance;
		tx*=line->width;
		ty*=line->width;
		
		addIndexToBuffer(activeVBO->vertexCount,activeVBO);
		addIndexToBuffer(activeVBO->vertexCount+1,activeVBO);
		addIndexToBuffer(activeVBO->vertexCount+2,activeVBO);
		addIndexToBuffer(activeVBO->vertexCount+1,activeVBO);
		addIndexToBuffer(activeVBO->vertexCount+3,activeVBO);
		addIndexToBuffer(activeVBO->vertexCount+2,activeVBO);
		
		line->color.a = previousAlpha < currentAlpha ? previousAlpha : currentAlpha;
		color.r = line->color.r * line->color.a;
		color.g = line->color.g * line->color.a;
		color.b = line->color.b * line->color.a;
		color.a = line->color.a * 255;
		
		if (i==line->coordinateCount-1) {
			
			
			v0.coordinate.x = ox + begin->x + ty;
			v0.coordinate.y = oy + begin->y - tx;
			v0.uv.u = line->uv.u;
			v0.uv.v = line->uv.v;
			v0.color = color;
			
			v1.coordinate.x = ox + begin->x - ty;
			v1.coordinate.y = oy + begin->y + tx;
			v1.uv.u = line->uv.u;
			v1.uv.v = line->uv.v + line->uv.height;
			v1.color = color;
			
			addVertexToBuffer(v0,activeVBO);
			addVertexToBuffer(v1,activeVBO);
			
		}
		else {
			
			v0.coordinate.x = v2.coordinate.x;
			v0.coordinate.y = v2.coordinate.y;
			v0.uv.u = line->uv.u;
			v0.uv.v = line->uv.v;
			v0.color = color;
			
			v1.coordinate.x = v3.coordinate.x;
			v1.coordinate.y = v3.coordinate.y;
			v1.uv.u = line->uv.u;
			v1.uv.v = line->uv.v + line->uv.height;
			v1.color = color;
			
			addVertexToBuffer(v0,activeVBO);
			addVertexToBuffer(v1,activeVBO);
			
		}
		
		line->color.a = currentAlpha;
		color.r = line->color.r * line->color.a;
		color.g = line->color.g * line->color.a;
		color.b = line->color.b * line->color.a;
		color.a = line->color.a * 255;
		
		
		v2.coordinate.x = ox + end->x + ty;
		v2.coordinate.y = oy + end->y - tx;
		v2.uv.u = line->uv.u + line->uv.width;
		v2.uv.v = line->uv.v;
		v2.color = color;
		
		v3.coordinate.x = ox + end->x - ty;
		v3.coordinate.y = oy + end->y + tx;
		v3.uv.u = line->uv.u + line->uv.width;
		v3.uv.v = line->uv.v + line->uv.height;
		v3.color = color;
		
		addVertexToBuffer(v2,activeVBO);
		addVertexToBuffer(v3,activeVBO);
		
	}
}











-(void)setTextureReferences {
	textureAtlasReference = [(Texture*)[[ResourceManager sharedResourceManager] getResourceByIdentifier:@"texture-atlas.png"] reference];
}

-(void)setupCameraOffset:(Vector)offset {
	
	// world transforms
	frameOffset.x = offset.x;
	frameOffset.y = offset.y;
	
	/*
	// screen transforms
	if (camera.orientation != screenOrientation) {
		screenOrientationApplied = NO;
	}
	
	screenOrientation = camera.orientation;
	 */
}

-(Vector)getCameraOffset {
	return frameOffset;
}

-(UIDeviceOrientation)getScreenOrientation {
	return screenOrientation;
}

-(CGSize)getScreenSize {
	
	//if (screenOrientation == UIDeviceOrientationLandscapeLeft || 
	//	screenOrientation == UIDeviceOrientationLandscapeRight) {
//return CGSizeMake(screenSize.height, screenSize.width);
	//}
	
	return screenSize;
}

-(float)getScreenDensity {
	return screenDensity;
}

-(ScreenBorders)getScreenBordersByGutter:(float)gutter {
	return ScreenBordersMake(frameOffset.x, frameOffset.y, screenSize,gutter);
}

// finish frame
-(void)finishFrame {
	
	// present the render buffer to the context
	[eaglContext presentRenderbuffer:GL_RENDERBUFFER_OES];
	
}

-(void)projectLocationVector:(Vector*)location ToScreenVector:(Vector*)screen {
	
	screen->x = location->x + frameOffset.x;
	screen->y = location->y + frameOffset.y;
	
}

-(void)projectTouchPoint:(CGPoint*)touch ToCameraVector:(Vector*)camera {
	
	camera->x = touch->x;
	camera->y = screenSize.height - touch->y;
	
	/*
	if (screenOrientation == UIDeviceOrientationLandscapeLeft) {
		CGFloat temp = -camera->y;
		camera->y = camera->x;
		camera->x = temp;
	}
	else if (screenOrientation == UIDeviceOrientationLandscapeRight) {
		CGFloat temp = camera->y;
		camera->y = -camera->x;
		camera->x = temp;
	}*/
}

-(void)projectTouchPoint:(CGPoint*)touch To2DVector:(Vector*)vector {
	
	vector->y = screenSize.height - touch->y;
	vector->x = touch->x - screenQuarter.width;
	vector->y -= screenQuarter.height;
	/*
	if (screenOrientation == UIDeviceOrientationLandscapeLeft) {
		CGFloat temp = -vector->y;
		vector->y = vector->x;
		vector->x = temp;
	}
	else if (screenOrientation == UIDeviceOrientationLandscapeRight) {
		CGFloat temp = vector->y;
		vector->y = -vector->x;
		vector->x = temp;
	}*/
	
	vector->x -= frameOffset.x;
	vector->y -= frameOffset.y;
	
	float scale = IS_IPAD ? .5 : 1.0;
	
	vector->x *= scale;
	vector->y *= scale;
}

-(Vector)projectTouchToInterface:(CGPoint*)touch {
	
	Vector projection;
	projection.x = touch->x;
	projection.y = touch->y;
	
	projection.y = screenSize.height - projection.y;
	projection.x -= screenSize.width * .5;
	projection.y -= screenSize.height * .5;
	/*
	if (screenOrientation == UIDeviceOrientationLandscapeLeft) {
		CGFloat temp = -projection.y;
		projection.y = projection.x;
		projection.x = temp;
	}
	else if (screenOrientation == UIDeviceOrientationLandscapeRight) {
		CGFloat temp = projection.y;
		projection.y = -projection.x;
		projection.x = temp;
	}
	*/
	return projection;
}

-(UIImage*)snapshot:(UIView*)eaglview {
	
    GLint backingWidth, backingHeight;
	
    // Bind the color renderbuffer used to render the OpenGL ES view
    // If your application only creates a single color renderbuffer which is already bound at this point, 
    // this call is redundant, but it is needed if you're dealing with multiple renderbuffers.
    // Note, replace "_colorRenderbuffer" with the actual name of the renderbuffer object defined in your class.
    //glBindRenderbufferOES(GL_RENDERBUFFER_OES, _colorRenderbuffer);
	
    // Get the size of the backing CAEAGLLayer
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
	
    NSInteger x = 0, y = 0, width = backingWidth, height = backingHeight;
    NSInteger dataLength = width * height * 4;
    GLubyte *data = (GLubyte*)malloc(dataLength * sizeof(GLubyte));
	
    // Read pixel data from the framebuffer
    glPixelStorei(GL_PACK_ALIGNMENT, 4);
    glReadPixels(x, y, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);
	
    // Create a CGImage with the pixel data
    // If your OpenGL ES content is opaque, use kCGImageAlphaNoneSkipLast to ignore the alpha channel
    // otherwise, use kCGImageAlphaPremultipliedLast
    CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGImageRef iref = CGImageCreate(width, height, 8, 32, width * 4, colorspace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast,
                                    ref, NULL, true, kCGRenderingIntentDefault);
	
    // OpenGL ES measures data in PIXELS
    // Create a graphics context with the target size measured in POINTS
    NSInteger widthInPoints, heightInPoints;
    if (NULL != UIGraphicsBeginImageContextWithOptions) {
        // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
        // Set the scale parameter to your OpenGL ES view's contentScaleFactor
        // so that you get a high-resolution snapshot when its value is greater than 1.0
        CGFloat scale = eaglview.contentScaleFactor;
        widthInPoints = width / scale;
        heightInPoints = height / scale;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(widthInPoints, heightInPoints), NO, scale);
    }
    else {
        // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
        widthInPoints = width;
        heightInPoints = height;
        UIGraphicsBeginImageContext(CGSizeMake(widthInPoints, heightInPoints));
    }
	
    CGContextRef cgcontext = UIGraphicsGetCurrentContext();
	
    // UIKit coordinate system is upside down to GL/Quartz coordinate system
    // Flip the CGImage by rendering it to the flipped bitmap context
    // The size of the destination area is measured in POINTS
    CGContextSetBlendMode(cgcontext, kCGBlendModeCopy);
    CGContextDrawImage(cgcontext, CGRectMake(0.0, 0.0, widthInPoints, heightInPoints), iref);
	
    // Retrieve the UIImage from the current context
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	
    UIGraphicsEndImageContext();
	
    // Clean up
    free(data);
    CFRelease(ref);
    CFRelease(colorspace);
    CGImageRelease(iref);
	
    return image;
}

-(void)dealloc {
	
	// Tear down GL
	if (framebuffer)
	{
		glDeleteFramebuffersOES(1, &framebuffer);
		framebuffer = 0;
	}

	if (renderbuffer)
	{
		glDeleteRenderbuffersOES(1, &renderbuffer);
		renderbuffer = 0;
	}

	// Tear down context
	if ([EAGLContext currentContext] == eaglContext) {
		[EAGLContext setCurrentContext:nil];
	}
	
	[eaglContext release];
	eaglContext = nil;
	
	[super dealloc];
}



@end









