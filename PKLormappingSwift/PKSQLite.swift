//
//  PKSQLite.swift
//  PKlormTest
//
//  Created by 周经伟 on 15/7/14.
//  Copyright (c) 2015年 packy. All rights reserved.
//  SQLite 操作类

import Foundation

class PKSQLite: NSObject {
    var db:COpaquePointer = nil
    
    init(fileName:String){
        super.init()
        if self.openSQLiteDB(fileName) {
            
        }else{
            self.createSQLiteDB(fileName)
            self.openSQLiteDB(fileName)
        }
    }
    
    /*获取数据库文件路径*/
    func getSQLiteDBPath(fileName:String)->String{
        let docDir: AnyObject = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let filePath:String = "\(docDir as! String)/\(fileName)"
        return filePath
    }
    
    /*打开数据库*/
    func openSQLiteDB(fileName:String)->Bool{
        var database_path:String? = self.getSQLiteDBPath(fileName)
        if let dbPath:NSString = database_path{
            println("DataBasePath:\(dbPath)")
            if (sqlite3_open(dbPath.UTF8String, &db) != SQLITE_OK) {
                sqlite3_close(db);
                println("数据库打开失败");
                return false
            }
            return true
        }
        return false
    }
    
    /*创建数据库*/
    func createSQLiteDB(fileName:String){
        var fileManage:NSFileManager = NSFileManager.defaultManager()
        var database_path:String? = self.getSQLiteDBPath(fileName)
        if let dbPath:String = database_path{
            if !fileManage.fileExistsAtPath(dbPath){
                fileManage.createFileAtPath(dbPath, contents: nil, attributes: nil)
            }
        }
    }
    
    /*检查表是否存在*/
    func cheackTableExist(tableName:String) -> Bool{
        var count:Int32 = 0;
        var statement:COpaquePointer = nil
        let sql:NSString = "select count(*) from sqlite_master where type='table' and name='\(tableName)'"
        if (sqlite3_prepare_v2(db, sql.UTF8String, -1, &statement, nil) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                count = sqlite3_column_int(statement, 0)
            }
            sqlite3_finalize(statement)
            if (count>0) {
                return true
            }
        }
        return false
    }
    
    /*通过SQL查询结果集*/
    func selectBySQL(sql:String)->COpaquePointer
    {
        var statement:COpaquePointer = nil
        if (sqlite3_prepare_v2(db, (sql as NSString).UTF8String, -1, &statement, nil) == SQLITE_OK) {
            return statement
        }
            return nil
    }
    
    /*通过SQL查询结果集条数*/
    func countBySQL(sql:String)->Int{
        var count:Int = 0
        let result:COpaquePointer? = self.selectBySQL(sql)
        if result != nil
        {
            while sqlite3_step(result!) == SQLITE_ROW  {
                count = Int(sqlite3_column_int(result!, 0))
            }
        }
        return count
    }
    
    /*执行SQL*/
    func execute(sql:String)->Bool
    {
    
        var error:UnsafeMutablePointer<Int8> = nil
        if (sqlite3_exec(db, (sql as NSString).UTF8String, nil, nil, &error) != SQLITE_OK) {
            sqlite3_close(db);
            var errorMsg = String.fromCString(error)
            println("数据库操作数据失败,\(errorMsg)")
            return false
        }
        return true
    }
    
    /*创建表*/
    func createTable(tableName:String , columns:Array<TableBean>) ->Bool{
        var sql:String = "CREATE TABLE IF NOT EXISTS \(tableName)("
        
        for var i = 0; i<columns.count ; i++  {
                let param:TableBean = columns[i]
                if param.columnName == "ID" {
                    sql += "\(param.columnName) INTEGER PRIMARY KEY AUTOINCREMENT,"
                }else{
                    
                    if columns.count == (i+1) {
                        sql += "\(param.columnName) \(param.columnType))"
                    }else{
                        sql += "\(param.columnName) \(param.columnType),"
                    }
                }

        }
        return self.execute(sql);
    }
    
    /*开始事务*/
    func doBegin(){
        var error:UnsafeMutablePointer<Int8> = nil
        if(sqlite3_exec(db, "begin;", nil, nil, &error) != SQLITE_OK){
            println("开始事务失败:%s",String.fromCString(error))
        }
        sqlite3_free(error)
    }
    
    /*提交事务*/
    func doCommit(){
        var error:UnsafeMutablePointer<Int8> = nil
        if(sqlite3_exec(db, "commit;", nil, nil, &error) != SQLITE_OK){
            println("提交事务失败:%s",String.fromCString(error))
        }
        sqlite3_free(error)
    }
    
    /*回滚事务*/
    func doBackUp(){
        var error:UnsafeMutablePointer<Int8> = nil
        if(sqlite3_exec(db, "ROLLBACK", nil, nil, &error) != SQLITE_OK){
            println("回滚事务失败:%s",String.fromCString(error))
        }
        sqlite3_free(error)
    }
    
    /*关闭数据库*/
    func closeDB(){
        sqlite3_close(db);
    }
}
