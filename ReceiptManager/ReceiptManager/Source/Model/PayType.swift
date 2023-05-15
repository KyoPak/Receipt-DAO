//
//  PayType.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/04/28.
//

import Foundation

enum PayType: Int, CustomStringConvertible {
    case cash
    case card
    
    var description: String {
        switch self {
        case .cash:
            return "현금"
        case .card:
            return "카드"
        }
    }
}
