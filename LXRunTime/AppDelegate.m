//
//  AppDelegate.m
//  LXRunTime
//
//  Created by 李旭 on 16/9/10.
//  Copyright © 2016年 LX. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate+RunTime.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    //testStr1是本类的一个属性
    self.testStr1 = @"testStr1";
    
    //testStr2是分类里通过RunTime实现的一个属性
    self.testStr2 = @"testStr2";
    
    //testStr3是分类里通过静态变量储存实现的一个属性
    self.testStr3 = @"testStr3";
    
    //在分类里使用这三个属性
    [self testCategory];
    
    return YES;
}

- (void)testRedirect
{
    NSLog(@"测试重定向 %s", __func__);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
