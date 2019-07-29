//
//  XNHUDSuccessLayer.m
//  XNProgressHUD
//
//  Created by jarvis on 2019/7/20.
//  Copyright © 2019 罗函. All rights reserved.
//

#import "XNHUDSuccessLayer.h"

@interface XNHUDSuccessLayer ()
@property (nonatomic, strong) CAShapeLayer *success;
@property (nonatomic, strong) CAShapeLayer *circular;
@end

@implementation XNHUDSuccessLayer
@synthesize timingFunction;
@synthesize targetLayer;
@synthesize animationDuration;
@synthesize lineCap;
@synthesize xn_lineWidth;
@synthesize xn_strokeColor;

- (instancetype)init {
    if (!(self = [super init])) return nil;
    _success = [CAShapeLayer layer];
    _circular = [CAShapeLayer layer];
    [self addSublayer:_success];
    [self addSublayer:_circular];
    return self;
}

- (void)drawInContext:(CGContextRef)ctx {
    [super drawInContext:ctx];
    UIGraphicsPushContext(ctx);
    
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    float radius = self.bounds.size.width/2.0, start = 0.f, end = M_PI * 2;
    UIBezierPath *path2 = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:start endAngle:end clockwise:true];
    _circular.path = path2.CGPath;
    _circular.bounds = path2.bounds;
    _circular.position = center;
    _circular.fillColor = [UIColor clearColor].CGColor;
    
    CGFloat width = self.bounds.size.width;
    UIBezierPath* path = [UIBezierPath bezierPath];
    [path moveToPoint: CGPointMake(width / 4.8, width / 1.9)];
    [path addLineToPoint: CGPointMake(width / 2.39, width / 1.4)];
    [path addLineToPoint: CGPointMake(width / 1.3, width / 3.55)];
    _success.path = path.CGPath;
    _success.actions = @{@"strokeStart":[NSNull null], @"strokeEnd":[NSNull null], @"transform":[NSNull null]};
    _success.strokeStart = 0.f;
    _success.strokeEnd = 0.9f;
    _success.position = center;
    _success.fillColor = [UIColor clearColor].CGColor;
    _success.lineWidth = _circular.lineWidth = xn_lineWidth;
    _success.strokeColor = _circular.strokeColor = xn_strokeColor;
    CGPathRef strokingPath = CGPathCreateCopyByStrokingPath(_success.path, nil, _success.lineWidth, kCGLineCapRound, kCGLineJoinMiter, 0);
    _success.bounds = CGPathGetPathBoundingBox(strokingPath);
    
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
    
    // drawing
    [self setNeedsDisplay];
}

- (void)play {
    [_success removeAllAnimations];
    if (!self.superlayer) {
        [self.targetLayer addSublayer:self];
    }
    //对勾动画
    CABasicAnimation *arc = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    arc.fromValue = @(0.0);
    arc.toValue = @(1.0);
    arc.duration = 0.4;
    arc.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    arc.removedOnCompletion = NO;
    arc.fillMode = kCAFillModeForwards;
    [_success addAnimation:arc forKey:arc.keyPath];
}

- (void)stop {
    if(_success.animationKeys) {
        [_success removeAllAnimations];
    }
    if(self.superlayer) {
        [self removeFromSuperlayer];
    }
}
@end
