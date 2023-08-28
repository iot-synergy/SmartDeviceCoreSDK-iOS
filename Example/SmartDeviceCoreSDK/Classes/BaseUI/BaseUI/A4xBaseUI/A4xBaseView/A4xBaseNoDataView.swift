//
//  A4xBaseNoDataView.swift
//  AddxAi
//
//  Created by zhi kuiyu on 2019/4/11.
//  Copyright © 2019 addx.ai. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import SmartDeviceCoreSDK

// 普通样式、带大绿色按钮样式
public enum A4xBaseNoDataType {
    case normal
    case retry
}

// 特殊标记 - 可随时新增
public enum A4xBaseNoDataSpecialType {
    case none
    case sd
    case explore // 探索模块
    case alexa // 探索模块
}

public struct A4xBaseNoDataValueModel {
    public var error: String?
    public var image: UIImage?
    public var retry: Bool = true
    public var retryAction: (()->Void)?
    public var nodata: Bool = false
    public var retryTitle: String?
    public var noDataType: A4xBaseNoDataType?
    public var specialState: A4xBaseNoDataSpecialType?
    public init() {
        
    }
    
    public static func error(error: String?, comple : @escaping ()->Void ) -> A4xBaseNoDataValueModel {
        var noDataError = A4xBaseNoDataValueModel()
        noDataError.error = error
        noDataError.image = bundleImageFromImageName("failed_get_inform")?.rtlImage()
        noDataError.retry = true
        noDataError.retryAction = comple
        noDataError.noDataType = .normal
        return noDataError
    }

    public static func noData(error: String?,
                             image: UIImage?,
                             retry: Bool,
                             retryTitle: String? = nil,
                             noDataType: A4xBaseNoDataType?,
                             specialState: A4xBaseNoDataSpecialType?,
                             comple: @escaping ()->Void ) -> A4xBaseNoDataValueModel {
        var noDataError = A4xBaseNoDataValueModel()
        noDataError.error = error
        noDataError.image = image
        noDataError.retry = retry
        noDataError.retryAction = comple
        noDataError.retryTitle = retryTitle
        noDataError.noDataType = noDataType
        noDataError.specialState = specialState
        return noDataError
    }
}

public protocol A4xBaseNoDataViewDelegate: AnyObject {
    func a4xBaseNoDataViewTipToKnowButtonDidClicked()
}

public class A4xBaseNoDataView: UIView {
    
    public weak var delegate : A4xBaseNoDataViewDelegate?
    
    public var noDataStyle: A4xBaseNoDataType?
    public var isShreSD: Bool
    public var nodataValue: A4xBaseNoDataValueModel {
        didSet {
            self.updateData()
        }
    }
    public var imageMaxSize: Float = 189.auto()
    
    public var isShareAdmin: Bool?

