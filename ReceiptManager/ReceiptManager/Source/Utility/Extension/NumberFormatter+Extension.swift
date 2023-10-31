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
        
        let texts = numberText.split(separator: ".").map { String($0) }
        
        guard texts.count != 0,
            let integer = Int(texts[0]),
            let integerText = standard.string(from: NSNumber(value: integer)) else {
            return ""
        }
        
        if texts.count == 2 {
            return integerText + "." + String(texts[1])
        }
        
        let numbers = numberText.map { String($0) }
        
        if texts.count == 1 && numbers.contains(".") {
            return integerText + "."
        }
                
        return integerText
    }
}
