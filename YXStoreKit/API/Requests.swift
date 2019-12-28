//
//  Requests.swift
//  YXStoreKit
//
//  Created by Yijie Xu on 12/22/19.
//  Copyright © 2019 yx. All rights reserved.
//

import Foundation
import StoreKit

/** A request objects that  */
public protocol YXProductsRequest {
    init(productIdentifiers: Set<String>)
    var delegate: SKProductsRequestDelegate?{get set}
}
