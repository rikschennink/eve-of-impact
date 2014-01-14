//
//  Texture.m
//  Eve of Impact
//
//  Created by Rik Schennink on 2/16/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "Texture.h"

@implementation Texture

-(id)initWithIdentifier:(NSString *)identifierString andSize:(GLuint)size {
	
	if (self = [super initWithIdentifier:identifierString]) {
		
		// generate FBO
		glGenFramebuffersOES(1, &fbo);
		glBindFramebufferOES(GL_FRAMEBUFFER_OES, fbo);
		
		// generate texture
		glGenTextures(1, &texture);
		glBindTexture(GL_TEXTURE_2D, texture);
		
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		
		glTexImage2D(GL_TEXTURE_2D, 
					 0, 
					 GL_RGBA, 
					 size, 
					 size, 
					 0,  
					 GL_RGBA, 
					 GL_UNSIGNED_BYTE,
					 NULL);
		
		// associate texture with FBO
		glFramebufferTexture2DOES(
					GL_FRAMEBUFFER_OES, 
					GL_COLOR_ATTACHMENT0_OES, 
					GL_TEXTURE_2D, 
					texture, 
					0);
		
		// bind custom fbo
		glBindFramebufferOES(GL_FRAMEBUFFER_OES, fbo);
		glClearColor(0,0,0,0);
		glClear(GL_COLOR_BUFFER_BIT);
				
		// clear fbo bind
		glBindFramebufferOES(GL_FRAMEBUFFER_OES, 1);
		
		// clear texture bind
		glBindTexture(GL_TEXTURE_2D,0);
		
		// check if it worked (probably worth doing :) )
		GLuint status = glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES);
		if (status != GL_FRAMEBUFFER_COMPLETE_OES)
		{
			// didn't work
		}
	}
	
	return self;
	
}

-(id)initWithIdentifier:(NSString *)identifierString andFilename:(NSString*)filename {
	
	return [self initWithIdentifier:identifierString filename:filename andSize:0];
	
}

-(id)initWithIdentifier:(NSString *)identifierString filename:(NSString*)filename andSize:(GLuint)size  {
	
	if (self = [super initWithIdentifier:identifierString]) {
		
		// get filename parts
		NSArray* components = [filename componentsSeparatedByString:@"."];
		NSString* file = [components objectAtIndex:0];
		NSString* extension = [components objectAtIndex:1];
		
		// load texture data
		NSString* path = [[NSBundle mainBundle] pathForResource:file ofType:extension];
		NSData* data = [[NSData alloc] initWithContentsOfFile:path];
		
		// load textures
		glGenTextures(1,&texture);
		
		// bind texture and start loading texture data into it
		glBindTexture(GL_TEXTURE_2D, texture);
		
		// use these parameters when loading texture data
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
		
		// check extension
		if ([extension isEqualToString:@"pvr"]) {
			
			// set width and height of texture
			width = size;
			height = width;
			
			// load image data
			[self loadPVR:data];
		}
		else {
			[self loadPNG:data];
		}
		
		// release data object
		[data release];
	}
	
	return self;
}

-(void)loadPVR:(NSData*)data {
	
	// This assumes that source PVRTC image is 4 bits per pixel and RGB not RGBA
	// If you use the default settings in texturetool, e.g.:
	//
	//      texturetool -e PVRTC -o texture.pvrtc texture.png
	//
	// then this code should work fine for you.
	
	glCompressedTexImage2D(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG, width, height, 0, [data length], [data bytes]);
	
	GLenum err = glGetError();
	if (err != GL_NO_ERROR)
	{
		NSLog(@"Error uploading compressed texture - glError: 0x%04X", err);
	}
	else {
		NSLog(@"success");
	}

}

-(void)loadPNG:(NSData*)data {
	
	UIImage* image = [[UIImage alloc] initWithData:data];
	
	if (image == nil) {
		NSLog(@"Texture reference not found!");
	}
	
	width = CGImageGetWidth(image.CGImage);
	height = CGImageGetHeight(image.CGImage);
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	void *imageData = malloc( height * width * 4 );
	CGContextRef context = CGBitmapContextCreate( imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
	CGColorSpaceRelease( colorSpace );
	CGContextClearRect( context, CGRectMake( 0, 0, width, height ) );
	
	// flip vertical
	CGContextTranslateCTM (context, 0, height);
	CGContextScaleCTM (context, 1.0, -1.0);
	
	//CGContextTranslateCTM( context, 0, height - height );
    CGContextTranslateCTM( context, 0, 0 );
	CGContextDrawImage( context, CGRectMake( 0, 0, width, height ), image.CGImage );
	
	// load image to opengl
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
	
	// start releasing memory
	CGContextRelease(context);
	free(imageData);
	[image release];
}

-(GLuint)reference {
	return texture;	
}

-(GLuint)fboReference {
	return fbo;	
}

-(void)dealloc {
	
	glDeleteTextures(1,&texture);
	
	[super dealloc];
}

@end
