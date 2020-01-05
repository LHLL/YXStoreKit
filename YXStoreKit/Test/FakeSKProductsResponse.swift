//
//  FakeSKProductsResponse.swift
//  YXStoreKitTests
//
//  Created by Yijie Xu on 12/29/19.
//  Copyright © 2019 yx. All rights reserved.
//

import UIKit
import StoreKit

/** Testable SKProductsResponse. */
class FakeSKProductsResponse: SKProductsResponse {
    
    override
    var invalidProductIdentifiers: [String] {
        return invalidIds
    }
    
    override
    var products: [SKProduct] {
        return skProducts
    }
    
    private let invalidIds:[String]
    private let skProducts:[SKProduct]
    
    init(productIdentifiers: Set<String>, invalidIdentifiers:[String]){
        invalidIds = invalidIdentifiers
        let ids = productIdentifiers.filter({!invalidIdentifiers.contains($0)})
        var prods = [SKProduct]()
        for id in ids {
            
            prods.append(FakeSKProduct(productId: id))
        }
        skProducts = prods
    }
}
