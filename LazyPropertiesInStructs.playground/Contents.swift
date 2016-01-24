//: Lazy Properties in Structs Playground

import UIKit

private enum LazyValue<T> {
    case NotYetComputed(() -> T)
    case Computed(T)
}

final class LazyBox<T> {
    init(computation: () -> T) {
        _value = .NotYetComputed(computation)
    }
    
    private var _value: LazyValue<T>
    
    /// All reads and writes of `_value` must happen on this queue.
    private let queue = dispatch_queue_create("LazyBox._value", DISPATCH_QUEUE_SERIAL)
    
    var value: T {
        var returnValue: T? = nil
        
        dispatch_sync(queue) {
            switch self._value {
            case .NotYetComputed(let computation):
                let result = computation()
                self._value = .Computed(result)
                returnValue = result
                
            case .Computed(let result):
                returnValue = result
            }
        }
        assert(returnValue != nil)
        return returnValue!
    }
}

var counter = 0
let box = LazyBox<Int> {
    counter += 1
    return counter * 10
}
assert(box.value == 10)
assert(box.value == 10)
assert(counter == 1)

struct Image {
    // Lazy storage
    private let _metadata = LazyBox<[String: AnyObject]> {
        let meta: [String: AnyObject] = [:]
        
        // Load image file and parse metadata, expensive
        // ...
        
        return meta
    }
    
    var metadata: [String: AnyObject] {
        return _metadata.value
    }
}

let  image = Image()
//: no error
print(image.metadata)





