//
//  AntiLostSensor.m
//  Anti-Lost
//
//  Created by Htedsv on 12-12-27.
//  Copyright (c) 2012年 htedsv. All rights reserved.
//

#define LOW -80
#define HIGH -60

#import "AntiLostSensor.h"
#import "BluetoothViewController.h"
#import "ConnectedViewController.h"

@interface AntiLostSensor () <CBCentralManagerDelegate, CBPeripheralDelegate>
@property (strong, nonatomic) CBCentralManager      *centralManager;
@property (strong, nonatomic) CBPeripheral          *discoveredPeripheral, *last;
@property (strong, nonatomic) CBCharacteristic          *alertLevel;
@property (strong, nonatomic) CBService          *alertSer;
@property (strong, nonatomic) NSMutableArray        *discoveredPeripherals;
@property (strong, nonatomic) BluetoothViewController      *vc;
@property (strong, nonatomic) ConnectedViewController      *vc2;

@end

@implementation AntiLostSensor

int alertType;
SInt8 tx_power;
int musicId;
@synthesize soundFileURLRef;
@synthesize soundFileObject;
bool connStatus;
bool distanceStatus;
int alertLevel;

- (void) handleTimer: (NSTimer *) timer
{
    if (_discoveredPeripheral.isConnected)
        [_discoveredPeripheral readRSSI];
}

- (id)init {
    self = [super init];
    if (self) {
        _centralManager = [[CBCentralManager alloc]initWithDelegate:self
                                                              queue:nil];
        _discoveredPeripherals = [[NSMutableArray alloc] init];
        [self startScan];
        connStatus = true;
        distanceStatus = true;
        
    }

    musicId = 1000;
    tx_power = 0;
    NSTimer *timer;
    timer = [NSTimer scheduledTimerWithTimeInterval: 2
                                             target: self
                                           selector: @selector(handleTimer:)
                                           userInfo: nil
                                            repeats: YES];
    connStatus = true;
    
    return self;
}
- (void)dealloc {
    [self stopScan];
}

+ (AntiLostSensor *)sharedInstance {
    static AntiLostSensor *_sharedInstance = nil;
    if (_sharedInstance == nil) {
        _sharedInstance = [[AntiLostSensor alloc] init];
    }
    
    return _sharedInstance;
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSString *messtoshow;
    UIAlertView * alertA;
    switch (central.state) {
        case CBCentralManagerStateUnknown:
        {
            messtoshow=[NSString stringWithFormat:@"State unknown, update imminent."];
            break;
        }
        case CBCentralManagerStateResetting:
        {
            messtoshow=[NSString stringWithFormat:@"The connection with the system service was momentarily lost, update imminent."];
            break;
        }
        case CBCentralManagerStateUnsupported:
        {
            messtoshow=[NSString stringWithFormat:@"The platform doesn't support Bluetooth Low Energy"];
            break;
        }
        case CBCentralManagerStateUnauthorized:
        {
            messtoshow=[NSString stringWithFormat:@"The app is not authorized to use Bluetooth Low Energy"];
            break;
        }
        case CBCentralManagerStatePoweredOff:
        {
            messtoshow=nil;
            break;
        }
        case CBCentralManagerStatePoweredOn:
        {
            messtoshow=nil;
            [self startScan];
            break;
        }
    }
    NSLog(messtoshow);
    if (messtoshow != nil)
    {
        alertA= [[UIAlertView alloc] initWithTitle:@"Error" message:messtoshow delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertA show];
    }
}

- (void)startScan
{
    [_discoveredPeripherals removeAllObjects];
    [self.vc.table reloadData];
    [_centralManager stopScan];
    [_centralManager  scanForPeripheralsWithServices:nil options:0];
}


- (void)stopScan {
    [_centralManager stopScan];
}


- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Peripheral Disconnected");
    self.last = self.discoveredPeripheral;
    //self.discoveredPeripheral = nil;
    [self startScan];
    [self.vc2 dismissModalViewControllerAnimated:YES];
    [self.vc reload];
    [self.vc.table reloadData];
    
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Message"
                                                   message:@"Your device is disconnected."
                                                  delegate:self
                                         cancelButtonTitle:@"ok"
                                         otherButtonTitles:nil];
    [alert show];
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{NSLog(@"didUpdateNotificationStateForCharacteristic");}


- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"ErrorWrite: %@", error);
}
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"recall: %d", peripheral.RSSI.integerValue);
    if (peripheral.RSSI.integerValue < LOW && distanceStatus && alertLevel == 2)
    {
        [self alert];
        [self localAlert];
    }
    else if (peripheral.RSSI.integerValue < HIGH && alertLevel > 0 && distanceStatus )
    {
        [self vibrate];
        [self localAlert];
    }

}



