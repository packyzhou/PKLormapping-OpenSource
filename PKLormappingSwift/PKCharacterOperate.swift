//
//  PKCharacterOperate.swift
//  PKlormTest
//
//  Created by 周经伟 on 15/7/15.
//  Copyright (c) 2015年 packy. All rights reserved.
//

import Foundation

class PKCharacterOperate: NSObject {
    
    /*  驼峰字符串处理成数据库字符串
    *  如：userInfo -> USER_INFO
    */
    class func humpCharacterOperate(str:String) -> String{
        var targetChar:String = "";
        var startId:Int = 0;
        var endId:Int = 0;
        var i = 0
        for c in str
        {
            if(isupper(c.toInt32()) != Int32(0)  && endId != 0){
                //大写
                var range = NSMakeRange(startId,endId)
                targetChar+=(str as NSString).substringWithRange(range).uppercaseString
                targetChar+="_"
                startId = i
                endId = 0
            }else if(i == count(str)-1){
                var range = NSMakeRange(startId,endId+1)
                targetChar+=(str as NSString).substringWithRange(range).uppercaseString
            }
            endId++
            i++
        }
        return targetChar;
    }
    
    /*
    *   判断属性类型
    *   返回String类型
    */
    class func objectWithPropertysType(type:Any.Type) -> String{
        switch type {
        case _ as String.Type:return "String"
        case _ as String?.Type:return "String"
        case _ as Character.Type:return "String"
        case _ as Character?.Type:return "String"
        case _ as Int.Type:return "Int"
        case _ as Int?.Type:return "Int"
        case _ as Double.Type:return "Double"
        case _ as Double?.Type:return "Double"
        case _ as Float.Type:return "Float"
        case _ as Float?.Type:return "Float"
        case _ as Bool.Type:return "Bool"
        case _ as Bool?.Type:return "Bool"
        case _ as Array<Any.Type>.Type:return "Array"
        case _ as Array<Any.Type>?.Type:return "Array"
        case _ as Array<AnyObject>.Type:return "Array"
        case _ as Array<AnyObject>?.Type:return "Array"
         
        case _ as NSString.Type:return "NSString"
        case _ as NSString?.Type:return "NSString"
        case _ as NSNumber.Type:return "NSNumber"
        case _ as NSNumber?.Type:return "NSNumber"
        case _ as NSNumber.Type:return "NSNumber"
        case _ as NSNumber?.Type:return "NSNumber"
        case _ as NSDate.Type:return "NSDate"
        case _ as NSDate?.Type:return "NSDate"
        case _ as NSArray.Type:return "NSArray"
        case _ as NSArray?.Type:return "NSArray"
        case _ as PKArray.Type:return "PKArray"
        case _ as PKArray?.Type:return "PKArray"
        default:
            
            var unknowType = "\(type)"
            var unknowSpilt = unknowType.componentsSeparatedByString(".")
            if unknowSpilt.count > 0{
                unknowType = unknowType.componentsSeparatedByString(".")[1]
            }
            if unknowType.rangeOfString("PKArray", options: nil, range: nil, locale: nil) != nil && unknowSpilt.count > 1{
                unknowType = "PKArray<\(unknowSpilt[2])"
            }
            
            return unknowType
        }
    }
    
    /*
    *   根据属性类型返回列类型
    */
    
    class func objTypeTranslateDataType(type:String)->String{
        if type == "String" || type == "NSString"{
            return "TEXT"
        }else if(type == "Int" || type == "NSInteger"){
            return "INTEGER"
        }else if(type == "Bool" ){
            return "Boolean"
        }else if(type == "NSDate" ){
            return "Timestamp"
        }else if(type == "NSData" ){
            return "BLOB"
        }else if(type == "Double" ){
            return "Double"
        }else if(type == "Float" ){
            return "Float"
        }else if(type == "Double" ){
            return "Double"
        }else if(type == "NSNumber" ){
            return "Double"
        }
        return ""
    }
    
    /*
    *   匹配额外类型
    */
    
    class func extraMapping(value:AnyObject,type:String?) -> AnyObject{
        if type == "NSString" || type == "String" || type == "Character" {
            return "'\(value)'"
        }else if type == "NSDate" {
            var date:String = PKDateUnit.dateFormatterString(date: value as! NSDate, formatter: "yyyy-MM-dd HH:mm:ss")
            return "'\(date)'"
        }
        return value
    }
}


