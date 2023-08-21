//


//


//

import UIKit
import SmartDeviceCoreSDK

public enum A4xBaseActionSheetStyleEnum {
    case pickerView
    case tableView
}

public enum A4xBaseActionSheetType {
    case cancle(_ title: String?, _ cancelBlock: (()->Void)? )
    case done(_ title: String?, _ doneBlock: ((Int)->Void)? )
    case close(_ closeBlock: (()->Void)?)
    case dataSource(_ dataSource: [(String, String, [String : Any])], _ defaultSelect: Int, style: A4xBaseActionSheetStyleEnum)
    //
    case title(_ title: String?)
    case ok(_ title: String?, _ okBlock: (((Int, Int))->Void)? )
    case dataTimeSource(_ dataTimeSource: ([String], [String]), _ defaultSelect: (Int, Int))
}

@available(iOS 6.0, *)
public enum A4xBaseTitleAlignment: Int, @unchecked Sendable {
    
    case left = 0 
    
    case center = 1 

    case right = 2 
    
    case justified = 3 

    case natural = 4 
}

public struct A4xBaseActionsheetConfig {

    static let CornerRadius: CGFloat          = 8
    static let ButtonHeight: CGFloat          = 36
    static let ButtonWidth: CGFloat           = 80
    static let BackgroundAlpha: CGFloat       = 0.3
    static let SheetHeight: CGFloat           = 164
    static let Duration: CGFloat              = 0.3
    static let RowHeight : CGFloat            = 40

    public var cornerRadius: CGFloat          = A4xBaseActionsheetConfig.CornerRadius
    public var buttonHeight: CGFloat          = A4xBaseActionsheetConfig.ButtonHeight
    public var buttonWidth : CGFloat          = A4xBaseActionsheetConfig.ButtonWidth
    public var backgroundAlpha: CGFloat       = A4xBaseActionsheetConfig.BackgroundAlpha
    public var sheetHeight: CGFloat           = A4xBaseActionsheetConfig.SheetHeight
    public var duration:CGFloat               = A4xBaseActionsheetConfig.Duration
    public var rowHeight:CGFloat               = A4xBaseActionsheetConfig.RowHeight

    public var initialSpringVelocity:CGFloat  = 0.5
    public var damping:CGFloat                = 0.8
    
    
    public var buttonFont: UIFont            = ADTheme.B1
    public var rowTextFont: UIFont           = ADTheme.B1

    
    public var cancelTextColor: UIColor = ADTheme.Theme
    public var doneTitleColor: UIColor  = ADTheme.Theme
    public var rowTextColor: UIColor  = UIColor(red: 51.0/255.0, green:51.0/255.0 , blue:51.0/255.0, alpha:1.0)
    
    
    public var titleAlignment: A4xBaseTitleAlignment = .center
    
    
    public var cancelButtonHidden: Bool = false
    
    
    public var doneButtonHidden: Bool = false

    public init(){
        
    }
}


