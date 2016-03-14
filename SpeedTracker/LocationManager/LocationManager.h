//
//  LocationManager.h
//  SpeedTracker
//
//  Created by Bao (Brian) L. LE on 3/14/16.
//  Copyright © 2016 Brian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@protocol LocationManagerDelegate;

@interface LocationManager : NSObject<CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
    id delegate;
}

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) id delegate;

@end

//*****************************************************************************
#pragma mark -
#pragma mark - ** Location Manager Delegate **
/*
 * Location Delegate
 */
@protocol LocationManagerDelegate
@required
- (void)locationUpdate:(CLLocation *)location; // Our location updates are sent here
- (void)locationError:(NSError *)error; // Any errors are sent here
@end
