//
//  FXWeeklyCalendarView.swift
//  ncapprove
//
//  Created by 缪海露 on 15/8/8.
//  Copyright (c) 2015年  user. All rights reserved.
//

import UIKit

protocol FXWeeklyCalendarViewDelegate {
    func dailyCalendarViewDidSelect(date : NSDate)
    func CLCalendarBehaviorAttributes()->NSDictionary
}


extension NSObject
{
    func performSelectorOnMainThread(selector aSelector: Selector,withObject object:AnyObject! ,waitUntilDone wait:Bool)
    {
        if self.respondsToSelector(aSelector)
        {
            var continuego = false
            let group = dispatch_group_create()
            let queue = dispatch_queue_create("com.fsh.dispatch", nil)
            dispatch_group_async(group,queue,{
                dispatch_async(queue ,{
                    //做了个假的
                    NSThread.detachNewThreadSelector(aSelector, toTarget:self, withObject: object)
                    continuego = true
                })
            })
            dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
            
            if wait
            {
                let ret = NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate.distantFuture() as! NSDate)
                while (!continuego && ret)
                {
                    
                }
            }
        }
    }
    
    func performSelector(selector aSelector: Selector, object anArgument: AnyObject! ,delay afterDelay:NSTimeInterval)
    {
        if self.respondsToSelector(aSelector)
        {
            let minseconds = afterDelay * Double(NSEC_PER_SEC)
            let dtime = dispatch_time(DISPATCH_TIME_NOW, Int64(minseconds))
            
            dispatch_after(dtime,dispatch_get_main_queue() , {
                //做了个假的
                NSThread.detachNewThreadSelector(aSelector, toTarget:self, withObject: anArgument)
            })
        }
    }
}



class FXWeeklyCalendarView: UIView ,DailyCalendarViewDelegate, UIGestureRecognizerDelegate{
    
    
    
    let WEEKLY_VIEW_COUNT  = 7
    let DAY_TITLE_VIEW_HEIGHT : CGFloat = 20
    let DAY_TITLE_FONT_SIZE : CGFloat = 11
    let DATE_TITLE_MARGIN_TOP : CGFloat = 22
    
    let DATE_VIEW_MARGIN : CGFloat = 3
    let DATE_VIEW_HEIGHT : CGFloat = 28
    
    
    let DATE_LABEL_MARGIN_LEFT : CGFloat = 9
    let DATE_LABEL_INFO_WIDTH : CGFloat = 180
    let DATE_LABEL_INFO_HEIGHT : CGFloat = 40
    
    let WEATHER_ICON_WIDTH : CGFloat = 20
    let WEATHER_ICON_HEIGHT : CGFloat = 20
    let WEATHER_ICON_LEFT : CGFloat = 90
    let WEATHER_ICON_MARGIN_TOP : CGFloat = 9
    
    //Attribute Keys
    let  CLCalendarWeekStartDay = "CLCalendarWeekStartDay";
    let  CLCalendarDayTitleTextColor = "CLCalendarDayTitleTextColor";
    let CLCalendarSelectedDatePrintFormat = "CLCalendarSelectedDatePrintFormat";
    let CLCalendarSelectedDatePrintColor = "CLCalendarSelectedDatePrintColor";
    let CLCalendarSelectedDatePrintFontSize = "CLCalendarSelectedDatePrintFontSize";
    let CLCalendarBackgroundImageColor = "CLCalendarBackgroundImageColor";
    
    //Default Values
    let CLCalendarWeekStartDayDefault : NSInteger = 1;
    
    let CLCalendarSelectedDatePrintFormatDefault =  "EEE,yyyy年MM月dd日"
    let CLCalendarSelectedDatePrintFontSizeDefault : CGFloat = 13
    
    
    
    var dailySubViewContainer : UIView!
    var dayTitleSubViewContainer : UIView!
    var backgroundImageView : UIImageView!
    var dailyInfoSubViewContainer : UIView!
    var weatherIcon : UIImageView!
    var dateInfoLabel : UILabel!
    var startDate : NSDate!
    var endDate : NSDate!
    var arrDailyWeather : NSDictionary!
    
    
    
