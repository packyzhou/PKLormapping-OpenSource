//
//  PKDataBaseAccess.swift
//  PKlormTest
//
//  Created by 周经伟 on 15/7/18.
//  Copyright (c) 2015年 packy. All rights reserved.
//

import Foundation

public protocol PKDataAccessDelegate{
    /*
    *  数据集回调
    *  rs:数据集
    *  state:状态 0为没数据返回，1为有数据返回
    */
    func dataResult( rs:AnyObject? ,state:Bool);
}

protocol PKDataBaseAccessProtocol {
    
    /*
    * 创建通用数据库的线程，并加入到线程池
    * sql为执行sql
    * delegate 通过代理返回结果集
    */
    func execute(sql:String,callBackTarget:PKDataAccessDelegate?)
    
    /*
    * 创建一个访问数据库的线程，并加入到线程池
    * obj 是注入对象，若请求是select需要添加注入对象
    * delegate 通过代理返回结果集
    * <T>为映射范型
    */
    func queryExecute<T:NSObject>(obj:T,hql:PKHQLer,callBackTarget:PKDataAccessDelegate?)
    
    /*
    * 创建一个插入数据库的线程，并加入到线程池
    * obj 是注入对象
    * delegate 通过代理返回结果集
    * <T>为映射范型
    */
    func insertExecute<T:NSObject>(obj:T,callBackTarget:PKDataAccessDelegate?)
    
    /*
    * 创建一个修改数据库的线程，并加入到线程池
    * obj 是注入对象
    * delegate 通过代理返回结果集
    * <T>为映射范型
    */
    func updateExecute<T:NSObject>(hql:PKHQLer,obj:T,callBackTarget:PKDataAccessDelegate?)
    
    /*
    * 创建一个删除数据库的线程，并加入到线程池
    * obj 是注入对象
    * delegate 通过代理返回结果集
    * <T>为映射范型
    */
    func deleteExecute<T:NSObject>(hql:PKHQLer,obj:T,callBackTarget:PKDataAccessDelegate?)
    
    /*
    * 创建一个查询总数数据库的线程，并加入到线程池
    * delegate 通过代理返回结果集
    * <T>为映射范型
    */
    func countExecute<T:NSObject>(hql:PKHQLer,obj:T,callBackTarget:PKDataAccessDelegate?)
    
    /*
    *  创建一个批量插入数据库线程，并加入线程池
    *  batchArray 批量处理数据列表，元素必须为同类型对象
    *  delegate 通过代理返回结果集
    */
    func batchInsertExecute(batchArray:NSArray,callBackTarget:PKDataAccessDelegate?)
    
    /*
    *  创建一个批量插入数据库线程，并加入线程池
    *  batchArray 批量处理数据列表，元素必须为同类型对象
    *  delegate 通过代理返回结果集
    */
    func batchUpdateExecute(hql:PKHQLer,batchArray:NSArray,callBackTarget:PKDataAccessDelegate?)
    
    /*
    *  关闭数据库线程
    */
    func closeDataBase()

}


public class PKDataBaseAccess: NSObject,PKDataBaseAccessProtocol {
     //数据库线程单例,线程安全
//    class var sharedInstance:PKDataBaseAccess{
//        struct Instance {
//            static var onceToken: dispatch_once_t = 0
//            static var instance: PKDataBaseAccess? = nil
//        }
//        dispatch_once(&Instance.onceToken){
//            Instance.instance = PKDataBaseAccess()
//        }
//        return Instance.instance!
//    }
    var dbPath:String?//数据库路径
    var db:PKSQLite?//数据库连接
   public var timeOut:Int = 3 //超时时间，默认为3秒
   public var poolCount:Int = 1 //线程池大小，默认1
   public var isCacheData:Bool = true //是否使用缓存，默认true
    var pool:NSOperationQueue = NSOperationQueue()//创建线程池
    var dataCache:NSMutableDictionary = NSMutableDictionary()//缓存数据
    let cacheCount = 1 //缓存数据数量
    
    
    /*
    *  单例模式
    *  path为数据库路径
    */
    public class func shareAccess(path:String) -> PKDataBaseAccess{
        struct Instance {
            static var onceToken: dispatch_once_t = 0
            static var instance: PKDataBaseAccess? = nil
        }
        dispatch_once(&Instance.onceToken){
            Instance.instance = PKDataBaseAccess(path: path)
        }
        return Instance.instance!
    }
    
    /*
    *  多线程操作数据库初始化
    *  path为数据库路径
    */
    init(path:String){
        super.init()
        dbPath = path
        db = PKSQLite(fileName: path)
        pool.maxConcurrentOperationCount = poolCount
    }
    
