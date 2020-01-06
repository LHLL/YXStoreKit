//
//  FakeSKPaymentTransaction.swift
//  YXStoreKitTests
//
//  Created by Yijie Xu on 1/4/20.
//  Copyright © 2020 yx. All rights reserved.
//

import UIKit
import StoreKit

enum FakeTransactionMode{
    // Transaction state will become [purchased] right after transaction
    // being added to the payment queue.
    case succeed
    // Transaction state will become [failed] right after transaction
    // being added to the payment queue.
    case fail
    // Transaction state will remain [purchasing]
    case idle
}

class FakeSKPaymentTransaction: SKPaymentTransaction {
    override
    var error:Error? {
        return fakeError
    }
    var fakeError:Error?
    
    override
    var transactionState:SKPaymentTransactionState{
        return state
    }
    
    var state:SKPaymentTransactionState{
        didSet{
            if state == .purchased || state == .failed {
                transactionId = "transaction id"
            }
        }
    }
    
    override
    var transactionIdentifier: String? {
        return transactionId
    }
    
    private var transactionId:String?
    
    override
    var payment:SKPayment {
        return _payment
    }
    let mode: FakeTransactionMode
    
    private var _payment:SKPayment
    
    init(payment:SKPayment,
         transactionMode: FakeTransactionMode) {
        _payment = payment
        mode = transactionMode
        state = .purchasing
    }
}
