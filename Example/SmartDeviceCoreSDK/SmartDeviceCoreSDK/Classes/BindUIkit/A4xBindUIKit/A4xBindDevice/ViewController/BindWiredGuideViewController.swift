//


//


//

import UIKit
import SmartDeviceCoreSDK

class BindWiredGuideViewController: BindBaseViewController {
    
    private var bindWiredGuideView: A4xBindWiredGuideView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        defaultNav()
        navView?.backgroundColor = UIColor(hex: "#F6F7F9")
        self.navView?.lineView?.isHidden = true
        bindWiredGuideView = A4xBindWiredGuideView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: self.view.height))
        bindWiredGuideView?.protocol = self
        let currentView = bindWiredGuideView
        self.view.addSubview(currentView!)
    
        currentView?.backClick = { [weak self] in
            //self?.addCamera_select_bindmode_show("back")
            //self?.leftClick(isReset: false)
            
            self?.navigationController?.popViewController(animated: false)
        }
        
    }
}

extension BindWiredGuideViewController: A4xBindWiredGuideViewProtocol {
    func clickAction(tag: Int) {
        if tag == 101 { 
            
            
            //self.addCamera_select_bindmode_show("wireless")
            //self.viewControllerIdentifier = "wifi_password"
            //viewPageStackPush("A4xBindChooseWifiView")
            //A4xBindChooseWifiViewController()
            //self.page_set_wifi_view(source: "select_connection_type_page")
            
            let vc = BindChooseWifiViewController()
            self.navigationController?.pushViewController(vc, animated: false)
        } else { 
            
            //self.addCamera_select_bindmode_show("wired")
            
            
            if selectedBindDeviceModel != nil { 
                self.view.makeToastActivity(title: "loading") { (f) in }
                //checkNextStep(isWiredAndWireless: false)
                BindCore.getInstance().startBindByWire(bindDeviceModel: self.selectedBindDeviceModel)
            } else {
                
                
                //viewPageStackPush("A4xBindCableCheckView")
                //A4xBindCableCheckViewController()
                //self.page_ethernet_guide_show()
                
            }
        }

    }
}

