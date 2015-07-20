//
//  PKHQLer.swift
//  PKlormTest
//
//  Created by 周经伟 on 15/7/16.
//  Copyright (c) 2015年 packy. All rights reserved.
//

import Foundation

protocol PKHQLerProtocol{
    
    /*
    *   根据HQL帮助类返回查询条件
    */
    func getHQL()->String
    
    /*添加等于比较条件
    * key为列名，value为值
    * 如:id == 1
    */
    func addEqual(key:String?,value:AnyObject?)->PKHQLer
    
    /*添加不等于比较条件
    * key为列名，value为值
    * 如:id != 1
    */
    func addNotEqual(key:String?,value:AnyObject?)->PKHQLer
    
    /*添加前后模糊查询条件
    * key为列名，value为值
    * 如:name like '%tom%'
    */
    func addLike(key:String?,value:AnyObject?)->PKHQLer
    
    /*添加非前后模糊查询条件
    * key为列名，value为值
    * 如:name not like '%tom%'
    */
    func addNotLike(key:String?,value:AnyObject?)->PKHQLer
    
    /*添加前置模糊查询条件
    * key为列名，value为值
    * 如:name like '%tom'
    */
    func addStartLike(key:String?,value:AnyObject?)->PKHQLer
    
    /*添加后置模糊查询条件
    * key为列名，value为值
    * 如:name like 'tom%'
    */
    func addEndLike(key:String?,value:AnyObject?)->PKHQLer
    
    /*添加in 查询条件
    * key为列名，value为值
    * 如:id in (1,2,3)
    */
    func addIn(key:String?,value:Array<AnyObject>?)->PKHQLer
    
    /*添加not in 查询条件
    * key为列名，value为值
    * 如:id not in (1,2,3)
    */
    func addNotIn(key:String?,value:Array<AnyObject>?)->PKHQLer
    
    /*添加 is null 查询条件
    * key为列名，value为值
    * 如:is null
    */
    func addIsNull(key:String?)->PKHQLer
    
    /*添加 is not null 查询条件
    * key为列名，value为值
    * 如:id not in (1,2,3)
    */
    func addNotNull(key:String?)->PKHQLer
    
    /*添加 小于 查询条件
    * key为列名，value为值
    * 如: id < 100
    */
    func addLessThan(key:String?,value:AnyObject?)->PKHQLer
    
    /*添加 小于 查询条件
    * key为列名，value为值
    * 如: id <= 100
    */
    func addLessEqualThan(key:String?,value:AnyObject?)->PKHQLer
    
    /*添加 大于 查询条件
    * key为列名，value为值
    * 如: id > 100
    */
    func addGreatThan(key:String?,value:AnyObject?)->PKHQLer
    
    /*添加 大于等于 查询条件
    * key为列名，value为值
    * 如: id >= 100
    */
    func addGreatEqualThan(key:String?,value:AnyObject?)->PKHQLer
    
    /*添加 日期之间 查询条件
    * key为列名，startDate为开始时间 ，endDate 为结束时间
    * 如: date between '2015-02-20' and '2015-02-23'
    */
    func addBetweenDate(key:String?,startDate:String?,endDate:String?)->PKHQLer
    
    /*添加 等于日期 查询条件
    * key为列名，value为值
    * 如: date < '2015-02-20'
    */
    func addEqualDate(key:String?,date:String?)->PKHQLer
    
    /*添加 小于日期 查询条件
    * key为列名，value为值
    * 如: date < '2015-02-20'
    */
    func addLessDate(key:String?,date:String?)->PKHQLer
    
    /*添加 小于等于日期 查询条件
    * key为列名，value为值
    * 如: date <＝ '2015-02-20'
    */
    func addLessEqualDate(key:String?,date:String?)->PKHQLer
    
    /*添加 大于日期 查询条件
    * key为列名，value为值
    * 如: date > '2015-02-20'
    */
    func addGreatDate(key:String?,date:String?)->PKHQLer
    
    /*添加 大于等于日期 查询条件
    * key为列名，value为值
    * 如: date >= '2015-02-20'
    */
    func addGreatEqualDate(key:String?,date:String?)->PKHQLer
    
