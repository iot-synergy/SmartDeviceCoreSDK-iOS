#
#  Be sure to run `pod spec lint BindUIkit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "BindUIkit"
  spec.version      = "1.6.5"
  spec.summary      = "A short description of BindUIkit."

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  spec.description  = <<-DESC
                      Bind SDK
                   DESC

  spec.homepage     = "http://EXAMPLE/BindUIkit"
  spec.swift_version = '5.1'
  # spec.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See https://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #

  spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the authors of the library, with email addresses. Email addresses
  #  of the authors are extracted from the SCM log. E.g. $ git log. CocoaPods also
  #  accepts just a name if you'd rather not provide an email address.
  #
  #  Specify a social_media_url where others can refer to, for example a twitter
  #  profile URL.
  #

  spec.author             = { "demo" => "hm@a4x.io" }
  # Or just: spec.author    = "demo"
  # spec.authors            = { "demo" => "hm@a4x.io" }
  # spec.social_media_url   = "https://twitter.com/demo"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  spec.ios.deployment_target = "11.0"

  spec.source       = { :git => "ssh://git@192.168.31.7:7999/ios_module/g0-ios.git", :tag => "#{spec.version}" }


  spec.source_files = ['*.{swift,h,m,mm}','A4xBindUIKit/**/*.{swift,h,m,mm}','BindEvent/**/*.{swift,h,m,mm}']

  spec.public_header_files = "BindUIkit.h"

  
  spec.subspec 'Resources' do |ss|
    ss.resources = ['Resources/Images.xcassets', 'Resources/gif/*.gif', 'Resources/json/*']
  end

  
  spec.dependency 'SmartDeviceCoreSDK'
  spec.dependency 'Resolver'
  spec.dependency 'BindInterface'
  spec.dependency 'A4xLiveVideoUIInterface'
  spec.dependency 'lottie-ios'
  spec.dependency 'A4xLocation'
  spec.dependency 'ScanQR'
  spec.dependency 'BaseUI'

end
