//
//  PKBaseEntityCategory.m
//  PKLormapping
//
//  Created by 周经伟 on 15/6/20.
//  Copyright © 2015年 packy. All rights reserved.
//

#import "PKBaseEntityCategory.h"

@implementation NSObject (PKBaseEntityCategory)
-(NSString *) getEntityName{
    return NSStringFromClass([self class]);
}

-(NSString *) getTableName{
    NSString *entityName = [self getEntityName];
    
    NSMutableString *tableName = [[NSMutableString alloc] initWithString:@"T_"];
    NSString *targetChar = [PKCharacterOperate humpCharacterOperate:entityName];
    if (![targetChar isEqualToString:@""]) {
        [tableName appendString:targetChar];
    }
    return tableName;
}

-(NSArray *) getPropertys{
    NSArray *propertys = [PKCharacterOperate classPropertyWithArray:self.class];
    NSArray *targetArray = [self getPropertysBesidesType:[PKArray class] array:propertys];
    return targetArray;
}

-(NSArray *) getColumns{
    NSArray *columns = [PKCharacterOperate classColumnWithArray:self.class];
    NSArray *targetArray = [self getColumnsBesidesType:@"PKArray" array:columns];
    return targetArray;
}

-(NSArray *) getPropertysBesidesType:(Class) type array:(NSArray *) array{
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:array];
    for (PKClassBean *classBean in array) {
        if ([classBean.propertyType isEqualToString:NSStringFromClass(type)]) {
            [tempArray removeObject:classBean];
        }
    }
    return tempArray;
}

-(NSArray *) getColumnsBesidesType:(NSString *) type array:(NSArray *)array{
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:array];
    for (PKTableBean *tableBean in array) {
        if ([tableBean.columnType isEqualToString:type]) {
            [tempArray removeObject:tableBean];
        }
    }
    return tempArray;
}


-(NSString *) getClassType{
    if ([self isKindOfClass:[NSString class]]) {
        return @"NSString";
    }else if ([self isKindOfClass:[NSDate class]]) {
        return @"NSDate";
    }
    return @"";
}

-(NSArray *) getAllColumns{
    NSArray *columns = [PKCharacterOperate classColumnWithArray:self.class];
    return columns;
}

-(NSArray *) getAllPropertys{
    NSArray *propertys = [PKCharacterOperate classPropertyWithArray:self.class];
    return propertys;
}

-(NSArray *) getOnlyTypeObject:(Class) type{
    if (type != NULL) {
        NSArray *targetArray = [self getAllPropertys];
        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
        for (PKClassBean *classBean in targetArray) {
            if ([classBean.propertyType isEqualToString:NSStringFromClass(type)]) {
                [tempArray addObject:classBean];
            }
        }
        return tempArray;
    }
    return nil;
}

@end
