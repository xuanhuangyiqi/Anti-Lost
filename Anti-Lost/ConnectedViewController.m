//
//  ConnectedViewController.m
//  Anti-Lost
//
//  Created by Htedsv on 12-12-27.
//  Copyright (c) 2012年 htedsv. All rights reserved.
//

#import "ConnectedViewController.h"
#import "SettingsViewController.h"


@interface ConnectedViewController ()

@end

@implementation ConnectedViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    AntiLostSensor *a = [AntiLostSensor sharedInstance];
    if ([a getConnStatus] == FALSE)
    {
        [a setConnStatus:TRUE];
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)viewDidUnload{
    [self setAlertLevel:nil];
    [self setSw:nil];
[super viewDidUnload];}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)dis:(id)sender
{
    [[AntiLostSensor sharedInstance] disconnect];
    [self dismissModalViewControllerAnimated:YES];

}

- (IBAction)alert:(id)sender {
    [[AntiLostSensor sharedInstance] alert];
}

- (IBAction)stopAlert:(id)sender {
    [[AntiLostSensor sharedInstance] stopAlert];
}

- (IBAction)settings:(id)sender {
    SettingsViewController *vc = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    [self presentModalViewController:vc animated:YES];
}

- (IBAction)distanceAlert:(id)sender {
    [[AntiLostSensor sharedInstance] changeDistanceStatus: self.sw.on];
}

- (IBAction)levelAlert:(id)sender {
    [[AntiLostSensor sharedInstance] changeDistanceLevel:self.alertLevel.selectedSegmentIndex];
    
}

@end
