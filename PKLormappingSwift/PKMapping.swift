//
//  PKMapping.swift
//  PKlormTest
//
//  Created by 周经伟 on 15/7/16.
//  Copyright (c) 2015年 packy. All rights reserved.
//

import Foundation

class PKMapping: NSObject {
    
    /*
    *   查询时 根据HQL帮助类组装查询映射的SQL语句
    */
    class func queryMappingToSQL<T:NSObject>(#conditions:String?,entity:T)->String{

        var sql:String = "select "
        
        var allPropertys:Array<ClassBean> = entity.getPropertys()//获取所有属性
        var allColumns:Array<TableBean> = entity.getColumns()//映射所有列名
        
        //添加字段
        for var i=0 ;i<allColumns.count ; i++ {
            var tableBean:TableBean = allColumns[i]
            if  allColumns.count == (i+1){
                sql += "\(tableBean.columnName) "
            }else{
                sql += "\(tableBean.columnName),"
            }
        }
        
        sql += "from T_\(entity.getTableName()) "
        
        //添加查询条件
        if let condition = conditions{
            sql += "\(condition)"
        }
        println("[\(PKDateUnit.nowDate())] SQL: \(sql)")
        return sql
    }
  
    /*
    *  查询时 根据对象属性映射结果集
    */
    class func resultMappingToObject<T:NSObject>(stmtResult:COpaquePointer?,entity:T)->NSArray{
        var resultList:NSMutableArray = NSMutableArray()
        
        if let result = stmtResult{
            while sqlite3_step(result) == SQLITE_ROW {
//                println(entity.classForCoder)
                var object:T = entity.classForCoder.alloc() as! T   //创建实例
                //遍历属性
                for var i = 0 ; i < entity.getColumns().count ; i++ {
                    let tableBean:TableBean = entity.getColumns()[i]
                    let classBean:ClassBean = entity.getPropertys()[i]
                    //映射结果
                    self.resultMappingToObjectByStmt(classBean.propertyName,
                        stmt: result,
                        index: CInt(i),
                        tableBean: tableBean,
                        resultObj: object)
                }
                
                resultList.addObject(object)
            }
        }
        return resultList
    }
    
    /*
    *   多表联动查询
    */
   class func multipleTableQueryByMappingToSQL(resultObj:NSObject)->String?{
        
        let multipleTables:Array<ClassBean> = resultObj.getOnlyTypeObject(type: "PKArray")
        var subSql:String?
        //获取从表映射
        for classBean:ClassBean in multipleTables
        {
           
            let multipleArray:PKArray = resultObj.valueForKey(classBean.propertyName) as! PKArray
            
            if let foreginKey:Dictionary<String,String> = multipleArray.foreginKeyMapping {
//                var mapObj:AnyObject = multipleArray.returnElement()//创建对象
                var subHql:PKHQLer = PKHQLer()
                
                //获取主键和外键映射关系
                for (primaryKey,foreignKey) in foreginKey {
                    let primaryKeyValue:AnyObject? = resultObj.valueForKey(primaryKey) //获取主表数据
                    let foreignKeyName =  PKCharacterOperate.humpCharacterOperate(foreignKey)//主表数据作为从表外键条件查询
                    if primaryKeyValue != nil {
                        subHql.addEqual(foreignKeyName, value: primaryKeyValue)
                    }
                }
                //映射从表数据
                subSql = self.queryMappingToSQL(conditions: subHql.getHQL(), entity: multipleArray)
                println("[\(PKDateUnit.nowDate())] SQL: \(subSql!)")
                return subSql;
            }
        }
        return subSql
    }
    
    /*
    *   根据key,value组装cell
    */
   class func resultMappingToObjectByStmt<T:NSObject>(key:String ,stmt:COpaquePointer,index:CInt,tableBean:TableBean,resultObj:T){
        switch tableBean.columnType {
            case "TEXT":
                let text:UnsafePointer<Int8> = UnsafePointer<Int8>(sqlite3_column_text(stmt, index))
                let value:String? = String.fromCString(UnsafePointer<CChar>(text))
                if value != nil {
                    resultObj.setValue(value, forKey: key)
                }
            case "INTEGER":
                let rs:Int = Int(sqlite3_column_int(stmt, index))
                resultObj.setValue(rs, forKey: key)
            case "Boolean":
                let rs:Int = Int(sqlite3_column_int(stmt, index))
                resultObj.setValue(rs, forKey: key)
            case "Timestamp":
                let text:UnsafePointer<Int8> = UnsafePointer<Int8>(sqlite3_column_text(stmt, index))
                if let date:String = String.fromCString(UnsafePointer<CChar>(text)){
                    let value = PKDateUnit.stringFormatterDate(dateStr: date, formatter: "yyyy-MM-dd HH:mm:ss")
                    resultObj.setValue(value, forKey: key)
                }
            case "Float":
                let rs:Float = Float(sqlite3_column_double(stmt, index))
                resultObj.setValue(rs, forKey: key)
            case "Double":
                let rs:Double = Double(sqlite3_column_double(stmt, index))
                resultObj.setValue(rs, forKey: key)
            case "BLOB":
                let rs:Int = Int(sqlite3_column_bytes(stmt, index))
                resultObj.setValue(rs, forKey: key)
            default:
            break
        }
    }
    
