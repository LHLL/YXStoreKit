//
//  YXTransactionManager.swift
//  YXStoreKit
//
//  Created by Yijie Xu on 1/4/20.
//  Copyright © 2020 yx. All rights reserved.
//

import Foundation
import StoreKit

private typealias YXTransactionCompletion = ((YXError?) -> Void)

public class YXTransactionManagerImpl:NSObject, YXTransactionManager {
    
    private let queue:YXPaymentQueue
    private let manager:YXReceiptManager
    private let userManager:YXUserManager
    
    /** A dispatch queue that all async tasks will be called in. */
    private let requestQueue:DispatchQueue
    
    /** The dispatch queue that  the callbackComplete will be called in.*/
    private var callbackQueue:DispatchQueue?
    /** The blocked to be invoked when the transaction is completed. */
    private var callbackCompletion:YXTransactionCompletion?
    
    private var user:YXUser?
    
    /** A list of product identifiers that the user cannot buy. */
    private var disabledProducts = [String]()
    
    /** The identifier of the product that user wants to purchase in the current session. */
    private var pendingProductId:String?
    
    public init(paymentQueue:YXPaymentQueue = SKPaymentQueue.default(),
                receiptManager: YXReceiptManager,
                userManager:YXUserManager) {
        queue = paymentQueue
        manager = receiptManager
        self.userManager = userManager
        requestQueue = DispatchQueue(label: "com.yx.transactionQueue")
        super.init()
    }
    
    public func startObserving(for user: YXUser,
                               callbackQueue: DispatchQueue,
                               completion: @escaping (([YXError]) -> Void)) {
        requestQueue.async {
            let response = YXTransactionProcessor.process(transactions: self.queue.transactions,
                                                          for: user)
            guard !response.wrongAppleID else {
                callbackQueue.async {
                    completion([YXError(domain: .transaction, type: .wrongAppleId)])
                }
                return
            }
            self.user = user
            self.disabledProducts = response.disabledProductIdentifiers
            guard !response.finishedTransactions.isEmpty ||
                  !response.failedTransactions.isEmpty else {
                    self.queue.add(self)
                    callbackQueue.async {
                        completion([])
                    }
                    return
            }
            self.manager.validateReceipt(callbackQueue: self.requestQueue) { (error) in
                guard (error == nil) else {
                    self.queue.add(self)
                    callbackQueue.async {
                        completion([error!])
                    }
                    return
                }
                var errors:[YXError] = []
                var pending = user.pendingTransactions
                if !response.failedTransactions.isEmpty {
                    response.failedTransactions.forEach { (transaction) in
                        self.queue.finishTransaction(transaction)
                        pending.removeAll(where: {$0 == transaction.payment.productIdentifier})
                        errors.append(YXError(domain: .transaction,
                        type: .normal(reason: transaction.payment.productIdentifier)))
                    }
                }
                if !response.finishedTransactions.isEmpty {
                    response.finishedTransactions.forEach { (transaction) in
                        self.queue.finishTransaction(transaction)
                        pending.removeAll(where: {$0 == transaction.payment.productIdentifier})
                        // TODO: Handle subscription validation here
                    }
                }
                // TODO: Handle subscription validation here.
                let newUser = YXUser(identifier: user.identifier,
                                     pendingTransactions: pending,
                                     existingSubscriptions: user.existingSubscriptions,
                                     productIdentifiers: user.productIdentifiers)
                self.userManager.update(user: newUser, callbackQueue: self.requestQueue) { (error) in
                    self.queue.add(self)
                    self.user = error == nil ? newUser : user
                    callbackQueue.async {
                        completion(errors)
                    }
                }
            }
        }
    }
    
    public func stopObserving() {
        requestQueue.async {
            self.queue.remove(self)
        }
    }
    
