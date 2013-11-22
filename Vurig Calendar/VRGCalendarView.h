//
//  VRGCalendarView.h
//  Vurig
//
//  Created by in 't Veen Tjeerd on 5/8/12.
//  Copyright (c) 2012 Vurig Media. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "UIColor+expanded.h"
#import "NSDate+convenience.h"
#import "KDCalendarHeaders.h"

#define kVRGCalendarViewTopBarHeight 60
#define kVRGCalendarViewWidth 320

#define kVRGCalendarViewDayWidth 44
#define kVRGCalendarViewDayHeight 44

#define kDefaultPreMonthFillColor [UIColor grayColor]
#define kDefaultNextMonthFillColor [UIColor grayColor]
#define kDefaultCurrentMonthFillColor [UIColor whiteColor]
#define kDefaultMarkColor [UIColor purpleColor]
#define kDefaultSelectedColor [UIColor redColor]
#define kDefaultTodayColor [UIColor blueColor]

#define kDefaultWeekTitleColor [UIColor colorWithHexString:@"0x383838"]

@protocol VRGCalendarViewDelegate;
@interface VRGCalendarView : UIView {
    id <VRGCalendarViewDelegate> delegate;

    NSDate *currentMonth;
    
    UILabel *labelCurrentMonth;
    
    BOOL isAnimating;
    BOOL prepAnimationPreviousMonth;
    BOOL prepAnimationNextMonth;
    
    UIImageView *animationView_A;
    UIImageView *animationView_B;
    
    NSArray *markedDates;
    NSArray *markedColors;
}

@property (nonatomic, strong) id <VRGCalendarViewDelegate> delegate;
@property (nonatomic, strong) NSDate *currentMonth;
@property (nonatomic, strong) UILabel *labelCurrentMonth;
@property (nonatomic, strong) UIImageView *animationView_A;
@property (nonatomic, strong) UIImageView *animationView_B;
@property (nonatomic, strong) NSArray *markedDates;
@property (nonatomic, strong) NSArray *markedColors;
@property (nonatomic, getter = calendarHeight) float calendarHeight;
@property (nonatomic, strong, getter = selectedDate) NSDate *selectedDate;
@property (nonatomic, assign) FirstDayOfWeekStyle firstDayOfWeekStyle;
@property (nonatomic, strong) NSArray *weekTitleColor;
@property (nonatomic, strong) UIColor *yearAndMonthTitleColor;

-(void)selectDate:(int)date;
-(void)reset;

-(void)markDates:(NSArray *)dates;
-(void)markDates:(NSArray *)dates withColors:(NSArray *)colors;

-(void)showNextMonth;
-(void)showPreviousMonth;

-(int)numRows;
-(void)updateSize;
-(UIImage *)drawCurrentState;

@end

@protocol VRGCalendarViewDelegate <NSObject>
-(void)calendarView:(VRGCalendarView *)calendarView switchedToDate:(NSDate *)toDate targetHeight:(float)targetHeight animated:(BOOL)animated;
-(void)calendarView:(VRGCalendarView *)calendarView dateSelected:(NSDate *)date;
@end
