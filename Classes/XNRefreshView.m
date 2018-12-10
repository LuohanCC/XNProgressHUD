//
//  XNRefreshView.m
//  XNTools
//
//  Created by 罗函 on 2018/2/8.
//

#import "XNRefreshView.h"
#define YHWaitingViewItemMargin 1

static NSString *kMMRingStrokeAnimationKey = @"materialdesignspinner.stroke";
static NSString *kMMRingRotationAnimationKey = @"materialdesignspinner.rotation";

@interface XNRefreshView()
@property (nonatomic, assign) BOOL isFirst;
@property (nonatomic, assign, getter=isAnimating) BOOL animating;
@property (nonatomic, strong) UIImageView *imageView;


@property (nonatomic, strong) CAShapeLayer *infoLayer;
@property (nonatomic, strong) CAShapeLayer *errorLayer01;
@property (nonatomic, strong) CAShapeLayer *errorLayer02;
@property (nonatomic, strong) CAShapeLayer *successLayer;
@end

@implementation XNRefreshView
@synthesize refreshShapeLayer = _refreshShapeLayer;

- (void)addSubviewIfNotContain:(UIView *)view superView:(UIView *)superView{
    if((view && superView) && (!view.superview || view.superview != superView)) {
        [superView addSubview:view];
    }
}

- (void)removeFromSuperview:(UIView *)view {
    if(view && view.superview) {
        [view removeFromSuperview];
        view = nil;
    }
}

- (void)removeLayerFromSuperLayer:(CALayer *)layer {
    if(layer && layer.superlayer) {
        [layer removeFromSuperlayer];
    }
}

- (instancetype)init {
    if(!(self = [super init])) return nil;
    [self initialize];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if(!(self = [super initWithFrame:frame])) return nil;
    [self initialize];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if(!(self = [super initWithCoder:aDecoder])) return nil;
    [self initialize];
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialize];
}

- (void)initialize {
    _percentComplete = 0.f;
    _duration = 1.3f;
    _lineWidth = 1.5f;
    _timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.layer addSublayer:self.refreshShapeLayer];
    [self.layer addSublayer:self.shapeLayer];
    [self setBackgroundColor:[UIColor clearColor]];
    //register notifications
    [self registerNotifications];
    
    [self invalidateIntrinsicContentSize];
}

@synthesize tintColor = _tintColor;
- (UIColor *)tintColor {
    if(_tintColor)
        return _tintColor;
    else
     return [UIColor grayColor];
}

- (void)setTintColor:(UIColor *)tintColor {
    _tintColor = tintColor;
    self.refreshShapeLayer.strokeColor = tintColor.CGColor;
}

- (void)setColor:(UIColor *)color {
    _tintColor = color;
    self.refreshShapeLayer.strokeColor = color.CGColor;
}

- (void)setLineWidth:(CGFloat)lineWidth {
    _refreshShapeLayer.lineWidth = _lineWidth = lineWidth;
    [self updateRefreshLayer];
}

- (void)setLineCap:(NSString *)lineCap {
    _refreshShapeLayer.lineCap = _lineCap = lineCap;
    [self updateRefreshLayer];
}


- (void)removeRefreshShapeLayer {
    if(_refreshShapeLayer && _refreshShapeLayer.superlayer) {
        [_refreshShapeLayer removeFromSuperlayer];
    }
    _refreshShapeLayer = nil;
}

- (UILabel *)label {
    if(!_label) {
        _label = [[UILabel alloc] init];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.numberOfLines = 1;
        _label.textColor = self.tintColor;
        _label.text = @"0%";
    }
    return _label;
}

- (void)setLabelFont {
    CGFloat fontSize = self.frame.size.width / 3.65;
    if(fontSize < 8.f) fontSize = 8.f;
    self.label.font = [UIFont fontWithName:@"HelveticaNeue" size:fontSize];//AvenirNext-UltraLight
}

- (UIImageView *)imageView {
    if(!_imageView) {
        _imageView = [UIImageView new];
        _imageView.contentMode = UIViewContentModeCenter;
        _imageView.image = self.infoImage;
    }
    return _imageView;
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xn_startAnimation) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xn_stopAnimation) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)removeNotifiations {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    [self removeNotifiations];
}