- (void)localAlert
{
    AudioServicesPlaySystemSound(musicId);    
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"Discovered %@ at %d", peripheral.name, RSSI.integerValue);
    if (RSSI.integerValue > -15) return;
    
    if( ![_discoveredPeripherals containsObject:peripheral] )
    {
        [_discoveredPeripherals addObject:peripheral];
        [self.vc.table reloadData];
    }

    
}

- (void) peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A07"]])
    {
        NSData * updatedValue = characteristic.value;
        SInt8 * dataPointer = (SInt8*)[updatedValue bytes];
        tx_power = *dataPointer;
        NSLog(@"New value: %d", tx_power);
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A06"]])
    {
        uint8_t alarmValue  = 0;
        [[characteristic value] getBytes:&alarmValue length:sizeof (alarmValue)];
        NSLog(@"readValue: %d", alarmValue);
    }

}
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]);
    [self startScan];
    [self.vc.table reloadData];
    [self.vc2 dismissModalViewControllerAnimated:YES];
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral
{
    [aPeripheral setDelegate:self];
    [aPeripheral discoverServices:nil];
    self.discoveredPeripheral = aPeripheral;
    [self.vc createConnectedView];
}


- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    //:
    if([service.UUID isEqual:[CBUUID UUIDWithString:@"1802"]])
    {
        for (CBCharacteristic * characteristic in service.characteristics)
        {
            [_discoveredPeripheral setNotifyValue:YES forCharacteristic:characteristic];
            //2A06: Alert Level , 0:“No Alert”, 1:“Mild Alert”, 2:“High Alert”
            
            if([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A06"]])
                _alertLevel = characteristic;
            
        }
    }
    //tx_power
    if([service.UUID isEqual:[CBUUID UUIDWithString:@"1804"]])
    {
        for (CBCharacteristic * characteristic in service.characteristics)
        {
            if([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A07"]])
            {
                [aPeripheral readValueForCharacteristic:characteristic];
            }
        }

    }
    //lose_link
    if([service.UUID isEqual:[CBUUID UUIDWithString:@"1803"]])
    {
        for (CBCharacteristic * characteristic in service.characteristics)
        {
            NSLog(@"Lose Link:%@",characteristic.UUID);
            /*
            if([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A07"]])
            {
                [aPeripheral readValueForCharacteristic:characteristic];
            }*/
        }
        
    }
}
- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error
{
    for (CBService *aService in aPeripheral.services)
    {
        
        /* Immediate Alert */
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"1802"]])
        {
            _alertSer = aService;
            [aPeripheral discoverCharacteristics:nil forService:aService];
        }
        
        /* tx_power */
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"1804"]])
        {
            [aPeripheral discoverCharacteristics:nil forService:aService];
        }
        
        /* GAP (Generic Access Profile) for Device Name */
        if ( [aService.UUID isEqual:[CBUUID UUIDWithString:CBUUIDGenericAccessProfileString]] )
        {
            [aPeripheral discoverCharacteristics:nil forService:aService];
        }
        
    }
}
-(void) alertService
{
    uint8_t val = alertType;
    NSData* data = [NSData dataWithBytes:(void*)&val length:sizeof(val)];
    [_discoveredPeripheral writeValue:data forCharacteristic:_alertLevel type:CBCharacteristicWriteWithoutResponse];
}
-(void)alert
{
    alertType = 2;
    [self alertService];
}
- (void)vibrate
{
    alertType = 1;
    [self alertService];
}
-(void)stopAlert
{
    alertType = 0;
    [self alertService];
}
-(NSMutableArray *) getDevices
{
    [self startScan];
    return _discoveredPeripherals;
}
-(void) setViewController:(UIViewController *)controller
{
    self.vc = controller;
}
-(void) setViewController2:(UIViewController *)controller
{
    self.vc2 = controller;
}


-(Boolean)connect:(int)index
{
    CBPeripheral* p = [_discoveredPeripherals objectAtIndex:index];
    [p setDelegate:self];
    [_centralManager connectPeripheral:p options:nil];
    return TRUE;

}
-(void)changeDistanceStatus:(BOOL)status
{
    distanceStatus = status;
    NSLog(@"%@", distanceStatus);
}
-(void)changeDistanceLevel:(NSInteger)level
{
    alertLevel = level;
}

-(void)disconnect{[_centralManager cancelPeripheralConnection:self.discoveredPeripheral];}
-(void)setMusicId:(int)mid{musicId = mid;}
-(void) setConnStatus:(BOOL)b{connStatus = b;}
-(BOOL) getConnStatus{return connStatus;}

@end