    /*
    *添加 or 查询条件
    */
    func addOr(hql:PKHQLer?)->PKHQLer
    
    /*
    *添加 全部为 or 查询条件
    */
    func addAllOr(hql:PKHQLer?)->PKHQLer
    
    /*添加 排序
    * key为列名，type为 "desc" or "asc"
    * 如: order by id asc
    */
    func addOrderBy(key:String?,type:String?)->PKHQLer
}

public class PKHQLer: NSObject,PKHQLerProtocol {
    private var queryCondition:String = "" //查询条件
    private var orderByCondition:String = "" //排序条件
    public var queryPage:PKQueryPage?  //分页
    
    public func getHQL()->String{
        var sql:String = ""
        if queryCondition != "" {
            sql += " where \(queryCondition)"
        }
        if orderByCondition != "" {
            sql += " order by \(orderByCondition)"
        }
        if queryPage != nil {
            sql += " limit \(queryPage!.rows) offset \(queryPage!.page*queryPage!.rows)"
        }
        return sql
    }
    
    /*添加等于比较条件
    * key为列名，value为值
    * 如:id == 1
    */
   public func addEqual(key:String?,value:AnyObject?)->PKHQLer{
        if key == nil  || key == "" ||  value == nil{
            return self
        }
        if queryCondition != "" {
            queryCondition += " and "
        }
        
        var resultValue: AnyObject = PKCharacterOperate.extraMapping(value!, type:"\(value!.classForCoder)")
        queryCondition += "\(key!) = \(resultValue)"
        return self
    }
    
    /*添加不等于比较条件
    * key为列名，value为值
    * 如:id != 1
    */
   public func addNotEqual(key:String?,value:AnyObject?)->PKHQLer{
        if key == nil  || key == "" ||  value == nil{
            return self
        }
        if queryCondition != "" {
            queryCondition += " and "
        }
        
        var resultValue: AnyObject = PKCharacterOperate.extraMapping(value!, type:"\(value!.classForCoder)")
        queryCondition += "\(key!) != \(resultValue)"
        return self
    }
    
    /*添加前后模糊查询条件
    * key为列名，value为值
    * 如:name like '%tom%'
    */
   public func addLike(key:String?,value:AnyObject?)->PKHQLer{
        
        if key == nil  || key == "" ||  value == nil{
            return self
        }
        if queryCondition != "" {
            queryCondition += " and "
        }
        
        queryCondition += "\(key!) like '%\(value!)%'"
        return self;
    }
    
    /*添加非前后模糊查询条件
    * key为列名，value为值
    * 如:name not like '%tom%'
    */
   public func addNotLike(key:String?,value:AnyObject?)->PKHQLer{
        if key == nil  || key == "" ||  value == nil{
            return self
        }
        if queryCondition != "" {
            queryCondition += " and "
        }
        
        queryCondition += "\(key!) not like '%\(value!)%'"
        return self
    }
    
    /*添加前置模糊查询条件
    * key为列名，value为值
    * 如:name like '%tom'
    */
   public func addStartLike(key:String?,value:AnyObject?)->PKHQLer{
        if key == nil  || key == "" ||  value == nil{
            return self
        }
        if queryCondition != "" {
            queryCondition += " and "
        }
        
        queryCondition += "\(key!) like '%\(value!)'"
        return self
    }
    
    /*添加后置模糊查询条件
    * key为列名，value为值
    * 如:name like 'tom%'
    */
   public func addEndLike(key:String?,value:AnyObject?)->PKHQLer{
        if key == nil  || key == "" ||  value == nil{
            return self
        }
        if queryCondition != "" {
            queryCondition += " and "
        }
        
        queryCondition += "\(key!) like '\(value!)%'"
        return self
    }
    
    /*添加in 查询条件
    * key为列名，value为值
    * 如:id in (1,2,3)
    */
   public func addIn(key:String?,value:Array<AnyObject>?)->PKHQLer{
        if key == nil  || key == "" ||  value == nil{
            return self
        }
        if queryCondition != "" {
            queryCondition += " and "
        }
        
        queryCondition += "\(key!) in ("
        
        for var i = 0 ; i < value!.count ; i++ {
            var rs:AnyObject = value![i]
            rs = PKCharacterOperate.extraMapping(rs, type: "\(rs.classForCoder)")
            if value?.count == (i+1) {
                queryCondition += "\(rs) "
            }else{
                queryCondition += "\(rs),"
            }
        }
        
        queryCondition += ")"
        return self;

    }
    
