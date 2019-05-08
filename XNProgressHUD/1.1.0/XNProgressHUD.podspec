#
#  Be sure to run `pod spec lint XNProgressHUD.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
    
  s.name         = "XNProgressHUD"
  s.version      = "1.1.0"
  s.summary      = "一款支持自定义状态视图的的HUD"
  s.description  =
  <<-DESC
  一款支持自定义状态视图的的HUD，继承自XNProgressHUD并实现XNProgressHUDMethod中的方法。
  DESC

  s.homepage = "https://github.com/LuohanCC/XNProgressHUD"
  s.license  = { :type => 'MIT', :file => 'LICENSE' }
  s.author   = { "罗函" => "luohancc@163.com" }
  s.source   = { :git => "https://github.com/LuohanCC/XNProgressHUD.git", :tag => "#{s.version}" }
  
  s.ios.deployment_target = "7.0"
  s.source_files  = "Classes/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"
  s.framework     = "UIKit"
  s.requires_arc  = true

end
