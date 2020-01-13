//
//  YXTransactionManagerTest.swift
//  YXStoreKitTests
//
//  Created by Yijie Xu on 1/5/20.
//  Copyright © 2020 yx. All rights reserved.
//

import XCTest
import StoreKit

class YXTransactionManagerTest: XCTestCase {
    
    private let user = YXUser(identifier: "user",
                              pendingTransactions: ["product1"],
                              existingSubscriptions: ["product2"],
                              productIdentifiers: ["product1", "product2", "product3"])
    private let userManager = YXLocalUserManager(userIdentifier: "user",
                                                 productIdentifiers: ["product1", "product2", "product3"])
    private let receiptUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test")
    private let receiptData = "test".data(using: .utf8)
    
    private var queue:FakeSKPaymentQueue!
    private var receiptManager:YXReceiptManager!

    override func setUp() {
        super.setUp()
        let validator = FakeYXReceiptValidator(expectedData: receiptData!)
        let builder = FakeYXReceiptRefreshRequestBuilder(mode: .normal,
                                                         receipt: receiptData,
                                                         url: receiptUrl)
        let refresher = YXReceiptRefresherImpl(requestBuilder: builder)
        receiptManager = YXReceiptManagerImpl(receiptValidator: validator,
                                              receiptRefresher: refresher,
                                              receiptUrl: receiptUrl)
        write(data: receiptData!)
    }

    override func tearDown() {
        prune()
        XCTAssertNil(try? Data(contentsOf: receiptUrl))
        UserDefaults.standard.removeObject(forKey: "user")
        super.tearDown()
    }
    
    func testWrongAppleID() {
        let exp = expectation(description: "observe an empty payment queue.")
        queue = FakeSKPaymentQueue(transactions: [])
        let manager = YXTransactionManagerImpl(paymentQueue: queue,
                                               receiptManager: receiptManager,
                                               userManager: userManager)
        manager.startObserving(for: user, callbackQueue: .main) { (error) in
            XCTAssertEqual(error.count, 1)
            XCTAssertEqual(error.first?.domain, YXErrorDomain.transaction)
            XCTAssertEqual(error.first?.type, YXErrorType.wrongAppleId)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.25, handler: nil)
    }
    
    func testProcessPending() {
        let exp = expectation(description: "pending transaction is handled.")
        let product = FakeSKProduct(productId: "product1")
        let transaction = FakeSKPaymentTransaction(payment: SKMutablePayment(product: product),
                                                   transactionMode: .succeed)
        transaction.state = .purchased
        queue = FakeSKPaymentQueue(transactions: [transaction])
        let manager = YXTransactionManagerImpl(paymentQueue: queue,
                                               receiptManager: receiptManager,
                                               userManager: userManager)
        manager.startObserving(for: user, callbackQueue: .main) { (error) in
            XCTAssertTrue(error.isEmpty)
            XCTAssertTrue(self.queue.transactions.isEmpty)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.25, handler: nil)
    }
    
    func testErrorHandling() {
        let exp = expectation(description: "failed transaction is handled.")
        let product = FakeSKProduct(productId: "product1")
        let transaction = FakeSKPaymentTransaction(payment: SKMutablePayment(product: product),
                                                   transactionMode: .fail)
        transaction.state = .failed
        queue = FakeSKPaymentQueue(transactions: [transaction])
        let manager = YXTransactionManagerImpl(paymentQueue: queue,
                                               receiptManager: receiptManager,
                                               userManager: userManager)
        manager.startObserving(for: user, callbackQueue: .main) { (error) in
            XCTAssertEqual(error.count, 1)
            XCTAssertEqual(error.first?.domain, YXErrorDomain.transaction)
            XCTAssertEqual(error.first?.type, YXErrorType.normal(reason: "product1"))
            XCTAssertTrue(self.queue.transactions.isEmpty)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.25, handler: nil)
    }
    
    func testAutoRenewal(){
        let exp = expectation(description: "auto-renewal is handled.")
        let product1 = FakeSKProduct(productId: "product1")
        let transaction1 = FakeSKPaymentTransaction(payment: SKMutablePayment(product: product1),
                                                    transactionMode: .succeed)
        transaction1.state = .purchased
        let product2 = FakeSKProduct(productId: "product2")
        let transaction2 = FakeSKPaymentTransaction(payment: SKMutablePayment(product: product2),
                                                    transactionMode: .fail)
        transaction2.state = .purchased
        queue = FakeSKPaymentQueue(transactions: [transaction1,transaction2])
        let manager = YXTransactionManagerImpl(paymentQueue: queue,
                                               receiptManager: receiptManager,
                                               userManager: userManager)
        manager.startObserving(for: user, callbackQueue: .main) { (error) in
            XCTAssertTrue(error.isEmpty)
            XCTAssertTrue(self.queue.transactions.isEmpty)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.25, handler: nil)
    }
    
    func testUnownedTransactions(){
        let exp = expectation(description: "unowned transaction is handled.")
        let product1 = FakeSKProduct(productId: "product1")
        let transaction1 = FakeSKPaymentTransaction(payment: SKMutablePayment(product: product1),
                                                    transactionMode: .succeed)
        transaction1.state = .purchased
        let product2 = FakeSKProduct(productId: "product3")
        let transaction2 = FakeSKPaymentTransaction(payment: SKMutablePayment(product: product2),
                                                    transactionMode: .fail)
        transaction2.state = .purchased
        queue = FakeSKPaymentQueue(transactions: [transaction1,transaction2])
        let manager = YXTransactionManagerImpl(paymentQueue: queue,
                                               receiptManager: receiptManager,
                                               userManager: userManager)
        manager.startObserving(for: user, callbackQueue: .main) { (error) in
            XCTAssertTrue(error.isEmpty)
            XCTAssertEqual(self.queue.transactions.count, 1)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.25, handler: nil)
    }
    
    func testPurchase() {
        let exp = expectation(description: "product can be purchased.")
        let product1 = FakeSKProduct(productId: "product1")
        let product2 = FakeSKProduct(productId: "product3")
        let transaction = FakeSKPaymentTransaction(payment: SKMutablePayment(product: product1),
                                                   transactionMode: .succeed)
        transaction.state = .purchased
        queue = FakeSKPaymentQueue(transactions: [transaction])
        let manager = YXTransactionManagerImpl(paymentQueue: queue,
                                               receiptManager: receiptManager,
                                               userManager: userManager)
        manager.startObserving(for: user, callbackQueue: .main) { (error) in
            XCTAssertTrue(error.isEmpty)
            XCTAssertTrue(self.queue.transactions.isEmpty)
            manager.createTransaction(for: product2, callbackQueue: .main) { (error) in
                XCTAssertNil(error)
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 0.25, handler: nil)
    }

}

//MARK: Private Utility Methods
extension YXTransactionManagerTest {
    private func write(data:Data) {
        try? data.write(to: receiptUrl, options: .atomic)
    }
    
    private func prune(){
        try? FileManager.default.removeItem(at: receiptUrl)
    }
}
