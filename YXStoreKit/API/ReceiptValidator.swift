//
//  ReceiptValidator.swift
//  YXStoreKit
//
//  Created by Yijie Xu on 12/30/19.
//  Copyright © 2019 yx. All rights reserved.
//

import Foundation

/**
 * Protocol defines a validator that can validate the App Store receipt.
 *
 * Client app needs to implement this protocol.
 * Typically, Apple suggests that the receipt should be validated by the backend. Even the client choose to validate it
 * in the app, it should still be conducted async in a queue that is not the main queue.
 */
public protocol YXReceiptValidator{
    /**
     * Validates the passed-in receipt in the binary format.
     *
     * @param receipt The App Store receipt in the binary format.
     * @param callbackQueue The queue that the completion will be called in.
     * @param completion A block to be called when the async method is finished.
     */
    func validate(receipt:Data, callbackQueue:DispatchQueue, completion: @escaping ((Error?)->Void))
}
