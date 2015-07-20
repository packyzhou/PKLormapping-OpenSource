//
//  PKDateUnit.swift
//  PKlormTest
//
//  Created by 周经伟 on 15/7/16.
//  Copyright (c) 2015年 packy. All rights reserved.
//

import Foundation

public class PKDateUnit: NSObject {
    
    /*
    *  date类型转string类型
    */
   public class func dateFormatterString(#date:NSDate , formatter:String) ->String{
        var dateformat:NSDateFormatter = NSDateFormatter()
        dateformat.dateFormat = formatter
        return dateformat.stringFromDate(date)
    }
    
    /*
    *  获取当前时间 ,格式 :yyyy-MM-dd hh:mm:ss
    *   返回string
    */
   public class func nowDate()-> String {
        var dateformat:NSDateFormatter = NSDateFormatter()
        dateformat.dateFormat = "yyyy-MM-dd hh:mm:ss"
        return dateformat.stringFromDate(NSDate())
    }
    
    /*
    *  string类型转date类型
    */
   public class func stringFormatterDate(#dateStr:String , formatter:String) ->NSDate{
        var dateformat:NSDateFormatter = NSDateFormatter()
        var timeZone:NSTimeZone = NSTimeZone.systemTimeZone()
        dateformat.timeZone = timeZone
        dateformat.dateFormat = formatter
        return dateformat.dateFromString(dateStr)!
    }

}
