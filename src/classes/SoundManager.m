//
//  SoundManager.m
//  SLQTSOR
//
//  Created by Michael Daley on 22/05/2009.
//  Copyright 2009 Michael Daley. All rights reserved.
//

#import "SoundManager.h"
#import "SynthesizeSingleton.h"
#import "MyOpenALSupport.h"
#import "Prefs.h"

#pragma mark -
#pragma mark Private interface

@interface SoundManager (Private)

// This method is used to initialize OpenAL.  It gets the default device, creates a new context 
// to be used and then preloads the define # sources.  This preloading means we wil be able to play up to
// (max 32) different sounds at the same time
- (BOOL)initOpenAL;

// Used to get the next available OpenAL source.  The returned source is then bound to a sound
// buffer so that the sound can be played.  This method checks each of the available OpenAL 
// soucres which have been generated and returns the first source which is not currently being
// used.  If no sources are found to be free then the first looping source is returned.  If there
// are no looping sources then the first source created is returned
- (NSUInteger)nextAvailableSource;

// Used to set the current state of OpenAL.  When the game is interrupted the OpenAL state is
// stopped and then restarted when the game becomes active again.
- (void)setActivated:(BOOL)aState;

// If audio is currently playing this method returns YES
- (BOOL)isExternalAudioPlaying;

// Checks for any OpenAL error that may have been set
- (void)checkForErrors;

@end


#pragma mark -
#pragma mark Public implementation

@implementation SoundManager

// Make this class a singleton class
SYNTHESIZE_SINGLETON_FOR_CLASS(SoundManager);

@synthesize currentMusicVolume;
@synthesize fxVolume;
@synthesize isExternalAudioPlaying;
@synthesize isMusicPlaying;
@synthesize usePlaylist;
@synthesize loopLastPlaylistTrack;
@synthesize musicVolume;

#pragma mark -
#pragma mark Dealloc and Init and Shutdown

- (void)dealloc {
	// Loop through the OpenAL sources and delete them
	for(NSNumber *sourceIDVal in soundSources) {
		NSUInteger sourceID = [sourceIDVal unsignedIntValue];
		alDeleteSources(1, &sourceID);
	}
	
	// Loop through the OpenAL buffers and delete 
	NSEnumerator *enumerator = [soundLibrary keyEnumerator];
	id key;
	while ((key = [enumerator nextObject])) {
		NSNumber *bufferIDVal = [soundLibrary objectForKey:key];
		NSUInteger bufferID = [bufferIDVal unsignedIntValue];
		alDeleteBuffers(1, &bufferID);		
	}
    
	// Release the arrays and dictionaries we have been using
	[soundLibrary release];
	[soundSources release];
	[musicLibrary release];
	[musicPlaylists release];
	if (currentPlaylistTracks) {
		[currentPlaylistTracks release];
	}
	
	// If background music has been played then release the AVAudioPlayer
	if(musicPlayer)
		[musicPlayer release];
	
	// Disable and then destroy the context
	alcMakeContextCurrent(NULL);
	alcDestroyContext(context);
	
	// Close the device
	alcCloseDevice(device);
	
	[super dealloc];
}


