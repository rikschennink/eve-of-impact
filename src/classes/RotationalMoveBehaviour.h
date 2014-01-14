//
//  RotationalMoveBehaviour.h
//  Eve of Impact
//
//  Created by Rik Schennink on 2/15/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MoveBehaviourBase.h"

@interface RotationalMoveBehaviour : MoveBehaviourBase {

@private
	
	float distance;
	float offset;
	float speed;
	
}

-(id)initAndRotateAtDistance:(float)d 
				  withOffset:(float)o 
					 atSpeed:(float)s;

@end
