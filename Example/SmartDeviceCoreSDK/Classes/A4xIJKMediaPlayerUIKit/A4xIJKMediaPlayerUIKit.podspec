#
# Be sure to run `pod lib lint A4xIJKMediaPlayerUIKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'A4xIJKMediaPlayerUIKit'
  s.version          = '1.6.5'
  s.summary          = 'A short description of A4xIJKMediaPlayerUIKit.'
  
  
  s.description      = <<-DESC
  TODO: Add long description of the pod here.
  DESC
  
  s.homepage         = 'http://192.168.31.7:7990/projects/IOS_MODULE/repos/A4xIJKMediaPlayerUIKit/browse'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'A4xIJKMediaPlayerUIKit' => 'xxxx@xxx.ai' }
  s.source           = { :git => 'ssh://git@192.168.31.7:7999/ios_module/A4xIJKMediaPlayerUIKit.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '11.0'
  s.swift_version = '5.1'
  
  #一级目录
  s.source_files = '**/*.{swift,h,m,mm}'
  
  ijkMediaPlayerUIKitPodspecPath = File.dirname(__FILE__)
  s.xcconfig     = {
    "GCC_PREPROCESSOR_DEFINITIONS" => ["$(inherited)","COCOAPODS=1"]
  }
  
  s.libraries = "c++","z"
  s.dependency 'SmartDeviceCoreSDK'
  s.dependency 'BaseUI'
  s.dependency 'MediaCodec'

  s.pod_target_xcconfig = {'OTHER_LDFLAGS' => ["$(inherited)"]}
  
end
