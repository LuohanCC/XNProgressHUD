//
//  XNProgressHUD.h
//  XNTools
//
//  Created by 罗函 on 2018/2/8.
//

#import <Foundation/Foundation.h>
#import "XNProgressHUDProtocol.h"

#define HUDScreenSize [UIScreen mainScreen].bounds.size
#define HUDWeakSelf __weak typeof(self) weakSelf = self
#define XNRefreshViewWidth 26.f

#define XNHUD [XNProgressHUD shared]
@interface XNProgressHUD : NSObject <XNProgressHUDProtocol, XNProgressHUDMethod>

@property (nonatomic, assign) XNProgressHUDOrientation orientation;
@property (nonatomic, assign, readonly) XNProgressHUDStyle style;
@property (nonatomic, assign) CGFloat borderWidth; //圆角
@property (nonatomic, assign) NSTimeInterval duration; //动画时长
//最小延时消失时间（生效于：XNRefreshViewStyleInfoImage、XNRefreshViewStyleError、XNRefreshViewStyleSuccess）
@property (nonatomic, assign) NSTimeInterval minimumDelayDismissDuration;
//最大延时消失时间（生效于：XNRefreshViewStyleLoading、XNRefreshViewStyleProgress）
@property (nonatomic, assign) NSTimeInterval maximumDelayDismissDuration;
@property (nonatomic, assign) CGPoint position; //显示位置
@property (nonatomic, assign) CGFloat refreshViewWidth; //转圈视图的尺寸
@property (nonatomic, assign) XNRefreshViewStyle refreshStyle; //样式
@property (nonatomic, assign) CGColorRef shadowColor; //阴影颜色
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) BOOL showing; //是否正在显示
@property (nonatomic, strong) NSString *title; //文字
@property (nonatomic, strong) UIColor *tintColor; //色调
@property (nonatomic, weak)   UIViewController *viewController; //是否显示在ViewController上，为空时显示在Window上
//MaskView
@property (nonatomic, assign, readonly) XNProgressHUDMaskType maskType;
@property (nonatomic, assign) struct XNHUDMaskColor maskColor;
@property (nonatomic, strong) HUDDismissBlock hudDismissBlock; //点击遮罩时的回调

/**
 单例（define：XNHUD）
 */
+ (instancetype)shared;

/**
 * 一次性生效：设置延时时间（延时显示时间、延时消失时间）
 */
- (void)setDisposableDelayResponse:(NSTimeInterval)delayResponse delayDismiss:(NSTimeInterval)delayDismiss;

/**
 * 一次性生效：设置遮罩类型
 */
- (void)setMaskType:(XNProgressHUDMaskType)maskType;
- (void)setMaskType:(XNProgressHUDMaskType)maskType hexColor:(uint32_t)color;

/**
 * 是否正在显示
 */
- (BOOL)isShowing;

/**
 * 清理资源
 */
- (void)clearUp;
@end



