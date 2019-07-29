//
//  XNHUDLoadingLayer.m
//  XNProgressHUD
//
//  Created by jarvis on 2019/7/20.
//  Copyright © 2019 罗函. All rights reserved.
//

#import "XNHUDLoadingLayer.h"

static NSString *kMMRingStrokeAnimationKey = @"materialdesignspinner.stroke";
static NSString *kMMRingRotationAnimationKey = @"materialdesignspinner.rotation";

@interface XNHUDLoadingLayer()
@property (nonatomic, strong) CAShapeLayer *loading;
@end

@implementation XNHUDLoadingLayer
@synthesize timingFunction;
@synthesize targetLayer;
@synthesize animationDuration;
@synthesize lineCap;
@synthesize xn_lineWidth;
@synthesize xn_strokeColor;

- (instancetype)init {
    if (!(self = [super init])) return nil;
    _loading = [CAShapeLayer layer];
    [self addSublayer:_loading];
    return self;
}

- (void)setCustomPath:(CAShapeLayer *)layer {
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat radius = MIN(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2) - layer.lineWidth / 2;
    CGFloat startAngle = 0.f;
    CGFloat endAngle = M_PI * 2.f;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    layer.path = path.CGPath;
    layer.strokeStart = 0.f;
    layer.strokeEnd = 0.f;
    layer.frame = self.bounds;
}

- (void)drawInContext:(CGContextRef)ctx {
    [super drawInContext:ctx];
    UIGraphicsPushContext(ctx);
    
    [self setCustomPath:_loading];
    
    _loading.lineCap = kCALineCapRound;
    _loading.lineJoin = kCALineJoinBevel;
    _loading.strokeColor = xn_strokeColor;
    _loading.fillColor = [UIColor clearColor].CGColor;
    _loading.lineWidth = xn_lineWidth;
    _loading.position = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
    
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
    
    // drawing
    [self setNeedsDisplay];
}

- (void)play {
    [_loading removeAnimationForKey:kMMRingStrokeAnimationKey];
    
    if (!self.superlayer) {
        [self.targetLayer addSublayer:self];
    }
    float duration = self.animationDuration;
    
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"transform.rotation";
    animation.duration = duration / 0.5;
    animation.fromValue = @(0.f);
    animation.toValue = @(2 * M_PI);
    animation.repeatCount = INFINITY;
    animation.removedOnCompletion = NO;
    [_loading addAnimation:animation forKey:kMMRingRotationAnimationKey];
    
    CABasicAnimation *headAnimation = [CABasicAnimation animation];
    headAnimation.keyPath = @"strokeStart";
    headAnimation.duration = duration / 2;
    headAnimation.fromValue = @(0.f);
    headAnimation.toValue = @(0.3f);
    headAnimation.timingFunction = self.timingFunction;
    
    CABasicAnimation *tailAnimation = [CABasicAnimation animation];
    tailAnimation.keyPath = @"strokeEnd";
    tailAnimation.duration = duration / 2;
    tailAnimation.fromValue = @(0.f);
    tailAnimation.toValue = @(1.0f);
    tailAnimation.timingFunction = timingFunction;
    
    CABasicAnimation *endHeadAnimation = [CABasicAnimation animation];
    endHeadAnimation.keyPath = @"strokeStart";
    endHeadAnimation.beginTime = duration - headAnimation.duration;
    endHeadAnimation.duration = duration / 2;
    endHeadAnimation.fromValue = headAnimation.toValue;
    endHeadAnimation.toValue = @(1.0f);
    endHeadAnimation.timingFunction = self.timingFunction;
    
    CABasicAnimation *endTailAnimation = [CABasicAnimation animation];
    endTailAnimation.keyPath = @"strokeEnd";
    endTailAnimation.beginTime = duration - tailAnimation.duration;
    endTailAnimation.duration = duration / 2;
    endTailAnimation.fromValue = tailAnimation.toValue;
    endTailAnimation.toValue = @(1.0f);
    endTailAnimation.timingFunction = self.timingFunction;
    
    CAAnimationGroup *animations = [CAAnimationGroup animation];
    [animations setDuration:duration];
    [animations setAnimations:@[headAnimation, tailAnimation, endHeadAnimation, endTailAnimation]];
    animations.repeatCount = INFINITY;
    animations.removedOnCompletion = NO;
    animations.fillMode = kCAFillModeForwards;
    [_loading addAnimation:animations forKey:kMMRingStrokeAnimationKey];
}

- (void)stop {
    if(_loading.animationKeys) {
        [_loading removeAnimationForKey:kMMRingStrokeAnimationKey];
    }
    if(self.superlayer) {
        [self removeFromSuperlayer];
    }
}




@end
