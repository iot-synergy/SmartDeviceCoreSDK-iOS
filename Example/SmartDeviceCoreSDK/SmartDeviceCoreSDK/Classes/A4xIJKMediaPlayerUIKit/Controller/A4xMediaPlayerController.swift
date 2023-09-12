//


//


//

import Foundation
import MediaCodec

import SmartDeviceCoreSDK
import BaseUI


public enum A4xMediaPlayerType {
    case ijkType
    case avType
}

@objc public enum A4xMediaPlayerState: Int {
    case none       
    case cache      
    case playing    
    case comple     
    case pause      
    case stop       
    case error      
}


public protocol A4xMediaPlayerControllerDelegate: class {
    
    func mediaPlayerUpdateState(_ state: A4xMediaPlayerState, _ playTime: Float?, _ isCacheDone: Bool?, _ errorInfo: String?)
    
}

open class A4xMediaPlayerController : NSObject {
    
    public weak var delegate: A4xMediaPlayerControllerDelegate? 
    
    
    private var avplayer: AVPlayer?
    private var playerItem: AVPlayerItem!
    
    
    private var ijkPlayer: IJKFFMoviePlayerController?
    
    private var playerState: A4xMediaPlayerState? {
        didSet {
            
        }
    }
    
    private var isPlaying = false
    private var isSeeking = false
    private var url: URL? {
        didSet {
            self.stopVideo()
        }
    }
    
    //记录上次时间
    private var _currentDuration: Float = 0 {
        didSet {
            
            self.mediaPlayerView?.currentDuration = _currentDuration
        }
    }
    
    public var mediaPlayerView: A4xMediaPlayerView?
    
    public var magicPixEnable: Bool = false {
        didSet {
            ijkPlayer?.magicPixEnable = magicPixEnable
        }
    }
    
    public var playerType: A4xMediaPlayerType? = .ijkType
    
    public var isAutoPlay = false
    
    public var videoUrl: URL? {
        get {
            return url
        }
        set {
            self.url = newValue
        }
    }
    
    public var duration: Float {
        var totalTimeRes: CMTime?
        if playerType == .avType {
            guard let totalTime = self.avplayer?.currentItem?.duration else {
                return 0.0
            }
            totalTimeRes = totalTime
        } else {
            guard let totalTime = self.ijkPlayer?.duration else {
                return 0.0
            }
            totalTimeRes = CMTimeMake(value: Int64(totalTime), timescale: 1)
        }
        let totalSec = CMTimeGetSeconds(totalTimeRes ?? CMTimeMake(value: Int64(0), timescale: 1))
        return Float(totalSec)
    }
    
