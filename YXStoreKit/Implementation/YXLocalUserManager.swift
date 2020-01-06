//
//  YXLocalUserManager.swift
//  YXStoreKit
//
//  Created by Yijie Xu on 12/31/19.
//  Copyright © 2019 yx. All rights reserved.
//

import Foundation

/**
 * A thread-safe user manager that stores all user related information on the local device.
 *
 * Not recommanded to be used in the production app duo to:
 *    1. Infomation will not be encrypted and could be leaked.
 *    2. User has to finish the transaction on the same device where the transaction was initiated
 *      which could potentially cause confusion since user may have multiple iOS devices signed
 *      in with the same Apple ID.
 *    3. If the app is deleted by accident, all associated user data will be pruned at the same time that
 *      could cause future issues for clients that sell auto-renewable subscriptions via IAP.
 */
public struct YXLocalUserManager:YXUserManager {
    /** A string that uniquely identifies the user. */
    private let userId:String
    private let productIds:Set<String>
    private let userDefaults = UserDefaults.standard
    private let existingSubscriptionKey = "com.yx.existingTransactions"
    private let pendingTransactionKey = "com.yx.pendingTransactions"
    
    public init(userIdentifier:String, productIdentifiers:Set<String>) {
        userId = userIdentifier
        productIds = productIdentifiers
    }
    
    public func user(callbackQueue: DispatchQueue, completion: @escaping YXUserCompletion) {
        guard let userDict = userDefaults.dictionary(forKey: userId) else{
            let user = YXUser(identifier: userId,
                              pendingTransactions: [],
                              existingSubscriptions: [],
                              productIdentifiers: productIds)
            update(user: user, callbackQueue: callbackQueue) { (error) in
                completion(user, error)
            }
            return
        }
        guard let dict = userDict as? [String:[String]] else{
            callbackQueue.async {
                completion(/*user= */nil, YXError(domain: .user, type: .unexpectedUser))
            }
            return
        }
        let pendingTransactions = dict[pendingTransactionKey] ?? []
        let existingTrasnactions = dict[existingSubscriptionKey] ?? []
        let user = YXUser(identifier: userId,
                          pendingTransactions: pendingTransactions,
                          existingSubscriptions: existingTrasnactions,
                          productIdentifiers: productIds)
        callbackQueue.async {
            completion(user, /*error= */nil)
        }
    }
    
    public func update(user: YXUser,
                       callbackQueue: DispatchQueue,
                       completion: @escaping YXUpdateCompletion) {
        guard user.identifier == userId else{
            callbackQueue.async {
                completion(YXError(domain: .user, type: .wrongUser))
            }
            return
        }
        let userDict = [
            existingSubscriptionKey: user.existingSubscriptions,
            pendingTransactionKey: user.pendingTransactions
        ]
        userDefaults.set(userDict, forKey: userId)
        callbackQueue.async {
            completion(/*error =*/nil)
        }
    }
}
