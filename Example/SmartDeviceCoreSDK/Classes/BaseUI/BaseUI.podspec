#
# Be sure to run `pod lib lint BaseUI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BaseUI'
  s.version          = '0.1.0'
  s.summary          = 'A short description of BaseUI.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/demo/BaseUI'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'demo' => 'hm@a4x.io' }
  s.source           = { :git => 'https://github.com/demo/BaseUI.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.swift_version = '5.1'
  s.source_files = ['BaseUI/A4xRouter/**/*', 'BaseUI/A4xBaseUI/**/*', 'BaseUI/Extension/**/*', 'BaseUI/Tools/**/*', 'BaseUI/UIConfig/**/*', 'BaseUI/A4xBaseLog/**/*']
  
  s.subspec 'Resources' do |ss|
    ss.resources = ['Resources/Assets.xcassets','Resources/Localizable/**/*','Resources/Other/json_normail_animail/*','Resources/Other/json_theme_animail/*','Resources/Other/Resource/*']
  end
  
  s.dependency 'URLNavigator', '~> 2.1.0'
  s.dependency 'SmartDeviceCoreSDK'
  s.dependency 'AutoInch', '~> 1.3.1'
  s.dependency 'SnapKit' , '~> 5.0.0'
  s.dependency 'MJRefresh' , '~> 3.2'
  s.dependency 'YogaKit'
  s.dependency 'lottie-ios'

  
end
