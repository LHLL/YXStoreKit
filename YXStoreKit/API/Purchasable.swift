//
//  Purchasable.swift
//  YXStoreKit
//
//  Created by Yijie Xu on 12/22/19.
//  Copyright © 2019 yx. All rights reserved.
//

import Foundation

public enum YXSubscriptionPeriod:CaseIterable {
    case day, week, month, year
}

/** Defines a product that user can purchase. */
public protocol YXProduct {
    var productIdentifier: String {get}
    var localizedDescription: String {get}
    var localizedTitle: String {get}
    var price: NSDecimalNumber {get}
    var priceLocale: Locale {get}
    var subscriptionUnit: YXSubscriptionPeriod? {get}
    var numberOfUnits: Int {get}
}

/** Defines  a  subscription. */
public protocol YXSubscription: YXProduct {
    /** Expiration date of the subscription. */
    var expirationDate:Date{get}
}
