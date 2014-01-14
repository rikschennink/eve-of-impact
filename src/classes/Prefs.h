

#import <Foundation/Foundation.h>
#import "Common.h"

extern Color const COLOR_INTERFACE;
extern Color const COLOR_INTERFACE_MASK;
extern Color const ASTEROID_BURN_COLOR;
extern Color const ASTEROID_BURN_COLOR_ALT;




// boards
#define LEADER_BOARD_UID 							@"1"


// twitter
//#define TWITTER_URL		 @"http://eveofimpact.com"
#define TWITTER_MESSAGE	 @"Broadcast to %@ survivors: Earth has been lost, it's up to us to find a new home. #eveofimpact"
#define TWITTER_PIC		 @"gameover.png"

// game tick rate
#define TICK_RATE					25

#define IS_IPAD						(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE					(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA					([UIScreen mainScreen].scale > 1.0)



// media
#define SCREENSHOT_MODE				false	// false

// sound
#define MUSIC_ENABLED				true	// true
#define SFX_ENABLED					true	// true
#define MAX_OPENAL_SOURCES			16 		// iPhone MAX == 32
#define MAX_MUSIC_VOLUME			.5

// game difficulty levels
#define INTRO 						0
#define EASY 						1
#define MEDIUM 						2
#define HARD 						3
#define INSANE 						4

// planet
#define PLANET_RADIUS				26.0
#define PLANET_MASS					.4

// moon
#define MOON_RADIUS					8.0
#define MOON_MASS					.1
#define MOON_MAX_HITS				5


// max explosion fragments
#define EXPLOSION_SHARD_LIMIT				16
#define EXPLOSION_WEAKEN_DISTANCE_SQUARED   10000.0

// max highscores
#define LOCAL_HIGH_SCORE_MAX		9
#define GLOBAL_HIGH_SCORE_MAX		100

// actors
#define ACTOR_REMOVAL_DISTANCE_SQUARED		360000.0 	// = 600 * 600

// asteroid
#define ASTEROID_SPAWN_DISTANCE				700.0 		// = 490.000
#define ASTEROID_DETECTION_DISTANCE_SQUARED	220000.0 	// = +/- 550 * 550
#define ASTEROID_WARNING_DISTANCE_SQUARED	30000.0
#define ASTEROID_IMPACT_DISTANCE_SQUARED	5000.0 		// distance when impact is a possibility
#define ASTEROID_IMPACT_RANGE_SQUARED		900.0
#define ASTEROID_BURN_DISTANCE_SQUARED		6000.0 		// when is the asteroid going to heat up from friction with the planet
#define ASTEROID_TARGET_FUZZINESS			50.0
#define ASTEROID_HARMLESS_RADIUS			.5
#define ASTEROID_MIN_RADIUS					1.0
#define ASTEROID_MAX_RADIUS					4.0
#define ASTEROID_VELOCITY					1.15
#define ASTEROID_VELOCITY_RANGE	 			.25


// shield
#define SHIELD_INITIAL_ENERGY		1.0 				// default = 1.0
#define SHIELD_RANGE				44.0
#define SHIELD_CHARGE_STEP			.00015
#define SHIELD_ENERGY_WEAK			.332
#define SHIELD_OVERLOAD_ENERGY		.332
#define SHIELD_OVERLOAD_DURATION	48 					// 2 seconds
#define SHIELD_SHOCKWAVE_LIFESPAN	48
#define SHIELD_SHOCKWAVE_RANGE		240.0

// satellite cooldown
#define SATELLITE_DISTANCE			50.0
#define SATELLITE_COOLDOWN			.4

// missile
#define MISSILE_VELOCITY			8.0 // 8.0

// shuttle
#define SHUTTLE_BOARDING_DURATION			12.5 	// in seconds
#define SHUTTLE_PANIC_PENALTY				10
#define SHUTTLE_PANIC_RECOVERY_SPEED		1
#define SHUTTLE_MAX_PANIC_DELAY				100
#define SHUTTLE_INITIAL_AMOUNT				1
#define SHUTTLE_MAX_CAPACITY				500
#define SHUTTLE_LAUNCH_RANGE				20.0
#define SHUTTLE_TARGET_DISTANCE				1600.0
#define SHUTTLE_MAX_SPEED					.75 				
#define SHUTTLE_EXPLOSION_PUSH_RADIUS		28.0
#define SHUTTLE_EXPLOSION_FRAGMENT_RADIUS	24.0
#define SHUTTLE_EXPLOSION_LIFE_SPAN			9
#define SHIP_MAX_SPEED						1.0				
#define SHIP_CAPACITY_FIRST					3000					
#define SHIP_CAPACITY_STEP					1500


