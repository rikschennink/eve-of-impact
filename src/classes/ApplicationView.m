//
//  EAGLView.m
//  Eve of Impact
//
//  Created by Rik Schennink on 2/12/10.
//  Copyright Rik Schennink 2010. All rights reserved.
//

#import "ApplicationView.h"
#import "ApplicationModel.h"
#import "ParallaxLayer.h"
#import "PlanetLayer.h"
#import "WorldLayer.h"
#import "EffectsLayer.h"
#import "DecorationLayer.h"
#import "CameraLayer.h"
#import "InterfaceLayer.h"
#import "RenderEngine.h"
#import "Camera.h"
#import "SatelliteActor.h"
#import "ResourceManager.h"
#import "Texture.h"
#import "Common.h"
#import "MathAdditional.h"
#import "SoundManager.h"
#import "MissileActor.h"
#import "Prefs.h"
#import "UserContext.h"
#import "HighScoreBoard.h"
#import "HighScore.h"
#import "Easing.h"
#import "ParticleLayer.h"
#import "Button.h"
#import "Easing.h"
#import "ShieldActor.h"

@implementation ApplicationView


@synthesize interface;


/*
 * The GL view is stored in the nib file. 
 * When it's unarchived it's sent -initWithCoder:
 */
-(id)initWithFrame:(CGRect)frameRect andModelReference:(ApplicationModel*)applicationModel {
    
	self = [super initWithFrame:frameRect];
	
    if (self) {
		
		halt = NO;
		captureScreen = NO;
				
		
		sharedSoundManager = [SoundManager sharedSoundManager];
		/*
        [sharedSoundManager loadMusicWithKey:@"music-intro" musicFile:@"music-intro.mp3"];
		[sharedSoundManager loadMusicWithKey:@"music-ingame" musicFile:@"music-ingame.mp3"];
		[sharedSoundManager loadMusicWithKey:@"music-outro" musicFile:@"music-end.mp3"];
		
		[sharedSoundManager loadSoundWithKey:@"effect-warning" soundFile:@"effect-warning.mp3"];
		[sharedSoundManager loadSoundWithKey:@"effect-target-locked" soundFile:@"effect-target-locked.mp3"];
		[sharedSoundManager loadSoundWithKey:@"effect-button-pressed" soundFile:@"effect-button-pressed.wav"];
		[sharedSoundManager loadSoundWithKey:@"effect-button-intro" soundFile:@"effect-button-intro.mp3"];
        */

		
		[sharedSoundManager setMusicVolume:MAX_MUSIC_VOLUME];
		[sharedSoundManager setFxVolume:1.0f];
		
		if (!MUSIC_ENABLED) {
			[sharedSoundManager setMusicVolume:0.0f];
		}
		
		if (!SFX_ENABLED) {
			[sharedSoundManager setFxVolume:0.0f];
		}
		
		
		// set model reference
		model = applicationModel;
		
		// currently not touching
		touchCount = 0;
		
		// Get the layer and set properties
		CAEAGLLayer* eaglLayer = (CAEAGLLayer*)self.layer;
		eaglLayer.opaque = TRUE;
		eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
									   [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
		if (IS_RETINA) {
			eaglLayer.contentsScale = 2;	
			[self setContentScaleFactor:2.0];
		}
		
		
		
		// get context and check if it's available
		context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
		if (!context || ![EAGLContext setCurrentContext:context]) {
			[self release];
			return nil;
		}
		
		// initialize renderengine with context and layer
		[[RenderEngine singleton] initWithContext:context andLayer:eaglLayer];
		
		// setup textures
		NSMutableArray* resources = [[NSMutableArray alloc]init];
		
        CGSize screenSize = [[RenderEngine singleton] getScreenSize];
        
        
		float planetDynamicSize,shockwaveDynamicSize,interfaceDynamicSize;
		
		NSString* textureAtlasReference;
		NSString* textureAtlasInterfaceReference;
		
		if (IS_RETINA || IS_IPAD) {
			
			textureAtlasReference = @"texture-atlas@2x.png";
			textureAtlasInterfaceReference = @"texture-atlas-interface@2x.png";
			
			planetDynamicSize = 128.0;
			shockwaveDynamicSize = 128.0;
			interfaceDynamicSize = 2048.0;
			
			if (IS_RETINA && IS_IPAD) {
				
				planetDynamicSize = 256.0;
				shockwaveDynamicSize = 256.0;
				interfaceDynamicSize = 4096.0;
				
			}
			
		}
		else {
			
			textureAtlasReference = @"texture-atlas.png";
			textureAtlasInterfaceReference = @"texture-atlas-interface.png";
			
			planetDynamicSize = 64.0;
			shockwaveDynamicSize = 64.0;
			interfaceDynamicSize = 1024.0;
                
		}
		
		
		[resources addObject:[[Texture alloc] initWithIdentifier:@"texture-atlas" andFilename:textureAtlasReference]];
		[resources addObject:[[Texture alloc] initWithIdentifier:@"texture-atlas-interface" andFilename:textureAtlasInterfaceReference]];
		[resources addObject:[[Texture alloc] initWithIdentifier:@"scanlines" andFilename:@"scanlines.png"]];
		[resources addObject:[[Texture alloc] initWithIdentifier:@"planet.dynamic" andSize:planetDynamicSize]];
		[resources addObject:[[Texture alloc] initWithIdentifier:@"shockwave.dynamic" andSize:shockwaveDynamicSize]];
		[resources addObject:[[Texture alloc] initWithIdentifier:@"interface.dynamic" andSize:interfaceDynamicSize]];
		
		[[ResourceManager sharedResourceManager] addResources:resources];
		[resources release];
		
		// set texture references
		uint atlasTexture = [(Texture*)[[ResourceManager sharedResourceManager] getResourceByIdentifier:@"texture-atlas"] reference];
		uint interfaceTexture = [(Texture*)[[ResourceManager sharedResourceManager] getResourceByIdentifier:@"texture-atlas-interface"] reference];
		uint scanlinesTexture = [(Texture*)[[ResourceManager sharedResourceManager] getResourceByIdentifier:@"scanlines"] reference];
		uint planetVisual = [(Texture*)[[ResourceManager sharedResourceManager] getResourceByIdentifier:@"planet.dynamic"] reference];
		uint shockwaveVisual = [(Texture*)[[ResourceManager sharedResourceManager] getResourceByIdentifier:@"shockwave.dynamic"] reference];
		uint interfaceVisual = [(Texture*)[[ResourceManager sharedResourceManager] getResourceByIdentifier:@"interface.dynamic"] reference];
		
		[[RenderEngine singleton] addTexture:atlasTexture at:TEXTURE_DEFAULT];
		[[RenderEngine singleton] addTexture:interfaceTexture at:TEXTURE_INTERFACE];
		[[RenderEngine singleton] addTexture:scanlinesTexture at:TEXTURE_SCANLINES];
		[[RenderEngine singleton] addTexture:planetVisual at:TEXTURE_PLANET_VISUAL];
		[[RenderEngine singleton] addTexture:shockwaveVisual at:TEXTURE_SHOCKWAVE_VISUAL];
		[[RenderEngine singleton] addTexture:interfaceVisual at:TEXTURE_INTERFACE_VISUAL];
		
		
		
		float interfaceFBOSize,destroyedPlanetFBOSize,shockwaveFBOSize;
        
        interfaceFBOSize = screenSize.height;
        
        if (IS_IPAD) {
			shockwaveFBOSize = 128.0;
			destroyedPlanetFBOSize = 128.0;
        }
        else {
			shockwaveFBOSize = 64.0;
			destroyedPlanetFBOSize = 64.0;
        }
        
        if (IS_RETINA) {
            shockwaveFBOSize*=2.0;
            destroyedPlanetFBOSize*=2.0;
            interfaceFBOSize*=2.0;
        }
        
		
		// set interface framebuffer
		uint ifbo = [(Texture*)[[ResourceManager sharedResourceManager] getResourceByIdentifier:@"interface.dynamic"] fboReference];
		FrameBuffer interfaceFBO = FrameBufferMake(ifbo, interfaceFBOSize, interfaceFBOSize);
		[[RenderEngine singleton] addFrameBuffer:interfaceFBO at:FBO_INTERFACE];
		
		// set destroyed planet framebuffer
		uint pfbo = [(Texture*)[[ResourceManager sharedResourceManager] getResourceByIdentifier:@"planet.dynamic"] fboReference];
		FrameBuffer destroyedPlanetFBO = FrameBufferMake(pfbo, destroyedPlanetFBOSize, destroyedPlanetFBOSize);
		[[RenderEngine singleton] addFrameBuffer:destroyedPlanetFBO at:FBO_PLANET_DESTROYED];
		
		// set shockwave framebuffer
		uint sfbo = [(Texture*)[[ResourceManager sharedResourceManager] getResourceByIdentifier:@"shockwave.dynamic"] fboReference]; 
		FrameBuffer shockwaveFBO = FrameBufferMake(sfbo, shockwaveFBOSize, shockwaveFBOSize);
		[[RenderEngine singleton] addFrameBuffer:shockwaveFBO at:FBO_PLANET_SHOCKWAVE];
		
		// define default and alt vbo's
		VertexBuffer defaultVBO = VertexBufferMake();
		VertexBuffer altVBO = VertexBufferMake();
		[[RenderEngine singleton] addVertexBuffer:defaultVBO at:VBO_DEFAULT];
		[[RenderEngine singleton] addVertexBuffer:altVBO at:VBO_ALT];
		
		
		// setup world view
		stars = [[ParallaxLayer alloc] initWithModel:model];
		planet = [[PlanetLayer alloc] initWithModel:model];
		world = [[WorldLayer alloc] initWithModel:model];
		decoration = [[DecorationLayer alloc] initWithModel:model];
		effects = [[EffectsLayer alloc] initWithModel:model];
		interface = [[InterfaceLayer alloc] initWithModel:model];
		camera = [[CameraLayer alloc] initWithModel:model];
		particles = [[ParticleLayer alloc] initWithModel:model];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(handleUserInput:) 
													 name:@"RequestUserInput" 
												   object:nil];
		
		// set touch vectors
		touchBeginLocation = VectorMake(0, 0);
		touchMoveLocation = VectorMake(0, 0);
		touchEndLocation = VectorMake(0, 0);
		tapEndLocation = VectorMake(0, 0);
		
		
		
		// set player name input field
		if (IS_IPAD) {
			playerNameInput = [[UITextField alloc] initWithFrame:CGRectMake(212, 446, 360, 26)];
		}
		else {			
			playerNameInput = [[UITextField alloc] initWithFrame:CGRectMake(46, (screenSize.height*.5) - 22, 240, 16)];
		}
		[playerNameInput setDelegate:self];
		
        
		
		NSString* path;
		if (IS_RETINA || IS_IPAD) {
			path = [[NSBundle mainBundle] pathForResource:@"name-input@2x" ofType:@"png"];
		}
		else {
			path = [[NSBundle mainBundle] pathForResource:@"name-input" ofType:@"png"];		
		}
		
		NSData* data = [[NSData alloc] initWithContentsOfFile:path];
		UIImage* playerNameInputBackground = [[UIImage alloc] initWithData:data];
		
		// style
		if (IS_IPAD){
			playerNameInputPadding = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 210, 17)] autorelease];	
		}
		else {
			playerNameInputPadding = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 138, 16)] autorelease];
		}
		
		playerNameInput.leftView = playerNameInputPadding;
		playerNameInput.leftViewMode = UITextFieldViewModeAlways;
		
		[playerNameInput setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
		[playerNameInput setTextAlignment:UITextAlignmentLeft];
		[playerNameInput setBackground:playerNameInputBackground];
		[playerNameInput setBackgroundColor:[UIColor clearColor]];
		[playerNameInput setBorderStyle:UITextBorderStyleNone];
		[playerNameInput setAutocapitalizationType:UITextAutocapitalizationTypeAllCharacters];
		[playerNameInput setAutocorrectionType:UITextAutocorrectionTypeNo];
		[playerNameInput setKeyboardType:UIKeyboardTypeAlphabet];
		[playerNameInput setKeyboardAppearance:UIKeyboardAppearanceAlert];
		[playerNameInput setClearButtonMode:UITextFieldViewModeNever];
		[playerNameInput setReturnKeyType:UIReturnKeyDone];
		[playerNameInput setTextColor:[UIColor colorWithRed:0.0 / 255.0 green:50.0 / 255.0 blue:1.0 alpha:.95]];
		
		if (IS_IPAD) {
			[playerNameInput setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17.0f]];
		}
		else {
			[playerNameInput setFont:[UIFont fontWithName:@"Helvetica-Bold" size:11.0f]];
		}
		
	}
	
    return self;
}


