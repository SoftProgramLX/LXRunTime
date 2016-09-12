//
//  AppDelegate.h
//  LXRunTime
//
//  Created by 李旭 on 16/9/10.
//  Copyright © 2016年 LX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, copy)   NSString *testStr1;

- (void)testRedirect;

@end

