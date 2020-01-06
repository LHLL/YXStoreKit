//
//  ReceiptManager.swift
//  YXStoreKit
//
//  Created by Yijie Xu on 12/30/19.
//  Copyright © 2019 yx. All rights reserved.
//

import Foundation

/** A protocol that manages local App Store receipt. */
public protocol YXReceiptManager {
    /**
     * Validates the App Store receipt.
     *
     * @param callbackQueue A queue that the completion block will be called in.
     * @param completion A block to be invoked when the async method is finished.
     */
    func validateReceipt(callbackQueue:DispatchQueue, completion:@escaping ((YXError?)->Void))
}
