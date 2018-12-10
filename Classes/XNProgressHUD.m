//
//  XNProgressHUD.m
//  XNTools
//
//  Created by 罗函 on 2018/2/8.
//

#import "XNProgressHUD.h"
#import "XNRefreshView.h"

@interface XNProgressHUD() {
    UIView *_refreshView;
}
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *shadeContentView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) NSTimer *displayTimer;
@property (nonatomic, strong) NSTimer *dismissTimer;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) HUDPadding padding;
@property (nonatomic, assign) NSTimeInterval disposableDelayResponse; //延时相应
@property (nonatomic, assign) NSTimeInterval disposableDelayDismiss; //延时消失时间
@end

@implementation XNProgressHUD

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


- (void)stopTimerAndSetItNil:(NSTimer *)timer {
    if(timer) {
        [timer invalidate];
        timer = nil;
    }
}

- (UIColor *)createColorWithRGBA:(uint32_t)rgbaValue {
    return [UIColor colorWithRed:((rgbaValue & 0xFF000000) >> 24) / 255.0f
                           green:((rgbaValue & 0xFF0000) >> 16) / 255.0f
                            blue:((rgbaValue & 0xFF00) >> 8) / 255.0f
                           alpha:(rgbaValue & 0xFF) / 255.0f];
}

- (uint32_t)rgbaValueWithUIColor:(UIColor *)color {
    CGFloat r = 0, g = 0, b = 0, a = 0;
    [color getRed:&r green:&g blue:&b alpha:&a];
    int8_t red = r * 255;
    uint8_t green = g * 255;
    uint8_t blue = b * 255;
    uint8_t alpha = a * 255;
    return (red << 24) + (green << 16) + (blue << 8) + alpha;
}

+ (instancetype)shared {
    static XNProgressHUD *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[XNProgressHUD alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if(!(self = [super init])) return nil;
    [self initialize];
    return self;
}

- (UIView *)maskView {
    if(!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HUDScreenSize.width, HUDScreenSize.height)];
        _maskView.userInteractionEnabled = YES;
        // 为MaskView添加点击事件
        if(_hudDismissBlock) {
            [self addMaskTapGestureEvent];
        }
    }
    return _maskView;
}

- (UIColor *)maskColorWithMaskType:(XNProgressHUDMaskType)maskType {
    unsigned int hexColor;
    switch (maskType) {
        case XNProgressHUDMaskTypeClear:
            hexColor = _maskColor.clear;
            break;
        case XNProgressHUDMaskTypeBlack:
            hexColor = _maskColor.black;
            break;
        case XNProgressHUDMaskTypeCustom:
            hexColor = _maskColor.custom;
            break;
        default:
            hexColor = 0x00000000;
            break;
    }
    UIColor *color = [self createColorWithRGBA:hexColor];
    return color ? color : [UIColor clearColor];
}

- (void)setMaskType:(XNProgressHUDMaskType)maskType {
    _maskType = maskType;
}

- (void)setMaskType:(XNProgressHUDMaskType)maskType hexColor:(uint32_t)color {
    switch (maskType) {
        case XNProgressHUDMaskTypeClear:
            _maskColor.clear = color;
            break;
        case XNProgressHUDMaskTypeBlack:
            _maskColor.black= color;
            break;
        case XNProgressHUDMaskTypeCustom:
            _maskColor.custom = color;
            break;
        default:
            break;
    }
}

- (UIView *)refreshView {
    if(!_refreshView) {
        XNRefreshView *view = [XNRefreshView new];
        view.tintColor = self.titleLabel.textColor;
        view.lineWidth = 2.f;
        _refreshView = view;
    }
    return _refreshView;
}


- (void)setRefreshView:(UIView *)refreshView {
    if (refreshView) {
        _refreshView = refreshView;
        _refreshView.tintColor = _titleLabel.textColor;
        [self.contentView addSubview:refreshView];
    }
}


