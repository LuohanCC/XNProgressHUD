//
//  XNHUDLayerProtocol.h
//  XNProgressHUD
//
//  Created by jarvis on 2019/7/20.
//  Copyright © 2019 罗函. All rights reserved.
//

#ifndef XNHUDLayerProtocol_h
#define XNHUDLayerProtocol_h

#import <UIKit/UIKit.h>

@protocol XNHUDLayerProtocol <NSObject>
@property (nonatomic, weak, nullable)   CALayer *targetLayer;
@property (nonatomic, strong, nullable) CAMediaTimingFunction *timingFunction;
@property (nonatomic, assign) NSTimeInterval animationDuration;

@property (nullable) CGColorRef xn_strokeColor;
@property (nonatomic, assign) CGFloat xn_lineWidth;
@property (copy, nullable) CAShapeLayerLineCap lineCap;;

- (void)prepare;
- (void)play;
- (void)stop;

@optional
- (void)setProgress:(CGFloat)progress;
@end

#endif /* XNHUDLayerProtocol_h */
