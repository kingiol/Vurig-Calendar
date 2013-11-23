//
//  VRGCalendarView.m
//  Vurig
//
//  Created by in 't Veen Tjeerd on 5/8/12.
//  Copyright (c) 2012 Vurig Media. All rights reserved.
//

#import "VRGCalendarView.h"
#import <QuartzCore/QuartzCore.h>
#import "NSMutableArray+convenience.h"
#import "UIView+convenience.h"

@interface VRGCalendarView ()

@property (nonatomic, assign) CGRect preSelectDateRect;
@property (nonatomic, assign) CGRect selectDateRect;
@property (nonatomic, strong) NSDate *preSelectDate;

@end

@implementation VRGCalendarView
@synthesize currentMonth,delegate,labelCurrentMonth, animationView_A,animationView_B;
@synthesize markedDates,markedColors,calendarHeight,selectedDate;

#pragma mark - Select Date
-(void)selectDate:(int)date {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit fromDate:self.currentMonth];
    [comps setDay:date];
    self.preSelectDate = self.selectedDate;
    self.selectedDate = [gregorian dateFromComponents:comps];

    int selectedDateYear = [selectedDate year];
    int selectedDateMonth = [selectedDate month];
    int currentMonthYear = [currentMonth year];
    int currentMonthMonth = [currentMonth month];
    
    BOOL isSame = NO;
    
    if (selectedDateYear < currentMonthYear) {
        [self showPreviousMonth];
    } else if (selectedDateYear > currentMonthYear) {
        [self showNextMonth];
    } else if (selectedDateMonth < currentMonthMonth) {
        [self showPreviousMonth];
    } else if (selectedDateMonth > currentMonthMonth) {
        [self showNextMonth];
    } else {
        if (self.preSelectDate != nil && [self.preSelectDate isDayEqualsDay:self.selectedDate]) {
            isSame = YES;
        }else {
            if (CGRectEqualToRect(self.preSelectDateRect, CGRectZero)) {
                [self setNeedsDisplay];
            }else {
                if (self.selectDayWithAnimation) {
                    UIView *preView = [[UIView alloc] initWithFrame:self.preSelectDateRect];
                    preView.backgroundColor = kDefaultCurrentMonthFillColor;
                    UILabel *preDateLabel = [[UILabel alloc] init];
                    preDateLabel.backgroundColor = [UIColor clearColor];
                    preDateLabel.textColor = [UIColor blackColor];
                    preDateLabel.font = [UIFont systemFontOfSize:17];
                    preDateLabel.text = [NSString stringWithFormat:@"%d", [self.preSelectDate day]];
                    [preDateLabel sizeToFit];
                    preDateLabel.center = CGPointMake(preView.frameWidth/2, preView.frameHeight/2);
                    [preView addSubview:preDateLabel];
                    [self addSubview:preView];
                    
                    UIView *selView = [[UIView alloc] initWithFrame:self.preSelectDateRect];
                    selView.backgroundColor = kDefaultSelectedColor;
                    [self addSubview:selView];
                    
                    [UIView animateWithDuration:0.2
                                     animations:^{
                                         selView.center = CGPointMake(CGRectGetMidX(self.selectDateRect), CGRectGetMidY(self.selectDateRect));
                                     } completion:^(BOOL finished) {
                                         [preView removeFromSuperview];
                                         [selView removeFromSuperview];
                                         [self setNeedsDisplay];
                                     }];
                }else {
                    [self setNeedsDisplay];
                }
            }
            
        }
    }
    
    if ([delegate respondsToSelector:@selector(calendarView:dateSelected:isSameDate:)])
        [delegate calendarView:self dateSelected:self.selectedDate isSameDate:isSame];
}