- (UIView *)shadeContentView {
    if(!_shadeContentView) {
        _shadeContentView = [UIView new];
        _shadeContentView.backgroundColor = [UIColor clearColor];
        _shadeContentView.layer.shadowColor = _shadowColor;
        _shadeContentView.layer.shadowOffset = CGSizeMake(3,3);
        _shadeContentView.layer.shadowOpacity = 0.6;
        _shadeContentView.layer.shadowRadius = 5.f;
        _shadeContentView.userInteractionEnabled = NO;
    }
    return _shadeContentView;
}

- (UIView *)contentView {
    if(!_contentView) {
        _contentView = [UIView new];
        _contentView.backgroundColor = _tintColor;
        _contentView.layer.borderColor = [UIColor clearColor].CGColor;
        _contentView.layer.borderWidth = 1.f;
        _contentView.layer.cornerRadius = 5.f;
        _contentView.layer.shouldRasterize = NO;
        _contentView.layer.rasterizationScale = 2;
        _contentView.layer.edgeAntialiasingMask = kCALayerLeftEdge | kCALayerRightEdge | kCALayerBottomEdge | kCALayerTopEdge;
        _contentView.clipsToBounds = YES;
        _contentView.layer.masksToBounds = YES;
    }
    return _contentView;
}


- (UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16.f];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _titleLabel;
}

@synthesize targetView = _targetView;
- (UIView *)targetView {
    if(_targetView) {
        return _targetView;
    }else{
        if(_viewController) {
            return _viewController.view;
        }else{
            return [UIApplication sharedApplication].delegate.window;
        }
    }
}

- (void)setTargetView:(UIView *)targetView {
    _targetView = targetView;
    _viewController = nil;
}

- (void)setTargetView:(UIView *)targetView position:(CGPoint)position {
    self.targetView = targetView;
    self.position = position;
}

- (void)setViewController:(UIViewController *)viewController {
    _viewController = viewController;
    _targetView = nil;
}

- (NSTimeInterval)minimumDelayDismissDuration {
    return _minimumDelayDismissDuration > 0 ? _minimumDelayDismissDuration : 1.5f;
}

- (NSTimeInterval)maximumDelayDismissDuration {
    return _maximumDelayDismissDuration > 0 ? _maximumDelayDismissDuration : 20.f;
}

- (void)setStyle:(XNProgressHUDStyle)style {
    _style = style;
}

- (void)setDisposableDelayDismiss:(NSTimeInterval)disposableDelayDismiss {
    _disposableDelayDismiss = disposableDelayDismiss;
}

- (void)setRefreshStyle:(XNRefreshViewStyle)refreshStyle {
    _refreshStyle = refreshStyle;
}

- (void)setTitle:(NSString *)title {
    _title = title;
}

- (void)setTintColor:(UIColor *)tintColor {
    self.contentView.backgroundColor = _tintColor = tintColor;
}

- (BOOL)isShowing {
    return _showing;
}

- (BOOL)isMaskEnable {
    return _maskType != XNProgressHUDMaskTypeNone;
}

- (CGFloat)maximumWidth {
    return [[UIScreen mainScreen] bounds].size.width * 0.7;
}

- (CGSize)titleLabelContentSize {
    if(!self.titleLabel.text || self.titleLabel.text.length == 0)
        return CGSizeZero;
    else
        return [self.titleLabel sizeThatFits:CGSizeMake(self.maximumWidth - _padding.left + _padding.right, MAXFLOAT)];
}

- (XNProgressHUDStyle)styleWithTitle:(NSString *)title {
    return (title && title.length > 0) ? XNProgressHUDStyleLoadingAndTitle : XNProgressHUDStyleLoading;
}

- (void)addMaskTapGestureEvent {
    [self removeMaskTapGestureEvent];
    UITapGestureRecognizer *maskTapEvent = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [self.maskView addGestureRecognizer: maskTapEvent];
}

