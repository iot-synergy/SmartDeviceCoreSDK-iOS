//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI

public class A4xDownloadProgressView: A4xBaseCircleView {
    
    var checkPhotoBlock: (() -> Void)?
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.downLoadLable.isHidden = false
        self.progressLabel.isHidden = false
        self.indexLable.isHidden = false
        self.imageV.isHidden = true
        self.isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var indexTitle: String? {
        didSet {
            self.indexLable.text = indexTitle
        }
    }
    
    var downLoadTitle: String? {
        didSet {
            self.downLoadLable.text = downLoadTitle
        }
    }
    
    var progress: Float = 0 {
        didSet {
            updateProgress()
        }
    }
    
    var nav: UINavigationController?
    
    var isShowJumpToPhotoArrow: Bool = false {  
        didSet {
            if isShowJumpToPhotoArrow {  
                self.checkPhotoBtn.isHidden = false
                self.checkPhotoBtn.isUserInteractionEnabled = true 
            } else { 
                self.checkPhotoBtn.isHidden = true
                self.checkPhotoBtn.isUserInteractionEnabled = false 
            }
        }
    }
    
    private lazy var imageV : UIImageView = {
        let temp: UIImageView = UIImageView()
        temp.image = bundleImageFromImageName("resouce_bottom_download")?.rtlImage()
        self.addSubview(temp)
        
        temp.snp.makeConstraints { make in
            make.centerY.equalTo(self.snp.centerY)
            make.leading.equalTo(15)
        }
        return temp;
    }()
    
    private lazy var indexLable: UILabel = {
        let tem: UILabel = UILabel()
        tem.font = ADTheme.B2
        tem.textColor = .white
        self.addSubview(tem)
        tem.snp.makeConstraints { make in
            make.centerY.equalTo(self.snp.centerY)
            make.trailing.equalTo(self.progressLabel.snp.leading).offset(-8)
        }
        return tem
    }()
    
    private lazy var downLoadLable: UILabel = { 
        let tem: UILabel = UILabel()
        tem.font = UIFont.regular(14)
        tem.textColor = .white
        tem.textAlignment = .right
        self.addSubview(tem)
        tem.snp.makeConstraints { make in
            make.centerY.equalTo(self.snp.centerY)
            make.width.equalTo(180.auto())
            make.trailing.equalTo(self.indexLable.snp.leading).offset(0)
        }
        return tem
    }()
    
    private lazy var checkPhotoBtn: UIButton = { 
        let temp = UIButton()
        temp.isHidden = true
        temp.isUserInteractionEnabled = false 
        temp.addTarget(self, action: #selector(checkPhotoAction), for: UIControl.Event.touchUpInside)
        self.addSubview(temp)
        temp.snp.makeConstraints { make in
            make.centerY.equalTo(self.snp.centerY)
            make.trailing.equalTo(-10.auto())
            make.width.equalTo(UIScreen.width / 2)
        }
        return temp
    }()
    
    private lazy var progressLabel : UILabel = {
        let tem: UILabel = UILabel()
        tem.font = UIFont.regular(14)
        tem.textColor = .white
        self.addSubview(tem)
        
        tem.snp.makeConstraints { make in
            make.centerY.equalTo(self.snp.centerY)
            make.trailing.equalTo(self.snp.trailing).offset(-15)
        }
        return tem;
    }()
    
    private func updateProgress() {
        if progress < 0 {
            self.progressLabel.text = ""
        }else {
            self.progressLabel.text = String(format: "%.1f%%", progress * 100).replacingOccurrences(of: "inf", with: "1", options: .literal, range: nil)
        }
    }
}



extension A4xDownloadProgressView {
    
    @objc func checkPhotoAction() {
        self.checkPhotoBlock?()
        let vc = UIImagePickerController()
        vc.mediaTypes = ["public.movie", "public.image"]
        self.nav?.present(vc, animated: true)
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let moreButtonFrame = checkPhotoBtn.frame.inset(by: UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10))
        if moreButtonFrame.contains(point) {
            return checkPhotoBtn
        } else {
            return super.hitTest(point, with: event)
        }
    }
}
