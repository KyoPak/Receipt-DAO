//
//  OCRResult.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/06/01.
//

import Foundation

struct OCRResult {
    var date: Date = Date()
    var store: String = ""
    var price: Int = .zero
    var paymentType: Int = PayType.cash.rawValue
}
