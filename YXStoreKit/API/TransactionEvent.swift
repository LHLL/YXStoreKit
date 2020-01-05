//
//  TransactionProcessor.swift
//  YXStoreKit
//
//  Created by Yijie Xu on 12/31/19.
//  Copyright © 2019 yx. All rights reserved.
//

import Foundation

public enum YXTransactionEvent{
    // Processes transactions when app launches.
    case launch
    // Processes transactions when transactions changed
    // in the SKPaymentQueue.
    case update
}
