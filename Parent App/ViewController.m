//
//  ViewController.m
//  Parent App
//
//  Created by Rael Kenny on 10/21/16.
//  Copyright © 2016 Rael Kenny. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController ()


@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
}

//CLLocation Delegate Method
-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [self.locationManager stopUpdatingLocation];

    CLLocation *currentLocation = locations[0];
    NSString *currentLatitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude];
    self.zoneLatitude.text = currentLatitude;
    
    NSString *currentLongitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude];
    self.zoneLongitude.text = currentLongitude;

    //NSDictionary:
    NSDictionary *userDetails = @{@"username":self.usernameTextField.text,
                                  @"radius":self.radiusTextField.text,
                                  @"longitude":self.zoneLongitude.text,
                                  @"latitude":self.zoneLatitude.text
                                  };
    
    //Dictionary -> JSON
    NSError *error;
    NSData *userJSONData = [NSJSONSerialization dataWithJSONObject:userDetails options:NSJSONWritingPrettyPrinted error:&error];
    
    if (! userJSONData) {
        NSLog(@" Error %@", error);
    } else {
        
        //PUT request for new user:
        NSString *urlString = [NSString stringWithFormat:@"https://turntotech.firebaseio.com/digitalleash/%@.json", self.usernameTextField.text];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
        
        //HTTP PUT Request:
        [request setHTTPBody:userJSONData];
        [request setHTTPMethod:@"PUT"];
        
        //create NSURLSession and fire request we made above:
        NSURLSession *session = [NSURLSession sessionWithConfiguration:
                                 [NSURLSessionConfiguration defaultSessionConfiguration]];
        
        [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
    //        NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            NSLog(@"request complete");
            
        }]
         resume];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)createButton:(id)sender {
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    
}

    
    
    
- (IBAction)updateButton:(id)sender {
    NSDictionary *userDetails = @{@"username":self.usernameTextField.text,
                                  @"radius":self.radiusTextField.text,
                                  @"longitude":self.zoneLongitude.text,
                                  @"latitude":self.zoneLatitude.text
                                  };

    //PATCH request to update child's location:
    NSError *error;
    NSData *userJSONData = [NSJSONSerialization dataWithJSONObject:userDetails
                                                           options:0
                                                             error:&error];
    if (! userJSONData) {
        NSLog(@"Error %@", error);
    }
    //else {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://turntotech.firebaseio.com/digitalleash/%@.json",self.usernameTextField.text]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    
    [request setHTTPBody:userJSONData];
    [request setHTTPMethod:@"PATCH"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:
                             [NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse * response, NSError *error) {
        
        // NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSLog(@"Patch request completed");
    }]
     resume];
//}
}


- (IBAction)statusButton:(id)sender {
    
//    NSDictionary *userDetails = @{@"Username":self.usernameTextField.text,
//                                  @"Radius":self.radiusTextField.text,
//                                  @"Longitude":self.zoneLongitude.text,
//                                  @"Latitude":self.zoneLatitude.text
//                                  }; NOT REQUIRED.
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://turntotech.firebaseio.com/digitalleash/%@.json", self.usernameTextField.text]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];

    [request setHTTPMethod:@"GET"];
    
    NSURLSessionConfiguration * sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.timeoutIntervalForRequest = 5;
    NSURLSession *session = [NSURLSession sessionWithConfiguration: sessionConfig];

    [[session dataTaskWithRequest:request //setting up a data task and completion handler.
                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    if (error) {
                        NSLog(@"ERROR %@",error);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self noInternetAlert:error];
                        });
                    } else {
                        NSError* jError;
                        NSDictionary *jsonDict = [NSJSONSerialization
                                                  JSONObjectWithData:data
                                                  options:kNilOptions
                                                  error:&jError];
                
        double childLatitude = [[jsonDict valueForKey:@"current_latitude"] doubleValue];
        double childLongitude = [[jsonDict valueForKey:@"current_longitude"] doubleValue];
        
        CLLocation *childLocation = [[CLLocation alloc]initWithLatitude:childLatitude
                                                                 longitude:childLongitude];
        
        double parentLatitude = [[jsonDict valueForKey:@"latitude"] doubleValue];
        double parentLongitude = [[jsonDict valueForKey:@"longitude"] doubleValue];
            
        CLLocation *parentLocation = [[CLLocation alloc]initWithLatitude:parentLatitude
                                                               longitude:parentLongitude];
            
        double CLLocationDistance = [parentLocation distanceFromLocation:childLocation];
        double radius = [[jsonDict valueForKey:@"radius"] doubleValue];
            
        dispatch_async(dispatch_get_main_queue(), ^{
            if (CLLocationDistance <= radius) {
                [self performSegueWithIdentifier:@"success" sender:self];
            } else {
                [self performSegueWithIdentifier:@"fail" sender:self];
            }
        });
                        
           
        }
                }]
     resume]; //fire off the request.
    
}

-(void) noInternetAlert:(NSError*)error {
        NSString *title = (@"Error");
        NSString *message = error.localizedDescription;
        NSString *actionButtonOk = (@"OK");
        NSString *actionButtonCancel = (@"Cancel");
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle: title
                                                                             message: message
                                                                      preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:actionButtonOk
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action){
                                                   [alertController dismissViewControllerAnimated:YES completion:nil];
                                               }];
    
    UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:actionButtonCancel style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alertController addAction:okButton];
    [alertController addAction:cancelButton];
    
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}
@end














