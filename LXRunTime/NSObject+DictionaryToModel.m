//
//  NSObject+DictionaryToModel.m
//  LXRunTime
//
//  Created by 李旭 on 16/9/12.
//  Copyright © 2016年 LX. All rights reserved.
//

#import "NSObject+DictionaryToModel.h"
#import <objc/runtime.h>

@implementation NSObject (DictionaryToModel)

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary
{
    id objc = [[self alloc] init];
    unsigned int count;

    // 获取类中的所有成员属性
    Ivar *ivarList = class_copyIvarList(self, &count);
    
    for (int i = 0; i < count; i++) {
        // 根据角标，从数组取出对应的成员属性
        Ivar ivar = ivarList[i];
        
        // 获取成员属性名
        NSString *name = [NSString stringWithUTF8String:ivar_getName(ivar)];
        
        // 从第一个角标开始截取，因为属性变量的第一个字符为“_”,
        if (![[name substringToIndex:1] isEqualToString:@"_"]) {
            continue;
        }
        NSString *key = [name substringFromIndex:1];
        // 根据成员属性名去字典中查找对应的value
        id value = dictionary[key];
        
        // 二级转换:如果字典中还有字典，也需要把对应的字典转换成模型
        // 判断下value是否是字典
        if ([value isKindOfClass:[NSDictionary class]]) {
            // 获取成员属性类型
            NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
            
            // 根据字符串类名生成类对象
            Class modelClass = NSClassFromString([self cutClassString:type]);
            
            if (modelClass) { // 有对应的模型才需要转
                // 把字典转模型，采用递归
                value = [modelClass modelWithDictionary:value];
            }
        }
        
        // 三级转换：NSArray中也是字典，把数组中的字典转换成模型.
        // 判断值是否是数组
        if ([value isKindOfClass:[NSArray class]]) {
            // 判断对应类有没有实现字典数组转模型数组的协议
            if ([self respondsToSelector:@selector(arrayContainModelClass)]) {

                // 获取数组中字典对应的模型
                Class classModel = [self arrayContainModelClass][key];
                NSMutableArray *arrM = [NSMutableArray array];
                // 遍历字典数组，生成模型数组
                for (NSDictionary *dict in value) {
                    // 字典转模型
                    id model =  [classModel modelWithDictionary:dict];
                    [arrM addObject:model];
                }

                // 把模型数组赋值给value
                value = arrM;
            }
        }
        if (value) { // 有值，才需要给模型的属性赋值
            // 利用KVC给模型中的属性赋值
            [objc setValue:value forKey:key];
        }
    }
    
    return objc;
}

// 裁剪类型字符串
+ (NSString *)cutClassString:(NSString *)classString
{
    // 生成的是这种@"User" 类型,在OC字符串中 \是转义的意思，不占用字符
    NSRange range = [classString rangeOfString:@"\""];
    classString = [classString substringFromIndex:range.location + range.length];
    range = [classString rangeOfString:@"\""];
    classString = [classString substringToIndex:range.location];
    return classString;
}

@end



