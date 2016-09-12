//
//  NSObject+DictionaryToModel.h
//  LXRunTime
//
//  Created by 李旭 on 16/9/12.
//  Copyright © 2016年 LX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (DictionaryToModel)

+ (void)transformToModelByDictionary:(NSDictionary *)dict;

@end