- (id)init {
    self = [super init];
	if(self != nil) {
		
        // Initialize the array and dictionaries we are going to use
		soundSources = [[NSMutableArray alloc] init];
		soundLibrary = [[NSMutableDictionary alloc] init];
		musicLibrary = [[NSMutableDictionary alloc] init];
		musicPlaylists = [[NSMutableDictionary alloc] init];
		
		// Grab a reference to the AVAudioSession singleton
		audioSession = [AVAudioSession sharedInstance];
        [audioSession setDelegate:self];
		soundCategory = AVAudioSessionCategoryAmbient;
		[audioSession setCategory:soundCategory error:&audioSessionError];
		
		// Now we have initialized the sound engine using ambient sound, we can check to see if ipod music is already playing.
		// If that is the case then you can leave the sound category as AmbientSound.  If ipod music is not playing we can set the
		// sound category to SoloAmbientSound so that decoding is done using the hardware.
		isExternalAudioPlaying = [self isExternalAudioPlaying];
		
		if (!isExternalAudioPlaying) {
			soundCategory = AVAudioSessionCategorySoloAmbient;
			audioSessionError = nil;
			[audioSession setCategory:soundCategory error:&audioSessionError];
			//if (audioSessionError) {
				//NSLog(@"WARNING - SoundManager: Error setting the sound category to SoloAmbientSound");
			//}
		}
		
        // Set up OpenAL.  If an error occurs then nil will be returned.
		BOOL success = [self initOpenAL];
		if(!success) {
           // NSLog(@"ERROR - SoundManager: Error initializing OpenAL");
            return nil;
        }
        
        // Set the default volume for music and fx along with the default play list index
		currentMusicVolume = 0.5f;
		musicVolume = 0.5f;
		fxVolume = 0.5f;
		playlistIndex = 0;
		
		// Set up initial flag values
		isFading = NO;
		isMusicPlaying = NO;
		stopMusicAfterFade = YES;
		usePlaylist = NO;
		loopLastPlaylistTrack = NO;
	}
    return self;
}


- (void)shutdownSoundManager {
	@synchronized(self) {
		if(sharedSoundManager != nil) {
			[self dealloc];
		}
	}
}

#pragma mark -
#pragma mark Sound management

- (void)loadSoundWithKey:(NSString*)aSoundKey soundFile:(NSString*)aMusicFile {

    // Check to make sure that a sound with the same key does not already exist
    NSNumber *numVal = [soundLibrary objectForKey:aSoundKey];
    
    // If the key is not found log it and finish
    if(numVal != nil) {
        //NSLog(@"WARNING - SoundManager: Sound key '%@' already exists.", aSoundKey);
        return;
    }
    
	// Set up the bufferID that will hold the OpenAL buffer generated
    NSUInteger bufferID;
	
	alError = AL_NO_ERROR;

	// Generate a buffer within OpenAL for this sound
	alGenBuffers(1, &bufferID);
	
	// Check to make sure no errors occurred.
	if((alError = alGetError()) != AL_NO_ERROR) {
		//NSLog(@"ERROR - SoundManager: Error generating OpenAL buffer with error %x for filename %@\n", alError, aMusicFile);
		
	}
    
    // Set up the variables which are going to be used to hold the format
    // size and frequency of the sound file we are loading along with the actual sound data
	ALenum  format;
	ALsizei size;
	ALsizei frequency;
	ALvoid *data;
    
	NSBundle *bundle = [NSBundle mainBundle];
	
	// Get the audio data from the file which has been passed in
	NSString *fileName = [[aMusicFile lastPathComponent] stringByDeletingPathExtension];
	NSString *fileType = [aMusicFile pathExtension];
	CFURLRef fileURL = (CFURLRef)[[NSURL fileURLWithPath:[bundle pathForResource:fileName ofType:fileType]] retain];
	
	if (fileURL) {	
		data = MyGetOpenALAudioData(fileURL, &size, &format, &frequency);
		CFRelease(fileURL);
		
		// Use the static buffer data API
		alBufferData(bufferID, format, data, size, frequency);
		
		if((alError = alGetError()) != AL_NO_ERROR) {
			//NSLog(@"ERROR - SoundManager: Error attaching audio to buffer: %x\n", alError);
		}
		
		// Free the memory we used when getting the audio data
		free(data);
	} else {
		//NSLog(@"ERROR - SoundManager: Could not find file '%@.%@'", fileName, fileType);
		if (data)
			free(data);
		data = NULL;
	}
	
	// Place the buffer ID into the sound library against |aSoundKey|
	[soundLibrary setObject:[NSNumber numberWithUnsignedInt:bufferID] forKey:aSoundKey];
    //NSLog(@"INFO - SoundManager: Loaded sound with key '%@' into buffer '%d'", aSoundKey, bufferID);
}

