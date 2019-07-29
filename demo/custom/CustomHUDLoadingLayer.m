//
//  CustomHUDLoadingLayer.m
//  XNProgressHUD
//
//  Created by jarvis on 2019/7/20.
//  Copyright © 2019 罗函. All rights reserved.
//

#import "CustomHUDLoadingLayer.h"

static NSString *kMMRingStrokeAnimationKey = @"materialdesignspinner.stroke";

@interface CustomHUDLoadingLayer()
@property (nonatomic, strong) CAShapeLayer *loading;
@property (nonatomic, strong) CAShapeLayer *loadingBG;
@end

@implementation CustomHUDLoadingLayer
@synthesize timingFunction;
@synthesize targetLayer;
@synthesize animationDuration;
@synthesize lineCap;
@synthesize xn_lineWidth;
@synthesize xn_strokeColor;

- (instancetype)init {
    if (!(self = [super init])) return nil;
    _loadingBG = [CAShapeLayer layer];
    [self addSublayer:_loadingBG];
    _loading = [CAShapeLayer layer];
    [self addSublayer:_loading];
    return self;
}

- (void)setCustomPath:(CAShapeLayer *)layer {
    float w = self.bounds.size.width * 1.2;
    float h = w * 0.65;
    
    UIBezierPath *bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(w, 0)];
    [bezier2Path addLineToPoint: CGPointMake(1, h)];
    [bezier2Path addLineToPoint: CGPointMake(1, h - h)];
    [bezier2Path addLineToPoint: CGPointMake(w, h)];
    [bezier2Path addLineToPoint: CGPointMake(w, 0)];
    [bezier2Path closePath];
    [[UIColor clearColor] setStroke];
    [[UIColor clearColor] setFill];
    [bezier2Path stroke];
    
    layer.path = bezier2Path.CGPath;
    layer.bounds = bezier2Path.bounds;
    CGPathRef strokingPath = CGPathCreateCopyByStrokingPath(layer.path, nil, 4, kCGLineCapSquare,kCGLineJoinRound, 4);
    layer.bounds = CGPathGetPathBoundingBox(strokingPath);
    layer.fillColor = [UIColor clearColor].CGColor;
}

- (void)drawInContext:(CGContextRef)ctx {
    [super drawInContext:ctx];
    UIGraphicsPushContext(ctx);
    
    [self setCustomPath:_loading];
    [self setCustomPath:_loadingBG];
    
    _loading.lineCap = kCALineCapRound;
    _loading.lineJoin = kCALineJoinBevel;
    _loading.strokeColor = xn_strokeColor;
    _loading.lineWidth = xn_lineWidth;
    _loading.position = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
    _loadingBG.strokeColor = [[UIColor colorWithCGColor:xn_strokeColor] colorWithAlphaComponent:0.2].CGColor;
    _loadingBG.lineWidth = xn_lineWidth;
    _loadingBG.position = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
    
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
    
    CABasicAnimation *headAnimation = [CABasicAnimation animation];
    headAnimation.keyPath = @"strokeStart";
    headAnimation.beginTime = duration / 4;
    headAnimation.duration = duration / 2;
    headAnimation.fromValue = @(0.f);
    headAnimation.toValue = @(1.0f);
    headAnimation.timingFunction = self.timingFunction;
    
    CABasicAnimation *endHeadAnimation = [CABasicAnimation animation];
    endHeadAnimation.keyPath = @"strokeStart";
    endHeadAnimation.beginTime = headAnimation.beginTime + headAnimation.duration;
    endHeadAnimation.duration = duration / 4;
    endHeadAnimation.fromValue = headAnimation.toValue;
    endHeadAnimation.toValue = @(1.0f);
    endHeadAnimation.timingFunction = self.timingFunction;
    
    CABasicAnimation *tailAnimation = [CABasicAnimation animation];
    tailAnimation.keyPath = @"strokeEnd";
    tailAnimation.duration = duration / 2;
    tailAnimation.fromValue = @(0.f);
    tailAnimation.toValue = @(1.0f);
    tailAnimation.timingFunction = self.timingFunction;
    
    CABasicAnimation *endTailAnimation = [CABasicAnimation animation];
    endTailAnimation.keyPath = @"strokeEnd";
    endTailAnimation.beginTime = tailAnimation.beginTime + tailAnimation.duration;
    endTailAnimation.duration = duration - tailAnimation.duration;
    endTailAnimation.fromValue = tailAnimation.toValue;
    endTailAnimation.toValue = @(1.0f);
    endTailAnimation.timingFunction = self.timingFunction;
    
    CAAnimationGroup *animations = [CAAnimationGroup animation];
    [animations setDuration:duration-0.3];
    [animations setAnimations:@[headAnimation, endHeadAnimation, tailAnimation, endTailAnimation]];
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
