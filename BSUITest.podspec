#
# Be sure to run `pod lib lint BSUITest.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BSUITest'
  s.version          = '0.1.2'
  s.summary          = 'A useful UI Automatic Testing Tool that supports UI Recording/UI Playback/Screen Record/Video Screenshot Comparison'
  
  s.description      = 'It is a useful UI Automatic Testing Tool that supports UI Recording/UI Playback/Screen Record/Video Screenshot Comparison without writing any ui test script.一个不用写UI测试脚本便可实现录制/回放/录屏/录屏截图相识度对比的UI自动化测试工具。'

  s.homepage         = 'https://github.com/vviicc/BSUITest'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'vviicc' => '704550191@qq.com' }
  s.source           = { :git => 'https://github.com/vviicc/BSUITest.git', :tag => s.version.to_s }
  s.frameworks = 'IOKit','CoreGraphics'
  s.vendored_frameworks = 'BSUITest/Classes/Vendor/PTFakeTouch.framework'
  
  s.ios.deployment_target = '8.0'

  s.source_files = 'BSUITest/Classes/**/*'
  s.exclude_files = 'BSUITest/Classes/Vendor/TPPreciseTimer.{h,m}'
  
  s.subspec 'mrc' do |sp|
      sp.source_files = 'BSUITest/Classes/Vendor/TPPreciseTimer.{h,m}'
      sp.requires_arc = false
  end
  
end