- (void)setWeekTitleColor:(NSArray *)weekTitleColor {
    NSAssert(weekTitleColor.count >= 7, @"weekTitleColor must more than 7");
    for (id obj in weekTitleColor) {
        NSAssert([obj isKindOfClass:[NSNull class]] || [obj isKindOfClass:[UIColor class]], @"weekTitleColor must only contian UIColor objects");
    }
    _weekTitleColor = weekTitleColor;
}

- (void)setYearAndMonthTitleColor:(UIColor *)yearAndMonthTitleColor {
    self.labelCurrentMonth.textColor = yearAndMonthTitleColor;
}

#pragma mark - Mark Dates
//NSArray can either contain NSDate objects or NSNumber objects with an int of the day.
-(void)markDates:(NSArray *)dates {
    self.markedDates = dates;
    NSMutableArray *colors = [[NSMutableArray alloc] init];
    
    for (int i = 0; i<[dates count]; i++) {
        [colors addObject:kDefaultMarkColor];
    }
    
    self.markedColors = [NSArray arrayWithArray:colors];
    
    [self setNeedsDisplay];
}

//NSArray can either contain NSDate objects or NSNumber objects with an int of the day.
-(void)markDates:(NSArray *)dates withColors:(NSArray *)colors {
    self.markedDates = dates;
    self.markedColors = colors;
    
    [self setNeedsDisplay];
}

#pragma mark - Set date to now
-(void)reset {
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components =
    [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit |
                           NSDayCalendarUnit) fromDate: [NSDate date]];
    self.currentMonth = [gregorian dateFromComponents:components]; //clean month
    
    [self updateSize];
    [delegate calendarView:self switchedToDate:currentMonth targetHeight:self.calendarHeight animated:YES];
}

#pragma mark - Next & Previous
-(void)showNextMonth {
    if (isAnimating) return;
    self.preSelectDate = nil;
    self.preSelectDateRect = CGRectZero;
    self.selectedDate = nil;
    self.selectDateRect = CGRectZero;
    self.markedDates=nil;
    isAnimating=YES;
    prepAnimationNextMonth=YES;
    
    [self setNeedsDisplay];
    
    int lastBlock = [currentMonth firstWeekDayInMonth:self.firstDayOfWeekStyle]+[currentMonth numDaysInMonth]-1;
    int numBlocks = [self numRows]*7;
    BOOL hasNextMonthDays = lastBlock<numBlocks;
    
    //Old month
    float oldSize = self.calendarHeight;
    UIImage *imageCurrentMonth = [self drawCurrentState];
    
    //New month
    self.currentMonth = [currentMonth offsetMonth:1];
    if ([delegate respondsToSelector:@selector(calendarView:switchedToDate:targetHeight: animated:)])
        [delegate calendarView:self switchedToDate:currentMonth targetHeight:self.calendarHeight animated:YES];
    prepAnimationNextMonth=NO;
    [self setNeedsDisplay];
    
    UIImage *imageNextMonth = [self drawCurrentState];
    float targetSize = fmaxf(oldSize, self.calendarHeight);
    UIView *animationHolder = [[UIView alloc] initWithFrame:CGRectMake(0, [self privateTopHeadHeight], [self privateCalenderWidth], targetSize-[self privateTopHeadHeight])];
    [animationHolder setClipsToBounds:YES];
    [self addSubview:animationHolder];
    
    //Animate
    self.animationView_A = [[UIImageView alloc] initWithImage:imageCurrentMonth];
    self.animationView_B = [[UIImageView alloc] initWithImage:imageNextMonth];
    [animationHolder addSubview:animationView_A];
    [animationHolder addSubview:animationView_B];
    
    if (hasNextMonthDays) {
        animationView_B.frameY = animationView_A.frameY + animationView_A.frameHeight - ([self privateCalendarViewDayHeight]+3);
    } else {
        animationView_B.frameY = animationView_A.frameY + animationView_A.frameHeight -3;
    }
    
    //Animation
    __weak VRGCalendarView *blockSafeSelf = self;
    [UIView animateWithDuration:.35
                     animations:^{
                         [self updateSize];
                         //blockSafeSelf.frameHeight = 100;
                         if (hasNextMonthDays) {
                             animationView_A.frameY = -animationView_A.frameHeight + [self privateCalendarViewDayHeight]+3;
                         } else {
                             animationView_A.frameY = -animationView_A.frameHeight + 3;
                         }
                         animationView_B.frameY = 0;
                     }
                     completion:^(BOOL finished) {
                         [animationView_A removeFromSuperview];
                         [animationView_B removeFromSuperview];
                         blockSafeSelf.animationView_A=nil;
                         blockSafeSelf.animationView_B=nil;
                         isAnimating=NO;
                         [animationHolder removeFromSuperview];
                     }
     ];
}

