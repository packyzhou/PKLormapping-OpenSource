//
//  PKHQLer.m
//  PKLormapping
//
//  Created by 周经伟 on 15/6/20.
//  Copyright © 2015年 packy. All rights reserved.



#import "PKHQLer.h"

@implementation PKHQLer
-(id) initForEntity:(id<PKEntityProtocol>) entiy{
    self = [super init];
    if (self) {
        self.queryConditions = [[NSMutableString alloc] init];
        self.orderByCondition = [[NSMutableString alloc] init];
        self.tableName = [entiy getTableName];
        return self;
    }
    return nil;
}

-(PKHQLer *) addEqual:(NSString *)key value:(id)value{
    if ([key isEqual:nil] || [value isEqual:nil]) {
        return self;
    }
    
    if (![_queryConditions isEqualToString:@""]) {
        [_queryConditions appendString:@" and "];
    }
    value = [PKCharacterOperate extraMapping:value type:[value getClassType]];
    [_queryConditions appendFormat:@"%@ = %@",key,value];
    
    return self;
}

-(PKHQLer *) addNotEqual:(NSString *)key value:(id)value{
    if ([key isEqual:nil] || [value isEqual:nil]) {
        return self;
    }
    
    if (![_queryConditions isEqualToString:@""]) {
        [_queryConditions appendString:@" and "];
    }
    value = [PKCharacterOperate extraMapping:value type:[value getClassType]];
    [_queryConditions appendFormat:@"%@ != %@",key,value];
    
    return self;
}

-(PKHQLer *) addLike:(NSString *)key value:(id)value{
    if ([key isEqual:nil] || [value isEqual:nil]) {
        return self;
    }
    
    if (![_queryConditions isEqualToString:@""]) {
        [_queryConditions appendString:@" and "];
    }
    
    [_queryConditions appendFormat:@"%@ like %@",key,@"'%"];
    [_queryConditions appendFormat:@"%@",value];
    [_queryConditions appendFormat:@"%@",@"%'"];
    return self;
}

-(PKHQLer *) addNotLike:(NSString *)key value:(id)value{
    if ([key isEqual:nil] || [value isEqual:nil]) {
        return self;
    }
    
    if (![_queryConditions isEqualToString:@""]) {
        [_queryConditions appendString:@" and "];
    }
   
    [_queryConditions appendFormat:@"%@ not like %@",key,@"'%"];
    [_queryConditions appendFormat:@"%@",value];
    [_queryConditions appendFormat:@"%@",@"%'"];
    return self;
}

-(PKHQLer *) addStartLike:(NSString *)key value:(id)value{
    if ([key isEqual:nil] || [value isEqual:nil]) {
        return self;
    }
    
    if (![_queryConditions isEqualToString:@""]) {
        [_queryConditions appendString:@" and "];
    }
    value = [PKCharacterOperate extraMapping:value type:[value getClassType]];
    [_queryConditions appendFormat:@"%@ not like %@",key,@"'%"];
    [_queryConditions appendFormat:@"%@'",value];
    [_queryConditions appendFormat:@"%@",@"'"];
    return self;
}

-(PKHQLer *) addEndLike:(NSString *)key value:(id)value{
    if ([key isEqual:nil] || [value isEqual:nil]) {
        return self;
    }
    
    if (![_queryConditions isEqualToString:@""]) {
        [_queryConditions appendString:@" and "];
    }
    value = [PKCharacterOperate extraMapping:value type:[value getClassType]];
    [_queryConditions appendFormat:@"%@ not like %@",key,@"'"];
    [_queryConditions appendFormat:@"%@",value];
    [_queryConditions appendFormat:@"%@",@"%'"];
    return self;
}

-(PKHQLer *) addLessThan:(NSString *)key value:(id)value{
    if ([key isEqual:nil] || [value isEqual:nil]) {
        return self;
    }
    
    if (![_queryConditions isEqualToString:@""]) {
        [_queryConditions appendString:@" and "];
    }
    value = [PKCharacterOperate extraMapping:value type:[value getClassType]];
    [_queryConditions appendFormat:@"%@ < %@",key,value];
    return self;
}

