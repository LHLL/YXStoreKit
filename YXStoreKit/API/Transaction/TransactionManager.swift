//
//  TransactionManager.swift
//  YXStoreKit
//
//  Created by Yijie Xu on 1/4/20.
//  Copyright © 2020 yx. All rights reserved.
//

import Foundation
import StoreKit

/** Manages SKPaymentTransactions for the client. */
public protocol YXTransactionManager {
    /**
     * Starts transaction updates.
     * Nedds to be called as soon as app launches and user account switches.
     *
     * @param user The current logged-in user.
     * @param callbackQueue A queue that completion closure will be called in. Default is main queue.
     * @param completion A closure to be invoked when the call is finished.
     */
    func startObserving(for user:YXUser,
                        callbackQueue:DispatchQueue,
                        completion: @escaping (([YXError])->Void))
    
    /**
     * Stops transaction updates.
     * Needs to be called when app becomes inactive.
     */
    func stopObserving()
    
    /**
     * Creates a trasnaction of the product for the user.
     *
     * @param product The product that the user wants to purchase.
     * @param discount The discount that can be applied to the product.
     * @param quantity The number of the product that the user wants to purchase.
     * @param callbackQueue A queue that completion closure will be called in. Default is main queue.
     * @param completion A closure to be invoked when the call is finished.
     */
    func createTransaction(for product:SKProduct,
                           discount:SKPaymentDiscount?,
                           quantity:Int,
                           callbackQueue:DispatchQueue,
                           completion: @escaping ((YXError?)->Void))
}