    var weekStartConfig : NSNumber!
    var dayTitleTextColor : UIColor!
    var selectedDatePrintFormat : String!
    var selectedDatePrintColor : UIColor!
    var selectedDatePrintFontSize : CGFloat!
    var backgroundImageColor : UIColor!
    
    var delegate : FXWeeklyCalendarViewDelegate!
    var selectedDate : NSDate!
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setDelegate(delegate : FXWeeklyCalendarViewDelegate)
    {
        self.delegate = delegate
        self.applyCustomDefaults()
        self.initbackgroundImageView()
        self.addSubview(self.backgroundImageView)
        self.arrDailyWeather = NSDictionary()
    }
    
    func applyCustomDefaults()
    {
        var attributes : NSDictionary!
        if(self.delegate != nil)
        {
            attributes = self.delegate.CLCalendarBehaviorAttributes()
            if(attributes[CLCalendarWeekStartDay] != nil){
                self.weekStartConfig = attributes[CLCalendarWeekStartDay] as! NSNumber!
            }else{
                self.weekStartConfig = NSNumber(integer: CLCalendarWeekStartDayDefault)
            }
            
            if(attributes[CLCalendarDayTitleTextColor] != nil){
                self.dayTitleTextColor = attributes[CLCalendarDayTitleTextColor] as! UIColor!
            }else{
                self.dayTitleTextColor = UIColor(rgba: "0xC2E8FF")
            }
            
            if(attributes[CLCalendarSelectedDatePrintFormat] != nil){
                self.selectedDatePrintFormat = attributes[CLCalendarSelectedDatePrintFormat] as! String!
            }else{
                self.selectedDatePrintFormat = CLCalendarSelectedDatePrintFormatDefault
            }
            
            if(attributes[CLCalendarSelectedDatePrintColor] != nil){
                self.selectedDatePrintColor = attributes[CLCalendarSelectedDatePrintColor] as! UIColor!
            }else{
                self.selectedDatePrintColor = UIColor.blackColor()
            }
            
            if(attributes[CLCalendarSelectedDatePrintFontSize] != nil){
                self.selectedDatePrintFontSize = attributes[CLCalendarSelectedDatePrintFontSize] as! CGFloat!
            }else{
                self.selectedDatePrintFontSize = CLCalendarSelectedDatePrintFontSizeDefault
            }
            
            if(attributes[CLCalendarBackgroundImageColor] != nil){
                self.backgroundImageColor = attributes[CLCalendarBackgroundImageColor] as! UIColor!
            }else{
                //self.backgroundImageColor = UIColor.lightGrayColor()
            }
            
            
            
            
            //NSLog(@"%@  %f", attributes[CLCalendarBackgroundImageColor],  self.selectedDatePrintFontSize);
            self.setNeedsDisplay()
        }
        
    }
    func initdailyInfoSubViewContainer()
    {
        if(self.dailyInfoSubViewContainer == nil){
            self.dailyInfoSubViewContainer = UIView(frame: CGRectMake(0, DATE_TITLE_MARGIN_TOP+DAY_TITLE_VIEW_HEIGHT + DATE_VIEW_HEIGHT + DATE_VIEW_MARGIN * 2, self.bounds.size.width, DATE_LABEL_INFO_HEIGHT))
            self.dailyInfoSubViewContainer.userInteractionEnabled = true
            initweatherIcon()
            initdateInfoLabel()
            //self.dailyInfoSubViewContainer.addSubview(self.weatherIcon)
            self.dailyInfoSubViewContainer.addSubview(self.dateInfoLabel)
            
            self.backgroundColor = UIColor.clearColor()
            
            var singleFingerTap = UITapGestureRecognizer(target: self, action: "dailyInfoViewDidClick:")
            self.dailyInfoSubViewContainer.addGestureRecognizer(singleFingerTap)
        }
    }
    
    
    func initweatherIcon()
    {
        if(self.weatherIcon == nil){
            self.weatherIcon = UIImageView(frame: CGRectMake(WEATHER_ICON_LEFT, WEATHER_ICON_MARGIN_TOP, WEATHER_ICON_WIDTH, WEATHER_ICON_HEIGHT))
            self.weatherIcon.backgroundColor = UIColor.blackColor()
        }
    }
    
    
    func initdateInfoLabel()
    {
        if(self.dateInfoLabel == nil){
            
            self.dateInfoLabel = UILabel(frame: CGRectMake(WEATHER_ICON_LEFT+WEATHER_ICON_WIDTH+DATE_LABEL_MARGIN_LEFT, 0, DATE_LABEL_INFO_WIDTH, DATE_LABEL_INFO_HEIGHT))
            self.dateInfoLabel.textAlignment = NSTextAlignment.Center
            self.dateInfoLabel.userInteractionEnabled = true
            self.dateInfoLabel.font = UIFont.systemFontOfSize(self.CLCalendarSelectedDatePrintFontSizeDefault)
            self.dateInfoLabel.textColor = self.selectedDatePrintColor
        }
        
    }
    
