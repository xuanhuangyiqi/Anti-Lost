//
//  AntiLostSensor.h
//  Anti-Lost
//
//  Created by Htedsv on 12-12-27.
//  Copyright (c) 2012年 htedsv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BluetoothViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>



@class AntiLostSensor;


@interface AntiLostSensor : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>
{
    AVAudioPlayer *player;
}

- (void) startScan;
- (void) stopScan;
-(NSMutableArray *) getDevices;
+ (AntiLostSensor *)sharedInstance;
-(void)alert;
-(void)stopAlert;
-(Boolean)connect:(int)index;
-(void)disconnect;
-(void)setMusicId:(int)mid;
-(void) setViewController:(BluetoothViewController *)controller;
-(void) setViewController2:(BluetoothViewController *)controller;
-(void) setConnStatus:(BOOL)b;
-(BOOL) getConnStatus;
-(void) changeDistanceStatus:(BOOL)status;
-(void) changeDistanceLevel:(NSInteger)level;
@property (readwrite)	CFURLRef		soundFileURLRef;
@property (readonly)	SystemSoundID	soundFileObject;

@end
