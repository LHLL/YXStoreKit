//
//  Error.swift
//  YXStoreKit
//
//  Created by Yijie Xu on 12/22/19.
//  Copyright © 2019 yx. All rights reserved.
//

import Foundation

public enum YXErrorType:Equatable {
    // Unknown errors
    case unknown
    // Unexpected network requests.
    case unexpectedRequests
    // User cancelled a network request.
    case userCancelled
    // The validation for the App Store receipt failed.
    case receiptValidationFailed
    // The App Store receipt is not found on this device.
    // This could because user made the initial purchase on a different
    // device. (e.g. User has an iPhone and an iPad, made purchase on the
    // iPhone and tries to validate the receipt on the iPad.)
    case receiptMissing
    // The receipt URL provided by the client app is not correct.
    case wrongReceiptUrl
    // The response of the user from the data base is unexpected.
    case unexpectedUser
    // Passed-in user is different than the user that is managed by the
    // the framework.
    // This normally happens when the client app allows multiple logins.
    // When user switches the account, client app needs to create a new
    // instance of [YXLocalUserManager]
    case wrongUser
    // Custom error
    case normal(reason:String)
}

extension YXErrorType {
    var message:String {
        switch self {
        case .unknown:
            return "Unknown error"
        case .unexpectedRequests:
            return "There is an unexpected requests found."
        case .userCancelled:
            return "User cancelled the request."
        case .receiptValidationFailed:
            return "Cannot validate the App Store receipt."
        case .receiptMissing:
            return "Cannot find the App Store on this device."
        case .wrongReceiptUrl:
            return "The url that points to the receipt is not legit."
        case .unexpectedUser:
            return "Unexpected user object received from the database."
        case .wrongUser:
            return "Passed-in user is different than the current user."
        case .normal(let reason):
            return reason
        }
    }
}

public enum YXErrorDomain:Equatable {
    // Unknown errors
    case unknown
    // Error that is related to products fetching.
    case products
    // Error that is related to the transaction processing.
    case transaction
    // Error that is related to receipt validation.
    case receipt
    // Error that is related to the user.
    case user
}

extension YXErrorDomain {
    var message:String {
        switch self {
        case .unknown:
            return "com.yxstorekit.unknown"
        case .products:
            return "com.yxstorekit.products"
        case .transaction:
            return "com.yxstorekit.transaction"
        case .receipt:
            return "com.yxstorekit.receipt"
        case .user:
            return "com.yxstorekit.user"
        }
    }
}

/** Error object that is used in the framework. All public API will return this error instead of NSError or Error. */
public struct YXError:Error {
    let domain:YXErrorDomain
    let type:YXErrorType
}
