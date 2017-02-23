//
//  ViewController.h
//  Parent App
//
//  Created by Rael Kenny on 10/21/16.
//  Copyright © 2016 Rael Kenny. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController <CLLocationManagerDelegate, NSURLSessionDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *radiusTextField;
@property (weak, nonatomic) IBOutlet UITextField *zoneLongitude;
@property (weak, nonatomic) IBOutlet UITextField *zoneLatitude;






- (IBAction)createButton:(id)sender;
- (IBAction)updateButton:(id)sender;
- (IBAction)statusButton:(id)sender;

-(void) noInternetAlert;

@end

