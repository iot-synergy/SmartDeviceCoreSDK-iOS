//

import Foundation

public struct A4xBaseGradLocation {
    public var xRatio : CGFloat = 0
    public var yRatio : CGFloat = 0
    
    public init(xRatio : CGFloat , yRatio : CGFloat) {
        self.xRatio = xRatio
        self.yRatio = yRatio
    }
    
    public static func topLocation() -> A4xBaseGradLocation {
        return A4xBaseGradLocation(xRatio: 0.5, yRatio: 0)
    }
    
    public static func bottomLocation() -> A4xBaseGradLocation {
        return A4xBaseGradLocation(xRatio: 0.5, yRatio: 1)
    }

    public static func leftLocation() -> A4xBaseGradLocation {
        return A4xBaseGradLocation(xRatio: 0, yRatio: 0.5)
    }
    
    public static func rightLocation() -> A4xBaseGradLocation {
        return A4xBaseGradLocation(xRatio: 1, yRatio: 0.5)
    }
}


public struct A4xBaseGradColor {
    
    public var beginPostion      : A4xBaseGradLocation = A4xBaseGradLocation.topLocation()
    public var endPostion   : A4xBaseGradLocation = A4xBaseGradLocation.bottomLocation()
    public var colors          : [CGColor]?
    public var locations       : [CGFloat] = [0,1]
    
    public func isVaild() -> Bool {
        guard self.colors != nil else {
            return false
        }
        guard self.colors!.count == self.locations.count else {
            return false
        }
        return true
    }
    
    public init(
        PostionBegin begin      : A4xBaseGradLocation = A4xBaseGradLocation.topLocation() ,
        PostionEnd end          : A4xBaseGradLocation = A4xBaseGradLocation.bottomLocation() ,
        Colors colors           : [CGColor] ,
        Locations locations     : [CGFloat] = [0,1])
    {
        self.colors = colors
        self.locations = locations
        self.beginPostion = begin
        self.endPostion = end
    }
}
