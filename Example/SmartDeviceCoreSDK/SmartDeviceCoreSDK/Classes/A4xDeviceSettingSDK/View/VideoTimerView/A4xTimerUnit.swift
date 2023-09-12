//


//


//

import Foundation
import UIKit

enum A4xSDVideoTimeItem {
    case point(center : CGPoint , alpha : Float)
    case text(center : CGPoint , text : String? , alpha : Float)
}

struct A4xSDVideoPlaySpacers {
    
    static var timeSpacers : [Int] = [4 * 60 * 60, 2 * 60 * 60, 60 * 60, 30 * 60, 15 * 60, 8 * 60, 4 * 60, 2 * 60 , 1 * 60 ] //最小单位分钟
    static func `default`() -> Int {
        return timeSpacers[0]
    }
    
    static func great(_ current : Int) -> Int {
        var result = current
        for value in timeSpacers.reversed() {
            if value > current {
                result = value
                break
            }
        }
      
        return result
    }
    
    static func less(_ current : Int) -> Int {
        var result = current
        for value in timeSpacers {
            if value  < current {
                result = value
                break
            }
        }
        return result
    }
    
    static func min() -> Int {
        return (timeSpacers.last ?? 1) 
    }
    
    static func max() -> Int {
        return (timeSpacers.first ?? 1)
    }
}
 
extension Date {
    func videoMinData(of day : Int ) -> Date {
        let timeinter = self.timeIntervalSince1970
        let truncating = timeinter.truncatingRemainder(dividingBy: 24 * 60 * 60)
        let currentd = timeinter - truncating - TimeInterval(day * 24 * 60 * 60)  - TimeInterval(8 * 60 * 60)
        return Date(timeIntervalSince1970: currentd)
    }
    
    func videoDrawMaxDate() -> Date {
        let temp = A4xSDVideoPlaySpacers.max()
        let timeinter = self.timeIntervalSince1970
        let truncating = timeinter.truncatingRemainder(dividingBy: timeinter)
        let addedTime = TimeInterval(temp) - truncating
        return self.addingTimeInterval(addedTime)
    }
    
    
    static func sdMaxSelect() -> Date {
        
        let date = Date()
        if let morninginter = date.getMorningDate()?.timeIntervalSince1970 {
            let dateTimeInter = date.timeIntervalSince1970
            
            if (dateTimeInter - morninginter) > 12 * 60 * 60 {
                return Date(timeIntervalSince1970: morninginter + 12 * 60 * 60)
            } else {
                return date.dateBefore(60 * 60)
            }
        } else {
            return date.dateBefore(60 * 60)
        }
    }
}

enum A4xDateType {
    case none
    case min
    case max
}
