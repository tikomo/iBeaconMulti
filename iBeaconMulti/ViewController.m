//
//  ViewController.m
//  iBeaconMulti
//
//  Created by KomoritaTsuyoshi on 2016/08/27.
//  Copyright © 2016年 KomoritaTsuyoshi. All rights reserved.
//

#import "ViewController.h"

#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>

@interface ViewController () <CLLocationManagerDelegate> {

    CLLocationManager *_locationManager;

}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _locationManager = [[CLLocationManager alloc] init];
    
    // ②位置情報サービスのON/OFFで挙動を分岐
    //if ([CLLocationManager locationServicesEnabled]) {
        // ③locationManagerの各プロパティを設定
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        _locationManager.activityType = CLActivityTypeFitness;
        _locationManager.pausesLocationUpdatesAutomatically = NO;
        _locationManager.distanceFilter = 10.0;
        // ④位置情報の取得開始
        [_locationManager startUpdatingLocation];
    //} else {
    //    NSLog(@"Location services not available.");
    //}

    
    // NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:@"C768FFC6-B7C4-4079-8EC7-9094AAA19782"];
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:@"C768FFC6-B7C4-4079-8EC7-9094AAA19782"];
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:@"hoge"];
    [_locationManager startRangingBeaconsInRegion:beaconRegion];
    NSLog(@"%@", _locationManager.rangedRegions);
    
    proximityUUID = [[NSUUID alloc] initWithUUIDString:@"3C9079D9-7246-4DF5-9555-1A32908CB220"];
    beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:@"fuga"];
    [_locationManager startRangingBeaconsInRegion:beaconRegion];
    NSLog(@"%@", _locationManager.rangedRegions);
    
    // [_locationManager requestWhenInUseAuthorization]; // iOS8から必要 アプリ起動中のみ許可
    [_locationManager requestAlwaysAuthorization]; // iOS8から必要 アプリ起動中&裏も許可
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"viewDidAppear - ここでstartRangingBeaconsInRegionをしている");

}

- (void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
}

// 位置情報更新時
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
    // ログを出力
    NSLog(@"didUpdateToLocation latitude=%f, longitude=%f, accuracy=%f, time=%@",
          [newLocation coordinate].latitude,
          [newLocation coordinate].longitude,
          newLocation.horizontalAccuracy,
          newLocation.timestamp);
}


#pragma mark - CLLocationManagerDelegate protocol method
- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    NSLog(@"%s, %@", __PRETTY_FUNCTION__, error);
}


// ユーザの位置情報の許可状態を確認するメソッド
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

// 指定した領域に入った場合
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"didEnterRegion");
}

// 指定した領域から出た場合
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"didExitRegion");
}

// iBeacon領域内に既にいるか/いないかの判定
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    switch (state) {
        case CLRegionStateInside:
            if([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]){
            }
            break;
        case CLRegionStateOutside:
            if([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]){
            }
            break;
        case CLRegionStateUnknown:
            if([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]){
            }
            break;
        default:
            break;
    }
}

// Beacon信号を検出した場合
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{

    // ここからは検出したビーコンの情報をWebServiceへ
    
    NSLog(@"Beacon NUM = %ld", beacons.count);
    
    if (beacons.count > 0) {
        
        for(CLBeacon *beacon in beacons){
            
            NSString *wkProximity = @"Unknown";
            
            if (beacon.proximity == CLProximityImmediate){
                // 至近
                wkProximity = @"Immediate";
            } else if (beacon.proximity == CLProximityNear) {
                // 近くにあるよ
                wkProximity = @"Near";
            } else if (beacon.proximity == CLProximityFar) {
                // 遠くにあります
                wkProximity = @"Far";
            } else {
                // 不明
                wkProximity = @"Unknown";
            }
            
            CLLocation *location = [_locationManager location];
            CLLocationCoordinate2D coordinate = [location coordinate];

            
            NSString *wkStr = [NSString stringWithFormat:@"{\"uuid\":\"%@\",\"major\":\"%d\",\"minor\":\"%d\",\"proximity\":\"%@\",\"rssi\":\"%ld\",\"acc\":\"%.2f\",\"lat\":\"%f\",\"long\":\"%f\"}",
                               [beacon.proximityUUID UUIDString],
                               [beacon.major intValue],
                               [beacon.minor intValue],
                               wkProximity,
                               (long)beacon.rssi,
                               beacon.accuracy,
                               coordinate.latitude,
                               coordinate.longitude
                               ];

            
            NSLog(@"%@", wkStr);
        }
    }

    /*
    
    if (beacons.count > 0) {
        
        // 一番近くのビーコンの情報を表示
        
        nearestBeacon = beacons.firstObject;
        NSString *rangeMessage;
        
        switch(nearestBeacon.proximity) {
            case CLProximityImmediate:
                rangeMessage = @"Range Immediate";
                break;
            case CLProximityNear:
                rangeMessage = @"Range Near";
                break;
            case CLProximityFar:
                rangeMessage = @"Range Far";
                break;
            default:
                rangeMessage = @"Range Unknown";
                break;
        }
        
        NSString *str= [[NSString alloc] initWithFormat:@"%f [m]", nearestBeacon.accuracy];
        
        NSLog(@"%@", str);
        
        //[self sendLocalNotificationForMessage:str];
    }
     */

}

// ローカルプッシュ
/*
- (void)sendLocalNotificationForMessage:(NSString *)message
{
    UILocalNotification *localNotification = [UILocalNotification new];
    localNotification.alertBody = message;
    localNotification.fireDate = [NSDate date];
    localNotification.soundName = nil;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}
*/

@end
