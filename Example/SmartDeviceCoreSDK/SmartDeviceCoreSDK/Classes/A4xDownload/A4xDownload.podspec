#
# Be sure to run `pod lib lint A4xDownload.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'A4xDownload'
  s.version          = '1.6.5'
  s.summary          = 'A short description of A4xDownload.'
  
  
  s.description      = <<-DESC
  TODO: Add long description of the pod here.
  DESC
  
  s.homepage         = 'http://192.168.31.7:7990/projects/IOS_MODULE/repos/A4xDownload/browse'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'A4xDownload' => 'wjin@a4x.ai' }
  s.source           = { :git => 'ssh://git@192.168.31.7:7999/ios_module/A4xDownload.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '11.0'
  s.swift_version = '4.2'
  
  #一级目录
  s.source_files = '*.{swift,h,m,mm}'
  
  s.dependency 'A4xBaseSDK'
  s.dependency 'A4xZKDownload', '0.1.5'
  
end
