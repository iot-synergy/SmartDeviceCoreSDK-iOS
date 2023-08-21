#
# Be sure to run `pod lib lint SmartDeviceCoreSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SmartDeviceCoreSDK'
  s.version          = '2.0.0-alpha'
  s.summary          = 'smart device core sdk.'

  
  s.description      = <<-DESC
                        smart device core SDK
                       DESC

  s.homepage         = 'https://bitbucket-internal.addx.live/projects/SWCLIEN/repos/smartdevicecoresdk-ios/browse'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'meihuafeng' => 'hmei@a4x.io' }
  s.source           = { :git => 'ssh://git@bitbucket-internal.addx.live:7999/swclien/smartdevicecoresdk-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.swift_version = '5.1'
  
  s.subspec 'Binary' do |binary|
    binary.vendored_frameworks = 'SmartDeviceCoreSDK/Binary/*.xcframework'
  end
  
  
end
