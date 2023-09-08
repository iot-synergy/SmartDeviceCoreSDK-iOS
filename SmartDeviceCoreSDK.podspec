#
# Be sure to run `pod lib lint SmartDeviceCoreSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SmartDeviceCoreSDK'
  s.version          = '2.0.0-alph8'
  s.summary          = 'smart device core sdk.'

  
  s.description      = <<-DESC
                        smart device core SDK
                       DESC

  s.homepage         = 'https://github.com/SmartIotDeviceSDK/SmartDeviceCoreSDK-iOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'mhf' => 'freelancer.mhf@gmail.com' }
  s.source           = { :git => 'git@github.com:SmartIotDeviceSDK/SmartDeviceCoreSDK-iOS.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.swift_version = '5.1'
  
  s.subspec 'Binary' do |binary|
    binary.vendored_frameworks = 'SmartDeviceCoreSDK/Binary/*.xcframework'
  end
  
  
end
