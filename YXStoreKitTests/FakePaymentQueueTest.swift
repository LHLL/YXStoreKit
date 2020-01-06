//
//  FakePaymentQueueTest.swift
//  YXStoreKitTests
//
//  Created by Yijie Xu on 1/4/20.
//  Copyright © 2020 yx. All rights reserved.
//

import XCTest
import StoreKit

class FakePaymentQueueTest: XCTestCase {
    
    private var exp:XCTestExpectation?
    private var queue:FakeSKPaymentQueue?
    private var failedTransaction:FakeSKPaymentTransaction?

    override func setUp() {
        super.setUp()
        failedTransaction = FakeSKPaymentTransaction(payment: SKMutablePayment(),
                                                     transactionMode: .fail)
        queue = FakeSKPaymentQueue(transactions: [failedTransaction!])
        queue?.add(self)
        XCTAssertEqual(queue?.observers.count, 1)
    }

    override func tearDown() {
        queue?.remove(self)
        XCTAssertEqual(queue?.observers.count, 0)
        exp = nil
        super.tearDown()
    }
    
    func testAdd() {
        exp = expectation(description: "Test add payment")
        queue?.add(SKMutablePayment())
        waitForExpectations(timeout: 0.25, handler: nil)
    }
    
    func testFinish() {
        queue?.transactions.forEach({queue!.finishTransaction($0)})
        XCTAssert(queue!.transactions.isEmpty)
    }

}

extension FakePaymentQueueTest:SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        if transactions.contains(where: {$0.transactionState == .purchased}) {
            XCTAssert(transactions.contains(where: {$0.transactionState == .failed}))
            exp?.fulfill()
        }
    }
}