- (void)removeSoundWithKey:(NSString*)aSoundKey {
 
	// Reset errors in OpenAL
	alError = alGetError();
	alError = AL_NO_ERROR;

    // Find the buffer which has been linked to the sound key provided
    NSNumber *numVal = [soundLibrary objectForKey:aSoundKey];
    
    // If the key is not found log it and finish
    if(numVal == nil) {
        //NSLog(@"WARNING - SoundManager: No sound with key '%@' was found so cannot be removed", aSoundKey);
        return;
    }
    
    // Get the buffer number from
    NSUInteger bufferID = [numVal unsignedIntValue];
	NSInteger bufferForSource;
	NSInteger sourceState;
	for(NSNumber *sourceID in soundSources) {

		NSUInteger currentSourceID = [sourceID unsignedIntValue];
		
		// Grab the current state of the source and also the buffer attached to it
		alGetSourcei(currentSourceID, AL_SOURCE_STATE, &sourceState);
		alGetSourcei(currentSourceID, AL_BUFFER, &bufferForSource);

		// If this source is not playing then unbind it.  If it is playing and the buffer it
		// is playing is the one we are removing, then also unbind that source from this buffer
		if(sourceState != AL_PLAYING || (sourceState == AL_PLAYING && bufferForSource == bufferID)) {
			alSourceStop(currentSourceID);
			alSourcei(currentSourceID, AL_BUFFER, 0);
		}
	} 
    
	// Delete the buffer
	alDeleteBuffers(1, &bufferID);
	
	// Check for any errors
	if((alError = alGetError()) != AL_NO_ERROR) {
		//NSLog(@"ERROR - SoundManager: Could not delete buffer %d with error %x", bufferID, alError);
		exit(1);
	}
	
	// Remove the soundkey from the soundLibrary
    [soundLibrary removeObjectForKey:aSoundKey];

    //NSLog(@"INFO - SoundManager: Removed sound with key '%@'", aSoundKey);
}


- (void)loadMusicWithKey:(NSString*)aMusicKey musicFile:(NSString*)aMusicFile {
	
	// Get the filename and type from the music file name passed in
	NSString *fileName = [[aMusicFile lastPathComponent] stringByDeletingPathExtension];
	NSString *fileType = [aMusicFile pathExtension];
	
    // Check to make sure that a sound with the same key does not already exist
    NSString *path = [musicLibrary objectForKey:aMusicKey];
    
    // If the key is found log it and finish
    if(path != nil) {
        //NSLog(@"WARNING - SoundManager: Music with the key '%@' already exists.", aMusicKey);
        return;
    }
    
	path = [[NSBundle mainBundle] pathForResource:fileName ofType:fileType];
	if (!path) {
		//NSLog(@"WARNING - SoundManager: Cannot find file '%@.%@'", fileName, fileType);
		return;
	}
	
	[musicLibrary setObject:path forKey:aMusicKey];
   // NSLog(@"INFO - SoundManager: Loaded background music with key '%@'", aMusicKey);
}

- (void)removeMusicWithKey:(NSString*)aMusicKey {
    NSString *path = [musicLibrary objectForKey:aMusicKey];
    if(path == NULL) {
        //NSLog(@"WARNING - SoundManager: No music found with key '%@' was found so cannot be removed", aMusicKey);
        return;
    }
    [musicLibrary removeObjectForKey:aMusicKey];
    //NSLog(@"INFO - SoundManager: Removed music with key '%@'", aMusicKey);
}

- (void)addToPlaylistNamed:(NSString*)aPlaylistName track:(NSString*)aTrackName {

	NSString *path = [musicLibrary objectForKey:aTrackName];
	if (!path) {
		//NSLog(@"WARNING - SoundManager: Track '%@' does not exist in the music library and cannot be added to the play list.");
		return;
	}

	// See if the playlist already exists
	NSMutableArray *playlistTracks = [musicPlaylists objectForKey:aPlaylistName];
	
	BOOL newPlayList = NO;
	
	if (!playlistTracks) {
		newPlayList = YES;
		playlistTracks = [[NSMutableArray alloc] init];
	}
	
	[playlistTracks addObject:aTrackName];
	
	// Add the track key to the play list
	[musicPlaylists setObject:playlistTracks forKey:aPlaylistName];
	
	// If a new playlist was created then we can release it as its been added to the musicPlaylist
	// dictionary which has incremented the retain count.  If we are added to a playlist that already
	// existed then we don't want to release else it will be removed altogether.  Hence this check is performed.
	if (newPlayList)
		[playlistTracks release];
}

