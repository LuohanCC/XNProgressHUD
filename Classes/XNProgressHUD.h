//
//  XNProgressHUD.h
//  XNTools
//
//  Created by 罗函 on 2018/2/8.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define HUDScreenSize [UIScreen mainScreen].bounds.size
#define HUDWeakSelf __weak typeof(self) weakSelf = self
#define XNRefreshViewWidth 26.f
#define XNHUD [XNProgressHUD shared]

typedef NS_ENUM(NSUInteger, XNProgressHUDOrientation) {
    XNProgressHUDOrientationHorizontal = 0,
    XNProgressHUDOrientationVertical
};

typedef NS_ENUM(NSInteger, XNProgressHUDStyle) {
    XNProgressHUDStyleTitle = 0,   //只显示标题
    XNProgressHUDStyleLoading, //只显示圈
    XNProgressHUDStyleLoadingAndTitle //显示圈+标题
};

typedef NS_ENUM(NSUInteger, XNProgressHUDMaskType) {
    XNProgressHUDMaskTypeNone = 0,
    XNProgressHUDMaskTypeClear,
    XNProgressHUDMaskTypeBlack,
    XNProgressHUDMaskTypeCustom
};

typedef NS_ENUM (NSInteger, XNRefreshViewStyle) {
    XNRefreshViewStyleNone = 0,
    XNRefreshViewStyleLoading,
    XNRefreshViewStyleProgress,
    XNRefreshViewStyleInfoImage,
    XNRefreshViewStyleError,
    XNRefreshViewStyleSuccess
};

typedef void(^HUDDismissBlock) (void);

typedef struct HUDPadding {
    CGFloat top, left, bottom, right;
} HUDPadding;

CG_INLINE HUDPadding
HUDPaddingMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right) {
    HUDPadding padding = {top, left, bottom, right};
    return padding;
}

typedef struct XNHUDMaskColor {
    unsigned int clear, black, custom;
} XNHUDMaskColor;
CG_INLINE XNHUDMaskColor
XNHUDMaskColorMake(unsigned int  clear, unsigned int black, unsigned int custom) {
    XNHUDMaskColor maskColor = {clear, black, custom};
    return maskColor;
}

// 控制RefreshView显示状态的方法，与协议XNRefreshViewProtocol对应
@protocol XNProgressHUDMethod <NSObject>
- (XNRefreshViewStyle)getStyleFromRefreshView;
- (void)setStyleInRefreshView:(XNRefreshViewStyle)style;
- (void)startRefreshAnimation;
- (void)stopRefreshAnimation;
- (void)setProgressInRefreshView:(CGFloat)progress;
@end

@protocol XNProgressHUDProtocol <NSObject>
@optional

/**
 * 显示Loading
 */
- (void)show;
- (void)showWithMaskType:(XNProgressHUDMaskType)maskType;

/**
 * 显示转圈视图 + 提示文字
 */
- (void)showLoadingWithTitle:(nullable NSString *)title;
- (void)showLoadingWithTitle:(nullable NSString *)title maskType:(XNProgressHUDMaskType)maskType;

/**
 * 显示提示文字
 */
- (void)showWithTitle:(nullable NSString *)title;
- (void)showWithTitle:(nullable NSString *)title maskType:(XNProgressHUDMaskType)maskType;

/**
 * 进度视图 + 提示文字
 */
- (void)showProgressWithProgress:(float)progress;
- (void)showProgressWithTitle:(nullable NSString *)title progress:(float)progress;
- (void)showProgressWithTitle:(nullable NSString *)title progress:(float)progress maskType:(XNProgressHUDMaskType)maskType;

/**
 * 显示提示视图 + 提示文字(警告)
 */
- (void)showInfoWithTitle:(nullable NSString *)title;
- (void)showInfoWithTitle:(nullable NSString *)title maskType:(XNProgressHUDMaskType)maskType;

/**
 * 显示提示视图 + 提示文字(操作失败)
 */
- (void)showErrorWithTitle:(nullable NSString*)title;
- (void)showErrorWithTitle:(nullable NSString*)title maskType:(XNProgressHUDMaskType)maskType;

/**
 * 显示提示视图 + 提示文字(操作成功)
 */
- (void)showSuccessWithTitle:(nullable NSString*)title;
- (void)showSuccessWithTitle:(nullable NSString*)title maskType:(XNProgressHUDMaskType)maskType;

- (void)dismiss;
- (void)dismissWithDelay:(NSTimeInterval)delay;

@end


@interface XNProgressHUD : NSObject <XNProgressHUDProtocol, XNProgressHUDMethod>

@property (nonatomic, strong, readwrite) UIView *refreshView;
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
@property (nonatomic, assign) BOOL showing; 
@property (nonatomic, strong) NSString *title; //文字
@property (nonatomic, strong) UIColor *tintColor; //主色色调
@property (nonatomic, weak)   UIViewController *viewController; //是否显示在ViewController上，为空时显示在Window上
@property (nonatomic, readonly, weak) UIView *targetView; //指定显示在某个View上
//MaskView
@property (nonatomic, assign, readonly) XNProgressHUDMaskType maskType;
@property (nonatomic, assign) struct XNHUDMaskColor maskColor;
@property (nonatomic, strong) HUDDismissBlock hudDismissBlock; //点击遮罩时的回调

/**
 单例（define：XNHUD）
 */
+ (instancetype)shared;

/**
 * 只对下一次显示生效：设置延时时间（延时显示时间、延时消失时间）
 */
- (void)setDisposableDelayResponse:(NSTimeInterval)delayResponse delayDismiss:(NSTimeInterval)delayDismiss;

/**
 * 只对下一次显示生效：设置遮罩类型
 */
- (void)setMaskType:(XNProgressHUDMaskType)maskType;
- (void)setMaskType:(XNProgressHUDMaskType)maskType hexColor:(uint32_t)color;

/**
 * 设置目标显示视图，并传入HUD显示位置
 */
- (void)setTargetView:(UIView *)targetView position:(CGPoint)position;

/**
 * 是否正在显示
 */
- (BOOL)isShowing;

/**
 * 清理资源
 */
- (void)clearUp;


@end

