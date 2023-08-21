//


//


//

import UIKit
import SmartDeviceCoreSDK

public protocol A4xBaseImageCardProtocol: class {
    

    func clickAction(sender: UIButton?)
}
    

public class A4xBaseImageCard: A4xBaseCardView {
    
    public weak var `protocol` : A4xBaseImageCardProtocol?

    var setImg: UIImage? {
        didSet {
            imageView.image = setImg
        }
    }
    
    public var setNumStr: String? {
        didSet {
            numLbl.text = setNumStr
        }
    }
    
    public var cardModel: CarReIdBean?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        imageView.isHidden = false
      
        
        numLbl.isHidden = false
        
        
        hintLbl.isHidden = false
        
        
        unkonwBtn.isHidden = false
        
        
        konwBtn.isHidden = false
    }
    
    public lazy var imageView: UIImageView = {
        let temp = UIImageView()
        temp.contentMode = .scaleAspectFill
        temp.backgroundColor = ADTheme.C4
        self.addSubview(temp)
        temp.snp.makeConstraints { make in
            make.leading.equalTo(12.auto())
            make.top.equalTo(12.auto())
            make.size.equalTo(CGSize(width: 268.5.auto(), height: 179.auto()))
        }
        temp.layoutIfNeeded()
        temp.layer.cornerRadius = 5
        temp.layer.masksToBounds = true
        
        return temp
    }()
    
    lazy private var numLbl: UILabel = {
        let temp = UILabel()
        temp.font = UIFont.regular(14)
        temp.textColor = ADTheme.C1
        temp.textAlignment = .center
        temp.text = "1/1"
        self.addSubview(temp)
        temp.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8.auto())
            make.centerX.equalToSuperview()
        }
        
        return temp
    }()
    
    lazy private var hintLbl: UILabel = {
        let temp = UILabel()
        temp.font = UIFont.regular(18)
        temp.textColor = ADTheme.C1
        temp.textAlignment = .center
        temp.text = A4xBaseManager.shared.getLocalString(key: "know_vehicle_popwindow")
        self.addSubview(temp)
        temp.snp.makeConstraints { make in
            make.top.equalTo(numLbl.snp.bottom).offset(8.auto())
            make.centerX.equalToSuperview()
            make.width.equalTo(self.snp.width).offset(-32.auto())
        }
        
        return temp
    }()
    
    lazy private var unkonwBtn: UIButton = {
        let temp = UIButton()
        temp.setTitle(A4xBaseManager.shared.getLocalString(key: "not_know"), for: .normal)
        temp.titleLabel?.font = UIFont.regular(16)
        temp.setTitleColor(UIColor.colorFromHex("#330000"), for: .normal)
        temp.backgroundColor = UIColor.colorFromHex("#F5F6FA")
        temp.tag = 0
        temp.addTarget(self, action: #selector(clickAction(sender:)), for: .touchUpInside)
        self.addSubview(temp)
        temp.snp.makeConstraints { make in
            make.top.equalTo(hintLbl.snp.bottom).offset(24.auto())
            make.leading.equalTo(16.auto())
            make.width.equalTo(128.auto())
            make.height.equalTo(40.auto())
        }
        temp.layoutIfNeeded()
        temp.layer.cornerRadius = 20.auto()
        
        return temp
    }()
    
    lazy private var konwBtn: UIButton = {
        let temp = UIButton()
        temp.setTitle(A4xBaseManager.shared.getLocalString(key: "know"), for: .normal)
        temp.titleLabel?.font = UIFont.regular(16)
        temp.setTitleColor(.white, for: .normal)
        temp.backgroundColor = ADTheme.Theme
        temp.tag = 1
        temp.addTarget(self, action: #selector(clickAction(sender:)), for: .touchUpInside)
        self.addSubview(temp)
        temp.snp.makeConstraints { make in
            make.top.equalTo(hintLbl.snp.bottom).offset(24.auto())
            make.trailing.equalTo(-16.auto())
            make.width.equalTo(128.auto())
            make.height.equalTo(40.auto())
        }
        temp.layoutIfNeeded()
        temp.layer.cornerRadius = 20.auto()
        
        return temp
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func clickAction(sender: UIButton) {
        self.protocol?.clickAction(sender: sender)
    }

}

