#
#  Be sure to run `pod spec lint XNProgressHUD.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "XNProgressHUD"
  s.version      = "0.0.1"
  s.summary      = "一款支持自定义状态视图的的HUD"

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description  = <<-DESC
  一款支持自定义状态视图的的HUD，继承自XNProgressHUD并实现XNProgressHUDMethod中的方法。
                   DESC

  s.homepage = "https://github.com/LuohanCC/XNProgressHUD"
  s.license  = { :type => 'MIT', :file => 'LICENSE' }
  s.author   = { "罗函" => "luohancc@163.com" }
  s.source   = { :git => "https://github.com/LuohanCC/XNProgressHUD.git", :tag => "#{s.version}" }
  
  s.ios.deployment_target = "7.0"
  s.source_files  = "SVProgressHUD/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"
  s.framework     = "UIKit"
  s.requires_arc  = true

end
