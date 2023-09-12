//


//


//

import Foundation
import UIKit
import SmartDeviceCoreSDK

public enum A4xBaseBatteryUIType {
    case light
    case dark
}

public enum A4xBaseBatteryStateType : Int {
    case `default` = 0
    case charging = 1
    case chargingFull = 2
    
    public func isCharging() -> Bool {
        if self == .default {
            return false
        }
        return true
    }
}

public class A4xBaseBatteryView : UIView {

    public var lowColor        : UIColor =  #colorLiteral(red: 0.9803921569, green: 0.3176470588, blue: 0.3176470588, alpha: 1)
    public var enoughColor     : UIColor =  #colorLiteral(red: 0.3098039216, green: 0.3137254902, blue: 0.3215686275, alpha: 1)
    public var lightEnoughColor     : UIColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    public var chargingColor   : UIColor =  #colorLiteral(red: 0.2705882353, green: 0.8117647059, blue: 0.4156862745, alpha: 1)
    
    public var batterStyle : A4xBaseBatteryUIType = .dark {
        didSet {
            switch batterStyle {
            case .light:
                self.bgView.image = bundleImageFromImageName("device_batter_bg_light")?.rtlImage()
            case .dark:
                self.bgView.image = bundleImageFromImageName("device_batter_bg")?.rtlImage()
            }
            self.layoutIfNeeded()
        }
    }
    
    private var batterleavel : Int = 0
    
    private var lowBatteryWarmLeavel : Int = 10
    
    private var quantityCharge : Bool = false

    private var chargingType : A4xBaseBatteryStateType = .default {
        didSet {
            self.chargingView.isHidden = !chargingType.isCharging()
        }
    }
    
    
    public func setBatterInfo(leavel: Int, isCharging: Int, isOnline: Bool, quantityCharge: Bool, lowBatterWarmLeavel lowBatter: Int = 10) {
        self.batterleavel = leavel
        self.quantityCharge = quantityCharge
        //
        self.alpha = isOnline ? 1 : 0.4
        self.chargingType = A4xBaseBatteryStateType(rawValue: isCharging) ?? .default
        self.lowBatteryWarmLeavel = lowBatter
        self.setNeedsDisplay()
    }
    
    public func setBatterAPInfo(leavel: Int, isCharging: Int, isAPOnline: Bool, quantityCharge: Bool, lowBatterWarmLeavel lowBatter: Int = 10) {
        self.batterleavel = leavel
        self.quantityCharge = quantityCharge
        //
        self.alpha = isAPOnline ? 1 : 0.4
        self.chargingType = A4xBaseBatteryStateType(rawValue: isCharging) ?? .default
        self.lowBatteryWarmLeavel = lowBatter
        self.setNeedsDisplay()
    }
    

    public override var intrinsicContentSize: CGSize {
        return CGSize(width: 22.auto(), height: 14.auto())
    }
    
    override public init(frame : CGRect = CGRect.zero) {
        super.init(frame : frame)
        self.backgroundColor = UIColor.clear
        self.bgView.isHidden = false
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy private var chargingView : UIImageView = {
        let temp = UIImageView()
        temp.contentMode = .scaleAspectFit
        temp.image = bundleImageFromImageName("batter_charging")?.rtlImage()
        self.addSubview(temp)
        return temp
    }()
    
    lazy private var bgView : UIImageView = {
        let temp = UIImageView()
        temp.image = bundleImageFromImageName("device_batter_bg")?.rtlImage()
        self.addSubview(temp)
        return temp
    }()
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        guard let image = self.bgView.image else {
            self.bgView.frame = self.bounds
            return
        }
        let imageSize = image.size
        guard imageSize.height > 0 && imageSize.width > 0 else {
            self.bgView.frame = self.bounds
            return
        }
        let wProportion = imageSize.width / self.frame.width
        let hProportion = imageSize.height / self.frame.height
        let pro = max(wProportion, hProportion)
        let rWidth = imageSize.width / pro
        let rHeight = imageSize.height / pro
        self.bgView.frame = CGRect(x: (self.frame.width - rWidth) / 2, y: (self.frame.height - rHeight) / 2, width: rWidth, height: rHeight)
        
        let maxX = 45.0 / 60.0 * self.bgView.frame.width
        let innserHeight = self.bgView.frame.height * (17.0 / 33.0)
        let margen = (self.bgView.frame.height - innserHeight)/2

        self.chargingView.frame = CGRect(x: self.bgView.frame.minX + margen, y: self.bgView.frame.minY, width: maxX - self.bgView.frame.minX - margen , height: self.bgView.frame.height)

    }
    
    public override func draw(_ rect: CGRect) {
        let innserHeight = self.bgView.frame.height * (17.0 / 33.0)
        
        let margen = (self.bgView.frame.height - innserHeight)/2
        let top = self.bgView.frame.minY + margen
        let left = self.bgView.frame.minX + margen
        let bottom = self.bgView.frame.maxY - margen
        let maxX =  (45.0 / 60.0) * self.bgView.frame.width
        
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.beginPath()
        if self.chargingType.isCharging() {
            if self.chargingType == .chargingFull {
                let beginPath = UIBezierPath(roundedRect: CGRect(x: left, y: top, width: maxX - left , height: bottom - top), cornerRadius: 0)
                ctx?.setFillColor(self.chargingColor.cgColor)
                ctx?.addPath(beginPath.cgPath)
            }else if quantityCharge {
                let batterWidth = (maxX - left) / 100.0 * CGFloat(self.batterleavel)
                let beginPath = UIBezierPath(roundedRect: CGRect(x: left, y: top, width: batterWidth , height: bottom - top), cornerRadius: 0)
                ctx?.setFillColor(self.chargingColor.cgColor)
                ctx?.addPath(beginPath.cgPath)
            }
        }else {

            let batterWidth = (maxX - left) / 100.0 * CGFloat(self.batterleavel)

            let beginPath = UIBezierPath(roundedRect: CGRect(x: left, y: top, width: batterWidth , height: bottom - top), cornerRadius: 0)

            if self.batterleavel > self.lowBatteryWarmLeavel {
                switch batterStyle {
                case .light:
                    ctx?.setFillColor(self.lightEnoughColor.cgColor)
                case .dark:
                    ctx?.setFillColor(self.enoughColor.cgColor)
                }
                
            } else {
                ctx?.setFillColor(self.lowColor.cgColor)
            }
            ctx?.addPath(beginPath.cgPath)

        }
        ctx?.drawPath(using: .fill)
            
    }
    
}
