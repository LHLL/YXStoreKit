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
    /** A private serial queue. */
    private let readWriteQueue = DispatchQueue(label: "com.yx.YXDictionary")
    
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
