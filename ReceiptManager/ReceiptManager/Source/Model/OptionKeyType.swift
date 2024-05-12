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
    case displayMode
    case sync
    
    var key: String {
        switch self {
        case .currency:
            return ConstantKey.currencyKey
        case .payment:
            return ConstantKey.paymentKey
        case .displayMode:
            return ConstantKey.displayModeKey
        case .sync:
            return ConstantKey.dataSyncKey
        }
    }
    
    var title: String {
        switch self {
        case .currency:
            return ConstantText.currencySettingText.localize()
        case .payment:
            return ConstantText.payTypeSettingText.localize()
        case .displayMode:
            return ConstantText.displayModeSettingText.localize()
        case .sync:
            return ""
        }
    }
}
