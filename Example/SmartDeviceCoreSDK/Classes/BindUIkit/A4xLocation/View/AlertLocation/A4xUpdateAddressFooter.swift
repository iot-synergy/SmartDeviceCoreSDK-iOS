//


//


//

import UIKit

class A4xUpdateAddressFooter: UIView {

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy var maskLayer = {
        return CAShapeLayer()
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath()
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x: self.width, y: 0))
        let radio : CGFloat = 10.auto()
        path.addQuadCurve(to: CGPoint(x: self.width - radio , y: radio), controlPoint: CGPoint(x: self.width, y: radio))
        path.addLine(to: CGPoint(x: radio , y: radio))
        path.addQuadCurve(to: CGPoint(x: 0, y: 0), controlPoint: CGPoint(x: 0, y: radio))
        path.close()
        
        self.maskLayer.frame = self.bounds
        self.maskLayer.path = path.cgPath
        self.layer.mask = self.maskLayer
    }
}