public class A4xBaseActionsheetView: UIViewController {
    public typealias KYTouchHandler = (A4xBaseActionsheetView) -> ()
    private var config: A4xBaseActionsheetConfig = A4xBaseActionsheetConfig()
    var currentRow: Int = 0
    private var dataSource : [(String, String, [String : Any])]?
    private var style: A4xBaseActionSheetStyleEnum?
    private var outHiddenBlock : (()->Void)?
    private var cancleBlock : (()->Void)?
    private var doneBlock : ((Int)->Void)?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public init(config: A4xBaseActionsheetConfig = A4xBaseActionsheetConfig(), cancleItem: A4xBaseActionSheetType?, doneItem: A4xBaseActionSheetType?, outHidden: A4xBaseActionSheetType?, select: A4xBaseActionSheetType?) {
        super.init(nibName: nil, bundle: nil)
        
        if viewNotReady() {
            DispatchQueue.main.a4xAfter(0.1) {
                self.loadConfig(config: config, cancleItem: cancleItem, doneItem: doneItem, outHidden: outHidden, select: select)
            }
            return
        }
        
        self.loadConfig(config: config, cancleItem: cancleItem, doneItem: doneItem, outHidden: outHidden, select: select)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate lazy var tapOutsideRecognizer: UITapGestureRecognizer = {
        return UITapGestureRecognizer()
    }()
 
    private lazy var alertBounds: CGRect = {
        let bounds = UIApplication.shared.keyWindow?.bounds ?? CGRect(x: 0, y: 0, width: 375, height: 568)
        return bounds
    }()

    private lazy var backgroundView: UIView = {
        let temp = UIView(frame: self.alertBounds)
        temp.isUserInteractionEnabled = true
        temp.backgroundColor = UIColor.black
        temp.alpha = 0
        self.alertWindow?.insertSubview(temp, belowSubview: alertView)
        temp.addGestureRecognizer(self.tapOutsideRecognizer)
        
        return temp
    }()
    
    private lazy var alertView: A4xBaseCircleView = {
        let width: CGFloat = CGFloat(self.alertWindow?.width ?? 375)
        
        let height: CGFloat = UIApplication.isIPhoneX() == true ? CGFloat(config.sheetHeight) : CGFloat(config.sheetHeight - 10)
        let temp = A4xBaseCircleView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        temp.bgColor = .white//UIColor.colorFromHex("#F6F7F9")
        temp.isUserInteractionEnabled = true
        temp.layer.cornerRadius = CGFloat(config.cornerRadius)
        self.alertWindow?.addSubview(temp)
        
        return temp
    }()
    
    private func viewNotReady() -> Bool {
        return UIApplication.shared.keyWindow == nil
    }
    
    
    private lazy var previousWindow: UIWindow? = {
        return UIApplication.shared.keyWindow
    }()
    
    private lazy var alertWindow: UIWindow? = {
        let window = UIWindow(frame: (UIApplication.shared.delegate?.window??.bounds)!)
        window.windowLevel = UIWindow.Level.alert
        window.backgroundColor = UIColor.clear
        window.rootViewController = self
        
        return window
    }()
    
    private lazy var pickerView: UIPickerView = {
        let width = self.alertWindow?.width ?? 375
        let height = self.alertWindow?.height ?? 800
        let frame = CGRect(x: 0, y: config.buttonHeight, width: width, height: config.sheetHeight - 30)
        let temp = UIPickerView(frame: frame)
        temp.delegate = self
        temp.dataSource = self
        self.alertView.addSubview(temp)
        return temp
    }()
    
    private lazy var tableView: UITableView = {
        let width = self.alertWindow?.width ?? 375
        let height = self.alertWindow?.height ?? 800
        let frame = CGRect(x: 0, y: 0, width: width, height: 56.auto())
        let temp = UITableView(frame: frame)
        temp.delegate = self
        temp.dataSource = self
        temp.backgroundColor = .clear
        temp.separatorStyle = .none
        temp.rowHeight = UITableView.automaticDimension
        self.alertView.addSubview(temp)
        return temp
    }()
    
    private lazy var lineView: UIView = {
        let temp = UIView()
        temp.backgroundColor = UIColor.hex(hex: 0xF6F7F9)
        self.alertView.addSubview(temp)
        return temp
    }()
    
    private lazy var doneView: UIButton = {
        let temp = UIButton()
        temp.titleLabel?.font = config.buttonFont
        temp.contentHorizontalAlignment = .right
        temp.setTitleColor(config.doneTitleColor, for: .normal)
        temp.addTarget(self, action: #selector(doneButtonAction), for: .touchUpInside)
        self.alertView.addSubview(temp)
        return temp
    }()
    
    private lazy var cancleBtn: UIButton = {
        let temp = UIButton()
        temp.contentHorizontalAlignment = .left
        temp.titleLabel?.font = config.buttonFont
        temp.setTitleColor(config.cancelTextColor, for: .normal)
        temp.addTarget(self, action: #selector(cancleButtonAction), for: .touchUpInside)
        self.alertView.addSubview(temp)
        return temp
    }()
    
    override public func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        self.view.layoutSubviews()
        self.view.setNeedsDisplay()
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
    
    public override func loadView() {
        super.loadView()
        self.view = nil
    }
    
    private func loadConfig(config: A4xBaseActionsheetConfig,  cancleItem: A4xBaseActionSheetType?, doneItem: A4xBaseActionSheetType?, outHidden: A4xBaseActionSheetType?, select: A4xBaseActionSheetType?) {
        self.config = config
        if case let .cancle(title, block)? = cancleItem {
            if title != nil {
                self.cancleBtn.setTitle(title, for: .normal)
                self.cancleBlock = block
            } else {
                self.cancleBlock = nil
            }
        }
        
        if case let .done(title, block)? = doneItem {
            if title != nil {
                self.doneView.setTitle(title, for: .normal)
                self.doneBlock = block
            } else {
                self.doneBlock = nil
            }
        }
        
        if case let .close(block)? = outHidden {
            if block != nil {
                self.outHiddenBlock = block
                self.tapOutsideRecognizer.addTarget(self, action: #selector(outSiteAction))
            } else {
                self.outHiddenBlock = nil
            }
        }
        
        var defIndex = 0
        
        if case let .dataSource(dataSource, defaultSelect, style)? = select {
            self.dataSource = dataSource
            self.style = style
            defIndex = defaultSelect
        }
        
        self.previousWindow?.isHidden = false
        
        
        loadViewData(defaultIndex: defIndex)
    }
}


extension A4xBaseActionsheetView {
    private func loadViewData(defaultIndex : Int = 0 ) {
        
        self.currentRow = defaultIndex

        let width = self.alertWindow?.width ?? 375
        _ = self.alertWindow?.height ?? 800

        self.alertView.radio = config.cornerRadius.toFloat
        self.alertView.radioType = [.topLeft, .topRight]
        
        
        if self.style == .pickerView {
            self.cancleBtn.frame = CGRect(x: 10.auto(), y: 0, width: (width - 50) / 2, height: config.buttonHeight)
            self.cancleBtn.resetFrameToFitRTL()
            self.doneView.frame = CGRect(x: width - (width - 50) / 2 - 10.auto(), y: 0, width: (width - 50) / 2, height: config.buttonHeight)
            self.doneView.resetFrameToFitRTL()
            self.pickerView.frame = CGRect(x: 0, y: config.buttonHeight, width: width, height: config.sheetHeight - 30)
            self.pickerView.contentMode = .center
            self.pickerView.reloadAllComponents()
            self.pickerView.selectRow(defaultIndex, inComponent: 0, animated: true)
        } else { 
            
            let height = config.cancelButtonHidden ? (config.sheetHeight + 20.auto()) : config.sheetHeight - 56.auto() - 20.auto()
            
            self.cancleBtn.frame = CGRect(x: 0, y: height + 9.5.auto(), width: width, height: 56.auto())
            
            self.cancleBtn.setTitleColor(ADTheme.C3, for: .normal)
            self.cancleBtn.backgroundColor = .white
            self.cancleBtn.contentHorizontalAlignment = .center
            self.cancleBtn.isHidden = config.cancelButtonHidden
            
            self.tableView.frame = CGRect(x: 0, y: 0, width: width, height: height)
            
            self.lineView.frame = CGRect(x: 0, y: height, width: width, height: 10.auto())
            self.lineView.isHidden = config.cancelButtonHidden
            
            self.tableView.reloadData()
            self.tableView.selectRow(at: IndexPath(row: defaultIndex, section: 0), animated: false, scrollPosition: .none)
            
        }
    }
    
    public func show() {
        if config.duration < 0.1 {
            config.duration = 0.3
        }
        showWithDuration(Double(config.duration))
    }
    
    public func dismissAlertView() {
        if config.duration < 0.1 {
            config.duration = 0.3
        }
        dismissWithDuration(0.3)
    }
    
    public func showWithDuration(_ duration: Double) {
        if viewNotReady() {
            return
        }
        
        if config.damping <= 0{
            config.damping = 0.1
        } else if config.damping >= 1 {
            config.damping = 1
        }
        
        if config.initialSpringVelocity <= 0 {
            config.initialSpringVelocity = 0.1
        } else if config.initialSpringVelocity >= 1 {
            config.initialSpringVelocity = 1
        }
        
        self.alertWindow?.makeKeyAndVisible()
        
        let width = self.alertWindow?.width ?? 375
        let height = self.alertWindow?.height ?? 800
        
        let alertViewHeight = UIApplication.isIPhoneX() == true ? config.sheetHeight  : config.sheetHeight - 10
        
        self.alertView.frame = CGRect(x: 0, y: height , width: width , height: alertViewHeight)

        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: CGFloat(config.damping), initialSpringVelocity: CGFloat(config.initialSpringVelocity), options: UIView.AnimationOptions.allowUserInteraction, animations: { () -> Void in
            let alertViewFrame = CGRect(x: 0, y: height - alertViewHeight , width: width , height: alertViewHeight)
            self.alertView.frame = alertViewFrame
            self.backgroundView.alpha = CGFloat(self.config.backgroundAlpha)
        }, completion: {  _ in
            
        })
    }
    
    public func dismissWithDuration(_ duration: Double) {
        let completion = { (complete: Bool) -> Void in
            if complete {
                self.alertWindow?.isHidden = true
                self.alertWindow = nil
                self.previousWindow?.makeKeyAndVisible()
                self.previousWindow = nil
            }
        }
        
        let width = self.alertWindow?.width ?? 375
        let height = self.alertWindow?.height ?? 800
        let alertViewHeight = UIApplication.isIPhoneX() == true ? config.sheetHeight  : config.sheetHeight - 10
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: CGFloat(self.config.damping), initialSpringVelocity: CGFloat(self.config.initialSpringVelocity), options: UIView.AnimationOptions.allowUserInteraction, animations: { () -> Void in
            self.alertView.frame = CGRect(x: 0, y: height , width: width , height: alertViewHeight)
            self.backgroundView.alpha = 0
        }, completion: completion)
        
    }
}


extension A4xBaseActionsheetView: UIPickerViewDelegate, UIPickerViewDataSource {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.dataSource?.count ?? 0
    }

    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        let string = self.dataSource?[row].0 ?? ""
        pickerLabel.textColor = config.rowTextColor
        pickerLabel.text = string
        pickerLabel.font = config.rowTextFont
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }
    
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return config.rowHeight
    }
    
    public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return pickerView.width
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.currentRow = row
    }
}