- (void)startPlaylistNamed:(NSString*)aPlaylistName {

	NSMutableArray *playlistTracks = [musicPlaylists objectForKey:aPlaylistName];
	
	if (!playlistTracks) {
		NSLog(@"WARNING - SoundManager: No play list exists with the name '%@'", aPlaylistName);
		return;
	}

	currentPlaylistName = aPlaylistName;
	currentPlaylistTracks = playlistTracks;
	usePlaylist = YES;
	playlistIndex = 0;
	
	[self playMusicWithKey:[playlistTracks objectAtIndex:playlistIndex] timesToRepeat:0];
}

- (void)removeFromPlaylistNamed:(NSString*)aPlaylistName track:(NSString*)aTrackName {

	// Find the tracks for the playlist provided
	NSMutableArray *playlistTracks = [musicPlaylists objectForKey:aPlaylistName];

	// If a playlist was found then loop through its tracks and remove the one with a matching
	// name to the one provided
	if (playlistTracks) {
		int indexToRemove;

		// Loop through the tracks in the playlist and set the indexToRemove variable to the index
		// of the entry that matches the track name.
		for (int index=0; index < [playlistTracks count]; index++) {
			if ([[playlistTracks objectAtIndex:index] isEqualToString:aTrackName]) {
				indexToRemove = index;
				break;
			}
		}

		// We have to remove the track from the dictionary outside of the loop as you are not able to
		// change a dictionary while looping through it's contents.
		[playlistTracks removeObjectAtIndex:indexToRemove];
	}
}

- (void)removePlaylistNamed:(NSString*)aPlaylistName {
	[musicPlaylists removeObjectForKey:aPlaylistName];
}

- (void)clearPlaylistNamed:(NSString*)aPlaylistName {
	NSMutableArray *playlistTracks = [musicPlaylists objectForKey:aPlaylistName];
	
	if (playlistTracks) {
		[playlistTracks removeAllObjects];
	}
}

#pragma mark -
#pragma mark Sound control

- (NSUInteger)playSoundWithKey:(NSString*)aSoundKey {
	return [self playSoundWithKey:aSoundKey gain:1.0f pitch:1.0f location:CGPointMake(0, 0) shouldLoop:NO];
}

- (NSUInteger)playSoundWithKey:(NSString *)aSoundKey location:(CGPoint)aLocation {
	return [self playSoundWithKey:aSoundKey gain:1.0f pitch:1.0f location:aLocation shouldLoop:NO];
}

- (NSUInteger)playSoundWithKey:(NSString*)aSoundKey gain:(float)aGain pitch:(float)aPitch location:(CGPoint)aLocation shouldLoop:(BOOL)aLoop {
	
	alError = alGetError(); // clear the error code
	
	// Find the buffer linked to the key which has been passed in
	NSNumber *numVal = [soundLibrary objectForKey:aSoundKey];
	if(numVal == nil) return 0;
	NSUInteger bufferID = [numVal unsignedIntValue];
	
	// Find the next available source
    NSUInteger sourceID;
    sourceID = [self nextAvailableSource];
	
	// If 0 is returned then no sound sources were available
	if (sourceID == 0) {
		NSLog(@"WARNING - SoundManager: No sound sources available to play %@", aSoundKey);
		return 0;
	}
	
	// Make sure that the source is clean by resetting the buffer assigned to the source
	// to 0
	alSourcei(sourceID, AL_BUFFER, 0);
    
	// Attach the buffer we have looked up to the source we have just found
	alSourcei(sourceID, AL_BUFFER, bufferID);
	
	// Set the pitch and gain of the source
	alSourcef(sourceID, AL_PITCH, aPitch);
	alSourcef(sourceID, AL_GAIN, aGain * fxVolume);
	
	// Set the looping value
	if(aLoop) {
		alSourcei(sourceID, AL_LOOPING, AL_TRUE);
	} else {
		alSourcei(sourceID, AL_LOOPING, AL_FALSE);
	}
   
	// Set the source location
	alSource3f(sourceID, AL_POSITION, aLocation.x, aLocation.y, 0.0f);
	
	// Now play the sound
	alSourcePlay(sourceID);

    // Check to see if there were any errors
	alError = alGetError();
	if(alError != 0) {
		NSLog(@"ERROR - SoundManager: %d", alError);
		return 0;
	}
    
	// Return the source ID so that loops can be stopped etc
	return sourceID;
}


