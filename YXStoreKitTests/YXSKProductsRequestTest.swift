//
//  YXSKProductsRequestTest.swift
//  YXStoreKitTests
//
//  Created by Yijie Xu on 12/29/19.
//  Copyright © 2019 yx. All rights reserved.
//

import XCTest
import StoreKit

class YXSKProductsRequestTest: XCTestCase {
    
    private let invalidIds = [
        "com.yx.invalid1",
        "com.yx.invalid2",
    ]
    private let productIds:Set<String> = [
        "com.yx.valid1",
        "com.yx.valid2",
        "com.yx.invalid1",
        "com.yx.invalid2",
    ]
    private let expectedProductsIds:[String] = [
        "com.yx.valid1",
        "com.yx.valid2",
    ]
    private let expectedErrorDomain = "com.yxstorekit.products"
    private let expectedErrorMessage = "User cancelled the request."
    
    private var exp:XCTestExpectation?

    func testStart() {
        exp = expectation(description: "test start")
        let request = FakeSKProductsRequest(productIdentifiers: productIds,
                                            invalidIdentifiers: invalidIds,
                                            requestMode: .normal)
        request.delegate = self
        request.start()
        waitForExpectations(timeout: 0.25, handler: nil)
    }
    
    func testCalcel() {
        exp = expectation(description: "test cancel")
        let request = FakeSKProductsRequest(productIdentifiers: productIds,
                                            invalidIdentifiers: invalidIds,
                                            requestMode: .idle)
        request.delegate = self
        request.start()
        request.cancel()
        waitForExpectations(timeout: 0.25, handler: nil)
    }
}

extension YXSKProductsRequestTest: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        XCTAssertEqual(invalidIds, response.invalidProductIdentifiers)
        XCTAssertEqual(expectedProductsIds, response.products.map({$0.productIdentifier}).sorted())
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        exp?.fulfill()
        XCTAssert(error is YXError)
        XCTAssertEqual((error as! YXError).domain.message, expectedErrorDomain)
        XCTAssertEqual((error as! YXError).type.message, expectedErrorMessage)
    }
    
    func requestDidFinish(_ request: SKRequest) {
        exp?.fulfill()
    }
}