// score increment
#define SCORE_INITIAL_SPEED             1.1
#define SCORE_INCREASE_SPEED            11.111
#define SCORE_INCREASE_SPEED_MIN        .001
#define SCORE_RECOVERY_SPEED            .05
#define SCORE_SLOW_PENALTY              1.31
#define SCORE_STACK_RECOVERY_SPEED      .1
#define SCORE_STACK_MAX                 9.99
#define SCORE_FALLBACK_SPEED            50.0
#define SCORE_SPAM_DISTANCE				1500


// particle settings
#define PARTICLE_DROP				24
#define PARTICLE_LIMIT				2000
#define PARTICLE_OPACITY_MAX		.25 // .25 // max opacity for non burning particles
#define IMPACT_PARTICLE_LIFESPAN	90
#define ASTEROID_PARTICLE_LIFESPAN	50
#define SHUTTLE_PARTICLE_LIFESPAN	40
#define EXPLOSION_PARTICLE_LIFESPAN	30
#define SHUTTLE_EXPLOSION_PARTICLE_LIFESPAN 40
#define DEBREE_PARTICLE_LIFESPAN	25
#define PLANET_DEBREE_PARTICLE_LIFESPAN	15
#define ESCAPE_POD_PARTICLE_LIFESPAN 20


// camera
#define CAMERA_WOBBLE_MAX_H			8.0
#define CAMERA_WOBBLE_MAX_V			16.0
#define CAMERA_WOBBLE_SPEED			.01 
#define CAMERA_SHAKE_DELAY			.5
#define CAMERA_SHAKE_BUILD			4.0
#define CAMERA_SHAKE_FADE			.5
#define CAMERA_SHAKE_LIMIT			5

#define CAMERA_RANGE				225
#define CAMERA_RANGE_SQUARED		50625
#define CAMERA_ARTIFACT_COUNTDOWN	32

#define NUKE_PUSH_RADIUS			80.0
#define NUKE_PUSH_FORCE				1.25
#define NUKE_FRAGMENT_RADIUS		16.5 // was 15.0
#define NUKE_LIFE_SPAN				31


// action request types
#define ACTION_NONE					0
#define ACTION_HOLD					1
#define ACTION_RELEASE				2
#define ACTION_TAP					3
#define ACTION_CHARGE_WMD			4

// game stateSTATE_MENU_GAMEOVER
#define STATE_PLAYING				0
#define STATE_TITLE					1
#define STATE_INTRO					2
#define STATE_MENU_MAIN				3
#define STATE_MENU_PAUSE			4
#define STATE_GAMEOVER				5
#define STATE_MENU_GAMEOVER			6
#define STATE_HIGHSCORE_BOARD		7
#define STATE_TUTORIAL				8

// actor state
#define STATE_SLEEPING				0
#define STATE_WAKING_UP				1
#define STATE_ALIVE					2
#define STATE_DYING					3
#define STATE_DEAD					4
#define STATE_INVULNERABLE			5
#define STATE_LEAVING				6
#define STATE_ATTENTION				7
#define STATE_DETECTED				8
#define STATE_WARNING				9
#define STATE_PUSHED				10
#define STATE_LEFT					11
#define STATE_VAPORIZING			12
#define STATE_EMPTY					100

// max states
#define ACTOR_MAX_STATES			20

// prompts
#define PROMPT_DURATION				8 // seconds
#define PROMPT_NONE					0
#define PROMPT_PAUSE				1

#define PAUSE_ALERT_TICKS			400   	// 0.15 minutes


// gui stuff
#define BUTTON_ORIENTATION_LEFT		0
#define BUTTON_ORIENTATION_RIGHT	1
#define BUTTON_MARGIN				2.0
#define BUTTON_PADDING				2.0
#define BUTTON_SIZE					72.0
#define BUTTON_SIZE_HALF			36.0
#define BUTTON_BAR_WIDTH			8.0
#define BUTTON_OFFSET				10.0

// graphic stuff
#define SHOCKWAVE_RADIUS_LIFE_RATIO	0.125

// texture stuff
#define TEXTURE_DEFAULT				0
#define TEXTURE_INTERFACE			1
#define TEXTURE_INTERFACE_BLURRED   2
#define TEXTURE_SCANLINES			3
#define TEXTURE_PARTICLE			4
#define TEXTURE_PLANET_VISUAL		5
#define TEXTURE_SHOCKWAVE_VISUAL	6
#define TEXTURE_SHIELD_VISUAL		7
#define TEXTURE_INTERFACE_VISUAL	8

// renderengine stuff
#define VBO_DEFAULT					0
#define VBO_ALT						1
#define VBO_STATIC_SPACE			2
#define VBO_STATIC_PLANET			3
#define VBO_STATIC_PLANET_DESTROYED	4

#define FBO_DEFAULT					0
#define FBO_PLANET_DESTROYED		1
#define FBO_PLANET_SHOCKWAVE		2
#define FBO_INTERFACE				3

// renderengine stuff
#define INDICATOR_TOP				0
#define INDICATOR_RIGHT				1
#define INDICATOR_BOTTOM	 		2
#define INDICATOR_LEFT				3


