//


//


//

import Foundation
import UIKit

public class A4xBaseURLTextView: UITextView, UITextViewDelegate {
    
    public var addLinkBlock: ((_ url : String) -> Void)?
    
    public override var textColor: UIColor? {
        didSet {
        }
    }
    public var linkTextColor : UIColor?  { //= ADTheme.Theme
        didSet {
        }
    }
    
    public override var selectedTextRange: UITextRange? {
        get {
            return nil
        }
        set { }

    }
    
    public override init(frame: CGRect = .zero, textContainer: NSTextContainer? = nil) {
        super.init(frame: frame, textContainer: textContainer)
        self.delegate = self
        self.backgroundColor = UIColor.clear
        self.isEditable = false
        self.delegate = self
        self.dataDetectorTypes = .link
        self.isScrollEnabled = false
        self.textContainer.lineFragmentPadding = 3.auto()
        self.textContainerInset = UIEdgeInsets.zero
        self.setDirectionConfig()
        self.textColor = ADTheme.C2
        self.font = ADTheme.B2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public override var canBecomeFirstResponder: Bool {
          return false
      }
    
    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        switch (action) {
        case #selector(paste(_:)):
            fallthrough
        case #selector(copy(_:)):
            fallthrough
        case #selector(cut(_:)):
            fallthrough
        case #selector(select(_:)):
            fallthrough
        case #selector(selectAll(_:)):
            return false
        default:
            break
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    public func text(text: String, links: (ChildStr: String, LinksURL: String) ... , completion: @escaping (CGFloat) -> Void) {
        
        guard text.count > 0 else {
            self.attributedText = nil
            return
        }
        
        let attrStr = NSMutableAttributedString(string: text)
        attrStr.addAttribute(NSAttributedString.Key.font, value: self.font ?? ADTheme.B2, range: NSRange(location: 0, length: text.count))
        
        attrStr.addAttribute(NSAttributedString.Key.foregroundColor, value: self.textColor ?? ADTheme.C2, range: NSRange(location: 0, length: text.count))
        
        let paragraphStyle:NSMutableParagraphStyle = NSMutableParagraphStyle()
        attrStr.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: text.count))

        paragraphStyle.lineSpacing = 3 //大小调整
        for (childStr, linksURL) in links {
            let range = text.range(of: childStr)
            if range != nil {
                let nsRange = NSRange(range! , in : text)
                //attrStr.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: nsRange)
                attrStr.addAttribute(NSAttributedString.Key.link, value: NSURL(string: linksURL)!, range: nsRange)

            }
        }
        





        
        let linkAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: self.linkTextColor ?? ADTheme.Theme,
        ]
        
        self.attributedText = attrStr
        self.linkTextAttributes = linkAttributes
        completion(self.heightOfAttributedString(attrStr))

    }
    
    
    public func heightOfAttributedString(_ attributedString: NSAttributedString) -> CGFloat {
        let height = attributedString.boundingRect(with: CGSize(width: UIScreen.main.bounds.size.width - 16.auto() * 2, height: CGFloat(MAXFLOAT)), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).height
        return ceil(height)
    }
    
    
    //MARK:-
    @available(iOS 10.0, *)
    public func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
    
    
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if self.addLinkBlock != nil {
            self.addLinkBlock!(URL.absoluteString)
        }
        return false
    }

}
