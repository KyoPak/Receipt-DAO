//
//  NumberFormatter+Extension.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/17.
//

import Foundation

extension NumberFormatter {
    static let standard = NumberFormatter()
    
    static func numberDecimal(from numberText: String) -> String {
        standard.numberStyle = .decimal
        
        let numbers = numberText.map { String($0) }
        guard let doubleValue = Double(numberText), let lastNumber = numbers.last else { return "" }
        
        if lastNumber == "." {
            return (standard.string(from: NSNumber(value: Int(doubleValue))) ?? "") + "."
        }
        
        if numbers.contains(".") && lastNumber == "0" {
            return (standard.string(from: NSNumber(value: Int(doubleValue))) ?? "") + ".0"
        }
        
        if doubleValue.truncatingRemainder(dividingBy: 1.0) == 0 {
            return standard.string(from: NSNumber(value: Int(doubleValue))) ?? ""
        } else {
            return standard.string(from: NSNumber(floatLiteral: doubleValue)) ?? ""
        }
    }
}