- (void)stopSoundWithKey:(NSString*)aSoundKey {

	// Reset errors in OpenAL
	alError = alGetError();
	alError = AL_NO_ERROR;
	
    // Find the buffer which has been linked to the sound key provided
    NSNumber *numVal = [soundLibrary objectForKey:aSoundKey];
    
    // If the key is not found log it and finish
    if(numVal == nil) {
        NSLog(@"WARNING - SoundManager: No sound with key '%@' was found so cannot be stopped", aSoundKey);
        return;
    }
    
    // Get the buffer number from
    NSUInteger bufferID = [numVal unsignedIntValue];
	NSInteger bufferForSource;
	for(NSNumber *sourceID in soundSources) {
		
		NSUInteger currentSourceID = [sourceID unsignedIntValue];
		
		// Grab the buffer currently bound to this source
		alGetSourcei(currentSourceID, AL_BUFFER, &bufferForSource);
		
		// If the buffer matches the buffer we want to stop then stop the source and unbind it from the buffer
		if(bufferForSource == bufferID) {
			alSourceStop(currentSourceID);
			alSourcei(currentSourceID, AL_BUFFER, 0);
		}
	} 

	// Check for any errors
	//if((alError = alGetError()) != AL_NO_ERROR) {
		//NSLog(@"ERROR - SoundManager: Could not stop sound with key '%@' got error %x", aSoundKey, alError);
	//}
}


- (void)playMusicWithKey:(NSString*)aMusicKey timesToRepeat:(NSUInteger)aRepeatCount {
		
	NSError *error;
	
	NSString *path = [musicLibrary objectForKey:aMusicKey];
	
	if(!path) {
		//NSLog(@"ERROR - SoundManager: The music key '%@' could not be found", aMusicKey);
		return;
	}
	
	if(musicPlayer)
		[musicPlayer release];
	
	// Initialize the AVAudioPlayer using the path that we have retrieved from the music library dictionary
	musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
	
	// If the backgroundMusicPlayer object is nil then there was an error
	if(!musicPlayer) {
		//NSLog(@"ERROR - SoundManager: Could not play music for key '%d'", error);
		return;
	}
	
	// Set the delegate for this music player to be the sound manager
	musicPlayer.delegate = self;
	
	// Set the number of times this music should repeat.  -1 means never stop until its asked to stop
	[musicPlayer setNumberOfLoops:aRepeatCount];
	
	// Set the volume of the music
	[musicPlayer setVolume:currentMusicVolume];
	
	// Play the music
	[musicPlayer play];
	
	// Set the isMusicPlaying flag
	isMusicPlaying = YES;
}

- (void)playNextTrack {
	if (playlistIndex + 1 == [currentPlaylistTracks count]-1 && loopLastPlaylistTrack) {
		playlistIndex += 1;
		[self playMusicWithKey:[currentPlaylistTracks objectAtIndex:playlistIndex] timesToRepeat:-1];
	} else if (playlistIndex + 1 < [currentPlaylistTracks count]) {
		playlistIndex += 1;
		[self playMusicWithKey:[currentPlaylistTracks objectAtIndex:playlistIndex] timesToRepeat:0];
	} else if (loopPlaylist) {
		playlistIndex = 0;
		[self playMusicWithKey:[currentPlaylistTracks objectAtIndex:playlistIndex] timesToRepeat:0];
	}
}

- (void)stopMusic {
	[musicPlayer stop];
	isMusicPlaying = NO;
	usePlaylist = NO;
}

