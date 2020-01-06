//
//  FakeSKPaymentQueue.swift
//  YXStoreKitTests
//
//  Created by Yijie Xu on 1/4/20.
//  Copyright © 2020 yx. All rights reserved.
//

import Foundation
import StoreKit

class FakeSKPaymentQueue:SKPaymentQueue {
    
    override
    var transactions: [SKPaymentTransaction] {
        return _transactions
    }
    
    var observers:[SKPaymentTransactionObserver] = []
    
    private var _transactions: [FakeSKPaymentTransaction]
    
    init(transactions:[FakeSKPaymentTransaction] = []) {
        _transactions = transactions
    }
    
    override
    func add(_ payment: SKPayment) {
        let transaction = FakeSKPaymentTransaction(payment:payment, transactionMode:.succeed)
        _transactions.append(transaction)
        for observer in observers {
            observer.paymentQueue(self, updatedTransactions: transactions)
        }
        _transactions.forEach({
            switch $0.mode {
            case .succeed:
                $0.state = .purchased
            case .fail:
                $0.state = .failed
                $0.fakeError = YXError(domain: .transaction, type: .unknown)
            default:
                break
            }
        })
        for observer in observers {
            observer.paymentQueue(self, updatedTransactions: transactions)
        }
    }
    
    override
    func finishTransaction(_ transaction: SKPaymentTransaction) {
        _transactions.removeAll(where: {$0==transaction})
    }
    
    override
    func add(_ observer: SKPaymentTransactionObserver) {
        observers.append(observer)
    }
    
    override
    func remove(_ observer: SKPaymentTransactionObserver) {
        observers.removeAll(where: {$0.isEqual(observer)})
    }
    
}
