//
//  ProductRequestBuilder.swift
//  YXStoreKit
//
//  Created by Yijie Xu on 12/29/19.
//  Copyright © 2019 yx. All rights reserved.
//

import Foundation
import StoreKit

/** A builder that builds different types SKProductsRequest for different purposes. */
public protocol YXProductRequestBuilder {
    /**
     * Creates a [SKProductsRequest] using the passed-in identifiers.
     *
     * @param productIdentifiers A set of strings that each of them uniquely identifiers a product.
     * @return An instance of the [SKProductsRequest].
     */
    func build(productIdentifiers:Set<String>)->SKProductsRequest
}
