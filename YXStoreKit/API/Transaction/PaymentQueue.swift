//
//  PaymentQueue.swift
//  YXStoreKit
//
//  Created by Yijie Xu on 1/4/20.
//  Copyright © 2020 yx. All rights reserved.
//

import Foundation
import StoreKit

/** Protocol that provides exactly same APIs of the [SKPaymentQueue]. */
public protocol YXPaymentQueue{
    @available(iOS 13.0, *)
    var delegate: SKPaymentQueueDelegate? { get set }
    
    @available(iOS 13.0, *)
    var storefront: SKStorefront? { get }
    
    @available(iOS 3.0, *)
    func add(_ payment: SKPayment)

    @available(iOS 3.0, *)
    func finishTransaction(_ transaction: SKPaymentTransaction)

    @available(iOS 3.0, *)
    func add(_ observer: SKPaymentTransactionObserver)

    @available(iOS 3.0, *)
    func remove(_ observer: SKPaymentTransactionObserver)

    @available(iOS 3.0, *)
    var transactions: [SKPaymentTransaction] { get }
    
    func ready()->Bool
}

extension SKPaymentQueue: YXPaymentQueue{
    public func ready() -> Bool {
        SKPaymentQueue.canMakePayments()
    }
}

