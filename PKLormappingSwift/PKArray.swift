//
//  PKArray.swift
//  PKlormTest
//
//  Created by 周经伟 on 15/7/17.
//  Copyright (c) 2015年 packy. All rights reserved.
//

import Foundation

public class PKArray: NSObject{
    /*
    *  T ：映射数组的对象class
    *  foreignKeyMapping : 外键映射 ,key 为主键 （主表）, value 为外键 (从表)
    *  如：{ id : userId } 对应数据库语句 -> id （主表）=  userId （从表）
    */
    var resultArray:NSArray = []
//    var entityClass:AnyClass?
//    var entityObject:AnyObject?
    var entityNSObject = NSObject()
//    var entityAny:Any?
   
   public var foreginKeyMapping:Dictionary<String,String>?;//外键映射
    
    override init() {
        super.init()
    }
    
//    init(entityClass:AnyClass) {
//        super.init()
//        self.entityClass = entityClass
//    }
//    
//    init(entityObject:AnyObject) {
//        super.init()
//        self.entityObject = entityObject
//    }
    
    public init(entityNSObject:NSObject) {
        super.init()
        self.entityNSObject = entityNSObject
    }
    
//    init(entityAny:Any) {
//        super.init()
//        self.entityAny = entityAny
//    }
    
    func count()->Int {
        return resultArray.count
    }
    
//    /*
//    *   创建实体
//    */
//    func returnElement()->AnyObject{
//        return entityClass!.alloc();
//    }
    
    subscript(index:Int)->AnyObject{
        get{
            var entity:AnyObject = self.resultArray.objectAtIndex(index)
            return entity
        }
    }
}
