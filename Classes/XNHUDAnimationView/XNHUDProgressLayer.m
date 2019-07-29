//
//  XNHUDProgressLayer.m
//  XNProgressHUD
//
//  Created by jarvis on 2019/7/20.
//  Copyright © 2019 罗函. All rights reserved.
//

#import "XNHUDProgressLayer.h"

@interface XNHUDProgressLayer()
@property (nonatomic, strong) CAShapeLayer *circular;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) CATextLayer *textLayer;
@end


@implementation XNHUDProgressLayer
@synthesize animationDuration;
@synthesize lineCap;
@synthesize targetLayer;
@synthesize timingFunction;
@synthesize xn_lineWidth;
@synthesize xn_strokeColor;

- (CATextLayer *)createTextLayer {
    CATextLayer *layer =  [CATextLayer layer];
    layer.alignmentMode = kCAAlignmentCenter;
    layer.font = (__bridge CFTypeRef _Nullable)(@"Cochin");
    layer.fontSize = 11.f;
    layer.backgroundColor = [UIColor clearColor].CGColor;
    layer.contentsScale = 2;
    return layer;
}

- (instancetype)init {
    if (!(self = [super init])) return nil;
    _circular = [CAShapeLayer layer];
    _progressLayer = [CAShapeLayer layer];
    _textLayer = [self createTextLayer];
    [self addSublayer:_progressLayer];
    [self addSublayer:_textLayer];
    return self;
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    _textLayer.string = [NSString stringWithFormat:@"%.f%%", progress * 100];
    [self setNeedsDisplay];
}

- (void)drawInContext:(CGContextRef)ctx {
    [super drawInContext:ctx];
    UIGraphicsPushContext(ctx);

    float fontHeight = self.bounds.size.height * 0.5;
    _textLayer.frame = CGRectMake(0, (self.bounds.size.height-fontHeight)/2, self.bounds.size.width, fontHeight);
    _textLayer.foregroundColor = xn_strokeColor;
    _textLayer.fontSize = self.bounds.size.width * 0.4231f;
    
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    float radius = self.bounds.size.width/2.0, from = 0.f, to = M_PI * 2;
    UIBezierPath *circularPath = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:from endAngle:to clockwise:true];
    _circular.path = circularPath.CGPath;
    _circular.bounds = circularPath.bounds;
    _circular.position = center;
    _circular.fillColor = [UIColor clearColor].CGColor;
    
    radius = self.frame.size.width/2.0;
    from = -M_PI_2;
    to = from + _progress * (M_PI * 2);
    UIBezierPath *path2 = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:from endAngle:to clockwise:true];
    _progressLayer.path = path2.CGPath;
    _progressLayer.path = path2.CGPath;
    _progressLayer.bounds = path2.bounds;
    _progressLayer.position = center;
    _progressLayer.fillColor = [UIColor clearColor].CGColor;
    _progressLayer.lineWidth = _circular.lineWidth = xn_lineWidth;
    _progressLayer.strokeColor = _circular.strokeColor = xn_strokeColor;
    
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
    if(_progressLayer.animationKeys) {
        [_progressLayer removeAllAnimations];
        [_circular removeAllAnimations];
    }
    if(self.superlayer) {
        [self removeFromSuperlayer];
    }
}

@end
