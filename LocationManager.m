//
//  LocationManager.m
//  Jarvis
//
//  Created by Joel Green on 1/24/14.
//  Copyright (c) 2014 Joel Green. All rights reserved.
//

#import "LocationManager.h"


@interface LocationManager () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSInteger locationErrorCode;

@end

@implementation LocationManager

- (void)updateLocation
{
    [self.locationManager startUpdatingLocation];
}


//- (void)viewWillDisappear:(BOOL)animated
//{
//    [self.locationManager stopUpdatingLocation];
//}

#pragma mark - location management

- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        CLLocationManager *locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager = locationManager;
    }
    return _locationManager;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.location = [locations lastObject];
    [self.locationManager stopUpdatingLocation];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Location Updated" object:self];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    self.locationErrorCode = error.code;
}




@end
