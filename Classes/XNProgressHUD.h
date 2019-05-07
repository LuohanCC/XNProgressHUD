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

@property (nonatomic, strong) UIView *maskView; //遮罩
@property (nonatomic, strong) UIView *shadeContentView; //阴影视图
@property (nonatomic, assign) CGColorRef shadowColor; //阴影颜色
@property (nonatomic, strong) UIView *contentView; //标题和动画视图的父视图
@property (nonatomic, strong) UILabel *titleLabel; //标题
@property (nonatomic, strong, readwrite) UIView *refreshView; //动画视图
@property (nonatomic, assign) CGFloat refreshViewWidth; //动画视图的尺寸
@property (nonatomic, assign) XNRefreshViewStyle refreshStyle; //动画视图的样式
@property (nonatomic, assign) CGFloat separatorWidth; //动画视图与标题的间距
//最小延时消失时间（生效于：XNRefreshViewStyleInfoImage、XNRefreshViewStyleError、XNRefreshViewStyleSuccess）
@property (nonatomic, assign) NSTimeInterval minimumDelayDismissDuration;
//最大延时消失时间（生效于：XNRefreshViewStyleLoading、XNRefreshViewStyleProgress）
@property (nonatomic, assign) NSTimeInterval maximumDelayDismissDuration;
@property (nonatomic, assign) BOOL showing; //显示状态
@property (nonatomic, strong) NSString *title; //文字
@property (nonatomic, assign) CGPoint position; //显示位置
@property (nonatomic, assign) HUDPadding padding; //内边距
@property (nonatomic, strong) UIColor *tintColor; //主色调
@property (nonatomic, assign) CGFloat borderWidth; //圆角
@property (nonatomic, assign) NSTimeInterval duration; //动画时长
@property (nonatomic, assign, readonly) XNProgressHUDStyle style; //样式
@property (nonatomic, assign) XNProgressHUDOrientation orientation; //方向,默认为水平b布局

/**
 * 默认为空, 显示在KeyWindow上, 若不为空，有两种情况：
 * 1.targetView=用户自定义的UIWindow，此时maskType不使能，需要锁定点击事件时需设置userInteractionEnabled属性
 * 2.targetView=UIView, 使用方法与默认状态下一样
 */
@property (nonatomic, weak)   UIView *targetView; //指定显示在某个View上
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
 * 是否正在显示
 */
- (BOOL)isShowing;

/**
 * 清理资源
 */
- (void)clearUp;


@end