    func initdayTitleSubViewContainer()
    {
        if(self.dayTitleSubViewContainer == nil){
            self.dayTitleSubViewContainer = UIImageView(frame: CGRectMake(0, DATE_TITLE_MARGIN_TOP, self.bounds.size.width, DAY_TITLE_VIEW_HEIGHT))
            
            self.dayTitleSubViewContainer.backgroundColor = UIColor.clearColor()
            self.dayTitleSubViewContainer.userInteractionEnabled = true
            
        }
        
        
    }
    func initdailySubViewContainer()
    {
        if(self.dailySubViewContainer == nil){
            self.dailySubViewContainer = UIImageView(frame: CGRectMake(0, DATE_TITLE_MARGIN_TOP+DAY_TITLE_VIEW_HEIGHT+DATE_VIEW_MARGIN, self.bounds.size.width, DATE_VIEW_HEIGHT))
            self.dailySubViewContainer.backgroundColor = UIColor.clearColor()
            
            self.dailySubViewContainer.userInteractionEnabled = true
            
        }
        
    }
    
    
    func initbackgroundImageView()
    {
        if(self.backgroundImageView == nil){
            
            self.backgroundImageView = UIImageView(frame: CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height))
            
            
            self.backgroundImageView.userInteractionEnabled = true
            initdayTitleSubViewContainer()
            initdailySubViewContainer()
            initdailyInfoSubViewContainer()
            self.backgroundImageView.addSubview(self.dayTitleSubViewContainer)
            self.backgroundImageView.addSubview(self.dailySubViewContainer)
            self.backgroundImageView.addSubview(self.dailyInfoSubViewContainer)
            
            
            
            //Apply swipe gesture
            
            
            var recognizerRight = UISwipeGestureRecognizer(target: self, action: "swipeRight:")
            recognizerRight.delegate=self;
            recognizerRight.direction = UISwipeGestureRecognizerDirection.Right
            self.backgroundImageView.addGestureRecognizer(recognizerRight)
            
            var  recognizerLeft = UISwipeGestureRecognizer(target: self, action: "swipeLeft:")
            recognizerLeft.delegate=self;
            recognizerLeft.direction = UISwipeGestureRecognizerDirection.Left
            self.backgroundImageView.addGestureRecognizer(recognizerLeft)
            
            
            
        }
        if ( self.backgroundImageColor != nil){
            self.backgroundImageView.backgroundColor = self.backgroundImageColor
        }else{
            var color = UIColor.getColor(NSDate())
            
            
            self.backgroundImageView.backgroundColor =     color
            
        }
    }
    
    
    func initDailyViews()
    {
        
        var dailyWidth : CGFloat = (self.bounds.size.width)/CGFloat(self.WEEKLY_VIEW_COUNT)
        var today = NSDate()
        var dtWeekStart = today.getWeekStartDate(self.weekStartConfig.integerValue)
        self.startDate = dtWeekStart
        
        for  v  in self.dailySubViewContainer.subviews{
            v.removeFromSuperview()
        }
        
        
        for var i = 0; i < 7; i++ {
            var dt = dtWeekStart.addDays(i)
            
            
            
            self.initdayTitleViewForDate(dt, frame: CGRectMake(dailyWidth*CGFloat(i), 0, dailyWidth, DAY_TITLE_VIEW_HEIGHT))
            self.initdailyViewForDate(dt, frame: CGRectMake(dailyWidth*CGFloat(i), 0, dailyWidth, DATE_VIEW_HEIGHT))
            
            
            self.endDate = dt
        }
        self.dailyCalendarViewDidSelect(NSDate())
        
    }
    
    
    
    func initdayTitleViewForDate(date:NSDate, frame : CGRect)
    {
        var dayTitleLabel = FXDayTitleLabel(frame: frame)
        dayTitleLabel.backgroundColor = UIColor.clearColor()
        dayTitleLabel.textColor = self.dayTitleTextColor
        dayTitleLabel.textAlignment = NSTextAlignment.Center;
        dayTitleLabel.font = UIFont.systemFontOfSize(DAY_TITLE_FONT_SIZE)
        date.getDayOfWeekShortString()
        dayTitleLabel.text = date.getDayOfWeekShortString().uppercaseString
        dayTitleLabel.date = date
        dayTitleLabel.userInteractionEnabled = true
        
        var singleFingerTap = UITapGestureRecognizer(target: self, action: "dayTitleViewDidClick:")
        dayTitleLabel.addGestureRecognizer(singleFingerTap)
        
        self.dayTitleSubViewContainer.addSubview(dayTitleLabel)
        
    }
    
    func initdailyViewForDate(date : NSDate, frame:CGRect)->FXDayView
    {
        var view = FXDayView(frame: frame)
        view.date = date;
        view.backgroundColor = UIColor.clearColor()
        view.delegate = self
        self.dailySubViewContainer.addSubview(view)
        return view
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override  func drawRect(rect :CGRect)
    {
        // Drawing code
        
        initDailyViews()
        
    }
    
    func markDateSelected(date:NSDate)
    {
        for v  in self.dailySubViewContainer.subviews as! [FXDayView]{
            v.markSelected(v.date.isSameDateWith(date))
            
        }
        
        self.selectedDate = date;
        var dayFormatter = NSDateFormatter()
        dayFormatter.dateFormat = self.selectedDatePrintFormat
        
        var strDate = dayFormatter.stringFromDate(date)
        if(date.isDateToday()){
            strDate = "Today\(strDate)"
        }
        
        self.adjustDailyInfoLabelAndWeatherIcon(false)
        
        self.dateInfoLabel.text = strDate;
    }
    
    
    func dailyInfoViewDidClick (tap:UIGestureRecognizer)
    {
        //Click to jump back to today
        self.redrawToDate(NSDate());
    }
    
    
    func dayTitleViewDidClick(tap : UIGestureRecognizer)
    {
        self.redrawToDate((tap.view as! FXDayTitleLabel!).date)
    }
    
    
    func redrawToDate(dt : NSDate)
    {
        
        if(!dt.isWithinDate(self.startDate, laterDate: self.endDate)){
            var swipeRight = (dt.compare(self.startDate) == NSComparisonResult.OrderedAscending)
            self.delegateSwipeAnimation(swipeRight, blnToday: true, selectedDate: NSDate())
            
        }
        
        //    if(![dt isWithinDate:self.startDate toDate:self.endDate]){
        //    BOOL swipeRight = ([dt compare:self.startDate] == NSOrderedAscending);
        //    [self delegateSwipeAnimation:swipeRight blnToday:[dt isDateToday] selectedDate:dt];
        //    }
        
        self.dailyCalendarViewDidSelect(dt)
    }
    
    
    func redrawCalenderData()
    {
        self.redrawToDate(self.selectedDate)
        
    }
    
    
    func adjustDailyInfoLabelAndWeatherIcon(blnShowWeatherIcon : Bool)
    {
        self.dateInfoLabel.textAlignment = NSTextAlignment.Center
        
        
        self.dateInfoLabel.frame = CGRectMake( (self.bounds.size.width - DATE_LABEL_INFO_WIDTH)/2, 0, DATE_LABEL_INFO_WIDTH, DATE_LABEL_INFO_HEIGHT);
        
        
        //self.weatherIcon.hidden = !blnShowWeatherIcon;
    }
    
    func dailyCalendarViewDidSelect(date:NSDate)
    {
        markDateSelected(date)
        self.delegate.dailyCalendarViewDidSelect(date)
        
    }
    
    
    
    
    func swipeLeft( swipe :UISwipeGestureRecognizer)
    {
        self.delegateSwipeAnimation(false, blnToday: false, selectedDate: NSDate())
        //self.delegateSwipeAnimation(false.boolValue, blnToday:false.boolValue, selectedDate: nil)
        //[self delegateSwipeAnimation: NO blnToday:NO selectedDate:nil];
    }
    func swipeRight(swipe : UISwipeGestureRecognizer)
    {
        
        self.delegateSwipeAnimation(true, blnToday:false, selectedDate: NSDate())
        // [self delegateSwipeAnimation: YES blnToday:NO selectedDate:nil];
    }
    
    
    func delegateSwipeAnimation(blnSwipeRight:Bool, blnToday:Bool, selectedDate:NSDate)
    {
        var animation = CATransition()
        animation.delegate = self
        animation.type = kCATransitionPush
        if(blnSwipeRight)
        {animation.subtype = kCATransitionFromLeft
            
        }else{
            animation.subtype = kCATransitionFromRight
        }
        animation.duration = 0.50
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        self.dailySubViewContainer.layer.addAnimation(animation, forKey: kCATransition)
        
        var data : NSMutableDictionary = ["blnSwipeRight": NSNumber(bool: blnSwipeRight), "blnToday":NSNumber(bool: blnToday)]
        
        if(blnToday){
            data.setObject(selectedDate, forKey: "selectedDate")
            
        }
        self.performSelector(selector: "renderSwipeDates:", object: data, delay: 0.05)
        //[self performSelector:@selector(renderSwipeDates:) withObject:data afterDelay:0.05f];
    }
    
    func renderSwipeDates(param:NSDictionary)
    {
        var step = -1
        if(param.objectForKey("blnSwipeRight") as! Bool){
            step = -1
        }else{
            step = 1
        }
        
        var blnToday = param.objectForKey("blnToday") as! Bool
        
        var selectedDate = param.objectForKey("selectedDate")
        
        var  dailyWidth = self.bounds.size.width/CGFloat(WEEKLY_VIEW_COUNT)
        
        
        var dtStart : NSDate!
        if(blnToday){
            dtStart = NSDate.new().getWeekStartDate(self.weekStartConfig.integerValue)
        }else{
            if(selectedDate != nil){
                dtStart = selectedDate?.getWeekStartDate(self.weekStartConfig.integerValue)
            }else{
                dtStart = self.startDate.addDays(step*7)
            }
            
        }
        
        self.startDate = dtStart;
        for  v in self.dailySubViewContainer.subviews{
            v.removeFromSuperview()
        }
        
        for var i = 0; i < WEEKLY_VIEW_COUNT; i++ {
            var dt = dtStart.addDays(i)
            
            var view = initdailyViewForDate(dt, frame: CGRectMake(dailyWidth*CGFloat(i), 0, dailyWidth, DATE_VIEW_HEIGHT))
            
            var titleLabel = self.dayTitleSubViewContainer.subviews[i] as! FXDayTitleLabel
            titleLabel.date = dt
            view.markSelected(false)
            if(view.date.isSameDateWith(self.selectedDate)){
                view.markSelected(true)
            }
            
            self.endDate = dt
            // [view markSelected:([view.date isSameDateWith:self.selectedDate])];
            
        }
    }
    
    
    //        func updateWeatherIconByKey(key : NSString)
    //    {
    ////    if(!key){
    ////    [self adjustDailyInfoLabelAndWeatherIcon:NO];
    ////    return;
    //    }
    //
    //    self.weatherIcon.image = [UIImage imageNamed:key];
    //    [self adjustDailyInfoLabelAndWeatherIcon:YES];
    //    }
    
    
    
}

