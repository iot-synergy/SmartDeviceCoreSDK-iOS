

import Foundation

public struct A4xBaseStack<T> {
    
    
    private var elements = [T]()

    
    public var count: Int {
        
        return elements.count
    }

    
    public var capacity: Int {

        
        get {
            
            return elements.capacity
        }

        
        set {
            
            elements.reserveCapacity(newValue)
        }
    }

    
    public init() {}

    
    public mutating func push(element: T) {
        
        if count == capacity {
            //fatalError("栈已满，不能再执行入栈操作！")
            print("-----------> 栈已满，不能再执行入栈操作！")
        }
        
        self.elements.append(element)
    }

    
    @discardableResult
    public mutating func pop() -> T? {
        
        if count == 0 {
            //fatalError("栈已空，不能再执行出栈操作！")
            print("-----------> 栈已空，不能再执行出栈操作！")
        }
        
        return elements.popLast()
    }

    
    public func peek() -> T? {
        
        return elements.last
    }

    
    public mutating func clear() {
        
        elements.removeAll()
    }

    
    public func isEmpty() -> Bool {
        
        return elements.isEmpty
    }

    
    public func isFull() -> Bool {
        
        if count == 0 {
            
            return false
        } else {
            
            
            return count == elements.capacity
        }
    }
}
