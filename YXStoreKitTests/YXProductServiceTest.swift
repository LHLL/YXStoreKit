//
//  YXProductServiceTest.swift
//  YXStoreKitTests
//
//  Created by Yijie Xu on 12/29/19.
//  Copyright © 2019 yx. All rights reserved.
//

import XCTest

class YXProductServiceTest: XCTestCase {
    
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

    func testFetchProducts(){
        let exp = expectation(description: "fetch products")
        let builder = FakeYXProductRequestBuilder(invalidIdentifiers: invalidIds,
                                                  requestMode: .normal)
        let service = YXProductService(builder: builder)
        service.fetchProducts(productIds: productIds, callbackQueue: .main) { [weak self] (products, invalids, error) in
            exp.fulfill()
            XCTAssertNil(error)
            XCTAssertEqual(invalids, self?.invalidIds)
            XCTAssertEqual(products.map({$0.productIdentifier}), self?.expectedProductsIds)
        }
        waitForExpectations(timeout: 0.25, handler: nil)
    }
    

}