-(void)showPreviousMonth {
    if (isAnimating) return;
    self.preSelectDate = nil;
    self.preSelectDateRect = CGRectZero;
    self.selectedDate = nil;
    self.selectDateRect = CGRectZero;
    isAnimating=YES;
    self.markedDates=nil;
    //Prepare current screen
    prepAnimationPreviousMonth = YES;
    [self setNeedsDisplay];
    BOOL hasPreviousDays = [currentMonth firstWeekDayInMonth:self.firstDayOfWeekStyle]>1;
    float oldSize = self.calendarHeight;
    UIImage *imageCurrentMonth = [self drawCurrentState];
    
    //Prepare next screen
    self.currentMonth = [currentMonth offsetMonth:-1];
    if ([delegate respondsToSelector:@selector(calendarView:switchedToDate:targetHeight:animated:)]) [delegate calendarView:self switchedToDate:currentMonth targetHeight:self.calendarHeight animated:YES];
    prepAnimationPreviousMonth=NO;
    [self setNeedsDisplay];
    UIImage *imagePreviousMonth = [self drawCurrentState];
    
    float targetSize = fmaxf(oldSize, self.calendarHeight);
    UIView *animationHolder = [[UIView alloc] initWithFrame:CGRectMake(0, [self privateTopHeadHeight], [self privateCalenderWidth], targetSize-[self privateTopHeadHeight])];
    
    [animationHolder setClipsToBounds:YES];
    [self addSubview:animationHolder];
    
    self.animationView_A = [[UIImageView alloc] initWithImage:imageCurrentMonth];
    self.animationView_B = [[UIImageView alloc] initWithImage:imagePreviousMonth];
    [animationHolder addSubview:animationView_A];
    [animationHolder addSubview:animationView_B];
    
    if (hasPreviousDays) {
        animationView_B.frameY = animationView_A.frameY - (animationView_B.frameHeight-[self privateCalendarViewDayHeight]) + 3;
    } else {
        animationView_B.frameY = animationView_A.frameY - animationView_B.frameHeight + 3;
    }
    
    __weak VRGCalendarView *blockSafeSelf = self;
    [UIView animateWithDuration:.35
                     animations:^{
                         [self updateSize];
                         
                         if (hasPreviousDays) {
                             animationView_A.frameY = animationView_B.frameHeight-([self privateCalendarViewDayHeight]+3); 
                             
                         } else {
                             animationView_A.frameY = animationView_B.frameHeight-3;
                         }
                         
                         animationView_B.frameY = 0;
                     }
                     completion:^(BOOL finished) {
                         [animationView_A removeFromSuperview];
                         [animationView_B removeFromSuperview];
                         blockSafeSelf.animationView_A=nil;
                         blockSafeSelf.animationView_B=nil;
                         isAnimating=NO;
                         [animationHolder removeFromSuperview];
                     }
     ];
}


#pragma mark - update size & row count
-(void)updateSize {
    self.frameHeight = self.calendarHeight;
    [self setNeedsDisplay];
}

-(float)calendarHeight {
    return [self privateTopHeadHeight] + [self numRows]*([self privateCalendarViewDayHeight]+2)+1;
}

