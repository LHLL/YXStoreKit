//
//  ReceiptRefreshRequestBuilder.swift
//  YXStoreKit
//
//  Created by Yijie Xu on 1/4/20.
//  Copyright © 2020 yx. All rights reserved.
//

import Foundation
import StoreKit

/** A builder that builds different types SKReceiptRefreshRequest for different purposes. */
public protocol YXReceiptRefreshRequestBuilder {
    /**
     * Creates a [SKReceiptRefreshRequest] using the passed-in properties.
     *
     * @return An instance of the [SKReceiptRefreshRequest].
     */
    func build()->SKReceiptRefreshRequest
}
