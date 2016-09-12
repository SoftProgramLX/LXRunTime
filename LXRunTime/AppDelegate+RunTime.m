//
//  AppDelegate+RunTime.m
//  LXRunTime
//
//  Created by 李旭 on 16/9/10.
//  Copyright © 2016年 LX. All rights reserved.
//

#import "AppDelegate+RunTime.h"
#import <objc/runtime.h>

static NSString *switchStr;

@implementation AppDelegate (RunTime)

- (void)testCategory
{
    NSLog(@"\n%@\n%@\n%@", self.testStr1, self.testStr2, self.testStr3);
}

-(NSString *)testStr2
{
    return objc_getAssociatedObject(self, _cmd);//_cmd当前方法的一个SEL指针，与@selector(str)对应，这样可以避免定义一个静态全局变量
}

-(void)setTestStr2:(NSString *)testStr2
{
    objc_setAssociatedObject(self, @selector(testStr2), testStr2, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSString *)testStr3
{
    return switchStr;
}

-(void)setTestStr3:(NSString *)testStr3
{
    switchStr = [testStr3 copy];
}

@end



