//
//  YXTransactionProcessor.swift
//  YXStoreKit
//
//  Created by Yijie Xu on 12/31/19.
//  Copyright © 2019 yx. All rights reserved.
//

import Foundation
import StoreKit

/** Prossor that processes transactions for the library. */
struct YXTransactionProcessor {
    
    @available(*, unavailable)
    init() {}
    
    /**
     * Processes a list of transactions for the user.
     *
     * @param transactions A list of transactions that needs to be processed.
     * @param user User object that contains essential information for transaction processing.
     */
    static func process(transactions:[SKPaymentTransaction],
                        for user:YXUser) -> YXTransactionResponse {
        var wrongAppleId = false
        for identifier in user.pendingTransactions {
            if !transactions.contains(where: {$0.payment.productIdentifier == identifier}) {
                wrongAppleId = true
                break
            }
        }
        var disabled = [String]()
        var finished = [SKPaymentTransaction]()
        var failed = [SKPaymentTransaction]()
        for transaction in transactions {
            guard user.pendingTransactions.contains(transaction.payment.productIdentifier) ||
                  user.existingSubscriptions.contains(transaction.payment.productIdentifier) else {
                disabled.append(transaction.payment.productIdentifier)
                continue
            }
            switch transaction.transactionState {
            case .purchased:
                finished.append(transaction)
            case .restored:
                finished.append(transaction)
            case .failed:
                failed.append(transaction)
            default:
                break
            }
        }
        return YXTransactionResponse(disabledProductIdentifiers: disabled,
                                     finishedTransactions: finished,
                                     failedTransactions: failed,
                                     wrongAppleID: wrongAppleId)
    }
    
    /**
     * Validates whether the user can purchase the product or not.
     *
     * @param product The product that needs to be validated.
     * @param user The user who wants to purchase the product.
     * @param disabledProducts A list of product identifiers that the user cannot purchase.
     */
    static func validate(product:SKProduct, user:YXUser, disabledProducts:[String])->YXError? {
        if disabledProducts.contains(product.productIdentifier) {
            return YXError(domain: .transaction, type: .unavailableProduct)
        }
        if user.pendingTransactions.contains(product.productIdentifier) {
            return YXError(domain: .transaction, type: .duplicateTransaction)
        }
        if user.existingSubscriptions.contains(product.productIdentifier) {
            return YXError(domain: .transaction, type: .existingSubscription)
        }
        return nil
    }
}
