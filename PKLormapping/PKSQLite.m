//
//  PKSQLite.m
//  PKFrameTest
//
//  Created by 周经伟 on 15/6/23.
//  Copyright © 2015年 packy. All rights reserved.
//

#import "PKSQLite.h"

@implementation PKSQLite
-(id) initWithSQLite:(NSString *) fileName
{
    self = [super init];
    if (self) {
        if ([self openSQLiteDB:fileName]) {
            
        }else{
            [self createSQLiteDB:fileName];
            [self openSQLiteDB:fileName];
        }
         return self;
    }
    return nil;
}
/*获取数据库文件路径*/
-(NSString *) getSQLiteDBPath:(NSString *) fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
    NSString *database_path = [documents stringByAppendingPathComponent:fileName];
    return database_path;
}

/*打开数据库*/
-(BOOL) openSQLiteDB:(NSString *) fileName
{
    @synchronized(self){
        NSString *database_path = [self getSQLiteDBPath:fileName];
        if (sqlite3_open([database_path UTF8String], &db) != SQLITE_OK) {
            sqlite3_close(db);
            NSLog(@"数据库打开失败");
            return NO;
        }
        return YES;
    }
}
/*创建数据库*/
-(void) createSQLiteDB:(NSString *) fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];//创建文件管理器
    NSString *database_path = [self getSQLiteDBPath:fileName];
    if (![fileManager fileExistsAtPath:database_path]) {
        [fileManager createFileAtPath:database_path contents:nil attributes:nil];
    }
}

/*判断表是否存在*/
-(BOOL) cheackTableExist:(NSString *) tableName
{
    int count = 0;
    sqlite3_stmt * statement;
    NSString *sql = [NSString stringWithFormat:@"select count(*) from sqlite_master where type='table' and name='%@'",tableName];
    if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            count = sqlite3_column_int(statement, 0);
        }
        if (count>0) {
            return YES;
        }
        sqlite3_finalize(statement);
    }
    return NO;
}

/*创建表*/
-(BOOL) createTable:(NSString *) tableName columnName:(NSString *) columnName,...
{
    @synchronized(self){
        if (![self cheackTableExist:tableName]) {
            
            NSMutableArray *arrays = [[NSMutableArray alloc] init];
            
            va_list argList;
            if (columnName) {
                [arrays addObject:columnName];
                va_start(argList,columnName);
                NSString *otherParam;
                while ((otherParam = va_arg(argList,NSString *)))
                {
                    [arrays addObject:otherParam];
                }
                va_end(argList);
            }
            
            NSMutableString *sql = [[NSMutableString alloc] init];
            [sql appendFormat:@"CREATE TABLE IF NOT EXISTS %@(",tableName];
            int i = 0;
            for (NSString *param in  arrays) {
                if ([param isEqualToString:@"id"]) {
                    [sql appendFormat:@"%@ INTEGER PRIMARY KEY AUTOINCREMENT,",param];
                }else{
                    if (arrays.count == (i+1)) {
                        [sql appendFormat:@"%@)",param];
                    }else{
                        [sql appendFormat:@"%@,",param];
                    }
                }
                i++;
            }
            
            
            return [self execute:sql];
            
        }
        return NO;
    }
}

-(sqlite3_stmt *) selectBySQL:(NSString *) sql
{
   
    @synchronized(self){
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
            return statement;
        }else{
            return nil;
        }
    }
}

