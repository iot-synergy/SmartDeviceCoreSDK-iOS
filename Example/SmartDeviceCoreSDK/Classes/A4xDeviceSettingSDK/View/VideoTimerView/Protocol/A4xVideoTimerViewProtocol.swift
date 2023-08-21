//


//


//

import Foundation
import SmartDeviceCoreSDK

typealias A4xTimerLoadCompleBlock = ((_ isScuess : Bool , _ dateSourde : [A4xVideoTimeModel]?) -> Void)



class A4xVideoChildView : UIView {
    let identifier : String
    init(frame: CGRect = .zero , identifier : String) {
        self.identifier = identifier
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol A4xVideoTimerViewProtocol : NSObjectProtocol {
    func timerView(timerView : A4xVideoTimerView , minDate date : Date)
    func timerViewMaxDate(timerView : A4xVideoTimerView ) -> Date
    func timerView(timerView : A4xVideoTimerView , willSelectDate date : Date)
    func timerView(timerView : A4xVideoTimerView , didSelectDate date : Date , inData : A4xVideoTimeModel? )
    func timerMinView(timerView : A4xVideoTimerView ) -> A4xVideoChildView?
    func timerMaxView(timerView : A4xVideoTimerView ) -> A4xVideoChildView?
    func timerLoadDate(timerView : A4xVideoTimerView , fromDate : Date , toDate : Date , comple : @escaping A4xTimerLoadCompleBlock)
}

protocol A4xVideoTimerViewInterface : class {
    var `protocol` : A4xVideoTimerViewProtocol? {
        set get
    }
    
    var timerMinDate : Date {
        get
    }
    
    var timerMaxDate : Date {
        get
    }
    
    var timerSelectDate : Date? {
        set get
    }
    
    var currentIsChange : Bool { //当前正在切换
        set get
    }
    
    func timerMinView(of Identifier : String) -> A4xVideoChildView?
    func timerMaxView(of Identifier : String) -> A4xVideoChildView?
    
    func reloadDate(comple: @escaping (() -> Void))
    
    func timerCurrentInfo(date : Date?) -> (Date , A4xVideoTimeModel?)
}
