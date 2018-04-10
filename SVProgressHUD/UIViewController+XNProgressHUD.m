//
//  UIViewController+XNProgressHUD.m
//  Pods
//
//  Created by 罗函 on 2018/3/23.
//

#import "UIViewController+XNProgressHUD.h"
#import <objc/runtime.h>

#pragma mark - show hud on viewcontroller
static char VCXNProgressHUD;
@implementation UIViewController (XNProgressHUD)

- (void)setHud:(XNProgressHUD *)hud {
    objc_setAssociatedObject(self, &VCXNProgressHUD, hud, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (XNProgressHUD *)hud {
    XNProgressHUD *hudView = objc_getAssociatedObject(self, &VCXNProgressHUD);
    if(!hudView) {
        hudView = [[XNProgressHUD alloc] init];
        hudView.viewController = self;
        [self setHud:hudView];
    }
    return hudView;
}

// replaceMethods
+ (void)load {
    [self exchangeMethod:@"viewDidDisappear:" exchangeMethod:@selector(vcViewDidDisappear:)];
}

+ (void)exchangeMethod:(NSString *)originalMethodStr exchangeMethod:(SEL)exchangeMethodSel {
    Method originalMethod = class_getInstanceMethod([self class], NSSelectorFromString(originalMethodStr));
    Method exchangeMethod = class_getInstanceMethod([self class], exchangeMethodSel);
    if (!class_addMethod([self class], exchangeMethodSel, method_getImplementation(exchangeMethod), method_getTypeEncoding(exchangeMethod))) {
        method_exchangeImplementations(exchangeMethod, originalMethod);
    }
}

- (void)vcViewDidDisappear:(BOOL)animated {
    [self vcViewDidDisappear:animated];
    XNProgressHUD *hudView = objc_getAssociatedObject(self, &VCXNProgressHUD);
    if(hudView) {
        [hudView clearUp];
        hudView = nil;
    }
}

@end
