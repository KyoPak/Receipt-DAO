//
//  Currency.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/07/02.
//

import Foundation

enum Currency: Int, CaseIterable {
    case KRW
    case USD
    case JPY
    
    var sign: String {
        switch self {
        case .KRW:
            return ConstantText.won
        case .USD:
            return ConstantText.dollar
        case .JPY:
            return ConstantText.yen
        }
    }
    
    var currencyImageText: String {
        switch self {
        case .KRW:
            return ConstantImage.wonSign
        case .USD:
            return ConstantImage.dollarSign
        case .JPY:
            return ConstantImage.yenSign
        }
    }
}

extension Currency: CustomStringConvertible {
    var description: String {
        switch self {
        case .KRW:
            return "KRW"
        case .USD:
            return "USD"
        case .JPY:
            return "JPY"
        }
    }
}
