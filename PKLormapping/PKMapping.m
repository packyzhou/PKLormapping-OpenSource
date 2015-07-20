//
//  PKMapping.m
//  PKFrameworkThreadTest
//
//  Created by 周经伟 on 15/6/24.
//  Copyright © 2015年 packy. All rights reserved.
//

#import "PKMapping.h"
#import "PKMappingCategory.h"
@implementation PKMapping

-(id) initWithMapping:(NSString *) databaseFile{
    self  = [super init];
    if (self) {
        
        if (sqlite == nil) {
            sqlite = [[PKSQLite alloc] initWithSQLite:databaseFile];
        }
        return self;
    }
    return nil;
}

-(PKSQLite *) sqliteDB{
    return sqlite;
}

-(id) queryMappingBySQL:(NSString *) sql obj:(id) object{
    @try {
        
        sqlite3_stmt *result = [sqlite selectBySQL:sql];
        NSMutableArray *resultArray  = [self mappingObject:result obj:object];
        sqlite3_finalize(result);
        return resultArray;
    }
    @catch (NSException *exception) {
        return nil;
    }
    @finally {
        
    }
}

-(NSString *) queryMappingSQL:(id)object HQL:(PKHQLer *)hql{
    NSString *tableName = [object getTableName];//表名
    NSArray *columns = [object getColumns];//列字段
    
    //        if (![sqlite cheackTableExist:tableName]) {
    //            //判断表是否存在,不存在则创建
    //            [sqlite createTable:tableName columnNames:columns];
    //        }

    NSString *columnNameStr = [self mappingQueryColumnsToSQL:columns];
    NSMutableString *sql = [[NSMutableString alloc] initWithFormat:@"select %@ from %@",columnNameStr,tableName];
    if (hql!=nil) {
        [sql appendString:[hql getHQL]];
    }
    [PKUnitCommon sqlPrintln:sql];//打印日志
    return sql;
}

-(BOOL) insertMappingBySQL:(id) object{
    @try {
        NSString *tableName = [object getTableName];//表名
//        NSArray *columns = [object getColumns];//列字段
        NSMutableString *sql = [[NSMutableString alloc] initWithFormat:@"insert into %@ ",tableName];
//        if (![sqlite cheackTableExist:tableName]) {
//            //判断表是否存在,不存在则创建
//            [sqlite createTable:tableName columnNames:columns];
//        }
        
        //插入映射
        [sql appendString:[self mappingInsertColumnsToSQL:object ]];//插入字段数组
        [sql appendString:@" values "];//插入关键字
        [self mappingInsertValuesToSQL:sql obj:object];//插入数据
        [PKUnitCommon sqlPrintln:sql];//打印日志
        return [sqlite execute:sql];
    }
    @catch (NSException *exception) {
        return NO;
    }
    @finally {
        NSLog(@"end [%@]",[PKUnitCommon dateFormatterString:[NSDate date] formatter:@"HH:mm:ss:SSS"]);
    }
}

-(BOOL) updateMappingBySQL:(id) object HQL:(PKHQLer *)hql{
    @try {
        NSString *tableName = [object getTableName];//表名
//        NSArray *columns = [object getColumns];//列字段
//        if (![sqlite cheackTableExist:tableName]) {
//            //判断表是否存在,不存在则创建
//            [sqlite createTable:tableName columnNames:columns];
//        }
        NSMutableString *sql = [[NSMutableString alloc] initWithFormat:@"update %@ set ",tableName];
        [self mappingUpdateValuesToSQL:sql obj:object];
        //添加HQL查询帮助语句
        if (hql!=nil) {
            [sql appendString:[hql getHQL]];
        }
        [PKUnitCommon sqlPrintln:sql];//打印日志
        return [sqlite execute:sql];
    }
    @catch (NSException *exception) {
        return NO;
    }
    @finally {
        NSLog(@"end [%@]",[PKUnitCommon dateFormatterString:[NSDate date] formatter:@"HH:mm:ss:SSS"]);
    }
}

-(BOOL) deleteByHQL:(id) object HQL:(PKHQLer *)hql{
    @try {
        NSString *tableName = [object getTableName];//表名
        NSMutableString *sql = [[NSMutableString alloc] initWithFormat:@"delete from %@ ",tableName];
        if (hql!=nil) {
            [sql appendString:[hql getHQL]];
        }
        [PKUnitCommon sqlPrintln:sql];//打印日志
        return [sqlite execute:sql];
    }
    @catch (NSException *exception) {
        return NO;
    }
    @finally {
        NSLog(@"end [%@]",[PKUnitCommon dateFormatterString:[NSDate date] formatter:@"HH:mm:ss:SSS"]);
    }
}

-(NSInteger) countBySQL:(id) object HQL:(PKHQLer *) hql{
    @try {
        NSInteger count = 0;
        NSString *tableName = [object getTableName];//表名
        NSMutableString *sql = [[NSMutableString alloc] initWithFormat:@"select count(*) from %@ ",tableName];
        if (hql!=nil) {
            [sql appendString:[hql getHQL]];
        }
        [PKUnitCommon sqlPrintln:sql];//打印日志
        sqlite3_stmt *result = [sqlite selectBySQL:sql];
        if(result!=nil)
        {
            while (sqlite3_step(result) == SQLITE_ROW ) {
                count = sqlite3_column_int(result, 0);
            }
        }
        return count;
    }
    @catch (NSException *exception) {
        return NO;
    }
    @finally {
        NSLog(@"end [%@]",[PKUnitCommon dateFormatterString:[NSDate date] formatter:@"HH:mm:ss:SSS"]);
    }
}

-(void) clean{
    [sqlite closeDB];
    sqlite = nil;
}
@end
