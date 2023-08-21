//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xLiveSpeakImageView : UIButton ,UIGestureRecognizerDelegate {
    override var isUserInteractionEnabled: Bool {
        didSet {
            self.gestureRecognizers?.forEach({ (re) in
                re.isEnabled = false
                re.isEnabled = true
            })
        }
    }
    
    var touchAction : ((LiveSpeakActionEnum)->Void)?
    var defaultIconColor : UIColor = ADTheme.C6
    var generator : UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle.light)



    convenience init(){
        self.init(frame: CGRect.zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = UIColor.clear
        

        
        let oneTap = UITapGestureRecognizer(target: self, action:#selector(oneClick(sender:)))
        self.addGestureRecognizer(oneTap)
        oneTap.numberOfTapsRequired = 1
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longTap(sender:)))
        longPress.minimumPressDuration = 0.2
        longPress.delegate = self
        self.addGestureRecognizer(longPress)

        oneTap.require(toFail:longPress )
    }
   
    @objc private
    func oneClick(sender : UITapGestureRecognizer){
        touchAction?(.tap)
        generator.prepare()
        generator.impactOccurred()
    }
    
    @objc private
    func longTap(sender : UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:


            touchAction?(.down)
            generator.prepare()
            generator.impactOccurred()
        case .failed:
            fallthrough
        case .cancelled:
            fallthrough
        case .ended:
            touchAction?(.up)


        default:
            break
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}

