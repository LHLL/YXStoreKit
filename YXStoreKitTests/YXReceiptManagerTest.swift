//
//  YXReceiptManagerTest.swift
//  YXStoreKitTests
//
//  Created by Yijie Xu on 12/31/19.
//  Copyright © 2019 yx. All rights reserved.
//

import XCTest

class YXReceiptManagerTest: XCTestCase {
    
    private var url:URL!

    override func setUp() {
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test")
        super.setUp()
    }
    
    override func tearDown() {
        prune()
        XCTAssertNil(try? Data(contentsOf: url))
        super.tearDown()
    }
    
    func testWrite(){
        let data = "test".data(using: .utf8)
        XCTAssertNotNil(data)
        XCTAssertNil(try? Data(contentsOf: url))
        write(data: data!)
        let expected = try? Data(contentsOf: url)
        XCTAssertNotNil(expected)
        XCTAssertEqual(data, expected)
    }
    
    func testReceiptMissing(){
        let exp = expectation(description: "Missing local receipt is handled.")
        let validator = FakeYXReceiptValidator(expectedData: Data())
        let builder = FakeYXReceiptRefreshRequestBuilder(mode: .normal, receipt: nil, url: nil)
        let manager = YXReceiptManagerImpl(receiptValidator:validator,
                                           receiptRefresher: YXReceiptRefresherImpl(requestBuilder: builder), receiptUrl:url)
        manager.validateReceipt(callbackQueue: .main) { (error) in
            XCTAssertEqual((error as? YXError)?.domain, YXErrorDomain.receipt)
            XCTAssertEqual((error as? YXError)?.type, YXErrorType.receiptMissing)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.25, handler: nil)
    }
    
    func testReceiptValidation(){
        let exp = expectation(description: "Local receipt validation is handled.")
        let data = "test".data(using: .utf8)
        XCTAssertNotNil(data)
        write(data: data!)
        let builder = FakeYXReceiptRefreshRequestBuilder(mode:.normal,
                                                         receipt: nil,
                                                         url: nil)
        let refresher = YXReceiptRefresherImpl(requestBuilder: builder)
        let validator = FakeYXReceiptValidator(expectedData: data!)
        let manager = YXReceiptManagerImpl(receiptValidator:validator,
                                           receiptRefresher: refresher,
                                           receiptUrl:url)
        manager.validateReceipt(callbackQueue: .main) { (error) in
            XCTAssertNil(error)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.25, handler: nil)
    }
    
    func testReceiptMissingReceiptUrl(){
        let exp = expectation(description: "Missing local receipt url is handled.")
        let builder = FakeYXReceiptRefreshRequestBuilder(mode:.normal,
                                                         receipt: nil,
                                                         url: nil)
        let refresher = YXReceiptRefresherImpl(requestBuilder: builder)
        let validator = FakeYXReceiptValidator(expectedData: Data())
        let manager = YXReceiptManagerImpl(receiptValidator:validator,
                                           receiptRefresher:refresher,
                                           receiptUrl:nil)
        manager.validateReceipt(callbackQueue: .main) { (error) in
            XCTAssertEqual((error as? YXError)?.domain, YXErrorDomain.receipt)
            XCTAssertEqual((error as? YXError)?.type, YXErrorType.receiptMissing)
            exp.fulfill()
        }
        waitForExpectations(timeout: 1.25, handler: nil)
    }
    
    func testRefresher(){
        let exp = expectation(description: "automatica receipt refresh is handled.")
        let data = "test".data(using: .utf8)
        XCTAssertNotNil(data)
        let builder = FakeYXReceiptRefreshRequestBuilder(mode:.normal,
                                                         receipt: data,
                                                         url: url)
        let refresher = YXReceiptRefresherImpl(requestBuilder: builder)
        let validator = FakeYXReceiptValidator(expectedData: data!)
        let manager = YXReceiptManagerImpl(receiptValidator:validator,
                                           receiptRefresher: refresher,
                                           receiptUrl:url)
        manager.validateReceipt(callbackQueue: .main) { (error) in
            XCTAssertNil(error)
            exp.fulfill()
        }
        waitForExpectations(timeout: 1.25, handler: nil)
    }

}

//MARK: Private Utility Methods
extension YXReceiptManagerTest {
    private func write(data:Data) {
        try? data.write(to: url, options: .atomic)
    }
    
    private func prune(){
        try? FileManager.default.removeItem(at: url)
    }
}
