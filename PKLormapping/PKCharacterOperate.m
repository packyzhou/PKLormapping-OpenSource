//
//  PKCharacterOperate.m
//  PKLormapping
//
//  Created by 周经伟 on 15/6/23.
//  Copyright © 2015年 packy. All rights reserved.
//

#import "PKCharacterOperate.h"

@implementation PKCharacterOperate
+(NSString *) humpCharacterOperate:(NSString *) character{
    NSMutableString *targetChar = [[NSMutableString alloc] init];
    int startId = 0;
    int endId = 0;
    for(int i =0; i < [character length]; i++)
    {
        char c = [character characterAtIndex:i];
        if(isupper(c)&& endId!=0){
            //大写
            [targetChar appendString:
             [[character substringWithRange:
               NSMakeRange(startId, endId)] uppercaseString]];
            [targetChar appendString:@"_"];
            startId = i;
            endId = 0;

        }else if(i == [character length]-1){
            [targetChar appendString:
             [[character substringWithRange:
               NSMakeRange(startId, endId+1)] uppercaseString]];
        }

        endId++;
    }
    return targetChar;
}

+(NSArray *) classPropertyWithArray:(Class)class{
    NSMutableArray *targetArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    
    unsigned int propertyCount = 0;
    unsigned int attributeCount = 0;
    
    objc_property_t *propertyArray = class_copyPropertyList(class, &propertyCount);
    for (int i = 0; i < propertyCount; i++) {
        PKClassBean *map = [[PKClassBean alloc] init];
        
        objc_property_t property = propertyArray[i];
        NSString *propertyName = [NSString stringWithFormat:@"%s",property_getName(property)];//属性名
        
        objc_property_attribute_t *attributes = property_copyAttributeList(property, &attributeCount);
        for (int j = 0;j <attributeCount;j++) {
            objc_property_attribute_t attribute = attributes[j];
            if ([[NSString stringWithFormat:@"%s",attribute.name] isEqualToString:@"T"]) {
                NSString *type ;//属性类型
                type =[NSString stringWithFormat:@"%s",attribute.value  ];
                type = [type stringByReplacingOccurrencesOfString:@"@\"" withString:@""];
                type = [type stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                map.propertyType = type;
            }
        }
        free(attributes);
        map.propertyName = propertyName;
       
        [targetArray addObject:map];
    }
    free(propertyArray);
    
    
    return targetArray;
}

+(NSArray *) classColumnWithArray:(Class) class{
    NSMutableArray *targetArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSArray *propertys = [self classPropertyWithArray:class];
    for (PKClassBean *map in propertys) {
        PKTableBean *tableColumn = [[PKTableBean alloc] init];
        tableColumn.columnName =[PKCharacterOperate humpCharacterOperate:map.propertyName];
        tableColumn.columnType = map.propertyType;
        [targetArray addObject:tableColumn];
    }
    
    return targetArray;
}

+(NSString *) objTypeTranslateDataType:(NSString *)type{
    if ([type isEqualToString:@"NSString"]) {
        return @"TEXT";
    }else if ([type isEqualToString:@"i"]) {
        return @"INTEGER";
    }else if ([type isEqualToString:@"l"]) {
        return @"INTEGER";
    }else if ([type isEqualToString:@"c"]) {
        return @"Boolean";
    }else if ([type isEqualToString:@"NSDate"]) {
        return @"Timestamp";
    }else if ([type isEqualToString:@"f"]) {
        return @"Float";
    }else if ([type isEqualToString:@"d"]) {
        return @"Double";
    }else if ([type isEqualToString:@"NSData"]) {
        return @"BLOB";
    }else if ([type isEqualToString:@"NSNumber"]) {
        return @"Float";
    }else{
        return @"";
    }
}

+(id) extraMapping:(id) value type:(NSString *)type{
    if ([type isEqualToString:@"NSString"]) {
        return [NSString stringWithFormat:@"'%@'",value ];
    }if ([type isEqualToString:@"NSDate"]) {
        return [NSString stringWithFormat:@"'%@'",[PKUnitCommon dateFormatterString:value formatter:@"yyyy-MM-dd HH:mm:ss"] ];
    }
    return value;
}
@end
