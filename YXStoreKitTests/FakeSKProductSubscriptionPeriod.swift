//
//  Fake SKProductSubscriptionPeriod.swift
//  YXStoreKitTests
//
//  Created by Yijie Xu on 12/22/19.
//  Copyright © 2019 yx. All rights reserved.
//

import UIKit
import StoreKit

class FakeSKProductSubscriptionPeriod: SKProductSubscriptionPeriod {
    
    override
    var numberOfUnits:Int {
        return num
    }
    
    override
    var unit:SKProduct.PeriodUnit {
        return fakeUnit
    }
    
    private var num:Int = 0
    private var fakeUnit:SKProduct.PeriodUnit
    
    init(numOfUnit:Int, unit:SKProduct.PeriodUnit) {
        self.num = numOfUnit
        self.fakeUnit = unit
    }
}
