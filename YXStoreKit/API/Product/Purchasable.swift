//
//  Purchasable.swift
//  YXStoreKit
//
//  Created by Yijie Xu on 12/22/19.
//  Copyright © 2019 yx. All rights reserved.
//

import Foundation

/** Defines the billing cycle of a subscription. e.g. month stands for a monthly subscription. */
public enum YXSubscriptionPeriod:CaseIterable {
    case day, week, month, year
}

/** Defines a product that user can purchase. */
public protocol YXProduct {
    /** A string uniquely identifies a purchasable product.  */
    var productIdentifier: String {get}
    
    /** The description of the product in the local language. */
    var localizedDescription: String {get}
    
    /** The title of the product in the local language. */
    var localizedTitle: String {get}
    
    /** A decimal number that stands for the price of the product. */
    var price: NSDecimalNumber {get}
    
    /** A locale of the price. */
    var priceLocale: Locale {get}
    
    /** The unit of billing cycle if the product is a subscription. */
    var subscriptionUnit: YXSubscriptionPeriod? {get}
    
    /**
     * The number of billing cycle if the product is a subscriotion.
     *
     * If the unit is week and number is 1 then it's a weekly subscription.
     * If the unit is week and number is 2 then it's a bi-weekly subscription.
     */
    var numberOfUnits: Int {get}
}

/** Defines  a  subscription. */
public protocol YXSubscription: YXProduct {
    /** Expiration date of the subscription. */
    var expirationDate:Date{get}
}
