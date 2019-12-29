//
//  FakeSKProduct.swift
//  YXStoreKitTests
//
//  Created by Yijie Xu on 12/29/19.
//  Copyright © 2019 yx. All rights reserved.
//

import UIKit
import StoreKit

/** Testable SKProduct. */
class FakeSKProduct: SKProduct {
    
    override var productIdentifier: String {
        return productId
    }
    private let productId:String
    
    init(productId:String) {
        self.productId = productId
    }
    
}
