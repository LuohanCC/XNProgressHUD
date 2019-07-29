//
//  XNHUDInfoLayer.m
//  XNProgressHUD
//
//  Created by jarvis on 2019/7/22.
//  Copyright © 2019 罗函. All rights reserved.
//

#import "XNHUDInfoLayer.h"

@interface XNHUDInfoLayer();
@property (nonatomic, strong) CAShapeLayer *info01;
@property (nonatomic, strong) CAShapeLayer *info02;
@property (nonatomic, strong) CAShapeLayer *circular;
@end


@implementation XNHUDInfoLayer
@synthesize timingFunction;
@synthesize targetLayer;
@synthesize animationDuration;
@synthesize xn_lineWidth;
@synthesize xn_strokeColor;
@synthesize lineCap;

- (instancetype)init {
    if (!(self = [super init])) return nil;
    _circular = [CAShapeLayer layer];
    _info01 = [CAShapeLayer layer];
    _info02 = [CAShapeLayer layer];
    [self addSublayer:_circular];
    [self addSublayer:_info01];
    [self addSublayer:_info02];
    return self;
}

- (void)drawInContext:(CGContextRef)ctx {
    [super drawInContext:ctx];
    UIGraphicsPushContext(ctx);
    
    CGRect frame = self.bounds;
    CGPoint center = CGPointMake(frame.size.width/2, frame.size.height/2);
    float radius = frame.size.width/2.0, start = 0.f, end = M_PI * 2;
    UIBezierPath *circularPath = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:start endAngle:end clockwise:true];
    _circular.path = circularPath.CGPath;
    _circular.bounds = circularPath.bounds;
    _circular.position = center;
    _circular.fillColor = [UIColor clearColor].CGColor;
    _circular.lineWidth = xn_lineWidth;
    _circular.strokeColor = xn_strokeColor;
    
    // Oval 椭圆形 2 Drawing
    float diameter = xn_lineWidth * 1.8;
    float top = frame.size.height * 0.23;
    float ovalX = (frame.size.width - diameter)/2;
    UIBezierPath* oval2Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(ovalX, top, diameter, diameter)];
    [[UIColor clearColor] setStroke];
    [[UIColor clearColor] setFill];
    [oval2Path stroke];
    _info01.path = oval2Path.CGPath;
    _info01.bounds = oval2Path.bounds;
    _info01.position = CGPointMake(center.x, top);
    _info01.fillColor = xn_strokeColor;
    
    top += xn_lineWidth * 1.1;
    // Bezier 路径 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(center.x, top)];
    [bezier2Path addLineToPoint: CGPointMake(center.x, frame.size.height-top)];
    bezier2Path.lineWidth = 1;
    bezier2Path.miterLimit = 1;
    [bezier2Path stroke];
    _info02.path = bezier2Path.CGPath;
    _info02.bounds = bezier2Path.bounds;
    _info02.position = CGPointMake(center.x, top+(frame.size.height-top)/2);
    _info02.strokeColor = xn_strokeColor;
    _info02.lineWidth = xn_lineWidth;
    _info02.lineCap = kCALineCapRound;
    
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
    [self removeAllAnimations];
    if (!self.superlayer) {
        [self.targetLayer addSublayer:self];
    }
}

- (void)stop {
    if(_circular.animationKeys) {
        [_circular removeAllAnimations];
    }
    if(self.superlayer) {
        [self removeFromSuperlayer];
    }
}

@end
