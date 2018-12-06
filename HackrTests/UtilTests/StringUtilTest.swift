//
//  StringUtilTest.swift
//  Hackr
//
//  Created by Alejandrina Patron on 12/5/18.
//  Copyright © 2018 Alejandrina Patron. All rights reserved.
//

@testable import Hackr
import Foundation
import XCTest

class StringUtilTest: XCTestCase {
    
    func testGetSingularQuantityString() {
        let quantity = 1
        let singular = "apple"
        let plural = "apples"
        let quantityString = getQuantityString(for: quantity, singular: singular, plural: plural)
        XCTAssertEqual("1 apple", quantityString)
    }
    
    func testGetPluralQuantityString() {
        let quantity = 2
        let singular = "apple"
        let plural = "apples"
        let quantityString = getQuantityString(for: quantity, singular: singular, plural: plural)
        XCTAssertEqual("2 apples", quantityString)
    }
    
    func testGetZeroQuantityString() {
        let quantity = 0
        let singular = "apple"
        let plural = "apples"
        let quantityString = getQuantityString(for: quantity, singular: singular, plural: plural)
        XCTAssertEqual("0 apples", quantityString)
    }
    
}