    /*添加not in 查询条件
    * key为列名，value为值
    * 如:id not in (1,2,3)
    */
   public func addNotIn(key:String?,value:Array<AnyObject>?)->PKHQLer{
        if key == nil  || key == "" ||  value == nil{
            return self
        }
        if queryCondition != "" {
            queryCondition += " and "
        }
        
        queryCondition += "\(key!) not in ("
        
        for var i = 0 ; i < value!.count ; i++ {
            var rs:AnyObject = value![i]
            rs = PKCharacterOperate.extraMapping(rs, type: "\(rs.classForCoder)")
            if value?.count == (i+1) {
                queryCondition += "\(rs) "
            }else{
                queryCondition += "\(rs),"
            }
        }
        
        queryCondition += ")"
        return self;
    }
    
    /*添加 is null 查询条件
    * key为列名
    * 如:is null
    */
   public func addIsNull(key:String?)->PKHQLer{
        if key == nil {
            return self
        }
        
        
        if queryCondition != "" {
            queryCondition += " and "
        }
        
        queryCondition += "\(key!) is null"
       
        return self;
    }
    
    /*添加 is not null 查询条件
    * key为列名
    * 如:id not null
    */
   public func addNotNull(key:String?)->PKHQLer{
        if key == nil {
            return self
        }
        
        
        if queryCondition != "" {
            queryCondition += " and "
        }
        
        queryCondition += "\(key!) is not null"
        
        return self;
    }
    
    /*添加 小于 查询条件
    * key为列名，value为值
    * 如: id < 100
    */
   public func addLessThan(key:String?,value:AnyObject?)->PKHQLer{
        if key == nil  || key == "" ||  value == nil{
            return self
        }
        if queryCondition != "" {
            queryCondition += " and "
        }
        var resultValue: AnyObject = PKCharacterOperate.extraMapping(value!, type:"\(value!.classForCoder)")
        queryCondition += "\(key!) < \(resultValue)"
        return self;
    }
    
    /*添加 小于 查询条件
    * key为列名，value为值
    * 如: id <= 100
    */
   public func addLessEqualThan(key:String?,value:AnyObject?)->PKHQLer{
        if key == nil  || key == "" ||  value == nil{
            return self
        }
        if queryCondition != "" {
            queryCondition += " and "
        }
        var resultValue: AnyObject = PKCharacterOperate.extraMapping(value!, type:"\(value!.classForCoder)")
        queryCondition += "\(key!) <= \(resultValue)"
        return self;
    }
    
    /*添加 大于 查询条件
    * key为列名，value为值
    * 如: id > 100
    */
   public func addGreatThan(key:String?,value:AnyObject?)->PKHQLer{
        if key == nil  || key == "" ||  value == nil{
            return self
        }
        if queryCondition != "" {
            queryCondition += " and "
        }
        var resultValue: AnyObject = PKCharacterOperate.extraMapping(value!, type:"\(value!.classForCoder)")
        queryCondition += "\(key!) > \(resultValue)"
        return self;
    }
    
    /*添加 大于等于 查询条件
    * key为列名，value为值
    * 如: id >= 100
    */
   public func addGreatEqualThan(key:String?,value:AnyObject?)->PKHQLer{
        if key == nil  || key == "" ||  value == nil{
            return self
        }
        if queryCondition != "" {
            queryCondition += " and "
        }
        var resultValue: AnyObject = PKCharacterOperate.extraMapping(value!, type:"\(value!.classForCoder)")
        queryCondition += "\(key!) >= \(resultValue)"
        return self;
    }
    
    /*添加 日期之间 查询条件
    * key为列名，startDate为开始时间 ，endDate 为结束时间
    * 如: date between '2015-02-20' and '2015-02-23'
    */
   public func addBetweenDate(key:String?,startDate:String?,endDate:String?)->PKHQLer{
        if key == nil  || key == "" ||  startDate == nil || endDate == nil{
            return self
        }
        if queryCondition != "" {
            queryCondition += " and "
        }
        queryCondition += "\(key!) between '\(startDate!)' and '\(endDate!)'"
        return self;
    }
    
