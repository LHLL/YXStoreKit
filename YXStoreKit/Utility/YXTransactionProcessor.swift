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
    
    /**
     * Processes a list of transactions for the user.
     *
     * @param transactions A list of transactions that needs to be processed.
     * @param user User object that contains essential information for transaction processing.
     * @param event
     */
    static func process(transactions:[SKPaymentTransaction],
                        for user:YXUser,
                        event:YXTransactionEvent) -> YXTransactionResponse {
        var disabled = [String]()
        var finished = [String]()
        var failed = [String]()
        for transaction in transactions {
            guard let identifier = transaction.transactionIdentifier else {
                // Purchasing or deferred transactions
                continue
            }
            guard user.pendingTransactions.contains(identifier) ||
                  user.existingSubscriptions.contains(identifier) else {
                disabled.append(identifier)
                continue
            }
            switch transaction.transactionState {
            case .purchased:
                finished.append(transaction.transactionIdentifier!)
            case .restored:
                finished.append(transaction.transactionIdentifier!)
            case .failed:
                failed.append(transaction.transactionIdentifier!)
            default:
                break
            }
        }
        return YXTransactionResponse(disabledProductIdentifiers: disabled,
                                     finishedTransactions: finished,
                                     failedTransactions: failed)
    }
}
