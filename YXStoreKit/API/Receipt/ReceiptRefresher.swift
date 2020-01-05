//
//  ReceiptRefresher.swift
//  YXStoreKit
//
//  Created by Yijie Xu on 1/4/20.
//  Copyright © 2020 yx. All rights reserved.
//

import Foundation

/**
 * Object that downloads the latest App Store receipt to the local disk.
 *
 * Although receipts typically update immediately after a completed purchase or restored purchase, changes can happen
 * at other times when the app is not running. App should refresh receipt during the app launch to ensure the receipt we
 * are working with is up-to-date, such as when a subscription renews in the background.
 */
public protocol YXReceiptRefresher {
    /**
     * Refreshes App Store receipt with Apple.
     *
     * @param callbackQueue A queue that completion closure will be called in.
     * @param completion A closure to be invoked when the call is finished.
     */
    func refresh(callbackQueue:DispatchQueue, completion:@escaping ((YXError?)->Void))
}
