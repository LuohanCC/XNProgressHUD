//
//  ViewController.m
//  XNProgressHUD
//
//  Created by 罗函 on 2018/4/10.
//  Copyright © 2018年 罗函. All rights reserved.
//

#import "ViewController.h"
#import "XNRefreshView.h"
#import "XNProgressHUD.h"
#import "UIViewController+XNProgressHUD.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet XNRefreshView *refreshView;
@property (weak, nonatomic) IBOutlet UISlider *sliderProgress;
@property (weak, nonatomic) IBOutlet UISwitch *switchDelayed;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segMaskType;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segDisplay;
@property (nonatomic, assign) NSTimeInterval delayResponse;
@property (nonatomic, assign) NSTimeInterval delayDismiss;
@property (nonatomic, strong) UIWindow *userWindow;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:225/255.0 green:101/255.0 blue:49/255.0 alpha:1];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.title = @"XNProgressHUD";
    self.view.backgroundColor = [UIColor colorWithRed:228/255.0 green:230/255.0 blue:234/255.0 alpha:1];
    
    [self initSubviews];
}

- (UIWindow *)userWindow {
    if (!_userWindow) {
        _userWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        //_userWindow.backgroundColor = [UIColor colorWithRed:1 green:0 blue:1 alpha:0.1];
        _userWindow.windowLevel = UIWindowLevelAlert + 1;
        _userWindow.hidden = NO;
    }
    return _userWindow;
}
- (void)initSubviews {
    // ini trefreshView.
    _delayResponse = 1.0f;
    _delayDismiss = 3.f;
    _refreshView.tintColor = [UIColor colorWithRed:225/255.0 green:101/255.0 blue:49/255.0 alpha:1];
    _refreshView.lineWidth = 4.f;
    _refreshView.label.font = [UIFont fontWithName:@"STHeitiTC-Light" size:14.f];
    _refreshView.style = XNRefreshViewStyleProgress;
    
    //init HUD.
    [XNHUD setPosition:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height * 0.7)];
    [XNHUD setTintColor:[UIColor colorWithRed:10/255.0 green:85/255.0 blue:145/255.0 alpha:0.7]];
    [XNHUD setMaskType:(XNProgressHUDMaskTypeCustom) hexColor:0x88000055];
    
    //init hud of the vc.
    [self.hud setPosition:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height * 0.7)];
    [self.hud setTintColor:[UIColor colorWithRed:38/255.0 green:50/255.0 blue:56/255.0 alpha:0.8]];
    [self.hud setRefreshStyle:(XNRefreshViewStyleProgress)];
    [self.hud setMaskType:(XNProgressHUDMaskTypeBlack)  hexColor:0x00000044];
    [self.hud setMaskType:(XNProgressHUDMaskTypeCustom) hexColor:0xff000044];
}

// 正在下载
- (IBAction)sliderProgressClick:(UISlider *)sender {
    _refreshView.progress = sender.value;
    [self.targetHud showProgressWithTitle:@"正在下载" progress:sender.value];
}

// 转态视图使用自定义视图
- (IBAction)switchCustomStatusView:(UISwitch *)sender {
    XNRefreshView *refreshView = (XNRefreshView *)self.hud.refreshView;
    if (sender.on) {
        [refreshView setInfoImage:[UIImage imageNamed:@"ico_xnprogresshud_info.png"]];
        [refreshView setErrorImage:[UIImage imageNamed:@"ico_xnprogresshud_error.png"]];
        [refreshView setSuccessImage:[UIImage imageNamed:@"ico_xnprogresshud_success.png"]];
    } else {
        [refreshView setInfoImage:nil];
        [refreshView setErrorImage:nil];
        [refreshView setSuccessImage:nil];
    }
}

// maskType
- (IBAction)maskTypeClick:(UISegmentedControl *)sender {
    [self.targetHud setMaskType:sender.selectedSegmentIndex];
}

