//
//  YXProductService.swift
//  YXStoreKit
//
//  Created by Yijie Xu on 12/22/19.
//  Copyright © 2019 yx. All rights reserved.
//

import Foundation
import StoreKit

typealias YXProductCompletion = (([YXProduct], [String], YXError?)->Void)
typealias YXSubscriptionCompletion = (([YXSubscription], [String], YXError?)->Void)

public final class YXProductService:NSObject {
    
    private var queues:YXDictionary<SKRequest,DispatchQueue> = YXDictionary()
    private var completions:YXDictionary<SKRequest,YXProductCompletion> = YXDictionary()
    private var requests:YXDictionary<Set<String>,SKRequest> = YXDictionary()
    
    /**
     * Fetches purchasable products .
     *
     * @param productIds A set of strings that each of them stands uniquely for a product.
     * @param callbackQueue A queue that completion closure will be called in. Default is main queue.
     * @param completion A closure to be invoked when the call is finished.
     */
    func fetchProducts(productIds:Set<String>, callbackQueue:DispatchQueue = .main, completion: @escaping YXProductCompletion) {
        let request = SKProductsRequest(productIdentifiers: productIds)
        request.delegate = self
        requests[productIds] = request
        queues[request] = callbackQueue
        completions[request] = completion
        request.start()
    }
    
    /**
     * Fetches all subscriptions.
     *
     * @param productIds A set of strings that each of them stands uniquely for a product.
     * @param callbackQueue A queue that completion closure will be called in. Default is main queue.
     * @param completion A closure to be invoked when the call is finished.
     */
    func fetchSubscriptionss(productIds:Set<String>, callbackQueue:DispatchQueue = .main, completion: @escaping YXProductCompletion) {
        let request = SKProductsRequest(productIdentifiers: productIds)
        request.delegate = self
        requests[productIds] = request
        queues[request] = callbackQueue
        completions[request] = completion
        request.start()
    }
}

//MARK: SKProductsRequestDelegate
extension YXProductService:SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        
    }
}
