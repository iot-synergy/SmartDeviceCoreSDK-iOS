//


//


//

import UIKit
import SmartDeviceCoreSDK

public class A4xBaseDatePickerView: UIViewController {
    
    //public typealias KYTouchHandler = (A4xBaseActionsheetView) -> ()
    private var config : A4xBaseActionsheetConfig = A4xBaseActionsheetConfig()
    public var currentHourRow : Int = 0
    public var currentMinuteRow : Int = 0
    private var dataSource : ([String]?, [String]?)
    
    let dataSizeMultiple  = 10_000
    public var pickerHourData: [String] = ["00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23"] //第一级数据
    public var pickerMinuteData: [String] = ["00","30"] //第二级数据
    
    private var outHiddenBlock : (()->Void)?
    private var cancleBlock : (()->Void)?
    private var doneBlock : (((Int, Int))->Void)?
    public override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    public init(config: A4xBaseActionsheetConfig = A4xBaseActionsheetConfig(), titleItem: A4xBaseActionSheetType?, cancleItem: A4xBaseActionSheetType?, okItem: A4xBaseActionSheetType?, outHidden: A4xBaseActionSheetType?, select: A4xBaseActionSheetType?) {
        super.init(nibName: nil, bundle: nil)
        if viewNotReady() {
            DispatchQueue.main.a4xAfter(0.1) {
                self.loadConfig(config: config, titleItem: titleItem, cancleItem: cancleItem, okItem: okItem, outHidden: outHidden, select: select)
            }
            return
        }
        self.loadConfig(config: config, titleItem: titleItem, cancleItem: cancleItem, okItem: okItem, outHidden: outHidden, select: select)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate lazy var tapOutsideRecognizer: UITapGestureRecognizer = {
        return UITapGestureRecognizer()
    }()
 
    private lazy var alertBounds : CGRect = {
        let bounds = UIApplication.shared.keyWindow?.bounds ?? CGRect(x: 0, y: 0, width: 375, height: 568)
        return bounds
    }()

    private lazy var backgroundView : UIView = {
        let temp = UIView(frame: self.alertBounds)
        temp.isUserInteractionEnabled = true
        temp.backgroundColor = UIColor.black
        temp.alpha = 0
        self.alertWindow?.insertSubview(temp, belowSubview: self.alertView)
        temp.addGestureRecognizer(self.tapOutsideRecognizer)
        
        return temp
    }()
    
    private lazy var alertView: A4xBaseCircleView = {
        let width : CGFloat = CGFloat(self.alertWindow?.width ?? 375)
        let height: CGFloat = UIApplication.isIPhoneX() == true ? CGFloat(config.sheetHeight) : CGFloat(config.sheetHeight - 20)
        let temp = A4xBaseCircleView(frame: CGRect(x: 0, y: 0, width: width , height: height))
        temp.bgColor = UIColor.white
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
        let window = UIWindow(frame: (UIApplication.shared.keyWindow?.bounds)!)
        window.windowLevel = UIWindow.Level.alert
        window.backgroundColor = UIColor.clear
        window.rootViewController = self
        return window
    }()
    
    private lazy var alertTitleLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = config.rowTextColor
        lbl.text = A4xBaseManager.shared.getLocalString(key: "sleep_start_time")
        lbl.font = ADTheme.B0
        lbl.textAlignment = NSTextAlignment.center
        self.alertView.addSubview(lbl)
        lbl.snp.makeConstraints { (make) in
            make.top.equalTo(15.auto())
            make.centerX.equalToSuperview()
            make.width.equalTo(self.alertView.snp.width).offset(-32.auto())
        }
        return lbl
    }()
    
    
    private lazy var pickerView: UIPickerView = {
        let temp = UIPickerView()
        temp.delegate = self
        temp.dataSource = self
        self.alertView.addSubview(temp)
        temp.snp.makeConstraints { (make) in
            make.height.equalTo(51.auto() * 3)
            make.width.equalToSuperview()
            make.center.equalToSuperview()
        }
        return temp
    }()
    
