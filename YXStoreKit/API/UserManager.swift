//
//  UserManager.swift
//  YXStoreKit
//
//  Created by Yijie Xu on 12/31/19.
//  Copyright © 2019 yx. All rights reserved.
//

import Foundation

/** A closure that provides callback for the [user] defined in the [YXUserManager]. */
public typealias YXUserCompletion = ((
    _ user: YXUser?,
    _ error: YXError?)->Void)

/** A closure that provides callback for the [update] defined in the [YXUserManager]. */
public typealias YXUpdateCompletion = ((
    _ error: YXError?)->Void)

/**
 * Manager that manages the state of the user.
 *
 * Client apps that store data on the server side should implement this protol by themselves.
 */
public protocol YXUserManager {
    /**
     * Fetches immutable user object from the database.
     *
     * @param callbackQueue A dispatch queue that the completion closure will be called in.
     * @param completion A closure that will be called when the async method is finished.
     */
    func user(callbackQueue:DispatchQueue, completion: @escaping YXUserCompletion)
    
    /**
     * Updates the user info in the database.
     *
     * @param user The new user object that needs to be updated with the database.
     * @param callbackQueue A dispatch queue that the completion closure will be called in.
     * @param completion A closure that will be called when the async method is finished.
     */
    func update(user:YXUser, callbackQueue:DispatchQueue, completion: @escaping YXUpdateCompletion)
}
