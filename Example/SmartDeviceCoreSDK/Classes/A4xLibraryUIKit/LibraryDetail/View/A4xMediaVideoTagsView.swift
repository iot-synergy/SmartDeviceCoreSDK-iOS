//


//


//

import UIKit
import SmartDeviceCoreSDK
import BaseUI


class A4xMediaVideoAiTagView : UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.imageView.isHidden = false
        self.title.isHidden = false
        self.backgroundColor = ADTheme.C5
        self.cornerRadius = 15.auto()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var imageView: UIImageView = {
        var temp: UIImageView = UIImageView()
        temp.contentMode = .left
        self.addSubview(temp)

        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(4.auto())
            make.centerY.equalTo(self)
            make.size.equalTo(CGSize(width: 20.auto(), height: 20.auto()))
        })
        return temp
    }()

    lazy var tagViewRedIV: UIImageView = {
        var temp: UIImageView = UIImageView()
        temp.contentMode = .left
        temp.isHidden = true
        self.addSubview(temp)
        temp.image = bundleImageFromImageName("main_libary_red")?.rtlImage()
        temp.snp.makeConstraints({ (make) in
            make.trailing.equalTo(self.imageView.snp.trailing).offset(0)
            make.top.equalTo(self.imageView.snp.top).offset(0)
            make.size.equalTo(CGSize(width: 14, height: 14))
        })
        return temp
    }()

    lazy var title: UILabel = {
        var temp: UILabel = UILabel()
        temp.textColor = ADTheme.C4
        temp.font = ADTheme.B2
        self.addSubview(temp)

        temp.snp.makeConstraints({ (make) in
            make.leading.equalTo(self.imageView.snp.trailing).offset(4.auto())
            make.centerY.equalTo(self.snp.centerY)
            make.trailing.equalTo(self.snp.trailing).offset(-8.auto())
        })
        return temp
    }()
}


