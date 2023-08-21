//


//


//

import UIKit
import MediaCodec
import SmartDeviceCoreSDK

@objc open class A4xLibraryViewModel: NSObject {
    let pageSize : Int = 20
    var resoucesModels : [RecordBean] = Array()
    @objc open var resoucesPage : Int = 0
    @objc open var resoucesTotal : Int = 0
    @objc open var resourceHasMore : Bool = false
    
    
    func getEventRecordByFilter(deviceName: String?, isFromSDCard: Bool, isMore: Bool, date: Date, serialNumbers: [String]?, filter: A4xVideoLibraryFilterModel?, result: @escaping ([RecordEventBean]?, _ hasMore: Bool, _ eventCount: Int?, _ libraryCount: Int?, _ errorCode: Int?, _ error: String?) -> Void) {
        
        
        
        if !isMore {
            self.resoucesPage = 0
            self.resoucesModels.removeAll()
        }
        
        let filterEntry = FilterEntry()
        filterEntry.isFromSDCard = isFromSDCard
        let timeBetween = date.dayBetween
        filterEntry.startTimestamp = timeBetween.0
        filterEntry.endTimestamp = timeBetween.1
        filterEntry.marked = filter?.isSelect(other: .mark) ?? false ? 1 : 0
        filterEntry.missing = filter?.isSelect(other: .unread) ?? false ? 1 : 0
        filterEntry.tags = filter?.tags() ?? []
        filterEntry.serialNumbers = serialNumbers
        filterEntry.deviceName = deviceName
        filterEntry.doorbellTags = filter?.bellTags() ?? []
        filterEntry.deviceCallEventTag = filter?.getDeviceCallEventTag() ?? ""
        filterEntry.from = self.resoucesPage * self.pageSize
        filterEntry.to =  self.resoucesPage * self.pageSize + self.pageSize
        filterEntry.serialNumberToActivityZone = filter?.saveZonePointsources
        weak var weakSelf = self
        LibraryCore.getInstance().getEventRecordByFilter(filterEntry: filterEntry) { code, msg, dataModel in
            if code == 0 {
                let list = dataModel?.list
                let eventCount = dataModel?.eventCount
                let libraryCount = dataModel?.libraryCount

                if let strongSelf = weakSelf {
                    strongSelf.resoucesTotal = eventCount ?? 0
                    let showMax = (strongSelf.resoucesPage + 1) * strongSelf.pageSize
                    strongSelf.resourceHasMore = showMax < strongSelf.resoucesTotal
                    strongSelf.resoucesPage += 1
                    result(list, strongSelf.resourceHasMore, eventCount, libraryCount, code, nil)
                }
            } else {
                let errorString = isFromSDCard ? A4xBaseManager.shared.getLocalString(key: "faied_get_sdvideo") : A4xBaseManager.shared.getLocalString(key: "failed_information")
                result(nil, true, 0, 0, code, errorString)
            }
        } onFail: { code, msg in
            let errorString = isFromSDCard ? A4xBaseManager.shared.getLocalString(key: "faied_get_sdvideo") : A4xBaseManager.shared.getLocalString(key: "failed_information")
            result(nil, true, 0, 0, code, errorString)
        }
    }
    
    
    func getEventDetail(isFromSDCard: Bool, serialNumbers: [String]?, startTimestamp: TimeInterval?, endTimestamp: TimeInterval?, filter: A4xVideoLibraryFilterModel?, videoEventKey: String, result: @escaping ([RecordBean]?, _ total: Int?, _ error: String?) -> Void) {
        
        
        
        let filterEntry = FilterEntry()
        filterEntry.isFromSDCard = isFromSDCard
        filterEntry.marked = filter?.isSelect(other: .mark) ?? false ? 1 : 0
        filterEntry.missing = filter?.isSelect(other: .unread) ?? false ? 1 : 0
        filterEntry.tags = filter?.tags() ?? []
        filterEntry.serialNumbers = serialNumbers
        filterEntry.doorbellTags = filter?.bellTags() ?? []
        filterEntry.deviceCallEventTag = filter?.getDeviceCallEventTag() ?? ""
        filterEntry.from = 0
        filterEntry.to = 1000
        filterEntry.videoEventKey = videoEventKey
        filterEntry.startTimestamp = startTimestamp
        filterEntry.endTimestamp = endTimestamp
        LibraryCore.getInstance().getEventDetail(isFromSDCard: isFromSDCard, videoEventKey: videoEventKey) { code, msg, libraryEventDetailBean in
            if code == 0 {
                let list = libraryEventDetailBean?.list
                let total = libraryEventDetailBean?.total
                if list?.count ?? 0 > 0 {
                    result(list, total, nil)
                } else {
                    result(nil, nil, nil)
                }
            } else {
                let errorString = isFromSDCard ? A4xBaseManager.shared.getLocalString(key: "faied_get_sdvideo") : A4xBaseManager.shared.getLocalString(key: "failed_information")
                result(nil, nil, errorString)
            }
        } onFail: { code, msg in
            let errorString = isFromSDCard ? A4xBaseManager.shared.getLocalString(key: "faied_get_sdvideo") : A4xBaseManager.shared.getLocalString(key: "failed_information")
            result(nil, nil, errorString)
        }
    }
    
    
    func getVideosByFilter(isMore: Bool, date: Date, filter: A4xVideoLibraryFilterModel?, result: @escaping ([RecordBean]?,  _ hasMore: Bool, _ total: Int?, _ error: String? ) -> Void) {
        A4xLog("-----------> getResources normal selectlibrary ")
        
        if !isMore {
            self.resoucesPage = 0
            self.resoucesModels.removeAll()
        }
        
        let filterEntry = FilterEntry()
        let timeBetween = date.dayBetween
        filterEntry.startTimestamp = timeBetween.0
        filterEntry.endTimestamp = timeBetween.1
        filterEntry.marked = filter?.isSelect(other: .mark) ?? false ? 1 : 0
        filterEntry.missing = filter?.isSelect(other: .unread) ?? false ? 1 : 0
        filterEntry.tags = filter?.tags() ?? []
        filterEntry.serialNumbers = filter?.filterTagAllDeviceId()
        filterEntry.doorbellTags = filter?.bellTags() ?? []
        filterEntry.deviceCallEventTag = filter?.getDeviceCallEventTag() ?? ""
        filterEntry.from = self.resoucesPage * self.pageSize
        filterEntry.to =  self.resoucesPage * self.pageSize + self.pageSize
        filterEntry.serialNumberToActivityZone = filter?.saveZonePointsources
        
        weak var weakSelf = self
        LibraryCore.getInstance().getVideosByFilter(filterEntry: filterEntry) { code, msg, model in
            if code == 0 {
                let list = model?.list
                let total = model?.total
                if let strongSelf = weakSelf {
                    strongSelf.resoucesTotal = total ?? 0
                    let showMax = (strongSelf.resoucesPage + 1) * strongSelf.pageSize
                    strongSelf.resourceHasMore = showMax < strongSelf.resoucesTotal
                    strongSelf.resoucesPage += 1
                    result(list, strongSelf.resourceHasMore, total, nil)
                }
            }
        } onFail: { code, msg in
            result(nil, true, 0, A4xBaseManager.shared.getLocalString(key: "failed_information"))
        }
    }
    
    
    func getLibraryStatus(isFromSDCard: Bool, start: TimeInterval, end: TimeInterval, serialNumbers: [String]? = [], filter: A4xVideoLibraryFilterModel?, result: @escaping ((Set<String>) -> Void)) {
        
        let filterEntry = FilterEntry()
        filterEntry.isFromSDCard = isFromSDCard
        filterEntry.startTimestamp = start
        filterEntry.endTimestamp = end
        filterEntry.marked = filter?.isSelect(other: .mark) ?? false ? 1 : 0
        filterEntry.missing = filter?.isSelect(other: .unread) ?? false ? 1 : 0
        filterEntry.tags = filter?.tags() ?? []
        filterEntry.serialNumbers = serialNumbers
        filterEntry.doorbellTags = filter?.bellTags() ?? []
        filterEntry.deviceCallEventTag = filter?.getDeviceCallEventTag() ?? ""
        
        LibraryCore.getInstance().getLibraryStatus(filterEntry: filterEntry, onSuccess: { code, msg, libraryStatusListBeans in
            var set : Set<String> = Set()
            if code == 0 {
                let list = libraryStatusListBeans
                list?.forEach({ (m) in
                    if let date = m.date  {
                        set.insert(date)
                    }
                })
            } else {
                
            }
            result(set)
        }, onFail: { code, msg in
            
            result(Set())
        })
    }
    
    
    public func deleteRecord(traceIdList: [String], result: @escaping (_ error : String?)->Void) {
        LibraryCore.getInstance().deleteRecord(traceIdList: traceIdList) { code, msg, res in
            result(nil)
        } onFail: { code, msg in
            result(msg)
        }
    }
}
