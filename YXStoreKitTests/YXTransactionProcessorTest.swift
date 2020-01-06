//
//  YXTransactionProcessorTest.swift
//  YXStoreKitTests
//
//  Created by Yijie Xu on 1/5/20.
//  Copyright © 2020 yx. All rights reserved.
//

import XCTest
import StoreKit

class YXTransactionProcessorTest: XCTestCase {
    
    private var user:YXUser!
        
    override func setUp() {
        super.setUp()
        user = YXUser(identifier: "user",
                      pendingTransactions: ["product1"],
                      existingSubscriptions: ["product3"],
                      productIdentifiers: ["product1", "product2", "product3"])
    }
    
    func testValidate(){
        let error = YXTransactionProcessor.validate(product:FakeSKProduct(productId:"product1"),
                                                       user:user,
                                                       disabledProducts:[])
        XCTAssertEqual(error?.domain, YXErrorDomain.transaction)
        XCTAssertEqual(error?.type, YXErrorType.duplicateTransaction)
        let err = YXTransactionProcessor.validate(product:FakeSKProduct(productId:"product1"),
                                                  user:user,     
                                                  disabledProducts:["product1"])
        XCTAssertEqual(err?.domain, YXErrorDomain.transaction)
        XCTAssertEqual(err?.type, YXErrorType.unavailableProduct)
        let e = YXTransactionProcessor.validate(product:FakeSKProduct(productId:"product3"),
                                                user:user,
                                                disabledProducts:[])
        XCTAssertEqual(e?.domain, YXErrorDomain.transaction)
        XCTAssertEqual(e?.type, YXErrorType.existingSubscription)
    }
    
    func testProcessTransaction() {
        let failed = FakeSKPaymentTransaction(payment: SKMutablePayment(product:FakeSKProduct(productId:"product1")),
                                              transactionMode: .fail)
        failed.state = .failed
        let succeed = FakeSKPaymentTransaction(payment: SKMutablePayment(product:FakeSKProduct(productId:"product2")),
                                               transactionMode: .succeed)
        succeed.state = .purchased
        let restored = FakeSKPaymentTransaction(payment: SKMutablePayment(product:FakeSKProduct(productId:"product3")),
                                                transactionMode: .succeed)
        restored.state = .restored
        let response = YXTransactionProcessor.process(transactions: [failed, succeed, restored], for: user)
        XCTAssertEqual(response.disabledProductIdentifiers, ["product2"])
        XCTAssertEqual(response.failedTransactions.count, 1)
        XCTAssertTrue(response.failedTransactions.first?.payment.productIdentifier == "product1")
        XCTAssertEqual(response.finishedTransactions.count, 1)
        XCTAssertTrue(response.finishedTransactions.first?.payment.productIdentifier == "product3")
        XCTAssertFalse(response.wrongAppleID)
    }
    
    func testWrongAppleId() {
        let response = YXTransactionProcessor.process(transactions: [], for: user)
        XCTAssertTrue(response.wrongAppleID)
    }
}
