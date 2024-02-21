//
//  OptionKeyType.swift
//  ReceiptManager
//
//  Created by parkhyo on 2/17/24.
//

import Foundation

// Private Setting Options Key and Title
enum OptionKeyType {
    case currency
    case payment
    
    var key: String {
        switch self {
        case .currency:
            return ConstantText.currencyKey
        case .payment:
            return ConstantText.paymentKey
        }
    }
    
    var title: String {
        switch self {
        case .currency:
            return ConstantText.currencySettingText.localize()
        case .payment:
            return ConstantText.payTypeSettingText.localize()
        }
    }
}
