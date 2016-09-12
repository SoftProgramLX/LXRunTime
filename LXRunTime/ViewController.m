//
//  ViewController.m
//  LXRunTime
//
//  Created by 李旭 on 16/9/10.
//  Copyright © 2016年 LX. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "AppDelegate.h"
#import "NSObject+DictionaryToModel.h"
#import "LXResultModel.h"

//用全局变量的地址作为关联对象的key
static char associatedObjectKey;
static char associatedObjectKey2;

@interface ViewController ()
{
    AppDelegate *appDelegate;
}
@property (nonatomic, strong) id property1;
@property (nonatomic, copy) NSString *property2;

@end

@implementation ViewController

void defualtFunc(id self, SEL _cmd)
{
    NSLog(@"掉用了默认方法");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"测试Runtime";
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self testRunTimeGetValue];
    [self testRunTimeAddValue];
    [self testRunTimeChangeFunction];
    
    //testCategory方法在本类没有实现方法，通过RunTime实现重定向，用AppDelegate单例调用该方法
    [self performSelector:@selector(testRedirect)];

    [self testRunTimeDictionaryToModel];
}

/**
 *  runtime获取变量、属性、方法、协议
 */
- (void)testRunTimeGetValue
{
    unsigned int count;
    
    //获取成员变量列表
    Ivar *ivarList = class_copyIvarList([self class], &count);
    for (unsigned int i=0; i<count; i++) {
        Ivar myivar = ivarList[i];
        const char *ivarname = ivar_getName(myivar);
        const char *ivarType = ivar_getTypeEncoding(myivar); // 获取变量编码类型
        NSString *ivarNameStr = [NSString stringWithUTF8String:ivarname];
        NSLog(@"ivar----="">%@  %@", ivarNameStr, [NSString stringWithUTF8String:ivarType]);
        if ([ivarNameStr isEqualToString:@"_property2"]) {
            [self setValue:@"这是属性值" forKey:@"property2"];
            NSLog(@"self.property2:%@", self.property2);
        }
    }
    
    //获取属性列表
    objc_property_t * propertyList = class_copyPropertyList([self class], &count);
    for (unsigned int i=0; i<count; i++) {
        const char * propertyname = property_getName(propertyList[i]);
        NSLog(@"property----="">%@", [NSString stringWithUTF8String:propertyname]);
    }
    
    //获取方法列表
    Method *methodList = class_copyMethodList([self class], &count);
    for (unsigned int i=0; i<count; i++) {
        Method method = methodList[i];
        NSLog(@"method----=>%@", NSStringFromSelector(method_getName(method)));
    }
    
    //获取协议列表
    __unsafe_unretained Protocol **protocolList = class_copyProtocolList([self class], &count);
    for (unsigned int i=0; i<count; i++) {
        Protocol *myprotocal = protocolList[i];
        const char *protocolname = protocol_getName(myprotocal);         NSLog(@"protocol----="">%@", [NSString stringWithUTF8String:protocolname]);
    }
}

/**
 *  runtime交换方法：
 *  交换实例方法使用class_getInstanceMethod
 *  交换类方法使用class_getClassMethod
 */
- (void)testRunTimeChangeFunction
{
    // 获取 testFunction1方法
    Method testFunction1 = class_getInstanceMethod([self class], @selector(testFunction1));
    
    // 获取 testFunction2方法
    Method testFunction2 = class_getInstanceMethod([self class], @selector(testFunction2));
    
    // 交换方法地址, 相当于交换实现
    method_exchangeImplementations(testFunction1, testFunction2);
    
    [self testFunction1];
    //实际上会掉用testFunction2方法
}

- (void)testFunction1
{
    NSLog(@"runtime交换方法-testFunction1");
}

- (void)testFunction2
{
    NSLog(@"runtime交换方法-testFunction2");
}

/**
 *  runtime添加属性，还可以添加任何对象
 */
- (void)testRunTimeAddValue
{
    //添加属性
    objc_setAssociatedObject(self, &associatedObjectKey, @"addProperty", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    //添加对象
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, 300, 60)];
    label.numberOfLines = 2;
    label.textColor = [UIColor blueColor];
    label.backgroundColor = [UIColor redColor];
    objc_setAssociatedObject(self, &associatedObjectKey2,label, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self getValueOfRunTime];
}

- (void)getValueOfRunTime
{
    //获取关联对象string与label

    NSString *propertyString = objc_getAssociatedObject(self, &associatedObjectKey);

    UILabel *label = objc_getAssociatedObject(self, &associatedObjectKey2);
    label.text = [NSString stringWithFormat:@"动态添加的属性名称为：%@\n此label也是动态添加的对象", propertyString];
    [self.view addSubview:label];
}

/**
 *  runtime过滤：
 *  调用一个不存在的实例方法的时候，会调用resolveInstanceMethod:方法，默认返回NO
 *  调用一个不存在的类方法的时候，会调用resolveClassMethod:方法，默认返回NO
 */
+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    //如果返回NO，则会再掉用forwardingTargetForSelector方法。如果返回Yes，反之不掉用。
#if 1
    return NO;
#else
    if (sel == @selector(testRedirect)) {
        class_addMethod([self class], sel, (IMP)defualtFunc, "v@:");
        return YES;
    }
    return [super resolveClassMethod:sel];
#endif
}

/**
 *  runtime重定向:
 *  将你调用的不存在的方法重定向到一个其他声明了这个方法的类，只需要返回一个有这个方法的target
 *
 */
- (id)forwardingTargetForSelector:(SEL)sel
{
    
    if(sel == @selector(testRedirect)) {
        return appDelegate;
    }
    return [super forwardingTargetForSelector:sel];
}

/**
 *  runtime转发:
 *  是将调用不存在的方法打包成了NSInvocation传递来。做完你自己的处理后，调用invokeWithTarget:方法让某个target触发这个方法
 *
 */
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    if ([appDelegate respondsToSelector:
         [anInvocation selector]]) {
        [anInvocation invokeWithTarget:appDelegate];
    } else {
        [super forwardInvocation:anInvocation];
    }
}

/**
 *  runtime字典转model
 */
- (void)testRunTimeDictionaryToModel
{
    //获取字典数据
    NSDictionary *dictionary = [self getMainBundleResource:@"jsonData.json"];
    
    LXResultModel *model = [LXResultModel modelWithDictionary:dictionary];
    NSLog(@"model.foods[0].food: %@", model.foods[0].food);
}

- (NSDictionary *)getMainBundleResource:(NSString *)file
{
    NSString *pathstr = [[NSBundle mainBundle] pathForResource:file ofType:nil];
    NSData *data = [[NSData alloc] initWithContentsOfFile:pathstr];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    return dictionary;
}

@end