- (void)setPercentComplete:(CGFloat)percentComplete {
    if(_animating) {
        _percentComplete = percentComplete;
        _refreshShapeLayer.strokeStart = 0.f;
        _refreshShapeLayer.strokeEnd = percentComplete;
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self layoutSubviews];
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    self.label.text = [NSString stringWithFormat:@"%.f%%", progress * 100];
    NSLog(@"%@", self.label.text);
    [self setNeedsDisplay];
}

- (CGFloat)scaleLineWith {
    CGFloat lineWidth = self.bounds.size.width / 26.f;
    if(lineWidth < 1.f) lineWidth = 1.f;
    return lineWidth;
}

- (CAShapeLayer *)createCAShapeLayer{
    CGFloat lineWidth = self.bounds.size.width / 26.f;
    if(lineWidth < 1.f) lineWidth = 1.f;
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.lineWidth = lineWidth;
    layer.strokeColor = self.tintColor.CGColor;
    layer.lineCap = kCALineCapRound;
    layer.fillColor = nil;
    return layer;
}

#pragma mark - refreshView
- (CAShapeLayer *)refreshShapeLayer {
    if(!_refreshShapeLayer) {
        _refreshShapeLayer = [CAShapeLayer layer];
        _refreshShapeLayer.frame = self.bounds;
        _refreshShapeLayer.lineWidth = _lineWidth;
        _refreshShapeLayer.strokeColor = self.tintColor.CGColor;
        _refreshShapeLayer.fillColor = nil;
        _refreshShapeLayer.lineCap = kCALineCapRound;
        _refreshShapeLayer.contentsScale = [UIScreen mainScreen].scale;
    }
    return _refreshShapeLayer;
}

- (void)updateRefreshLayer {
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat radius = MIN(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2) - _refreshShapeLayer.lineWidth / 2;
    CGFloat startAngle = 0.f;
    CGFloat endAngle = M_PI * 2.f;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    _refreshShapeLayer.path = path.CGPath;
    _refreshShapeLayer.strokeStart = 0.f;
    _refreshShapeLayer.strokeEnd = self.percentComplete;
    _refreshShapeLayer.frame = self.bounds;
}

- (void)startLoadingAnimation {
    [self stopLoadingAnimation];
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"transform.rotation";
    animation.duration = self.duration / 0.5;
    animation.fromValue = @(0.f);
    animation.toValue = @(2 * M_PI);
    animation.repeatCount = INFINITY;
    animation.removedOnCompletion = NO;
    [self.refreshShapeLayer addAnimation:animation forKey:kMMRingRotationAnimationKey];
    
    CABasicAnimation *headAnimation = [CABasicAnimation animation];
    headAnimation.keyPath = @"strokeStart";
    headAnimation.duration = self.duration / 2;
    headAnimation.fromValue = @(0.f);
    headAnimation.toValue = @(0.3f);
    headAnimation.timingFunction = self.timingFunction;
    
    CABasicAnimation *tailAnimation = [CABasicAnimation animation];
    tailAnimation.keyPath = @"strokeEnd";
    tailAnimation.duration = self.duration / 2;
    tailAnimation.fromValue = @(0.f);
    tailAnimation.toValue = @(1.0f);
    tailAnimation.timingFunction = self.timingFunction;
    
    CABasicAnimation *endHeadAnimation = [CABasicAnimation animation];
    endHeadAnimation.keyPath = @"strokeStart";
    endHeadAnimation.beginTime = self.duration - headAnimation.duration;
    endHeadAnimation.duration = self.duration / 2;
    endHeadAnimation.fromValue = headAnimation.toValue;
    endHeadAnimation.toValue = @(1.0f);
    endHeadAnimation.timingFunction = self.timingFunction;
    
    CABasicAnimation *endTailAnimation = [CABasicAnimation animation];
    endTailAnimation.keyPath = @"strokeEnd";
    endTailAnimation.beginTime = self.duration - tailAnimation.duration;
    endTailAnimation.duration = self.duration / 2;
    endTailAnimation.fromValue = tailAnimation.toValue;
    endTailAnimation.toValue = @(1.0f);
    endTailAnimation.timingFunction = self.timingFunction;
    
    CAAnimationGroup *animations = [CAAnimationGroup animation];
    [animations setDuration:self.duration];
    [animations setAnimations:@[headAnimation, tailAnimation, endHeadAnimation, endTailAnimation]];
    animations.repeatCount = INFINITY;
    animations.removedOnCompletion = NO;
    animations.fillMode = kCAFillModeForwards;
    [self.refreshShapeLayer addAnimation:animations forKey:kMMRingStrokeAnimationKey];
    
}