    public var currentDuration: Float {
        var currentTimeRes: CMTime?
        if playerType == .avType {
            guard let currentTime = self.avplayer?.currentItem?.currentTime() else {
                return 0.0
            }
            currentTimeRes = currentTime
        } else {
            guard let currentTime = self.ijkPlayer?.currentPlaybackTime else {
                return 0.0
            }
            
            var currentTimeFinal = currentTime
            if (self.ijkPlayer?.duration ?? 0) - currentTime < 0 {
                currentTimeFinal = self.ijkPlayer?.duration ?? 0
            }
            currentTimeRes = CMTimeMake(value: Int64(lroundf(Float(currentTimeFinal))), timescale: 1)
        }
        let currentSec = CMTimeGetSeconds(currentTimeRes ?? CMTimeMake(value: Int64(0), timescale: 1))
        return Float(currentSec)
    }
    
    
    internal func seek(time: Float) {
        if playerType == .avType {
            
            if let totalTime = self.avplayer?.currentItem?.duration {
                let totalSec = CMTimeGetSeconds(totalTime)
                let playTimeSec = min(Float(totalSec), time)
                self.isSeeking = true
                weak var weakSelf = self
                
                
                //playToEndTime
                seek(toTime: Float64(ceil(playTimeSec))) { (result) in
                    weakSelf?.isSeeking = false
                    weakSelf?.playVideo()
                }
            }
        } else {
            if let totalTime = self.ijkPlayer?.duration {
                let totalTimeRes = CMTimeMake(value: Int64(totalTime), timescale: 1)
                let totalSec = CMTimeGetSeconds(totalTimeRes)
                let playTimeSec = min(Float(totalSec), time)
                self.isSeeking = false
                weak var weakSelf = self
                
                
                self.seek(toTime: Float64(ceil(playTimeSec))) { (result) in
                    weakSelf?.isSeeking = false
                    //weakSelf?.playVideo()
                }
            }
        }
    }
    
    
    internal func seek(progress: Float) {
        if (progress < 0 || progress > 1) {
            return
        }
        
        if playerType == .avType {
            
            if let totalTime = self.avplayer?.currentItem?.duration {
                let totalSec = CMTimeGetSeconds(totalTime)
                let playTimeSec = Float(totalSec) * progress
                self.isSeeking = true
                
                weak var weakSelf = self
                guard !(playTimeSec.isNaN || playTimeSec.isInfinite) else {
                    return
                }
                
                seek(toTime: Float64(ceil(playTimeSec))) { (result) in
                    weakSelf?.isSeeking = false
                    weakSelf?.playVideo()
                }
            }
        } else {
            if let totalTime = self.ijkPlayer?.duration {
                let totalTimeRes = CMTimeMake(value: Int64(totalTime), timescale: 1)
                let totalSec = CMTimeGetSeconds(totalTimeRes)
                let playTimeSec = Float(totalSec) * progress
                self.isSeeking = false
                
                weak var weakSelf = self
                guard !(playTimeSec.isNaN || playTimeSec.isInfinite) else {
                    return
                }
                
                seek(toTime: Float64(ceil(playTimeSec))) { (result) in
                    weakSelf?.isSeeking = false
                }
            }
        }
    }
    
    private func mediaPlayerUpdateState(_ state: A4xMediaPlayerState, _ playTime: Float?, _ isCacheDone: Bool?, _ errorInfo: String?) {
        self.playerState = state
        switch state {
        case .playing:
            self.isPlaying = true
            self.mediaPlayerView?.duration = duration
        case .none:
            break
        case .cache:
            break
        case .comple:
            self.isPlaying = false
            break
        case .pause:
            self.isPlaying = false
            break
        case .stop:
            self.isPlaying = false
            break
        case .error:
            break
        }
        self.mediaPlayerView?.mediaPlayerUpdateState(state: state, playTime ?? 0.0, isCacheDone ?? false, errorInfo ?? "")
        self.delegate?.mediaPlayerUpdateState(state, playTime, isCacheDone, errorInfo)
    }
}


extension A4xMediaPlayerController {
    
    
    private func seek(toTime: Float64, completionHandler: @escaping (Bool) -> Void) {
        
        let currentTime = CMTimeMake(value: Int64(toTime), timescale: 1)
        if playerType == .avType {
            self.avplayer?.seek(to: currentTime, completionHandler: completionHandler)
        } else {
            self.ijkPlayer?.currentPlaybackTime = toTime
        }
    }
    
    
    private func rate(_ sender: Any) {
        if playerType == .avType {
            self.avplayer?.rate = 1.0
        } else {
            self.ijkPlayer?.playbackRate = 1.0
        }
    }
    
    
    private func muted() {
        if playerType == .avType {
            self.avplayer?.isMuted = false 
        } else {
            self.ijkPlayer?.playbackVolume = 0
        }
    }
    
    
    private func volume(_ sender: UISlider) {
        if (sender.value < 0 || sender.value > 1) {
            return
        }
        if playerType == .avType {
            if (sender.value > 0) {
                self.avplayer?.isMuted = false
            }
            self.avplayer?.volume = sender.value
        } else {
            self.ijkPlayer?.playbackVolume = sender.value
        }
    }
    
    
    public func playVideo() {
        
        self.isPlaying = true
        if playerType == .avType {
            if self.playerItem == nil {
                self.initPlayerWith(url: self.url)
            } else {
                self.resumeVideo()
            }
        } else {
            if self.ijkPlayer == nil {
                self.initPlayerWith(url: self.url)
            } else {
                self.resumeVideo()
            }
        }
    }
    
