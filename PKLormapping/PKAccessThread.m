//
//  PKAccessThread.m
//  PKFrameTest
//
//  Created by 周经伟 on 15/6/23.
//  Copyright © 2015年 packy. All rights reserved.
//

#import "PKAccessThread.h"

@implementation PKAccessThread

+(id) shareAccess:(NSString *) path{
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PKAccessThread alloc] initWithSQLitePath:path];
    });
    
    return sharedInstance;
}

-(id) init{
    self = [super init];
    if (self) {
        
        if (poolQueue == nil) {
            poolQueue = [[NSOperationQueue alloc] init];
            [poolQueue setMaxConcurrentOperationCount:1];
            self.timeOut = 3.0;
            self.isCacheData = YES;
        }
        mapping = [[PKMapping alloc] initWithMapping:@"lorm.sqlite"];
        return self;
    }
    return nil;
}

-(id) initWithSQLitePath:(NSString *) path{
    self = [super init];
    if (self) {
        if (poolQueue == nil) {
            poolQueue = [[NSOperationQueue alloc] init];
            [poolQueue setMaxConcurrentOperationCount:1];
            self.timeOut = 3.0;
            self.isCacheData = YES;
        }
        mapping = [[PKMapping alloc] initWithMapping:path];
        return self;
    }
    return nil;
}

-(void) queryExecute:(PKHQLer *)hql injectObj:(id)obj callBackTarget:(id)delegate{
    PKAccessTarget *target = [[PKAccessTarget alloc] init];
    target.obj = obj;
    target.timeOut = _timeOut;
    target.hql = hql;
    target.delegate = delegate;
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(queryThread:) object:target];
    [poolQueue addOperation:operation];
}

-(void) queryThread:(PKAccessTarget *) target{
    if (target.obj != nil ) {
        NSString *sql = [mapping queryMappingSQL:target.obj HQL:target.hql];
        //映射查询
        id result = [cacheData valueForKey:sql];//通过缓存取数据
        if (result ==nil) {
            result = [mapping queryMappingBySQL:sql obj:target.obj];
        }
        NSLog(@"end [%@]",[PKUnitCommon dateFormatterString:[NSDate date] formatter:@"HH:mm:ss:SSS"]);
        //结果集回调
        [target.delegate dataResult:result state:YES];
        //缓存数据
        if(_isCacheData){
            [self cacheData:sql data:result];
        }
        
        //返回标识结束线程
        target.isStop = YES;
        
    }else if(target.obj == nil ){
        //非映射查询
        
    }
    
    //线程超时返回
    while (!target.isStop) {
        [NSThread sleepForTimeInterval:target.timeOut];
        target.isStop = YES;
    }
}

-(void) insertExecute:(id)obj callBackTarget:(id)delegate{
    
    PKAccessTarget *target = [[PKAccessTarget alloc] init];
    target.obj = obj;
    target.timeOut = _timeOut;
    target.delegate = delegate;
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(insertThread:) object:target];
    [poolQueue addOperation:operation];
}

-(void) insertThread:(PKAccessTarget *) target{
    if (target.obj != nil ) {
        //增
        BOOL rs = [mapping insertMappingBySQL:target.obj];
        //结果集回调
        [target.delegate dataResult:nil state:rs];
        if (rs) {
            [self clearCacheDate];
        }
        //返回标识结束线程
        target.isStop = rs;
    }
    
    //线程超时返回
    while (!target.isStop) {
        [NSThread sleepForTimeInterval:target.timeOut];
        target.isStop = YES;
    }
}

-(void) updateExecute:(PKHQLer *)hql injectObj:(id)obj callBackTarget:(id)delegate{
    
    PKAccessTarget *target = [[PKAccessTarget alloc] init];
    target.obj = obj;
    target.timeOut = _timeOut;
    target.hql = hql;
    target.delegate = delegate;
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(updateThread:) object:target];
    [poolQueue addOperation:operation];
}

-(void) updateThread:(PKAccessTarget *) target
{
    if (target.obj != nil ) {
        //修
        BOOL rs = [mapping updateMappingBySQL:target.obj HQL:target.hql];
        //结果集回调
        [target.delegate dataResult:nil state:rs];
        if (rs) {
            [self clearCacheDate];
        }
        //返回标识结束线程
        target.isStop = rs;
    }
    //线程超时返回
    while (!target.isStop) {
        [NSThread sleepForTimeInterval:target.timeOut];
        target.isStop = YES;
    }
}

-(void) deleteExecute:(PKHQLer *)hql injectObj:(id)obj callBackTarget:(id)delegate{
    
    PKAccessTarget *target = [[PKAccessTarget alloc] init];
    target.obj = obj;
    target.timeOut = _timeOut;
    target.hql = hql;
    target.delegate = delegate;
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(deteleThread:) object:target];
    [poolQueue addOperation:operation];
}

-(void) deteleThread:(PKAccessTarget *) target{
    if (target.obj != nil ) {
        //删
        BOOL rs = [mapping deleteByHQL:target.obj HQL:target.hql];
        //结果集回调
        [target.delegate dataResult:nil state:rs];
        if (rs) {
            [self clearCacheDate];
        }
        //返回标识结束线程
        target.isStop = rs;
    }
    //线程超时返回
    while (!target.isStop) {
        [NSThread sleepForTimeInterval:target.timeOut];
        target.isStop = YES;
    }
}


-(void) execute:(NSString *) sql callBackTarget:(id) delegate{
    
    PKAccessTarget *target = [[PKAccessTarget alloc] init];
    target.sql = sql;
    target.timeOut = _timeOut;
    target.delegate = delegate;
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(accessThread:) object:target];
    [poolQueue addOperation:operation];
    
}