- (void)stopLoadingAnimation {
    if(self.refreshShapeLayer.animationKeys) {
        [self.refreshShapeLayer removeAnimationForKey:kMMRingRotationAnimationKey];
        [self.refreshShapeLayer removeAnimationForKey:kMMRingStrokeAnimationKey];
    }
}

#pragma mark - errorView
- (CAShapeLayer *)errorLayer01 {
    if(!_errorLayer01) {
        _errorLayer01 = [self createCAShapeLayer];
        [self updateErrorLayer:_errorLayer01];
    }
    return _errorLayer01;
}

- (CAShapeLayer *)errorLayer02 {
    if(!_errorLayer02) {
        _errorLayer02 = [self createCAShapeLayer];
        [self updateErrorLayer:_errorLayer02];
    }
    return _errorLayer02;
}

- (UIBezierPath *)errorPath {
    CGFloat width = self.bounds.size.width * 0.55;
    UIBezierPath* path = [UIBezierPath bezierPath];
    [path moveToPoint: CGPointMake(0, self.bounds.size.height/2)];
    [path addLineToPoint: CGPointMake(width, self.bounds.size.height/2)];
    return path;
}

- (void)addErrorLayer {
    [self removeLayerFromSuperLayer:_errorLayer01];
    [self removeLayerFromSuperLayer:_errorLayer02];
    _errorLayer01 = nil;
    _errorLayer02 = nil;
    [self.layer addSublayer:self.errorLayer01];
    [self.layer addSublayer:self.errorLayer02];
}

- (void)updateErrorLayer:(CAShapeLayer *)layer {
    UIBezierPath *errorPath = [self errorPath];
    layer.path = errorPath.CGPath;
    layer.bounds = errorPath.bounds;
    layer.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}

- (void)removeErrorLayer {
    if(_errorLayer01 && _errorLayer01.superlayer) {
        [_errorLayer01 removeFromSuperlayer];
        [_errorLayer02 removeFromSuperlayer];
        [_errorLayer01 removeAllAnimations];
        [_errorLayer02 removeAllAnimations];
    }
}

