//


//


//

import UIKit
import SmartDeviceCoreSDK

enum A4xFullLiveRightMenuType {
    case resolution
    case magicMic
}

class A4xFullLiveVideoRightMenuView: UIView {
    
    var selectResolutionBlock: ((A4xVideoSharpType) -> Void)?
    
    var resolutionIntroBlock: (() -> Void)?
    
    var supportResolutionList: [A4xVideoSharpType] = [] {
        didSet {
            self.tableView.reloadData()
            if self.selectedResolutionType == nil {
                self.selectedResolutionType = .standard_1
            }
        }
    }
    
    private var _selectedResolutionType: A4xVideoSharpType?
    
    var selectedResolutionType: A4xVideoSharpType? {
        set {
            _selectedResolutionType = newValue
            guard let sel =  _selectedResolutionType else {
                return
            }
            
            var selIndex = -1
            for (index, item) in supportResolutionList.enumerated() {
                if item == sel {
                    selIndex = index
                }
            }
            
            if selIndex != -1 {
                self.tableView.selectRow(at: IndexPath(row: selIndex, section: 0), animated: true, scrollPosition: UITableView.ScrollPosition.none)
            }
        }
        get {
            return _selectedResolutionType
        }
    }
    
    
    var curRightMenuViewType: A4xFullLiveRightMenuType = .resolution {
        didSet {
            if curRightMenuViewType == .magicMic {
                self.tableView.reloadData()
            }
        }
    }
    
    var bgArrowImage: UIImage? = A4xLiveUIResource.UIImage(named: "video_sharp_arrow")?.rtlImage()
    var tableViewHeight: CGFloat = 110
    
    private lazy var bgArrawHeight: CGFloat = {
        return self.bgArrowImage?.size.height ?? 0
    }()
    
    override init(frame: CGRect = CGRect.zero) {
        
        super.init(frame: frame)
        self.tableView.isHidden = false
        self.tableView.addObserver(self, forKeyPath: "contentSize", options: [], context: nil)
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("A4xFullLiveVideoRightMenuView ==> deinit")
        self.tableView.removeObserver(self, forKeyPath: "contentSize")
    }
    



    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let  ctheight : CGFloat = tableView.contentSize.height
   
        self.tableView.frame = CGRect(x: 0, y: (self.height - ctheight) / 2 , width: self.width, height: ctheight)

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()




    }
    
    private lazy var tableView: UITableView = {
        let temp = UITableView(frame: CGRect.zero, style: UITableView.Style.plain);
        temp.backgroundColor = UIColor.clear
        temp.separatorInset = UIEdgeInsets.zero
        temp.rowHeight = UITableView.automaticDimension
        temp.estimatedRowHeight = 30
        temp.accessibilityIdentifier = "tableView"
        temp.separatorColor = UIColor.clear
        temp.delegate = self
        temp.dataSource = self
        self.addSubview(temp)
        return temp
    }()
    
}


extension A4xFullLiveVideoRightMenuView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return self.supportResolutionList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        var cell = tableView.dequeueReusableCell(withIdentifier: "A4xFullLiveVideoResolutionSetViewCell") as? A4xFullLiveVideoResolutionSetViewCell
        if cell == nil {
            cell = A4xFullLiveVideoResolutionSetViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "A4xFullLiveVideoResolutionSetViewCell")
        }
        cell?.title = self.supportResolutionList[indexPath.row].name()
        cell?.resolutionIntroBlock = self.resolutionIntroBlock
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let currentSelect = self.supportResolutionList[indexPath.row]
        if let last = self.selectedResolutionType {
            if last == currentSelect {
                return
            }
        }
        self.selectedResolutionType = currentSelect
        DispatchQueue.main.a4xAfter(1) {
            self.selectResolutionBlock?(currentSelect)
        }
    
    }
    
}