- (void)removeMaskTapGestureEvent {
    if(self.maskView.gestureRecognizers.count > 0) {
        self.maskView.gestureRecognizers = nil;
    }
}

- (void)initialize {
    _duration = 0.2f;
    _padding = HUDPaddingMake(5, 5, 5, 6);
    _maskColor = XNHUDMaskColorMake(0x00000000, 0x00000033, 0x00000000);
    _refreshViewWidth = XNRefreshViewWidth;
    _tintColor = [UIColor colorWithRed:0/255.f green:0/255.f blue:0/255.f alpha:0.9f];
    _shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.f].CGColor;
    _position = [UIApplication sharedApplication].delegate.window.center;
    //shadeView、contentView
    [self.shadeContentView addSubview:self.contentView];
    [self.contentView addSubview:self.refreshView];
    [self.contentView addSubview:self.titleLabel];
}

- (void)update {
    //updateFrame
    HUDPadding padding = _padding;
    CGFloat refreshWidth = _refreshViewWidth;
    CGRect titleLabelFrame = CGRectZero, refreshViewFrame = CGRectZero;
    switch (self.style) {
        case XNProgressHUDStyleLoading: { //RefreshView
            refreshWidth *= 1.5;
            padding = HUDPaddingMake(padding.left*1.5, padding.left*1.5, padding.left*1.5, padding.left*1.5);
            _frame = CGRectMake(0, 0, refreshWidth + padding.left + padding.right, refreshWidth + padding.top + padding.bottom);
            _frame.origin = CGPointMake(_position.x-_frame.size.width/2, _position.y-_frame.size.height/2);
            refreshViewFrame = CGRectMake(padding.left, padding.top, refreshWidth, refreshWidth);
        }
            break;
        case XNProgressHUDStyleTitle: { //Title
            CGFloat maxWidth = self.maximumWidth;
            CGSize  titleLabelSize = [self.titleLabel sizeThatFits:CGSizeMake(maxWidth - padding.left + padding.right, MAXFLOAT)];
            _frame = CGRectMake(0, 0, padding.left + titleLabelSize.width + padding.right, padding.top + titleLabelSize.height + padding.bottom);
            _frame.origin = CGPointMake(_position.x-_frame.size.width/2, _position.y-_frame.size.height/2);
            titleLabelFrame = CGRectMake(padding.left, (_frame.size.height-titleLabelSize.height)/2, titleLabelSize.width, titleLabelSize.height);
        }
            break;
        case XNProgressHUDStyleLoadingAndTitle: { //RefreshView + Title
            CGSize  titleLabelSize = [self.titleLabel sizeThatFits:CGSizeMake(HUDScreenSize.width * 0.7f, MAXFLOAT)];
            CGFloat width = 0, height = 0;
            if(self.orientation == XNProgressHUDOrientationHorizontal) {
                width = padding.left*2 + refreshWidth + padding.right + titleLabelSize.width;
                CGFloat heightWithHudView = padding.top + refreshWidth + padding.bottom;
                CGFloat heightWithTitleView  = padding.top + titleLabelSize.height + padding.bottom;
                _frame.size = CGSizeMake(width, MAX(heightWithHudView, heightWithTitleView));
                _frame.origin = CGPointMake(_position.x-_frame.size.width/2, _position.y-_frame.size.height/2);
                refreshViewFrame = CGRectMake(padding.left, (_frame.size.height-refreshWidth)/2, refreshWidth, refreshWidth);
                titleLabelFrame = CGRectMake(padding.left*2 + refreshWidth, (_frame.size.height-titleLabelSize.height)/2, titleLabelSize.width, titleLabelSize.height);
            }else{
                refreshWidth *= 1.5;
                height = padding.top*2 + refreshWidth + padding.bottom + titleLabelSize.height;
                CGFloat widthWithHudView = padding.left + refreshWidth + padding.right;
                CGFloat widthWithTitleView  = padding.left + titleLabelSize.width + padding.right;
                _frame.size = CGSizeMake(MAX(widthWithHudView, widthWithTitleView), height);
                _frame.origin = CGPointMake(_position.x-_frame.size.width/2, _position.y-_frame.size.height/2);
                refreshViewFrame = CGRectMake((_frame.size.width-refreshWidth)/2, padding.top, refreshWidth, refreshWidth);
                titleLabelFrame = CGRectMake(padding.left, padding.top*2+refreshWidth, titleLabelSize.width, titleLabelSize.height);
            }
        }
            break;
        default:
            break;
    }
    if(! CGRectEqualToRect(titleLabelFrame, self.titleLabel.frame)) {
        self.titleLabel.frame = titleLabelFrame;
    }
    if(! CGRectEqualToRect(refreshViewFrame, self.refreshView.frame)) {
        self.refreshView.frame = refreshViewFrame;
    }
    self.shadeContentView.frame = self.frame;
    self.contentView.frame = self.shadeContentView.bounds;
}