    private lazy var doneView: UIButton = {
        let temp = UIButton()
        temp.titleLabel?.font = UIFont.regular(16)
        temp.setTitleColor(UIColor.colorFromHex("#FFFFFF"), for: .normal)
        temp.setBackgroundImage(UIImage.init(color: ADTheme.Theme), for: .normal)
        temp.layer.cornerRadius = 20.auto()
        temp.clipsToBounds = true
        temp.addTarget(self, action: #selector(doneButtonAction), for: .touchUpInside)
        self.alertView.addSubview(temp)
        temp.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 151.5.auto(), height: 40.auto()))
            make.trailing.equalTo(-16.auto())
            make.bottom.equalTo(-17.auto())
        }
        return temp
    }()
    
    private lazy var cancleView: UIButton = {
        let temp = UIButton()
        temp.titleLabel?.font = UIFont.regular(16)
        temp.setTitleColor(ADTheme.C1, for: .normal)
        temp.setBackgroundImage(UIImage.init(color: UIColor.colorFromHex("#F5F6FA")), for: .normal)
        temp.layer.cornerRadius = 20.auto()
        temp.clipsToBounds = true
        temp.addTarget(self, action: #selector(cancleButtonAction), for: .touchUpInside)
        self.alertView.addSubview(temp)
        temp.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 151.5.auto(), height: 40.auto()))
            make.leading.equalTo(16.auto())
            make.bottom.equalTo(-17.auto())
        }
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
    
    private func loadConfig(config: A4xBaseActionsheetConfig, titleItem: A4xBaseActionSheetType?, cancleItem: A4xBaseActionSheetType? , okItem: A4xBaseActionSheetType? , outHidden: A4xBaseActionSheetType?, select: A4xBaseActionSheetType?) {
        self.config = config
        
        if case let .title(title) = titleItem {
            if title != nil {
                self.alertTitleLbl.text = title
            } else {
                self.alertTitleLbl.text = A4xBaseManager.shared.getLocalString(key: "sleep_start_time")
            }
        }
        
        if case let .cancle(title, block)? = cancleItem {
            if title != nil {
                self.cancleView.setTitle(title, for: .normal)
                self.cancleBlock = block
            } else {
                self.cancleBlock = nil
            }
        }
        
        if case let .ok(title, block)? = okItem {
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
        
        var defIndex = (0,0)
        if case let .dataTimeSource(dataTimeSource , defaultSelect)? = select {
            self.dataSource = dataTimeSource
            defIndex = defaultSelect
        }
        
        self.previousWindow?.isHidden = false
        loadViewData(defaultIndex: defIndex)
    }

}