-(int)numRows {
    float lastBlock = [self.currentMonth numDaysInMonth]+([self.currentMonth firstWeekDayInMonth:self.firstDayOfWeekStyle]-1);
    return ceilf(lastBlock/7);
}

#pragma mark - private size method

- (CGFloat)privateCalenderWidth {
    return kVRGCalendarViewWidth;
}

- (CGFloat)privateTopHeadHeight {
    return [self privateTopYearMonthHeight] + [self privateTopWeekBarHeight];
}

- (CGFloat)privateTopYearMonthHeight {
    return self.hidenYearMonthTitle ? 0.0f : kVRGCalendarViewTopYearMonthBarHeight;
}

- (CGFloat)privateTopWeekBarHeight {
    return kVRGCalendarViewTopWeekBarHeight;
}

- (CGFloat)privateCalendarViewDayWidth {
    return kVRGCalendarViewDayWidth;
}

- (CGFloat)privateCalendarViewDayHeight {
    return kVRGCalendarViewDayHeight;
}

#pragma mark - Touches
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{       
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
//    self.selectedDate=nil;

    //Touch a specific day
    if (touchPoint.y > [self privateTopHeadHeight]) {
        float xLocation = touchPoint.x;
        float yLocation = touchPoint.y-[self privateTopHeadHeight];
        
        int column = floorf(xLocation/([self privateCalendarViewDayWidth]+2));
        int row = floorf(yLocation/([self privateCalendarViewDayHeight]+2));
        
        int blockNr = (column+1)+row*7;
        int firstWeekDay = [self.currentMonth firstWeekDayInMonth:self.firstDayOfWeekStyle]-1; //-1 because weekdays begin at 1, not 0
        int date = blockNr-firstWeekDay;
        
        
        int targetColumn = column;
        int targetRow = row;
        int targetX = targetColumn * ([self privateCalendarViewDayWidth]+1);
        int targetY = [self privateTopHeadHeight] + targetRow * ([self privateCalendarViewDayHeight]+1);
        
        CGRect rectangleGrid = CGRectMake(targetX,targetY,[self privateCalendarViewDayWidth]+1,[self privateCalendarViewDayHeight]+1);
        self.preSelectDateRect = self.selectDateRect;
        self.selectDateRect = rectangleGrid;
        
        [self selectDate:date];
        return;
    }
    
    self.markedDates=nil;
    self.markedColors=nil;  
    
    if (self.hidenYearMonthTitle) return;
    
    CGRect rectArrowLeft = CGRectMake(0, 0, 50, 40);
    CGRect rectArrowRight = CGRectMake(self.frame.size.width-50, 0, 50, 40);
    
    //Touch either arrows or month in middle
    if (CGRectContainsPoint(rectArrowLeft, touchPoint)) {
        [self showPreviousMonth];
    } else if (CGRectContainsPoint(rectArrowRight, touchPoint)) {
        [self showNextMonth];
    } else if (CGRectContainsPoint(self.labelCurrentMonth.frame, touchPoint)) {
        //Detect touch in current month
        int currentMonthIndex = [self.currentMonth month];
        int todayMonth = [[NSDate date] month];
        [self reset];
        if ((todayMonth!=currentMonthIndex) && [delegate respondsToSelector:@selector(calendarView:switchedToDate:targetHeight:animated:)])
            [delegate calendarView:self switchedToDate:currentMonth targetHeight:self.calendarHeight animated:NO];
    }
}