#pragma mark - show hud on window
#pragma mark - show hud on viewController
- (void)setDisposableDelayResponse:(NSTimeInterval)delayResponse delayDismiss:(NSTimeInterval)delayDismiss {
    _disposableDelayResponse = delayResponse;
    _disposableDelayDismiss = delayDismiss;
}

/**
 显示Loading
 */
- (void)show {
    [self setStyle:XNProgressHUDStyleLoading];
    [self setRefreshStyle:XNRefreshViewStyleLoading];
    [self setTitle:nil];
    [self display];
}

- (void)showWithMaskType:(XNProgressHUDMaskType)maskType {
    [self setMaskType:maskType];
    [self show];
}

/**
 * 显示提示文字
 */
- (void)showWithTitle:(nullable NSString *)title {
    [self setStyle:XNProgressHUDStyleTitle];
    [self setRefreshStyle:XNRefreshViewStyleNone];
    [self setTitle:title];
    [self display];
}

- (void)showWithTitle:(nullable NSString *)title maskType:(XNProgressHUDMaskType)maskType {
    [self setMaskType:maskType];
    [self showWithTitle:title];
}

/**
 * 显示转圈视图 + 提示文字
 */
- (void)showLoadingWithTitle:(nullable NSString *)title {
    [self setStyle:[self styleWithTitle:title]];
    [self setRefreshStyle:XNRefreshViewStyleLoading];
    [self setTitle:title];
    [self display];
}

- (void)showLoadingWithTitle:(nullable NSString *)title maskType:(XNProgressHUDMaskType)maskType {
    [self setMaskType:maskType];
    [self showLoadingWithTitle:title];
}

/**
 * 进度视图 + 提示文字
 */
- (void)showProgressWithProgress:(float)progress {
    [self showProgressWithTitle:nil progress:progress];
}

- (void)showProgressWithTitle:(nullable NSString *)title progress:(float)progress {
    [self setStyle:[self styleWithTitle:title]];
    [self setRefreshStyle:XNRefreshViewStyleProgress];
    [self setTitle:title];
    [self setProgress:progress];
    [self display];
}

- (void)showProgressWithTitle:(nullable NSString *)title progress:(float)progress maskType:(XNProgressHUDMaskType)maskType {
    [self setMaskType:maskType];
    [self showProgressWithTitle:title progress:progress];
}

/**
 * 显示提示视图 + 提示文字
 */
- (void)showInfoWithTitle:(nullable NSString *)title {
    [self setStyle:[self styleWithTitle:title]];
    [self setRefreshStyle:XNRefreshViewStyleInfoImage];
    [self setTitle:title];
    [self display];
}

- (void)showInfoWithTitle:(nullable NSString *)title maskType:(XNProgressHUDMaskType)maskType {
    [self setMaskType:maskType];
    [self showInfoWithTitle:title];
}

