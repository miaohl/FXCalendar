//
//  FXDayView.swift
//  ncapprove
//
//  Created by 缪海露 on 15/8/8.
//  Copyright (c) 2015年  user. All rights reserved.
//

import UIKit

protocol DailyCalendarViewDelegate
{
    func dailyCalendarViewDidSelect(date : NSDate)
}

class FXDayView: UIView {
    
    
    
    let DATE_LABEL_SIZE : CGFloat = 28
    let DATE_LABEL_FONT_SIZE : CGFloat = 13
    
    var dateLabel :UILabel!
    var dateLabelContainer : UIView!
    
    
    
    var delegate : DailyCalendarViewDelegate!
    var date : NSDate!
    var blnSelected : Bool!
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initdateLabelContainer()
        self.addSubview(self.dateLabelContainer)
        var singleFingerTap = UITapGestureRecognizer(target: self, action: "dailyViewDidClick:")
        self.addGestureRecognizer(singleFingerTap)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func initdateLabelContainer()
    {
        if(dateLabelContainer == nil){
            var x = (self.bounds.size.width-DATE_LABEL_SIZE)/2
            
            self.dateLabelContainer = UIView(frame: CGRectMake(x, 0, DATE_LABEL_SIZE, DATE_LABEL_SIZE))
            
            self.dateLabelContainer.backgroundColor = UIColor.clearColor()
            self.dateLabelContainer.layer.cornerRadius = DATE_LABEL_SIZE/2;
            self.dateLabelContainer.clipsToBounds = true
            initdateLabel()
            self.dateLabelContainer.addSubview(self.dateLabel)
        }
        
    }
    
    func initdateLabel(){
        if(self.dateLabel == nil){
            
            self.dateLabel = UILabel(frame: CGRectMake(0, 0, DATE_LABEL_SIZE, DATE_LABEL_SIZE))
            
            self.dateLabel.backgroundColor = UIColor.clearColor()
            self.dateLabel.textColor = UIColor.whiteColor()
            self.dateLabel.textAlignment = NSTextAlignment.Center
            
            self.dateLabel.font = UIFont.systemFontOfSize(DATE_LABEL_FONT_SIZE)
            
        }
    }
    
    
    
    
    
    override func drawRect(rect : CGRect)
    {
        self.dateLabel.text = self.date.getDateOfMonth() as String
     
    }
    
    func markSelected(blnSelected : Bool)
    {
    
    if(self.date.isDateToday()){
        if(blnSelected)
        {
            self.dateLabelContainer.backgroundColor = UIColor.whiteColor()
            self.dateLabel.textColor = UIColor(rgba: "0x0081c1")
        }
        else{
         self.dateLabelContainer.backgroundColor = UIColor(rgba: "0x0081c1")
            self.dateLabel.textColor = UIColor.whiteColor()
        }
    
        }else{
        if(blnSelected)
        {
            self.dateLabelContainer.backgroundColor = UIColor.whiteColor()
            self.dateLabel.textColor = UIColor(red: 52/255, green: 161/255, blue: 255/255, alpha: 1)
        }
        else{
            self.dateLabelContainer.backgroundColor = UIColor.clearColor()
            self.dateLabel.textColor = self.colorByDate()
        }
    
    }
    
    
    
    
    }
    func colorByDate()->UIColor
    {
        if(self.date.isPastDate()){
            return UIColor(rgba: "0x7BD1FF")
        }else{
            return UIColor.blackColor()
        }
    
    }
    
    func dailyViewDidClick ( tap : UIGestureRecognizer)
    {
        self.delegate.dailyCalendarViewDidSelect(self.date)
    
    }

    
}