- (void)pauseMusic {
	[musicPlayer pause];
	isMusicPlaying = NO;
}

- (void)resumeMusic {
	[musicPlayer play];
	isMusicPlaying = YES;
}

#pragma mark -
#pragma mark SoundManager settings

- (void)setMusicVolume:(float)aVolume {

	// Set the volume iVar
	if (aVolume > 1)
		aVolume = 1.0f;

	currentMusicVolume = aVolume;
	musicVolume = aVolume;

	// Check to make sure that the audio player exists and if so set its volume
	if(musicPlayer)
		[musicPlayer setVolume:currentMusicVolume];
}

- (void)setFxVolume:(float)aVolume {
	fxVolume = aVolume;
}

- (void)setListenerPosition:(CGPoint)aPosition {
	listenerPosition = aPosition;
	alListener3f(AL_POSITION, aPosition.x, aPosition.y, 0.0f);
}

- (void)setOrientation:(CGPoint)aPosition {
    float orientation[] = {aPosition.x, aPosition.y, 0.0f, 0.0f, 0.0f, 1.0f};
    alListenerfv(AL_ORIENTATION, orientation);
}

- (void)fadeMusicVolumeFrom:(float)aFromVolume toVolume:(float)aToVolume duration:(float)aSeconds stop:(BOOL)aStop {

	// If there is already a fade timer active, invalidate it so we can start another one
	if (timer) {
		[timer invalidate];
		timer = NULL;
	}
	
	// Work out how much to fade the music by based on the current volume, the requested volume
	// and the duration
	fadeAmount = (aToVolume - aFromVolume) / (aSeconds / kFadeInterval); 
	currentMusicVolume = aFromVolume;

	// Reset the fades duration
	fadeDuration = 0;
	targetFadeDuration = aSeconds;
	isFading = YES;
	stopMusicAfterFade = aStop;
	
	// Set up a timer that fires kFadeInterval times per second calling the fadeVolume method
	timer = [NSTimer scheduledTimerWithTimeInterval:kFadeInterval target:self selector:@selector(fadeVolume:) userInfo:nil repeats:TRUE];
}

#pragma mark -
#pragma mark AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {

	if (!flag) {
		NSLog(@"ERROR - SoundManager: Music finished playing due to an error.");
		return;
	}
	
	isMusicPlaying = NO;

	// If we are using a play list then handle the next track to be played
	if (usePlaylist) {
		[self playNextTrack];
	}
}

#pragma mark -
#pragma mark AVAudioSessionDelegate

- (void)beginInterruption {
	[self setActivated:NO];
}

- (void)endInterruption {
	[self setActivated:YES];
}

@end

#pragma mark -
#pragma mark Private implementation

@implementation SoundManager (Private)

- (BOOL)initOpenAL {
    //NSLog(@"INFO - Sound Manager: Initializing sound manager");
	
	// Define how many OpenAL sources should be generated
	uint maxOpenALSources = 16;
    
	// Get the device we are going to use for sound.  Using NULL gets the default device
	device = alcOpenDevice(NULL);
	
	// If a device has been found we then need to create a context, make it current and then
	// preload the OpenAL Sources
	if(device) {
		// Use the device we have now got to create a context in which to play our sounds
		context = alcCreateContext(device, NULL);
        
		// Make the context we have just created into the active context
		alcMakeContextCurrent(context);
        
        // Set the distance model to be used
        alDistanceModel(AL_LINEAR_DISTANCE_CLAMPED);
        
		// Pre-create sound sources which can be dynamically allocated to buffers (sounds)
		NSUInteger sourceID;
		for(int index = 0; index < maxOpenALSources; index++) {
			// Generate an OpenAL source
			alGenSources(1, &sourceID);
            
            // Configure the generated source so that sounds fade as the player moves
            // away from them
            //alSourcef(sourceID, AL_REFERENCE_DISTANCE, 25.0f);
            //alSourcef(sourceID, AL_MAX_DISTANCE, 150.0f);
            //alSourcef(sourceID, AL_ROLLOFF_FACTOR, 6.0f);
            alSourcef(sourceID, AL_REFERENCE_DISTANCE, 25.0f);
            alSourcef(sourceID, AL_MAX_DISTANCE, 300.0f);
            alSourcef(sourceID, AL_ROLLOFF_FACTOR, 0.0f);
            
			// Add the generated sourceID to our array of sound sources
			[soundSources addObject:[NSNumber numberWithUnsignedInt:sourceID]];
		}
        
		// Set up the listener position, orientation and velocity to default values.  These can be changed at any
		// time.
		float listener_pos[] = {0, 0, 0};
		float listener_ori[] = {0.0, 1.0, 0.0, 0.0, 0.0, 1.0};
		float listener_vel[] = {0, 0, 0};
		alListenerfv(AL_POSITION, listener_pos);
		alListenerfv(AL_ORIENTATION, listener_ori);
		alListenerfv(AL_VELOCITY, listener_vel);
		
        //NSLog(@"INFO - Sound Manager: Finished initializing the sound manager");
		// Return YES as we have successfully initialized OpenAL
		return YES;
	}

	// We were unable to obtain a device for playing sound so tell the user and return NO.
    //NSLog(@"ERROR - SoundManager: Unable to allocate a device for sound.");
	return NO;
}

