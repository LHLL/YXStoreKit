//
//  SKProduct+PurchasableTest.swift
//  YXStoreKitTests
//
//  Created by Yijie Xu on 12/22/19.
//  Copyright © 2019 yx. All rights reserved.
//

import XCTest
import StoreKit

class SKProduct_PurchasableTest: XCTestCase {
    
    private let day = FakeSKProductSubscriptionPeriod(numOfUnit:1, unit:SKProduct.PeriodUnit.day)
    private let week = FakeSKProductSubscriptionPeriod(numOfUnit:1, unit:SKProduct.PeriodUnit.week)
    private let month = FakeSKProductSubscriptionPeriod(numOfUnit:1, unit:SKProduct.PeriodUnit.month)
    private let year = FakeSKProductSubscriptionPeriod(numOfUnit:1, unit:SKProduct.PeriodUnit.year)

    func testSKProductSubscriptionPeriodToYXSubscriptionPeriodCasting() {
        XCTAssertEqual(YXSubscriptionPeriod.day, YXSubscriptionPeriod(day))
        XCTAssertEqual(YXSubscriptionPeriod.week, YXSubscriptionPeriod(week))
        XCTAssertEqual(YXSubscriptionPeriod.month, YXSubscriptionPeriod(month))
        XCTAssertEqual(YXSubscriptionPeriod.year, YXSubscriptionPeriod(year))
    }

}
