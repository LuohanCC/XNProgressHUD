//
//  XNHUDErrorLayer.m
//  XNProgressHUD
//
//  Created by jarvis on 2019/7/20.
//  Copyright © 2019 罗函. All rights reserved.
//

#import "XNHUDErrorLayer.h"

@interface XNHUDErrorLayer();
@property (nonatomic, strong) CAShapeLayer *error01;
@property (nonatomic, strong) CAShapeLayer *error02;
@property (nonatomic, strong) CAShapeLayer *circular;
@end

@implementation XNHUDErrorLayer
@synthesize timingFunction;
@synthesize targetLayer;
@synthesize animationDuration;
@synthesize xn_lineWidth;
@synthesize xn_strokeColor;
@synthesize lineCap;

- (instancetype)init {
    if (!(self = [super init])) return nil;
    _error01 = [CAShapeLayer layer];
    _error02 = [CAShapeLayer layer];
    _circular = [CAShapeLayer layer];
    [self addSublayer:_circular];
    [self addSublayer:_error01];
    [self addSublayer:_error02];
    return self;
}

- (void)addAnimationAtTBLayer:(CAShapeLayer *)layer transform:(CATransform3D)transform{
    NSTimeInterval transformDuration = self.animationDuration * 0.25;
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnimation.duration = transformDuration;
    transformAnimation.beginTime = CACurrentMediaTime();
    transformAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.5 :-1.55 :0.5 :1];
    transformAnimation.toValue = [NSValue valueWithCATransform3D: transform];
    transformAnimation.repeatCount = 1;
    transformAnimation.autoreverses = NO;
    transformAnimation.removedOnCompletion = NO;
    transformAnimation.fillMode = kCAFillModeForwards;
    [layer addAnimation:transformAnimation forKey:@"errorAnimation"];
}

- (void)drawInContext:(CGContextRef)ctx {
    [super drawInContext:ctx];
    UIGraphicsPushContext(ctx);
    
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    float radius = self.bounds.size.width/2.0, from = 0.f, to = M_PI * 2;
    UIBezierPath *path2 = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:from endAngle:to clockwise:true];
    _circular.path = path2.CGPath;
    _circular.bounds = path2.bounds;
    _circular.position = center;
    _circular.fillColor = [UIColor clearColor].CGColor;
    
    CGFloat width = self.bounds.size.width * 0.55;
    UIBezierPath* path = [UIBezierPath bezierPath];
    [path moveToPoint: CGPointMake(0, self.bounds.size.height/2)];
    [path addLineToPoint: CGPointMake(width, self.bounds.size.height/2)];
    _error01.path = _error02.path = path.CGPath;
    _error01.bounds = _error02.bounds = path.bounds;
    _error01.position = _error02.position = center;
    
    UIGraphicsPopContext();
}

#pragma mark - XNHUDLayerProtocol
- (void)prepare {
    if (self.animationDuration == 0) {
        self.animationDuration = 2.0;
    }
    if (!self.timingFunction) {
        self.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    }
    if (xn_lineWidth == 0) {
        xn_lineWidth = 1.8f;
    }
    if (!xn_strokeColor ) {
        xn_strokeColor = [UIColor blackColor].CGColor;
    }
    _error01.lineWidth = _error02.lineWidth = _circular.lineWidth = xn_lineWidth;
    _error01.strokeColor = _error02.strokeColor = _circular.strokeColor = xn_strokeColor;
    
    // drawing
    [self setNeedsDisplay];
}

- (void)play {
    [_error01 removeAllAnimations];
    [_error02 removeAllAnimations];
    if (!self.superlayer) {
        [self.targetLayer addSublayer:self];
    }
    CATransform3D translation = CATransform3DMakeTranslation(0, 0, 0);
    CATransform3D topTransfrom = CATransform3DRotate(translation, -M_PI_4, 0, 0, 1);
    CATransform3D bottomTransfrom = CATransform3DRotate(translation, M_PI_4, 0, 0, 1);
    [self addAnimationAtTBLayer:_error01 transform:topTransfrom];
    [self addAnimationAtTBLayer:_error02 transform:bottomTransfrom];
}

- (void)stop {
    if(_error01.animationKeys) {
        [_error01 removeAllAnimations];
        [_error02 removeAllAnimations];
    }
    if(self.superlayer) {
        [self removeFromSuperlayer];
    }
}

@end
