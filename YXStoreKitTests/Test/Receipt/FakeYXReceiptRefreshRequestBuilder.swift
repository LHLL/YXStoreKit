//
//  FakeYXReceiptRefreshRequestBuilder.swift
//  YXStoreKitTests
//
//  Created by Yijie Xu on 1/4/20.
//  Copyright © 2020 yx. All rights reserved.
//

import Foundation
import StoreKit

/** Testable implementation oi [YXReceiptRefreshRequestBuilder]. */
struct FakeYXReceiptRefreshRequestBuilder:YXReceiptRefreshRequestBuilder {
    
    let mode:YXFakeRequestMode
    let receipt:Data?
    let url:URL?
    
    func build() -> SKReceiptRefreshRequest {
        return FakeSKReceiptRefreshRequest(requestMode: mode,
                                           receiptData: receipt,
                                           receiptUrl: url)
    }
}
