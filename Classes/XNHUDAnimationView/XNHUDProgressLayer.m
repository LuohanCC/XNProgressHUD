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
    layer.font = (__bridge CFTypeRef _Nullable)(@"AvenirNextCondensed-Medium");
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
    [self addSublayer:_circular];
    [self addSublayer:_progressLayer];
    [self addSublayer:_textLayer];
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    _textLayer.string = [NSString stringWithFormat:@"%.f%%", progress * 100];
    _progressLayer.strokeEnd = progress;
}

- (void)drawInContext:(CGContextRef)ctx {
    [super drawInContext:ctx];
    UIGraphicsPushContext(ctx);

    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    float fontHeight = self.bounds.size.height * 0.5;
    _textLayer.frame = CGRectMake(0, (self.bounds.size.height-fontHeight)/2, self.bounds.size.width, fontHeight);
    _textLayer.foregroundColor = xn_strokeColor;
    _textLayer.fontSize = self.bounds.size.width * 0.4f;
    
    float radius = self.bounds.size.width/2.0, from = -M_PI_2, to = -M_PI_2 + M_PI * 2.f;
    UIBezierPath *circularPath = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:from endAngle:to clockwise:true];
    _circular.fillColor = _progressLayer.fillColor = [UIColor clearColor].CGColor;
    _circular.path = _progressLayer.path = circularPath.CGPath;
    _circular.bounds = _progressLayer.bounds =  circularPath.bounds;
    _circular.position = _progressLayer.position = center;
    _circular.lineWidth = _progressLayer.lineWidth = xn_lineWidth;
    _circular.strokeColor = [[UIColor blackColor] colorWithAlphaComponent:0.3].CGColor;
    _progressLayer.strokeColor = xn_strokeColor;
    
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
