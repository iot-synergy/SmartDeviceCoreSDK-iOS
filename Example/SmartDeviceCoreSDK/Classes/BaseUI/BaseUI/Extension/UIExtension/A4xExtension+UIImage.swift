//


//


//

import Foundation
import UIKit
import CoreImage
import SmartDeviceCoreSDK

public extension UIImage {
    
    
    var mostColor: UIColor {
        //获取图片信息
        let imgWidth: Int = Int(self.size.width) / 2
        let imgHeight: Int = Int(self.size.height) / 2
        
        //位图的大小 ＝ 图片宽 ＊ 图片高 ＊ 图片中每点包含的信息量
        let bitmapByteCount = imgWidth * imgHeight * 4
        
        //使用系统的颜色空间
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        //根据位图大小，申请内存空间
        let bitmapData = malloc(bitmapByteCount)
        defer { free(bitmapData) }
        
        //创建一个位图
        let context = CGContext(data: bitmapData,
                                width: imgWidth,
                                height: imgHeight,
                                bitsPerComponent: 8,
                                bytesPerRow: imgWidth * 4,
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        //图片的rect
        let rect = CGRect(x: 0, y: 0, width: CGFloat(imgWidth), height: CGFloat(imgHeight))
        
        //将图片画到位图中
        context?.draw(self.cgImage!, in: rect)
        
        //获取位图数据
        let bitData = context?.data
        let data = unsafeBitCast(bitData, to: UnsafePointer<CUnsignedChar>.self)
        
        let cls = NSCountedSet.init(capacity: imgWidth * imgHeight)
        
        for x in 0..<imgWidth {
            for y in 0..<imgHeight {
                
                //let offSet = (y * imgWidth + x) * 4
                
                let offSet = x * y * 4
                let r = (data + offSet).pointee
                let g = (data + offSet + 1).pointee
                let b = (data + offSet + 2).pointee
                let a = (data + offSet + 3).pointee
                if a > 0 {
                    //去除透明
                    if !(r == 255 && g == 255 && b == 255) {
                        //去除白色
                        cls.add([CGFloat(r), CGFloat(g), CGFloat(b), CGFloat(a)])
                    }
                }
            }
        }
        
        //找到出现次数最多的颜色
        let enumerator = cls.objectEnumerator()
        var maxColor: Array<CGFloat>? = nil
        var maxCount = 0
        while let curColor = enumerator.nextObject() {
            let tmpCount = cls.count(for: curColor)
            if tmpCount >= maxCount{
                maxCount = tmpCount
                maxColor = curColor as? Array<CGFloat>
            }
        }
        return UIColor.init(red: (maxColor![0] / 255), green: (maxColor![1] / 255), blue: (maxColor![2] / 255), alpha: (maxColor![3] / 255))
    }
    
    
    func addColor(_ color1: UIColor, with color2: UIColor) -> UIColor {
        var (r1, g1, b1, a1) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))
        var (r2, g2, b2, a2) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))
        
        color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        
        return UIColor(red: min(r1 + r2, 1), green: min(g1 + g2, 1), blue: min(b1 + b2, 1), alpha: (a1 + a2) / 2)
    }
    
    //
    func multiplyColor(_ color: UIColor, by multiplier: CGFloat) -> UIColor {
        var (r, g, b, a) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: r * multiplier, green: g * multiplier, blue: b * multiplier, alpha: a)
    }
    
    
    
    
    
    //
    
    
    
    
    
    /**
     设置是否是圆角(默认:3.0,图片大小)
     */
    func isRoundCorner() -> UIImage{
        return self.isRoundCorner(radius: 3.0, size: self.size)
    }
    
    /**
     设置是否是圆角
     - parameter radius: 圆角大小
     - parameter size:   size
     - returns: 圆角图片
     */
    func isRoundCorner(radius: CGFloat, size: CGSize) -> UIImage {
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        //开始图形上下文
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        
        let context = UIGraphicsGetCurrentContext()
        guard context != nil else {
            return UIImage()
        }
        //绘制路线
        context!.addPath(UIBezierPath(roundedRect: rect,
                                      byRoundingCorners: UIRectCorner.allCorners,
                                      cornerRadii: CGSize(width: radius, height: radius)).cgPath)
        //裁剪
        UIGraphicsGetCurrentContext()?.clip()
        //将原图片画到图形上下文
        self.draw(in: rect)
        context!.drawPath(using: .fillStroke)
        guard let output = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() }
        //关闭上下文
        UIGraphicsEndImageContext()
        return output
    }
    
    /**
     设置圆形图片
     - returns: 圆形图片
     */
    func isCircleImage() -> UIImage {
        
        //开始图形上下文
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
        //获取图形上下文
        let contentRef: CGContext = UIGraphicsGetCurrentContext()!
        //设置圆形
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        //根据 rect 创建一个椭圆
        contentRef.addEllipse(in: rect)
        //裁剪
        contentRef.clip()
        //将原图片画到图形上下文
        self.draw(in: rect)
        //从上下文获取裁剪后的图片
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        //关闭上下文
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func resizedImage(size: CGSize) -> UIImage {
        return autoreleasepool {() ->UIImage in
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            self.draw(in: CGRect(origin: .zero, size: size))
            let image = UIGraphicsGetImageFromCurrentImageContext() ?? self
            UIGraphicsEndImageContext()
            return image
        }
    }
    
    
    func blurred(radius: CGFloat) -> UIImage {
        var ciContext: CIContext?
        if #available(iOS 8.0, *) {
            ciContext = CIContext()
        } else {
            ciContext = CIContext(options: nil)
        }
        guard let cgImage = cgImage else { return self }
        return autoreleasepool { () -> UIImage in
            let inputImage = CIImage(cgImage: cgImage)
            guard let ciFilter = CIFilter(name: "CIGaussianBlur") else { return self }
            ciFilter.setValue(inputImage, forKey: kCIInputImageKey)
            ciFilter.setValue(radius, forKey: "inputRadius")
            guard let resultImage = ciFilter.value(forKey: kCIOutputImageKey) as? CIImage else { return self }
            
            guard let cgImage2 = ciContext?.createCGImage(resultImage, from: inputImage.extent) else { return self }
            return UIImage(cgImage: cgImage2)
        }
        
    }
    
    static var buttonNormallImage: UIImage {
        return UIImage.color(gradColor: A4xBaseGradColor(PostionBegin: A4xBaseGradLocation.leftLocation(), PostionEnd: A4xBaseGradLocation.rightLocation(), Colors: [ADTheme.Theme.withAlphaComponent(0.9).cgColor , ADTheme.Theme.cgColor], Locations: [0,1])) ?? UIImage.init(color: UIColor.clear)!
    }
    
    static var buttonPressImage : UIImage {
        return UIImage.color(gradColor: A4xBaseGradColor(PostionBegin: A4xBaseGradLocation.leftLocation(), PostionEnd: A4xBaseGradLocation.rightLocation(), Colors: [ADTheme.Theme.withAlphaComponent(0.9).cgColor , ADTheme.Theme.cgColor], Locations: [0,1])) ?? UIImage.init(color: UIColor.clear)!
    }
    
    static func color (gradColor: A4xBaseGradColor, size: CGSize = CGSize(width: 30, height: 30)) -> UIImage? {
        guard gradColor.isVaild() else {
            return nil
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.saveGState()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var colorComponents: [CGFloat] = []
        gradColor.colors?.forEach({ (cgc) in
            cgc.components?.forEach({ (com) in
                colorComponents.append(com)
            })
        })
        
        guard let gradient = CGGradient(colorSpace: colorSpace, colorComponents: colorComponents, locations: gradColor.locations, count: gradColor.locations.count) else {
            return nil
        }
        
        let startPoint = CGPoint(x: size.width * gradColor.beginPostion.xRatio, y: size.height * gradColor.beginPostion.yRatio )
        let endPoint = CGPoint(x: size.width * gradColor.endPostion.xRatio, y: size.height * gradColor.endPostion.yRatio)
        context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: UInt32(0)))
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        context.restoreGState()
        return img
    }
    
    static func color(color: UIColor) -> UIImage? {
        let rect = CGRect(origin: .zero, size: CGSize(width: 1, height: 1))
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
    
    
    func recognitionQrcode(comple: @escaping (String?) -> Void) {
        DispatchQueue.global().async {
            var string: String? = nil
            defer {
                DispatchQueue.main.async {
                    comple(string)
                }
            }
            
            guard let cgImage = self.cgImage else {
                string = nil
                return
            }
            
            let ciImage = CIImage(cgImage: cgImage)
            var options: [String : String] = Dictionary()
            options[CIDetectorAccuracy] = CIDetectorAccuracyHigh
            
            let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: CIContext(), options: options)
            let features = detector?.features(in: ciImage)
            
            for modle in features ?? [] where modle is CIQRCodeFeature {
                if let temp = modle as? CIQRCodeFeature {
                    string = temp.messageString
                    return
                }
            }
        }
    }
    
    
    
    func reduce(minSize: CGFloat = 256) -> UIImage? {
        let actualHeight = self.size.height
        let actualWidth = self.size.width
        var newWidth: CGFloat = 0
        var newHeight: CGFloat = 0
        
        if(actualWidth > actualHeight) {
            //宽图
            newHeight = minSize
            newWidth = actualWidth / actualHeight * newHeight
        } else {
            //长图
            newWidth = minSize
            newHeight = actualHeight / actualWidth * newWidth
        }
        let imageRect = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
        UIGraphicsBeginImageContext(imageRect.size)
        self.draw(in: imageRect)
        let theImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return theImage
    }

    static func agenerateQrcode(codeString: String, size: CGFloat = 300, result: @escaping (UIImage?) -> Void) {
        DispatchQueue.main.async  {
            var image : UIImage? = nil
            let filter : CIFilter? = CIFilter(name: "CIQRCodeGenerator")

            filter?.setDefaults()
            
            let data = codeString.data(using: .utf8)
            filter?.setValue(data, forKey: "inputMessage")
            filter?.setValue("L", forKey: "inputCorrectionLevel")

            let cimage = filter?.outputImage
            
            guard let ciimage = cimage else {
                DispatchQueue.main.async {
                    result(image)
                }
                return
            }
            
            let extent = cimage?.extent ?? CGRect(x: 0, y: 0, width: size, height: size)
            let scale = min(size / extent.width , size / extent.height)
            
            let width = Int(extent.width * scale)
            let height = Int(extent.height * scale)
            
            let cs = CGColorSpaceCreateDeviceGray()
            
            let bitmapRef = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: CGImageAlphaInfo.none.rawValue)
            
            
            let context = CIContext(options: nil)
            let bitMapImage = context.createCGImage(ciimage, from: extent)
            
            if bitMapImage == nil {
                DispatchQueue.main.async {
                    result(image)
                }
                return
            }
            
            bitmapRef?.interpolationQuality = .none
            bitmapRef?.scaleBy(x: scale, y: scale)
            bitmapRef?.draw(bitMapImage!, in: extent)
            
            let cgimg: CGImage? = bitmapRef?.makeImage()
            
            if cgimg == nil {
                DispatchQueue.main.async {
                    result(image)
                }
                return
            }
            image = UIImage(cgImage: cgimg!)
            DispatchQueue.main.async {
                result(image)
            }
            
        }
    }
    
 
    
    
    func imageDataToUIImage(fromImageData: Data?, width: Int, height: Int) -> UIImage? {
        let colorSpaceRef = CGColorSpaceCreateDeviceRGB()
        let bitmapInfoConfig = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue | CGImageByteOrderInfo.order32Big.rawValue).union(CGBitmapInfo())
        let uint8Ptr = UnsafeMutablePointer<UInt8>.allocate(capacity: fromImageData?.count ?? 0)
        let buffer = UnsafeMutableBufferPointer(start: uint8Ptr, count: fromImageData?.count ?? 0)
        _ = buffer.initialize(from: fromImageData ?? Data())
        
        //You can convert it to `UnsafeRawPointer`
        let rawPtr = buffer.baseAddress//UnsafeMutableRawPointer(uint8Ptr)
        
        guard let context = CGContext(data: rawPtr, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: Int(width) * 4, space: colorSpaceRef, bitmapInfo: bitmapInfoConfig.rawValue) else {
            return nil
        }
        
        var imageRef = context.makeImage()
        
        guard let cgImg = imageRef else {
            uint8Ptr.deallocate()
            return nil
        }
        uint8Ptr.deallocate()
        //imageRef = nil
        //buffer.deallocate()
        return UIImage(cgImage: cgImg)
    }
    
   
    func image(fromPixelValues pixelValues: [UInt8]?, width: Int, height: Int) -> CGImage? {
        var imageRef: CGImage?
        if var pixelValues = pixelValues {
            let bitsPerComponent = 8
            let bytesPerPixel = 4
            let bitsPerPixel = bytesPerPixel * bitsPerComponent
            let bytesPerRow = bytesPerPixel * width
            let totalBytes = height * bytesPerRow
            
            imageRef = withUnsafePointer(to: &pixelValues, {
                ptr -> CGImage? in
                var imageRef: CGImage?
                let colorSpaceRef = CGColorSpaceCreateDeviceRGB()
                let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue).union(CGBitmapInfo())
                let data = UnsafeRawPointer(ptr.pointee).assumingMemoryBound(to: UInt8.self)
                let releaseData: CGDataProviderReleaseDataCallback = {
                    (info: UnsafeMutableRawPointer?, data: UnsafeRawPointer, size: Int) -> () in
                }
                
                if let providerRef = CGDataProvider(dataInfo: nil, data: data, size: totalBytes, releaseData: releaseData) {
                    imageRef = CGImage(width: width,
                                       height: height,
                                       bitsPerComponent: bitsPerComponent,
                                       bitsPerPixel: bitsPerPixel,
                                       bytesPerRow: bytesPerRow,
                                       space: colorSpaceRef,
                                       bitmapInfo: bitmapInfo,
                                       provider: providerRef,
                                       decode: nil,
                                       shouldInterpolate: false,
                                       intent: CGColorRenderingIntent.defaultIntent)
                }
                
                return imageRef
            })
        }
        return imageRef
    }
    
    
    var buffer: CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.size.width), Int(self.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
    
    func resize(pixelBuffer: CVPixelBuffer) -> CVPixelBuffer? {
        
        let imageSide = 300
        var ciImage = CIImage(cvPixelBuffer: pixelBuffer, options: nil)
        let transform = CGAffineTransform(scaleX: CGFloat(imageSide) / CGFloat(CVPixelBufferGetWidth(pixelBuffer)), y: CGFloat(imageSide) / CGFloat(CVPixelBufferGetHeight(pixelBuffer)))
        ciImage = ciImage.transformed(by: transform).cropped(to: CGRect(x: 0, y: 0, width: imageSide, height: imageSide))
        //旋转
        //ciImage = ciImage.oriented(CGImagePropertyOrientation.right)
        
        let ciContext = CIContext()
        var resizeBuffer: CVPixelBuffer?
        
        CVPixelBufferCreate(kCFAllocatorDefault, imageSide, imageSide, kCVPixelFormatType_32ARGB, nil, &resizeBuffer)
        ciContext.render(ciImage, to: resizeBuffer!)
        return resizeBuffer
    }

}

extension UIImage {
    public func rtlImage() -> UIImage {
        if A4xBaseAppLanguageType.language() == .hebrew || A4xBaseAppLanguageType.language() == .arab {
            return UIImage.init(cgImage: self.cgImage!, scale: self.scale, orientation: .upMirrored)
        }
        return self
    }
}

