//
//  FakeSKReceiptRefreshRequestTest.swift
//  YXStoreKitTests
//
//  Created by Yijie Xu on 1/4/20.
//  Copyright © 2020 yx. All rights reserved.
//

import XCTest
import StoreKit

class FakeSKReceiptRefreshRequestTest: XCTestCase {
    private let expectedErrorDomain = "com.yxstorekit.receipt"
    private let expectedErrorMessage = "User cancelled the request."
    
    private var exp:XCTestExpectation?
    private var expectedData:Data?
    private var expectedUrl:URL?
    
    override func tearDown() {
        if let url = expectedUrl {
            try? FileManager.default.removeItem(at: url)
        }
        expectedData = nil
        expectedUrl = nil
        super.tearDown()
    }

    func testUserDoesNotHaveReceiptAfterRefresh() {
        exp = expectation(description: "test no receipt")
        let request = FakeSKReceiptRefreshRequest(requestMode: .normal)
        request.delegate = self
        request.start()
        waitForExpectations(timeout: 0.25, handler: nil)
    }
    
    func testUserHasReceiptAfterRefresh() {
        exp = expectation(description: "test having receipt")
        expectedData = "test".data(using: .utf8)
        expectedUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test")
        let request = FakeSKReceiptRefreshRequest(requestMode: .normal,
                                                  receiptData: expectedData,
                                                  receiptUrl: expectedUrl)
        request.delegate = self
        request.start()
        waitForExpectations(timeout: 0.25, handler: nil)
    }
    
    func testCalcel() {
        exp = expectation(description: "test cancel")
        let request = FakeSKReceiptRefreshRequest(requestMode: .idle)
        request.delegate = self
        request.start()
        request.cancel()
        waitForExpectations(timeout: 0.25, handler: nil)
    }
}

extension FakeSKReceiptRefreshRequestTest: SKRequestDelegate {
    func request(_ request: SKRequest, didFailWithError error: Error) {
        XCTAssertEqual((error as? YXError)?.domain.message, expectedErrorDomain)
        XCTAssertEqual((error as? YXError)?.type.message, expectedErrorMessage)
        exp?.fulfill()
    }
    
    func requestDidFinish(_ request: SKRequest) {
        if let data = expectedData, let url = expectedUrl {
            XCTAssertEqual(data, try? Data(contentsOf: url))
        }
        exp?.fulfill()
    }
}
