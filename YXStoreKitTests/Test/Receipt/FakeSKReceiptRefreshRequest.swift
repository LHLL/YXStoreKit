//
//  FakeSKReceiptRefreshRequest.swift
//  YXStoreKit
//
//  Created by Yijie Xu on 1/4/20.
//  Copyright © 2020 yx. All rights reserved.
//

import StoreKit

/** Testable implementation of [SKReceiptRefreshRequest]. */
class FakeSKReceiptRefreshRequest: SKReceiptRefreshRequest {
    
    private var mode:YXFakeRequestMode = .normal
    private var receipt:Data?
    private var url:URL?
    
    convenience init(requestMode:YXFakeRequestMode,
                     receiptData:Data? = nil,
                     receiptUrl: URL? = nil) {
        self.init(receiptProperties:nil)
        mode = requestMode
        receipt = receiptData
        url = receiptUrl
    }
    
    override
    private init() {
        super.init()
    }
    
    override
    private init(receiptProperties properties: [String : Any]?) {
        super.init(receiptProperties: properties)
    }
    
    override
    func start() {
        switch mode {
        case .normal:
            if let data = receipt, let url = url {
                try? data.write(to: url, options: .atomic)
            }
            delegate?.requestDidFinish?(self)
        case .delayed:
            if let data = receipt, let url = url {
                try? data.write(to: url, options: .atomic)
            }
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                self.delegate?.requestDidFinish?(self)
            }
        case .idle:
            return
        case .cancel:
            cancel()
        }
    }
    
    override
    func cancel() {
        let error = YXError(domain: .receipt,
                            type: .userCancelled)
        delegate?.request?(self, didFailWithError: error)
    }
}
