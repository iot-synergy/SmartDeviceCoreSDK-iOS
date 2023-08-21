
import Foundation
import UIKit
import SnapKit

private class A4xBaseTipViewHandle {
    let block: ((Bool) -> Void)?
    
    init(_ block: ((Bool) -> Void)?) {
        self.block = block
    }
}

var tipKey : String = "tipkey"

public enum A4xBaseLineType {
    case error
    case normail
    case selected
}

public extension UIView {
    
    func hiddenTip(){
        let tipView : UILabel? = self.viewWithTag(1000) as? UILabel
        guard tipView == nil else {
            tipView?.isHidden = true
            return
        }
    }
    
    func addLineStyle(){
        self.clipsToBounds = false
        let tipView : UIView? = self.viewWithTag(1200)
        guard tipView == nil else {
            tipView?.isHidden = false
            return
        }
        let nTipView = UIView();
        nTipView.tag = 1200
        nTipView.alpha = 0.8
        self.addSubview(nTipView)
        updateLineStyle(style: .normail)
        
        nTipView.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.bottom).offset(-5)
            make.width.equalTo(self.snp.width)
            make.leading.equalTo(self.snp.leading)
            make.height.equalTo(1)
        }
    }
    
    func updateLineStyle(style : A4xBaseLineType) {
        let lineView : UIView? = self.viewWithTag(1200)
        guard lineView != nil else {
            return
        }
        switch style {
        case .normail:
            lineView?.backgroundColor = ADTheme.C3.withAlphaComponent(0.3)
        case .selected:
            lineView?.backgroundColor = ADTheme.Theme
            self.hiddenTip()
        case .error:
            lineView?.backgroundColor = ADTheme.E1
        }
    }
}