- (NSUInteger)nextAvailableSource {
	
	// Holder for the current state of the current source
	NSInteger sourceState;
	
	// Find a source which is not being used at the moment
	for(NSNumber *sourceNumber in soundSources) {
		alGetSourcei([sourceNumber unsignedIntValue], AL_SOURCE_STATE, &sourceState);
		// If this source is not playing then return it
		if(sourceState != AL_PLAYING) return [sourceNumber unsignedIntValue];
	}
	
	return 0;
}

#pragma mark -
#pragma mark Interruption handling

- (void)setActivated:(BOOL)aState {
    /*
    OSStatus result;
    
    if(aState) {
       // NSLog(@"INFO - SoundManager: OpenAL Active");
        
        // Set the AudioSession AudioCategory to what has been defined in soundCategory
		[audioSession setCategory:soundCategory error:&audioSessionError];
        if(audioSessionError) {
			NSLog(@"ERROR - SoundManager: Unable to set the audio session category");
            return;
        }
        
        // Set the audio session state to true and report any errors
		[audioSession setActive:YES error:&audioSessionError];
		if (audioSessionError) {
            //NSLog(@"ERROR - SoundManager: Unable to set the audio session state to YES with error %d.", result);
            return;
        }
		
		if (musicPlayer) {
			[musicPlayer play];
		}
        
        // As we are finishing the interruption we need to bind back to our context.
        alcMakeContextCurrent(context);
    } else {
       	NSLog(@"INFO - SoundManager: OpenAL Inactive");
        
        // As we are being interrupted we set the current context to NULL.  If this sound manager is to be
        // compaitble with firmware prior to 3.0 then the context would need to also be destroyed and
        // then re-created when the interruption ended.
        alcMakeContextCurrent(NULL);
    }*/
}

- (BOOL)isExternalAudioPlaying {
	UInt32 audioPlaying = 0;
	UInt32 audioPlayingSize = sizeof(audioPlaying);
	AudioSessionGetProperty(kAudioSessionProperty_OtherAudioIsPlaying, &audioPlayingSize, &audioPlaying);
	return (BOOL)audioPlaying;
}

- (void)fadeVolume:(NSTimer*)aTimer {
	fadeDuration += kFadeInterval;
	if (fadeDuration >= targetFadeDuration) {
		if (timer) {
			[timer invalidate];
			timer = NULL;
		}

		isFading = NO;
		if (stopMusicAfterFade) {
			[musicPlayer stop];
			isMusicPlaying = NO;
		}
	} else {
		currentMusicVolume += fadeAmount;
	}
	
	// If music is currently playing then set its volume
	if(isMusicPlaying) {
		[musicPlayer setVolume:currentMusicVolume];
	}
}

- (void)checkForErrors {
	alError = alGetError();
	if(alError != AL_NO_ERROR) {
		//NSLog(@"ERROR - SoundManager: OpenAL reported error '%d'", alError);
	}
}

@end

