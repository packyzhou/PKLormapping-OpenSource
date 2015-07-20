//
//  PKMappingCategory.m
//  PKlormTest
//
//  Created by 周经伟 on 15/6/25.
//  Copyright (c) 2015年 packy. All rights reserved.
//

#import "PKMappingCategory.h"

@implementation PKMapping (PKMappingCategory)
-(NSString *) mappingQueryColumnsToSQL:(NSArray *)columns{
    NSMutableString *tempStr = [[NSMutableString alloc] initWithString:@" "];
    for (int i = 0; i< [columns count]; i++) {
        PKTableBean *tableBean = [columns objectAtIndex:i];//表
        if (columns.count == (i+1)) {
            [tempStr appendFormat:@"%@ ",tableBean.columnName];
        }else{
            [tempStr appendFormat:@"%@,",tableBean.columnName];
        }
    }
    return tempStr;
}
/*
 *  映射对象
 */
-(NSMutableArray *) mappingObject:(sqlite3_stmt *) result obj:(id)obj{
    NSArray *columns = [obj getColumns];//列字段
    
    NSMutableArray *resultArray = [[NSMutableArray alloc] initWithCapacity:0];
    if(result!=nil)
    {
        while (sqlite3_step(result) == SQLITE_ROW ) {
            id rsObj = [[[obj class] alloc] init];
            for (int i = 0; i< [columns count]; i++) {
                PKTableBean *tableBean = [columns objectAtIndex:i];//表
                
                //属性类型转字段类型
                NSString *columnType =[PKCharacterOperate objTypeTranslateDataType:tableBean.columnType];
                //字段映射对象,组装结果集
                [self mappingPropertyWithColumn:columnType object:rsObj index:i sqliteResult:result];
                
            }
            //多表联查
            [self multipleTableQueryByMapping:obj foreignKeyObj:rsObj];

            [resultArray addObject:rsObj];
        }
    }
    return resultArray;
}

/*
 *  多表联查映射
 */

-(void) multipleTableQueryByMapping:(id) obj foreignKeyObj:(id) fkObj{
    PKHQLer *hql;
    NSArray *multipleTables = [obj getOnlyTypeObject:[PKArray class]];
    if (multipleTables!=nil && multipleTables.count>0) {
        for (PKClassBean *classBean in multipleTables){
            PKArray *multipTableProperty = [obj valueForKey:classBean.propertyName];
            PKMultipleEntityBean *mappingBean = multipTableProperty.multipleEntityBean;
            if (mappingBean!=nil) {
                id mapObj = [[mappingBean.mappingClass alloc] init];//多表对象
                hql = [[PKHQLer alloc] initForEntity:mapObj];
                //主从表映射键值对hash
                NSDictionary *multipMap = mappingBean.foreignKeyMapping;
                //遍历所有关联关系键值对
                for(NSString *key in multipMap) {
                    id primaryKeyValue = [fkObj valueForKey:key];
                    id foreignKeyName = [multipMap objectForKey:key];
                    foreignKeyName = [PKCharacterOperate humpCharacterOperate:foreignKeyName];
                    [hql addEqual:foreignKeyName value:primaryKeyValue];
                }
                //映射从表数据
                NSString *mulitperSQL = [self queryMappingSQL:mapObj HQL:hql];
                id mulitperResult = [self queryMappingBySQL:mulitperSQL obj:mapObj];
                if (mulitperResult!=nil) {
                    [fkObj setValue:mulitperResult forKey:classBean.propertyName];
                }
            }
        }
    }
}



/*
 *  查询结果映射对象
 */
