//
//  YXDictionary.swift
//  YXStoreKit
//
//  Created by Yijie Xu on 12/22/19.
//  Copyright © 2019 yx. All rights reserved.
//

import Foundation

/** A thread-safe dictionary. */
struct YXDictionary<Key:Hashable, Value:Any> {
    private var dict = [Key:Value]()
    private let readWriteQueue = DispatchQueue(label: "com.yx.readWriteQueue")
    
    subscript(key:Key) -> Value? {
        get {
            readWriteQueue.sync{self.dict[key]}
        }
        set(newValue) {
            readWriteQueue.sync{self.dict[key] = newValue}
        }
    }
}
