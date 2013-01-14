//
//  BluetoothViewController.h
//  Anti-Lost
//
//  Created by Htedsv on 12-12-27.
//  Copyright (c) 2012年 htedsv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BluetoothViewController : UIViewController
- (IBAction)startScan:(id)sender;
- (void)reload;
- (void) createConnectedView;
@property (strong, nonatomic) IBOutlet UITableView *table;
@end
