//
//  NSDate+FX.swift
//  ncapprove
//
//  Created by 缪海露 on 15/8/9.
//  Copyright (c) 2015年  user. All rights reserved.
//

import Foundation

extension NSDate{
    
    
    
    func getWeekStartDate(weekStartIndex:NSInteger)->NSDate
    {
        var weekDay : NSInteger = self.getWeekDay().integerValue
        
        var gap : NSInteger = weekDay
        if(weekStartIndex > weekDay){
            gap = 7 + weekDay
        }
        
        var  day = weekStartIndex - gap
        
        return self.addDays(day)
    }
    
    func getWeekDay()->NSNumber
    {
        var gregorian = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        
        var comps = gregorian?.components(NSCalendarUnit.CalendarUnitWeekday, fromDate: self)
        
        return NSNumber(integer: comps!.weekday-1)
    }
    
    
    func addDays(day:NSInteger)->NSDate
    {
        var dayComponent = NSDateComponents()
        dayComponent.day = day;
        
        var theCalendar = NSCalendar.currentCalendar()
        return   theCalendar.dateByAddingComponents(dayComponent, toDate: self, options: NSCalendarOptions.allZeros)!
        
    }
    
    
    
    func getDayOfWeekShortString()->NSString
    {
        let  shortDayOfWeekFormatter = NSDateFormatter()
        
        
        var en_AU_POSIX = NSLocale(localeIdentifier: "zh-Hans")  //en_AU_POSIX
        shortDayOfWeekFormatter.locale=en_AU_POSIX
        shortDayOfWeekFormatter.dateFormat = "E"
        
        
        return shortDayOfWeekFormatter.stringFromDate(self)
    }
    
    func getDateOfMonth()->NSString
    {
        let  shortDayOfWeekFormatter = NSDateFormatter()
        
        
        var en_AU_POSIX = NSLocale(localeIdentifier: "zh-Hans")  //en_AU_POSIX
        shortDayOfWeekFormatter.locale = en_AU_POSIX
        shortDayOfWeekFormatter.dateFormat = "d"
        
        return shortDayOfWeekFormatter.stringFromDate(self)
    }
    
    func midnightDate()->NSDate {
        return NSCalendar.currentCalendar().dateFromComponents(NSCalendar.currentCalendar().components((NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.DayCalendarUnit), fromDate: self))!
        
    }
    func isSameDateWith(dt:NSDate)->Bool{
         
        return  self.midnightDate().isEqualToDate(dt.midnightDate())
    }
    func isDateToday()->Bool {
        return NSDate().midnightDate().isEqual(self.midnightDate())
    }
    
    
    func isWithinDate(earlierDate:NSDate, laterDate:NSDate)->Bool
    {
        var timestamp = self.midnightDate().timeIntervalSince1970
        var fdt = earlierDate.midnightDate()
        var tdt = laterDate.midnightDate()
        
        var isWithinDate =  timestamp >= fdt.timeIntervalSince1970  && timestamp <=  tdt.timeIntervalSince1970
        
        return isWithinDate;
        
    }
    
    func isPastDate()->Bool {
        var now =  NSDate()
        
        if(now.earlierDate(self).isEqualToDate(self)) {
            return true
        } else {
            return false
        }
    }
    
    
}