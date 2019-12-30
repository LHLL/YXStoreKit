//
//  FakeYXProductRequestBuilder.swift
//  YXStoreKitTests
//
//  Created by Yijie Xu on 12/29/19.
//  Copyright © 2019 yx. All rights reserved.
//

import Foundation
import StoreKit

struct FakeYXProductRequestBuilder: YXProductRequestBuilder {
    private let invalidIds:[String]
    private let mode:YXFakeRequestMode
    
    init(invalidIdentifiers:[String], requestMode:YXFakeRequestMode) {
        invalidIds = invalidIdentifiers
        mode = requestMode
    }
    
    public func build(productIdentifiers:Set<String>)->SKProductsRequest {
        return FakeSKProductsRequest(productIdentifiers: productIdentifiers,
                                     invalidIdentifiers: invalidIds,
                                     requestMode:mode)
    }
}
