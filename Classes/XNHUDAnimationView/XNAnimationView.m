//
//  XNAnimationView.m
//  XNProgressHUD
//
//  Created by jarvis on 2019/7/20.
//  Copyright © 2019 罗函. All rights reserved.
//

#import "XNAnimationView.h"
#import "XNHUDLoadingLayer.h"
#import "XNHUDErrorLayer.h"
#import "XNHUDSuccessLayer.h"
#import "XNHUDProgressLayer.h"
#import "XNHUDInfoLayer.h"

@interface XNAnimationView()
@property (nonatomic, assign) BOOL isFirst;
@property (nonatomic, assign, getter=isAnimating) BOOL animating;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSMutableArray *pointLayers;
@end

@implementation XNAnimationView

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

- (void)initialize {
    _duration = 2.0f;
    _lineWidth = 2.f;
    _tintColor = [UIColor colorWithRed:237/255.f green:36/255.f blue:95/255.f alpha:1.f];
    _tintBGColor = [_tintColor colorWithAlphaComponent:0.2];
    _timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    _loadingLayer = [XNHUDLoadingLayer new];
    _progressLayer = [XNHUDProgressLayer new];
    _infoLayer = [XNHUDInfoLayer new];
    _successLayer = [XNHUDSuccessLayer new];
    _errorLayer = [XNHUDErrorLayer new];
    
    _pointLayers = [[NSMutableArray alloc] initWithObjects:\
                    _loadingLayer, _progressLayer, _infoLayer, _errorLayer, _successLayer, nil];
    [self setBackgroundColor:[UIColor clearColor]];
    [self invalidateIntrinsicContentSize];
}

@synthesize tintColor = _tintColor;
- (UIColor *)tintColor {
    if(_tintColor)
        return _tintColor;
    else
        return [UIColor grayColor];
}

- (UIImageView *)imageView {
    if(!_imageView) {
        _imageView = [UIImageView new];
        _imageView.contentMode = UIViewContentModeCenter;
        _imageView.image = self.infoImage;
    }
    return _imageView;
}


@synthesize loadingLayer = _loadingLayer;
- (void)setLoadingLayer:(CALayer<XNHUDLayerProtocol> *)loadingLayer {
    if (!loadingLayer) {
        loadingLayer = [XNHUDLoadingLayer new];
    }
    if (_loadingLayer) {
        if ([_pointLayers containsObject:_loadingLayer]) {
            HUDWeakSelf;
            [_pointLayers enumerateObjectsUsingBlock:^(CALayer<XNHUDLayerProtocol>* obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj == weakSelf.loadingLayer) {
                    [obj stop];
                    [weakSelf.pointLayers replaceObjectAtIndex:idx withObject:loadingLayer];
                }
            }];
        }
    }
    _loadingLayer = loadingLayer;
    [self invalidateIntrinsicContentSize];
}

- (BOOL)isEmptyImages {
    return !_infoImage && !_errorImage && !_successImage;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if (!_pointLayers) return;
    HUDWeakSelf;
    [_pointLayers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CALayer<XNHUDLayerProtocol> *layer = (CALayer<XNHUDLayerProtocol> *)obj;
        layer.targetLayer = weakSelf.layer;
        layer.xn_strokeColor =  weakSelf.tintColor.CGColor;
        layer.xn_lineWidth = weakSelf.lineWidth;
        layer.timingFunction = weakSelf.timingFunction;
        layer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    }];
    self.imageView.frame = self.bounds;
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    self.progressLayer.progress = progress;
}

- (void)setStyle:(XNAnimationViewStyle)style {
    if (style > XNAnimationViewStyleNone) {
        [_pointLayers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CALayer<XNHUDLayerProtocol> *layer = (CALayer<XNHUDLayerProtocol> *)obj;
            if (idx != style) {
                [layer stop];
            }
        }];
    }
    if(_style != style) {
        [self removeImageView];
    }
    _style = style;
}

- (void)showImageView {
    if (!self.imageView.superview) {
        [self addSubview:_imageView];
    }
}

- (void)removeImageView {
    if (self.imageView.superview) {
        [_imageView removeFromSuperview];
    }
}

- (BOOL)showImageViewByStyle {
    UIImage *image = nil;
    if (_style > XNAnimationViewStyleProgress) {
        switch (_style) {
            case XNAnimationViewStyleInfoImage:
                image = _infoImage;
                break;
            case XNAnimationViewStyleError:
                image = _errorImage;
                break;
            case XNAnimationViewStyleSuccess:
                image = _successImage;
                break;
            default:
                break;
        }
    }
    if (image) {
        self.imageView.image = image;
        [self showImageView];
        return true;
    }
    return false;
}

- (void)showImageViewByImage:(UIImage *)image {
    self.imageView.image = image;
}

#pragma mark - XNAnimaionViewProtocol
- (NSNumber *)xn_getStyle {
    return [NSNumber numberWithUnsignedInteger:_style];
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
    if (_style == XNAnimationViewStyleNone) return;
    _animating = YES;
    if (![self showImageViewByStyle]) {
        CALayer<XNHUDLayerProtocol> *layer = _pointLayers[_style];
        [layer prepare];
        [layer play];
    }
}

- (void)xn_stopAnimation {
    if (_style == XNAnimationViewStyleNone) return;
    _animating = NO;
    CALayer<XNHUDLayerProtocol> *layer = _pointLayers[_style];
    [layer stop];
    [self removeImageView];
}

@end
