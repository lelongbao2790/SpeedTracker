//
//  LocationManager.m
//  SpeedTracker
//
//  Created by Bao (Brian) L. LE on 3/14/16.
//  Copyright © 2016 Brian. All rights reserved.
//

#import "LocationManager.h"

@implementation LocationManager
@synthesize delegate, locationManager;

//*****************************************************************************
#pragma mark -
#pragma mark - ** Life Cycle **
- (id)init {
    self = [super init];
    
    if(self != nil) {
//        self.locationManager = [[CLLocationManager alloc] init]; // Create new instance of locationManager
//        self.locationManager.delegate = self; // Set the delegate as self.
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        [self.locationManager startUpdatingLocation];
    }
    
    return self;
}

//*****************************************************************************
#pragma mark -
#pragma mark - ** CLLocationManager Delegate  **
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if([self.delegate conformsToProtocol:@protocol(LocationManagerDelegate)]) {  // Check if the class assigning itself as the delegate conforms to our protocol.  If not, the message will go nowhere.  Not good.
        [self.delegate locationUpdate:newLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if([self.delegate conformsToProtocol:@protocol(LocationManagerDelegate)]) {  // Check if the class assigning itself as the delegate conforms to our protocol.  If not, the message will go nowhere.  Not good.
        [self.delegate locationError:error];
    }
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
        {
            // do some error handling
        }
            break;
        default:{
            [self.locationManager startUpdatingLocation];
        }
            break;
    }
}

@end
