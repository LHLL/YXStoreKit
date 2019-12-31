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
    private let validIds:Set<String> = [
        "com.yx.valid1",
        "com.yx.valid2",
    ]

    func testFetchProducts(){
        let exp = expectation(description: "fetch products")
        let builder = FakeYXProductRequestBuilder(invalidIdentifiers: invalidIds,
                                                  requestMode: .normal)
        let service = YXProductServiceImpl(builder: builder)
        service.fetchProducts(productIds: productIds, callbackQueue: .main) { [weak self] (products, invalids, error) in
            exp.fulfill()
            XCTAssertNil(error)
            XCTAssertEqual(invalids, self?.invalidIds)
            XCTAssertEqual(products.map({$0.productIdentifier}).sorted(), self?.expectedProductsIds)
        }
        waitForExpectations(timeout: 0.25, handler: nil)
    }
    
    func testDuplicateRequests(){
        let exp = expectation(description: "duplicate requests")
        let builder = FakeYXProductRequestBuilder(invalidIdentifiers: invalidIds,
                                                  requestMode: .delayed)
        let service = YXProductServiceImpl(builder: builder)
        var callbackCount = 0
        service.fetchProducts(productIds: productIds, callbackQueue: .main) { [weak self] (products, invalids, error) in
            if callbackCount == 1 {
                exp.fulfill()
            } else {
                callbackCount += 1
            }
            XCTAssertNil(error)
            XCTAssertEqual(invalids, self?.invalidIds)
            XCTAssertEqual(products.map({$0.productIdentifier}).sorted(), self?.expectedProductsIds)
        }
        service.fetchProducts(productIds: productIds, callbackQueue: .main) { [weak self] (products, invalids, error) in
            if callbackCount == 1 {
                exp.fulfill()
            } else {
                callbackCount += 1
            }
            XCTAssertNil(error)
            XCTAssertEqual(invalids, self?.invalidIds)
            XCTAssertEqual(products.map({$0.productIdentifier}).sorted(), self?.expectedProductsIds)
        }
        waitForExpectations(timeout: 1.25, handler: nil)
    }
    
    func testMultipleRequests() {
        let exp = expectation(description: "multiple requests")
        let builder = FakeYXProductRequestBuilder(invalidIdentifiers: invalidIds,
                                                  requestMode: .delayed)
        let service = YXProductServiceImpl(builder: builder)
        var callbackCount = 0
        service.fetchProducts(productIds: productIds, callbackQueue: .main) { [weak self] (products, invalids, error) in
            if callbackCount == 1 {
                exp.fulfill()
            } else {
                callbackCount += 1
            }
            XCTAssertNil(error)
            XCTAssertEqual(invalids, self?.invalidIds)
            XCTAssertEqual(products.map({$0.productIdentifier}).sorted(), self?.expectedProductsIds)
        }
        service.fetchProducts(productIds: validIds, callbackQueue: .main) { [weak self] (products, invalids, error) in
            if callbackCount == 1 {
                exp.fulfill()
            } else {
                callbackCount += 1
            }
            XCTAssertNil(error)
            XCTAssertEqual(invalids, self?.invalidIds)
            XCTAssertEqual(products.map({$0.productIdentifier}).sorted(), self?.expectedProductsIds)
        }
        waitForExpectations(timeout: 1.25, handler: nil)
    }

}
