//
//  PayType.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/04/28.
//

import Foundation

enum PayType: Int, CustomStringConvertible {
    case card
    case cash
    
    var description: String {
        switch self {
        case .card:
            return "카드"
        case .cash:
            return "현금"
        }
    }
}