-(void)doHalt {
	halt = YES;
}

-(void)doResume {
	halt = NO;
}


/*
 * Actual drawing
 */
-(void)draw:(float)interpolation {
	
	if (halt) {
		return;
	}
	
	// set camera transform object for later use
	Vector cameraOffset;
	cameraOffset.x = model.camera.mergedOffset.x + (model.camera.velocity.x * interpolation);
	cameraOffset.y = model.camera.mergedOffset.y + (model.camera.velocity.y * interpolation);
	
	// set listener position
	[sharedSoundManager setListenerPosition:CGPointMake(-cameraOffset.x,-cameraOffset.y)];
	
	// camera position is stored in renderengine for later reference
	[[RenderEngine singleton] setupCameraOffset:cameraOffset];
	Transform cameraTransform = TransformMake(TRANSFORM_TRANSLATE, 0.0, Transform3DMake(cameraOffset.x,cameraOffset.y,0.0));
	
	// setup view
	[[RenderEngine singleton] resetBlendMode];
	[[RenderEngine singleton] setActiveTexture:TEXTURE_DEFAULT];
	[[RenderEngine singleton] setActiveFrameBuffer:FBO_DEFAULT];
	[[RenderEngine singleton] clearActiveFrameBuffer];
	[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
	[[RenderEngine singleton] flushActiveVertexBuffer];
	
	[[RenderEngine singleton] set3DProjection]; // start in 3d projection when drawing nebula and starmaps
	
	[stars redraw:interpolation];				// stars are added to seperate vbo and cached
	
	[[RenderEngine singleton] set2DProjection]; // all other stuff is rendered in 2d
	
	[planet redraw:interpolation];				// planet does it's own drawing (too much going on)
	
	// set default vbo and reset it
	[[RenderEngine singleton] setActiveVertexBuffer:VBO_ALT];
	[[RenderEngine singleton] flushActiveVertexBuffer];
	[[RenderEngine singleton] resetTransformsOfActiveVertexBuffer];
	[[RenderEngine singleton] addTransformToActiveVertexBuffer:cameraTransform];
	
	[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
	[[RenderEngine singleton] flushActiveVertexBuffer];
	[[RenderEngine singleton] resetTransformsOfActiveVertexBuffer];
	[[RenderEngine singleton] addTransformToActiveVertexBuffer:cameraTransform];
	
	[world redraw:interpolation];				// world coordinates are not flushed and world is drawn at after sfx are added to the default and alt VBOs
	
	[effects redraw:interpolation];				// add explosions and glow effects
	
	[particles redraw:interpolation];			// add particle effects
	
	// draw world & effects
	[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT]; // default vertices
	[[RenderEngine singleton] renderActiveVertexBuffer];
	[[RenderEngine singleton] flushActiveVertexBuffer];
	[[RenderEngine singleton] resetTransformsOfActiveVertexBuffer];
	
	[[RenderEngine singleton] setActiveBlendMode:BLEND_MODE_DODGE]; // additional sfx vertices
	[[RenderEngine singleton] setActiveVertexBuffer:VBO_ALT];
	[[RenderEngine singleton] renderActiveVertexBuffer];
	[[RenderEngine singleton] flushActiveVertexBuffer];
	[[RenderEngine singleton] resetTransformsOfActiveVertexBuffer];
	
	// draw camera
	[camera redraw:interpolation];
	
	[[RenderEngine singleton] setActiveBlendMode:BLEND_MODE_DEFAULT];
	[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
	[[RenderEngine singleton] renderActiveVertexBuffer];
	[[RenderEngine singleton] flushActiveVertexBuffer];
	
	[[RenderEngine singleton] setActiveBlendMode:BLEND_MODE_DODGE];
	[[RenderEngine singleton] setActiveVertexBuffer:VBO_ALT];
	[[RenderEngine singleton] renderActiveVertexBuffer];
	[[RenderEngine singleton] flushActiveVertexBuffer];
	
	
	// take screenshot withouth descoration and interface
	if (captureScreen) {
		
		// don't capture screen again
		captureScreen = NO;
		
		// get screenshot
		UIImage* screenshot = [[RenderEngine singleton] snapshot:self];
		
		// crop to center
		float screenWidth = self.bounds.size.width;
		float screenHeight = self.bounds.size.height;
		
		if (IS_RETINA) {
			screenWidth  *= 2.0;
			screenHeight *= 2.0;
		}
		
		CGSize size = CGSizeMake(screenWidth,screenHeight / 2.4);
		float diff;
		CGPoint offset = CGPointMake(model.camera.offset.x + screenWidth*.5,-model.camera.offset.y + screenHeight*.5);
		CGRect area = CGRectMake(offset.x - size.width * .5, offset.y - size.height * .5, size.width, size.height);
		
		if (area.origin.x < 0) {
			area.origin.x = 0;
		}
		
		if (area.origin.y < 0) {
			area.origin.y = 0;
		}
		
		if (area.origin.x + area.size.width > screenWidth) {
			diff = (area.origin.x + area.size.width) - screenWidth;
			area.origin.x -= diff;
		}
		
		if (area.origin.y + area.size.height > screenHeight) {
			diff = (area.origin.x + area.size.height) - screenHeight;
			area.origin.y -= diff;
		}
		
		CGImageRef imageRef = CGImageCreateWithImageInRect([screenshot CGImage], area);
		screenshot = [UIImage imageWithCGImage:imageRef];
		CGImageRelease(imageRef);
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ScreenCaptured" object:screenshot];
	}
	
	
	// switch to interface FBO
	[[RenderEngine singleton] setActiveFrameBuffer:FBO_INTERFACE];
	[[RenderEngine singleton] clearActiveFrameBuffer];
	[[RenderEngine singleton] set2DProjection];
	
	// draw decoration to default VBO
	[[RenderEngine singleton] resetBlendMode];
	[[RenderEngine singleton] setActiveVertexBuffer:VBO_DEFAULT];
	[[RenderEngine singleton] setActiveBlendMode:BLEND_MODE_DEFAULT];
	[[RenderEngine singleton] setTransformModeOfActiveVertexBuffer:TRANSFORM_MODE_DIRECT];
	[[RenderEngine singleton] resetTransformsOfActiveVertexBuffer];
	
	// draw decorion and apply camera offset directly
	[[RenderEngine singleton] addTransformToActiveVertexBuffer:cameraTransform];
	
	[decoration redraw:interpolation];
	
	// draw interface and don't apply any transforms
	[[RenderEngine singleton] resetTransformsOfActiveVertexBuffer];
	[[RenderEngine singleton] resetTransformsModeOfActiveVertexBuffer];
	
	[interface redraw:interpolation];
	
	[[RenderEngine singleton] finishFrame];
}




/*
 * Touch handling
 */
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
		
	// get touch event
	UITouch* touch = [[event allTouches] anyObject];
	CGPoint touchLocation = [touch locationInView:touch.view];
	
	// send to interface
	[interface onTouchesBeginAt:touchLocation];
	
	// check if interface is being touched
	if (!interface.touching) {
		
		if (model.state == STATE_PLAYING) {
			
			// get 2.5D touch position
			[[RenderEngine singleton] projectTouchPoint:&touchLocation To2DVector:&touchBeginLocation];
			
			// tell model to handle this action request
			[model handle:ACTION_HOLD RequestAt:touchBeginLocation];
			
			// if not, user must want to drag the camera
			[[RenderEngine singleton] projectTouchPoint:&touchLocation ToCameraVector:&touchBeginLocation];
			
			// do camera transforms
			[model.camera startDrag:touchBeginLocation];
			
		}
	}
	
	// show intro on first touch @ title animation
	if (model.state == STATE_TITLE || model.state == STATE_INTRO) {
		[model doShowStartMenu];
	}
	
	// show outro on first touch @ gameover animation
	else if (model.ticks > 24 && model.state == STATE_GAMEOVER) {
		[model doShowGameOverMenu];
	}
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	// get touch event
	UITouch *touch = [[event allTouches] anyObject];
	CGPoint touchLocation = [touch locationInView:touch.view];
	
	// send to interface
	[interface onTouchesMoveAt:[touch locationInView:touch.view]];
	
	if (!interface.touching) {
		
		if (model.state == STATE_PLAYING) {
			
			// set to 2D vector
			[[RenderEngine singleton] projectTouchPoint:&touchLocation To2DVector:&touchMoveLocation];
		
			// location of touch as 3D vector
			[[RenderEngine singleton] projectTouchPoint:&touchLocation ToCameraVector:&touchMoveLocation];
			
			// convert location to camera space
			if (model.camera.dragging) {
				
				// no shield overloading while dragging
				[model.shield overloadCancel];
				
				// drag
				[model.camera drag:touchMoveLocation];
			}
		}
	}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	// get touch event
	UITouch *touch = [[event allTouches] anyObject];
	CGPoint touchLocation = [touch locationInView:touch.view];
	
	// send to interface
	[interface onTouchesEndAt:[touch locationInView:touch.view]];
	
	if (!interface.touching) {
		
		// location of touch as 3D vector
		[[RenderEngine singleton] projectTouchPoint:&touchLocation ToCameraVector:&touchEndLocation];
		
		// calculate distance between start and end touch to determine if this was a tap or not
		if (getDistanceSquaredBetween(touchBeginLocation.x, touchBeginLocation.y, touchEndLocation.x, touchEndLocation.y) < 250.0) {
			[self tapEnded:[touch locationInView:touch.view]];
			//return;
		}
		
		// get 2.5D touch position
		[[RenderEngine singleton] projectTouchPoint:&touchLocation To2DVector:&touchEndLocation];
		
		// tell model to handle this action request
		[model handle:ACTION_RELEASE RequestAt:touchEndLocation];
		
		// stop camera dragging
		if (model.camera.dragging) {
			[model.camera stopDrag];
		}
	}
}

-(void)tapEnded:(CGPoint)location {
	
	// get 2.5D touch position
	[[RenderEngine singleton] projectTouchPoint:&location To2DVector:&tapEndLocation];
	
	// tell model to handle this action request
	[model handle:ACTION_TAP RequestAt:tapEndLocation];
}


-(void)playButtonFlicker:(Button*)button {
	
	float volume = button.ticks == 1 ? .75 : .5;
	volume = randomBetween(volume - .1, volume);
	float pitch = randomBetween(1.0, 1.1);
	CGPoint location = CGPointMake(button.position.x - 160, button.position.y - 240);
	
	[sharedSoundManager playSoundWithKey:@"effect-button-intro" gain:volume pitch:pitch location:location shouldLoop:NO]; 	
}

-(void)playButtonPress:(Button*)button {
	
	[sharedSoundManager playSoundWithKey:@"effect-button-pressed" gain:.25 pitch:1.0 location:CGPointMake(0, 0) shouldLoop:NO];
	
}

-(void)playTargetLocked:(CGPoint)location {
	
	[sharedSoundManager playSoundWithKey:@"effect-target-locked" gain:.5 pitch:1.0 location:location shouldLoop:NO];
	
}

-(void)playWarning {
	
	[sharedSoundManager playSoundWithKey:@"effect-warning"];
	
}

-(void)playMusicIntro {
	
	if (!MUSIC_ENABLED) {
		return;
	}
	
	[sharedSoundManager playMusicWithKey:@"music-intro" timesToRepeat:0];
	
}

-(void)playMusicInGameStart {
	
	if (sharedSoundManager.isMusicPlaying) {
		
		[sharedSoundManager fadeMusicVolumeFrom:MAX_MUSIC_VOLUME toVolume:0.0 duration:2.0 stop:YES];
		
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playMusicInGame) object:nil];
		[self performSelector:@selector(playMusicInGame) withObject:nil afterDelay:2.5];
		/*
		[NSTimer scheduledTimerWithTimeInterval:2.5 target:self 
										selector:@selector(playMusicInGame:)
										userInfo:nil
										 repeats:NO];
		*/
	}
	else {
		[self playMusicInGame];
	}
	
}

