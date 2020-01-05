//
//  YXProductServiceImpl.swift
//  YXStoreKit
//
//  Created by Yijie Xu on 12/31/19.
//  Copyright © 2019 yx. All rights reserved.
//

import Foundation
import StoreKit

/** The concrete implementation of the [YXProductService] */
public final class YXProductServiceImpl: NSObject, YXProductService {
    /** A thread-safe dictionary that stores all callback queues. */
    private var queues:YXDictionary<SKRequest, [DispatchQueue]> = YXDictionary()
    
    /** A thread-safe dictionary that stores all callback closures. */
    private var completions:YXDictionary<SKRequest, [YXProductCompletion]> = YXDictionary()
    
    /** A thread-safe dictionary that stores all pending requests. */
    private var requests:YXDictionary<Set<String>, SKRequest> = YXDictionary()
    
    /** A builder that builds a [SKProductsRequest] upon demand. */
    private let requestBuilder:YXProductRequestBuilder
    
    public init(builder:YXProductRequestBuilder) {
        requestBuilder = builder
    }
    
    @available(*, unavailable)
    override init() {
        fatalError("init() has not been implemented")
    }
    
    public func fetchProducts(productIds:Set<String>, callbackQueue:DispatchQueue, completion: @escaping YXProductCompletion) {
        guard let request = requests[productIds] else{
            let request = requestBuilder.build(productIdentifiers: productIds)
            request.delegate = self
            requests[productIds] = request
            queues[request] = [callbackQueue]
            completions[request] = [completion]
            request.start()
            return
        }
        var callbackQueues = queues[request]
        callbackQueues?.append(callbackQueue)
        queues[request] = callbackQueues
        
        var callbackCompletions = completions[request]
        callbackCompletions?.append(completion)
        completions[request] = callbackCompletions
    }
}

//MARK: SKProductsRequestDelegate
extension YXProductServiceImpl:SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        guard let callbackQueues = queues[request], let callbackCompletions = completions[request] else {
            return
        }
        queues[request] = nil
        completions[request] = nil
        requests.dump(value: request)
        guard callbackCompletions.count == callbackCompletions.count else {
            assert(false, "Count of callback queues and callback compeltions doesn't match.")
            return
        }
        for i in 0..<callbackQueues.count {
            callbackQueues[i].async {
                callbackCompletions[i](response.products, response.invalidProductIdentifiers, /* error= */ nil)
            }
        }
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        guard let callbackQueues = queues[request], let callbackCompletions = completions[request] else {
            return
        }
        queues[request] = nil
        completions[request] = nil
        requests.dump(value: request)
        guard callbackCompletions.count == callbackCompletions.count else {
            assert(false, "Count of callback queues and callback compeltions doesn't match.")
            return
        }
        let err = YXError(domain: .products, type: .normal(reason: error.localizedDescription))
        for i in 0..<callbackQueues.count {
            callbackQueues[i].async {
                callbackCompletions[i](/*products= */[], /*invalids= */[], err)
            }
        }
    }
}
