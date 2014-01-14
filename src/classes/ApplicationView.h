//
//  EAGLView.h
//  Eve of Impact
//
//  Created by Rik Schennink on 2/12/10.
//  Copyright Rik Schennink 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "Common.h"
#import "Vector.h"

@class ApplicationModel;
@class InterfaceLayer;
@class WorldLayer;
@class PlanetLayer;
@class RenderEngine;
@class ParallaxLayer;
@class EffectsLayer;
@class DecorationLayer;
@class SoundManager;
@class CameraLayer;
@class ParticleLayer;
@class Button;

// This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
// The view content is basically an EAGL surface you render your OpenGL scene into.
// Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
@interface ApplicationView : UIView <UITextFieldDelegate> {

@private
	
	EAGLContext *context;
	
	ApplicationModel* model;
	
	ParallaxLayer* stars;
	WorldLayer* world;
	PlanetLayer* planet;
	InterfaceLayer* interface;
	EffectsLayer* effects;
	DecorationLayer* decoration;
	CameraLayer* camera;
	ParticleLayer* particles;
	
	CADisplayLink* displayLink;
	
	int touchCount;
	Vector touchBeginLocation;
	Vector touchMoveLocation;
	Vector touchEndLocation;
	Vector tapEndLocation;
	
	SoundManager* sharedSoundManager;
	
	UITextView* scores;
	UITextField* playerNameInput;
	UIView* playerNameInputPadding;
	
	BOOL captureScreen;
	BOOL halt;
}

@property (nonatomic,retain) InterfaceLayer* interface;

-(id)initWithFrame:(CGRect)frame andModelReference:(ApplicationModel*)applicationModel;

-(void)doHalt;
-(void)doResume;

-(void)draw:(float)interpolation;

-(void)tapEnded:(CGPoint)location;
-(void)requestUsername;

-(void)playButtonPress:(Button*)button;
-(void)playButtonFlicker:(Button*)button;
-(void)playTargetLocked:(CGPoint)location;
-(void)playWarning;

-(void)fadeMusic:(float)scale;
-(void)playMusicIntro;
-(void)playMusicInGameStart;
-(void)playMusicInGame;
-(void)playMusicOutro;

-(void)stopMusic;
-(void)stopAllSounds;

-(void)captureScreenshot;


@end