    public func changeVideoUrl(url: URL?) {
        self.videoUrl = url
        DispatchQueue.main.a4xAfter(0.3) {
            self.playVideo()
        }
    }
    
    
    private func resumeVideo() {
        self.mediaPlayerUpdateState(.playing, self.currentDuration, nil, nil)
        if playerType == .avType {
            if !self.videoCanPlay() {
                self.videoIntoCache()
            }
            self.avplayer?.play()
        } else {
            self.ijkPlayer?.play()
        }
    }
    
    
    public func pauseVideo() {
        self.mediaPlayerUpdateState(.pause, nil, nil, nil)
        if playerType == .avType {
            self.avplayer?.pause()
        } else {
            self.ijkPlayer?.pause()
        }
    }
    
    
    public func stopVideo() {
        self.mediaPlayerUpdateState(.stop, nil, nil, nil)
        
        if playerType == .avType {
            guard self.avplayer != nil && self.playerItem != nil else {
                return
            }
            
            self.avplayer?.pause()
            removeAVMovieNotificationObservers()
            self.playerItem = nil
            self.avplayer = nil
        } else {
            guard self.ijkPlayer != nil else {
                return
            }
            
            self.stopIJKPLayerTimer()
            self.ijkPlayer?.pause()
            
            
            self.ijkPlayer?.stop()
            self.ijkPlayer?.shutdown()
            if self.ijkPlayer?.view != nil {
                self.ijkPlayer?.view.removeFromSuperview()
            }
            self.removeIJKMovieNotificationObservers()
            self.ijkPlayer = nil
        }
    }
    
    public func changeOrientation(isLandscape: Bool) {
        var frame = CGRect(x: 0, y: 0, width: max(UIScreen.width, UIScreen.height), height: min(UIScreen.width, UIScreen.height))
        if isLandscape {
            self.mediaPlayerView?.frame = frame
        } else {
            let contentHeight = CGFloat(0.56) * min(UIScreen.width, UIScreen.height)
            frame = CGRect(x: 0, y: 0, width: min(UIScreen.width, UIScreen.height), height: contentHeight)
            self.mediaPlayerView?.frame = frame
        }
        if playerType == .ijkType {
            
            self.ijkPlayer?.view.frame = frame
            
            let oldImgView = self.mediaPlayerView?.mediaContentView.getSubViewByTag(tag: 1001)
            if (oldImgView?.count ?? 0) > 0 {
                oldImgView?[0].frame = frame
            }
        }
    }
    
    
    private func stopError() {
        self.mediaPlayerUpdateState(.error, nil, nil, "load error")
        self.stopVideo()
    }
    
    
    private func initPlayerWith(url: URL?) {
        self.mediaPlayerView?.protocol = self
        guard let url = self.url else {
            return
        }
        
        videoIntoCache()
        
        if playerType == .avType {
            initVideoAVPlayer(videoUrl: url)
        } else {
            initVideoIJKPlayer(videoUrl: url, voiceEnable: true)
        }
    }
    
    
    private func updateTimesInfo() {
        let currentD = self.currentDuration
        if _currentDuration != currentD {
            _currentDuration = currentD
        }
        
        if !self.isSeeking && self.isPlaying {
            self.mediaPlayerUpdateState(.playing, self.currentDuration, nil, nil)
        }
        
        if playerType == .avType {
            
            if self.duration > 0 {
                if Int(self.currentDuration) / Int(self.duration) == 1 {
                    DispatchQueue.main.a4xAfter(0.2) {
                        self.pauseVideo()
                    }
                }
            }
        }
    }
    
    
    private func videoIntoCache() {
        self.mediaPlayerUpdateState(.cache, nil, false, nil)
    }
    
    
    private func videoCacheDone() {
        self.mediaPlayerUpdateState(.cache, nil, true, nil)
        //更新封面图
        self.reloadVideoCoverImage()
    }
    
