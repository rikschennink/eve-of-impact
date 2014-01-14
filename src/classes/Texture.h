//
//  Texture.h
//  Eve of Impact
//
//  Created by Rik Schennink on 2/16/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "Resource.h"

@interface Texture : Resource {
	
	GLuint fbo;
	GLuint texture;
	GLuint width;
	GLuint height;
	
}

-(id)initWithIdentifier:(NSString *)identifierString filename:(NSString*)filename andSize:(GLuint)size;
-(id)initWithIdentifier:(NSString *)identifierString andFilename:(NSString*)filename;
-(id)initWithIdentifier:(NSString *)identifierString andSize:(GLuint)size;

-(void)loadPNG:(NSData*)data;
-(void)loadPVR:(NSData*)data;

-(GLuint)reference;
-(GLuint)fboReference;

@end
