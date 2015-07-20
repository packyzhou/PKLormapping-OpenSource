//
//  PKAccessTarget.m
//  PKFrameTest
//
//  Created by 周经伟 on 15/6/23.
//  Copyright © 2015年 packy. All rights reserved.
//

#import "PKAccessTarget.h"

@implementation PKAccessTarget
-(id) init{
    self = [super init];
    if (self) {
        self.isStop = NO;
        return self;
    }
    return nil;
}

@end
