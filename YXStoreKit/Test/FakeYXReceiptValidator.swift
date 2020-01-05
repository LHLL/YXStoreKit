//
//  FakeYXReceiptValidator.swift
//  YXStoreKitTests
//
//  Created by Yijie Xu on 12/30/19.
//  Copyright © 2019 yx. All rights reserved.
//

import Foundation

/** Testable implementation of [YXReceiptValidator]. */
struct FakeYXReceiptValidator:YXReceiptValidator {
    
    private let data:Data
    
    init(expectedData:Data) {
        data = expectedData
    }
    
    func validate(receipt:Data, callbackQueue:DispatchQueue, completion: @escaping ((Error?)->Void)) {
        callbackQueue.async {
            completion(self.data == receipt ? nil:YXError(domain: .receipt, type: .receiptValidationFailed))
        }
    }
}
