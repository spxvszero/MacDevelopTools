//
//  JKApplicationHoldManager.m
//  MacDevelopTools
//
//  Created by 曾坚 on 2018/12/13.
//  Copyright © 2018年 JK. All rights reserved.
//

#import "JKApplicationHoldManager.h"
#import <objc/runtime.h>

@interface NSObject (JKDeallocBlock)

@property (nonatomic, strong) void(^JK_DeallocBlock)(id object);

@end

@implementation NSObject (JKDeallocBlock)

@dynamic JK_DeallocBlock;

- (void)setJK_DeallocBlock:(void (^)(id))JK_DeallocBlock
{
    objc_setAssociatedObject(self, @selector(JK_DeallocBlock), JK_DeallocBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void (^)(id))JK_DeallocBlock
{
    return objc_getAssociatedObject(self, @selector(JK_DeallocBlock));
}


@end


@interface JKApplicationHoldObject : NSObject

@property (nonatomic, strong) NSString *objClassName;
@property (nonatomic, weak) id obj;
@property (nonatomic, strong) void (^DeallocBlock)(JKApplicationHoldObject *holdObject);

@end
@implementation JKApplicationHoldObject

- (void)setObj:(id)obj
{
    _obj = obj;
    self.objClassName = NSStringFromClass([obj class]);
    if (![obj respondsToSelector:NSSelectorFromString(@"exchangeDeallocMethod_signal")]) {
        class_addMethod([obj class], NSSelectorFromString(@"exchangeDeallocMethod_signal"), imp_implementationWithBlock(^(){}), "v@:");
        IMP objDelloc = class_getMethodImplementation([obj class], NSSelectorFromString(@"dealloc"));
        IMP nsDelloc = class_getMethodImplementation([NSObject class], NSSelectorFromString(@"dealloc"));
        if (objDelloc != nsDelloc) {
            Method method = class_getInstanceMethod([obj class], NSSelectorFromString(@"dealloc"));
            IMP imp = class_getMethodImplementation([self class], NSSelectorFromString(@"jk_dealloc"));
            class_addMethod([obj class], NSSelectorFromString(@"jk_dealloc"), imp, "v@:");
            Method changeMethod = class_getInstanceMethod([obj class], NSSelectorFromString(@"jk_dealloc"));
            method_exchangeImplementations(changeMethod, method);
        }else{
            IMP imp = class_getMethodImplementation([self class], @selector(jk_dealloc));
            class_addMethod([obj class], NSSelectorFromString(@"dealloc"), imp, "v@:");
        }
        
    }
    
    __weak typeof(self) weakSelf = self;
    [obj setJK_DeallocBlock:^(id object) {
        if (weakSelf.DeallocBlock) {
            weakSelf.DeallocBlock(weakSelf);
        }
    }];
}

- (void)jk_dealloc
{
    if (self.JK_DeallocBlock) {
        self.JK_DeallocBlock(self);
    }
    
    if ([self respondsToSelector:NSSelectorFromString(@"jk_dealloc")]) {
        [self jk_dealloc];
    }
    NSLog(@"this is jk dealloc");
}

@end


@interface JKApplicationHoldManager ()

@property (nonatomic, strong) NSMutableDictionary *objHoldDic;

@end
@implementation JKApplicationHoldManager


- (void)addObject:(id)obj
{
    JKApplicationHoldObject *holdObj = [[JKApplicationHoldObject alloc] init];
    __weak typeof(self) weakSelf = self;
    holdObj.DeallocBlock = ^(JKApplicationHoldObject *holdObject) {
        NSMutableSet *holdSet = [weakSelf obtainSetWithClassName:holdObject.objClassName];
        [holdSet removeObject:holdObject];
    };
    holdObj.obj = obj;
    
    NSMutableSet *set = [self obtainSetWithClassName:[obj className]];
    [set addObject:holdObj];
}

- (BOOL)hasObject:(id)obj
{
    NSMutableSet *set = [self obtainSetWithClassName:[obj className]];
    return [set containsObject:obj];
}

- (BOOL)hasObjectClass:(NSString *)className
{
    NSMutableSet *set = [self obtainSetWithClassName:className];
    return set.count > 0;
}

- (id)getAnyObjWithClass:(NSString *)className
{
    NSMutableSet *set = [self obtainSetWithClassName:className];
    if (set.count > 0) {
        JKApplicationHoldObject *obj = set.anyObject;
        return obj.obj;
    }else{
        return nil;
    }
}

- (NSMutableSet *)obtainSetWithClassName:(NSString *)className
{
    NSMutableSet *set = [self.objHoldDic objectForKey:className];
    if (!set) {
        set = [NSMutableSet set];
        [self.objHoldDic setObject:set forKey:className];
    }
    return set;
}


- (NSMutableDictionary *)objHoldDic
{
    if (!_objHoldDic) {
        _objHoldDic = [NSMutableDictionary dictionary];
    }
    return _objHoldDic;
}

@end