    public func createTransaction(for product: SKProduct,
                                  discount:SKPaymentDiscount? = nil,
                                  quantity:Int = 1,
                                  callbackQueue: DispatchQueue,
                                  completion: @escaping ((YXError?) -> Void)) {
        requestQueue.async {
            guard self.queue.ready() else {
                callbackQueue.async {
                    completion(YXError(domain: .transaction, type: .systemNotReady))
                }
                return
            }
            guard let user = self.user else {
                callbackQueue.async {
                    completion(YXError(domain: .transaction, type: .wrongUser))
                }
                return
            }
            let error = YXTransactionProcessor.validate(product: product,
                                                        user: user,
                                                        disabledProducts: self.disabledProducts)
            guard error == nil else {
                callbackQueue.async {
                    completion(error)
                }
                return
            }
            self.updateUser(productId: product.productIdentifier) { (error) in
                guard error == nil else {
                    callbackQueue.async {
                        completion(error)
                    }
                    return
                }
                self.pendingProductId = product.productIdentifier
                self.callbackQueue = callbackQueue
                self.callbackCompletion = completion
                self.createTransaction(of: product,
                                       discount: discount,
                                       quantity: quantity)
            }
        }
    }
    
}

//MARK: SKPaymentTransactionObserver
extension YXTransactionManagerImpl:SKPaymentTransactionObserver {
    public func paymentQueue(_ queue: SKPaymentQueue,
                             updatedTransactions transactions: [SKPaymentTransaction]) {
        requestQueue.async {
            guard let user = self.user else {
                return
            }
            // Ignores transactions that are not initiated by the user in the current session.
            guard let identifier = self.pendingProductId else {
                return
            }
            let response = YXTransactionProcessor.process(transactions: queue.transactions,
                                                          for: user)
            guard !response.wrongAppleID else {
                let queue = self.callbackQueue
                self.callbackQueue = nil
                let completion = self.callbackCompletion
                self.callbackCompletion = nil
                queue?.async {
                    completion?(YXError(domain: .transaction, type: .wrongAppleId))
                }
                return
            }
            self.disabledProducts = response.disabledProductIdentifiers
            guard !response.finishedTransactions.isEmpty ||
                  !response.failedTransactions.isEmpty else {
                    return
            }
            let failed = response.failedTransactions.filter({$0.payment.productIdentifier == identifier})
            guard failed.isEmpty else {
                failed.forEach({queue.finishTransaction($0)})
                let queue = self.callbackQueue
                self.callbackQueue = nil
                let completion = self.callbackCompletion
                self.callbackCompletion = nil
                queue?.async {
                    completion?(YXError(domain: .transaction, type: .normal(reason: identifier)))
                }
                return
            }
            let finished = response.finishedTransactions.filter({$0.payment.productIdentifier == identifier})
            guard !finished.isEmpty else {
                return
            }
            self.manager.validateReceipt(callbackQueue: self.requestQueue) { (error) in
                guard (error != nil) else {
                    let queue = self.callbackQueue
                    self.callbackQueue = nil
                    let completion = self.callbackCompletion
                    self.callbackCompletion = nil
                    queue?.async {
                        completion?(error)
                    }
                    return
                }
                finished.forEach({queue.finishTransaction($0)})
                let queue = self.callbackQueue
                self.callbackQueue = nil
                let completion = self.callbackCompletion
                self.callbackCompletion = nil
                queue?.async {
                    completion?(nil)
                }
            }
        }
    }
}

//MARK: Private Method
extension YXTransactionManagerImpl {
    private func updateUser(productId:String, completion:@escaping YXTransactionCompletion) {
        guard let user = self.user else {
            completion(YXError(domain: .transaction, type: .wrongUser))
            return
        }
        var pending = user.pendingTransactions
        pending.append(productId)
        let newUser = YXUser(identifier: user.identifier,
                             pendingTransactions: pending,
                             existingSubscriptions: user.existingSubscriptions,
                             productIdentifiers: user.productIdentifiers)
        userManager.update(user: newUser, callbackQueue: self.requestQueue) {[weak self] (error) in
            self?.user = error == nil ? newUser : user
            completion(error)
        }
    }
    
    private func createTransaction(of product:SKProduct,
                                   discount:SKPaymentDiscount?,
                                   quantity:Int) {
        let payment = SKMutablePayment(product: product)
        payment.applicationUsername = self.user?.identifier
        payment.paymentDiscount = discount
        payment.quantity = quantity
        queue.add(payment)
    }
    
}