-(void)playMusicInGame {
	
	if (!MUSIC_ENABLED) {
		return;
	}
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playMusicInGame) object:nil];
	
	/*
	// check if called from timer
	if (timer != nil) {
		[timer invalidate];
		timer = nil;
	}
	*/
	// intro music no longer needed
	[sharedSoundManager stopMusic];
	[sharedSoundManager removeMusicWithKey:@"music-intro"];
	
	// play ingame music
	[sharedSoundManager fadeMusicVolumeFrom:0.0 toVolume:MAX_MUSIC_VOLUME duration:2.5 stop:NO];
	[sharedSoundManager playMusicWithKey:@"music-ingame" timesToRepeat:-1];
}

-(void)fadeMusic:(float)scale {
	
	float newVolume = scale * MAX_MUSIC_VOLUME;
	float currentVolume = sharedSoundManager.currentMusicVolume;
	
	if (newVolume < currentVolume) {
		[sharedSoundManager fadeMusicVolumeFrom:currentVolume toVolume:newVolume duration:.25 stop:NO];
	}
	else {
		[sharedSoundManager fadeMusicVolumeFrom:currentVolume toVolume:newVolume duration:2.0 stop:NO];
	}
}

-(void)playMusicOutro {
	
	if (!MUSIC_ENABLED) {
		return;
	}
	
	[sharedSoundManager stopMusic];
	[sharedSoundManager fadeMusicVolumeFrom:0.0 toVolume:MAX_MUSIC_VOLUME duration:2.0 stop:NO];
	[sharedSoundManager playMusicWithKey:@"music-outro" timesToRepeat:0];
	
}