/**
 * 显示提示视图 + 提示文字(操作失败)
 */
- (void)showErrorWithTitle:(nullable NSString *)title {
    [self setStyle:[self styleWithTitle:title]];
    [self setRefreshStyle:XNRefreshViewStyleError];
    [self setTitle:title];
    [self display];
    
}

- (void)showErrorWithTitle:(nullable NSString *)title maskType:(XNProgressHUDMaskType)maskType {
    [self setMaskType:maskType];
    [self showErrorWithTitle:title];
}

/**
 * 显示提示视图 + 提示文字(操作成功)
 */
- (void)showSuccessWithTitle:(nullable NSString*)title {
    [self setStyle:[self styleWithTitle:title]];
    [self setRefreshStyle:XNRefreshViewStyleSuccess];
    [self setTitle:title];
    [self display];
    
}

- (void)showSuccessWithTitle:(nullable NSString*)title maskType:(XNProgressHUDMaskType)maskType {
    [self setMaskType:maskType];
    [self showSuccessWithTitle:title];
}


// 从外界直接关闭，也叫强制关闭，需要清理强引用资源，然后再移除视图
- (void)dismiss {
    [self clearUp];
    [self didDismiss];
}

- (void)dismissWithDelay:(NSTimeInterval)delay {
    if(_showing && delay > 0) {
        [self startDismissTimerWithDuration:delay];
    }
}

- (void)display {
    if(self.disposableDelayResponse <= 0 || _showing) {
        [self stopTimers];
        [self didDisplay];
    }else{
        [self startDisplayTimerWithDuration:self.disposableDelayResponse];
    }
}

- (void)didDisplayOnMainQueue {
    // 标题
    self.titleLabel.text = self.title;
    // 样式,设置HUD的显示内容
    switch (_style) {
        case XNProgressHUDStyleTitle:{ //标题
            [self removeFromSuperview:self.refreshView];
            [self addSubviewIfNotContain:self.titleLabel superView:self.contentView];
        }
            break;
        case XNProgressHUDStyleLoading:{ //加载中
            [self removeFromSuperview:self.titleLabel];
            [self addSubviewIfNotContain:self.refreshView superView:self.contentView];
        }
            break;
        case XNProgressHUDStyleLoadingAndTitle:{//标题+加载中
            [self addSubviewIfNotContain:self.refreshView superView:self.contentView];
            [self addSubviewIfNotContain:self.titleLabel  superView:self.contentView];
        }
            break;
        default:
            break;
    }
    // 设置RefreshView的显示内容
    [self setStyleInRefreshView:self.refreshStyle];
    if(self.refreshStyle == XNRefreshViewStyleProgress) {
        [self setProgressInRefreshView:self.progress];
    }
    // maskView
    if(self.isMaskEnable) {
        self.maskView.backgroundColor = [self maskColorWithMaskType:self.maskType];
        [self addSubviewIfNotContain:self.maskView superView:self.targetView];
    }
    // contentView
    [self addSubviewIfNotContain:self.shadeContentView superView:self.targetView];
    // 如果没有显示，需要先调整位置，防止视图跳动
    BOOL showing = self.showing;
    if(!showing) {
        self.maskView.alpha = 0.f;
        self.shadeContentView.alpha = 0.f;
        [self update];
    }
    self.showing = YES;
    [self startRefreshAnimation];
    HUDWeakSelf;
    [UIView animateWithDuration:self.duration animations:^{
        // 如果正在显示，通过动画过度Frame
        if(showing) {
            [weakSelf update];
        }else{
            weakSelf.maskView.alpha = 1.f;
            weakSelf.shadeContentView.alpha = 1.f;
        }
    } completion:^(BOOL finished) {
        weakSelf.disposableDelayResponse = 0.f;
    }];
    
    // 延时自动消失
    if(_disposableDelayDismiss > 0) {
        [self startDismissTimerWithDuration:_disposableDelayDismiss];
    }else{
        switch ([self getStyleFromRefreshView]) {
            case XNRefreshViewStyleNone:
            case XNRefreshViewStyleInfoImage:
            case XNRefreshViewStyleError:
            case XNRefreshViewStyleSuccess:
                [self startDismissTimerWithDuration:self.minimumDelayDismissDuration];
                break;
            default:
                [self startDismissTimerWithDuration:self.maximumDelayDismissDuration];
                break;
        }
    }
}

