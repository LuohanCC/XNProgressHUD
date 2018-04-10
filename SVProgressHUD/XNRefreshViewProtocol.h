//
//  XNRefreshViewProtocol.h
//  Pods
//
//  Created by 罗函 on 2018/3/22.
//

#import <Foundation/Foundation.h>
#import "XNProgressHUDProtocol.h"

@protocol XNRefreshViewProtocol <NSObject>
/* 自定义加载视图时，需要实现以下协议方法，由XNProgressHUD控制
 *
 */
- (XNRefreshViewStyle)style;
- (void)setStyle:(XNRefreshViewStyle)style;
- (BOOL)isAnimating; //是否正在播放动画
- (void)startAnimation; //开始动画
- (void)stopAnimation; //停止动画

@optional

/**
 返回转圈动画的View，由XNProgressHUD调用，集成XNProgressHUD并重写该方法即可自定义refreshView
 @return custom refreshview
 */
- (UIView *)refreshView;

@end