    /*添加 等于日期 查询条件
    * key为列名，date为值
    * 如: date = '2015-02-20'
    */
   public func addEqualDate(key:String?,date:String?)->PKHQLer{
        if key == nil  || key == "" ||  date == nil{
            return self
        }
        if queryCondition != "" {
            queryCondition += " and "
        }
       
        queryCondition += "\(key!) = '\(date!)'"
        return self;
    }
    
    /*添加 小于日期 查询条件
    * key为列名，date为值
    * 如: date < '2015-02-20'
    */
   public func addLessDate(key:String?,date:String?)->PKHQLer{
        if key == nil  || key == "" ||  date == nil{
            return self
        }
        if queryCondition != "" {
            queryCondition += " and "
        }
        
        queryCondition += "\(key!) < '\(date!)'"
        return self;

    }
    
    /*添加 小于等于日期 查询条件
    * key为列名，value为值
    * 如: date <＝ '2015-02-20'
    */
   public func addLessEqualDate(key:String?,date:String?)->PKHQLer{
        if key == nil  || key == "" ||  date == nil{
            return self
        }
        if queryCondition != "" {
            queryCondition += " and "
        }
        
        queryCondition += "\(key!) <= '\(date!)'"
        return self;
    }
    
    /*添加 大于日期 查询条件
    * key为列名，value为值
    * 如: date > '2015-02-20'
    */
   public func addGreatDate(key:String?,date:String?)->PKHQLer{
        if key == nil  || key == "" ||  date == nil{
            return self
        }
        if queryCondition != "" {
            queryCondition += " and "
        }
        
        queryCondition += "\(key!) > '\(date!)'"
        return self;
    }
    
    /*添加 大于等于日期 查询条件
    * key为列名，value为值
    * 如: date >= '2015-02-20'
    */
   public func addGreatEqualDate(key:String?,date:String?)->PKHQLer{
        if key == nil  || key == "" ||  date == nil{
            return self
        }
        if queryCondition != "" {
            queryCondition += " and "
        }
        
        queryCondition += "\(key!) >= '\(date!)'"
        return self;
    }
    
    /*
    *添加 or 查询条件
    */
   public func addOr(hql:PKHQLer?)->PKHQLer{
        if hql == nil || hql!.getHQL() == ""{
            return self
        }
        if queryCondition != "" {
            queryCondition += " or "
        }
        
        var newHQL:String = hql!.getHQL().stringByReplacingOccurrencesOfString("where", withString: "", options: nil, range: nil)
        queryCondition += "(\(newHQL))"
        return self
    }
    
    /*
    *添加 全部为 or 查询条件
    */
   public func addAllOr(hql:PKHQLer?)->PKHQLer{
        if hql == nil || hql!.getHQL() == ""{
            return self
        }
        if queryCondition != "" {
            queryCondition += " or "
        }
        var newHQL:String = hql!.getHQL().stringByReplacingOccurrencesOfString("where", withString: "", options: nil, range: nil)
        var orReplace:String = newHQL.stringByReplacingOccurrencesOfString("and", withString: "or", options: nil, range: nil)
        queryCondition += "(\(newHQL))"
        return self
    }
    
    /*添加 排序
    * key为列名，type为 "desc" or "asc"
    * 如: order by id asc
    */
   public func addOrderBy(key:String?,type:String?)->PKHQLer{
        if key == nil || type == nil {
            return self
        }
        
        if orderByCondition == "" {
            orderByCondition += "\(key!) "
        }else{
            orderByCondition += ",\(key!) "
        }
        
        if orderByCondition.rangeOfString("asc", options: nil, range: nil, locale: nil) != nil{
            orderByCondition = orderByCondition.stringByReplacingOccurrencesOfString("asc", withString: "", options: nil, range: nil)
        }
        if orderByCondition.rangeOfString("desc", options: nil, range: nil, locale: nil) != nil{
            orderByCondition = orderByCondition.stringByReplacingOccurrencesOfString("desc", withString: "", options: nil, range: nil)
        }
        orderByCondition += "\(type!)"
       return self
    }
}
