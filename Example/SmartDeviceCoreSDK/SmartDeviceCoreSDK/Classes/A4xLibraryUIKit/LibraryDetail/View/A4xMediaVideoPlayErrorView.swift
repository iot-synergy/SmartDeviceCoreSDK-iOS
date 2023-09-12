//


//

//

import Foundation
import SmartDeviceCoreSDK
import BaseUI

public class A4xMediaVideoPlayErrorView: UIView {
    
    var reloadBtnClick: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.errorIconView)
        self.addSubview(self.errorLabel)
        self.addSubview(self.reloadBtn)
        self.backgroundColor = .black
        updateFrame()
    }
    
    private func updateFrame() {
        self.errorLabel.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.width.equalTo(240.auto())
            make.height.equalTo(20.auto())
            make.bottom.equalTo(self.snp.centerY)
        }
        self.errorIconView.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.size.equalTo(CGSizeMake(28.auto(), 28.auto()))
            make.bottom.equalTo(self.errorLabel.snp.top).offset(-8.auto())
        }
        self.reloadBtn.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self.snp.centerY).offset(35.auto())
            make.height.equalTo(22.auto())
            make.width.equalTo(240.auto())
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var errorIconView: UIImageView = {
        let temp = UIImageView()
        temp.image = A4xBaseResource.UIImage(named: "home_report_log")?.rtlImage()
        return temp
    }()
    
    lazy var errorLabel: UILabel = {
        let temp = UILabel()
        temp.text = A4xBaseManager.shared.getLocalString(key: "server_error") 
        temp.textColor = .white
        temp.textAlignment = .center
        temp.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return temp
    }()
    
    public lazy var reloadBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .clear
        btn.setTitle(A4xBaseManager.shared.getLocalString(key: "reconnect"), for: .normal)
        btn.titleLabel?.font = UIFont.regular(16)
        btn.setTitleColor(ADTheme.Theme, for: .normal)
        btn.addTarget(self, action: #selector(reloadClick), for: .touchUpInside)
        return btn
    }()
    
    @objc func reloadClick() {
        reloadBtnClick?()
    }
}
