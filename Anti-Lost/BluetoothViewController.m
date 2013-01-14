//
//  BluetoothViewController.m
//  Anti-Lost
//
//  Created by Htedsv on 12-12-27.
//  Copyright (c) 2012年 htedsv. All rights reserved.
//

#import "BluetoothViewController.h"
#import "ConnectedViewController.h"
#import "AntiLostSensor.h"


@interface BluetoothViewController ()
@property (strong, nonatomic) NSMutableArray * devices;
@end

@implementation BluetoothViewController
@synthesize table;

int discoverNumbers;

- (void)viewDidLoad
{
    discoverNumbers = 0;
    [super viewDidLoad];
    [self reload];
    
}
- (void)reload
{
    AntiLostSensor *sensor = [AntiLostSensor sharedInstance];
    [sensor setViewController:self];
    _devices = [sensor getDevices];
   // [self.table reloadData];
}
- (void)viewDidUnload
{
    [self setTable:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma Table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{return 1;}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_devices count];}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    //NSString *content = [[array objectAtIndex:row] objectForKey:@"content"];
    
    CBPeripheral *p = [_devices objectAtIndex:indexPath.row];
    
    cell.textLabel.text = p.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AntiLostSensor *sensor = [AntiLostSensor sharedInstance];
    [sensor connect:indexPath.row];
}

- (IBAction)startScan:(id)sender
{
    [[AntiLostSensor sharedInstance] startScan];
    [self reload];
}

- (void) createConnectedView
{
    AntiLostSensor *sensor = [AntiLostSensor sharedInstance];
    ConnectedViewController *connected = [[ConnectedViewController alloc] initWithNibName:@"ConnectedViewController" bundle:nil];
    [self presentModalViewController:connected animated:YES];
    [sensor setViewController2:connected];
}

@end