#pragma mark - Drawing
- (void)drawRect:(CGRect)rect
{
    
    int firstWeekDay = [self.currentMonth firstWeekDayInMonth:self.firstDayOfWeekStyle] - 1;
    
    //clear the view context
    CGContextClearRect(UIGraphicsGetCurrentContext(),rect);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (!self.hidenYearMonthTitle) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy MMM"];
        labelCurrentMonth.text = [formatter stringFromDate:self.currentMonth];
        [labelCurrentMonth sizeToFit];
        labelCurrentMonth.frameX = roundf(self.frame.size.width/2 - labelCurrentMonth.frameWidth/2);
        labelCurrentMonth.frameY = 10;
        
        CGRect rectangle = CGRectMake(0,0,self.frame.size.width,[self privateTopYearMonthHeight]);
        CGContextAddRect(context, rectangle);
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextFillPath(context);
        
        //Arrows
        int arrowSize = 12;
        int xmargin = 20;
        int ymargin = 18;
        
        //Arrow Left
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, xmargin+arrowSize/1.5, ymargin);
        CGContextAddLineToPoint(context,xmargin+arrowSize/1.5,ymargin+arrowSize);
        CGContextAddLineToPoint(context,xmargin,ymargin+arrowSize/2);
        CGContextAddLineToPoint(context,xmargin+arrowSize/1.5, ymargin);
        
        CGContextSetFillColorWithColor(context,
                                       [UIColor blackColor].CGColor);
        CGContextFillPath(context);
        
        //Arrow right
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, self.frame.size.width-(xmargin+arrowSize/1.5), ymargin);
        CGContextAddLineToPoint(context,self.frame.size.width-xmargin,ymargin+arrowSize/2);
        CGContextAddLineToPoint(context,self.frame.size.width-(xmargin+arrowSize/1.5),ymargin+arrowSize);
        CGContextAddLineToPoint(context,self.frame.size.width-(xmargin+arrowSize/1.5), ymargin);
        
        CGContextSetFillColorWithColor(context,
                                       [UIColor blackColor].CGColor);
        CGContextFillPath(context);
    }
    
