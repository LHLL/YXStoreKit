//
//  FakeYXReceiptValidatorTest.swift
//  YXStoreKitTests
//
//  Created by Yijie Xu on 12/30/19.
//  Copyright © 2019 yx. All rights reserved.
//

import XCTest

class FakeYXReceiptValidatorTest: XCTestCase {
    
    func testSuccess() {
        let exp = expectation(description: "test a successful validation")
        FakeYXReceiptValidator(validatorMode: .succeed).validate(receipt: Data(),
                                                                 callbackQueue: .main)
        { (error) in
            XCTAssertNil(error)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.25, handler: nil)
    }
    
    func testFailure() {
        let exp = expectation(description: "test a successful validation")
        FakeYXReceiptValidator(validatorMode: .error).validate(receipt: Data(),
                                                                 callbackQueue: .main)
        { (error) in
            XCTAssertNotNil(error)
            XCTAssert(error is YXError)
            XCTAssertEqual((error as? YXError)?.domain, YXErrorDomain.receiptValidation)
            XCTAssertEqual((error as? YXError)?.type, YXErrorType.receipt)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.25, handler: nil)
    }
    
}
