//
//  ModuleAViewController.m
//  LabThree
//
//  Created by Austin Wells on 2/24/15.
//  Copyright (c) 2015 Austin Wells. All rights reserved.
//

#import "ModuleAViewController.h"
#import <CoreMotion/CoreMotion.h>



@interface ModuleAViewController ()


@property (nonatomic, strong) CMMotionActivityManager *motionActivityManager;
@property (nonatomic, strong) CMPedometer * pedometer;
@property (weak, nonatomic) IBOutlet UILabel *activityLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepsTodayLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepsYesterdayLabel;


@end

@implementation ModuleAViewController



- (CMMotionActivityManager*)motionActivityManager{
    if(!_motionActivityManager) {
        _motionActivityManager = [[CMMotionActivityManager alloc] init];
    }
    return _motionActivityManager;
    
}

- (CMPedometer*)pedometer{
    if(!_pedometer) {
        _pedometer = [[CMPedometer alloc] init];
    }
    return _pedometer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // get query period for date
    NSDate *now = [NSDate date];
    NSDate *today = [NSDate date]; // need to subtract todays seconds 
    
    // All intervals taken from Google
    NSDate *yesterday = [today dateByAddingTimeInterval: -86400.0];
    
    //request past data
    [self.pedometer queryPedometerDataFromDate:now toDate:from withHandler:^(CMPedometerData *pedometerData, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.stepsYesterdayLabel.text = [NSString stringWithFormat:@"%@ steps", pedometerData.numberOfSteps];
           
        });
    }
    
    // request updates from pedometer
    if([CMPedometer isStepCountingAvailable] == YES) {
        [self.pedometer startPedometerUpdatesFromDate:[NSDate date] withHandler:^(CMPedometerData *pedometerData, NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.stepsTodayLabel.text = [NSString stringWithFormat:@"%@ steps", pedometerData.numberOfSteps];
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Some Message" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                [alertView show];
            });
           
            NSLog(@"num steps %@", pedometerData.numberOfSteps);
        }];
    }
    
    
    // request updates from activity manager
    if([CMMotionActivityManager isActivityAvailable] == YES) {
        [self.motionActivityManager startActivityUpdatesToQueue:[NSOperationQueue mainQueue]
                                    withHandler:^(CMMotionActivity *activity) {
                                       // #TODO get updates on not main queue and launch main queu to set things
                                        if(activity.stationary)
                                            self.activityLabel.text = @"stationary";
                                        else if(activity.walking)
                                            self.activityLabel.text = @"walking";
                                        else if(activity.running)
                                            self.activityLabel.text = @"running";
                                        else if(activity.cycling)
                                             self.activityLabel.text = @"cycling";
                                        else if(activity.automotive)
                                             self.activityLabel.text = @"automotive";
                                    }];
    }
    else
        NSLog(@"Cannot start activity manager");
   //  Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillDisappear:(BOOL)animated {
    if([CMMotionActivityManager isActivityAvailable] == YES )
        [self.motionActivityManager stopActivityUpdates];
}


@end
