

import Foundation
import Resolver
import A4xDeviceSettingSDK
import A4xDeviceSettingInterface
import BindInterface
import A4xLiveVideoUIKit
import A4xLiveVideoUIInterface
import BindUIkit
import BaseUI
import SmartDeviceCoreSDK
import MediaCodec

extension AppDelegate: ResolverRegistering {
    public static func registerAllServices() {
        Resolver.main.register { A4xDeviceSettingImpl() }.implements(A4xDeviceSettingInterface.self)
        Resolver.main.register { BindUIkitImpl() }.implements(BindInterface.self)
        Resolver.main.register { A4xLiveVideoUIImpl() }.implements(A4xLiveVideoUIInterface.self)
        A4xBaseManager.shared.setupBaseAdapter(adapterInstance: BaseCoreAdapter())
        A4xBaseManager.shared.setUpMediaCodecAdapter(adapterInstance: MediaCodecAdapter())
        A4xBaseManager.shared.setBaseLanguageAdapter(adapterInstance: BaseLanguageAdapter())
    }
}