extension A4xBaseDatePickerView {
    private func loadViewData(defaultIndex: (Int, Int) = (0, 0) ){
        self.currentHourRow = defaultIndex.0
        self.currentMinuteRow = defaultIndex.1

        let width = self.alertWindow?.width ?? 375
        let height = self.alertWindow?.height ?? 800
        let setheight = config.sheetHeight + config.buttonHeight
        
        //self.cancleView.frame = CGRect(x: 10.auto(), y: 0, width: (width - 50) / 2, height: config.buttonHeight)
        //self.doneView.frame = CGRect(x: width - (width - 50) / 2 - 10.auto() , y: 0, width: (width - 50) / 2, height: config.buttonHeight)
        //self.pickerView.frame = CGRect(x: 0, y: config.buttonHeight, width: width, height: config.sheetHeight - 30)
        
        self.alertView.radio = config.cornerRadius.toFloat
        
        self.alertView.radioType = [.topLeft,.topRight]
        self.alertView.frame = CGRect(x: 0, y: height, width: width, height: setheight)
        self.pickerView.contentMode = .center
        self.pickerView.reloadAllComponents()
        
        //让pickerView默认选中中间项 pickerHourData pickerMinuteData
        let position0 = dataSizeMultiple * (self.dataSource.0?.count ?? 0) / 2 + defaultIndex.0
        self.pickerView.selectRow(position0, inComponent: 0, animated: false)
        let position1 = dataSizeMultiple * (self.dataSource.1?.count ?? 0) / 2 + defaultIndex.1
        self.pickerView.selectRow(position1, inComponent: 1, animated: false)
        
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
    
    public func showWithDuration(_ duration: Double){
        if viewNotReady() {
            return
        }
        if config.damping <= 0 {
            config.damping = 0.1
        }else if config.damping >= 1 {
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
        let setheight = config.sheetHeight + config.buttonHeight
        
        self.alertView.frame = CGRect(x: 0, y: height , width: width , height: setheight)
        
        self.alertWindow?.bringSubviewToFront(self.backgroundView)
        self.alertWindow?.bringSubviewToFront(self.alertView)
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: CGFloat(config.damping), initialSpringVelocity: CGFloat(config.initialSpringVelocity), options: UIView.AnimationOptions.allowUserInteraction, animations: { () -> Void in
            let alertViewFrame = CGRect(x: 0, y: height - setheight , width: width , height: setheight)
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
        let setheight = config.sheetHeight + config.buttonHeight
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: CGFloat(self.config.damping), initialSpringVelocity: CGFloat(self.config.initialSpringVelocity), options: UIView.AnimationOptions.allowUserInteraction, animations: { () -> Void in
            self.alertView.frame = CGRect(x: 0, y: height , width: width , height: setheight)
            self.backgroundView.alpha = 0
        }, completion: completion)
        
    }
}

extension A4xBaseDatePickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    //设置pickerView的行数
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return dataSizeMultiple * (self.dataSource.0?.count ?? 0)
        } else {
            return dataSizeMultiple * (self.dataSource.1?.count ?? 0)
        }
    }
    
    //设置pickerView各选项的内容
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return self.dataSource.0?[row % (self.dataSource.0?.count ?? 0)]
        } else {
            return self.dataSource.1?[row % (self.dataSource.1?.count ?? 0)]
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if component == 0 {
            return NSAttributedString(string: (self.dataSource.0?[row % (self.dataSource.0?.count ?? 0)])!, attributes: [NSAttributedString.Key.foregroundColor: ADTheme.C1])
        } else {
            return NSAttributedString(string: (self.dataSource.1?[row % (self.dataSource.1?.count ?? 0)])!, attributes: [NSAttributedString.Key.foregroundColor: ADTheme.C1])
        }
    }

    
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 51.auto() //config.rowHeight
    }
    
    //pickerView选中某一项后会触发
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //重新让pickerView又选回中间部分的数据项
        if component == 0 {
            self.currentHourRow = row % (self.dataSource.0?.count ?? 0)
            let position = dataSizeMultiple * (self.dataSource.0?.count ?? 0) / 2 + self.currentHourRow
            pickerView.selectRow(position, inComponent: 0, animated: false)
            //小时改变后同步改变对应的分钟数据 - 级联效果
            //self.currentMinuteRow = 0
            //pickerView.reloadComponent(1)
            //pickerView.selectRow(dataSizeMultiple * (self.dataSource.1?.count ?? 0) / 2, inComponent: 1, animated: false)
        } else {
            self.currentMinuteRow = row % (self.dataSource.1?.count ?? 0)
            let position = dataSizeMultiple * (self.dataSource.1?.count ?? 0) / 2 + currentMinuteRow
            pickerView.selectRow(position, inComponent: 1, animated: false)
        }
    }
}

extension A4xBaseDatePickerView {
    @objc public func cancleButtonAction() {
        self.cancleBlock?()
        dismissAlertView()
    }
    
    @objc public func doneButtonAction() {
        self.doneBlock?((self.currentHourRow, self.currentMinuteRow))
        dismissAlertView()
    }
    
    @objc public func outSiteAction() {
        self.outHiddenBlock?()
        dismissAlertView()
    }
}
