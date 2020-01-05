//
//  YXProductService.swift
//  YXStoreKit
//
//  Created by Yijie Xu on 12/22/19.
//  Copyright © 2019 yx. All rights reserved.
//

import Foundation

/**
 * Closure that provides callback for [fetchProducts] method defined in the [YXProductService].
 *
 * Needs to be used as @escaping.
 */
public typealias YXProductCompletion = ((
    _ products:[YXProduct],
    _ invalidIds:[String],
    _ error:YXError?
    )->Void)

public protocol YXProductService:AnyObject {
    /**
     * Fetches purchasable products.
     *
     * @param productIds A set of strings that each of them stands uniquely for a product.
     * @param callbackQueue A queue that completion closure will be called in. Default is main queue.
     * @param completion A closure to be invoked when the call is finished.
     */
    func fetchProducts(productIds:Set<String>,
                       callbackQueue:DispatchQueue,
                       completion: @escaping YXProductCompletion)
}
