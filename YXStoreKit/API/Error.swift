//
//  Error.swift
//  YXStoreKit
//
//  Created by Yijie Xu on 12/22/19.
//  Copyright © 2019 yx. All rights reserved.
//

import Foundation

public enum YXErrorType {
    case unknown
    case duplicateRequests
    case normal(reason:String)
}

extension YXErrorType {
    var message:String {
        switch self {
        case .unknown:
            return "Unknown error"
        case .duplicateRequests:
            return "There is a same request pending."
        case .normal(let reason):
            return reason
        }
    }
}

public struct YXError {
    let domain:String
    let type:YXErrorType
}