class A4xMediaVideoBirdTagButton : UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.layer.masksToBounds = true
        self.cornerRadius = 15.auto()
    }
    
    var birdImg: UIImage? {
        didSet {
            self.iconImageView.image = birdImg
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configAiButton(titleString: String) -> CGFloat {
        self.addSubview(self.iconImageView)
        self.addSubview(self.title)
        self.addSubview(self.arrowImageView)
        
        self.title.text = titleString
        
        let titleWidth = titleString.textWidthFromTextString(text: titleString, textHeight: 30.auto(), fontSize: 13.auto(), isBold: false) + 2.auto()

        self.iconImageView.snp.makeConstraints({ (make) in
            make.centerY.equalTo(self)
            make.leading.equalTo(4.auto())
            make.size.equalTo(CGSize(width: 20.auto(), height: 20.auto()))
        })
        self.title.snp.makeConstraints({ (make) in
            make.leading.equalTo(self.iconImageView.snp.trailing).offset(4.auto())
            make.centerY.equalTo(self.snp.centerY)
            make.width.equalTo(titleWidth)
            make.height.equalTo(20.auto())
        })
        self.arrowImageView.snp.makeConstraints { make in
            make.leading.equalTo(self.title.snp.trailing).offset(8.auto())
            make.size.equalTo(CGSize(width: 16.auto(), height: 16.auto()))
            make.centerY.equalTo(self.snp.centerY)
        }
        return 4.auto()+20.auto()+4.auto()+titleWidth+8.auto()+16.auto()+8.auto()
    }

    lazy var iconImageView: UIImageView = {
        var temp: UIImageView = UIImageView()

        return temp
    }()

    lazy var title: UILabel = {
        var temp: UILabel = UILabel()
        temp.textColor = ADTheme.C4
        temp.font = ADTheme.B2
        return temp
    }()

    lazy var arrowImageView: UIImageView = {
        var temp: UIImageView = UIImageView()
        temp.image = bundleImageFromImageName("device_more_info_arrow_bird")?.rtlImage()
        return temp
    }()
}

class A4xMediaVideoTagsView : UIView {
        
    
    var recouceTags : [A4xLibraryVideoAiTagType]? {
        didSet{
            for index in 0..<(self.recouceTags?.count ?? 0){
                let recouceTag = recouceTags?.getIndex(index)
                let temp: A4xMediaVideoAiTagView = A4xMediaVideoAiTagView()
                temp.tag = index
                temp.imageView.image = recouceTag?.image()
                temp.title.text = recouceTag?.title()
                self.addSubview(temp)
                let perView: UIView = self.getSubViewByTag(tag: index > 0 ? index - 1 : 0)[0]
                
                temp.snp.makeConstraints({ (make) in
                    make.leading.equalTo(index > 0 ? perView.snp.trailing : 0).offset(index > 0 ? 5.auto() : 0)
                    make.top.equalTo(self.snp.top)
                    make.height.equalTo(30.auto())
                })
            }
        }
    }
    
    
    var recouceVerticalTags : ([A4xLibraryVideoAiTagType]?, [String]?) {
        didSet{
            for index in 0..<(self.recouceVerticalTags.0?.count ?? 0) {
                
                let recouceTag = recouceVerticalTags.0?.getIndex(index)
                let temp: A4xMediaVideoAiTagView = A4xMediaVideoAiTagView()
                temp.tag = index
                temp.imageView.image = recouceTag?.image()
                switch recouceTag {
                case .package_drop_off:
                    fallthrough
                case .package_pick_up:
                    fallthrough
                //case .package_exist:
                //fallthrough
                case .vehicle_enter:
                    fallthrough
                case .vehicle_out:
                    //fallthrough
                    //case .vehicle_held_up:
                    temp.tagViewRedIV.isHidden = false
                    break
                default:
                    temp.tagViewRedIV.isHidden = true
                }
                
                temp.title.text = index < (recouceVerticalTags.1?.count ?? 0) ? (recouceVerticalTags.1?[index] ?? "") : recouceTag?.title()
                self.addSubview(temp)
                let perView: UIView = self.getSubViewByTag(tag: index > 0 ? index - 1 : 0)[0]

                temp.snp.makeConstraints({ (make) in
                    make.leading.equalTo(0)
                    make.top.equalTo(index > 0 ? perView.snp.bottom : self.snp.top).offset(index > 0 ? 5.auto() : 0)
                    make.height.equalTo(30.auto())
                })
            }
        }
    }
    
    
    func configResourceLineFeedTags(isEvent: Bool, hasPossibleSubcategory: Bool, sources: ([A4xLibraryVideoAiTagType]? , [String]?)) -> (CGFloat, Bool) {
        
        self.subviews.forEach({ $0.removeFromSuperview() })
        var containBird = false
        var totalHeight: CGFloat = 0
        for index in 0..<(sources.0?.count ?? 0) {
            let recouceTag = sources.0?.getIndex(index)
            let titleString = sources.1?.getIndex(index) 
            var itemWidth = 0.0;
            
            var temp = UIView()
            
            if (recouceTag == .bird && hasPossibleSubcategory) {
                containBird = true
            }
            if (recouceTag == .bird && isEvent && hasPossibleSubcategory) {
                let tempview: A4xMediaVideoBirdTagButton = A4xMediaVideoBirdTagButton()
                itemWidth = tempview.configAiButton(titleString: titleString ?? "")
                tempview.tag = index
                tempview.birdImg = recouceTag?.image() ?? bundleImageFromImageName("main_libary_bird")?.rtlImage()
                temp = tempview
                
                DispatchQueue.main.a4xAfter(0.01) {
                    let startColor = UIColor.colorFromHex("#5AC4A7", alpha:0.15)
                    let endColor = UIColor.colorFromHex("#48E2B6", alpha:0.15)
                    tempview.gradientColor(CGPoint(x:0, y:0), CGPoint(x:0, y:1), [startColor.cgColor, endColor.cgColor])
                }
                self.addSubview(tempview)
            } else {
                let tempview: A4xMediaVideoAiTagView = A4xMediaVideoAiTagView()
                tempview.tag = index
                tempview.imageView.image = recouceTag?.image()
                tempview.title.text = titleString
                switch recouceTag {
                case .package_drop_off:
                    fallthrough
                case .package_pick_up:
                    fallthrough
                case .vehicle_enter:
                    fallthrough
                case .vehicle_out:
                    tempview.tagViewRedIV.isHidden = false
                    break
                default:
                    tempview.tagViewRedIV.isHidden = true
                }
                temp = tempview
                self.addSubview(tempview)
                
                var titleWidth = titleString?.textWidthFromTextString(text: titleString!, textHeight: 30.auto(), fontSize: 13.auto(), isBold: false) ?? 0
                titleWidth += 2.auto()
                itemWidth = 28.auto()+titleWidth+8.auto()
            }
            
            let leftGap = isEvent ? 8.auto() : 16.auto()
            let otherGap = isEvent ? (32+8+8+8).auto() : (16+16).auto()
            
            if index == 0 {
                temp.frame = CGRect(x: leftGap.auto(), y: 0, width: itemWidth, height: 30.auto())
                totalHeight += 30.auto();
            } else {
                let perView: UIView = self.getSubViewByTag(tag: index > 0 ? index - 1 : 0)[0]
                
                if (perView.maxX + 8.auto() + itemWidth + otherGap > UIScreen.main.bounds.width) {
                    
                    if (itemWidth + otherGap) > UIScreen.main.bounds.width {
                        itemWidth = UIScreen.main.bounds.width - otherGap
                    }
                    temp.frame = CGRect(x: leftGap, y: perView.maxY+5.auto(), width: itemWidth, height: 30.auto())
                    totalHeight += 35.auto();
                } else {
                    
                    temp.frame = CGRect(x: perView.maxX + 8.auto(), y: perView.origin.y, width: itemWidth, height: 30.auto())
                }
            }
        }
        return (totalHeight, containBird)
    }
    
}


class A4xMediaVideoAiTagImageView: UIView {
    
    func configBottomTagAiImageView(sources: ([A4xLibraryVideoAiTagType]? , [String]?)) -> CGFloat {
        
        self.subviews.forEach({ $0.removeFromSuperview() })

        var totalHeight: CGFloat = 0
        for index in 0..<(sources.0?.count ?? 0) {
            let recouceTag = sources.0?.getIndex(index)
            let temp: UIImageView = UIImageView()
            temp.tag = index
            temp.image = recouceTag?.image()
            self.addSubview(temp)
            
            let itemWidth = 24.auto()
            let itemHeight = 24.auto()
            let widthGap = 24.auto()
            let heightGap = 5.auto()
            if index == 0 {
                temp.frame = CGRect(x: 8.auto(), y: 0, width: itemWidth, height: itemHeight)
                totalHeight += itemWidth
            } else {
                let perView: UIView = self.getSubViewByTag(tag: index > 0 ? index - 1 : 0)[0]
                if (perView.maxX + itemWidth + widthGap + (32+8+8+8).auto() > UIScreen.main.bounds.width) {
                    
                    temp.frame = CGRectMake(8.auto(), itemHeight+heightGap, itemWidth, itemHeight)
                    totalHeight += (itemHeight+heightGap);
                } else {
                    
                    temp.frame = CGRect(x: perView.maxX+itemWidth, y: perView.origin.y, width: itemWidth, height: itemHeight)
                }
            }
        }
        return totalHeight;
    }
    
}
