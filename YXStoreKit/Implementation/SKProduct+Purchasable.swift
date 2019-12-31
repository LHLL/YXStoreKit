//
//  SKProduct+Purchasable.swift
//  YXStoreKit
//
//  Created by Yijie Xu on 12/22/19.
//  Copyright © 2019 yx. All rights reserved.
//

import StoreKit

extension YXSubscriptionPeriod {
    public init(_ period:SKProductSubscriptionPeriod) {
        self = YXSubscriptionPeriod.allCases[Int(period.unit.rawValue)]
    }
}

extension SKProduct:YXProduct {
    public var subscriptionUnit: YXSubscriptionPeriod? {
        if let unit = self.subscriptionPeriod {
            return YXSubscriptionPeriod(unit)
        }
        return nil;
    }
    
    public var numberOfUnits: Int {
        return self.subscriptionPeriod?.numberOfUnits ?? 0
    }
}
