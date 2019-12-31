//
//  FakeYXReceiptValidatorTest.swift
//  YXStoreKitTests
//
//  Created by Yijie Xu on 12/30/19.
//  Copyright © 2019 yx. All rights reserved.
//

import XCTest

class FakeYXReceiptValidatorTest: XCTestCase {
    private let expectedData = "test".data(using: .utf8)
    
    func testSuccess() {
        let exp = expectation(description: "test a successful validation")
        FakeYXReceiptValidator(expectedData: expectedData!).validate(receipt: expectedData!,
                                                                 callbackQueue: .main)
        { (error) in
            XCTAssertNil(error)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.25, handler: nil)
    }
    
    func testFailure() {
        let exp = expectation(description: "test a successful validation")
        FakeYXReceiptValidator(expectedData: expectedData!).validate(receipt: Data(),
                                                                 callbackQueue: .main)
        { (error) in
            XCTAssertNotNil(error)
            XCTAssert(error is YXError)
            XCTAssertEqual((error as? YXError)?.domain, YXErrorDomain.receipt)
            XCTAssertEqual((error as? YXError)?.type, YXErrorType.receiptValidationFailed)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.25, handler: nil)
    }
    
}
