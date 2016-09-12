//
//  LXAddressModel.h
//  LXRunTime
//
//  Created by 李旭 on 16/9/12.
//  Copyright © 2016年 LX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LXLikePlacesModel.h"
#import "LXLikePlacesModel.h"

@interface LXAddressModel : NSObject

@property (nonatomic, copy)   NSString *province;
@property (nonatomic, copy)   NSString *city;
@property (nonatomic, strong) LXLikePlacesModel *likePlaces;

@end
