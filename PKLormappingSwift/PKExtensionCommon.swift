//
//  PKExtensionCommon.swift
//  PKlormTest
//
//  Created by 周经伟 on 15/7/15.
//  Copyright (c) 2015年 packy. All rights reserved.
//

import Foundation

extension Character{
    /*character类型转Int32类型*/
    func toInt32()->Int32{
        var int32:Int32 = Int32()
        var intSys:Int = Int()
        for utfInt in String(self).utf8
        {
            //这个循环只会执行1次
            intSys = Int(utfInt)
        }
        int32 = Int32(intSys)
        return int32
    }
    
}

extension String{
    func length()->Int{
        return count(self)
    }
}

extension NSObject{
    
    /*获取类型名*/
    func getClassName()->String{
        var className:String = NSStringFromClass(self.classForCoder)
        var spiltName:[String] = className.componentsSeparatedByString(".")
        if spiltName.count > 1{
            className = spiltName[1]
        }
        return className
    }
    
    /*获取表名*/
    func getTableName()->String{
        var className:String = NSStringFromClass(self.classForCoder)
        var spiltName:[String] = className.componentsSeparatedByString(".")
        if spiltName.count > 1{
            className = spiltName[1]
        }
        var tableName:String = PKCharacterOperate.humpCharacterOperate(className)
        return tableName
    }
    
    /*获取属性列表*/
    func getPropertys()->Array<ClassBean>{
        var propertys:Array<ClassBean> = self.objectWithPropertysBesiderType(type: "PKArray", propertys: self.objectWithPropertys())
        return propertys
    }
    
    /*获取属性映射的表列名列表*/
    func getColumns()->Array<TableBean>{
        var columns:Array<TableBean> = Array<TableBean>()
        var propertys:Array<ClassBean> = self.getPropertys()
        for classBean:ClassBean in propertys{
            let name = PKCharacterOperate.humpCharacterOperate(classBean.propertyName)
            let type = PKCharacterOperate.objTypeTranslateDataType(classBean.propertyType)
            columns.append(TableBean(columnName:name,columnType:type))
        }
        return columns
    }
    
    /*只获取type类型的属性信息*/
    func getOnlyTypeObject(#type:String)->Array<ClassBean>{
        var targetArray:Array<ClassBean> = Array<ClassBean>()
        for classBean:ClassBean in self.objectWithPropertys(){
            if classBean.propertyType.rangeOfString("PKArray", options: nil, range: nil, locale: nil) != nil
            {
                targetArray.append(classBean)
            }
        }
        return targetArray
    }
    
    /*利用反射，获取除super外的所有属性和类型*/
    private func objectWithPropertys()->Array<ClassBean>{
        var targetArray:Array<ClassBean> = Array<ClassBean>()
        let mirror:MirrorType = reflect(self)
        let count = mirror.count
        
        for var i = 0 ; i < count ; i++ {
            let name:String = mirror[i].0
            if name == "super" && i == 0 {
                continue
            }
//            println(mirror[i].1.valueType)
            var type:String = PKCharacterOperate.objectWithPropertysType(mirror[i].1.valueType)
            var spiltType:[String] = type.componentsSeparatedByString(".")
            if spiltType.count > 1{
                type = spiltType[1]
            }
//            println("\(name) : \(mirror[i].1.valueType)")
            targetArray.append( ClassBean(propertyName:name,propertyType:type))
        }
        return targetArray
    }
    
    /*获取除type类型外的所有属性信息*/
    private func objectWithPropertysBesiderType(#type:String,propertys:Array<ClassBean>)->Array<ClassBean>{
        var targetArray:Array<ClassBean> = Array<ClassBean>()
        for classBean:ClassBean in propertys{
            if classBean.propertyType.rangeOfString("PKArray", options: nil, range: nil, locale: nil) != nil
            {
                continue
            }
            targetArray.append(classBean)
        }
        return targetArray
    }
    
}