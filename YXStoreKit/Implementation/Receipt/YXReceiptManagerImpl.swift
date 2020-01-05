//
//  YXReceiptManagerImpl.swift
//  YXStoreKit
//
//  Created by Yijie Xu on 12/30/19.
//  Copyright © 2019 yx. All rights reserved.
//

import Foundation

/** The concrete implementation of the YXReceiptManager. */
public final class YXReceiptManagerImpl:YXReceiptManager {
    private let validator: YXReceiptValidator
    
    private let refresher: YXReceiptRefresher
    
    /** A serial queue that all operation will be conducted in. */
    private let queue:DispatchQueue
    
    /** A url that points to the local App Strore receipt. */
    private let url:URL?
    
    /** Boolean value indicates that whether or not SKReceiptRefreshRequest has been sent.*/
    private var retried = false
    
    public init(receiptValidator:YXReceiptValidator,
                receiptRefresher:YXReceiptRefresher,
        receiptUrl:URL? = Bundle.main.appStoreReceiptURL) {
        validator = receiptValidator
        refresher = receiptRefresher
        queue = DispatchQueue(label: "com.yx.receiptQueue")
        url = receiptUrl
    }
    
    public func validateReceipt(callbackQueue: DispatchQueue, completion: @escaping ((Error?) -> Void)) {
        queue.async {
            guard let url = self.url else{
                guard self.retried else {
                    self.refresh(callbackQueue: callbackQueue, completion: completion)
                    return
                }
                callbackQueue.async {
                    completion(YXError(domain: .receipt, type: .receiptMissing))
                }
                return
            }
            do {
                let data = try Data(contentsOf: url)
                self.validator.validate(receipt: data, callbackQueue: self.queue) { [weak self] (error) in
                    guard let err = error else{
                        callbackQueue.async {
                            completion(nil)
                        }
                        return
                    }
                    guard let flag = self?.retried, flag else {
                        self?.refresh(callbackQueue: callbackQueue, completion: completion)
                        return
                    }
                   callbackQueue.async {
                        completion(YXError(domain: .receipt, type: .normal(reason: err.localizedDescription)))
                    }
                }
            } catch {
                if (error as NSError).domain == "NSCocoaErrorDomain" &&
                    (error as NSError).code == 260{
                    guard self.retried else {
                        self.refresh(callbackQueue: callbackQueue, completion: completion)
                        return
                    }
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

//MARK: Private Method
extension YXReceiptManagerImpl {
    private func refresh(callbackQueue: DispatchQueue, completion: @escaping ((Error?) -> Void)) {
        self.retried = true
        self.refresher.refresh(callbackQueue: self.queue) { [weak self] (error) in
            guard let err = error else {
                self?.validateReceipt(callbackQueue: callbackQueue, completion: completion)
                return
            }
            callbackQueue.async {
                completion(YXError(domain: .receipt, type: .normal(reason: err.localizedDescription)))
            }
        }
    }
}

