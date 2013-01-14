//
//  ConnectedViewController.h
//  Anti-Lost
//
//  Created by Htedsv on 12-12-27.
//  Copyright (c) 2012年 htedsv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AntiLostSensor.h"


@interface ConnectedViewController : UIViewController
@property (strong, nonatomic) IBOutlet UISegmentedControl *alertLevel;
- (IBAction)dis:(id)sender;
- (IBAction)alert:(id)sender;
- (IBAction)stopAlert:(id)sender;
- (IBAction)settings:(id)sender;
- (IBAction)distanceAlert:(id)sender;
- (IBAction)levelAlert:(id)sender;


@end
