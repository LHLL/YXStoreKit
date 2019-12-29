//
//  YXDictionaryTest.swift
//  YXStoreKitTests
//
//  Created by Yijie Xu on 12/22/19.
//  Copyright © 2019 yx. All rights reserved.
//

import XCTest

class YXDictionaryTest: XCTestCase {

    func testReadWrite() {
        var dict = YXDictionary<String,Int>()
        XCTAssertNil(dict["1"])
        dict["1"] = 1
        let result = dict["1"]
        XCTAssertNotNil(result)
        XCTAssert(result == 1)
        dict["1"] = 2
        let result2 = dict["1"]
        XCTAssertNotNil(result2)
        XCTAssert(result2 == 2)
    }
    
    func testDump(){
        var dict = YXDictionary<String,Int>()
        XCTAssertNil(dict["1"])
        dict["1"] = 1
        dict.dump(value: 1)
        XCTAssertNil(dict["1"])
    }

}