-(void) mappingPropertyWithColumn:(NSString *) columnType object:(id) rsObj index:(int) i sqliteResult:(sqlite3_stmt *) result{
    NSArray *propertys = [rsObj getPropertys] ;//映射对象属性
    PKClassBean *classBean = [propertys objectAtIndex:i];//属性
    if ([columnType isEqualToString:@"TEXT"]) {
        char *c = (char*)sqlite3_column_text(result, i);
        if (c!=NULL) {
            NSString *str = [[NSString alloc]initWithUTF8String:c];
            [rsObj setValue:str forKey:classBean.propertyName];
        }
    }else if([columnType isEqualToString:@"INTEGER"]){
        int rs = sqlite3_column_int(result, i);
        
        NSNumber *number = [NSNumber numberWithInt:rs];
        [rsObj setValue:number forKey:classBean.propertyName];
    }else if([columnType isEqualToString:@"Boolean"]){
        
        int rs = sqlite3_column_int(result, i);
        NSNumber *number = [NSNumber numberWithInt:rs];
        [rsObj setValue:number forKey:classBean.propertyName];
    }else if([columnType isEqualToString:@"Timestamp"]){
        char *dateStr = (char *)sqlite3_column_text(result, i);
        NSString *dateForstr = [[NSString alloc]initWithUTF8String:dateStr];
        NSDate *date = [PKUnitCommon stringFormatterDate:dateForstr formatter:@"yyyy-MM-dd HH:mm:ss"];
        [rsObj setValue:date forKey:classBean.propertyName];
    }else if([columnType isEqualToString:@"Float"]){
        double rs = sqlite3_column_double(result, i);
        NSNumber *number = [NSNumber numberWithFloat:rs];
        [rsObj setValue:number forKey:classBean.propertyName];
    }else if([columnType isEqualToString:@"Double"]){
        double rs = sqlite3_column_double(result, i);
        NSNumber *number = [NSNumber numberWithDouble:rs];
        [rsObj setValue:number forKey:classBean.propertyName];
    }else if([columnType isEqualToString:@"BLOB"]){
        int rs = sqlite3_column_bytes(result, i);
        NSNumber *number = [NSNumber numberWithDouble:rs];
        [rsObj setValue:number forKey:classBean.propertyName];
    }
}


/*
 * insert组装字段
 * 格式如：(id,name,sex)
 */
-(NSString *) mappingInsertColumnsToSQL:(id) obj{
    NSArray *propertys = [obj getPropertys] ;//映射对象属性
    NSArray *columns = [obj getColumns]; //映射表字段
    NSMutableString *tempStr = [[NSMutableString alloc] initWithString:@"("];
    for (int i = 0; i< [columns count]; i++) {
        PKTableBean *tableBean = [columns objectAtIndex:i];//表
        PKClassBean *classBean = [propertys objectAtIndex:i];
        id value = [obj valueForKey:classBean.propertyName];
        if(value != nil){
            if (columns.count == (i+1)) {
                [tempStr appendFormat:@"%@)",tableBean.columnName];
            }else{
                [tempStr appendFormat:@"%@,",tableBean.columnName];
            }
        }
    }
    NSString *lastStr = [tempStr substringFromIndex:tempStr.length-1];
    if ([lastStr isEqualToString:@","]) {
        [tempStr replaceCharactersInRange:NSMakeRange(tempStr.length-1, 1) withString:@")"];
    }
    return tempStr;
}


/*
 * insert组装数据
 * 格式如：(1,'zjw','m')
 */
-(void) mappingInsertValuesToSQL:(NSMutableString *)sql obj:(id) obj{
    NSMutableString *tempStr = [[NSMutableString alloc] initWithString:@"("];
    
    NSArray *propertys = [obj getPropertys] ;//映射对象属性
    for (int i = 0; i< [propertys count]; i++) {
        PKClassBean *classBean = [propertys objectAtIndex:i];
        id value = [obj valueForKey:classBean.propertyName];
        if (value!=nil) {
            value = [PKCharacterOperate extraMapping:value type:classBean.propertyType];
            if (propertys.count == (i+1)) {
                [tempStr appendFormat:@"%@)",value];
            }else{
                [tempStr appendFormat:@"%@,",value];
            }
        }
    }
    NSString *lastStr = [tempStr substringFromIndex:tempStr.length-1];
    if ([lastStr isEqualToString:@","]) {
        [tempStr replaceCharactersInRange:NSMakeRange(tempStr.length-1, 1) withString:@")"];
    }
    [sql appendString:tempStr];
}

/*
 *  根据类属性和属性值组装SQL
 */
-(void) mappingUpdateValuesToSQL:(NSMutableString *)sql obj:(id) obj{
    NSMutableString *tempStr = [[NSMutableString alloc] initWithString:@"("];
    NSArray *propertys = [obj getPropertys] ;//映射对象属性
    for (int i = 0; i< [propertys count]; i++) {
        PKClassBean *classBean = [propertys objectAtIndex:i];
        id value = [obj valueForKey:classBean.propertyName];
        if (value!=nil) {
            //属性名转字段名
            NSString *columnName =[PKCharacterOperate humpCharacterOperate:classBean.propertyName];
            value = [PKCharacterOperate extraMapping:value type:classBean.propertyType];
            if (propertys.count == (i+1)) {
                [tempStr appendFormat:@"%@ = %@ ",columnName,value];
            }else{
                [tempStr appendFormat:@"%@ = %@, ",columnName,value];
            }
        }
    }
    NSString *lastStr = [tempStr substringFromIndex:tempStr.length-1];
    if ([lastStr isEqualToString:@","]) {
        [tempStr replaceCharactersInRange:NSMakeRange(tempStr.length-1, 1) withString:@")"];
    }
    [sql appendString:tempStr];
}

@end
