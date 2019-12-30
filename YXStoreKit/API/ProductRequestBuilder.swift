//
//  ProductRequestBuilder.swift
//  YXStoreKit
//
//  Created by Yijie Xu on 12/29/19.
//  Copyright © 2019 yx. All rights reserved.
//

import Foundation
import StoreKit

public protocol YXProductRequestBuilder {
    func build(productIdentifiers:Set<String>)->SKProductsRequest
}
