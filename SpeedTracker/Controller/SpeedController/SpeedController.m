//
//  SpeedController.m
//  SpeedTracker
//
//  Created by Bao (Brian) L. LE on 3/14/16.
//  Copyright © 2016 Brian. All rights reserved.
//

#import "SpeedController.h"

@interface SpeedController () {
    int stepCount;
}

@property (strong, nonatomic) LocationManager *locationManager;
@property (assign, nonatomic) float maxSpeed;

@property (weak, nonatomic) IBOutlet UILabel *lbMaxSpeed;
@property (weak, nonatomic) IBOutlet UILabel *lbAverageSpeed;
@property (weak, nonatomic) IBOutlet UILabel *lbSpeedNumber;
@property (weak, nonatomic) IBOutlet UILabel *lbStatus;
@property (weak, nonatomic) IBOutlet UIButton *btnMph;
@property (weak, nonatomic) IBOutlet UIButton *btnKmh;
@property (weak, nonatomic) IBOutlet MarqueeLabel *lbStepWalking;
@end

@implementation SpeedController {
    CLLocationDistance _distance;
    CLLocation *_lastLocation;
    NSDate *_startDate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self config];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initVariable {
    _distance = 0;
    _lastLocation = nil;
    _startDate = nil;
    self.maxSpeed = 0;
}

- (void)config {
    
    // Init
    [self initVariable];
    
    [SOMotionDetector sharedInstance].motionTypeChangedBlock = ^(SOMotionType motionType) {
        NSString *type = @"";
        switch (motionType) {
            case MotionTypeNotMoving:
                type = @"Not moving";
                break;
            case MotionTypeWalking:
                type = @"Walking";
                break;
            case MotionTypeRunning:
                type = @"Running";
                break;
            case MotionTypeAutomotive:
                type = @"Automotive";
                break;
        }
        
        self.lbStatus.text = type;
    };
    
    [SOMotionDetector sharedInstance].locationChangedBlock = ^(CLLocation *location) {
        self.lbSpeedNumber.text = [NSString stringWithFormat:@"%.2f",[SOMotionDetector sharedInstance].currentSpeed];
        [self caculateAverageSpeed:NO andLocation:location];
        [self showAddress:location];
        
    };
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [SOMotionDetector sharedInstance].useM7IfAvailable = YES; //Use M7 chip if available, otherwise use lib's algorithm
    }
    
    //This is required for iOS > 9.0 if you want to receive location updates in the background
    [SOLocationManager sharedInstance].allowsBackgroundLocationUpdates = YES;
    
    //Starting motion detector
    [[SOMotionDetector sharedInstance] startDetection];
    
    //Starting pedometer
    [[SOStepDetector sharedInstance] startDetectionWithUpdateBlock:^(NSError *error) {
        if (error) {
            NSLog(@"%@", error.localizedDescription);
            return;
        }
        
        stepCount++;
        
    }];
}

- (void)caculateAverageSpeed:(BOOL)isKmh andLocation:(CLLocation *)location {
    if ([self.lbSpeedNumber.text doubleValue] > 0) {
        
        if (self.maxSpeed <= [self.lbAverageSpeed.text floatValue]) {
            self.maxSpeed = [self.lbAverageSpeed.text floatValue];
        }
        
        [self showAddress:location];
        if (_startDate == nil) // first update!
        {
            _startDate = location.timestamp;
            _distance = 0;
        }
        else
        {
            _distance += [location distanceFromLocation:_lastLocation];
            _lastLocation = location;
            NSTimeInterval travelTime = [location.timestamp timeIntervalSinceDate:_startDate];
            if (travelTime > 0)
            {
                double avgSpeed = (_distance / travelTime);
                if (self.maxSpeed <= avgSpeed) {
                    self.maxSpeed = avgSpeed;
                }
                NSString *unit = @"";
                if (isKmh) {
                    avgSpeed = avgSpeed * 3.6f;
                    unit = @"km/h";
                } else {
                    unit = @"mph";
                }
                self.lbAverageSpeed.text = [NSString stringWithFormat: @"%.2f %@", avgSpeed, unit];
                self.lbMaxSpeed.text = [NSString stringWithFormat: @"%.2f %@", self.maxSpeed, unit];
                NSLog(@"Average speed %.2f", avgSpeed);
            }
        }
    }
}

- (void)showAddress:(CLLocation *)location {
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!(error))
         {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             NSLog(@"\nCurrent Location Detected\n");
             NSLog(@"placemark %@",placemark);
             NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
             NSString *Address = [[NSString alloc]initWithString:locatedAt];
//             NSString *Area = [[NSString alloc]initWithString:placemark.locality];
             NSString *Country = [[NSString alloc]initWithString:placemark.country];
//             NSString *CountryArea = [NSString stringWithFormat:@"%@, %@", Area,Country];
//             NSLog(@"%@",CountryArea);
             
             NSString *adressString = [NSString stringWithFormat:@"%@, %@", Country, Address];
             
             if (![self.lbStepWalking.text isEqualToString:@""]) {
                 if (![self.lbStepWalking.text isEqualToString:adressString]) {
                     self.lbStepWalking.text = adressString;
                     [self.lbStepWalking restartLabel];
                 }
             } else {
                self.lbStepWalking.text = adressString;
                 [self.lbStepWalking restartLabel];
             }
         }
         else
         {
             NSLog(@"Geocode failed with error %@", error);
             NSLog(@"\nCurrent Location Not Detected\n");
//             //return;
//             CountryArea = NULL;
             
             self.lbStepWalking.text = [NSString stringWithFormat:@"Can not find address"];
         }
         /*---- For more results
          placemark.region);
          placemark.country);
          placemark.locality);
          placemark.name);
          placemark.ocean);
          placemark.postalCode);
          placemark.subLocality);
          placemark.location);
          ------*/
     }];
}

- (IBAction)btnKmh:(id)sender {
     self.lbSpeedNumber.text = [NSString stringWithFormat:@"%.2f",[SOMotionDetector sharedInstance].currentSpeed * 3.6f];
    self.btnKmh.backgroundColor = [UIColor darkGrayColor];
    self.btnMph.backgroundColor = [UIColor whiteColor];
    [self.btnKmh setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnMph setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [SOMotionDetector sharedInstance].locationChangedBlock = ^(CLLocation *location) {
        self.lbSpeedNumber.text = [NSString stringWithFormat:@"%.2f",[SOMotionDetector sharedInstance].currentSpeed * 3.6f];
        [self caculateAverageSpeed:YES andLocation:location];
    };
}
- (IBAction)btnMph:(id)sender {
    self.lbSpeedNumber.text = [NSString stringWithFormat:@"%.2f",[SOMotionDetector sharedInstance].currentSpeed];
    
    self.btnKmh.backgroundColor = [UIColor whiteColor];
    self.btnMph.backgroundColor = [UIColor darkGrayColor];
    [self.btnKmh setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnMph setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [SOMotionDetector sharedInstance].locationChangedBlock = ^(CLLocation *location) {
        self.lbSpeedNumber.text = [NSString stringWithFormat:@"%.2f",[SOMotionDetector sharedInstance].currentSpeed];
        [self caculateAverageSpeed:NO andLocation:location];
    };
}

- (void)locationError:(NSError *)error {
    self.lbSpeedNumber.text = [error description];
}

@end