- (void)addAnimationAtTBLayer:(CAShapeLayer *)layer transform:(CATransform3D)transform{
    NSTimeInterval transformDuration = self.duration * 0.25;
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

- (void)startErrorAnimation {
    [self stopErrorAnimation];
    //叉叉动画
    CATransform3D translation = CATransform3DMakeTranslation(0, 0, 0);
    CATransform3D topTransfrom = CATransform3DRotate(translation, -M_PI_4, 0, 0, 1);
    CATransform3D bottomTransfrom = CATransform3DRotate(translation, M_PI_4, 0, 0, 1);
    [self addAnimationAtTBLayer:self.errorLayer01 transform:topTransfrom];
    [self addAnimationAtTBLayer:self.errorLayer02 transform:bottomTransfrom];
}

- (void)stopErrorAnimation {
    if(self.errorLayer01.animationKeys) {
        [self.errorLayer01 removeAllAnimations];
    }
    if(self.errorLayer02.animationKeys) {
        [self.errorLayer02 removeAllAnimations];
    }
}

#pragma  mark - successView
- (CAShapeLayer *)successLayer {
    if(!_successLayer) {
        _successLayer = [self createCAShapeLayer];
        [self updateSuccessLayer];
    }
    return _successLayer;
}

- (UIBezierPath *)successPath {
    CGFloat width = self.bounds.size.width;
    UIBezierPath* path = [UIBezierPath bezierPath];
    [path moveToPoint: CGPointMake(width / 4.8, width / 1.9)];
    [path addLineToPoint: CGPointMake(width / 2.39, width / 1.4)];
    [path addLineToPoint: CGPointMake(width / 1.3, width / 3.55)];
    return path;
}

- (void)updateSuccessLayer {
    UIBezierPath* path = [self successPath];
    self.successLayer.path = path.CGPath;
    CGPathRef strokingPath = CGPathCreateCopyByStrokingPath(_successLayer.path, nil, _successLayer.lineWidth, kCGLineCapRound, kCGLineJoinMiter, 0);
    self.successLayer.bounds = CGPathGetPathBoundingBox(strokingPath);
    self.successLayer.actions = @{@"strokeStart":[NSNull null], @"strokeEnd":[NSNull null], @"transform":[NSNull null]};
    self.successLayer.strokeStart = 0.f;
    self.successLayer.strokeEnd = 0.9f;
    self.successLayer.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}

- (void)addSuccessLayer {
    [self removeLayerFromSuperLayer:_successLayer];
    _successLayer = nil;
    [self.layer addSublayer:self.successLayer];
}

- (void)removeSuccessLayer {
    if(_successLayer && _successLayer.superlayer) {
        [_successLayer removeFromSuperlayer];
    }
    _successLayer = nil;
}

- (void)startSuccessAnimation {
    [self stopSuccessAnimation];
    //对勾动画
    CABasicAnimation *arc = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    arc.fromValue = @(0.0);
    arc.toValue = @(1.0);
    arc.duration = 0.4;
    arc.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    arc.removedOnCompletion = NO;
    arc.fillMode = kCAFillModeForwards;
    [self.successLayer addAnimation:arc forKey:arc.keyPath];
}

- (void)stopSuccessAnimation {
    if(self.successLayer.animationKeys) {
        [self.successLayer removeAllAnimations];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self invalidateIntrinsicContentSize];
    if(_imageView) {
        _imageView.frame = self.bounds;
    }
    if(_label) {
        _label.frame = CGRectMake(0, (self.bounds.size.height-16)/2, self.bounds.size.width, 16);
        [self setLabelFont];
    }
    switch (_style) {
        case XNRefreshViewStyleLoading:
            [self updateRefreshLayer];
            break;
        case XNRefreshViewStyleProgress:
            break;
        case XNRefreshViewStyleInfoImage:
            if(!_infoImage) {  }
            break;
        case XNRefreshViewStyleError:
            if(!_errorImage) {
                [self updateErrorLayer:self.errorLayer01];
                [self updateErrorLayer:self.errorLayer02];
            }
            break;
        case XNRefreshViewStyleSuccess:
            if(!_successImage) {
                [self updateSuccessLayer];
            }
            break;
            
        default:
            break;
    }
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    //progress Display
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat xCenter = rect.size.width * 0.5;
    CGFloat yCenter = rect.size.height * 0.5;
    CGContextSetLineWidth(ctx, _lineWidth);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGFloat radius = MIN(rect.size.width-_lineWidth, rect.size.height-_lineWidth) * 0.5 - 0;
    CGFloat from = -M_PI_2;
    
    switch (_style) {
        case XNRefreshViewStyleProgress: {
            //底圆
            [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2] setStroke];
            CGContextAddArc(ctx, xCenter, yCenter, radius, from, from + M_PI*2.0, 0);
            CGContextStrokePath(ctx);
            //弧圆
            CGFloat to = from + M_PI*2.0*self.progress;//将进度转换成弧度
            [self.tintColor setStroke];
            CGContextAddArc(ctx, xCenter, yCenter, radius, from, to, 0);
            CGContextStrokePath(ctx);
        }
            break;
        case XNRefreshViewStyleInfoImage:{
            if(_infoImage) return;
            CGFloat lineWidth = [self scaleLineWith];
            CGFloat height = self.bounds.size.height;
            CGContextAddArc(ctx, xCenter, height*0.25, lineWidth*1.5, from, from + M_PI*2.0, 0);
            [self.tintColor setFill];
            CGContextFillPath(ctx);
            
            CGContextMoveToPoint(ctx, xCenter, height*0.25 + lineWidth*5);
            CGContextAddLineToPoint(ctx, xCenter, height*0.8);
            [self.tintColor setStroke];
            CGContextStrokePath(ctx);
        }
        case XNRefreshViewStyleError:
            if(_errorImage) return;
        case XNRefreshViewStyleSuccess:{
            if(_successImage) return;
            CGContextSetLineWidth(ctx, [self scaleLineWith]);
            //底圆
            [self.tintColor setStroke];
            CGContextAddArc(ctx, xCenter, yCenter, radius, from, from + M_PI*2.0, 0);
            CGContextStrokePath(ctx);
        }
            break;
        default:
            break;
    }
}

