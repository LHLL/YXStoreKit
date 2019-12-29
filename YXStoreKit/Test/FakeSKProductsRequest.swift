//
//  FakeSKProductsRequest.swift
//  YXStoreKitTests
//
//  Created by Yijie Xu on 12/28/19.
//  Copyright © 2019 yx. All rights reserved.
//

import UIKit
import StoreKit

class FakeSKProductsRequest: SKProductsRequest {
    
    private let productsIds: Set<String>
    private let invalidIds: [String]
    
    init(productIdentifiers: Set<String>, invalidIdentifiers:[String]) {
        productsIds = productIdentifiers
        invalidIds = invalidIdentifiers
        super.init(productIdentifiers: productIdentifiers)
    }
    
    override
    func start() {
        let response = FakeSKProductsResponse(productIdentifiers: productsIds,
                                              invalidIdentifiers: invalidIds)
        delegate?.productsRequest(self, didReceive: response)
        delegate?.requestDidFinish?(self)
    }
    
    override
    func cancel() {
        let error = YXError(domain: .products,
                            type: .userCancelled)
        delegate?.request?(self, didFailWithError: error)
    }
    
}
