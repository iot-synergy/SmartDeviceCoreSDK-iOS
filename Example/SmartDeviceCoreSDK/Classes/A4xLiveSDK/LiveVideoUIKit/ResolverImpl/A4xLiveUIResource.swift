//



import Foundation
import SmartDeviceCoreSDK
import Lottie
import UIKit
import BaseUI

class A4xLiveUIResource {
    
    static func UIImage(named: String) -> UIImage? {
        return bundleImageFromImageName(named, for: A4xLiveUIResource.self)
    }
    
    
    static func Animation(named: String) -> LottieAnimation? {
        return LottieAnimation.named(named, bundle: a4xBaseBundle(for: A4xLiveUIResource.self))
    }
    
    static func AnimationView(name: String) -> LottieAnimationView {
        return LottieAnimationView(name: name, bundle: a4xBaseBundle(for: A4xLiveUIResource.self))
    }
    
    
    static func UIImage(gifName: String) -> UIImage {
        return UIKit.UIImage.init(gifName: gifName, for: A4xLiveUIResource.self)
    }

}
