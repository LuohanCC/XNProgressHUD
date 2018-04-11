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
- (XNRefreshViewStyle)style;
- (void)setStyle:(XNRefreshViewStyle)style;
- (BOOL)isAnimating; //是否正在播放动画
- (void)startAnimation; //开始动画
- (void)stopAnimation; //停止动画
@end

