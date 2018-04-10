//
//  UIViewController+XNProgressHUD.h
//  Pods
//
//  Created by 罗函 on 2018/3/23.
//

#import <UIKit/UIKit.h>
#import "XNProgressHUD.h"

#pragma mark - show hud on viewcontroller
@interface UIViewController (XNProgressHUD)
- (XNProgressHUD *)hud;
@end
