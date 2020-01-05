//
//  YXProductRequestBuilderImp.swift
//  YXStoreKit
//
//  Created by Yijie Xu on 12/29/19.
//  Copyright © 2019 yx. All rights reserved.
//

import Foundation
import StoreKit

/** The concrete implementation of the [YXProductRequestBuilder]. */
public struct YXProductRequestBuilderImpl:YXProductRequestBuilder {
    public func build(productIdentifiers:Set<String>)->SKProductsRequest {
        return SKProductsRequest(productIdentifiers: productIdentifiers)
    }
}
