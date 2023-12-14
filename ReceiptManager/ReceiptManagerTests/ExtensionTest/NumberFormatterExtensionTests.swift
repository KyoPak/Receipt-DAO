//
//  NumberFormatterExtensionTests.swift
//  ReceiptManagerTests
//
//  Created by parkhyo on 12/14/23.
//

import XCTest
@testable import ReceiptManager

final class NumberFormatterExtensionTests: XCTestCase {
    func test_when_numberString() {
        let targetText = "1234567"
        let correct = "1,234,567"
        
        XCTAssertEqual(correct, NumberFormatter.numberDecimal(from: targetText))
    }
    
    func test_when_numberString_have_point() {
        let targetText = "1234567.123456"
        let correct = "1,234,567.123456"
        
        XCTAssertEqual(correct, NumberFormatter.numberDecimal(from: targetText))
    }
    
    func test_when_notNumberString() {
        let targetText = "Test"
        let correct = ""
        
        XCTAssertEqual(correct, NumberFormatter.numberDecimal(from: targetText))
    }
    
    func test_when_notNumberString_have_point() {
        let targetText = "123.Test"
        let correct = "123"
        
        XCTAssertEqual(correct, NumberFormatter.numberDecimal(from: targetText))
    }
    
    func test_when_notNumberString_have_point_trailing() {
        let targetText = "Test.12345"
        let correct = ""
        
        XCTAssertEqual(correct, NumberFormatter.numberDecimal(from: targetText))
    }
}
