//
//  YXReceiptManagerImpl.swift
//  YXStoreKit
//
//  Created by Yijie Xu on 12/30/19.
//  Copyright © 2019 yx. All rights reserved.
//

import Foundation

/** The concrete implementation of the YXReceiptManager. */
public struct YXReceiptManagerImpl:YXReceiptManager {
    private var validator: YXReceiptValidator
    
    /** A serial queue that all operation will be conducted in. */
    private let queue:DispatchQueue
    
    /** A url that points to the local App Strore receipt. */
    private let url:URL?
    
    public init(receiptValidator:YXReceiptValidator, receiptUrl:URL? = Bundle.main.appStoreReceiptURL) {
        validator = receiptValidator
        queue = DispatchQueue(label: "com.yx.receiptQueue")
        url = receiptUrl
    }
    
    public func validateReceipt(callbackQueue: DispatchQueue, completion: @escaping ((Error?) -> Void)) {
        guard let url = self.url else{
            callbackQueue.async {
                completion(YXError(domain: .receipt, type: .receiptMissing))
            }
            return
        }
        queue.async {
            do {
                let data = try Data(contentsOf: url)
                self.validator.validate(receipt: data, callbackQueue: callbackQueue, completion: completion)
            } catch {
                if (error as NSError).domain == "NSCocoaErrorDomain" &&
                    (error as NSError).code == 260{
                    callbackQueue.async {
                        completion(YXError(domain: .receipt, type: .receiptMissing))
                    }
                } else {
                    callbackQueue.async {
                        completion(YXError(domain: .receipt, type: .unknown))
                    }
                }
            }
        }
    }
}
