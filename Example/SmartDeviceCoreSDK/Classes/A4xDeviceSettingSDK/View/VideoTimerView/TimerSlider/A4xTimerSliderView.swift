//


//


//

import UIKit



class A4xTimerSliderView : UIView {
    var value : Float {
        set {
            self.sliderView.value = 1 - newValue
            loadFrame()
        }
        get {
            return 1 - self.sliderView.value
        }
    }
    
    var valueChangeBlock : ((Float)->Void)?
    var timeUnitBlock : (()->Int)?
    
    override var frame: CGRect {
        didSet {
            loadFrame()
        }
    }
    
    private func loadFrame(){
        self.sliderView.frame = CGRect(x: 0, y: 40 , width: self.bounds.width, height: 40)
        self.sliderIndicator.frame = CGRect(x: 30, y: 0, width: 27, height: 33)
        self.sliderIndicator.frame = CGRect(x: Int(self.sliderView.sliderCenterX - 27 / 2), y: 0, width: 27, height: 33)

    }
    

    private lazy
    var sliderView : A4xTimerSliderContontView = {
        let temp = A4xTimerSliderContontView()
        temp.addTarget(self, action: #selector(sliderValueChange), for: .valueChanged)
        temp.addTarget(self, action: #selector(sliderBeginMove), for: .touchDown)
        temp.addTarget(self, action: #selector(sliderEndMove), for: .touchUpInside)
        self.addSubview(temp)
        temp.layer.cornerRadius = 20
        return temp
    }()
    
    private lazy
    var sliderIndicator : A4xSliderIndicator = {
        let temp = A4xSliderIndicator()
        temp.isHidden = true
        self.addSubview(temp)
        return temp
    }()
    
    @objc private
    func sliderValueChange(){
        self.valueChangeBlock?(1 - self.sliderView.value)
        self.sliderIndicator.frame = CGRect(x: Int(self.sliderView.sliderCenterX - 27 / 2), y: 0, width: 27, height: 33)
        
        let min = self.timeUnitBlock?() ?? 60
        var text : String = ""
        if min < 60 {
            text = "\(min)s"
        }else if min < 60 * 60 {
            text = "\(Int(min / 60))m"
        }else if min < 60 * 60 * 24 {
            text = "\(Int(min / 60 / 60 ))h"
        }else {
            text = "\(Int(min / 60 / 60 / 24))d"
        }
        
        self.sliderIndicator.text = text
    }
    
    @objc private
    func sliderBeginMove(){
        self.sliderIndicator.isHidden = false
    }
    
    @objc private
    func sliderEndMove(){
        self.sliderIndicator.isHidden = true
    }
}
