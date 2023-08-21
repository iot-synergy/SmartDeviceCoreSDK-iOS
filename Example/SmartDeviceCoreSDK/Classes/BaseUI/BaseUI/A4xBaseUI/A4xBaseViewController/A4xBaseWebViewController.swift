//


//

//

import UIKit
import WebKit
import SmartDeviceCoreSDK

open class A4xBaseWebViewController: A4xBaseViewController {
    
    public var webvIsLoad: Bool = false
    
    private var isAddObserver: Bool = false
        
    private var urlString : String = ""
     
    public init(urlString: String) {
        super.init(nibName: nil, bundle: nil)
        self.urlString = urlString
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /** WKWebView */
    @objc public lazy var bgView: UIView = {
        let temp = UIView()
        temp.isUserInteractionEnabled = false
        temp.backgroundColor = UIColor.clear
        self.view.addSubview(temp)
        
        temp.snp.makeConstraints { (make) in
            make.top.equalTo(self.navView!.snp.bottom)
            make.leading.equalTo(0)
            make.width.equalTo(self.view.snp.width)
            make.bottom.equalTo(self.view.snp.bottom)
        }
        
        return temp
    }()
    
    @objc public lazy var webView: WKWebView = {
        let temp = WKWebView()
        temp.isHidden = true
        temp.navigationDelegate = self
        self.view.insertSubview(temp, at: 0)
        temp.snp.makeConstraints { (make) in
            make.leading.equalTo(self.bgView.snp.leading)
            make.width.equalTo(self.bgView.snp.width)
            make.top.equalTo(self.navView!.snp.bottom)
            make.bottom.equalTo(self.bgView.snp.bottom)
        }
        return temp
    }()

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.defaultNav() 
        
        self.bgView.isHidden = false
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: [.new], context: nil)
        isAddObserver = true
        self.loadWebView(urlString: self.urlString)
    }
    
    deinit {
        if isAddObserver {
            isAddObserver = !isAddObserver
            
            webView.removeObserver(self, forKeyPath: "estimatedProgress")
        }
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            guard let changes = change else { return }
            
            let newValue = changes[NSKeyValueChangeKey.newKey] as? Double ?? 0
            
            if newValue > 0.5 {
                if webView.scrollView.contentInset.bottom < 10 {
                    webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 90.auto(), right: 0)
                    webvIsLoad = true
                    self.bgView.hideToastActivity()
                }
                
            }
            
        }
    }
    
    private func loadWebView(urlString: String) {
        DispatchQueue.main.a4xAfter(0.01) {
            self.bgView.makeToastActivity(title: "") { (f) in }
        }
        
        if let url = URL(string: urlString) {
            self.webView.load(URLRequest(url: url))
        } else {
            
            self.view.makeToast(A4xBaseManager.shared.getLocalString(key: "request_timeout_and_try"))
            self.bgView.hideToastActivity()
        }
    }

}


extension A4xBaseWebViewController : WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        webvIsLoad = false
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.view.makeToast(A4xBaseManager.shared.getLocalString(key: "request_timeout_and_try"))
        self.bgView.hideToastActivity()
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if let requestError : NSError = error as NSError?  {
            let code = requestError.code
            if code == -1001 {
                self.view.makeToast(A4xBaseManager.shared.getLocalString(key: "request_timeout_and_try"))
            } else if code == -1009 {
                self.view.makeToast(A4xBaseManager.shared.getLocalString(key: "phone_weak_network_short"))
            } else {
                self.view.makeToast(A4xBaseManager.shared.getLocalString(key: "other_error_with_code"))//code
            }
        }
        self.bgView.hideToastActivity()
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("didFinish ")
        webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 90.auto(), right: 0)
        webvIsLoad = true
        self.webView.evaluateJavaScript("document.getElementsByClassName(\"error-page\")[0].innerHTML") { [weak self] (result, err) in
            if err == nil {
                
                
                
                let resultString = self?.urlString.replacingOccurrences(of: "en-us", with: A4xBaseAppLanguageType.language().zendeskValue())
                self?.loadWebView(urlString: resultString ?? "")
            } else {
                self?.showWebView()
            }
        }
    }
    
    func showWebView() {
        self.webView.isHidden = false
        self.navView?.title = webView.title
        self.bgView.hideToastActivity()
        
        if isAddObserver {
            
            //webView.removeObserver(self, forKeyPath: "estimatedProgress")
        }
    }
    

}