-(void)stopMusic {
	
	[sharedSoundManager fadeMusicVolumeFrom:MAX_MUSIC_VOLUME toVolume:0.0 duration:2.0 stop:YES];
	
}

-(void)stopAllSounds {
	[sharedSoundManager stopMusic];
}



-(void)requestUsername {
	
	playerNameInput.text = model.userContext.username;
	[self addSubview:playerNameInput];
	[playerNameInput becomeFirstResponder];
	
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	
}

- (void)textFieldDidEndEditing:(UITextField*)textField {
	
	// end editing and remove from view
	[textField endEditing:YES];
	[textField removeFromSuperview];
	
	// notify view
	[[NSNotificationCenter defaultCenter] postNotificationName:@"UsernameEntered" object:[[textField text] uppercaseString]];
	
}

- (BOOL)textFieldShouldReturn:(UITextField*)texField {
	
	// end editing
	[texField resignFirstResponder];
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)entered {
	
	NSCharacterSet *validCharacters = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "];
	
	uint length = [entered length];
	
	for (int i=0; i<length; i++) {
		
		unichar c = [entered characterAtIndex:i];
		
		if (![validCharacters characterIsMember:c]) {
			return NO;
		}
	}
	
	uint newLength = [textField.text length] + [entered length] - range.length;
	
	if (newLength > 10) {
		return NO;
	}
	
	return YES;
}

-(void)captureScreenshot {
	captureScreen = YES;
}


/*
 * Memory stuff
 */
-(void)dealloc {
	
	[playerNameInput release];
	[playerNameInputPadding release];
	
	[world release];
	
	[sharedSoundManager shutdownSoundManager];
	
	[interface release];
	
	[context release];
	
	[super dealloc];
}

// You must implement this method
+(Class)layerClass {
    return [CAEAGLLayer class];
}

@end
