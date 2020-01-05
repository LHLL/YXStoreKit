//
//  YXReceiptRefresher.swift
//  YXStoreKit
//
//  Created by Yijie Xu on 1/4/20.
//  Copyright © 2020 yx. All rights reserved.
//

import Foundation
import StoreKit

private typealias YXReceiptRefreshCompletiom = ((YXError?)->Void)

/** The concrete implementation of the [YXReceiptRefresher]. */
public final class YXReceiptRefresherImpl:NSObject, YXReceiptRefresher {
    /** An array that stores all callback queues. */
    private var queues = [DispatchQueue]()
       
    /** An array that stores all callback closures. */
    private var completions = [YXReceiptRefreshCompletiom]()
    
    /** Builder that builds SKRefreshReceiptRequest upon demand. */
    private let builder:YXReceiptRefreshRequestBuilder
    
    public init(requestBuilder: YXReceiptRefreshRequestBuilder) {
        builder = requestBuilder
        super.init()
    }
    
    @available(*, unavailable)
    override init() {
        fatalError("Unimplementated method")
    }
    
    public func refresh(callbackQueue: DispatchQueue, completion: @escaping ((YXError?) -> Void)) {
        guard !queues.isEmpty else{
            let request = builder.build()
            request.delegate = self
            queues.append(callbackQueue)
            completions.append(completion)
            request.start()
            return
        }
        assert(queues.count == completions.count, "Uneven queue completion pair.")
        queues.append(callbackQueue)
        completions.append(completion)
    }
}

extension YXReceiptRefresherImpl:SKRequestDelegate {
    
    public func requestDidFinish(_ request: SKRequest) {
        let callbackQueues = queues
        queues = []
        let callbackCompletions = completions
        completions = []
        for i in 0..<callbackQueues.count {
            callbackQueues[i].async {
                callbackCompletions[i](nil)
            }
        }
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        let err = YXError(domain: .receipt, type: .normal(reason: error.localizedDescription))
        let callbackQueues = queues
        queues = []
        let callbackCompletions = completions
        completions = []
        for i in 0..<callbackQueues.count {
            callbackQueues[i].async {
                callbackCompletions[i](err)
            }
        }
    }
}
