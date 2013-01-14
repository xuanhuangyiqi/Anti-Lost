//
//  SettingsViewController.m
//  Anti-Lost
//
//  Created by Htedsv on 12-12-28.
//  Copyright (c) 2012年 htedsv. All rights reserved.
//
#import "AntiLostSensor.h"
#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController
@synthesize table;
NSMutableArray *data;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"songs" ofType:@"plist"];
    data = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
}

- (void)viewDidUnload
{
    [self setTable:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma Table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{return 1;}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [data count]; }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    //NSString *content = [[array objectAtIndex:row] objectForKey:@"content"];
    
    NSMutableArray *item = [data objectAtIndex:[indexPath row]];
    cell.textLabel.text = [item objectAtIndex:1];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *item = [data objectAtIndex:[indexPath row]];
    NSString *music_id = [item objectAtIndex:0];
    [[AntiLostSensor sharedInstance] setMusicId:[music_id integerValue]];
    [self dismissModalViewControllerAnimated:YES];
}


- (IBAction)back:(id)sender {
    [self dismissModalViewControllerAnimated:YES];

}
@end
