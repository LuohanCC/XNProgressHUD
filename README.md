# XNProgressHUD

一个丝滑、灵活的HUD

![hud-01.gif](http://www.wailian.work/images/2019/07/29/hud-01.gif)
![hud-02.gif](http://www.wailian.work/images/2019/07/29/hud-02.gif)
![hud-03.gif](http://www.wailian.work/images/2019/07/29/hud-03.gif)
![hud-04.gif](http://www.wailian.work/images/2019/07/29/hud-04.gif)
#
一款支持各种自定义的轻量级HUD，支持垂直、水平两种样式。XNProgressHUD非常灵活，所见的部分都可根据自己的要求进行自定义，包括自义动画效果或图片，只需要实现相关协议方法。

## 安装使用
```ruby
 pod 'XNProgressHUD'
```

## 使用说明

 ```Objective-C
// 设置显示位置
[XNHUD setPosition:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height * 0.7)];
// 设置主色调
[XNHUD setTintColor:[UIColor colorWithRed:38/255.0 green:50/255.0 blue:56/255.0 alpha:0.8]];
// 设置相应的maskType状态下的颜色（16进制颜色值）
[XNHUD setMaskType:(XNProgressHUDMaskTypeBlack)  hexColor:0x00000044];
[XNHUD setMaskType:(XNProgressHUDMaskTypeCustom) hexColor:0xff000044];
 ```

 **在UIWindow上显示：**
 ```Objective-C
 [XNHUD showLoadingWithTitle:@"正在登录"];
 [XNHUD showWithTitle:@"这是一个支持自定义的轻量级HUD"];
 [XNHUD showInfoWithTitle:@"邮箱地址不能为空"];
 [XNHUD showErrorWithTitle:@"拒绝访问"];
 [XNHUD showSuccessWithTitle:@"操作成功"];
 ```

 **在UIViewController上显示（maskType.enable=true时，导航栏依然可以接受点击事件）**
 ```Objective-C
 // 引入'UIViewController+XNProgressHUD.h'
 [self.hud showLoadingWithTitle:@"正在登录"];
 [self.hud showWithTitle:@"这是一个支持自定义的轻量级HUD"];
 [self.hud showInfoWithTitle:@"邮箱地址不能为空"];
 [self.hud showErrorWithTitle:@"拒绝访问"];
 [self.hud showSuccessWithTitle:@"操作成功"];
 ```

 **在UIView上显示**
  ```Objective-C
UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
[self.view addSubview:view];
// 设置显示的目标View并传入显示位置
[XNHUD setTargetView:view position:CGPointMake(view.bounds.size.width/2,  view.bounds.size.height/2)];
[XNHUD showLoadingWithTitle:@"指定显示在某个View上"];
  ```

 ## 属性和方法说明
 显示时长minimumDelayDismissDuration作用于非加载样式的视图：***XNAnimationViewStyleInfoImage、XNAnimationViewStyleError、XNAnimationViewStyleSuccess***；
 显示时长maximumDelayDismissDuration作用与加载样式的视图：***XNAnimationViewStyleLoading、XNAnimationViewStyleProgress***。
 ```Objective-C
@property (nonatomic, assign) NSTimeInterval minimumDelayDismissDuration; //default:1.5f
@property (nonatomic, assign) NSTimeInterval maximumDelayDismissDuration; //default:20.f
 ```

延时显示时间和延时消失时间，该方法只对下一次HUD显示生效（只生效一次）。
 ```Objective-C
[XNHUD setDisposableDelayResponse:1.0f delayDismiss:2.0f];
 ```

 设置排列方向，默认为垂直方向
 ```Objective-C
[XNHUD setOrientation:XNProgressHUDOrientationHorizontal];
 ```

 ## 自定义XNProgressHUD
 你可以自定义某一个状态下的动画，步骤非常简单，喜欢XNAnimationView中相应的Layer就行了，如果你想替换所有状态下的动画，请重写XNAnimationView。



这里就介绍这么多，其他功能自行探索。




 ## GitHub地址
 https://github.com/LuohanCC/XNProgressHUD
 #
**如果你觉得不错，请给我Star ★★★★★★★★★★**
![给我Star吧](http://www.wailian.work/images/2018/08/03/star.png)


