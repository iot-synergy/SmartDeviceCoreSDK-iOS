//


//

//

import UIKit
import SmartDeviceCoreSDK



class BindJoinAPNetGuideViewController: BindBaseViewController {
    
    private var bindJoinAPNetView: A4xBindJoinAPNetGuideView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindJoinAPNetView = A4xBindJoinAPNetGuideView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: self.view.height))
        let currentView = bindJoinAPNetView
        currentView?.protocol = self
        self.view.addSubview(currentView!)
        
        var datas: [String : String] = [:]
        
        let jsonData = (self.selectedBindDeviceModel?.apInfo ?? "").data(using: String.Encoding.utf8, allowLossyConversion: false) ?? Data()
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let apInfoDetailModel = try? decoder.decode(A4xBindAPDeviceInfoModel.self, from: jsonData)
        datas["apSSID"] = apInfoDetailModel?.ssid
        currentView!.datas = datas
        
        currentView?.backClick = { [weak self] in
            
            //self?.leftClick(isReset: false)
            self?.navigationController?.popViewController(animated: false)
        }
    }
}

extension BindJoinAPNetGuideViewController: A4xBindJoinAPNetGuideViewProtocol {
    func joinAPNetGuideNextAction() {
        let vc = BindConnectWaitViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
