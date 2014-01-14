//
//  Impactable.h
//  Eve of Impact
//
//  Created by Rik Schennink on 6/30/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImpactActor.h"

@protocol Impactable <NSObject>

-(void)bindImpact:(ImpactActor*)impact;

-(void)clearImpacts;

@end
