//
//  Menu.h
//  Eve of Impact
//
//  Created by Rik Schennink on 5/1/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "Control.h"
#import "Button.h"
#import "Label.h"
#import "Clip.h"
#import "ApplicationModel.h"
#import <Twitter/Twitter.h>

@interface Menu : Control {
	
	ApplicationModel* model;
	
	Button* play;
	Button* resume;
	Button* retry;
	Button* exit;
	Button* scores;
	Button* edit;
	Button* tutorial;
	Button* leaderboards;
	Button* achievements;
	Button* share;
	Label* user;
	
	int slotA;
	int slotB;
	int slotC;
	
	Clip* title;
	Clip* author;
	
	QuadTemplate labelUsername;
	
}

@property (nonatomic,retain) Label* user;

-(id)initWithModel:(ApplicationModel*)applicationModel;

@end
