//
//  YXReceiptRefresherTest.swift
//  YXStoreKitTests
//
//  Created by Yijie Xu on 1/4/20.
//  Copyright © 2020 yx. All rights reserved.
//

import XCTest

class YXReceiptRefresherTest: XCTestCase {

    func testRefresh() {
        let exp = expectation(description: "test single request is handled")
        let builder = FakeYXReceiptRefreshRequestBuilder(mode:.normal,
                                                         receipt: nil,
                                                         url: nil)
        let refresher = YXReceiptRefresherImpl(requestBuilder: builder)
        refresher.refresh(callbackQueue: .main) { (error) in
            XCTAssertNil(error)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.25, handler: nil)
    }
    
    func testErrorHandling() {
        let exp = expectation(description: "test error is handled")
        let builder = FakeYXReceiptRefreshRequestBuilder(mode:.cancel,
                                                         receipt: nil,
                                                         url: nil)
        let refresher = YXReceiptRefresherImpl(requestBuilder: builder)
        refresher.refresh(callbackQueue: .main) { (error) in
            XCTAssertEqual(error?.domain, YXErrorDomain.receipt)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.25, handler: nil)
    }
    
    func testDuplicateRequests() {
        let exp = expectation(description: "test duplicate requests are handled")
        let builder = FakeYXReceiptRefreshRequestBuilder(mode:.delayed,
                                                         receipt: nil,
                                                         url: nil)
        let refresher = YXReceiptRefresherImpl(requestBuilder: builder)
        var count = 0
        refresher.refresh(callbackQueue: .main) { (error) in
            XCTAssertNil(error)
            if count == 1 {
                exp.fulfill()
            } else {
                count += 1
            }
        }
        refresher.refresh(callbackQueue: .main) { (error) in
            XCTAssertNil(error)
            if count == 1 {
                exp.fulfill()
            } else {
                count += 1
            }
        }
        waitForExpectations(timeout: 1.5, handler: nil)
    }

}
