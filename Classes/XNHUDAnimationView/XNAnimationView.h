//
//  XNAnimationView.h
//  XNProgressHUD
//
//  Created by jarvis on 2019/7/20.
//  Copyright © 2019 罗函. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XNAnimaionViewProtocol.h"
#import "XNHUDLayerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

//@class XNHUDLoadingLayer, XNHUDErrorLayer, XNHUDSuccessLayer, XNHUDProgressLayer, XNHUDInfoLayer;
@interface XNAnimationView : UIView<XNAnimaionViewProtocol>
@property (nonatomic, assign) XNAnimationViewStyle style;
@property (nonatomic, strong) CALayer<XNHUDLayerProtocol>  *loadingLayer;
@property (nonatomic, strong) CALayer<XNHUDLayerProtocol>  *errorLayer;
@property (nonatomic, strong) CALayer<XNHUDLayerProtocol>  *successLayer;
@property (nonatomic, strong) CALayer<XNHUDLayerProtocol>  *progressLayer;
@property (nonatomic, strong) CALayer<XNHUDLayerProtocol>  *infoLayer;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, readwrite) NSTimeInterval duration;
@property (nullable, nonatomic, strong) CAMediaTimingFunction *timingFunction;
@property (nonatomic, readwrite) CGFloat lineWidth;
@property (nullable, nonatomic, readwrite) UIColor *tintColor;
@property (nullable, nonatomic, readwrite) UIColor *tintBGColor;
@property (nullable, nonatomic, strong) UIImage *infoImage;
@property (nullable, nonatomic, strong) UIImage *errorImage;
@property (nullable, nonatomic, strong) UIImage *successImage;
@end

NS_ASSUME_NONNULL_END
