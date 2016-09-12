//
//  LXResultModel.h
//  LXRunTime
//
//  Created by 李旭 on 16/9/12.
//  Copyright © 2016年 LX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LXAddressModel.h"
#import "LXFoodsModel.h"

@interface LXResultModel : NSObject

@property (nonatomic, copy)   NSString *name;
@property (nonatomic, copy)   NSArray<LXFoodsModel *> *foods;
@property (nonatomic, copy)   NSNumber *age;
@property (nonatomic, strong) LXAddressModel *address;

@end

