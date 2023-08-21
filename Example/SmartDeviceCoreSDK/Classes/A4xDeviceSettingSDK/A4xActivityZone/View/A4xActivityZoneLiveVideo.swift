//


//


//

import UIKit
import SmartDeviceCoreSDK

class A4xActivityZoneLiveVideo : UIView {
    weak var `protocol` : A4xActivityZoneVideoControlProtocol? {
        didSet {
            self.videoControlView.protocol = self.protocol
        }
    }
    
    var rectlist : [ZoneBean]? {
        didSet {
           self.videoControlView.rectlist = rectlist
        }
    }

    var videoState: (Int, String?)? {
        didSet {
            self.videoControlView.videoState = videoState ?? (A4xPlayerStateType.paused.rawValue, nil)
        }
    }
    
    weak var videoView : UIView? {
        didSet {
            self.videoControlView.videoNewView.playerView = videoView
        }
    }
    
    var deviceId: String? {
        didSet {
            
        }
    }
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var videoControlView : A4xActivityZoneVideoControl = {
        let temp = A4xActivityZoneVideoControl()
        temp.backgroundColor = UIColor.clear
        self.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.edges.equalTo(self.snp.edges)
        })
        return temp
    }()
    

}


