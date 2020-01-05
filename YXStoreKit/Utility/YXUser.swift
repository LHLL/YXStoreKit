//
//  YXUser.swift
//  YXStoreKit
//
//  Created by Yijie Xu on 12/31/19.
//  Copyright © 2019 yx. All rights reserved.
//

import Foundation

/** An user object that can purchase a product. */
public struct YXUser:Equatable {
    /**
     * A string that uniquely identifies a user.
     *
     * This value should be provided by the client app, clinet app should at least
     * integrate [Login with Apple] if it doesn't provide an account sysytem.
     */
    let identifier:String
    
    /**
     * A list of strings that each of them uniquely identifies a pending transaction.
     *
     * Idearly, this value should be stored on the server side and fetched as soon as app launches.
     */
    let pendingTransactions:[String]
    
    /**
     * A list of strings that each of them uniquely identifies a subscription.
     *
     * Idearly, this value should be stored on the server side and fetched as soon as app launches.
     */
    let existingSubscriptions:[String]
    
    /**
     * A list of products that are available for the user to purchase.
     *
     * Idearly, this value should be stored on the server side and fetched as soon as app launches.
     */
    let productIdentifiers:Set<String>
    
}
