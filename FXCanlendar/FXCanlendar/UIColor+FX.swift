//
//  UIColor+FX.swift
//  ncapprove
//
//  Created by 缪海露 on 15/8/9.
//  Copyright (c) 2015年  user. All rights reserved.
//

import Foundation
import UIKit
let UIColorMon = UIColor(red: 0/255, green: 191/255, blue: 255/255, alpha: 0.5)

let UIColorTues = UIColor(red: 95/255, green: 158/255, blue: 160/255, alpha: 0.5)

let UIColorWed = UIColor(red: 30/255, green: 144/255, blue: 255/255, alpha: 0.5)

let UIColorThur = UIColor(red: 0/255, green: 0/255, blue: 128/255, alpha: 0.5)

let UIColorFri = UIColor(red: 25/255, green: 25/255, blue: 112/255, alpha: 0.5)

let UIColorSat = UIColor(red: 138/255, green: 43/255, blue: 226/255, alpha: 0.5)

let UIColorSun = UIColor(red: 220/255, green: 20/255, blue: 60/255, alpha: 0.5)

extension UIColor{

    public convenience init(rgba:String) {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 1.0
        
        if rgba.hasPrefix("#") {
            let index = advance(rgba.startIndex,1)
            let hex = rgba.substringFromIndex(index)
            let scanner = NSScanner(string: hex)
            var hexValue: CUnsignedLongLong = 0
            if scanner.scanHexLongLong(&hexValue) {
                switch (count(hex)) {
                case 3:
                    red = CGFloat((hexValue & 0xF00) >> 8) / 15.0
                    green = CGFloat((hexValue & 0x0F0) >> 4) / 15.0
                    blue = CGFloat(hexValue & 0x00F) / 15.0
                case 4:
                    red = CGFloat((hexValue & 0xF000) >> 12) / 15.0
                    green = CGFloat((hexValue & 0x0F00) >> 8) / 15.0
                    blue = CGFloat((hexValue & 0x00F0) >> 4) / 15.0
                    alpha = CGFloat(hexValue & 0x000F) / 15.0
                case 6:
                    red = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
                    green = CGFloat((hexValue & 0x00FF00) >> 8) / 255.0
                    blue = CGFloat(hexValue & 0x0000FF) / 255.0
                case 8:
                    red = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                    green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                    blue = CGFloat((hexValue & 0x0000FF00) >> 8) / 255.0
                    alpha = CGFloat(hexValue & 0x000000FF) / 255.0
                default:
                    print("Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8")
                }
            } else {
                println("Scan hex error")
            }
        } else {
            print("Invalid RGB string, missing '#' as prefix")
        }
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }

    static func getColor(date:NSDate) ->UIColor{
        var week = date.getDayOfWeekShortString()
        switch week{
        case "周一" : return UIColorMon
        case "周二" : return UIColorTues
        case "周三" : return UIColorWed
        case "周四" : return UIColorThur
        case "周五" : return UIColorFri
        case "周六" : return UIColorSat
        case "周日" : return UIColorSun
        default : return UIColor.whiteColor()
        }
    }
    
}