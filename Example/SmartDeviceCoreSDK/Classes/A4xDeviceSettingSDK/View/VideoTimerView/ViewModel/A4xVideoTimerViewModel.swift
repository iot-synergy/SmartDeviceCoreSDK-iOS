
import Foundation
import SmartDeviceCoreSDK

extension Date {
    
    func checkLoadDate(maxTimeRange: Int64, unitTime: Int = 3600, loadHours: Set<Int>)
    -> [(fromDate: Date, toDate: Date)] {
        
        
        let currentTimeInterval = self.timeIntervalSince1970
        
        
        let unitDouble = Double(unitTime)

        
        let halfShow = TimeInterval(maxTimeRange / 2)

        
        let fromMinHours: Int64 = Int64(floor(((currentTimeInterval - halfShow) / unitDouble)))

        
        let toMaxHours: Int64 = Int64(ceil(((currentTimeInterval + halfShow) / unitDouble)))
        
        
        
        
        let loadDataHours = loadHours.filter { (hours) -> Bool in
            if hours >= fromMinHours || hours <= toMaxHours {
                return true
            }
            return false
        }

        let requestDate = Array(fromMinHours...toMaxHours).filter { (hours) -> Bool in
            return !loadDataHours.contains(Int(hours))

        }.sorted()

        guard requestDate.count > 0 else {
            return []
        }

        var beginloadDate: [(fromDate: Date, toDate: Date)] = []
        
        var tempChild: [Int64] = []

        requestDate.forEach { (body) in
            
            let lastValue = tempChild.last
            
            if lastValue == nil || body - lastValue! == 1 {
                tempChild.append(body)
            } else {
                
                if tempChild.count > 0 {
                    beginloadDate.append((fromDate: Date(timeIntervalSince1970: TimeInterval((tempChild.first ?? 0) * Int64(unitTime))), toDate: Date(timeIntervalSince1970: TimeInterval((tempChild.last ?? 0) * Int64(unitTime) + Int64(unitTime - 1)))))
                }
                tempChild = [body]
            }
        }

        if tempChild.count > 0 {
            beginloadDate.append((fromDate: Date(timeIntervalSince1970: TimeInterval((tempChild.first ?? 0) * Int64(unitTime))), toDate: Date(timeIntervalSince1970: TimeInterval((tempChild.last ?? 0) * Int64( unitTime) + Int64(unitTime - 1)))))
        }
        
        //return [(fromDate: Date(timeIntervalSince1970: currentTimeInterval - 3600 * 12), toDate: Date(timeIntervalSince1970: currentTimeInterval + 3600 * 12))]

        return beginloadDate
    }
    
    static func dataToUnitTimes(fromDate: Date, toDate: Date, unitTime: Int = 3600) -> [Int] {
        let fromHours : Int = Int(floor(fromDate.timeIntervalSince1970 / Double(unitTime)))
        let toHours : Int = Int(floor(toDate.timeIntervalSince1970 / Double(unitTime)))
        return Array(fromHours...toHours)
    }
}

class A4xVideoTimerViewModel {
    var loadDataUnits : Set<Int> = []
    var loadingUnits : Set<Int> = []
    var dataSources : [A4xVideoTimeModel] = []
    
    private var loadMinDataBlock: ((_ fromDate : Date , _ toDate : Date , _ comple: @escaping ((_ isError: Bool, _ dateSourde: [A4xVideoTimeModel]?, _ fromDate: Date, _ toData: Date) -> Void))-> Void )
    
    init(loadDataBlock: @escaping ((_ fromDate : Date , _ toDate : Date , _ comple : @escaping ((_ isError : Bool , _ dateSourde : [A4xVideoTimeModel]? ,_  fromDate : Date , _ toDate : Date) -> Void))-> Void )) {
        loadMinDataBlock = loadDataBlock
    }
    
    var onDataSourcesChange : (([A4xVideoTimeModel]) -> Void)?
    
    func clearData() {
        loadDataUnits.removeAll()
        loadingUnits.removeAll()
        dataSources.removeAll()
    }
    
    
    func loadData(currentTime: Date, maxTimeRange: TimeInterval, comple: @escaping (([A4xVideoTimeModel]) -> Void)) {
        
        
        let checkLoadDatas = currentTime.checkLoadDate(maxTimeRange: Int64(maxTimeRange), loadHours: loadDataUnits.union(loadingUnits))
        
        A4xLog("A4xVideoTimerViewModel loadData: \(checkLoadDatas)")
        
        weak var weakSelf = self
        
        checkLoadDatas.forEach { [weak self] (fromDate, toDate) in
            
            guard let strongSelf = weakSelf else {
                return
            }
            
            A4xLog("-----------> UTC(世界时间) fromDate: \(fromDate) toDate: \(toDate)")
            
            var datas: Set<Int> = Set(Date.dataToUnitTimes(fromDate: fromDate, toDate: toDate))
            
            datas.subtract(loadingUnits)
            
            loadingUnits = loadingUnits.union(datas)
            
            
            strongSelf.loadMinDataBlock(fromDate, toDate) { (isError, dateSourde, minFromDate, minToDate) in
                
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.loadingUnits = strongSelf.loadingUnits.symmetricDifference(datas)
                
                if isError {
                    return
                }
                
                strongSelf.loadDataUnits = strongSelf.loadDataUnits.union(datas)
                
                let array: Set<A4xVideoTimeModel> = Set(strongSelf.dataSources)
                
                strongSelf.dataSources = Array(array.union(Set(dateSourde ?? []))).sorted { (t1, t2) -> Bool in
                    return t1.start ?? 0 < t2.start ?? 0
                }
                
                comple(strongSelf.dataSources)
            }
            
        }
        
        
    }
}
