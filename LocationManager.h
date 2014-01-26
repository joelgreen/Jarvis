//
//  LocationManager.h
//  Jarvis
//
//  Created by Joel Green on 1/24/14.
//  Copyright (c) 2014 Joel Green. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManager : NSObject

@property (strong, nonatomic) CLLocation *location;

- (void)updateLocation;

@end
