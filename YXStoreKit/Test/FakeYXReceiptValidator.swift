//
//  FakeYXReceiptValidator.swift
//  YXStoreKitTests
//
//  Created by Yijie Xu on 12/30/19.
//  Copyright © 2019 yx. All rights reserved.
//

import Foundation

enum ReceiptValidatorMode{
    // Simulates a successful validation.
    case succeed
    // Simulates a failed validation.
    case error
}

struct FakeYXReceiptValidator:YXReceiptValidator {
    
    private let mode:ReceiptValidatorMode
    
    init(validatorMode:ReceiptValidatorMode) {
        mode = validatorMode
    }
    
    func validate(receipt:Data, callbackQueue:DispatchQueue, completion: @escaping ((Error?)->Void)) {
        if mode == .succeed {
            callbackQueue.async {
                completion(nil)
            }
            return
        }
        callbackQueue.async {
            completion(YXError(domain: .receiptValidation, type: .receipt))
        }
    }
}
