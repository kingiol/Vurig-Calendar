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

@implementation VRGViewController {
    VRGCalendarView *calendar;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    calendar = [[VRGCalendarView alloc] init];
    calendar.firstDayOfWeekStyle = FirstDayOfWeekStyleSunday;
    NSArray *ary = @[[UIColor redColor], [NSNull null], [NSNull null], [NSNull null], [NSNull null], [NSNull null], [UIColor redColor]];
    calendar.weekTitleColor = ary;
    calendar.yearAndMonthTitleColor = [UIColor redColor];
//    calendar.hidenYearMonthTitle = YES;
    calendar.delegate=self;
    calendar.selectDayWithAnimation = NO;
    [self.view addSubview:calendar];
    
    UIButton *preBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 400, 50, 20)];
    preBtn.backgroundColor = [UIColor redColor];
    [preBtn setTitle:@"pre" forState:UIControlStateNormal];
    preBtn.tag = 1;
    [preBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:preBtn];
    
    UIButton *sBtn = [[UIButton alloc] initWithFrame:CGRectMake(60, 400, 50, 20)];
    sBtn.backgroundColor = [UIColor redColor];
    [sBtn setTitle:@"show" forState:UIControlStateNormal];
    sBtn.tag = 2;
    [sBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sBtn];
    
    UIButton *nBtn = [[UIButton alloc] initWithFrame:CGRectMake(120, 400, 50, 20)];
    nBtn.backgroundColor = [UIColor redColor];
    [nBtn setTitle:@"next" forState:UIControlStateNormal];
    nBtn.tag = 3;
    [nBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nBtn];
}

- (void)btnClick:(UIButton *)btn {
    switch (btn.tag) {
        case 1: // pre
        {
            [calendar showPreviousMonth];
        }
            break;
            
        case 2: // show
        {
            NSLog(@"height : %f", calendar.frame.size.height);
        }
            break;
            
        case 3: // next
        {
            [calendar showNextMonth];
        }
            break;
            
        default:
            break;
    }
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
