//
//  PayType.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/04/28.
//

import Foundation

enum PayType: Int, CaseIterable {
    case cash
    case card
}

extension PayType: CustomStringConvertible {
    var description: String {
        switch self {
        case .cash:
            return ConstantText.cash.localize()
        case .card:
            return ConstantText.card.localize()
        }
    }
}
