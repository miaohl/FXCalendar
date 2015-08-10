//
//  ViewController.swift
//  FXCanlendar
//
//  Created by 缪海露 on 15/8/10.
//  Copyright (c) 2015年 缪海露. All rights reserved.
//

import UIKit

class ViewController: UIViewController ,FXWeeklyCalendarViewDelegate{
    
    var calendarView : FXWeeklyCalendarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView = FXWeeklyCalendarView(frame: CGRectMake(0, 0, self.view.bounds.size.width, 120))
        self.calendarView.setDelegate(self)
        self.view.addSubview(self.calendarView)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func dailyCalendarViewDidSelect(date : NSDate){
        println(date)
    }
    
    func CLCalendarBehaviorAttributes()->NSDictionary
    {
        var dic : NSDictionary = ["CLCalendarWeekStartDay":1]
        
        return dic
    }
}
