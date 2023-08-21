//


//


//

import UIKit
import Foundation
import SmartDeviceCoreSDK

public extension UILabel {
    
    private func indexOfAttributedTextCharacterAtPoint(point: CGPoint) -> Int {
        assert(self.attributedText != nil, "This method is developed for attributed string")
        let textStorage = NSTextStorage(attributedString: self.attributedText!)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: self.frame.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = self.numberOfLines
        textContainer.lineBreakMode = self.lineBreakMode
        layoutManager.addTextContainer(textContainer)

        let index = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return index
    }
    
    func subStringStyle (clickText : String , attributed : [NSAttributedString.Key : Any]? , onClickBlock block : ( ()->Void)? = nil) {

        var attrString : NSMutableAttributedString
        if self.attributedText == nil {
            assert(self.text != nil , "label 字符为空，不能添加点击")
            attrString =
                NSMutableAttributedString(string: self.text!,
                                               attributes: [
                                                NSAttributedString.Key.font: self.font,
                                                NSAttributedString.Key.foregroundColor: self.textColor
                ])
        } else {
            attrString = NSMutableAttributedString(attributedString: self.attributedText!)
        }
        
        let ranges = attrString.string.ranges(of: clickText)
        if let att = attributed {
            ranges.forEach { (range) in
                attrString.addAttributes(att, range: range)
            }
        }
        self.attributedText = attrString
        
        guard let compleBlock = block else {
            return
        }
        
        assert(ranges.count > 0 , "lable 文案 \(attrString.string) ---> 未匹配到 \(clickText)")
        let gresture = self.loadA4xLinkTapGesture()
        gresture?.addNewClick(checkString: clickText, block: { [weak self] (key , location) in
            guard key == clickText else {
                return
            }
            if let ranges = self?.attributedText?.string.ranges(of: key) {
                if let index = self?.indexOfAttributedTextCharacterAtPoint(point: location) {
                    if self?.inranges(ranges: ranges, index: index) ?? false {
                        compleBlock()
                    }
                }
            }

        })
    }
    
    private func loadA4xLinkTapGesture() -> A4xBaseUITapGestureRecognizer?{
        var tempGrsture : A4xBaseUITapGestureRecognizer? = nil
        self.gestureRecognizers?.forEach({ (gesture) in
            if let temp = gesture as? A4xBaseUITapGestureRecognizer {
                tempGrsture = temp
            }
        })
        if tempGrsture == nil {
            tempGrsture = A4xBaseUITapGestureRecognizer()
            self.addGestureRecognizer(tempGrsture!)
        }
        self.isUserInteractionEnabled = true
        return tempGrsture!
    }
    
    private func inranges(ranges : [NSRange] , index : Int) -> Bool {
        for range in ranges {
            if index >= range.location && index < range.location + range.length {
                return true
            }
        }
        return false
    }

    
    //根据宽度动态计算高度(old)
    func getLabelHeight(_ text: NSAttributedString, width: CGFloat) -> CGFloat {
        let contentHeight = text.boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: [.usesLineFragmentOrigin], context: nil).height
        return contentHeight
    }
    
    
    func getLabelHeight(_ label: UILabel, width: CGFloat) -> CGFloat {
        return label.sizeThatFits(CGSize(width:width, height: CGFloat(MAXFLOAT))).height
    }
    
    //根据高度动态计算宽度(old)
    func getLabelWidth(_ text: NSAttributedString, height: CGFloat) -> CGFloat {
        let contentWidth = text.boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: height), options: [.usesLineFragmentOrigin], context: nil).width
        return contentWidth
    }
    
    //根据高度动态计算宽度(new)
    func getLabelWidth(_ label: UILabel, height: CGFloat) -> CGFloat {
        return label.sizeThatFits(CGSize(width:CGFloat(MAXFLOAT), height: height)).width
    }
}


extension UILabel { 
    
    public class func setRtlDirection() {
        self.rtl_MethodSwizzling(fromMethod: #selector(setter: UILabel.textAlignment), toMethod: #selector(rtl_setTextAlignment(textAlignment:)))
    }
    
    class func rtl_MethodSwizzling(fromMethod: Selector, toMethod: Selector) {
        guard let method1 = class_getInstanceMethod(self, fromMethod) else { return }
        guard let method2 = class_getInstanceMethod(self, toMethod) else { return }
        method_exchangeImplementations(method1, method2)
    }
    
    @objc func rtl_setTextAlignment(textAlignment: NSTextAlignment) {
        var alignment = textAlignment
        if A4xBaseAppLanguageType.language() == .hebrew || A4xBaseAppLanguageType.language() == .arab {
            if textAlignment == .natural || textAlignment == .left {
                alignment = .right
            } else if textAlignment == .right {
                alignment = .left
            }
        }
        self.rtl_setTextAlignment(textAlignment: alignment)
    }
}
