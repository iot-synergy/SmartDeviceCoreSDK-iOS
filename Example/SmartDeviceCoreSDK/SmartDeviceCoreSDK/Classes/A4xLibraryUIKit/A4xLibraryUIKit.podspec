#
# Be sure to run `pod lib lint A4xLibraryUIKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'A4xLibraryUIKit'
  s.version          = '1.6.5'
  s.summary          = 'A short description of A4xLibraryUIKit.'
  
  
  s.description      = <<-DESC
  TODO: Add long description of the pod here.
  DESC
  
  s.homepage         = 'http://192.168.31.7:7990/projects/IOS_MODULE/repos/A4xLibraryUIKit/browse'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'A4xLibraryUIKit' => 'xxxx@xxx.ai' }
  s.source           = { :git => 'ssh://git@192.168.31.7:7999/ios_module/A4xLibraryUIKit.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '11.0'
  s.swift_version = '5.1'
  
  #一级目录
  s.source_files = '**/*.{swift,h,m,mm}'

  s.dependency 'lottie-ios'
  s.dependency 'SmartDeviceCoreSDK'
  s.dependency 'A4xIJKMediaPlayerUIKit'
  s.dependency 'FSCalendar'
  s.dependency 'JXSegmentedView'
  s.dependency 'A4xDeviceSettingInterface'
  s.dependency 'Resolver'
  s.dependency 'BaseUI'
  s.dependency 'MediaCodec'
  s.dependency 'YYWebImage'
  
  
end
