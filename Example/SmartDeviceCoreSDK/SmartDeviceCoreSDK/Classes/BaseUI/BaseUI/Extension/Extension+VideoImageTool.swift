//


import Foundation
import SmartDeviceCoreSDK

extension A4xBaseVideoImageTool {
    
    public func getThumbsImage(key: String, videoRatio: Int = 0) -> UIImage? {
        let image: UIImage? = try? Disk.retrieve("\(key)_thumb", from: .documents, as: UIImage.self)
        var cameraImageName = "home_temp_image"
        var doorbellImageName = "home_temp_image_doorbell"
        let defaultImgName = videoRatio == 0 ? cameraImageName : doorbellImageName
        let tempImage = bundleImageFromImageName(defaultImgName) ?? UIImage()
        return image ?? tempImage
    }
    
}


public func thumbImage(deviceID: String?, videoRatio: Int = 0) -> UIImage? { 
    guard let image = A4xBaseVideoImageTool.shared.getThumbsImage(key: deviceID ?? "", videoRatio: videoRatio) else {
        var cameraImageName : String
        var doorbellImageName : String
        cameraImageName = "home_temp_image"
        doorbellImageName = "home_temp_image_doorbell"
        
        let defaultImgName = videoRatio == 0 ? cameraImageName : doorbellImageName
        let defaultImg: UIImage = bundleImageFromImageName(defaultImgName) ?? UIImage()
        
        if let thumbPath = thumbUrl(deviceID: deviceID), FileManager.default.fileExists(atPath: thumbPath.relativePath) {
            if let data: Data = (try? Data(contentsOf: thumbPath))?.decryption() {
                let loimage = UIImage(data: data) ?? defaultImg
                A4xBaseVideoImageTool.shared.saveThumbsImage(key: deviceID ?? "", image: loimage)
                return loimage
            } else {
                return defaultImg
            }
        } else {
            return defaultImg
        }
    }
    return image
}