    public init(frame: CGRect = .zero, value: A4xBaseNoDataValueModel = A4xBaseNoDataValueModel(), maxSize : Float = 189.auto() , isShreSD: Bool) {
        // 获取外部赋值
        self.nodataValue = value
        self.isShreSD = isShreSD
        super.init(frame: frame)
        self.imageV.isHidden = false
        self.tipLabel.isHidden = false
        self.tipToKnowButton.isHidden = true
        self.imageMaxSize = maxSize
        self.noDataStyle = self.nodataValue.noDataType
        
        if self.noDataStyle == .retry {
            self.retryButton.isHidden = false
        } else {
            // normal
            self.retryButton.setAttributedTitle (
                self.buttonTitle(A4xBaseManager.shared.getLocalString(key: "please_retry")),
                for: .normal)
        }
        
        self.updateData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updateData() {
        // 无网络判断
        if A4xUserDataHandle.Handle?.netConnectType == .nonet {
            self.tipLabel.text = self.nodataValue.error
            //self.tipLabel.text = self.noDataStyle == .retry ? A4xBaseManager.shared.getLocalString(key: "phone_no_net") : A4xBaseManager.shared.getLocalString(key: "error_no_net")
            
            var img: UIImage = bundleImageFromImageName("no_wifi_connet_tip")?.rtlImage() ?? UIImage()
            if self.nodataValue.specialState == .sd {
                img = bundleImageFromImageName("sd_play_no_net")?.rtlImage() ?? UIImage()
            } else if self.nodataValue.specialState == .explore {
                self.tipLabel.text = A4xBaseManager.shared.getLocalString(key: "connect_sever_timeout")
                img = bundleImageFromImageName("explore_loading_error")?.rtlImage() ?? UIImage()
                imageMaxSize = 126.auto()
            }
            
            self.imageV.image = img
        } else {
            
            let showRetry = self.nodataValue.retry
            
            if let errorStr = self.nodataValue.error {
                logDebug("展示的errorStr: \(errorStr)")
                if errorStr == A4xBaseManager.shared.getLocalString(key: "not_support_vehicle_marking") {
                    /// "点击了解详情 >>"
                    let tips = A4xBaseManager.shared.getLocalString(key: "tap_to_know")
                    let rangesTemp = errorStr.ranges(of: tips)
                    let rangeTemp = rangesTemp.getIndex(0)
                    // 删除"点击了解详情 >>"文字
                    let errorLabelString = NSMutableString.init(string: errorStr)
                    errorLabelString.deleteCharacters(in: NSRange.init(location: rangeTemp?.location ?? 0, length: rangeTemp?.length ?? 0))
                    self.tipLabel.text = errorLabelString as String
                    ///
                    let buttonAttr = NSMutableAttributedString.init(string: tips)
                    let attr: [NSAttributedString.Key : Any] = [.foregroundColor: UIColor.hex(0x316BD8),.underlineStyle: NSUnderlineStyle.single.rawValue,.underlineColor: UIColor.hex(0x316BD8)]
                    buttonAttr.addAttributes(attr, range: NSRange.init(location: 0, length: buttonAttr.length))
                    self.tipToKnowButton.isHidden = false
                    self.tipToKnowButton.setAttributedTitle(buttonAttr, for: .normal)
                } else {
                    self.tipLabel.text = errorStr
                }
            }
            
            if let nodataImage = self.nodataValue.image {
                self.imageV.image = nodataImage
            } else {
                self.imageV.image = bundleImageFromImageName("failed_get_inform")?.rtlImage()
            }
        
            if isShareAdmin ?? false { // 管理者
                self.retryButton.isHidden = !showRetry
            } else {
                if isShreSD { // 不是管理者
                    self.retryButton.isHidden = showRetry
                } else { // 是管理者
                    self.retryButton.isHidden = !showRetry
                }
            }
           // self.retryButton.isHidden = !showRetry
        }
        
        let retryTitle : String? = self.nodataValue.retryTitle == nil ?
            (self.noDataStyle == .retry
                ? ( self.nodataValue.specialState == .alexa
                        ? A4xBaseManager.shared.getLocalString(key: "help_center") :
                        A4xBaseManager.shared.getLocalString(key: "reconnect") )
                : A4xBaseManager.shared.getLocalString(key: "please_retry") )
            : self.nodataValue.retryTitle
        if self.noDataStyle == .retry {
            self.retryButton.setTitle(retryTitle, for: .normal)
        } else {
            self.retryButton.setAttributedTitle(
                              self.buttonTitle(retryTitle),
                              for: .normal)
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        var imageWidth: CGFloat = 0
        var imageHeight: CGFloat = 0
       
//        let padding : CGFloat = 15

        let tipSize = self.tipLabel.sizeThatFits(CGSize(width: self.width - 30.auto(), height: 100))
        let tipSize_Button = self.tipLabel.sizeThatFits(CGSize(width: self.width - 30.auto(), height: 100))
        let butSize = self.noDataStyle == .retry ? CGSize(width: 214.auto(), height: 50.auto()) :  self.retryButton.sizeThatFits(CGSize(width: self.width - 70, height: 100))

        imageWidth = CGFloat(imageMaxSize)//min(CGFloat(self.imageMaxSize), self.width - padding * 2)
        imageHeight = CGFloat(imageMaxSize) //min(CGFloat(self.imageMaxSize), self.height - padding * 2 - tipSize.height - butSize.height )
        self.imageV.frame = CGRect(x: (self.width - imageWidth) / 2, y: (self.height - imageHeight)/2 - 30.auto(), width: imageWidth, height: imageHeight)
        
        
//        let scale = 1//imageHeight / imageHeight
        
        self.tipLabel.frame = CGRect(x: (self.width - tipSize.width) / 2, y: self.imageV.frame.maxY + 10 , width: tipSize.width, height: tipSize.height)
        self.tipToKnowButton.frame = CGRect(x: (self.width - tipSize.width) / 2, y: self.imageV.frame.maxY + 50 , width: tipSize.width, height: 40)
        
        self.retryButton.frame = self.noDataStyle == .retry ? CGRect(x: (self.width - butSize.width) / 2, y: self.tipLabel.frame.maxY + 20.auto(), width: butSize.width, height: butSize.height): CGRect(x: (self.width - butSize.width)/2 - 10, y: self.tipLabel.frame.maxY + 4, width: butSize.width + 20, height: butSize.height)
    }
    
    private  lazy var imageV: UIImageView = {
        let temp = UIImageView()
        temp.contentMode = .scaleAspectFit
        self.addSubview(temp)
        return temp
    }()
    
    public lazy var tipLabel: UILabel = {
        let temp = UILabel()
        temp.textColor = ADTheme.C4
        temp.font = ADTheme.B2
        temp.textAlignment = .center
        temp.setContentHuggingPriority(.required, for: .vertical)
        temp.lineBreakMode = .byWordWrapping
        temp.numberOfLines = 0
        self.addSubview(temp)
        return temp
    }()
    
    lazy var tipToKnowButton: UIButton = {
        let temp = UIButton()
        temp.setTitleColor(UIColor.hex(hex: 0x316BD8), for: .normal)
        temp.titleLabel?.font = ADTheme.B2
        temp.addTarget(self, action: #selector(tipToKnowButtonDidClicked), for: .touchUpInside)
        self.addSubview(temp)
        return temp
    }()
    
    @objc func tipToKnowButtonDidClicked()
    {
        /// 实现方法
        if self.delegate != nil {
            self.delegate?.a4xBaseNoDataViewTipToKnowButtonDidClicked()
        }
    }
    
    private lazy var retryButton: UIButton = {
        let temp = UIButton()
        temp.addTarget(self, action: #selector(retryAction), for: .touchUpInside)
        if self.noDataStyle == .retry  {
            temp.titleLabel?.font = UIFont.regular(16)
            temp.titleLabel?.numberOfLines = 0
            temp.titleLabel?.textAlignment = .center
            
            temp.setTitle(A4xBaseManager.shared.getLocalString(key: "next"), for: .normal)
            temp.setTitleColor(UIColor.white, for: .normal)
            temp.setTitleColor(ADTheme.C4, for: .disabled)
            
            let image = temp.currentBackgroundImage
            temp.setBackgroundImage(UIImage.buttonNormallImage , for: .normal)
            let pressColor = image?.multiplyColor(image?.mostColor ?? ADTheme.Theme, by: 0.9)
            temp.setBackgroundImage(UIImage.init(color: pressColor ?? ADTheme.Theme), for: .highlighted)
            temp.setBackgroundImage(UIImage.init(color: ADTheme.C5), for: .disabled)
            temp.layer.cornerRadius = 25.auto()
            temp.clipsToBounds = true
            
            temp.isEnabled = true
        } else {
            temp.setTitleColor(ADTheme.Theme , for: .normal)
            temp.titleLabel?.font = ADTheme.B2
        }
        
        self.addSubview(temp)
        return temp
    }()
    
    private func buttonTitle(_ title : String?) -> NSAttributedString? {
        guard let bTitle = title else {
            return nil
        }
        let attributes: [NSAttributedString.Key : Any] = [
            .foregroundColor: ADTheme.Theme,
            .underlineColor: ADTheme.Theme,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .font : ADTheme.B2
        ]
        let attrString = NSAttributedString(string: bTitle, attributes: attributes)
        return attrString
    }
    
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if self.retryButton.frame.contains(point) {
            return true
        }
        if self.tipToKnowButton.frame.contains(point)
        {
            return true
        }
        return false
    }
    
    @objc private func retryAction() {
        self.nodataValue.retryAction?()
    }
}

public extension UIView {
    static let noDataTag: Int = "tag".hashValue + 11
    
    // 无数据处理UI - 是不是管理者
    func showNoDataView(value: A4xBaseNoDataValueModel, isShareAdmin: Bool ) -> A4xBaseNoDataView? {
        let temp = self
        let noDataView = createNoDataView(frame: temp.bounds, value: value , isShareAdmin: isShareAdmin)
        noDataView.snp.makeConstraints { (make) in
            make.width.equalTo(temp.snp.width)
            make.centerY.equalTo(temp.snp.centerY).offset(-6)
            make.centerX.equalTo(temp.snp.centerX)
            make.bottom.equalTo(temp.snp.bottom)
        }
        noDataView.updateData()
        return noDataView
    }
    
    private func createNoDataView(frame : CGRect = .zero ,value : A4xBaseNoDataValueModel , isShareAdmin: Bool , _ isShreSD: Bool = true ) -> A4xBaseNoDataView {
        hiddNoDataView()
        let noDataView = A4xBaseNoDataView(frame: frame, value: value , isShreSD: isShreSD )
        noDataView.tag = UIView.noDataTag
        noDataView.isShareAdmin = isShareAdmin
        
        self.addSubview(noDataView)
        return noDataView
    }

    private func createNoDataView(bounds : CGRect = .zero ,value : A4xBaseNoDataValueModel) -> A4xBaseNoDataView {
        hiddNoDataView()
        let noDataView = A4xBaseNoDataView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height), value: value , isShreSD:false )
        noDataView.tag = UIView.noDataTag
        self.addSubview(noDataView)
        return noDataView
    }
    
    func updateAlertViewInfo() {
        guard let nodata : A4xBaseNoDataView = self.viewWithTag(UIView.noDataTag) as? A4xBaseNoDataView else {
            return
        }
        nodata.updateData()
    }

    var nodateView : A4xBaseNoDataView? {
        return self.viewWithTag(UIView.noDataTag) as? A4xBaseNoDataView
    }
    
    // 无数据处理UI
    func showNoDataView(value: A4xBaseNoDataValueModel) -> A4xBaseNoDataView? {
        let temp = self
        let noDataView = createNoDataView(bounds: temp.bounds, value: value)
        noDataView.snp.makeConstraints { (make) in
            make.width.equalTo(temp.snp.width)
            make.centerY.equalTo(temp.snp.centerY).offset(-6)
            make.centerX.equalTo(temp.snp.centerX)
            make.bottom.equalTo(temp.snp.bottom)
        }
        noDataView.updateData()
        return noDataView
    }
    
    func hiddNoDataView() {
        let oldView = self.viewWithTag(UIView.noDataTag)
        if oldView != nil {
            oldView?.removeFromSuperview()
        }
    }
}


public extension UITableView {
    func adReloadData(error: String?, noDataTip: String?, noDataImage: UIImage?, noDataRetry: Bool, noDataType: A4xBaseNoDataType?, comple: @escaping ()-> Void ){
        onMainThread {
            var rowCount : Int = 0
            for session in (0..<self.numberOfSections){
                rowCount += self.numberOfRows(inSection: session)
            }
            if rowCount > 0 {
                self.hiddNoDataView()
            }else {
                var errorValue : A4xBaseNoDataValueModel?
                if error != nil {
                    errorValue = A4xBaseNoDataValueModel.error(error: error, comple: comple)
                } else {
                    errorValue = A4xBaseNoDataValueModel.noData(error: noDataTip, image: noDataImage, retry: noDataRetry, noDataType: noDataType, specialState: A4xBaseNoDataSpecialType.none, comple: comple)
                }
                self.showNoDataView(value: errorValue! )
            }
        }
    }
    
    func fetchNoDataView() -> A4xBaseNoDataView? {
        return self.viewWithTag(UIView.noDataTag) as? A4xBaseNoDataView
    }
}

public extension UICollectionView {
    func fetchNoDataView() -> A4xBaseNoDataView? {
        return self.viewWithTag(UIView.noDataTag) as? A4xBaseNoDataView
    }
}

public extension UIView {
    func adReloadData(error: String?, noDataTip: String?, noDataImage: UIImage?, showRetry: Bool = true, noDataType: A4xBaseNoDataType?, comple: @escaping ()-> Void ) {
        var errorValue: A4xBaseNoDataValueModel?
        if error != nil {
            errorValue = A4xBaseNoDataValueModel.error(error: error, comple: comple)
        } else {
            errorValue = A4xBaseNoDataValueModel.noData(error: noDataTip, image: noDataImage, retry: showRetry, noDataType: noDataType, specialState: A4xBaseNoDataSpecialType.none, comple: comple)
        }
        let _ = self.showNoDataView(value: errorValue!)
    }
}
