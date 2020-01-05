//
//  YXLocalUserManagerTest.swift
//  YXStoreKitTests
//
//  Created by Yijie Xu on 12/31/19.
//  Copyright © 2019 yx. All rights reserved.
//

import XCTest

class YXLocalUserManagerTest: XCTestCase {
    
    private let userId = "test user"
    private let wrongId = "wrong user"
    private let pendingTransactions = [
        "transaction1",
        "transaction2",
    ]
    private let existingTransactions = [
        "transaction3",
        "transaction4",
    ]
    private let productIds:Set<String> = []
    private let existingTransactionKey = "com.yx.existingTransactions"
    private let pendingTransactionKey = "com.yx.pendingTransactions"
    private var manager:YXUserManager!
    
    override func setUp() {
        manager = YXLocalUserManager(userIdentifier:userId,
                                     productIdentifiers:productIds)
        super.setUp()
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: userId)
        UserDefaults.standard.removeObject(forKey: wrongId)
        super.tearDown()
    }

    func testGetUserWhenThereIsNoUser() {
        let exp = expectation(description: "new user creation is handled.")
        manager.user(callbackQueue: .main) {[weak self] (user, error) in
            XCTAssertNil(error)
            XCTAssertEqual(user?.identifier, self?.userId)
            XCTAssertEqual(user?.existingSubscriptions, [])
            XCTAssertEqual(user?.pendingTransactions, [])
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.25, handler: nil)
    }
    
    /** User login with account A and then switch to account B but client app doesn't create a new user manager. */
    func testWrongUserId() {
        let exp = expectation(description: "wrong user id is handled.")
        let wrongUser = YXUser(identifier: wrongId,
                               pendingTransactions: pendingTransactions,
                               existingSubscriptions: existingTransactions,
                               productIdentifiers: productIds)
        manager.update(user: wrongUser, callbackQueue: .main) { (error) in
            XCTAssertEqual(error?.domain, YXErrorDomain.user)
            XCTAssertEqual(error?.type, YXErrorType.wrongUser)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.25, handler: nil)
    }
    
    func testUserCanBeUpdated() {
        let exp = expectation(description: "user can be updated.")
        let expectedUser = YXUser(identifier: userId,
                                  pendingTransactions: pendingTransactions,
                                  existingSubscriptions: existingTransactions,
                                  productIdentifiers: productIds)
        manager.update(user: expectedUser, callbackQueue: .main,
                       completion: {[weak self] (error) in
            self?.manager.user(callbackQueue: .main) {(user, error) in
                XCTAssertNil(error)
                XCTAssertEqual(user, expectedUser)
                exp.fulfill()
            }
        })
        waitForExpectations(timeout: 0.25, handler: nil)
    }
    
    func testUnexpectedUser(){
        let exp = expectation(description: "unexpected data can be updated.")
        let unpectedData:[String:Any] = [
            "unexpectedKey": "unexpected data",
            existingTransactionKey: existingTransactions,
            pendingTransactionKey: pendingTransactions,
        ]
        UserDefaults.standard.set(unpectedData, forKey: userId)
        manager.user(callbackQueue: .main) {(user, error) in
            XCTAssertNil(user)
            XCTAssertEqual(error?.domain, YXErrorDomain.user)
            XCTAssertEqual(error?.type, YXErrorType.unexpectedUser)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.25, handler: nil)
    }
}
