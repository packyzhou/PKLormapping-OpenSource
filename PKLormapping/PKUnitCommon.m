//
//  PKUnitCommon.m
//  PKFrameworkThreadTest
//
//  Created by 周经伟 on 15/6/24.
//  Copyright © 2015年 packy. All rights reserved.
//

#import "PKUnitCommon.h"

@implementation PKUnitCommon
+(NSString *) dateFormatterString:(NSDate *)date formatter:(NSString *) formatter{
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:formatter];
    return [dateformatter stringFromDate:date];
}

+(NSDate *) stringFormatterDate:(NSString *)dateStr formatter:(NSString *)formatter{
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateformatter setTimeZone:timeZone];
    [dateformatter setDateFormat:formatter];
    NSDate * date = [dateformatter dateFromString:dateStr];
    return date;
}

+(void) sqlPrintln:(NSString *)msg{
     NSLog(@"[%@] execute SQL: %@",[PKUnitCommon dateFormatterString:[NSDate date] formatter:@"HH:mm:ss:SSS"],msg);
}
@end
