//
//  RenderEngine.h
//  Eve of Impact
//
//  Created by Rik Schennink on 2/25/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "Common.h"
#import "Vector.h"

@class Visual;
@class Camera;

@interface RenderEngine : NSObject {
	
@private
	
	// opengl default properties
	GLuint framebuffer;
	GLuint renderbuffer;
	EAGLContext* eaglContext;
	CAEAGLLayer* eaglLayer;
	GLsizei vertexDataStride;
	
	// buffers related
	VertexBuffer vertexBuffers[10];
	FrameBuffer frameBuffers[10];
	GLuint textures[10];
	
	// state related
	VertexBuffer *activeVBO;
	FrameBuffer *activeFBO;
	uint activeTexture;
	//TransformSet transformSet;
	uint activeBlendMode;
	bool culling;
	
	// default textures
	GLuint textureAtlasReference;
	
	// screen dimensions and orientation
	CGRect screenBounds;
	CGSize screenSize;
	float screenDensity;
	CGSize screenQuarter;
	UIDeviceOrientation screenOrientation;
	BOOL screenOrientationApplied;
	
	// camera transforms
	Vector frameOffset;
	BOOL doCameraTransforms;

}

+(RenderEngine*)singleton;

-(void)set3DProjection;
-(void)set2DProjection;

-(void)addTexture:(uint)texture at:(uint)index;
-(void)setActiveTexture:(uint)index;

-(void)setActiveBlendMode:(uint)blendMode;
-(void)resetBlendMode;

-(void)enableCulling;
-(void)disableCulling;

-(void)setTransformModeOfActiveVertexBuffer:(uint)mode;
-(void)resetTransformsModeOfActiveVertexBuffer;
-(void)addTransformToActiveVertexBuffer:(Transform)transform;
-(void)resetTransformsOfActiveVertexBuffer;

-(void)addFrameBuffer:(FrameBuffer)buffer at:(uint)index;
-(void)setActiveFrameBuffer:(uint)index;
-(void)clearActiveFrameBuffer;

-(void)addVertexBuffer:(VertexBuffer)buffer at:(uint)index;
-(void)setActiveVertexBuffer:(uint)index;

-(void)renderActiveVertexBuffer;
-(void)flushActiveVertexBuffer;

-(void)addIndex:(GLushort)index;
-(void)addVertex:(VertexData)vertex;

-(void)addQuad:(QuadTemplate*)quad;
-(void)addQuad:(QuadTemplate*)quad andRotateBy:(float)rotation;
-(void)addCenteredQuad:(QuadTemplate*)quad;
-(void)addRing:(RingTemplate*)ring;
-(void)addRing:(RingTemplate*)ring withMode:(uint)mode;
-(void)addLine:(LineTemplate*)line;





-(id)initWithContext:(EAGLContext*)context andLayer:(CAEAGLLayer*)layer;

-(void)finishFrame;

//-(void)setupCamera:(Camera*)camera;
-(void)setupCameraOffset:(Vector)offset;
-(Vector)getCameraOffset;
-(ScreenBorders)getScreenBordersByGutter:(float)gutter;
-(UIDeviceOrientation)getScreenOrientation;
-(CGSize)getScreenSize;
-(float)getScreenDensity;

-(void)projectLocationVector:(Vector*)location ToScreenVector:(Vector*)screen;
-(void)projectTouchPoint:(CGPoint*)touch ToCameraVector:(Vector*)camera;
-(void)projectTouchPoint:(CGPoint*)touch To2DVector:(Vector*)vector;

-(Vector)projectTouchToInterface:(CGPoint*)touch;

-(UIImage*)snapshot:(UIView*)eaglview;

@end