    @objc func becomActive() {
        self.resumeVideo()
    }
    
    @objc func enterBackGround() {
        self.pauseVideo()
    }
}


extension A4xMediaPlayerController {
    private func initVideoAVPlayer(videoUrl: URL) {
        
        let asset = AVURLAsset(url: videoUrl)
        let playerItem = AVPlayerItem(asset: asset)
        self.playerItem = playerItem
        self.avplayer = AVPlayer(playerItem: self.playerItem)
        
        if #available(iOS 10.0, *) {
            self.avplayer?.automaticallyWaitsToMinimizeStalling = false
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            //try AVAudioSession.sharedInstance().setCategory(.multiRoute)
            try AVAudioSession.sharedInstance().setActive(true, options: [])
        } catch {
            
        }
        
        
        
        

        if let playerLayer = self.mediaPlayerView?.mediaContentView.layer as? AVPlayerLayer {
            
            playerLayer.player = avplayer
            
            /*
             videoGravity 视频拉伸方式
             .resizeAspect          
             .resizeAspectFill      
             .resize                
             */
            playerLayer.videoGravity = .resizeAspect
            
            playerLayer.backgroundColor = UIColor.black.cgColor
        }
        
        installAVMovieNotificationObservers()
    }
    
    
    private func installAVMovieNotificationObservers() {
        
        
        self.playerItem.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        self.playerItem.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        self.playerItem.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        self.playerItem.addObserver(self, forKeyPath: "playbackBufferFull", options: .new, context: nil)
        
        weak var weakSelf = self
        self.avplayer?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 2), queue: DispatchQueue.main) { (time) in
            weakSelf?.updateTimesInfo()
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(playToEndTime), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(playError), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: self.playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(videoInterrup(sender:)), name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())

        NotificationCenter.default.addObserver(self, selector: #selector(becomActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enterBackGround), name: UIApplication.didEnterBackgroundNotification, object: nil)
          
    }
    
    private func removeAVMovieNotificationObservers() {
        self.playerItem.removeObserver(self, forKeyPath: "status")
        self.playerItem.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        self.playerItem.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        self.playerItem.removeObserver(self, forKeyPath: "playbackBufferFull")
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerItem)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: self.playerItem)
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
   
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let playerItem = object as? AVPlayerItem else { return }
        if keyPath == "status" {
            
            if playerItem.status == .readyToPlay {
                self.playVideo()
                self.updateTimesInfo()
            } else {
                
                self.stopError()
            }
        } else if keyPath == "playbackBufferEmpty" {
            
            if playerItem.isPlaybackBufferEmpty {
                self.videoIntoCache()
            }
        } else if keyPath == "playbackLikelyToKeepUp" {
            
            if self.isPlaying && playerItem.isPlaybackLikelyToKeepUp {
                
                self.videoCacheDone()
                self.playVideo()
            }
        } else if keyPath == "playbackBufferFull" {
            
            self.videoCacheDone()
            self.playVideo()
        }
    }
    
    
    @objc private func playToEndTime() {
        self.mediaPlayerUpdateState(.comple, nil, nil, nil)
        self.isSeeking = true
        weak var weakSelf = self
        self.seek(toTime: 0) { (result) in
            weakSelf?.isSeeking = false
        }
        self.pauseVideo()
    }
    
    
    @objc private func playError() {
        self.mediaPlayerUpdateState(.error, nil, nil, "video error")
    }
    
    
    @objc private func videoInterrup(sender: NSNotification) {
        let userInfo = sender.userInfo
        if let typeValue: UInt = ((userInfo?[AVAudioSessionInterruptionTypeKey] ?? "") as? UInt)  {
            if let type: AVAudioSession.InterruptionType = AVAudioSession.InterruptionType(rawValue: typeValue) {
                if case .began = type {
                    self.pauseVideo()
                }
            }
        }
    }
    
    
    private func cacheDuration() -> TimeInterval {
        var timeRanges = self.avplayer?.currentItem?.loadedTimeRanges
        if playerType == .avType {
        } else {
            timeRanges = []
        }
        
        let timeRange = timeRanges?.first?.timeRangeValue
        if let range = timeRange {
            let start = CMTimeGetSeconds(range.start);
            let duration = CMTimeGetSeconds(range.duration)
            let result  = start + duration
            return result
        }
        return 0
    }
    
    
    private func videoCanPlay() -> Bool {
        let cacheDur = cacheDuration()
        let currentPlay = currentPlayTime()
        
        
        if cacheDur - 0.5 > currentPlay {
            return true
        }
        return false
    }
    
    
    private func currentPlayTime() -> TimeInterval {
        let timeScale = self.avplayer?.currentTime().timescale
        let timeValue = self.avplayer?.currentTime().value
        let time = (timeValue ?? Int64(Int32(0))) / Int64(timeScale ?? 1)
        return TimeInterval(time)
    }
}


