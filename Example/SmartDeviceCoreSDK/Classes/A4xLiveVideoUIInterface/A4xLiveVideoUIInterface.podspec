#
#  Be sure to run `pod spec lint A4xLiveUIService.podspec' to ensure this is a
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

  spec.name         = "A4xLiveVideoUIInterface"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of A4xLiveVideoUIInterface."

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  spec.description  = <<-DESC
                  直播 UI 接口
                   DESC

  spec.homepage     = "http://EXAMPLE/A4xLiveVideoUIInterface"
  # spec.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See https://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #

  spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  spec.swift_version = '5.1'

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

  spec.source       = { :git => "ssh://git@192.168.31.7:7999/ios_module/A4xLiveVideoUIInterface.git", :tag => "#{spec.version}" }


  spec.source_files  = ["*.{swift,h,m,mm}","Model/**/*.{swift,h,m,mm}","View/**/*.{swift,h,m,mm}"]
  spec.exclude_files = "Classes/Exclude"


  spec.dependency 'SmartDeviceCoreSDK'
  spec.dependency 'Resolver'
  spec.dependency 'BaseUI'
  
end
