//
//  NumberFormatter+Extension.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/17.
//

import Foundation

extension NumberFormatter {
    static let standard = NumberFormatter()
    
    static func numberDecimal(from number: Int) -> String {
        standard.numberStyle = .decimal
        
        return standard.string(from: NSNumber(value: number)) ?? ""
    }
}
