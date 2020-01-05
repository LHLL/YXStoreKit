//
//  YXReceiptRefreshRequestBuilder.swift
//  YXStoreKit
//
//  Created by Yijie Xu on 1/4/20.
//  Copyright © 2020 yx. All rights reserved.
//

import Foundation
import StoreKit

/** The concrete implementation of [YXReceiptRefreshRequestBuilder]. */
public struct YXReceiptRefreshRequestBuilderImpl:YXReceiptRefreshRequestBuilder {
    
    /**
     * Receipt refresh request property for the sandbox environment to control the local receipt state.
     * Nil for production environnment.
     */
    private let receiptProperties: [String : Any]?
    
    public init(receiptProperties properties: [String : Any]? = nil) {
        receiptProperties = properties
    }
    
    public func build() -> SKReceiptRefreshRequest {
        return SKReceiptRefreshRequest(receiptProperties: receiptProperties)
    }
}
