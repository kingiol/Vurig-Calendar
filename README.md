VURIG Calendar
=====================

#### A calendar view for iOS.
Easy to use, simple, clean.

Also animated :-)

#### Add new features by kingiol.

* custom weektitle color
* support for monday or sunday first show
* custom yearAndMonthTitleColor
* change select date with animation
* show or hiden yearMonthTitleView

### Installation
Copy the files from the calendar group to your own project.

### Usage
```
VRGCalendarView *calendar = [[VRGCalendarView alloc] init];
calendar.delegate=self;
calendar.firstDayOfWeekStyle = FirstDayOfWeekStyleSunday;
NSArray *ary = @[[UIColor redColor], [NSNull null], [NSNull null], [NSNull null], [NSNull null], [NSNull null], [UIColor redColor]];
calendar.weekTitleColor = ary;
calendar.yearAndMonthTitleColor = [UIColor redColor];
calendar.hidenYearMonthTitle = YES;
calendar.delegate=self;
calendar.selectDayWithAnimation = NO;
[self.view addSubview:calendar];
```

##Delegate methods
####Selecting days
Whenever a user selects a date, the following method will be called:
<pre>
-(void)calendarView:(VRGCalendarView *)calendarView dateSelected:(NSDate *)date;
</pre>
####Switching months
This delegate method will be called whenever a user switches to the next or previous month.  
<pre>
-(void)calendarView:(VRGCalendarView *)calendarView switchedToDate:(NSDate *)toDate targetHeight:(float)targetHeight animated:(BOOL)animated;
</pre>
With the way the calendar layouts work, the number of rows (and thus the height) can vary. You can react to this change by using the targetHeight parameter.

Mark the dates of that month by sending an array with NSDate or NSNumber objects. Like so:
<pre>
NSArray *dates = [NSArray arrayWithObjects:[NSNumber numberWithInt:1],[NSNumber numberWithInt:5], nil];
[calendarView markDates:dates];
</pre>
Or 
<pre>
NSArray *date = [NSArray arrayWithObjects:[NSDate date], nil];
NSArray *color = [NSArray arrayWithObjects:[UIColor redColor],nil];
[calendarView markDates:date withColors:color];
</pre>

##License
Vurig Calendar is released under the MIT License  
http://opensource.org/licenses/MIT




	
