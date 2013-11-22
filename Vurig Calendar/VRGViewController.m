//
//  VRGViewController.m
//  Vurig Calendar
//
//  Created by in 't Veen Tjeerd on 5/29/12.
//  Copyright (c) 2012 Vurig. All rights reserved.
//

#import "VRGViewController.h"

@interface VRGViewController ()

@end

@implementation VRGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    VRGCalendarView *calendar = [[VRGCalendarView alloc] init];
    calendar.firstDayOfWeekStyle = FirstDayOfWeekStyleSunday;
    NSArray *ary = @[[UIColor redColor], [NSNull null], [NSNull null], [NSNull null], [NSNull null], [NSNull null], [UIColor redColor]];
    calendar.weekTitleColor = ary;
    calendar.yearAndMonthTitleColor = [UIColor redColor];
    calendar.delegate=self;
//    calendar.frame = CGRectMake(20, 20, 320 - 40, 300);
    [self.view addSubview:calendar];
}


-(void)calendarView:(VRGCalendarView *)calendarView switchedToDate:(NSDate *)toDate targetHeight:(float)targetHeight animated:(BOOL)animated {
    
    if ([toDate month] == [[NSDate date] month]) {
        NSArray *dates = [NSArray arrayWithObjects:[NSNumber numberWithInt:1],[NSNumber numberWithInt:5], nil];
        [calendarView markDates:dates];
    }
}

-(void)calendarView:(VRGCalendarView *)calendarView dateSelected:(NSDate *)date isSameDate:(BOOL)isSame {
    NSLog(@"Selected date = %d-%d-%d, isSameDate:%@",[date year], [date month], [date day], isSame ?@"YES" : @"NO");
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
