//
//  OptionKeyType.swift
//  ReceiptManager
//
//  Created by parkhyo on 2/17/24.
//

import Foundation

enum OptionKeyType: CustomStringConvertible {
    case currency
    case payment
    
    var description: String {
        switch self {
        case .currency:
            return ConstantText.currencyKey
        case .payment:
            return ConstantText.paymentKey
        }
    }
}