-(void) accessThread:(PKAccessTarget *) target{
    
    if ([target.sql rangeOfString:@"select"].location !=NSNotFound ) {
        
        PKSQLite *sqlite = mapping.sqliteDB;
        sqlite3_stmt *rs = [sqlite selectBySQL:target.sql];
        [target.delegate dataResult:(__bridge id)(rs) state:YES];
        //返回标识结束线程
        target.isStop = YES;
    }else{
        PKSQLite *sqlite = mapping.sqliteDB;
        BOOL rs = [sqlite execute:target.sql];
        [target.delegate dataResult:nil state:rs];
        if (rs) {
            [self clearCacheDate];
        }
        //返回标识结束线程
        target.isStop = rs;
        
    }
    //线程超时返回
    while (!target.isStop) {
        [NSThread sleepForTimeInterval:target.timeOut];
        target.isStop = YES;
    }
    
}

-(void) countExecute:(PKHQLer *)hql injectObj:(id) obj callBackTarget:(id)delegate{
    PKAccessTarget *target = [[PKAccessTarget alloc] init];
    target.timeOut = _timeOut;
    target.hql = hql;
    target.delegate = delegate;
    target.obj = obj;
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(countThread:) object:target];
    [poolQueue addOperation:operation];
}

-(void) countThread:(PKAccessTarget *) target{
    if (target.obj != nil ) {
        //总数
        NSInteger rs = [mapping countBySQL:target.obj HQL:target.hql];
        //结果集回调
        [target.delegate dataResult:[NSNumber numberWithInt:rs ] state:YES];
        //返回标识结束线程
        target.isStop = YES;
    }
    //线程超时返回
    while (!target.isStop) {
        [NSThread sleepForTimeInterval:target.timeOut];
        target.isStop = YES;
    }
}

-(void) batchInsertExecute:(NSArray *)batchArray callBackTarget:(id)delegate{
    PKAccessTarget *target = [[PKAccessTarget alloc] init];
    target.obj = batchArray;
    target.timeOut = _timeOut;
    target.delegate = delegate;
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(batchInsertThread:) object:target];
    [poolQueue addOperation:operation];
}

-(void) batchInsertThread:(PKAccessTarget *) target{
    PKSQLite *db = mapping.sqliteDB;
    @try {
        if (target.obj != nil ) {
            //批量新增
            [db doBegin];//开始事务
            NSArray *datas = target.obj;
            for(int i = 0;i<datas.count;i++){
                id batchObject = [datas objectAtIndex:i];
                [mapping insertMappingBySQL:batchObject];
            }
            [db doCommit];//提交事务
            //        BOOL rs = [mapping insertMappingBySQL:target.obj];
            //结果集回调
            [target.delegate dataResult:nil state:YES];
            
            [self clearCacheDate];
            
            //返回标识结束线程
            target.isStop = YES;
        }
        
        //线程超时返回
        while (!target.isStop) {
            [NSThread sleepForTimeInterval:target.timeOut];
            target.isStop = YES;
        }
    }
    @catch (NSException *exception) {
        [db backUp];
    }
    @finally {
        
    }
}

-(void) batchUpdateExecute:(PKHQLer *)hql batchArray:(NSArray *)batchArray callBackTarget:(id)delegate{
    PKAccessTarget *target = [[PKAccessTarget alloc] init];
    target.obj = batchArray;
    target.timeOut = _timeOut;
    target.delegate = delegate;
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(batchUpdateThread:) object:target];
    [poolQueue addOperation:operation];
}

-(void) batchUpdateThread:(PKAccessTarget *)target{
    PKSQLite *db = mapping.sqliteDB;
    @try {
        if (target.obj != nil ) {
            //批量新增
            [db doBegin];//开始事务
            NSArray *datas = target.obj;
            for(int i = 0;i<datas.count;i++){
                id batchObject = [datas objectAtIndex:i];
                [mapping updateMappingBySQL:batchObject HQL:target.hql];
            }
            [db doCommit];//提交事务
            //        BOOL rs = [mapping insertMappingBySQL:target.obj];
            //结果集回调
            [target.delegate dataResult:nil state:YES];
            
            [self clearCacheDate];
            
            //返回标识结束线程
            target.isStop = YES;
        }
        
        //线程超时返回
        while (!target.isStop) {
            [NSThread sleepForTimeInterval:target.timeOut];
            target.isStop = YES;
        }
    }
    @catch (NSException *exception) {
        [db backUp];
    }
    @finally {
        
    }
}

/*
 * 缓存数据
 */
-(void) cacheData:(NSString *) key data:(id)value{
    //缓存数据
    if (cacheData==nil) {
        cacheData = [NSMutableDictionary dictionaryWithCapacity:0];
        [cacheData setValue:value forKey:key];
    }else if([cacheData valueForKey:key]==nil && cacheData.count < cachaCount){
        [cacheData setValue:value forKey:key];
    }else if([cacheData valueForKey:key]==nil && cacheData.count == cachaCount){
        cacheData =  [NSMutableDictionary dictionaryWithObject:value forKey:key];//老化处理
    }
}

-(PKSQLite *) sqlite{
    return mapping.sqliteDB;
}

-(void) setPoolCount:(NSInteger)poolCount{
    [poolQueue setMaxConcurrentOperationCount:poolCount];
}
-(NSInteger) poolCount{
    return self.poolCount;
}

-(void) clearCacheDate{
    if (cacheData != nil) {
        [cacheData removeAllObjects];
//        cacheData = nil;
    }
}

-(void) closeDataBaseThread{
    [self clearCacheDate];
    [mapping clean];
    poolQueue = nil;
}

-(void) dealloc{
    NSLog(@"线程清理中……");
    [self closeDataBaseThread];
}
@end
