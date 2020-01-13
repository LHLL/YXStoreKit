//
//  YXStoreKitService.swift
//  YXStoreKit
//
//  Created by Yijie Xu on 1/7/20.
//  Copyright © 2020 yx. All rights reserved.
//

import Foundation
import StoreKit

/** A closure-based wrapper of StoreKit with queue contract. */
public class YXStoreKit {
    private let userManager:YXUserManager
    private let productService:YXProductService
    private let receiptManager:YXReceiptManager
    private let transactionManager:YXTransactionManager
    private let requestQueue:DispatchQueue
    
    private var ready = false
    
    init(user:YXUserManager,
         product:YXProductService,
         receipt:YXReceiptManager,
         transaction:YXTransactionManager) {
        userManager = user
        productService = product
        receiptManager = receipt
        transactionManager = transaction
        requestQueue = DispatchQueue(label: "com.yx.facade")
    }
    
    /**
     * Starts the system, needs to be called as soon as app launches and user account switches.
     *
     * @param callbackkQueue: A dispatch queue that the completion closure will be called in.
     * @param completion A closure to be invoked after the method is finished.
     */
    func start(callbackQueue:DispatchQueue, completion: @escaping (([YXError])->Void)){
        self.requestQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            guard !self.ready else {
                callbackQueue.async {
                    completion([YXError(domain: YXErrorDomain.system,
                                        type: YXErrorType.notStopped)])
                }
                return
            }
            self.userManager.user(callbackQueue: self.requestQueue) { [weak self] (user, error) in
                guard let self = self else {
                    return
                }
                self.ready = true
                guard let user = user else{
                    callbackQueue.async {
                        completion([error!])
                    }
                    return
                }
                self.transactionManager.startObserving(for: user,
                                                       callbackQueue: callbackQueue,
                                                       completion: completion)
            }
        }
    }
    
    /**
     * Stops transaction processing for the current user. Needs to be called when user account switches.
     */
    func stop(){
        self.requestQueue.async {
            self.ready = false
            self.transactionManager.stopObserving()
        }
    }
    
    /**
     * Gets a list of products that the user can purchase.
     *
     * @param callbackkQueue: A dispatch queue that the completion closure will be called in.
     * @param completion A closure to be invoked after the method is finished.
     */
    func products(callbackQueue:DispatchQueue, completion: @escaping (YXProductCompletion)) {
        requestQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            guard self.ready else {
                callbackQueue.async {
                    completion([],
                               [],
                               YXError(domain: YXErrorDomain.system,
                                       type: YXErrorType.systemNotReady))
                }
                return
            }
            self.userManager.user(callbackQueue: self.requestQueue) { [weak self] (user, userError) in
                guard let self = self else {
                    return
                }
                guard let user = user else {
                    callbackQueue.async {
                        completion([],[], userError)
                    }
                    return
                }
                self.receiptManager.validateReceipt(callbackQueue: self.requestQueue) { [weak self] (receiptError) in
                    guard let self = self else {
                        return
                    }
                    guard receiptError == nil else {
                        callbackQueue.async {
                            completion([],[], receiptError)
                        }
                        return
                    }
                    self.productService.fetchProducts(productIds: user.productIdentifiers,
                                                      callbackQueue: callbackQueue,
                                                      completion: completion)
                }
            }
        }
    }
    
    /**
     * Purchases a product for the user.
     *
     * @param product The product that the user wants to purchase.
     * @param discount The discount that can be applied to the product.
     * @param quantity The number of the product that the user wants to purchase.
     * @param callbackQueue A queue that completion closure will be called in. Default is main queue.
     * @param completion A closure to be invoked when the call is finished.
     */
    func purchase(product:YXProduct,
                  discount:SKPaymentDiscount?,
                  quantity:Int,
                  callbackQueue:DispatchQueue,
                  completion: @escaping ((YXError?)->Void)) {
        self.requestQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            self.transactionManager.createTransaction(for: (product as! SKProduct),
                                                      discount: discount,
                                                      quantity: quantity,
                                                      callbackQueue: callbackQueue,
                                                      completion: completion)
        }
    }
}
