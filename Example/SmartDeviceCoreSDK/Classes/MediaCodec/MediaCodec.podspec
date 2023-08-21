#
# Be sure to run `pod lib lint MediaCodec.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MediaCodec'
  s.version          = '0.1.0'
  s.summary          = '视频编解码的三方库'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/meihuafeng/MediaCodec'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'meihuafeng' => 'freelancer.mhf@gmail.com' }
  s.source           = { :git => 'https://github.com/meihuafeng/MediaCodec.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'


  s.subspec 'ffmpeg' do |ffmpeg|
    ffmpeg.source_files = ['MediaCodec/Classes/*.{swift,h,m,mm}']
    ffmpeg.public_header_files = 'MediaCodec/Classes/*.h'
  end

  s.subspec 'IJKMediaPlayer' do |ijkplayer|
    ijkplayer.source_files = ['MediaCodec/IJKMediaPlayer/*.{h,mm,m}','MediaCodec/IJKMediaPlayer/**/*.{h,mm,m,c}','MediaCodec/ijkmedia/ijkplayer/ijkavformat/*.{h,c}','MediaCodec/ijkmedia/ijkplayer/ijkavutil/*.{h,c,cpp}','MediaCodec/ijkmedia/ijkplayer/pipeline/*.{h,c}','MediaCodec/ijkmedia/ijkplayer/*.{h,c}','MediaCodec/ijkmedia/ijksdl/*.{h,c}','MediaCodec/ijkmedia/ijksdl/dummy/*.{h,c}','MediaCodec/ijkmedia/ijksdl/ffmpeg/**/*.{h,c}','MediaCodec/ijkmedia/ijksdl/gles2/**/*.{h,c,m}']
    #ijkplayer.private_header_files = ['MediaCodec/IJKMediaPlayer/*.{h}']
    ijkplayer.public_header_files = ['MediaCodec/IJKMediaPlayer/IJKMediaPlayback.h','MediaCodec/IJKMediaPlayer/IJKMPMoviePlayerController.h','MediaCodec/IJKMediaPlayer/IJKFFOptions.h','MediaCodec/IJKMediaPlayer/IJKFFMoviePlayerController.h','MediaCodec/IJKMediaPlayer/IJKAVMoviePlayerController.h','MediaCodec/IJKMediaPlayer/IJKMediaModule.h','MediaCodec/IJKMediaPlayer/IJKMediaPlayer.h','MediaCodec/IJKMediaPlayer/IJKNotificationManager.h','MediaCodec/IJKMediaPlayer/IJKKVOController.h','MediaCodec/IJKMediaPlayer/IJKSDLGLViewProtocol.h','MediaCodec/IJKMediaPlayer/IJKFFMonitor.h']
    ijkplayer.exclude_files = ['MediaCodec/ijkmedia/ijkplayer/ijkavformat/ijkioandroidio.c','MediaCodec/ijkmedia/ijkplayer/ijkavformat/ijkmediadatasource.c','MediaCodec/ijkmedia/ijksdl/ijksdl_extra_log.h','MediaCodec/ijkmedia/ijksdl/ijksdl_extra_log.c']
    ijkplayer.requires_arc = false
    ijkplayer.requires_arc = ['MediaCodec/IJKMediaPlayer/*','MediaCodec/IJKMediaPlayer/ijkmedia/ijkplayer/ios/pipeline/*','MediaCodec/IJKMediaPlayer/ijkmedia/ijkplayer/ios/*','MediaCodec/IJKMediaPlayer/ijkmedia/ijksdl/ios/*','MediaCodec/ijkmedia/ijkplayer/ijkavformat/*','MediaCodec/ijkmedia/ijkplayer/ijkavutil/*','MediaCodec/ijkmedia/ijkplayer/pipeline/*','MediaCodec/ijkmedia/ijkplayer/*','MediaCodec/ijkmedia/ijksdl/*','MediaCodec/ijkmedia/ijksdl/dummy/*','MediaCodec/ijkmedia/ijksdl/ffmpeg/**/*','MediaCodec/ijkmedia/ijksdl/gles2/**/*']
    
  end
  
  s.subspec 'TS2MP4' do |ts2mp4|
    ts2mp4.source_files = 'MediaCodec/TS2MP4/*.{swift,h,mm,m}'
    ts2mp4.public_header_files = ['MediaCodec/TS2MP4/ADMediaAssetExportSession.h','MediaCodec/TS2MP4/KMMedia.h','MediaCodec/TS2MP4/KMMediaAsset.h','MediaCodec/TS2MP4/KMMediaFormat.h','MediaCodec/TS2MP4/KMMediaAsset.h','MediaCodec/TS2MP4/KMMediaAssetExportSession.h']
  end
  
  #三级目录
  s.subspec 'GPAC4iOS' do |gpac4ios|
    gpac4ios.source_files = 'MediaCodec/GPAC4iOS/*.{swift,h,mm,m}'
    gpac4ios.private_header_files = 'MediaCodec/GPAC4iOS/*.{h}'
  end

  podspecPath = File.dirname(__FILE__)
  
  s.vendored_libraries  = 'MediaCodec/ffmpeg/lib/*.{a}','MediaCodec/TS2MP4/*.{a}','MediaCodec/GPAC4iOS/*.{a}'
  s.libraries =  'iconv', 'z'

  
  # 通过添加 -lssl 和 -lcrypto 链接标志，告诉链接器在链接 MediaCodec 模块时，要链接 libssl 和 libcrypto 这两个库。
  s.pod_target_xcconfig     = {
    'HEADER_SEARCH_PATHS' => [
    podspecPath + "/MediaCodec/ffmpeg/include",
    podspecPath + "/MediaCodec/ijkmedia",
    podspecPath + "/MediaCodec/IJKMediaPlayer/ijkmedia"
    ],
    "GCC_PREPROCESSOR_DEFINITIONS" => ["$(inherited)","A4X_RTC=1"],
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  
  s.dependency 'SmartDeviceCoreSDK'

end