extension A4xMediaPlayerController {
    
    private func initVideoIJKPlayer(videoUrl: URL?, voiceEnable: Bool) {
        
        weak var weakSelf = self
        DispatchQueue.main.async {
            let isDebug = A4xBaseManager.shared.checkIsDebug()
            if isDebug == true {
                IJKFFMoviePlayerController.setLogReport(true)
                IJKFFMoviePlayerController.setLogLevel(k_IJK_LOG_VERBOSE)
            } else {
                IJKFFMoviePlayerController.setLogReport(false)
                IJKFFMoviePlayerController.setLogLevel(k_IJK_LOG_ERROR)
            }
            







            IJKFFMoviePlayerController.checkIfFFmpegVersionMatch(false)
            
            let options = IJKFFOptions.byDefault()
            options?.isLivePlayer = false
            options?.setCodecOptionIntValue(48, forKey: "skip_loop_filter") 
            options?.setCodecOptionValue("0", forKey: "skip_frame")
            options?.setFormatOptionValue("0", forKey: "auto_convert") 
            options?.setPlayerOptionValue("0", forKey: "videotoolbox") 
            options?.setPlayerOptionIntValue(1, forKey: "soundtouch")
            options?.setPlayerOptionIntValue(1, forKey: "reconnect")
            options?.setPlayerOptionIntValue(3, forKey: "framedrop")
            options?.setPlayerOptionIntValue(1, forKey: "enable-accurate-seek")
            options?.setPlayerOptionIntValue(1000, forKey: "accurate-seek-timeout")
            options?.setPlayerOptionValue("fflags", forKey: "fastseek")
            //options?.setPlayerOptionValue("fcc-i420", forKey: "overlay-format")
            
            if let url: URL = videoUrl {
                
                if weakSelf?.ijkPlayer != nil {
                    
                    weakSelf?.stopIJKPLayerTimer()
                    weakSelf?.ijkPlayer?.pause()
                    weakSelf?.ijkPlayer?.stop()
                    weakSelf?.ijkPlayer?.shutdown()
                    weakSelf?.ijkPlayer?.view.removeFromSuperview()
                    weakSelf?.ijkPlayer = nil
                }
                
                
                
                weakSelf?.ijkPlayer = IJKFFMoviePlayerController(contentURL: url, with: options)
                weakSelf?.ijkPlayer?.shouldAutoplay = weakSelf?.isAutoPlay ?? false
                weakSelf?.ijkPlayer?.setPauseInBackground(true)
                weakSelf?.ijkPlayer?.audioEnable = voiceEnable
                weakSelf?.ijkPlayer?.scalingMode = .aspectFit 
                
                weakSelf?.ijkPlayer?.view.frame = weakSelf?.mediaPlayerView?.frame ?? CGRect(x: 0, y: 0, width: 0, height: 0)
                weakSelf?.ijkPlayer?.playbackVolume = 10.0
                weakSelf?.ijkPlayer?.view.backgroundColor = .black
                weakSelf?.mediaPlayerView?.mediaContentView.insertSubview(weakSelf?.ijkPlayer?.view ?? UIView(), at: 0)
                weakSelf?.ijkPlayer?.magicPixEnable = weakSelf?.magicPixEnable ?? false
                
                weakSelf?.ijkPlayer?.videoDelegate = self
                
                
                let oldImgView = weakSelf?.mediaPlayerView?.mediaContentView.getSubViewByTag(tag: 1001)
                if (oldImgView?.count ?? 0) > 0 {
                    oldImgView?[0].removeFromSuperview()
                }
                
                if weakSelf?.isAutoPlay ?? false {
                    weakSelf?.installMovieNotificationObservers()
                }
                weakSelf?.ijkPlayer?.prepareToPlay()
                
                
            }
        }
    }
    
    
    private func installMovieNotificationObservers() {
        

        NotificationCenter.default.addObserver(self, selector: #selector(loadStateDidChange(sender:)), name: NSNotification.Name.IJKMPMoviePlayerLoadStateDidChange, object: self.ijkPlayer)
        NotificationCenter.default.addObserver(self, selector: #selector(moviePlayBackDidFinish(sender:)), name: NSNotification.Name.IJKMPMoviePlayerPlaybackDidFinish, object: self.ijkPlayer)
        NotificationCenter.default.addObserver(self, selector: #selector(mediaIsPreparedToPlayDidChange(sender:)), name: NSNotification.Name.IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: self.ijkPlayer)
        NotificationCenter.default.addObserver(self, selector: #selector(moviePlayBackStateDidChange(sender:)), name: NSNotification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: self.ijkPlayer)
        NotificationCenter.default.addObserver(self, selector: #selector(moviePlayBackStateNaturalSizeChange(sender:)), name: NSNotification.Name.IJKMPMovieNaturalSizeAvailable, object: self.ijkPlayer)
        NotificationCenter.default.addObserver(self, selector: #selector(seekComplete), name: NSNotification.Name.IJKMPMoviePlayerAccurateSeekComplete, object: self.ijkPlayer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didSeekComplete), name: NSNotification.Name.IJKMPMoviePlayerDidSeekComplete, object: self.ijkPlayer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(firstVideoFrameRendered(sender:)), name: NSNotification.Name.IJKMPMoviePlayerFirstVideoFrameRendered, object: self.ijkPlayer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(enterBackGround), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(becomActive), name: UIApplication.didBecomeActiveNotification, object: nil)

    }
    
    
    private func removeIJKMovieNotificationObservers() {
        
        if self.ijkPlayer != nil {
            
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerLoadStateDidChange, object: self.ijkPlayer)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerPlaybackDidFinish, object: self.ijkPlayer)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: self.ijkPlayer)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: self.ijkPlayer)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMovieNaturalSizeAvailable, object: self.ijkPlayer)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerAccurateSeekComplete, object: self.ijkPlayer)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerDidSeekComplete, object: self.ijkPlayer)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.IJKMPMoviePlayerFirstVideoFrameRendered, object: self.ijkPlayer)
            
            NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        }
    }
    
    @objc func seekComplete() {
        
    }
    
    @objc func didSeekComplete() {
        
        self.ijkPlayer?.play()
        
    }
    
    @objc func moviePlayBackStateNaturalSizeChange(sender: Notification) {
        
    }
    
    
    @objc func firstVideoFrameRendered(sender: Notification) {
        
        self.mediaPlayerUpdateState(.cache, nil, true, nil)
    }
    
    @objc func loadStateDidChange(sender: Notification) {
        if (self.ijkPlayer?.loadState == IJKMPMovieLoadState.stalled) {
            self.videoIntoCache()
        } else {
            self.videoCacheDone()
        }
    }
    
    @objc func moviePlayBackDidFinish(sender: Notification) {
        
        stopIJKPLayerTimer()
        
        let userinfo = sender.userInfo as? Dictionary<String, Int>
        if ((userinfo?.keys.contains("IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey")) != nil &&
            userinfo?["IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey"] ?? 0 == IJKMPMovieFinishReason.playbackError.rawValue) {
            //self.mediaPlayerUpdateState(.error, nil, nil, userinfo?.toJson())
            self.stopError()
        } else {
            self.mediaPlayerUpdateState(.comple, nil, nil, nil)
        }
        
        
    }
    
    @objc func mediaIsPreparedToPlayDidChange(sender: Notification) {
        
    }
    
    
    @objc func moviePlayBackStateDidChange(sender : Notification) {
        
        if let player = sender.object as? IJKFFMoviePlayerController {
            switch player.playbackState {
            case .stopped:
                
                self.isPlaying = false
                stopIJKPLayerTimer()
                self.videoCacheDone()
                break
            case .playing:
                
                self.isPlaying = true
                startIJKPlayerTimer()
                break
            case .paused:
                
                self.isPlaying = false
                stopIJKPLayerTimer()
                self.videoCacheDone()
                break
            case .interrupted:
                
                self.isPlaying = false
                stopIJKPLayerTimer()
                self.videoCacheDone()
                break
            case .seekingForward, .seekingBackward:
                self.isPlaying = false
                stopIJKPLayerTimer()
                
                break
            }
        }
    }
    
    
    private func startIJKPlayerTimer() {
        
        A4xGCDTimer.shared.scheduledDispatchTimer(withName: "IJKPLAYER_TIMER", timeInterval: 0.4, queue: DispatchQueue.main, repeats: true) { [weak self] in
            self?.updateTimesInfo()
        }
    }
    
    
    private func stopIJKPLayerTimer() {
        
        A4xGCDTimer.shared.destoryTimer(withName: "IJKPLAYER_TIMER")
    }
    
    private func reloadVideoCoverImage() {
        
        if playerType == .ijkType {
            
            let oldImgView = self.mediaPlayerView?.mediaContentView.getSubViewByTag(tag: 1001)
            if (oldImgView?.count ?? 0) > 0 {
                oldImgView?[0].removeFromSuperview()
            }
            
            let imgView = UIImageView()
            imgView.frame = self.mediaPlayerView?.frame ?? CGRect(x: 0, y: 0, width: 0, height: 0)
            imgView.tag = 1001
            imgView.image = self.ijkPlayer?.thumbnailImageAtCurrentTime()
            self.mediaPlayerView?.mediaContentView.insertSubview(imgView, belowSubview: self.ijkPlayer?.view ?? UIView())
        }
    }
}

extension A4xMediaPlayerController: A4xMediaPlayerViewProtocol {
    
    public func magicPixEnableSettingAction(_ enable: Bool) {
        self.magicPixEnable = enable
    }
    
    public func playBtnClickAction(_ selected: Bool) {
        if selected {
            self.pauseVideo()
        } else {
            self.playVideo()
        }
    }
    
    public func seekAction(_ progress: Float) {
        self.seek(progress: progress)
    }
    
}

extension A4xMediaPlayerController: VideoEnhanceDelegate {
    public func didEnhanceVideoFrame(_ width: Int32, h height: Int32, frame: UnsafeMutablePointer<UInt8>!, len length: Int32) {
        
    }
}

