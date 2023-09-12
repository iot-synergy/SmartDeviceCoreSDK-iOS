//
//  A4xBaseCalendarView.swift
//  AddxAi
//
//  Created by wei jin on 2023/6/8.
//  Copyright © 2023 addx.ai. All rights reserved.
//

import Foundation
import UIKit
import SmartDeviceCoreSDK

public enum HeaderPostion {
    case Left
    case Center
    case Right
}

public typealias A4xBaseCalendarViewClickBlock = (_ type : HeaderPostion , _ show  : Bool) -> Void

public class A4xBaseCalendarView: UIView {
    
    public var headInfoClickBlock: A4xBaseCalendarViewClickBlock? {
        didSet {
            weak var weakSelf = self
            self.infoView.headerShowBlock = {(result ) in
                if weakSelf?.headInfoClickBlock != nil {
                    weakSelf?.headInfoClickBlock?(HeaderPostion.Center,result)
                }
            }
        }
    }
    public var headInfoDoubleClickBlock : (()->Void)? {
        didSet {
            weak var weakSelf = self
            self.infoView.doubleClick = {
                weakSelf?.headInfoDoubleClickBlock?()
            }
        }
    }

    public var leftImage : UIImage? {
        didSet {
            if leftImage == nil {
                self.leftView.isHidden = true
            }else {
                self.leftView.setImage(leftImage, for: UIControl.State.normal)
                self.leftView.isHidden = false
            }
        }
    }
    
    public var rightImage : UIImage? {
        didSet {
            if rightImage == nil {
                self.rightView.isHidden = true
            }else {
                self.rightView.setImage(rightImage, for: UIControl.State.normal)
                self.rightView.isHidden = false
            }
        }
    }

    public var title : String? {
        didSet {
            self.infoView.title = title
        }
    }
    
    public var titleType : HeaderCenterType = .Arrow {
        didSet {
            self.infoView.titleType = self.titleType
        }
    }
    
    public var titleInfoShow : Bool? {
        didSet {
            if let s = titleInfoShow {
                self.infoView.headerShowType = s ? .Show : .Hidden
                self.infoView.updateType(ani : false);
            }
        }
    }
    
    @objc
    public func headerInfoClickActin(sender : UIButton){
        if self.headInfoClickBlock != nil {
            self.headInfoClickBlock!(HeaderPostion.Center,true)
        }
    }
    
    @objc
    public func headerAddClickActin(sender : UIButton){
        self.titleInfoShow = false
        if self.headInfoClickBlock != nil {
            self.headInfoClickBlock!(HeaderPostion.Right,true)
        }
    }
    
    @objc
    public func headerMenuClickActin(sender : UIButton){
        self.titleInfoShow = false
        if self.headInfoClickBlock != nil {
            self.headInfoClickBlock!(HeaderPostion.Left,true)
        }
    }
    
    private lazy var leftView : UIButton = {
        var temp : UIButton = UIButton()
        self.addSubview(temp)
        temp.setImage(bundleImageFromImageName("homepage_head_menus")?.rtlImage(), for: UIControl.State.normal)
        temp.addTarget(self, action: #selector(headerMenuClickActin(sender:)), for: UIControl.Event.touchUpInside)
        temp.imageView?.contentMode = .scaleAspectFit
        temp.snp.makeConstraints({ (make) in
            make.bottom.equalTo(self.snp.bottom)
            make.height.equalTo(44.auto())
            make.width.equalTo(44.auto())
            make.leading.equalTo(0)
        })
        return temp
    }()

     lazy var rightView : UIButton = {
        var temp : UIButton = UIButton()
        self.addSubview(temp)
        temp.setImage(bundleImageFromImageName("homepage_head_add")?.rtlImage(), for: UIControl.State.normal)
        temp.imageView?.contentMode = .scaleAspectFit
        temp.addTarget(self, action: #selector(headerAddClickActin(sender:)), for: UIControl.Event.touchUpInside)
        temp.snp.makeConstraints({ (make) in
            make.bottom.equalTo(self.snp.bottom)
            make.height.equalTo(44.auto())
            make.width.equalTo(44.auto())
            make.trailing.equalTo(self.snp.trailing)
        })
        return temp
    }()

    public lazy var infoView: A4xHomeBaseHeaderUIControl = {
        var temp: A4xHomeBaseHeaderUIControl = A4xHomeBaseHeaderUIControl()
        self.addSubview(temp)
        
        temp.snp.makeConstraints({ (make) in
            make.bottom.equalTo(self.snp.bottom)
            make.height.equalTo(44.auto())
            make.width.lessThanOrEqualTo(self.snp.width).offset(88)
            make.centerX.equalTo(self.snp.centerX)
        })
        return temp
    }()

    public convenience init(){
        self.init(frame: CGRect.zero)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.infoView.isHidden = false
        
       
    }
  
    deinit {
        
    }
 
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