    /*
    * 创建通用数据库的线程，并加入到线程池
    * sql为执行sql
    * delegate 通过代理返回结果集
    */
   public func execute(sql:String,callBackTarget:PKDataAccessDelegate?){
        pool.addOperationWithBlock { () -> Void in
            let rs:Bool = self.db!.execute(sql)
            callBackTarget?.dataResult(nil, state: rs)
        }
    }

    /*
    * 创建一个访问数据库的线程，并加入到线程池
    * obj 是注入对象，若请求是select需要添加注入对象
    * delegate 通过代理返回结果集
    * <T>为映射范型
    */
   public func queryExecute<T:NSObject>(obj:T,hql:PKHQLer,callBackTarget:PKDataAccessDelegate?){
        var isStop:Bool = false
        pool.addOperationWithBlock { () -> Void in
            let sql:String = PKMapping.queryMappingToSQL(conditions: hql.getHQL(),entity:obj)
            //查看缓存是否有数据
            var data:AnyObject? = self.dataCache.valueForKey(sql)
            if data == nil {
                let stmt:COpaquePointer = self.db!.selectBySQL(sql)
                var results:NSArray = PKMapping.resultMappingToObject(stmt,entity:obj)//映射结果集
                sqlite3_finalize(stmt);
                //多表联动查询，NSObject kvc问题导致不能映射
                self.multipleTableQuery(obj,results: results)
                self.cacheDate(sql, value: results)
                data = results
            }
            callBackTarget?.dataResult(data, state: true)
            isStop = true
            self.setTimeOut(&isStop,message: sql)//设置超时
        }
    }
    
    /*
    *   多表联动查询
    */
    private func multipleTableQuery<T:NSObject>(obj:T ,results:NSArray){
        let subObjects:Array<ClassBean> = obj.getOnlyTypeObject(type: "PKArray")
        //获取从表对象
        for subBean:ClassBean in subObjects {
            var subEntity: PKArray = obj.valueForKey(subBean.propertyName) as! PKArray
            
            //获取映射信息
            if let subMappingKeyValue:Dictionary<String,String> = subEntity.foreginKeyMapping {
                
                for (primaryKey,subColumns) in subMappingKeyValue{
                    for var i = 0 ; i < results.count ; i++ {
                        var primaryObj:T = results.objectAtIndex(i) as! T //主表对象
                        
                        if let foreginValue:AnyObject = primaryObj.valueForKey(primaryKey) {
                            //注入关联表查询SQL
                            var subHQL:PKHQLer = PKHQLer()
                            subHQL.addEqual(PKCharacterOperate.humpCharacterOperate(subColumns), value: foreginValue)
                            var subObjEntity = subEntity.entityNSObject//映射从表对象
                            
                            var subSQL:String = PKMapping.queryMappingToSQL(conditions: subHQL.getHQL(),entity: subObjEntity)
                            if subSQL != "" {
                                let subStmt:COpaquePointer = self.db!.selectBySQL(subSQL)
                                var subResults = PKMapping.resultMappingToObject(subStmt,entity: subObjEntity)//映射结果集
                                sqlite3_finalize(subStmt);
                                var subObj: PKArray = PKArray()
                                subObj.resultArray = subResults
                                primaryObj.setValue(subObj, forKey: subBean.propertyName)
                            }
                        }
                    }
                    
                }
            }
            
        }
    }
    
    /*
    * 创建一个插入数据库的线程，并加入到线程池
    * obj 是注入对象
    * delegate 通过代理返回结果集
    * <T>为映射范型
    */
   public func insertExecute<T:NSObject>(obj:T,callBackTarget:PKDataAccessDelegate?){
        var isStop:Bool = false
        pool.addOperationWithBlock { () -> Void in
            let sql:String = PKMapping.insertMappingByObject(obj)
            let rs:Bool = self.db!.execute(sql)
            self.dataCache.removeAllObjects()
            callBackTarget?.dataResult(rs, state: rs)
            isStop = rs
            self.setTimeOut(&isStop,message: sql)//设置超时
        }
    }
    
    /*
    * 创建一个修改数据库的线程，并加入到线程池
    * obj 是注入对象
    * delegate 通过代理返回结果集
    * <T>为映射范型
    */
   public func updateExecute<T:NSObject>(hql:PKHQLer,obj:T,callBackTarget:PKDataAccessDelegate?){
        var isStop:Bool = false
        pool.addOperationWithBlock { () -> Void in
            var sql:String = PKMapping.updateMappingByObject(obj)
            sql += hql.getHQL()
            println("[\(PKDateUnit.nowDate())] SQL: \(sql)")
            let rs:Bool = self.db!.execute(sql)
            self.dataCache.removeAllObjects()
            callBackTarget?.dataResult(rs, state: rs)
            isStop = rs
            self.setTimeOut(&isStop,message: sql)//设置超时
        }
    }
    
