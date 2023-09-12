//
//  UITextField+Helper.swift
//  Alamofire
//
//  Created by zhi kuiyu on 2019/7/25.
//

import UIKit
import SmartDeviceCoreSDK

fileprivate var A4xMaxCharNumberKey : String = "A4xMaxCharNumberKey"
fileprivate var A4xMaxCharNumberaKey : String = "A4xMaxCharNumberaKey"
fileprivate var A4xMaxCharcanEmojiKey : String = "A4xMaxCharcanEmojiKey"
fileprivate var A4xDoubleInputKey : String = "A4xDoubleInputKey"

extension UITextField {
    private var maxCharcher : Int {
        set {
            objc_setAssociatedObject(self , &A4xMaxCharNumberKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &A4xMaxCharNumberKey) as? Int) ?? -1
        }
    }
    
    
    /// 禁止双字节输入
    public var  offDoubleByteInput : Bool {
        set {
            objc_setAssociatedObject(self , &A4xDoubleInputKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &A4xDoubleInputKey) as? Bool) ?? false
        }
    }
    
    private var hasAddChange : Bool {
        set {
            objc_setAssociatedObject(self , &A4xMaxCharNumberaKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &A4xMaxCharNumberaKey) as? Bool) ?? false
        }
    }
    
    public var canEmoji : Bool {
          set {
              objc_setAssociatedObject(self , &A4xMaxCharcanEmojiKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
          }
          get {
              return (objc_getAssociatedObject(self, &A4xMaxCharcanEmojiKey) as? Bool) ?? false
          }
      }
    
    public func setMaxTextsCount(maxChar : Int) {
        self.maxCharcher = maxChar
        if !self.hasAddChange {
            NotificationCenter.default.addObserver(self, selector: #selector(textFieldTextChange), name: UITextField.textDidChangeNotification, object: self)
            self.hasAddChange = true
        }
    }
    
    @objc private
    func textFieldTextChange(){
        if !self.canEmoji {
            if self.text?.containsEmoji ?? false {
                self.text = self.text?.noEmojiString
            }
        }

        
        if let selectedRange = self.markedTextRange {
            if let _ = self.position(from: selectedRange.start, offset: 0 ) {
                return
            }
        }
        if self.offDoubleByteInput {
            self.text = self.text?.filterDoubleByte()
        }
        
        guard self.maxCharcher > 0 else {
            return
        }
        if self.text?.cLength ?? 0 >= self.maxCharcher {
            self.text = self.text?.subCLength(length: self.maxCharcher)
            self.layoutIfNeeded()
        }
//        print("self.text \(self) \(String(describing: self.text))")
    }
  
}


extension UITextInput {
    var selectedRange: NSRange? {
        guard let range = selectedTextRange else { return nil }
        let location = offset(from: beginningOfDocument, to: range.start)
        let length = offset(from: range.start, to: range.end)
        return NSRange(location: location, length: length)
    }
}
