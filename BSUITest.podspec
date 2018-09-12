#
# Be sure to run `pod lib lint BSUITest.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BSUITest'
  s.version          = '0.1.5'
  s.summary          = 'A useful UI Automatic Testing Tool that supports UI Recording/UI Playback/Screen Record/Video Screenshot Comparison'
  
  s.description      = 'It is a useful UI Automatic Testing Tool that supports UI Recording/UI Playback/Screen Record/Video Screenshot Comparison without writing any ui test script.一个不用写UI测试脚本便可实现录制/回放/录屏/录屏截图相识度对比的UI自动化测试工具。'

  s.homepage         = 'https://github.com/vviicc/BSUITest'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'vviicc' => '704550191@qq.com' }
  s.source           = { :git => 'https://github.com/vviicc/BSUITest.git', :tag => s.version.to_s }
  s.frameworks       = 'IOKit','CoreGraphics'

  s.ios.deployment_target = '8.0'
  s.source_files = 'BSUITest/Classes/BSUITestManager.{h,m}'


  s.subspec 'Logic' do |logicsp|
      logicsp.source_files = 'BSUITest/Classes/BSUITestLogic.{h,m}','BSUITest/Classes/BSUITestFileHelper.{h,m}'
      logicsp.dependency 'BSUITest/Vendor'
      logicsp.dependency 'BSUITest/MRC'
      logicsp.vendored_frameworks = 'BSUITest/Classes/Vendor/PTFakeTouch.framework'
  end
  
  s.subspec 'UI' do |uisp|
      uisp.source_files = 'BSUITest/Classes/UI/*.{h,m}'
      uisp.dependency 'BSUITest/Logic'
      uisp.dependency 'BSUITest/Vendor'
  end

  s.subspec 'Vendor' do |vendorsp|
      vendorsp.source_files = 'BSUITest/Classes/Vendor/**/*.{h,m}'
      vendorsp.exclude_files = 'BSUITest/Classes/Vendor/TPPreciseTimer.{h,m}'
  end

  s.subspec 'MRC' do |mrcsp|
      mrcsp.source_files = 'BSUITest/Classes/Vendor/TPPreciseTimer.{h,m}'
      mrcsp.requires_arc = false
  end
  
end