extension A4xBaseActionsheetView: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.auto()
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier: String = "A4xBaseActionsheetViewCell"
        var tableCell: A4xBaseActionsheetViewCell? = tableView.dequeueReusableCell(withIdentifier: identifier) as? A4xBaseActionsheetViewCell
        if (tableCell == nil) {
            tableCell = A4xBaseActionsheetViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: identifier)
        }
        
        if self.dataSource?[indexPath.row].2.count ?? 0 > 0 {
            let enabled = self.dataSource?[indexPath.row].2.values.first as! Bool
            tableCell?.title = self.dataSource?[indexPath.row].2.keys.first
            if enabled {
                tableCell?.titleLbl.textColor = UIColor.colorFromHex("#2F3742")
            } else {
                tableCell?.titleLbl.textColor = ADTheme.C3
            }
        } else {
            tableCell?.title = self.dataSource?[indexPath.row].0
        }
        tableCell?.des = self.dataSource?[indexPath.row].1
        tableCell?.cellType = config.titleAlignment
        
        return tableCell ?? UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.dataSource?[indexPath.row].2.count ?? 0 > 0 {
            let enabled = self.dataSource?[indexPath.row].2.values.first as! Bool
            if enabled {
                self.currentRow = indexPath.row
                self.doneButtonAction()
            } else {
                
            }
        } else {
            self.currentRow = indexPath.row
            self.doneButtonAction()
        }
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = .zero
        cell.clipsToBounds = true
        let count = self.tableView(self.tableView, numberOfRowsInSection: indexPath.section)
        if indexPath.row == count {
            cell.contentView.layer.mask = nil
            return
        }
        let bounds = cell.contentView.bounds
        
        var rectCorner: UIRectCorner = UIRectCorner.allCorners
        if indexPath.row == 0 {
            rectCorner = [.topLeft,.topRight]
            cell.separatorInset = .zero
        } else {
            rectCorner = []
            cell.separatorInset = UIEdgeInsets(top: 0, left: 15.auto(), bottom: 0, right: 15.auto())
        }
       
        
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: rectCorner, cornerRadii: CGSize(width: 10.auto(), height: 10.auto()))
        
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = cell.contentView.bounds
        maskLayer.path = path.cgPath
        cell.contentView.layer.mask = maskLayer
        
        cell.contentView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.07).cgColor
        cell.contentView.layer.shadowOffset = CGSize(width: 0, height: 1)
        cell.contentView.layer.shadowOpacity = 1
        cell.contentView.layer.shadowRadius = 7.5
    }
    
    

}


extension A4xBaseActionsheetView {
    @objc func cancleButtonAction() {
        self.cancleBlock?()
        dismissAlertView()
    }
    
    @objc func doneButtonAction() {
        self.doneBlock?(self.currentRow)
        dismissAlertView()
    }
    
    @objc func outSiteAction() {
        self.outHiddenBlock?()
        dismissAlertView()
    }
}


