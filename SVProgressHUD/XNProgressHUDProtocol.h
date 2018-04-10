//
//  
//  Pods
//
//  Created by 罗函 on 2018/3/23.
//

#ifndef XNProgressHUDProtocol_h
#define XNProgressHUDProtocol_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

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

// 与RefreshView之间的接口方法，扩展、自定义RefreshView时需要实现重写以下方法
@protocol XNProgressHUDMethod <NSObject>
- (UIView *)refreshView;
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

@end

#endif /* XNProgressHUDProtocol_h */
