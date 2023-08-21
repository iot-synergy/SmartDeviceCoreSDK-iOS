//


//


//

import UIKit
import SmartDeviceCoreSDK
import A4xDeviceSettingInterface
import BaseUI

class A4xFilterTagZoneSubCell: UICollectionViewCell {
    
    var filterData : A4xVideoLibraryFilterModel?
    
    var deviceModel : ZoneBean? {
        didSet {
            if let data: ZoneBean = deviceModel {
                self.subAllTitleLbl.text = data.zoneName
                guard let sernum = data.serialNumber else {
                    self.subAllImageView.image = nil
                    return
                }
                self.subAllImageView.image = thumbImage(deviceID: sernum)
                self.messageView.dataSource = [data]
            }else {
                self.subAllTitleLbl.text = nil
                self.messageView.dataSource = []
            }
        }
    }
    
    var checked : Bool = false {
        didSet {
            self.isSelect = checked
        }
    }

    //是否选中 - 适合单选
    var isSelect: Bool = false {
        didSet{
            print("\(isSelect)")
            self.selecteImage.isHidden = isSelect
            if isSelect {
                subAllImageView.layer.borderWidth = 4
                subAllImageView.layer.borderColor = ADTheme.Theme.cgColor
                self.selecteImage.isHidden = false
            }else {
                subAllImageView.layer.borderWidth = 0
                subAllImageView.layer.borderColor = ADTheme.C6.cgColor
                self.selecteImage.isHidden = true
            }
        }
    }

    lazy var subAllImageView: UIImageView = {
        let temp = UIImageView()
        temp.backgroundColor = UIColor.black
       
        temp.layer.cornerRadius = 5.5.auto()
        temp.clipsToBounds = true
        self.contentView.addSubview(temp)
        temp.snp.makeConstraints({(make) in
            make.top.equalTo(0)
            make.leading.equalTo(0)
            make.height.equalTo(46.auto())
            make.width.equalTo(self.snp.width)
        })
        return temp
    }()
    
    
    lazy var subAllTitleLbl: UILabel = {
        var temp: UILabel = UILabel()
        temp.text = "摄像机摄像机区域1"
        temp.textColor = ADTheme.C1
        temp.font = UIFont.regular(14)
        temp.textAlignment = .center
        self.contentView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.top.equalTo(subAllImageView.snp.bottom).offset(7.auto())
            make.width.equalTo(self.snp.width)
            make.height.equalTo(20.auto())
            make.leading.equalTo(0.auto())
        })
        return temp
    }()
    
    
    lazy var selecteImage: UIImageView = {
        let temp = UIImageView()
        temp.image = bundleImageFromImageName("filter_selected_camera_icon")?.rtlImage()
        self.contentView.addSubview(temp)
        temp.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.subAllImageView.snp.centerY)
            make.centerX.equalTo(self.subAllImageView.snp.centerX)
        }
        return temp
    }()
    
    lazy var messageView: A4xFilterActivityZoneView = {
        let temp = A4xFilterActivityZoneView()
        self.contentView.addSubview(temp)
        temp.snp.makeConstraints({ (make) in
            make.leading.top.equalTo(0.auto())
            make.size.equalTo(CGSize(width: 82.auto(), height: 46.auto()))
        })
        return temp
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.subAllImageView.isHidden = false
        self.subAllTitleLbl.isHidden = false
        self.messageView.isHidden = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


class A4xFilterActivityZoneView: UIView {

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var dataSource : [ZoneBean]?{
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        dataSource?.reversed().forEach({ (point) in
            let pointPath = UIBezierPath()
            pointPath.lineWidth = 2
            guard let points = point.verticesPoints() else {
                return
            }
            
            guard points.count > 0 else {
                return
            }
            var color : UIColor = ADTheme.Theme
            let recolor = point.rectColor
            if recolor != NULL_INT {
                color = UIColor.hex(recolor)
            }
            
            color.setStroke()
            color.withAlphaComponent(0.3).setFill()
            pointPath.move(to: getPointValue(point: points.first!))
            for index in 1..<points.count{
                pointPath.addLine(to: getPointValue(point: points[index]))
            }
            pointPath.close()
            pointPath.stroke()
            pointPath.fill()
        })
    }
    
    private func getPointValue(point : CGPoint) -> CGPoint {
        let width = self.bounds.width
        let height = self.bounds.height
        
        return CGPoint(x: width * point.x , y: height * point.y )
    }
}