//    [currentMonth firstWeekDayInMonth:self.firstDayOfWeekStyle];

    int numRows = [self numRows];
    
    CGContextSetAllowsAntialiasing(context, NO);
    
    //Grid background
    float gridHeight = numRows*([self privateCalendarViewDayHeight]+2)+1 + [self privateTopWeekBarHeight];
    CGRect rectangleGrid = CGRectMake(0,[self privateTopYearMonthHeight],self.frame.size.width,gridHeight);
    CGContextAddRect(context, rectangleGrid);
    CGContextSetFillColorWithColor(context, [UIColor colorWithHexString:@"0xf3f3f3"].CGColor);
    CGContextFillPath(context);
    
    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, [self privateTopYearMonthHeight]+0.5);
    CGContextAddLineToPoint(context, [self privateCalenderWidth], [self privateTopYearMonthHeight]+0.5);
    CGContextStrokePath(context);

    //Weekdays
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat=@"EEE";
    //always assume gregorian with monday first
    NSMutableArray *weekdays = [[NSMutableArray alloc] initWithArray:[dateFormatter shortWeekdaySymbols]];
    if (self.firstDayOfWeekStyle == FirstDayOfWeekStyleMonday) {
        [weekdays moveObjectFromIndex:0 toIndex:6];
    }
    for (int i =0; i<[weekdays count]; i++) {
        UIColor *color = [self.weekTitleColor objectAtIndex:i];
        if (color != nil && ![color isKindOfClass:[NSNull class]]) {
            CGContextSetFillColorWithColor(context, color.CGColor);
        }else {
            CGContextSetFillColorWithColor(context,
                                           kDefaultWeekTitleColor.CGColor);
        }
        NSString *weekdayValue = (NSString *)[weekdays objectAtIndex:i];
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:12];
        [weekdayValue drawInRect:CGRectMake(i*([self privateCalendarViewDayWidth]+2), [self privateTopYearMonthHeight] + 1, [self privateCalendarViewDayWidth]+2, [self privateTopWeekBarHeight]) withFont:font lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
    }

    //Grid white lines
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, [self privateTopHeadHeight]+1);
    CGContextAddLineToPoint(context, [self privateCalenderWidth], [self privateTopHeadHeight]+1);
    for (int i = 1; i<7; i++) {
        CGContextMoveToPoint(context, i*([self privateCalendarViewDayWidth]+1)+i*1-1, [self privateTopHeadHeight]);
        CGContextAddLineToPoint(context, i*([self privateCalendarViewDayWidth]+1)+i*1-1, [self privateTopHeadHeight]+gridHeight);
        
        if (i>numRows-1) continue;
        //rows
        CGContextMoveToPoint(context, 0, [self privateTopHeadHeight]+i*([self privateCalendarViewDayHeight]+1)+i*1+1);
        CGContextAddLineToPoint(context, [self privateCalenderWidth], [self privateTopHeadHeight]+i*([self privateCalendarViewDayHeight]+1)+i*1+1);
    }
    CGContextStrokePath(context);
    
    //Grid dark lines
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithHexString:@"0xcfd4d8"].CGColor);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, [self privateTopHeadHeight]);
    CGContextAddLineToPoint(context, [self privateCalenderWidth], [self privateTopHeadHeight]);
    for (int i = 1; i<7; i++) {
        //columns
        CGContextMoveToPoint(context, i*([self privateCalendarViewDayWidth]+1)+i*1, [self privateTopHeadHeight]);
        CGContextAddLineToPoint(context, i*([self privateCalendarViewDayWidth]+1)+i*1, [self privateTopHeadHeight]+gridHeight);
        
        if (i>numRows-1) continue;
        //rows
        CGContextMoveToPoint(context, 0, [self privateTopHeadHeight]+i*([self privateCalendarViewDayHeight]+1)+i*1);
        CGContextAddLineToPoint(context, [self privateCalenderWidth], [self privateTopHeadHeight]+i*([self privateCalendarViewDayHeight]+1)+i*1);
    }
    CGContextMoveToPoint(context, 0, gridHeight+[self privateTopHeadHeight]);
    CGContextAddLineToPoint(context, [self privateCalenderWidth], gridHeight+[self privateTopHeadHeight]);
    
    CGContextStrokePath(context);
    
    CGContextSetAllowsAntialiasing(context, YES);
    
    //Draw days
    CGContextSetFillColorWithColor(context, 
                                   [UIColor colorWithHexString:@"0x383838"].CGColor);
    
    //NSLog(@"currentMonth month = %i, first weekday in month = %i",[self.currentMonth month],[self.currentMonth firstWeekDayInMonth]);
    
    int numBlocks = numRows*7;
    NSDate *previousMonth = [self.currentMonth offsetMonth:-1];
    int currentMonthNumDays = [currentMonth numDaysInMonth];
    int prevMonthNumDays = [previousMonth numDaysInMonth];
    
    int selectedDateBlock = ([selectedDate day]-1)+firstWeekDay;
    
    //prepAnimationPreviousMonth nog wat mee doen
    
    //prev next month
    BOOL isSelectedDatePreviousMonth = prepAnimationPreviousMonth;
    BOOL isSelectedDateNextMonth = prepAnimationNextMonth;
    
    if (self.selectedDate!=nil) {
        isSelectedDatePreviousMonth = ([selectedDate year]==[currentMonth year] && [selectedDate month]<[currentMonth month]) || [selectedDate year] < [currentMonth year];
        
        if (!isSelectedDatePreviousMonth) {
            isSelectedDateNextMonth = ([selectedDate year]==[currentMonth year] && [selectedDate month]>[currentMonth month]) || [selectedDate year] > [currentMonth year];
        }
    }
    
    if (isSelectedDatePreviousMonth) {
        int lastPositionPreviousMonth = firstWeekDay-1;
        selectedDateBlock=lastPositionPreviousMonth-([selectedDate numDaysInMonth]-[selectedDate day]);
    } else if (isSelectedDateNextMonth) {
        selectedDateBlock = [currentMonth numDaysInMonth] + (firstWeekDay-1) + [selectedDate day];
    }
    
    
    NSDate *todayDate = [NSDate date];
    int todayBlock = -1;
    
