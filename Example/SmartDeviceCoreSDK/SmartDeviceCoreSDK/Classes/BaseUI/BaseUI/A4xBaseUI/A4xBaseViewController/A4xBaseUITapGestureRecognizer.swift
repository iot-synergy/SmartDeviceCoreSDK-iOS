//


//


//

import Foundation

class A4xBaseUITapGestureRecognizer : UITapGestureRecognizer {
    
    var excueBlockInfo : [String : (String , _ location : CGPoint)->Void] = [:]

    var checkString : String?
    init( ) {
        super.init(target: nil, action: nil)
        self.addTarget(self, action: #selector(excueFunc(gesture:)))
    }
    
    func addNewClick(checkString : String , block : ( (String , _ location : CGPoint)-> Void)? = nil){
        excueBlockInfo[checkString] = block
    }
    
    @objc private func excueFunc(gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: self.view)
        excueBlockInfo.forEach { (key, comple) in
            comple(key , tapLocation)
        }
    }
}
