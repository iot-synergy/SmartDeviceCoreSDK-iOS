//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

class A4xScanSelectResultViewController: A4xBaseViewController {
 
    var image : UIImage?
    var selectResult : ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.isHidden = false
        self.contentImageV.isHidden = false
        DispatchQueue.main.a4xAfter(0.1) {
            self.updateImage()
        }
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.defaultNav()
        var rightItem = A4xBaseNavItem()
        rightItem.title = A4xBaseManager.shared.getLocalString(key: "choose")
        rightItem.titleColor = ADTheme.Theme
        self.navView?.rightItem = rightItem

        self.navView?.rightClickBlock = {[weak self] in
            self?.getQrcodeInformation()
        }

        






    }
    
    
    
    @objc
    func getQrcodeInformation() {
        guard let img = self.image else {
            return
        }
        self.view.makeToastActivity(title: A4xBaseManager.shared.getLocalString(key: "loading") , bgColor : UIColor.clear) { (f) in }
        weak var weakSelf = self
        img.recognitionQrcode(comple: { (st) in
            weakSelf?.view.hideToastActivity {
                guard let result = st else {
                    weakSelf?.view.makeToast(A4xBaseManager.shared.getLocalString(key: "no_qr_code"))
                    return
                }
                weakSelf?.selectQrCode(result: result)
            }
        })
    }
    
    @objc
    func selectQrCode(result : String) {
        self.selectResult?(result)
        self.navigationController?.dismiss(animated: true)
    }
    
    @objc
    func backUpController() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func updateImage() {
        let size = image?.size ?? CGSize.zero
        let scSize = self.scrollView.frame.size
        if scSize.equalTo(CGSize.zero) {
            return
        }
        let zoom = max(size.width / scSize.width , size.height / scSize.height)
        self.contentImageV.frame = CGRect(x: (scSize.width - size.width / zoom) / 2, y: (scSize.height - size.height / zoom) / 2 , width: size.width / zoom , height: size.height / zoom)
        self.contentImageV.isHidden = false
        self.contentImageV.image = self.image
        
        self.scrollView.contentSize = self.contentImageV.frame.size
    }
    
    private lazy var contentImageV : UIImageView = {
        let temp = UIImageView()
        temp.contentMode = .scaleAspectFit
        temp.backgroundColor = UIColor.clear
        temp.isUserInteractionEnabled = true
        let oneTap = UITapGestureRecognizer(target: self, action:#selector(oneClick(tap:)))
        temp.addGestureRecognizer(oneTap)
        oneTap.numberOfTapsRequired = 1
        
        let doubleTap = UITapGestureRecognizer(target: self, action:#selector(doubleClick(tap:)))
        temp.addGestureRecognizer(doubleTap)
        doubleTap.numberOfTapsRequired = 2
        
        oneTap.require(toFail: doubleTap)
        self.scrollView.addSubview(temp)
        
        temp.center = self.view.center
        return temp
    }()
    
    private lazy var scrollView  : UIScrollView = {
        let temp = UIScrollView()
        temp.delegate = self
        temp.maximumZoomScale = 3
        temp.minimumZoomScale = 1
        temp.backgroundColor = UIColor.clear
        temp.showsVerticalScrollIndicator = false
        temp.showsHorizontalScrollIndicator = false
        self.view.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(0)
            make.width.equalTo(self.view.snp.width)
            make.top.equalTo(self.navView!.snp.bottom)
            if #available(iOS 11.0, *) {

                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)

            } else {

                make.bottom.equalTo(bottomLayoutGuide.snp.bottom)
            }
        })
        return temp
    }()
    
    @objc
    private func doubleClick( tap : UITapGestureRecognizer) {
        
        if self.scrollView.zoomScale > 1.5 {
            self.scrollView.setZoomScale(1, animated: true)
        }else {
            self.scrollView.setZoomScale(2.5, animated: true)
        }
    }
    
    @objc
    private func oneClick( tap : UITapGestureRecognizer) {
        
     
        
    }
}

extension A4xScanSelectResultViewController : UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.contentImageV
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        let offsetX = max(((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5) ,0)
        let offsetY = max(((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5) ,0)
        self.contentImageV.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)

    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = max(((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5) ,0)
        let offsetY = max(((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5) ,0)
        self.contentImageV.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        self.scrollView.setZoomScale(scale, animated: true)
    }
}
