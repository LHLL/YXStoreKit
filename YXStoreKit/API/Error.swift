//
//  Error.swift
//  YXStoreKit
//
//  Created by Yijie Xu on 12/22/19.
//  Copyright © 2019 yx. All rights reserved.
//

import Foundation

public enum YXErrorType:Equatable {
    case unknown
    case duplicateRequests
    case unexpectedRequests
    case userCancelled
    case receipt
    case normal(reason:String)
}

extension YXErrorType {
    var message:String {
        switch self {
        case .unknown:
            return "Unknown error"
        case .duplicateRequests:
            return "There is a same request pending."
        case .unexpectedRequests:
            return "There is an unexpected requests found."
        case .userCancelled:
            return "User cancelled the request."
        case .receipt:
            return "Cannot validate the App Store receipt."
        case .normal(let reason):
            return reason
        }
    }
}

public enum YXErrorDomain:Equatable {
    case unknown
    case products
    case transaction
    case receiptValidation
    case receiptMissing
}

extension YXErrorDomain {
    var message:String {
        switch self {
        case .unknown:
            return "Unknown domain"
        case .products:
            return "com.yxstorekit.products"
        case .transaction:
            return "com.yxstorekit.transaction"
        case .receiptValidation:
            return "com.yxstorekit.receiptValidation"
        case .receiptMissing:
            return "com.yxstrorekit.receiptMissing"
        }
    }
}

public struct YXError:Error {
    let domain:YXErrorDomain
    let type:YXErrorType
}
