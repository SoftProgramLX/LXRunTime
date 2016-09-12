##runtime 的运行时机制
runtime 又叫运行时，是一套底层的 C 语言 API，其为 iOS 内部的核心之一，我们平时编写的 OC 代码，底层都是基于它来实现的。Objective-C语言是一门动态语言。

##runtime 的作用
* 能获得某个类的所有成员变量、属性、方法、协议
* 能动态添加一个成员变量、属性、方法
* 过滤
* 重定向
* 交换方法
* 转发
* 字典转模型

##demo演示
####1.runtime获取变量、属性、方法、协议
```objective-c
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
```

####2.runtime添加属性，还可以添加任何对象
```objective-c
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

    NSString *string = objc_getAssociatedObject(self, &associatedObjectKey);
    
    UILabel *label = objc_getAssociatedObject(self, &associatedObjectKey2);
    label.text = [NSString stringWithFormat:@"动态添加的属性名称为：%@\n此label也是动态添加的对象", string];
    [self.view addSubview:label];
}
```

####3. runtime过滤
调用一个不存在的实例方法的时候，会调用resolveInstanceMethod:方法；调用一个不存在的类方法的时候，会调用resolveClassMethod:方法；
如果resolveInstanceMethod：返回NO，则会再掉用forwardingTargetForSelector方法实现转发。如果返回Yes，反之不掉用。从而实现过滤的作用。
```objective-c
+ (BOOL)resolveInstanceMethod:(SEL)sel
{
#if 1
    return NO;
#else
    if (sel == @selector(testCategory)) {
        class_addMethod([self class], sel, (IMP)defualtFunc, "v@:");
        return YES;
    }
    return [super resolveClassMethod:sel];
#endif
}
```

####4. runtime重定向
将你调用的不存在的方法重定向到一个其他声明了这个方法的类，只需要返回一个有这个方法的target。
```objective-c
- (id)forwardingTargetForSelector:(SEL)sel
{
    if(sel == @selector(testCategory)) {
        return appDelegate;
    }
    return [super forwardingTargetForSelector:sel];
}
```

####5. runtime交换方法
交换实例方法使用class_getInstanceMethod。交换类方法使用class_getClassMethod。
```objective-c
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
```

####6. runtime转发
是将调用不存在的方法打包成了NSInvocation传递来。做完你自己的处理后，调用invokeWithTarget:方法让某个target触发这个方法
```objective-c
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    if ([appDelegate respondsToSelector:
         [anInvocation selector]]) {
        [anInvocation invokeWithTarget:appDelegate];
    } else {
        [super forwardInvocation:anInvocation];
    }
}
```

####7. runtime字典转模型
* 用法：通过方法modelWithDictionary:传入了一个字典，返回一个对应的model，用法简单。

```objective-c
- (void)testRunTimeDictionaryToModel
{
    //获取字典数据
    NSDictionary *dictionary = [self getMainBundleResource:@"jsonData.json"];
    
    LXResultModel *model = [LXResultModel modelWithDictionary:dictionary];
    NSLog(@"model.foods[0].food: %@", model.foods[0].food);
}
```

* 必要条件：根据字典结构（在jsonData.json文件中）创建对应的model层级结构（在RuntimeDicToModel文件夹中），并将字典的key声明为model的属性名称。字典结构如下，因此对应的model可以这样取到值，正如上面的NSLog输出为：model.foods[0].food: rice。
```objective-c
{
    "address": {
        "city": "遵义市",
        "likePlaces": {
            "place": "HongKong"
        },
        "province": "贵州省"
    },
    "age": 25,
    "foods" :[
    {
        "food": "rice",
        "fruit": "apple",
    },
    {
        "food": "noodle",
        "fruit": "watermelon",
    }
    ],
    "name": "lixu"
}
```

* 核心代码：使用到runtime的逻辑处理，可以将字典里的arr子元素数据转化为model，也可以将字典里包含的字典转化为model（用递归算法）。

```objective-c
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
```

##讨论
为了瘦身ViewController或者AppDelegate代码，常常用到继承、封装、分类等方案，这里为了结合runtime只讨论分类。

现在的需求是将AppDelegate里的代码部分隔离到AppDelegate+RunTime中，其中需要引用AppDelegate的一个属性testStr。

好，重点来了，下面我采用了三种方案可以在AppDelegate+RunTime中引用属性testStr。分别用testStr1、testStr2 、testStr3表示。

方案一：在本类AppDelegate的.h声明属性，即可在分类中导入本类头文件，引用其属性了
```objective-c
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, copy)   NSString *testStr1;

- (void)testRedirect;

@end
```

将testStr2与testStr3都声明在了分类中
```objective-c
@interface AppDelegate (RunTime)

@property (nonatomic, copy)   NSString *testStr2;
@property (nonatomic, copy)   NSString *testStr3;

- (void)testCategory;

@end
```

方案二：在AppDelegate+RunTime.m中重写testStr2 的set和get方法，使用runtime实现给分类添加属性。
```objective-c
-(NSString *)testStr2
{
    return objc_getAssociatedObject(self, _cmd);//_cmd当前方法的一个SEL指针，与@selector(str)对应，这样可以避免定义一个静态全局变量
}

-(void)setTestStr2:(NSString *)testStr2
{
    objc_setAssociatedObject(self, @selector(testStr2), testStr2, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
```

方案三：在AppDelegate+RunTime.m中重写testStr3 的set和get方法，使用全局静态变量switchStr去引用testStr3的值实现给分类添加属性。
```objective-c
static NSString *switchStr;

-(NSString *)testStr3
{
    return switchStr;
}

-(void)setTestStr3:(NSString *)testStr3
{
    switchStr = [testStr3 copy];
}
```

通过调用testCategory方法可以看到三种方案设置的属性都可以正常获取值，那么平时你使用的是哪种方案呢？为什么呢？

<br>
源码请点击[github地址](https://github.com/SoftProgramLX/LXRunTime)下载。
---
QQ:2239344645    [我的github](https://github.com/SoftProgramLX?tab=repositories)<br>
