//
//  XNRefreshView.h
//  XNTools
//
//  Created by 罗函 on 2018/2/8.
//

#import <UIKit/UIKit.h>
#import "XNRefreshViewProtocol.h"


@interface XNRefreshView : UIView <XNRefreshViewProtocol>
@property (nullable, nonatomic, readonly) CAShapeLayer *refreshShapeLayer;
@property (nullable, nonatomic, readonly) CAShapeLayer *shapeLayer;
@property (nullable, nonatomic, strong) NSString *lineCap;
@property (nullable, nonatomic, strong) CAMediaTimingFunction *timingFunction;
@property (nullable, nonatomic, readwrite) UIColor *tintColor;
@property (nonatomic, readwrite) CGFloat percentComplete;
@property (nonatomic, readwrite) CGFloat lineWidth;
@property (nonatomic, readwrite) NSTimeInterval duration;

@property (nonatomic, assign) XNRefreshViewStyle style; //样式
@property (nonatomic, readwrite) CGFloat progress;
@property (nullable, nonatomic, readwrite) UILabel *label;
@property (nullable, nonatomic, strong) UIImage *infoImage;
@property (nullable, nonatomic, strong) UIImage *errorImage;
@property (nullable, nonatomic, strong) UIImage *successImage;


@end
