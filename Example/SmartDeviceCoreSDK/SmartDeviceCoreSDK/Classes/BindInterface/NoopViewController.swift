//


import Foundation

class NoopViewController: UIViewController {
    
    var isPresented: Bool = false
    
    init(isPresented: Bool) {
        super.init(nibName: nil, bundle: nil)
        self.isPresented = isPresented
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: self.view.width, height: 100)
        button.center = self.view.center
        button.backgroundColor = .white
        button.setTitle("not register bind impl, click back", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.addTarget(self, action: #selector(self.clickBack), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        self.view.backgroundColor = .white
        self.view.addSubview(button)
    }
    
    
    @objc private func clickBack() {
        if isPresented {
            self.navigationController?.dismiss(animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}