- (void)setStyle:(XNRefreshViewStyle)style {
    UIImage *image = nil;
    switch (style) {
        case XNRefreshViewStyleLoading:{
            [self removeErrorLayer];//layer
            [self removeSuccessLayer];
            [self removeFromSuperview:_label];//view
            [self removeFromSuperview:_imageView];
            //add sublayer
            if(!self.refreshShapeLayer.superlayer) {
                [self.layer addSublayer:self.refreshShapeLayer];
            }
        }
            break;
        case XNRefreshViewStyleProgress:{
            [self removeRefreshShapeLayer];//layer
            [self removeErrorLayer];
            [self removeSuccessLayer];
            [self removeFromSuperview:_imageView];//view
            //add subview
            if(!self.label.superview) {
                [self addSubview:self.label];
            }
            //drawRect
        }
            break;
        case XNRefreshViewStyleInfoImage: {
            [self removeFromSuperview:_imageView];
            [self removeRefreshShapeLayer];//layer
            [self removeErrorLayer];
            [self removeSuccessLayer];
            [self removeFromSuperview:_label];//view
            [self removeFromSuperview:_imageView];
            if(_infoImage) {
                image = self.infoImage;//add subview
            }else{
                //drawRect
            }
        }
            break;
        case XNRefreshViewStyleError: {
            [self removeFromSuperview:_imageView];
            [self removeRefreshShapeLayer];//layer
            [self removeSuccessLayer];
            [self removeFromSuperview:_label];//view
            [self removeFromSuperview:_imageView];
            if(_errorImage) {
                image = self.errorImage;
            }else{
                [self addErrorLayer];//add errorLayer
            }
        }
            break;
        case XNRefreshViewStyleSuccess:{
            [self removeRefreshShapeLayer];//layer
            [self removeErrorLayer];
            [self removeFromSuperview:_label];//view
            [self removeFromSuperview:_imageView];
            if(_successImage) {
                image = self.successImage;
            }else{
                [self addSuccessLayer];//drawRect
            }
        }
            break;
        default:
            break;
    }
    
    if(image && !self.imageView.superview) {
        self.imageView.image = image;
        [self addSubview:self.imageView];
    }
    _style = style;
}

#pragma mark - XNRefreshViewProtocol
- (NSNumber *)xn_getStyle {
    return [NSNumber numberWithUnsignedInteger:_style];;
}

- (void)xn_setStyle:(NSNumber *)styleValue {
    if (styleValue) {
        self.style = styleValue.unsignedIntegerValue;
    }
}

- (void)xn_setProgress:(NSNumber *)progressValue {
    if (progressValue) {
        self.progress = progressValue.floatValue;
    }
}

- (NSNumber *)xn_isAnimating {
    return [NSNumber numberWithUnsignedInteger:_animating];;
}

- (void)xn_startAnimation {
    _animating = YES;
    [self setNeedsDisplay];
    switch (_style) {
        case XNRefreshViewStyleLoading:{
            [self startLoadingAnimation];
        }
            break;
        case XNRefreshViewStyleProgress:{
        }
            break;
        case XNRefreshViewStyleInfoImage:{
            if(! _infoImage) {
            }
        }
            break;
        case XNRefreshViewStyleError:{
            if(! _errorImage) {
                [self startErrorAnimation];
            }
        }
            break;
        case XNRefreshViewStyleSuccess:{
            if(! _successImage) {
                [self startSuccessAnimation];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)xn_stopAnimation {
    _animating = NO;
    switch (_style) {
        case XNRefreshViewStyleLoading:{
            [self stopLoadingAnimation];
        }
            break;
        case XNRefreshViewStyleProgress:{
            [self setNeedsDisplay];
        }
            break;
        case XNRefreshViewStyleInfoImage:{
            if(! _infoImage) {
                [self setNeedsDisplay];
            }
        }
            break;
        case XNRefreshViewStyleError:{
            if(! _errorImage) {
                [self stopErrorAnimation];
            }
        }
            break;
        case XNRefreshViewStyleSuccess:{
            if(! _successImage) {
                [self stopSuccessAnimation];
            }
        }
            break;
            
        default:
            break;
    }
}

@end
