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
    
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    [self.view addSubview:view];
    // 设置显示的目标View并传入显示位置
    [XNHUD setTargetView:view position:CGPointMake(view.bounds.size.width/2, view.bounds.size.height/2)];
    [XNHUD showLoadingWithTitle:@"指定显示在某个View上"];
    
}

- (void)initSubviews {
    _delayResponse = 1.0f;
    _delayDismiss = 3.f;
    _refreshView.tintColor = [UIColor colorWithRed:225/255.0 green:101/255.0 blue:49/255.0 alpha:1];
    _refreshView.lineWidth = 4.f;
    _refreshView.label.font = [UIFont fontWithName:@"STHeitiTC-Light" size:14.f];
    _refreshView.style = XNRefreshViewStyleProgress;
    //show HUD at window
    [[XNProgressHUD shared] setPosition:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height * 0.7)];
    [[XNProgressHUD shared] setTintColor:[UIColor colorWithRed:10/255.0 green:85/255.0 blue:145/255.0 alpha:0.7]];
    //show HUD at vc
    [self.hud setPosition:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height * 0.7)];
    [self.hud setTintColor:[UIColor colorWithRed:38/255.0 green:50/255.0 blue:56/255.0 alpha:0.8]];
    [self.hud setRefreshStyle:(XNRefreshViewStyleProgress)];
    [self.hud setMaskType:(XNProgressHUDMaskTypeBlack)  hexColor:0x00000044];
    [self.hud setMaskType:(XNProgressHUDMaskTypeCustom) hexColor:0xff000044];
}

// 正在下载
- (IBAction)sliderProgressClick:(UISlider *)sender {
    _refreshView.progress = sender.value;
    [self.hud showProgressWithTitle:@"正在下载" progress:sender.value];
}

// 转态视图使用自定义视图
- (IBAction)switchCustomStatusView:(UISwitch *)sender {
    XNRefreshView *refreshView = (XNRefreshView *)self.hud.refreshView;
    if(sender.on) {
        [refreshView setInfoImage:[UIImage imageNamed:@"ico_xnprogresshud_info.png"]];
        [refreshView setErrorImage:[UIImage imageNamed:@"ico_xnprogresshud_error.png"]];
        [refreshView setSuccessImage:[UIImage imageNamed:@"ico_xnprogresshud_success.png"]];
    }else{
        [refreshView setInfoImage:nil];
        [refreshView setErrorImage:nil];
        [refreshView setSuccessImage:nil];
    }
}

// maskType
- (IBAction)maskTypeClick:(UISegmentedControl *)sender {
    [self.hud setMaskType:sender.selectedSegmentIndex];
}

// 重复上一次操作
- (IBAction)repeatitionClick:(UIButton *)sender {
    [self showhudWithIndex:_segDisplay.selectedSegmentIndex];
}

// 显示样式
- (IBAction)showHUDWithSegmentIndex:(UISegmentedControl *)sender {
    self.segMaskType.selectedSegmentIndex = 0;
    [self showhudWithIndex:sender.selectedSegmentIndex];
}

- (void)showhudWithIndex:(NSInteger)index {
    switch (index) {
        case 0:{
            if(_switchDelayed.on) {
                [self.hud setDisposableDelayResponse:_delayResponse delayDismiss:_delayDismiss];
            }
            [self.hud show];
        }
            break;
        case 1:{
            if(_switchDelayed.on) {
                [self.hud setDisposableDelayResponse:_delayResponse delayDismiss:_delayDismiss];
            }
            [self.hud showLoadingWithTitle:@"正在登录"];
        }
            break;
        case 2:{
            [self.hud showWithTitle:@"这是一个支持自定义的轻量级HUD"];
        }
            break;
        case 3:{
            [self.hud showInfoWithTitle:@"请输入账号"];
        }
            break;
        case 4:{
            [self.hud showErrorWithTitle:@"拒绝访问"];
        }
            break;
        case 5:{
            [self.hud showSuccessWithTitle:@"操作成功"];
        }
            break;
        default:
            break;
    }
}

// 选择方向
- (IBAction)horizontionChanged:(UISegmentedControl *)sender {
    [self.hud setOrientation:sender.selectedSegmentIndex];
}

// dismiss
- (IBAction)dismissClick:(id)sender {
    [self.hud dismiss];
}
@end
