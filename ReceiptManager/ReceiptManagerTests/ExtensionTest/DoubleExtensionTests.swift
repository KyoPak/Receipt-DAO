//
//  DoubleExtensionTests.swift
//  ReceiptManagerTests
//
//  Created by parkhyo on 12/14/23.
//

import XCTest
@testable import ReceiptManager

final class DoubleExtensionTests: XCTestCase {
    func test_when_Double_canNotConvertIntString() {
        let target = 123.456
        let correct = target.description
        
        XCTAssertEqual(target.convertString(), correct)
    }
    
    func test_when_Double_canConvertIntString() {
        let target = 123
        let correct = target.description
        
        XCTAssertEqual(Double(target).convertString(), correct)
    }
    
    func test_when_zero() {
        XCTAssertEqual(Double.zero.convertString(), "")
    }
}