-(PKHQLer *) addLessEqualThan:(NSString *)key value:(id)value{
    if ([key isEqual:nil] || [value isEqual:nil]) {
        return self;
    }
    
    if (![_queryConditions isEqualToString:@""]) {
        [_queryConditions appendString:@" and "];
    }
    value = [PKCharacterOperate extraMapping:value type:[value getClassType]];
    [_queryConditions appendFormat:@"%@ <= %@",key,value];
    return self;
}

-(PKHQLer *) addGreatThan:(NSString *)key value:(id)value{
    if ([key isEqual:nil] || [value isEqual:nil]) {
        return self;
    }
    
    if (![_queryConditions isEqualToString:@""]) {
        [_queryConditions appendString:@" and "];
    }
    value = [PKCharacterOperate extraMapping:value type:[value getClassType]];
    [_queryConditions appendFormat:@"%@ > %@",key,value];
    return self;
}

-(PKHQLer *) addGreatEqualThan:(NSString *)key value:(id)value{
    if ([key isEqual:nil] || [value isEqual:nil]) {
        return self;
    }
    
    if (![_queryConditions isEqualToString:@""]) {
        [_queryConditions appendString:@" and "];
    }
    value = [PKCharacterOperate extraMapping:value type:[value getClassType]];
    [_queryConditions appendFormat:@"%@ >= %@",key,value];
    return self;
}

-(PKHQLer *) addIsNull:(NSString *)key{
    if ([key isEqual:nil] ) {
        return self;
    }
    
    if (![_queryConditions isEqualToString:@""]) {
        [_queryConditions appendString:@" and "];
    }
    
    [_queryConditions appendFormat:@"%@ is null",key];
    return self;
}

-(PKHQLer *) addNotNull:(NSString *)key{
    if ([key isEqual:nil] ) {
        return self;
    }
    
    if (![_queryConditions isEqualToString:@""]) {
        [_queryConditions appendString:@" and "];
    }
    
    [_queryConditions appendFormat:@"%@ not null",key];
    return self;
}

-(PKHQLer *) addEqualDate:(NSString *)key date:(NSString *)date{
    if ([key isEqual:nil] || [date isEqual:nil]) {
        return self;
    }
    
    if (![_queryConditions isEqualToString:@""]) {
        [_queryConditions appendString:@" and "];
    }
    
    [_queryConditions appendFormat:@"%@ = '%@'",key,date];
    return self;

}

-(PKHQLer *) addBetweenDate:(NSString *)key startDate:(NSString *)startDate endDate:(NSString *)endDate{
    if ([key isEqual:nil] || [startDate isEqual:nil]|| [endDate isEqual:nil]) {
        return self;
    }
    
    if (![_queryConditions isEqualToString:@""]) {
        [_queryConditions appendString:@" and "];
    }
    
    [_queryConditions appendFormat:@"%@ between '%@' and '%@'",key,startDate,endDate];
    return self;
}

-(PKHQLer *) addLessDate:(NSString *)key date:(NSString *)date{
    if ([key isEqual:nil] || [date isEqual:nil]) {
        return self;
    }
    
    if (![_queryConditions isEqualToString:@""]) {
        [_queryConditions appendString:@" and "];
    }
    
    [_queryConditions appendFormat:@"%@ < '%@'",key,date];
    return self;
}

-(PKHQLer *) addLessEqualDate:(NSString *)key date:(NSString *)date{
    if ([key isEqual:nil] || [date isEqual:nil]) {
        return self;
    }
    
    if (![_queryConditions isEqualToString:@""]) {
        [_queryConditions appendString:@" and "];
    }
    
    [_queryConditions appendFormat:@"%@ <= '%@'",key,date];
    return self;
}

-(PKHQLer *) addGreatDate:(NSString *)key date:(NSString *)date{
    if ([key isEqual:nil] || [date isEqual:nil]) {
        return self;
    }
    
    if (![_queryConditions isEqualToString:@""]) {
        [_queryConditions appendString:@" and "];
    }
    
    [_queryConditions appendFormat:@"%@ > '%@'",key,date];
    return self;
}

-(PKHQLer *) addGreatEqualDate:(NSString *)key date:(NSString *)date{
    if ([key isEqual:nil] || [date isEqual:nil]) {
        return self;
    }
    
    if (![_queryConditions isEqualToString:@""]) {
        [_queryConditions appendString:@" and "];
    }
    
    [_queryConditions appendFormat:@"%@ >= '%@'",key,date];
    return self;
}

