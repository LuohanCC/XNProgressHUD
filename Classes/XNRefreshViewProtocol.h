//
//  XNRefreshViewProtocol.h
//  Pods
//
//  Created by 罗函 on 2018/3/22.
//

#import <Foundation/Foundation.h>
#import "XNProgressHUD.h"

@protocol XNRefreshViewProtocol <NSObject>
/*
 * 自定义加载视图时，需要实现以下协议方法
 */
- (NSNumber *)xn_isAnimating;
- (NSNumber *)xn_getStyle;
- (void)xn_setStyle:(NSNumber *)styleValue;
- (void)xn_setProgress:(NSNumber *)progressValue;
- (void)xn_startAnimation;
- (void)xn_stopAnimation; 
@end