//    NSLog(@"currentMonth month = %i day = %i, todaydate day = %i",[currentMonth month],[currentMonth day],[todayDate month]);
    
    if ([todayDate month] == [currentMonth month] && [todayDate year] == [currentMonth year]) {
        todayBlock = [todayDate day] + firstWeekDay - 1;
    }
    
    for (int i=0; i<numBlocks; i++) {
        int targetDate = i;
        int targetColumn = i%7;
        int targetRow = i/7;
        int targetX = targetColumn * ([self privateCalendarViewDayWidth]+2);
        int targetY = [self privateTopHeadHeight] + targetRow * ([self privateCalendarViewDayHeight]+2);
        
        CGRect rectangleGrid = CGRectMake(targetX,targetY,[self privateCalendarViewDayWidth]+1,[self privateCalendarViewDayHeight]+1);
        CGContextAddRect(context, rectangleGrid);
        NSString *hex = (isSelectedDatePreviousMonth) ? @"0x383838" : @"aaaaaa";
        
        // BOOL isCurrentMonth = NO;
        if (i<firstWeekDay) { //previous month
            targetDate = (prevMonthNumDays-firstWeekDay)+(i+1);
            CGContextSetFillColorWithColor(context, kDefaultPreMonthFillColor.CGColor);
        } else if (i>=(firstWeekDay+currentMonthNumDays)) { //next month
            targetDate = (i+1) - (firstWeekDay+currentMonthNumDays);
            CGContextSetFillColorWithColor(context, kDefaultNextMonthFillColor.CGColor);
        } else { //current month
            // isCurrentMonth = YES;
            targetDate = (i-firstWeekDay)+1;
            hex = (isSelectedDatePreviousMonth || isSelectedDateNextMonth) ? @"0xaaaaaa" : @"0x383838";
            CGContextSetFillColorWithColor(context, kDefaultCurrentMonthFillColor.CGColor);
        }
        CGContextFillPath(context);
        
        CGContextSetFillColorWithColor(context,
                                       [UIColor colorWithHexString:hex].CGColor);
        
        NSString *date = [NSString stringWithFormat:@"%i",targetDate];
        
        //draw selected date
        if (selectedDate && i==selectedDateBlock) {
            CGRect rectangleGrid = CGRectMake(targetX,targetY,[self privateCalendarViewDayWidth]+2,[self privateCalendarViewDayHeight]+2);
            self.selectDateRect = rectangleGrid;
            CGContextAddRect(context, rectangleGrid);
            CGContextSetFillColorWithColor(context, kDefaultSelectedColor.CGColor);
            CGContextFillPath(context);
            
            CGContextSetFillColorWithColor(context, 
                                           [UIColor whiteColor].CGColor);
        } else if (todayBlock==i) { //today
            CGRect rectangleGrid = CGRectMake(targetX,targetY,[self privateCalendarViewDayWidth]+2,[self privateCalendarViewDayHeight]+2);
            CGContextAddRect(context, rectangleGrid);
            CGContextSetFillColorWithColor(context, kDefaultTodayColor.CGColor);
            CGContextFillPath(context);
            
            CGContextSetFillColorWithColor(context, 
                                           [UIColor whiteColor].CGColor);
        }
        
        [date drawInRect:CGRectMake(targetX+2, targetY+10, [self privateCalendarViewDayWidth], [self privateCalendarViewDayHeight]) withFont:[UIFont systemFontOfSize:17] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
    }
    
    //    CGContextClosePath(context);
    
    //Draw markings
    if (!self.markedDates || isSelectedDatePreviousMonth || isSelectedDateNextMonth) return;
    
    for (int i = 0; i<[self.markedDates count]; i++) {
        id markedDateObj = [self.markedDates objectAtIndex:i];
        
        int targetDate;
        if ([markedDateObj isKindOfClass:[NSNumber class]]) {
            targetDate = [(NSNumber *)markedDateObj intValue];
        } else if ([markedDateObj isKindOfClass:[NSDate class]]) {
            NSDate *date = (NSDate *)markedDateObj;
            targetDate = [date day];
        } else {
            continue;
        }
        
        
        int targetBlock = firstWeekDay + (targetDate-1);
        int targetColumn = targetBlock%7;
        int targetRow = targetBlock/7;
        
        /*
        int targetX = targetColumn * ([self privateCalendarViewDayWidth]+2) + 7;
        int targetY = [self privateTopHeadHeight] + targetRow * ([self privateCalendarViewDayHeight]+2) + 38;
        
        CGRect rectangle = CGRectMake(targetX,targetY,32,2);
        CGContextAddRect(context, rectangle);
         */
        int targetX = targetColumn * ([self privateCalendarViewDayWidth]+2);
        int targetY = [self privateTopHeadHeight] + targetRow * ([self privateCalendarViewDayHeight]+2);
        CGRect rectangle = CGRectMake(targetX,targetY,[self privateCalendarViewDayWidth]+2,[self privateCalendarViewDayHeight]+2);
        CGContextAddRect(context, rectangle);
        
        UIColor *color;
        if (selectedDate && selectedDateBlock==targetBlock) {
            color = kDefaultSelectedColor;
        }  else if (todayBlock==targetBlock) {
            color = kDefaultTodayColor;
        } else {
            color  = (UIColor *)[markedColors objectAtIndex:i];
        }
        
        
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillPath(context);
        
        CGContextSetFillColorWithColor(context,
                                       [UIColor whiteColor].CGColor);
        NSString *date = [NSString stringWithFormat:@"%i",targetDate];
        [date drawInRect:CGRectMake(targetX+2, targetY+10, [self privateCalendarViewDayWidth], [self privateCalendarViewDayHeight]) withFont:[UIFont systemFontOfSize:17] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
    }
}

#pragma mark - Draw image for animation
-(UIImage *)drawCurrentState {
    float targetHeight = [self privateTopHeadHeight] + [self numRows]*([self privateCalendarViewDayHeight]+2)+1;
    
    UIGraphicsBeginImageContext(CGSizeMake([self privateCalenderWidth], targetHeight-[self privateTopHeadHeight]));
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(c, 0, -[self privateTopHeadHeight]);    // <-- shift everything up by 40px when drawing.
    [self.layer renderInContext:c];
    UIImage* viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
}

#pragma mark - Init
-(id)init {
    self = [super initWithFrame:CGRectMake(0, 0, [self privateCalenderWidth], 0)];
    if (self) {
        self.contentMode = UIViewContentModeTop;
        self.clipsToBounds=YES;
        self.firstDayOfWeekStyle = FirstDayOfWeekStyleMonday;
        self.selectDayWithAnimation = YES;
        self.hidenYearMonthTitle = NO;
        
        isAnimating=NO;
        
        [self performSelector:@selector(reset) withObject:nil afterDelay:0.1]; //so delegate can be set after init and still get called on init
//        [self reset];
    }
    return self;
}

- (void)setHidenYearMonthTitle:(BOOL)hidenYearMonthTitle {
    if (!hidenYearMonthTitle) {
        self.labelCurrentMonth = [[UILabel alloc] initWithFrame:CGRectMake(34, 0, [self privateCalenderWidth]-68, 40)];
        [self addSubview:labelCurrentMonth];
        labelCurrentMonth.backgroundColor=[UIColor whiteColor];
        labelCurrentMonth.font = [UIFont systemFontOfSize:17];//[UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
        labelCurrentMonth.textColor = [UIColor colorWithHexString:@"0x383838"];
        labelCurrentMonth.textAlignment = UITextAlignmentCenter;
    }else {
        [labelCurrentMonth removeFromSuperview];
    }
    _hidenYearMonthTitle = hidenYearMonthTitle;
}

@end