    /*
    *   根据对象映射更新语句
    */
    class func updateMappingByObject<T:NSObject>(obj:T)->String{
        var sql:String = "update T_\(obj.getTableName()) set "
        var propertys:Array<ClassBean> = obj.getPropertys()
        var columns:Array<TableBean> = obj.getColumns()
        
        for var i = 0 ; i < columns.count ; i++ {
            var tableBean:TableBean = columns[i]
            var classBean:ClassBean = propertys[i]
           
            if var value:AnyObject = obj.valueForKey(classBean.propertyName) {
                value = PKCharacterOperate.extraMapping(value, type: "\(value.classForCoder)")
                if propertys.count == (i+1) {
                    sql += "\(tableBean.columnName) = \(value) "
                }else{
                    sql += "\(tableBean.columnName) = \(value),"
                }
            }
        }
        
        var lastStr = sql.substringFromIndex(advance(sql.startIndex, sql.length()-1))
        if lastStr == "," {
            var range:Range<String.Index> = Range<String.Index>(start:advance(sql.startIndex, sql.length()-1),
                end:advance(sql.endIndex, 0))
            sql.replaceRange(range, with: ")")
        }
        return sql
    }
    
    /*
    *   根据对象映射插入信息
    */
    class func insertMappingByObject<T:NSObject>(obj:T)->String{
        var sql:String = "insert into T_\(obj.getTableName()) "
        //组装字段
       var columnsToSQL:String = self.insertMappingByObjectToColumns(obj)
        //组装参数
       var dataToSQL:String = self.insertMappingByObjectToData(obj)
        sql += "\(columnsToSQL) values \(dataToSQL)"
        
       println("[\(PKDateUnit.nowDate())] SQL: \(sql)")
       return sql
    }
    
    /*
    * insert组装字段
    * 格式如：(id,name,sex)
    */
    class func insertMappingByObjectToColumns<T:NSObject>(obj:T)->String{
        var propertys:Array<ClassBean> = obj.getPropertys()
        var columns:Array<TableBean> = obj.getColumns()
        
        var columnsToSQL:String = "("
        for var i = 0 ; i < columns.count ; i++ {
            var tableBean:TableBean = columns[i]
            var classBean:ClassBean = propertys[i]
            if let value:AnyObject = obj.valueForKey(classBean.propertyName) {
                if columns.count == (i+1) {
                    columnsToSQL += "\(tableBean.columnName))"
                }else{
                    columnsToSQL += "\(tableBean.columnName),"
                }
            }
        }
        var lastStr = columnsToSQL.substringFromIndex(advance(columnsToSQL.startIndex, columnsToSQL.length()-1))
        if lastStr == "," {
            var range:Range<String.Index> = Range<String.Index>(start:advance(columnsToSQL.startIndex, columnsToSQL.length()-1),
                end:advance(columnsToSQL.endIndex, 0))
            columnsToSQL.replaceRange(range, with: ")")
        }
        return columnsToSQL
    }
    
    /*
    * insert组装数据
    * 格式如：(1,'zjw','m')
    */
    class func insertMappingByObjectToData<T:NSObject>(obj:T)->String{
        var propertys:Array<ClassBean> = obj.getPropertys()
        
        var dataToSQL:String = "("
        for var i = 0 ; i < propertys.count ; i++ {
            
            var classBean:ClassBean = propertys[i]
            if var value:AnyObject = obj.valueForKey(classBean.propertyName) {
                value = PKCharacterOperate.extraMapping(value, type: "\(value.classForCoder)")
                if propertys.count == (i+1) {
                    dataToSQL += "\(value))"
                }else{
                    dataToSQL += "\(value),"
                }
            }
        }
        var lastStr = dataToSQL.substringFromIndex(advance(dataToSQL.startIndex, dataToSQL.length()-1))
        if lastStr == "," {
            var range:Range<String.Index> = Range<String.Index>(start:advance(dataToSQL.startIndex, dataToSQL.length()-1),
                end:advance(dataToSQL.endIndex, 0))
            dataToSQL.replaceRange(range, with: ")")
        }
        return dataToSQL
    }

}
