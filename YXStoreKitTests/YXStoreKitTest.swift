//
//  YXStoreKitTest.swift
//  YXStoreKitTests
//
//  Created by Yijie Xu on 1/12/20.
//  Copyright © 2020 yx. All rights reserved.
//

import XCTest
import StoreKit

class YXStoreKitTest: XCTestCase {
    
    private var productService: YXProductService!
    private var receiptManager: YXReceiptManager!
    private let user = "test user"
    private let receiptUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test")
    private let productIdentifiers:Set<String> = [
        "com.test.valid1",
        "com.test.valid2",
        "com.test.valid3",
        "com.test.invalid1",
        "com.test.invalid2",
    ]
    private let invalidIdentifiers = [
        "com.test.invalid1",
        "com.test.invalid2",
    ]
    private lazy var userManager = YXLocalUserManager(userIdentifier: user,
                                                      productIdentifiers: productIdentifiers)

    override func setUp() {
        super.setUp()
        let builder = FakeYXProductRequestBuilder(invalidIdentifiers: invalidIdentifiers, requestMode: .normal)
        productService = YXProductServiceImpl(builder: builder)
        
        let data = "test".data(using: .utf8)!
        let validator = FakeYXReceiptValidator(expectedData: data)
        let refresher = YXReceiptRefresherImpl(requestBuilder: FakeYXReceiptRefreshRequestBuilder(mode: .normal,
                                                                                                  receipt: data,
                                                                                                  url: receiptUrl))
        receiptManager = YXReceiptManagerImpl(receiptValidator: validator,
                                              receiptRefresher: refresher,
                                              receiptUrl: receiptUrl)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: receiptUrl)
        XCTAssertNil(try? Data(contentsOf: receiptUrl))
        super.tearDown()
    }
    
    func testStartObserving() {
        let exp = expectation(description: "An empty transaction queue will be handled")
        let trasnactionManager = YXTransactionManagerImpl(paymentQueue: FakeSKPaymentQueue(transactions: []),
                                                          receiptManager: receiptManager,
                                                          userManager: userManager)
        let storeKit = YXStoreKit(user: userManager,
                                  product: productService,
                                  receipt: receiptManager,
                                  transaction: trasnactionManager)
        storeKit.start(callbackQueue: .main) { (errors) in
            XCTAssert(errors.isEmpty)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.25, handler: nil)
    }
    
    func testSucceededTransactionIsHandledAfterStartObserving() {
        let exp = expectation(description: "Failed transactions queue will be handled")
        let payment = SKMutablePayment(product: FakeSKProduct(productId: "com.test.valid1"))
        let transaction = FakeSKPaymentTransaction(payment: payment,
                                                   transactionMode: .succeed)
        transaction.state = .purchased
        let queue = FakeSKPaymentQueue(transactions: [transaction])
        let data = "test".data(using: .utf8)!
        write(data: data)
        let newUser = YXUser(identifier: user,
                             pendingTransactions: ["com.test.valid1"],
                             existingSubscriptions: [],
                             productIdentifiers:productIdentifiers)
        let trasnactionManager = YXTransactionManagerImpl(paymentQueue: queue,
                                                          receiptManager: receiptManager,
                                                          userManager: userManager)
        let storeKit = YXStoreKit(user: userManager,
                                  product: productService,
                                  receipt: receiptManager,
                                  transaction: trasnactionManager)
        userManager.update(user: newUser, callbackQueue: .main) { (error) in
            XCTAssertNil(error)
            storeKit.start(callbackQueue: .main) { (errors) in
                XCTAssertEqual(errors.count, 0)
                XCTAssertTrue(queue.transactions.isEmpty)
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 0.25, handler: nil)
    }
    
    func testFailedTransactionIsHandledAfterStartObserving() {
        let exp = expectation(description: "Failed transactions queue will be handled")
        let payment = SKMutablePayment(product: FakeSKProduct(productId: "com.test.valid1"))
        let transaction = FakeSKPaymentTransaction(payment: payment,
                                                   transactionMode: .fail)
        transaction.state = .failed
        let queue = FakeSKPaymentQueue(transactions: [transaction])
        let data = "test".data(using: .utf8)!
        write(data: data)
        let newUser = YXUser(identifier: user,
                             pendingTransactions: ["com.test.valid1"],
                             existingSubscriptions: [],
                             productIdentifiers:productIdentifiers)
        let trasnactionManager = YXTransactionManagerImpl(paymentQueue: queue,
                                                          receiptManager: receiptManager,
                                                          userManager: userManager)
        let storeKit = YXStoreKit(user: userManager,
                                  product: productService,
                                  receipt: receiptManager,
                                  transaction: trasnactionManager)
        userManager.update(user: newUser, callbackQueue: .main) { (error) in
            XCTAssertNil(error)
            storeKit.start(callbackQueue: .main) { (errors) in
                XCTAssertEqual(errors.count, 1)
                XCTAssertEqual(errors.first?.domain, YXErrorDomain.transaction)
                XCTAssertEqual(errors.first?.type, YXErrorType.normal(reason: "com.test.valid1"))
                XCTAssertTrue(queue.transactions.isEmpty)
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 0.25, handler: nil)
    }
    
    func testWrongAppleIdIsHandledAfterStartObserving() {
        let exp = expectation(description: "Wrong Apple Id will be handled")
        let queue = FakeSKPaymentQueue(transactions: [])
        let data = "test".data(using: .utf8)!
        write(data: data)
        let newUser = YXUser(identifier: user,
                             pendingTransactions: ["com.test.valid1"],
                             existingSubscriptions: [],
                             productIdentifiers:productIdentifiers)
        let trasnactionManager = YXTransactionManagerImpl(paymentQueue: queue,
                                                          receiptManager: receiptManager,
                                                          userManager: userManager)
        let storeKit = YXStoreKit(user: userManager,
                                  product: productService,
                                  receipt: receiptManager,
                                  transaction: trasnactionManager)
        userManager.update(user: newUser, callbackQueue: .main) { (error) in
            XCTAssertNil(error)
            storeKit.start(callbackQueue: .main) { (errors) in
                XCTAssertEqual(errors.count, 1)
                XCTAssertEqual(errors.first?.domain, YXErrorDomain.transaction)
                XCTAssertEqual(errors.first?.type, YXErrorType.wrongAppleId)
                XCTAssertTrue(queue.transactions.isEmpty)
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 0.25, handler: nil)
    }
    
    func testUnownedTransactionIsHandledAfterStartObserving() {
        let exp = expectation(description: "Succeeded transactions queue will be handled")
        let payment = SKMutablePayment(product: FakeSKProduct(productId: "com.test.valid1"))
        let transaction = FakeSKPaymentTransaction(payment: payment,
                                                   transactionMode: .fail)
        transaction.state = .failed
        let queue = FakeSKPaymentQueue(transactions: [transaction])
        let data = "test".data(using: .utf8)!
        write(data: data)
        let newUser = YXUser(identifier: user,
                             pendingTransactions: [],
                             existingSubscriptions: [],
                             productIdentifiers:productIdentifiers)
        let trasnactionManager = YXTransactionManagerImpl(paymentQueue: queue,
                                                          receiptManager: receiptManager,
                                                          userManager: userManager)
        let storeKit = YXStoreKit(user: userManager,
                                  product: productService,
                                  receipt: receiptManager,
                                  transaction: trasnactionManager)
        userManager.update(user: newUser, callbackQueue: .main) { (error) in
            XCTAssertNil(error)
            storeKit.start(callbackQueue: .main) { (errors) in
                XCTAssertEqual(errors.count, 0)
                XCTAssertEqual(queue.transactions.count, 1)
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 0.25, handler: nil)
    }
    
    func testHappyPath() {
        let exp = expectation(description: "A new transaction will be handled")
        let trasnactionManager = YXTransactionManagerImpl(paymentQueue: FakeSKPaymentQueue(transactions: []),
                                                          receiptManager: receiptManager,
                                                          userManager: userManager)
        let storeKit = YXStoreKit(user: userManager,
                                  product: productService,
                                  receipt: receiptManager,
                                  transaction: trasnactionManager)
        let product = FakeSKProduct(productId: "com.test.valid1")
        let newUser = YXUser(identifier: user,
                             pendingTransactions: [],
                             existingSubscriptions: [],
                             productIdentifiers:productIdentifiers)
        userManager.update(user: newUser, callbackQueue: .main) { (error) in
            XCTAssertNil(error)
            storeKit.start(callbackQueue: .main) { (errors) in
                XCTAssertTrue(errors.isEmpty)
                storeKit.purchase(product: product,
                                  discount: nil,
                                  quantity: 1,
                                  callbackQueue: .main) { (error) in
                    XCTAssertNil(error)
                    exp.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 0.25, handler: nil)
    }
    
    func testStartOberservingBeforePurchase() {
        let exp = expectation(description: "StartObserving needs to be called before purchase")
        let trasnactionManager = YXTransactionManagerImpl(paymentQueue: FakeSKPaymentQueue(transactions: []),
                                                          receiptManager: receiptManager,
                                                          userManager: userManager)
        let storeKit = YXStoreKit(user: userManager,
                                  product: productService,
                                  receipt: receiptManager,
                                  transaction: trasnactionManager)
        let product = FakeSKProduct(productId: "com.test.valid1")
        let newUser = YXUser(identifier: user,
                             pendingTransactions: [],
                             existingSubscriptions: [],
                             productIdentifiers:productIdentifiers)
        userManager.update(user: newUser, callbackQueue: .main) { (error) in
            XCTAssertNil(error)
            storeKit.purchase(product: product,
                              discount: nil,
                              quantity: 1,
                              callbackQueue: .main) { (error) in
                XCTAssertNotNil(error)
                XCTAssertEqual(error?.domain, YXErrorDomain.transaction)
                XCTAssertEqual(error?.type, YXErrorType.wrongUser)
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 0.25, handler: nil)
    }

}

extension YXStoreKitTest {
    private func write(data:Data) {
        try? data.write(to: receiptUrl, options: .atomic)
    }
    
    private func prune(){
        try? FileManager.default.removeItem(at: receiptUrl)
    }
}
