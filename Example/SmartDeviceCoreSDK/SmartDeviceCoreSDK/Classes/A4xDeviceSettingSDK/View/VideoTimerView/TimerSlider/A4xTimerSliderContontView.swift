//


//


//

import Foundation
import UIKit
import SmartDeviceCoreSDK
import BaseUI

extension UISlider {
    var thumbCenterX: CGFloat {
        let trackRect = self.trackRect(forBounds: frame)
        let thumbRect = self.thumbRect(forBounds: bounds, trackRect: trackRect, value: value)
        return thumbRect.midX
    }
}

class A4xTimerSliderContontView : UIControl {
    var value : Float {
        set {
            self.sliderView.setValue(newValue, animated: true)
        }
        get {
            return self.sliderView.value
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.layer.shadowColor = UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.14).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 15.5
    }
    
    override var frame: CGRect {
        didSet {
            loadFrame()
        }
    }
    
    private func loadFrame(){
        self.smailButton.frame = CGRect(x: 8.5, y: (self.frame.height - 20) / 2, width: 20, height: 20)
        self.bigButton.frame = CGRect(x: self.frame.width - 8.5 - 20 , y: (self.frame.height - 20) / 2, width: 20, height: 20)
        self.sliderView.frame = CGRect(x: self.smailButton.frame.maxX + 10, y: 0, width: self.bigButton.frame.minX - 20 - self.smailButton.frame.maxX , height: self.frame.height)
    }
    
    var sliderCenterX : Float  {
        return  Float(self.sliderView.thumbCenterX)
    }
    
    private lazy
    var sliderView : UISlider = {
        let temp = UISlider()
        temp.addTarget(self, action: #selector(sliderValueChange(slider:)), for: UIControl.Event.valueChanged)
        temp.addTarget(self, action: #selector(sliderBeginTouch), for: UIControl.Event.touchDown)
        temp.addTarget(self, action: #selector(sliderBeginEnd), for: UIControl.Event.touchUpInside)
        temp.addTarget(self, action: #selector(sliderBeginEnd), for: UIControl.Event.touchCancel)
        temp.addTarget(self, action: #selector(sliderBeginEnd), for: UIControl.Event.touchUpOutside)
        temp.minimumTrackTintColor = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1)
        temp.maximumTrackTintColor = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 0.8)
        //temp.setThumbImage(UIImage(color: ADTheme.Theme, size: CGSize(width: 6, height: 6))?.roundImage(cornerRadi: 6), for: UIControl.State.normal)
        temp.setThumbImage(UIImage(color: ADTheme.Theme, size: CGSize(width: 6, height: 6))?.isCircleImage(), for: UIControl.State.normal)
        self.addSubview(temp)
        return temp
    }()
    
    @objc private
    func sliderBeginTouch(){
        self.sendActions(for: UIControl.Event.touchDown)
    }
    @objc private
    func sliderBeginEnd(){
        self.sendActions(for: UIControl.Event.touchUpInside)
    }
    
    private lazy
    var smailButton : UIButton = {
        let temp = UIButton()
        temp.addTarget(self, action: #selector(smailSliderValue), for: .touchUpInside)
        self.addSubview(temp)
        temp.setImage(A4xDeviceSettingResource.UIImage(named: "time_change_smail")?.rtlImage(), for: .normal)
        return temp
    }()
    
    private lazy
    var bigButton : UIButton = {
        let temp = UIButton()
        temp.addTarget(self, action: #selector(bigSliderValue), for: .touchUpInside)
        self.addSubview(temp)
        temp.setImage(A4xDeviceSettingResource.UIImage(named: "time_change_big")?.rtlImage(), for: .normal)
        return temp
    }()
    
    @objc
    private func sliderValueChange(slider : UISlider){
        self.sendActions(for: UIControl.Event.valueChanged)
    }
    
    @objc
    private func smailSliderValue(){
        var current = self.sliderView.value
        current =  min(1, current - 0.1)
        if self.sliderView.value != current {
            self.sliderView.setValue(current, animated: true)
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    @objc
    private func bigSliderValue(){
        var current = self.sliderView.value
        current = min(1, current + 0.1)
        if self.sliderView.value != current {
            self.sliderView.setValue(current, animated: true)
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
