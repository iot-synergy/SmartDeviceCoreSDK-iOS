//


//


//

import UIKit
import MobileCoreServices
import AssetsLibrary
import AVKit
import AVFoundation
import SmartDeviceCoreSDK
import Photos
import BaseUI

class A4xScanSelectQrcodeViewController: UIImagePickerController {
    
    var selectResult : ((String) -> Void)?
    var picker: UIImagePickerController?
    
    var isDownLoadView: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isDownLoadView {
            self.photoMovieShow()
        } else {
            self.sourceType = .photoLibrary
            self.delegate = self
            self.allowsEditing = false
            self.navigationBar.tintColor = ADTheme.Theme
            let attDic = [NSAttributedString.Key.foregroundColor :   ADTheme.C1,
                          NSAttributedString.Key.font    :   ADTheme.H2];
            self.navigationBar.titleTextAttributes = attDic
            if let _ = UIImagePickerController.availableMediaTypes(for: UIImagePickerController.SourceType.photoLibrary){
                self.mediaTypes = ["public.image"]
            }

            let leftBar : UIBarButtonItem =  UIBarButtonItem(image: bundleImageFromImageName("icon_back_gray")?.rtlImage(), style: .plain, target: self, action: #selector(backUpController))
            self.navigationItem.leftBarButtonItem = leftBar
        }

    }
    
    @objc
    func backUpController() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func photoMovieShow() {
        
        
        weak var weakSelf=self

        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            //获取相册权限
                      PHPhotoLibrary.requestAuthorization({ [weak self] (status) in
                          switch status {
                          case .notDetermined: break
                          
                          case .restricted://此应用程序没有被授权访问的照片数据
                              break
                          case .denied://用户已经明确否认了这一照片数据的应用程序访问
                              break
                          case .authorized://已经有权限
                            if self?.picker == nil {
                                self?.picker = UIImagePickerController()
                                self?.picker?.sourceType = UIImagePickerController.SourceType.photoLibrary
                                self?.picker?.delegate = self
                                //控制相册中显示视频和照片
                                //self.picker?.mediaTypes = [kUTTypeMovie as String]
                                self?.picker?.mediaTypes = ["public.movie", "public.image"]
                                self?.picker?.allowsEditing = false
                            }
                            self?.present(self?.picker ?? UIImagePickerController(), animated: true, completion: nil)
                              break
                          case .limited: break
                            
                          }
                      })

    

        } else {
            
        }
    }
 
}


extension A4xScanSelectQrcodeViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate{

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }

        let vc = A4xScanSelectResultViewController()
        vc.image = selectImage
        vc.selectResult = self.selectResult
        self.pushViewController(vc, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true)
    }
    
    func navigationBar(_ navigationBar: UINavigationBar, shouldPush item: UINavigationItem) -> Bool { 
        return true
    }
    
    func navigationBar(_ navigationBar: UINavigationBar, didPush item: UINavigationItem) { 
        
    }
    
    func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        return true
    }
    
    func navigationBar(_ navigationBar: UINavigationBar, didPop item: UINavigationItem){
        
    }
}
