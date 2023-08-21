//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

public extension UIWindow {
    
    class func getDownloadView() -> A4xDownloadProgressView? {
        guard let keyWindow = UIApplication.shared.keyWindow else {
            return nil
        }
        
        if let current = keyWindow.viewWithTag(100021) as? A4xDownloadProgressView {
            return current
        }
        
        let temp = A4xDownloadProgressView(frame: .zero)
        temp.tag = 100021
        temp.radio = 0.1
        temp.downLoadTitle = ""
        temp.progress = 0.1
        temp.bgColor = ADTheme.Theme
        keyWindow.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.bottom.equalTo(keyWindow.snp.bottom).offset(-UIScreen.bottomBarHeight + 1.auto())
            make.width.equalTo(keyWindow.snp.width)
            make.centerX.equalTo(keyWindow.snp.centerX)
            make.height.equalTo(45)
        })
        return temp
    }
    
   
    private class func showDownloadInfo(currentIndex : Int = -1 , totle : Int  = -1 ,title : String , pro : Float = -1){
        self.getDownloadView()?.downLoadTitle = title
        self.getDownloadView()?.progress = pro
        if currentIndex > 0 && totle > 0 {
            self.getDownloadView()?.indexTitle = "\(currentIndex)/\(totle)"
        } else {
            self.getDownloadView()?.indexTitle = ""
        }
    }
    
    //MARK: - 下载完成，去相册查看
    
    
    private class func hiddenDownload(res: Bool) {
        self.showDownloadInfo(title: res ? A4xBaseManager.shared.getLocalString(key: "go_album_download") : A4xBaseManager.shared.getLocalString(key: "download_faild_and_try"))
        
        self.getDownloadView()?.isShowJumpToPhotoArrow = res 
       
        DispatchQueue.main.a4xAfter(2) {
            self.getDownloadView()?.removeFromSuperview()
        }
    }
    
   
    class func downloadSource(models: [RecordBean], nav: UINavigationController?, haveTabBar: Bool?) {
        A4xBasePhotoManager.default().checkAuthor { error in
            switch error {
            case .no:
                
                let libraryCore = LibraryCore()
                guard let progressView = UIWindow.getDownloadView() else {
                    return
                }
                progressView.nav = nav
                
                libraryCore.downloadSource(tasks: models, isShare: false) { d, t, p, describe in
                    DispatchQueue.main.async {
                        UIWindow.showDownloadInfo(currentIndex: d, totle: t, title: "\(A4xBaseManager.shared.getLocalString(key: "download"))...", pro: p)
                    }
                } onFinish: { res, sharePathArr, shareComple in
                    DispatchQueue.main.async {
                        UIWindow.hiddenDownload(res: res)
                    }
                }
                
                if haveTabBar ?? true {
                    progressView.snp.updateConstraints { make in
                        make.bottom.equalTo(UIApplication.shared.keyWindow!.snp.bottom).offset(-UIScreen.bottomBarHeight + 1.auto())
                    }
                } else {
                    progressView.snp.updateConstraints { make in
                        make.bottom.equalTo(UIApplication.shared.keyWindow!.snp.bottom).offset(-UIScreen.safeAreaHeight + 1.auto())
                    }
                }
                
            case .reject:
                A4xBaseAuthorizationViewModel.single.showRequestAlert(type: A4xBaseAuthorizationType.photo) { (f) in
                }
            }
        }
        
    }

    
    class func stopDownload() {
        self.getDownloadView()?.removeFromSuperview()
    }
}
