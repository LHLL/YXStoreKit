//
//  FakeSKProductsRequest.swift
//  YXStoreKitTests
//
//  Created by Yijie Xu on 12/28/19.
//  Copyright © 2019 yx. All rights reserved.
//

import UIKit
import StoreKit

enum YXFakeRequestMode{
    // Request will instantly finish after [start] call.
    case normal
    // Request will not instantly finish after [start] call.
    // Uses this mode for testing [cancel].
    case idle
    // Request will not instantly finish after [start] call.
    // use this mode for duplicate requests.
    case delayed
}

class FakeSKProductsRequest: SKProductsRequest {
    
    private var productsIds: Set<String> = []
    private var invalidIds: [String] = []
    private var mode:YXFakeRequestMode = .normal
    
    convenience init(productIdentifiers: Set<String>, invalidIdentifiers:[String], requestMode:YXFakeRequestMode) {
        self.init(productIdentifiers: productIdentifiers)
        self.productsIds = productIdentifiers
        self.invalidIds = invalidIdentifiers
        self.mode = requestMode
    }
    
    override
    private init(productIdentifiers: Set<String>) {
        super.init(productIdentifiers: productIdentifiers)
    }
    
    override init() {
        super.init()
    }
    
    override
    func start() {
        switch mode {
        case .normal:
            sendRequest()
        case .delayed:
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                self.sendRequest()
            }
        case .idle:
            return
        }
    }
    
    override
    func cancel() {
        let error = YXError(domain: .products,
                            type: .userCancelled)
        delegate?.request?(self, didFailWithError: error)
    }
    
}

//MARK: Private Methods
extension FakeSKProductsRequest {
    private func sendRequest(){
        let response = FakeSKProductsResponse(productIdentifiers: productsIds,
                                              invalidIdentifiers: invalidIds)
        delegate?.productsRequest(self, didReceive: response)
        delegate?.requestDidFinish?(self)
    }
}