-(PKHQLer *) addIn:(NSString *)key value:(NSArray *)value{
    if ([key isEqual:nil] || [value isEqual:nil]) {
        return self;
    }
    
    if (![_queryConditions isEqualToString:@""]) {
        [_queryConditions appendString:@" and "];
    }
   
    [_queryConditions appendFormat:@"%@ in %@",key,@"("];
    
    for (int i =0 ; i<[value count] ;i++) {
        id rs = [value objectAtIndex:i];
        if (rs != nil) {
            rs = [PKCharacterOperate extraMapping:rs type:[rs getClassType]];
        }
        if (value.count == (i+1)) {
            [_queryConditions appendFormat:@"%@  ",rs];
        }else{
            [_queryConditions appendFormat:@"%@, ",rs];
        }
    }
    [_queryConditions appendFormat:@"%@",@")" ];
    return self;
}

-(PKHQLer *) addNotIn:(NSString *)key value:(NSArray *)value{
    if ([key isEqual:nil] || [value isEqual:nil]) {
        return self;
    }
    
    if (![_queryConditions isEqualToString:@""]) {
        [_queryConditions appendString:@" and "];
    }
    
    [_queryConditions appendFormat:@"%@ not in %@",key,@"("];
    
    for (int i =0 ; i<[value count] ;i++) {
        id rs = [value objectAtIndex:i];
        if (rs != nil) {
            rs = [PKCharacterOperate extraMapping:rs type:[rs getClassType]];
        }
        if (value.count == (i+1)) {
            [_queryConditions appendFormat:@"%@  ",rs];
        }else{
            [_queryConditions appendFormat:@"%@, ",rs];
        }
    }
    [_queryConditions appendFormat:@"%@",@")" ];
    return self;
}

-(PKHQLer *) addOr:(PKHQLer *)hql{
    if (hql==nil||[[hql getHQL] isEqualToString:@""]) {
        return self;
    }
    
    if (![_queryConditions isEqualToString:@""]) {
        [_queryConditions appendString:@" or "];
    }
    NSString *newHQL = [[hql getHQL] stringByReplacingOccurrencesOfString:@"where" withString:@""];
    [_queryConditions appendFormat:@"(%@)",newHQL ];
    return self;
}

-(PKHQLer *) addAllOr:(PKHQLer *)hql{
    if (hql==nil||[[hql getHQL] isEqualToString:@""]) {
        return self;
    }
    
    if (![_queryConditions isEqualToString:@""]) {
        [_queryConditions appendString:@" or "];
    }
    NSString *newHQL = [[hql getHQL] stringByReplacingOccurrencesOfString:@"where" withString:@""];
    NSString *allOrReplace = [newHQL stringByReplacingOccurrencesOfString:@"and" withString:@"or"];
    [_queryConditions appendFormat:@"( %@ )",allOrReplace];
    return self;
}

-(PKHQLer *) addOrderBy:(NSString *)key type:(NSString *)type{
    if ([key isEqual:nil] || [type isEqual:nil]) {
        return self;
    }
    
    if ([_orderByCondition isEqualToString:@""]) {
        [_orderByCondition appendFormat:@"%@ ",key];
    }else{
        [_orderByCondition appendFormat:@",%@ ",key];
    }
    if ([_orderByCondition rangeOfString:@"asc"].location !=NSNotFound  ) {
        _orderByCondition = (NSMutableString *)[_orderByCondition stringByReplacingOccurrencesOfString:@"asc" withString:@""];
    }
    if ([_orderByCondition rangeOfString:@"desc"].location !=NSNotFound  ) {
        _orderByCondition = (NSMutableString *)[_orderByCondition stringByReplacingOccurrencesOfString:@"desc" withString:@""];
    }
    [_orderByCondition appendFormat:@"%@",type];
    return self;
}

-(NSString *) getHQL{
    NSMutableString *hql = [[NSMutableString alloc] init];
    if (![_queryConditions isEqualToString:@""]) {
        [hql appendFormat:@" where %@",_queryConditions];
    }
    if (![_orderByCondition isEqualToString:@""]) {
        [hql appendFormat:@" order by %@",_orderByCondition];
    }
    if (_queryPage != nil) {
        [hql appendFormat:@" limit %i offset %i",_queryPage.rows,_queryPage.page*_queryPage.rows];
    }
    return hql;
}
@end
