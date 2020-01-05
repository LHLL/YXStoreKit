//
//  YXTransactionProcessorResponse.swift
//  YXStoreKit
//
//  Created by Yijie Xu on 12/31/19.
//  Copyright © 2019 yx. All rights reserved.
//

import Foundation

/** Object that contains result of transaction procrssing. */
struct YXTransactionResponse {
    /**
     * A list of string that each of them uniquely identifies a product that the current user cannot purchase
     * at this moment.
     *
     * Apple associates a SKPaymentTransaction with the user's Apple Id only, for apps that have their own
     * account system (such as apps support login with Google), there is no way for the client app to establish
     * the relationship between the transaction and the user's account. To solve this problem, for any given
     * product, only one transaction is allowed at any given time. If user A has a pending transaction for buying
     * product B then even the user switches to user B, user B will not be able to purchase the product until
     * user A finishes his/her transaction.
     * Execution order:
     *       App launches
     *            |
     *            |
     *       get user object
     *            |
     *            |
     *   process transactions for launch
     *            |
     *            |
     *  allow user make new transaction
     *            |
     *            |
     *  process transactions for updates
     */
    let disabledProductIdentifiers:[String]
    
    /** A list of string that each of them uniquely identifies a finished transaction. */
    let finishedTransactions:[String]
    
    /** A list of string that each of them uniquely identifies a failed transaction. */
    let failedTransactions:[String]
}