- (void)didDisplay {
    [self performSelectorOnMainThread:@selector(didDisplayOnMainQueue) withObject:nil waitUntilDone:NO];
}

- (void)didDismiss {
    [self performSelectorOnMainThread:@selector(didDismissOnMainQueue) withObject:nil waitUntilDone:NO];
}

// 从内部关闭，由定时器调用或直接调用，无强引用隐患，无需清理强引用资源
- (void)didDismissOnMainQueue {
    BOOL showing = self.showing;
    if(!showing) return;
    self.showing = NO;
    if(_hudDismissBlock) _hudDismissBlock();
    [self stopRefreshAnimation];
    HUDWeakSelf;
    [UIView animateWithDuration:self.duration animations:^{
        if(weakSelf.isMaskEnable && weakSelf.maskView) {
            weakSelf.maskView.alpha = 0.f;
        }
        weakSelf.shadeContentView.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview:self.shadeContentView];
        [self removeFromSuperview:self.maskView];
        if(weakSelf.hudDismissBlock) {
            [self removeMaskTapGestureEvent];
        }
        weakSelf.disposableDelayDismiss = 0.f;
        weakSelf.maskType = XNProgressHUDMaskTypeNone;
    }];
}

- (void)startDisplayTimerWithDuration:(NSTimeInterval)duration{
    [self stopTimers];
    self.displayTimer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(didDisplay) userInfo:nil repeats:NO];
}

- (void)startDismissTimerWithDuration:(NSTimeInterval)duration {
    [self stopTimerAndSetItNil:_dismissTimer];
    self.dismissTimer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(didDismiss) userInfo:nil repeats:NO];
}

- (void)stopTimers {
    [self stopTimerAndSetItNil:_displayTimer];
    [self stopTimerAndSetItNil:_dismissTimer];
}

- (void)dealloc {
    [self clearUp];
}

- (void)clearUp {
    [self stopTimers];
}

#pragma mark - 控制RefreshView显示状态的方法
- (XNRefreshViewStyle)getStyleFromRefreshView {
    XNRefreshViewStyle style = XNRefreshViewStyleNone;
    if ([self.refreshView respondsToSelector:@selector(xn_getStyle)]) {
        NSNumber *value = [self.refreshView performSelector:@selector(xn_getStyle)];
        style = value.unsignedIntegerValue;
    }
    return style;
}

- (void)setStyleInRefreshView:(XNRefreshViewStyle)style {
    if ([self.refreshView respondsToSelector:@selector(xn_setStyle:)]) {
        NSNumber *value = [NSNumber numberWithUnsignedInteger:style];
        [self.refreshView performSelector:@selector(xn_setStyle:) withObject:value];
    }
}

- (void)startRefreshAnimation {
    if ([self.refreshView respondsToSelector:@selector(xn_startAnimation)]) {
        [self.refreshView performSelector:@selector(xn_startAnimation)];
    }
}

- (void)stopRefreshAnimation {
    if ([self.refreshView respondsToSelector:@selector(xn_stopAnimation)]) {
        [self.refreshView performSelector:@selector(xn_stopAnimation)];
    }
}

- (void)setProgressInRefreshView:(CGFloat)progress {
    if ([self.refreshView respondsToSelector:@selector(xn_setProgress:)]) {
        NSNumber *value = [NSNumber numberWithFloat:progress];
        [self.refreshView performSelector:@selector(xn_setProgress:) withObject:value];
    }
}
@end



