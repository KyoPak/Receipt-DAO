//
//  DateFormatter+Extension.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/05/16.
//

import Foundation

extension DateFormatter {
    static let standard = DateFormatter()
    
    static func string(from date: Date, _ format: String = "yyyy년 MM월") -> String {
        standard.dateFormat = format
        return standard.string(from: date)
    }
}