    /*
    * 创建一个删除数据库的线程，并加入到线程池
    * obj 是注入对象
    * delegate 通过代理返回结果集
    * <T>为映射范型
    */
   public func deleteExecute<T:NSObject>(hql:PKHQLer,obj:T,callBackTarget:PKDataAccessDelegate?){
        var isStop:Bool = false
        pool.addOperationWithBlock { () -> Void in
            var sql:String = "delete from T_\(obj.getTableName()) \(hql.getHQL())"
            println("[\(PKDateUnit.nowDate())] SQL: \(sql)")
            let rs:Bool = self.db!.execute(sql)
            self.dataCache.removeAllObjects()
            callBackTarget?.dataResult(rs, state: rs)
            isStop = rs
            self.setTimeOut(&isStop,message: sql)//设置超时
        }
    }
    
    /*
    * 创建一个查询总数数据库的线程，并加入到线程池
    * delegate 通过代理返回结果集
    * <T>为映射范型
    */
   public func countExecute<T:NSObject>(hql:PKHQLer,obj:T,callBackTarget:PKDataAccessDelegate?){
        var isStop:Bool = false
        pool.addOperationWithBlock { () -> Void in
            var sql:String = "select count(*) from T_\(obj.getTableName()) \(hql.getHQL())"
            println("[\(PKDateUnit.nowDate())] SQL: \(sql)")
            let rs:Int = self.db!.countBySQL(sql)
            self.dataCache.removeAllObjects()
            callBackTarget?.dataResult(rs, state: true)
            isStop = true
            self.setTimeOut(&isStop,message: sql)//设置超时
        }
    }
    
    /*
    *  创建一个批量插入数据库线程，并加入线程池
    *  batchArray 批量处理数据列表，元素必须为同类型对象
    *  delegate 通过代理返回结果集
    */
   public func batchInsertExecute(batchArray:NSArray,callBackTarget:PKDataAccessDelegate?){
        var isStop:Bool = false
        pool.addOperationWithBlock { () -> Void in
            var rs:Bool = false
            var sql:String = ""
            if batchArray.count > 0 {
                self.db!.doBegin()//开始事务
                for var i = 0 ; i < batchArray.count ; i++ {
                    var elementObj = batchArray[i] as! NSObject
                    sql = PKMapping.insertMappingByObject(elementObj)
                    rs = self.db!.execute(sql)
                }
                self.db!.doCommit()//提交事务
                self.dataCache.removeAllObjects()
                callBackTarget?.dataResult(rs, state: rs)
                isStop = rs
                self.setTimeOut(&isStop,message: sql)//设置超时
            }
        }
    }
    
    /*
    *  创建一个批量插入数据库线程，并加入线程池
    *  batchArray 批量处理数据列表，元素必须为同类型对象
    *  delegate 通过代理返回结果集
    */
   public func batchUpdateExecute(hql:PKHQLer,batchArray:NSArray,callBackTarget:PKDataAccessDelegate?){
        var isStop:Bool = false
        pool.addOperationWithBlock { () -> Void in
            var rs:Bool = false
            var sql:String = ""
            if batchArray.count > 0 {
                self.db!.doBegin()//开始事务
                for var i = 0 ; i < batchArray.count ; i++ {
                    var elementObj = batchArray[i] as! NSObject
                    sql = PKMapping.updateMappingByObject(elementObj)
                    sql += hql.getHQL()
                    println("[\(PKDateUnit.nowDate())] SQL: \(sql)")
                    rs = self.db!.execute(sql)
                }
                self.db!.doCommit()//提交事务
                self.dataCache.removeAllObjects()
                callBackTarget?.dataResult(rs, state: rs)
                isStop = rs
                self.setTimeOut(&isStop,message: sql)//设置超时
            }
        }
    } 
    
    /*
    *   设置超时
    *   isStop为控制超时标识
    *   message为超时信息
    */
    private func setTimeOut(inout isStop:Bool,message:String){
        while (!isStop) {
            NSThread.sleepForTimeInterval(Double(self.timeOut))
            println("［\(message)］操作超时……")
            isStop = true;
        }
    }
    
    /*
    *   缓存数据
    */
    func cacheDate(key:String,value:AnyObject){
        //缓存数据
        if dataCache.count == 0 {
            dataCache.setValue(value, forKey: key)
        }else if(dataCache.valueForKey(key) == nil && dataCache.count < cacheCount){
            dataCache.setValue(value, forKey: key) //多条数据缓存
        }else if(dataCache.valueForKey(key) == nil && dataCache.count == cacheCount){
            dataCache.removeAllObjects()
            dataCache.setValue(value, forKey: key)
        }
    }
    
    /*
    *  关闭数据库线程
    */
   public func closeDataBase(){
        self.db?.closeDB()
        dataCache.removeAllObjects()
    }
   
}