// 重复上一次操作
- (IBAction)repeatitionClick:(UIButton *)sender {
    [self showhudWithIndex:_segDisplay.selectedSegmentIndex];
}

// 显示样式
- (IBAction)showHUDWithSegmentIndex:(UISegmentedControl *)sender {
    //self.segMaskType.selectedSegmentIndex = 0;
    [self.targetHud setMaskType:_segMaskType.selectedSegmentIndex];
    [self showhudWithIndex:sender.selectedSegmentIndex];
}

- (XNProgressHUD *)targetHud {
    return XNHUD;
}

- (void)showhudWithIndex:(NSInteger)index {
    switch (index) {
        case 0:{
            if(_switchDelayed.on) {
                [self.targetHud setDisposableDelayResponse:_delayResponse delayDismiss:_delayDismiss];
            }
            [self.targetHud show];
        }
            break;
        case 1:{
            if(_switchDelayed.on) {
                [self.targetHud setDisposableDelayResponse:_delayResponse delayDismiss:_delayDismiss];
            }
            [self.targetHud showLoadingWithTitle:@"正在登录"];
        }
            break;
        case 2:{
            [self.targetHud showWithTitle:@"这是一个支持自定义的轻量级HUD"];
        }
            break;
        case 3:{
            [self.targetHud showInfoWithTitle:@"请输入账号"];
        }
            break;
        case 4:{
            [self.targetHud showErrorWithTitle:@"拒绝访问"];
        }
            break;
        case 5:{
            [self.targetHud showSuccessWithTitle:@"操作成功"];
        }
            break;
        default:
            break;
    }
}

// 选择方向
- (IBAction)horizontionChanged:(UISegmentedControl *)sender {
    [self.targetHud setOrientation:sender.selectedSegmentIndex];
}

- (IBAction)targetViewDidChanged:(UISegmentedControl *)sender {
    [self.targetHud setMaskType:_segMaskType.selectedSegmentIndex];
    switch (sender.selectedSegmentIndex) {
        case 0: { // show HUD at the keyWindow.
            UIView *v = [UIApplication sharedApplication].keyWindow;
            self.targetHud.targetView = nil;
            self.targetHud.position = CGPointMake(v.bounds.size.width/2, v.bounds.size.height * 0.7);
            [self.targetHud setMaskType:(XNProgressHUDMaskTypeCustom) hexColor:0x88000055];
            [self.targetHud showSuccessWithTitle:@"默认显示在KeyWindow上显示"];
        }
            break;
        case 1: { // show HUD at the custom Window.
            UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"UIAlertController" message:@"通过设置\"XNHUD.windowLevel\"可以使HUD显示在UIAlertController之上" preferredStyle:(UIAlertControllerStyleAlert)];
            [alertVc addAction:[UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:nil]];
            [self presentViewController:alertVc animated:YES completion:nil];
            self.targetHud.targetView = self.userWindow;
            self.targetHud.position = CGPointMake(self.userWindow.bounds.size.width/2, self.userWindow.bounds.size.height/2);
            [self.targetHud setMaskType:(XNProgressHUDMaskTypeCustom) hexColor:0x00880011];
            [self.targetHud showSuccessWithTitle:@"显示在AlertViewcontroller之上"];
        }
            break;
        default: { //show HUD at the targetView.
            self.targetHud.padding = HUDPaddingMake(8, 8, 8, 8);
            self.targetHud.orientation = XNProgressHUDOrientationHorizontal;
            self.targetHud.targetView = self.view;
            self.targetHud.position = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height * 0.7);
            [self.targetHud setMaskType:(XNProgressHUDMaskTypeCustom) hexColor:0x00008855];
            [self.targetHud showSuccessWithTitle:@"指定显示在某个View上"];
        }
            break;
    }
}

// dismiss
- (IBAction)dismissClick:(id)sender {
    [self.targetHud dismiss];
}
@end
