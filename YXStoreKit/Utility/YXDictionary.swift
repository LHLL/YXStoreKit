//
//  YXDictionary.swift
//  YXStoreKit
//
//  Created by Yijie Xu on 12/22/19.
//  Copyright © 2019 yx. All rights reserved.
//

import Foundation

/** A thread-safe, type-safe dictionary. */
struct YXDictionary<Key:Hashable, Value:Any> {
    private var dict = [Key:Value]()
    /**
     * A private serial queue.
     *
     * All operations should be sync. This class will normally hold less than 3 objects, sync should not cause
     * performance concerns
     */
    private let readWriteQueue = DispatchQueue(label: "com.yx.YXDictionary")
    
    /**
     * Usage:
     * ``` Swift Code
     * var dictionary = YXDictionary<String, Int>()
     * if let foo = dictionary["foo"] {
     *    dictionary["foo"] = foo + 1
     * }
     * ```
     */
    subscript(key:Key) -> Value? {
        get {
            readWriteQueue.sync{self.dict[key]}
        }
        set(newValue) {
            readWriteQueue.sync{self.dict[key] = newValue}
        }
    }
}

extension YXDictionary where Value:Equatable {
    
    /** Dumps all values in the dictionary that equal to the passed-in value. */
    mutating func dump(value:Value) {
        readWriteQueue.sync{
            for key in self.dict.keys {
                if let v = self.dict[key], v == value {
                    self.dict[key] = nil
                }
            }
        }
    }
}