-(sqlite3_stmt *) select:(NSString *)tableName sort:(NSString *)sort condition:(NSString *) condition,...
{
    @synchronized(self){
        sqlite3_stmt *statement;
        NSMutableArray *arrays = [[NSMutableArray alloc] init];
        
        va_list argList;
        if (condition != nil) {
            [arrays addObject:condition];
            va_start(argList,condition);
            NSString *otherParam;
            while ((otherParam = va_arg(argList,NSString *)))
            {
                [arrays addObject:otherParam];
            }
            va_end(argList);
        }
        
        NSMutableString *sql = [[NSMutableString alloc] init];
        [sql appendFormat:@"select * from %@ ",tableName];
        
        if (arrays.count >0) {
            [sql appendString:@"where "];
            int i = 0;
            for (NSString *param in  arrays) {
                [sql appendFormat:@"%@",param];
                i++;
            }
        }
        if (sort!=nil) {
             [sql appendFormat:@" %@",sort];
        }
       
        
        if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, nil) == SQLITE_OK) {
            return statement;
        }else{
            return nil;
        }
        
        return nil;
    }
}

-(BOOL) deleted:(NSString *)tableName condition:(NSString *) condition,...
{
    NSMutableArray *arrays = [[NSMutableArray alloc] init];
    
    va_list argList;
    if (condition) {
        [arrays addObject:condition];
        va_start(argList,condition);
        NSString *otherParam;
        while ((otherParam = va_arg(argList,NSString *)))
        {
            [arrays addObject:otherParam];
        }
        va_end(argList);
    }
    
    NSMutableString *sql = [[NSMutableString alloc] init];
    [sql appendFormat:@"delete from %@ ",tableName];
    
    if (arrays.count >0) {
        [sql appendString:@"where "];
        int i = 0;
        for (NSString *param in  arrays) {
            if (arrays.count == (i+1)) {
                [sql appendFormat:@"%@",param];
            }else{
                [sql appendFormat:@"%@,",param];
            }
            i++;
        }
    }
    
    
    return [self execute:sql];
}

-(BOOL) execute:(NSString *)sql
{
    @synchronized(self){
        char *err;
        
        if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
            sqlite3_close(db);
            NSString *error = [[NSString alloc]initWithUTF8String:err];
            
            NSLog(@"数据库操作数据失败,%@",error);
            return NO;
        }
        return YES;
    }
}
/**
 * 提交事务
 */
-(void) doCommit
{
    char *errorMsg;
    if(sqlite3_exec(db, "commit;", NULL, NULL, &errorMsg) != SQLITE_OK){
        NSLog(@"提交事务成功");
    }
    sqlite3_free(errorMsg);
}
/**
 * 开始事务
 */
-(void)doBegin{
    char *errorMsg;
    if(sqlite3_exec(db, "begin;", NULL, NULL, &errorMsg) != SQLITE_OK){
        NSLog(@"sqlite3_exec BEGIN_SQL error...%s", errorMsg);
    }
    sqlite3_free(errorMsg);
}

/**
 * 事务回滚
 */
-(void) backUp{
    char *errorMsg;
    if (sqlite3_exec(db, "ROLLBACK", NULL, NULL, &errorMsg)==SQLITE_OK)  {
        NSLog(@"回滚事务成功");
    }
    sqlite3_free(errorMsg);
}

-(void) closeDB
{
    sqlite3_close(db);
}

-(BOOL) createTable:(NSString *) tableName columnNames:(NSArray *) columnNames{
    @synchronized(self){
            NSMutableString *sql = [[NSMutableString alloc] init];
            [sql appendFormat:@"CREATE TABLE IF NOT EXISTS %@(",tableName];
            int i = 0;
            for (PKTableBean *param in  columnNames) {
                if ([param.columnName isEqualToString:@"ID"]) {
                    [sql appendFormat:@"%@ INTEGER PRIMARY KEY AUTOINCREMENT,",param.columnName];
                }else{
                    NSString *columnType =[PKCharacterOperate objTypeTranslateDataType:param.columnType];
                    if (columnNames.count == (i+1)) {
                        [sql appendFormat:@"%@ %@)",param.columnName,columnType];
                    }else{
                        [sql appendFormat:@"%@ %@,",param.columnName,columnType];
                    }
                }
                i++;
            }
           
            
            return [self execute:sql];
        
    }

}

@end

